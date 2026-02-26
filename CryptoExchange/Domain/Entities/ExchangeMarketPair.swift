// NOVA
import Foundation

struct ExchangeMarketPair: Identifiable, Equatable {
    let id: String
    let marketPairBase: MarketCurrency
    let marketPairQuote: MarketCurrency
    let priceUSD: Double?
    let volumeUSD24h: Double?
    let lastUpdated: Date?
}

struct MarketCurrency: Equatable {
    let currencyID: Int
    let currencySymbol: String
    let exchangeSymbol: String
    let currencyType: String
}
