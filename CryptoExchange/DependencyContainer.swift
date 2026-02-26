// NOVA
import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    private init() {}

    lazy var apiKey: String = AppConfiguration.cmcAPIKey

    lazy var apiClient: APIClientProtocol = APIClient(apiKey: apiKey)

    lazy var multiIDClient: MultiIDAPIClient = MultiIDAPIClient(apiKey: apiKey)

    lazy var exchangeRepository: ExchangeRepositoryProtocol = ExchangeRepository(
        apiClient: apiClient,
        multiIDClient: multiIDClient
    )

    lazy var getExchangeListUseCase: GetExchangeListUseCaseProtocol = GetExchangeListUseCase(
        repository: exchangeRepository
    )

    lazy var getExchangeDetailUseCase: GetExchangeDetailUseCaseProtocol = GetExchangeDetailUseCase(
        repository: exchangeRepository
    )

    lazy var getExchangeMarketPairsUseCase: GetExchangeMarketPairsUseCaseProtocol = GetExchangeMarketPairsUseCase(
        repository: exchangeRepository
    )
}
