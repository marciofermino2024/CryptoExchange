//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI
import Foundation

// MARK: - Image Load State

enum ImageLoadState {
    case idle
    case loading
    case success(Image)
    case failure(String)
}

// MARK: - ImageLoader (Actor — thread-safe)

actor ImageLoader {
    static let shared = ImageLoader()

    // In-memory cache: URL string → UIImage data
    private let cache = NSCache<NSString, NSData>()
    // Tracks in-flight tasks to avoid duplicate downloads
    private var inFlight: [String: Task<Data?, Never>] = [:]
    // Concurrency limit: max 6 simultaneous downloads
    private var activeCount = 0
    private let maxConcurrent = 6
    // Queue of waiting continuations
    private var waitQueue: [CheckedContinuation<Void, Never>] = []

    private let session: URLSession
    private let logger = CMCLogger.shared

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        // Limit URLSession connections to avoid saturation
        config.httpMaximumConnectionsPerHost = 6
        session = URLSession(configuration: config)
    }

    func loadImage(from urlString: String) async -> ImageLoadState {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            logger.logImageResult(url: urlString, statusCode: nil, latencyMS: 0,
                                  bytes: nil, mimeType: nil, cacheHit: false,
                                  failureReason: "invalid URL string")
            return .failure("Invalid URL")
        }

        // Cache hit?
        if let cached = cache.object(forKey: urlString as NSString) {
            let data = cached as Data
            if let uiImage = makeImage(from: data) {
                logger.logImageResult(url: urlString, statusCode: 200, latencyMS: 0,
                                      bytes: data.count, mimeType: nil, cacheHit: true,
                                      failureReason: nil)
                return .success(Image(uiImage: uiImage))
            }
        }

        // De-duplicate: if already in-flight, wait for that task
        if let existing = inFlight[urlString] {
            if let data = await existing.value, let uiImage = makeImage(from: data) {
                return .success(Image(uiImage: uiImage))
            }
            return .failure("Duplicate request failed")
        }

        // Concurrency gate
        await waitForSlot()

        let startTime = Date()
        let task = Task<Data?, Never> {
            do {
                var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
                request.setValue("image/png,image/jpeg,image/webp,image/*", forHTTPHeaderField: "Accept")
                let (data, response) = try await session.data(for: request)
                let http = response as? HTTPURLResponse
                let ms = Date().timeIntervalSince(startTime) * 1000
                let mime = http?.mimeType
                let code = http?.statusCode ?? 200

                if code == 200 {
                    logger.logImageResult(url: urlString, statusCode: code, latencyMS: ms,
                                          bytes: data.count, mimeType: mime, cacheHit: false,
                                          failureReason: nil)
                    return data
                } else {
                    logger.logImageResult(url: urlString, statusCode: code, latencyMS: ms,
                                          bytes: data.count, mimeType: nil, cacheHit: false,
                                          failureReason: "HTTP \(code)")
                    return nil
                }
            } catch {
                let ms = Date().timeIntervalSince(startTime) * 1000
                let reason: String
                if let urlErr = error as? URLError {
                    switch urlErr.code {
                    case .timedOut: reason = "timeout"
                    case .notConnectedToInternet: reason = "offline"
                    case .cancelled: reason = "cancelled"
                    default: reason = "URLError(\(urlErr.code.rawValue))"
                    }
                } else {
                    reason = error.localizedDescription
                }
                logger.logImageResult(url: urlString, statusCode: nil, latencyMS: ms,
                                      bytes: nil, mimeType: nil, cacheHit: false,
                                      failureReason: reason)
                return nil
            }
        }

        inFlight[urlString] = task
        let data = await task.value
        inFlight.removeValue(forKey: urlString)
        releaseSlot()

        guard let data else { return .failure("Download failed") }

        // Store in cache
        cache.setObject(data as NSData, forKey: urlString as NSString, cost: data.count)

        if let uiImage = makeImage(from: data) {
            return .success(Image(uiImage: uiImage))
        }
        logger.logImageResult(url: urlString, statusCode: 200, latencyMS: 0,
                              bytes: data.count, mimeType: nil, cacheHit: false,
                              failureReason: "Invalid image data")
        return .failure("Invalid image data")
    }

    func cancelAll() {
        inFlight.values.forEach { $0.cancel() }
        inFlight.removeAll()
    }

    // MARK: - Concurrency gate

    private func waitForSlot() async {
        if activeCount < maxConcurrent {
            activeCount += 1
            return
        }
        await withCheckedContinuation { continuation in
            waitQueue.append(continuation)
        }
        activeCount += 1
    }

    private func releaseSlot() {
        activeCount = max(0, activeCount - 1)
        if !waitQueue.isEmpty {
            let next = waitQueue.removeFirst()
            next.resume()
        }
    }

    // MARK: - Helpers

    private func makeImage(from data: Data) -> UIImage? {
        UIImage(data: data)
    }
}

// MARK: - CachedLogoView

/// Drop-in replacement for AsyncImage with caching, concurrency limiting, and logging.
struct CachedLogoView: View {
    let url: URL?
    let size: CGFloat

    @State private var state: ImageLoadState = .idle

    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .frame(width: size, height: size)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            case .failure:
                Image(systemName: "building.2")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .foregroundColor(.secondary)
                    .frame(width: size, height: size)
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: size * 0.167))
        .task(id: url?.absoluteString) {
            if isRunningForPreviews {
                // Keep previews offline and deterministic.
                state = .success(Image(systemName: "building.2"))
                return
            }
            guard let urlString = url?.absoluteString else {
                state = .failure("No URL")
                return
            }
            state = .loading
            state = await ImageLoader.shared.loadImage(from: urlString)
        }
    }
}

#if DEBUG

#Preview("CachedLogoView · Light") {
    CachedLogoView(url: PreviewFixtures.sampleLogoURL, size: 56)
        .padding()
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("CachedLogoView · Dark") {
    CachedLogoView(url: PreviewFixtures.sampleLogoURL, size: 56)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("CachedLogoView · A11y") {
    CachedLogoView(url: PreviewFixtures.sampleLogoURL, size: 56)
        .padding()
        .dynamicTypeSize(.accessibility3)
}

#endif
