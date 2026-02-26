// NOVA
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
