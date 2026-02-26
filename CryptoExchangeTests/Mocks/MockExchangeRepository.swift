// NOVA
import Foundation
@testable import CryptoExchange

final class MockExchangeRepository: ExchangeRepositoryProtocol {
    var exchangeListResult: Result<[Exchange], Error> = .success([])
    var exchangeDetailResult: Result<Exchange, Error> = .success(.stub())
    var marketPairsResult: Result<[ExchangeMarketPair], Error> = .success([])

    func fetchExchangeList(start: Int, limit: Int) async throws -> [Exchange] {
        try exchangeListResult.get()
    }

    func fetchExchangeDetail(id: Int) async throws -> Exchange {
        try exchangeDetailResult.get()
    }

    func fetchExchangeMarketPairs(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair] {
        try marketPairsResult.get()
    }
}

extension Exchange {
    static func stub(
        id: Int = 1,
        name: String = "Binance",
        slug: String = "binance",
        spotVolumeUSD: Double? = 1_000_000_000,
        dateLaunched: Date? = Date(timeIntervalSince1970: 0)
    ) -> Exchange {
        Exchange(
            id: id,
            name: name,
            slug: slug,
            logo: URL(string: "https://example.com/logo.png"),
            description: "Test exchange",
            websiteURL: URL(string: "https://example.com"),
            dateLaunched: dateLaunched,
            spotVolumeUSD: spotVolumeUSD,
            makerFee: 0.001,
            takerFee: 0.002,
            weeklyVisits: 100000,
            spot: 500
        )
    }
}

extension ExchangeMarketPair {
    static func stub(id: String = "1") -> ExchangeMarketPair {
        ExchangeMarketPair(
            id: id,
            marketPairBase: MarketCurrency(currencyID: 1, currencySymbol: "BTC", exchangeSymbol: "BTC", currencyType: "cryptocurrency"),
            marketPairQuote: MarketCurrency(currencyID: 2328, currencySymbol: "USDT", exchangeSymbol: "USDT", currencyType: "cryptocurrency"),
            priceUSD: 50000.0,
            volumeUSD24h: 500_000_000,
            lastUpdated: nil
        )
    }
}
