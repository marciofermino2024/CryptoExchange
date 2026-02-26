//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import XCTest
@testable import CryptoExchange

final class APIClientNetworkTests: XCTestCase {
    var session: URLSession!
    var sut: APIClient!
    let testKey = "TEST_KEY_1234"

    override func setUp() {
        super.setUp()
        session = MockURLProtocol.makeSession()
        sut = APIClient(session: session, apiKey: testKey)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - URL + Headers

    func test_request_setsAPIKeyHeader() async throws {
        let data = try loadFixture("exchange_map_response")
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let _: ExchangeMapResponseDTO = try await sut.request(.exchangeMap(start: 1, limit: 5))
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "X-CMC_PRO_API_KEY"), testKey)
    }

    func test_request_exchangeMap_correctURL() async throws {
        let data = try loadFixture("exchange_map_response")
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let _: ExchangeMapResponseDTO = try await sut.request(.exchangeMap(start: 1, limit: 20))

        XCTAssertNotNil(capturedURL)
        XCTAssertTrue(capturedURL?.path == "/v1/exchange/map")
        let queryItems = URLComponents(url: capturedURL!, resolvingAgainstBaseURL: false)?.queryItems
        XCTAssertTrue(queryItems?.contains(where: { $0.name == "start" && $0.value == "1" }) == true)
        XCTAssertTrue(queryItems?.contains(where: { $0.name == "limit" && $0.value == "20" }) == true)
    }

    func test_request_http401_throwsHTTPError() async {
        MockURLProtocol.mockHTTPError(statusCode: 401)

        do {
            let _: ExchangeMapResponseDTO = try await sut.request(.exchangeMap(start: 1, limit: 5))
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.httpError(statusCode: 401))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_request_offline_throwsNetworkOffline() async {
        MockURLProtocol.mockNetworkError()

        do {
            let _: ExchangeMapResponseDTO = try await sut.request(.exchangeMap(start: 1, limit: 5))
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.networkOffline)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_request_invalidJSON_throwsDecodingError() async {
        MockURLProtocol.mockSuccess(data: Data("not-json".utf8))

        do {
            let _: ExchangeMapResponseDTO = try await sut.request(.exchangeMap(start: 1, limit: 5))
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.decodingError)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - DTO Decoding with real fixtures

    func test_decodeExchangeMap_fromFixture() throws {
        let data = try loadFixture("exchange_map_response")
        let dto = try JSONDecoder().decode(ExchangeMapResponseDTO.self, from: data)

        XCTAssertEqual(dto.status.errorCode, 0)
        XCTAssertEqual(dto.data.count, 2)
        XCTAssertEqual(dto.data[0].id, 270)
        XCTAssertEqual(dto.data[0].name, "Binance")
        XCTAssertEqual(dto.data[0].slug, "binance")
        XCTAssertEqual(dto.data[0].isActive, 1)
    }

    func test_decodeExchangeInfo_fromFixture() throws {
        let data = try loadFixture("exchange_info_response")
        let dto = try JSONDecoder().decode(ExchangeInfoResponseDTO.self, from: data)

        XCTAssertEqual(dto.status.errorCode, 0)
        let exchange = dto.data["270"]
        XCTAssertNotNil(exchange)
        XCTAssertEqual(exchange?.id, 270)
        XCTAssertEqual(exchange?.name, "Binance")
        XCTAssertEqual(exchange?.spotVolumeUsd, 9_500_000_000.0)
        XCTAssertEqual(exchange?.makerFee, 0.001)
        XCTAssertEqual(exchange?.takerFee, 0.001)
        XCTAssertEqual(exchange?.dateLaunched, "2017-07-14T00:00:00.000Z")
        XCTAssertEqual(exchange?.urls?.website?.first, "https://www.binance.com")
    }

    func test_decodeMarketPairs_fromFixture() throws {
        let data = try loadFixture("exchange_market_pairs_response")
        let dto = try JSONDecoder().decode(ExchangeMarketPairsResponseDTO.self, from: data)

        XCTAssertEqual(dto.data.id, 270)
        XCTAssertEqual(dto.data.marketPairs?.count, 1)
        let pair = dto.data.marketPairs?.first
        XCTAssertEqual(pair?.marketPairBase?.currencySymbol, "BTC")
        XCTAssertEqual(pair?.marketPairQuote?.currencySymbol, "USDT")
        XCTAssertEqual(pair?.quote?.usd?.price, 43500.0)
    }

    // MARK: - Helpers

    private func loadFixture(_ name: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") else {
            throw XCTSkip("Fixture \(name).json not found in test bundle")
        }
        return try Data(contentsOf: url)
    }
}
