//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

#if DEBUG
import Foundation
import SwiftUI

enum PreviewFixtures {
    static let sampleLogoURL = URL(string: "https://example.com/logo.png")

    static let exchange: Exchange = Exchange(
        id: 1,
        name: "Example Exchange",
        slug: "example-exchange",
        logo: nil,
        description: "A sample exchange used only for SwiftUI previews.",
        websiteURL: URL(string: "https://example.com"),
        dateLaunched: Date(timeIntervalSince1970: 1_600_000_000),
        spotVolumeUSD: 12_345_678_901,
        makerFee: 0.12,
        takerFee: 0.22,
        weeklyVisits: 123_456,
        spot: 1
    )

    static let exchanges: [Exchange] = {
        var list: [Exchange] = []
        list.reserveCapacity(8)
        for i in 1...8 {
            let description: String? = (i % 2 == 0) ? "Description for Exchange \(i)." : nil
            let website = URL(string: "https://example.com/exchange\(i)")
            let launched = Date(timeIntervalSince1970: 1_550_000_000 + Double(i) * 86_400)
            let volume: Double = Double(1_000_000_000 * i)
            let weekly: Int = 10_000 * i

            let exchange = Exchange(
                id: i,
                name: "Exchange \(i)",
                slug: "exchange-\(i)",
                logo: nil,
                description: description,
                websiteURL: website,
                dateLaunched: launched,
                spotVolumeUSD: volume,
                makerFee: 0.10,
                takerFee: 0.20,
                weeklyVisits: weekly,
                spot: i
            )
            list.append(exchange)
        }
        return list
    }()

    static let marketPair: ExchangeMarketPair = ExchangeMarketPair(
        id: "BTC_USDT",
        marketPairBase: MarketCurrency(currencyID: 1, currencySymbol: "BTC", exchangeSymbol: "BTC", currencyType: "crypto"),
        marketPairQuote: MarketCurrency(currencyID: 2, currencySymbol: "USDT", exchangeSymbol: "USDT", currencyType: "crypto"),
        priceUSD: 64_321.12,
        volumeUSD24h: 12_345_678.9,
        lastUpdated: Date(timeIntervalSince1970: 1_700_000_000)
    )

    static let marketPairs: [ExchangeMarketPair] = [
        marketPair,
        ExchangeMarketPair(
            id: "ETH_USDT",
            marketPairBase: MarketCurrency(currencyID: 1027, currencySymbol: "ETH", exchangeSymbol: "ETH", currencyType: "crypto"),
            marketPairQuote: MarketCurrency(currencyID: 2, currencySymbol: "USDT", exchangeSymbol: "USDT", currencyType: "crypto"),
            priceUSD: 3_210.55,
            volumeUSD24h: 9_876_543.21,
            lastUpdated: Date(timeIntervalSince1970: 1_700_000_000)
        ),
        ExchangeMarketPair(
            id: "SOL_USDT",
            marketPairBase: MarketCurrency(currencyID: 5426, currencySymbol: "SOL", exchangeSymbol: "SOL", currencyType: "crypto"),
            marketPairQuote: MarketCurrency(currencyID: 2, currencySymbol: "USDT", exchangeSymbol: "USDT", currencyType: "crypto"),
            priceUSD: 145.321,
            volumeUSD24h: 1_234_567.0,
            lastUpdated: Date(timeIntervalSince1970: 1_700_000_000)
        )
    ]
}

// MARK: - Preview Mocks (UseCases)

struct MockGetExchangeListUseCase: GetExchangeListUseCaseProtocol {
    enum Mode {
        case success([Exchange])
        case empty
        case failure(AppError)
    }

    let mode: Mode

    func execute(start: Int, limit: Int) async throws -> [Exchange] {
        switch mode {
        case .success(let list):
            return Array(list.prefix(limit))
        case .empty:
            return []
        case .failure(let error):
            throw error
        }
    }
}

struct MockGetExchangeDetailUseCase: GetExchangeDetailUseCaseProtocol {
    enum Mode {
        case success(Exchange)
        case failure(AppError)
    }

    let mode: Mode

    func execute(id: Int) async throws -> Exchange {
        switch mode {
        case .success(let exchange):
            return exchange
        case .failure(let error):
            throw error
        }
    }
}

struct MockGetExchangeMarketPairsUseCase: GetExchangeMarketPairsUseCaseProtocol {
    enum Mode {
        case success([ExchangeMarketPair])
        case empty
        case failure(AppError)
    }

    let mode: Mode

    func execute(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair] {
        switch mode {
        case .success(let pairs):
            return Array(pairs.prefix(limit))
        case .empty:
            return []
        case .failure(let error):
            throw error
        }
    }
}

#endif

