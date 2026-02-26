//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import XCTest
@testable import CryptoExchange

final class GetExchangeListUseCaseTests: XCTestCase {
    var sut: GetExchangeListUseCase!
    var mockRepository: MockExchangeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockExchangeRepository()
        sut = GetExchangeListUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_success_returnsExchanges() async throws {
        let expected = [Exchange.stub(id: 1, name: "Binance"), Exchange.stub(id: 2, name: "Coinbase")]
        mockRepository.exchangeListResult = .success(expected)

        let result = try await sut.execute(start: 1, limit: 20)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Binance")
        XCTAssertEqual(result[1].name, "Coinbase")
    }

    func test_execute_networkError_throws() async {
        mockRepository.exchangeListResult = .failure(AppError.networkOffline)

        do {
            _ = try await sut.execute(start: 1, limit: 20)
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.networkOffline)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func test_execute_emptyList_returnsEmpty() async throws {
        mockRepository.exchangeListResult = .success([])

        let result = try await sut.execute(start: 1, limit: 20)
        XCTAssertTrue(result.isEmpty)
    }
}

final class GetExchangeDetailUseCaseTests: XCTestCase {
    var sut: GetExchangeDetailUseCase!
    var mockRepository: MockExchangeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockExchangeRepository()
        sut = GetExchangeDetailUseCase(repository: mockRepository)
    }

    func test_execute_success_returnsExchange() async throws {
        let expected = Exchange.stub(id: 42, name: "Kraken")
        mockRepository.exchangeDetailResult = .success(expected)

        let result = try await sut.execute(id: 42)
        XCTAssertEqual(result.id, 42)
        XCTAssertEqual(result.name, "Kraken")
    }

    func test_execute_httpError_throws() async {
        mockRepository.exchangeDetailResult = .failure(AppError.httpError(statusCode: 401))

        do {
            _ = try await sut.execute(id: 42)
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.httpError(statusCode: 401))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}

final class GetExchangeMarketPairsUseCaseTests: XCTestCase {
    var sut: GetExchangeMarketPairsUseCase!
    var mockRepository: MockExchangeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockExchangeRepository()
        sut = GetExchangeMarketPairsUseCase(repository: mockRepository)
    }

    func test_execute_success_returnsPairs() async throws {
        let expected = [ExchangeMarketPair.stub(id: "1"), ExchangeMarketPair.stub(id: "2")]
        mockRepository.marketPairsResult = .success(expected)

        let result = try await sut.execute(exchangeID: 1, start: 1, limit: 20)
        XCTAssertEqual(result.count, 2)
    }

    func test_execute_decodingError_throws() async {
        mockRepository.marketPairsResult = .failure(AppError.decodingError)

        do {
            _ = try await sut.execute(exchangeID: 1, start: 1, limit: 20)
            XCTFail("Should have thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.decodingError)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
