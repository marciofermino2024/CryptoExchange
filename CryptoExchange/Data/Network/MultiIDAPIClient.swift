//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

/// Fetches /v1/exchange/info for multiple IDs in a single request.
/// CoinMarketCap supports comma-separated IDs in the `id` query parameter.
final class MultiIDAPIClient {
    private let session: URLSession
    private let apiKey: String
    private let logger = CMCLogger.shared

    init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func requestExchangeInfo(ids: [Int]) async throws -> ExchangeInfoResponseDTO {
        var components = URLComponents(string: "https://pro-api.coinmarketcap.com/v1/exchange/info")
        components?.queryItems = [
            URLQueryItem(name: "id", value: ids.map { "\($0)" }.joined(separator: ","))
        ]

        guard let url = components?.url else {
            throw AppError.unknown("Invalid URL for multi-ID exchange info")
        }

        let requestID = UUID().uuidString.prefix(8).description
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        logger.logRequest(id: requestID, url: url, apiKey: apiKey)

        let startTime = Date()
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            logger.logNetworkError(id: requestID, url: url, error: urlError)
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw AppError.networkOffline
            } else if urlError.code == .timedOut {
                throw AppError.timeout
            }
            throw AppError.unknown(urlError.localizedDescription)
        }

        let latencyMS = Date().timeIntervalSince(startTime) * 1000
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown("Invalid response type")
        }

        logger.logResponse(id: requestID, url: url, statusCode: httpResponse.statusCode,
                           latencyMS: latencyMS, bodySize: data.count)

        guard httpResponse.statusCode == 200 else {
            let err = AppError.httpError(statusCode: httpResponse.statusCode)
            logger.logNetworkError(id: requestID, url: url, error: err, statusCode: httpResponse.statusCode)
            throw err
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(ExchangeInfoResponseDTO.self, from: data)
        } catch {
            logger.logDecodingError(id: requestID, url: url, error: error, data: data)
            throw AppError.decodingError
        }
    }
}
