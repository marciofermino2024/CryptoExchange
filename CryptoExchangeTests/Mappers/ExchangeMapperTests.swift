// NOVA
import XCTest
@testable import CryptoExchange

final class ExchangeMapperTests: XCTestCase {

    func test_mapInfoDTO_allFieldsPresent() {
        let dto = ExchangeInfoDTO(
            id: 270,
            name: "Binance",
            slug: "binance",
            logo: "https://s2.coinmarketcap.com/static/img/exchanges/64x64/270.png",
            description: "World's largest exchange",
            dateLaunched: "2017-07-14T00:00:00.000Z",
            notice: nil,
            spotVolumeUsd: 10_000_000_000,
            makerFee: 0.001,
            takerFee: 0.001,
            weeklyVisits: 5_000_000,
            spot: 1000,
            urls: ExchangeURLsDTO(
                website: ["https://binance.com"],
                blog: nil, chat: nil, fee: nil, twitter: nil
            )
        )

        let exchange = ExchangeMapper.map(dto)

        XCTAssertEqual(exchange.id, 270)
        XCTAssertEqual(exchange.name, "Binance")
        XCTAssertEqual(exchange.slug, "binance")
        XCTAssertNotNil(exchange.logo)
        XCTAssertEqual(exchange.logo?.absoluteString, "https://s2.coinmarketcap.com/static/img/exchanges/64x64/270.png")
        XCTAssertEqual(exchange.description, "World's largest exchange")
        XCTAssertEqual(exchange.spotVolumeUSD, 10_000_000_000)
        XCTAssertEqual(exchange.makerFee, 0.001)
        XCTAssertEqual(exchange.takerFee, 0.001)
        XCTAssertNotNil(exchange.dateLaunched)
        XCTAssertNotNil(exchange.websiteURL)
        XCTAssertEqual(exchange.websiteURL?.absoluteString, "https://binance.com")
    }

    func test_mapInfoDTO_nilOptionalFields_producesNilDomainFields() {
        let dto = ExchangeInfoDTO(
            id: 1, name: "Test", slug: "test",
            logo: nil, description: nil, dateLaunched: nil, notice: nil,
            spotVolumeUsd: nil, makerFee: nil, takerFee: nil,
            weeklyVisits: nil, spot: nil, urls: nil
        )

        let exchange = ExchangeMapper.map(dto)

        XCTAssertNil(exchange.logo)
        XCTAssertNil(exchange.description)
        XCTAssertNil(exchange.dateLaunched)
        XCTAssertNil(exchange.spotVolumeUSD)
        XCTAssertNil(exchange.makerFee)
        XCTAssertNil(exchange.takerFee)
        XCTAssertNil(exchange.websiteURL)
    }

    func test_mapInfoDTO_invalidDateString_producesNilDate() {
        let dto = ExchangeInfoDTO(
            id: 1, name: "X", slug: "x",
            logo: nil, description: nil,
            dateLaunched: "not-a-date", notice: nil,
            spotVolumeUsd: nil, makerFee: nil, takerFee: nil,
            weeklyVisits: nil, spot: nil, urls: nil
        )

        let exchange = ExchangeMapper.map(dto)
        XCTAssertNil(exchange.dateLaunched, "Invalid date string should produce nil, not crash")
    }

    func test_mapMarketPairDTO_validPair() {
        let dto = MarketPairDTO(
            rankId: 1,
            marketId: 101,
            marketPairBase: MarketPairCurrencyDTO(
                currencyId: 1, currencySymbol: "BTC",
                exchangeSymbol: "BTC", currencyType: "cryptocurrency"
            ),
            marketPairQuote: MarketPairCurrencyDTO(
                currencyId: 825, currencySymbol: "USDT",
                exchangeSymbol: "USDT", currencyType: "cryptocurrency"
            ),
            quote: MarketPairQuoteContainerDTO(
                exchangeReported: nil,
                usd: MarketPairQuoteDTO(
                    price: 50000.0, volume24hBase: 1000.0,
                    volume24hQuote: 50_000_000.0, volume24hUsd: 50_000_000.0,
                    lastUpdated: nil
                )
            )
        )

        let pair = MarketPairMapper.map(dto, index: 0)

        XCTAssertNotNil(pair)
        XCTAssertEqual(pair?.id, "101")
        XCTAssertEqual(pair?.marketPairBase.currencySymbol, "BTC")
        XCTAssertEqual(pair?.marketPairQuote.currencySymbol, "USDT")
        XCTAssertEqual(pair?.priceUSD, 50000.0)
        XCTAssertEqual(pair?.volumeUSD24h, 50_000_000.0)
    }

    func test_mapMarketPairDTO_missingBase_returnsNil() {
        let dto = MarketPairDTO(rankId: 1, marketId: 101, marketPairBase: nil, marketPairQuote: nil, quote: nil)
        XCTAssertNil(MarketPairMapper.map(dto, index: 0))
    }

    func test_mapFromFixture_exchangeInfo() throws {
        guard let url = Bundle(for: type(of: self)).url(forResource: "exchange_info_response", withExtension: "json") else {
            throw XCTSkip("Fixture not found")
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(ExchangeInfoResponseDTO.self, from: data)
        let dto = response.data["270"]!
        let exchange = ExchangeMapper.map(dto)

        XCTAssertEqual(exchange.id, 270)
        XCTAssertEqual(exchange.name, "Binance")
        XCTAssertNotNil(exchange.dateLaunched)
        XCTAssertEqual(exchange.spotVolumeUSD, 9_500_000_000.0)
        XCTAssertNotNil(exchange.logo)
    }
}
