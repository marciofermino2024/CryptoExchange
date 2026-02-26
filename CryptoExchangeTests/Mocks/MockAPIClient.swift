// NOVA
import Foundation
@testable import CryptoExchange

final class MockAPIClient: APIClientProtocol {
    var result: Any?
    var error: Error?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error = error { throw error }
        if let result = result as? T { return result }
        throw AppError.decodingError
    }
}
