//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

protocol GetExchangeDetailUseCaseProtocol {
    func execute(id: Int) async throws -> Exchange
}

final class GetExchangeDetailUseCase: GetExchangeDetailUseCaseProtocol {
    private let repository: ExchangeRepositoryProtocol

    init(repository: ExchangeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Exchange {
        try await repository.fetchExchangeDetail(id: id)
    }
}
