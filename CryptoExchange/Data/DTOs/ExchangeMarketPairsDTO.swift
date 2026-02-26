// NOVA
import Foundation

// GET /v1/exchange/market-pairs/latest response
struct ExchangeMarketPairsResponseDTO: Decodable {
    let status: StatusDTO
    let data: ExchangeMarketPairsDataDTO
}

struct ExchangeMarketPairsDataDTO: Decodable {
    let id: Int
    let name: String
    let numMarketPairs: Int?
    let marketPairs: [MarketPairDTO]?

    enum CodingKeys: String, CodingKey {
        case id, name
        case numMarketPairs = "num_market_pairs"
        case marketPairs = "market_pairs"
    }
}

struct MarketPairDTO: Decodable {
    let rankId: Int?
    let marketId: Int?
    let marketPairBase: MarketPairCurrencyDTO?
    let marketPairQuote: MarketPairCurrencyDTO?
    let quote: MarketPairQuoteContainerDTO?

    enum CodingKeys: String, CodingKey {
        case rankId = "rank_id"
        case marketId = "market_id"
        case marketPairBase = "market_pair_base"
        case marketPairQuote = "market_pair_quote"
        case quote
    }
}

struct MarketPairCurrencyDTO: Decodable {
    let currencyId: Int?
    let currencySymbol: String?
    let exchangeSymbol: String?
    let currencyType: String?

    enum CodingKeys: String, CodingKey {
        case currencyId = "currency_id"
        case currencySymbol = "currency_symbol"
        case exchangeSymbol = "exchange_symbol"
        case currencyType = "currency_type"
    }
}

struct MarketPairQuoteContainerDTO: Decodable {
    let exchangeReported: MarketPairQuoteDTO?
    let usd: MarketPairQuoteDTO?

    enum CodingKeys: String, CodingKey {
        case exchangeReported = "exchange_reported"
        case usd = "USD"
    }
}

struct MarketPairQuoteDTO: Decodable {
    let price: Double?
    let volume24hBase: Double?
    let volume24hQuote: Double?
    let volume24hUsd: Double?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case price
        case volume24hBase = "volume_24h_base"
        case volume24hQuote = "volume_24h_quote"
        case volume24hUsd = "volume_24h"
        case lastUpdated = "last_updated"
    }
}
