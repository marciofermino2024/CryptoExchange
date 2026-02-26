//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

protocol GetExchangeMarketPairsUseCaseProtocol {
    func execute(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair]
}

final class GetExchangeMarketPairsUseCase: GetExchangeMarketPairsUseCaseProtocol {
    private let repository: ExchangeRepositoryProtocol

    init(repository: ExchangeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair] {
        try await repository.fetchExchangeMarketPairs(exchangeID: exchangeID, start: start, limit: limit)
    }
}
