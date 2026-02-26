//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

protocol GetExchangeListUseCaseProtocol {
    func execute(start: Int, limit: Int) async throws -> [Exchange]
}

final class GetExchangeListUseCase: GetExchangeListUseCaseProtocol {
    private let repository: ExchangeRepositoryProtocol

    init(repository: ExchangeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(start: Int, limit: Int) async throws -> [Exchange] {
        try await repository.fetchExchangeList(start: start, limit: limit)
    }
}
