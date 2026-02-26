// NOVA
import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let apiKey: String
    private let logger = CMCLogger.shared

    init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw AppError.unknown("Invalid URL for endpoint")
        }

        let requestID = UUID().uuidString.prefix(8).description
        var urlRequest = URLRequest(url: url, timeoutInterval: 15)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        logger.logRequest(id: requestID, url: url, apiKey: apiKey)

        let startTime = Date()
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
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

        // Single shared decoder — use CodingKeys in DTOs (NOT convertFromSnakeCase)
        // to avoid conflicts when CodingKeys are manually defined
        let decoder = JSONDecoder()
        // Do NOT use .convertFromSnakeCase — all DTOs use explicit CodingKeys for snake_case fields
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.logDecodingError(id: requestID, url: url, error: error, data: data)
            throw AppError.decodingError
        }
    }
}
