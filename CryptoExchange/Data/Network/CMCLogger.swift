//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation
import os.log

// MARK: - Image Log Entry

struct ImageLogEntry {
    let url: String
    let statusCode: Int?
    let latencyMS: Double
    let bytes: Int?
    let mimeType: String?
    let cacheHit: Bool
    let failureReason: String?
    let timestamp: Date

    var summary: String {
        let status = statusCode.map { "\($0)" } ?? "—"
        let cache = cacheHit ? "✅HIT" : "❌MISS"
        let ms = String(format: "%.0f", latencyMS)
        let size = bytes.map { "\($0)B" } ?? "—"
        return "[\(cache)] \(status) \(ms)ms \(size) \(url)"
    }
}

// MARK: - CMCLogger

final class CMCLogger {
    static let shared = CMCLogger()

    private let apiLogger = Logger(subsystem: "com.meubanco.cryptoexchange", category: "CMC")
    private let imgLogger = Logger(subsystem: "com.meubanco.cryptoexchange", category: "IMG")

    struct RequestLog {
        let requestID: String
        let url: String
        let statusCode: Int?
        let latencyMS: Double?
        let bodySizeBytes: Int?
        let error: String?
        let jsonSnippet: String?
        let decodingPath: String?
    }

    // Last API error for debug sheet
    private(set) var lastErrorContext: RequestLog?

    // Last 20 image logs for debug sheet
    private var _imageLogs: [ImageLogEntry] = []
    private let imageLogsLock = NSLock()

    var imageLogs: [ImageLogEntry] {
        imageLogsLock.lock()
        defer { imageLogsLock.unlock() }
        return _imageLogs
    }

    private init() {}

    // MARK: - API Logging

    func logRequest(id: String, url: URL, apiKey: String) {
        let masked = maskAPIKey(apiKey)
        #if DEBUG
        apiLogger.debug("[CMC] ▶ id=\(id) url=\(url.absoluteString) key=***\(masked)")
        #endif
    }

    func logResponse(id: String, url: URL, statusCode: Int, latencyMS: Double, bodySize: Int) {
        #if DEBUG
        apiLogger.debug("[CMC] ◀ id=\(id) status=\(statusCode) \(String(format: "%.0f", latencyMS))ms \(bodySize)B")
        #else
        if statusCode >= 400 {
            apiLogger.error("[CMC] ◀ id=\(id) status=\(statusCode)")
        }
        #endif
    }

    func logDecodingError(id: String, url: URL, error: Error, data: Data) {
        let snippet = String(data: data.prefix(1500), encoding: .utf8) ?? "<non-utf8>"
        let path = decodingErrorDescription(error)

        #if DEBUG
        apiLogger.error("[CMC] ✖ DECODE id=\(id) path=\(path)")
        apiLogger.error("[CMC] ✖ JSON: \(snippet)")
        #else
        apiLogger.error("[CMC] ✖ DECODE id=\(id)")
        #endif

        lastErrorContext = RequestLog(
            requestID: id,
            url: url.absoluteString,
            statusCode: nil,
            latencyMS: nil,
            bodySizeBytes: data.count,
            error: path,
            jsonSnippet: snippet,
            decodingPath: path
        )
    }

    func logNetworkError(id: String, url: URL, error: Error, statusCode: Int? = nil) {
        #if DEBUG
        apiLogger.error("[CMC] ✖ NET id=\(id) status=\(statusCode ?? -1) err=\(error.localizedDescription)")
        #else
        apiLogger.error("[CMC] ✖ NET id=\(id) status=\(statusCode ?? -1)")
        #endif

        lastErrorContext = RequestLog(
            requestID: id,
            url: url.absoluteString,
            statusCode: statusCode,
            latencyMS: nil,
            bodySizeBytes: nil,
            error: error.localizedDescription,
            jsonSnippet: nil,
            decodingPath: nil
        )
    }

    // MARK: - Image Logging

    func logLogoURL(exchangeId: Int, name: String, logoURL: String?) {
        #if DEBUG
        if let url = logoURL, !url.isEmpty {
            imgLogger.debug("[IMG] exchange id=\(exchangeId) name=\(name) logoURL=\(url)")
        } else {
            imgLogger.warning("[IMG] ⚠️ MISSING LOGO id=\(exchangeId) name=\(name)")
        }
        #endif
    }

    func logImageResult(url: String, statusCode: Int?, latencyMS: Double, bytes: Int?,
                        mimeType: String?, cacheHit: Bool, failureReason: String?) {
        let entry = ImageLogEntry(
            url: url, statusCode: statusCode, latencyMS: latencyMS,
            bytes: bytes, mimeType: mimeType, cacheHit: cacheHit,
            failureReason: failureReason, timestamp: Date()
        )

        imageLogsLock.lock()
        _imageLogs.insert(entry, at: 0)
        if _imageLogs.count > 20 { _imageLogs = Array(_imageLogs.prefix(20)) }
        imageLogsLock.unlock()

        #if DEBUG
        if let reason = failureReason {
            imgLogger.error("[IMG] ✖ \(url) reason=\(reason)")
        } else {
            imgLogger.debug("[IMG] ✔ \(entry.summary)")
        }
        #endif
    }

    // MARK: - Helpers

    func maskAPIKey(_ key: String) -> String {
        guard key.count >= 4 else { return "****" }
        return String(key.suffix(4))
    }

    private func decodingErrorDescription(_ error: Error) -> String {
        guard let decErr = error as? DecodingError else { return error.localizedDescription }
        switch decErr {
        case .keyNotFound(let key, let ctx):
            return "keyNotFound('\(key.stringValue)') @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        case .typeMismatch(let type, let ctx):
            return "typeMismatch(\(type)) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        case .valueNotFound(let type, let ctx):
            return "valueNotFound(\(type)) @ \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let ctx):
            return "dataCorrupted @ \(ctx.codingPath.map(\.stringValue).joined(separator: ".")): \(ctx.debugDescription)"
        @unknown default:
            return error.localizedDescription
        }
    }
}
