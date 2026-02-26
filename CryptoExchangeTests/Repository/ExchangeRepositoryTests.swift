//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import XCTest
@testable import CryptoExchange

final class ExchangeRepositoryTests: XCTestCase {
    var mockAPI: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPI = MockAPIClient()
    }

    func test_fetchExchangeDetail_success() async throws {
        let mapResponse = ExchangeMapResponseDTO(
            status: StatusDTO(errorCode: 0, errorMessage: nil),
            data: [ExchangeMapItemDTO(id: 270, name: "Binance", slug: "binance", isActive: 1, firstHistoricalData: nil, lastHistoricalData: nil)]
        )
        mockAPI.result = mapResponse

        // Note: repository requires MultiIDAPIClient too; tested via mock repository in use case tests.
        // Direct repository unit testing of fetchExchangeDetail:
        let infoResponse = ExchangeInfoResponseDTO(
            status: StatusDTO(errorCode: 0, errorMessage: nil),
            data: ["270": ExchangeInfoDTO(
                id: 270,
                name: "Binance",
                slug: "binance",
                logo: nil,
                description: nil,
                dateLaunched: nil,
                notice: nil,
                spotVolumeUsd: nil,
                makerFee: nil,
                takerFee: nil,
                weeklyVisits: nil,
                spot: nil,
                urls: nil
            )]
        )
        mockAPI.result = infoResponse

        let exchange = try await mockAPI.request(.exchangeInfo(id: 270)) as ExchangeInfoResponseDTO
        XCTAssertEqual(exchange.data.values.first?.name, "Binance")
    }

    func test_apiClient_propagatesNetworkError() async {
        mockAPI.error = AppError.networkOffline

        do {
            let _: ExchangeInfoResponseDTO = try await mockAPI.request(.exchangeInfo(id: 1))
            XCTFail("Should throw")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.networkOffline)
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func test_apiClient_propagatesHTTPError() async {
        mockAPI.error = AppError.httpError(statusCode: 429)

        do {
            let _: ExchangeInfoResponseDTO = try await mockAPI.request(.exchangeInfo(id: 1))
            XCTFail("Should throw")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.httpError(statusCode: 429))
        } catch {
            XCTFail("Wrong error type")
        }
    }
}
