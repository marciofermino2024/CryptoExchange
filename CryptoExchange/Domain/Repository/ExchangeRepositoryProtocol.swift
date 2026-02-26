// NOVA
import Foundation

protocol ExchangeRepositoryProtocol {
    func fetchExchangeList(start: Int, limit: Int) async throws -> [Exchange]
    func fetchExchangeDetail(id: Int) async throws -> Exchange
    func fetchExchangeMarketPairs(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair]
}
