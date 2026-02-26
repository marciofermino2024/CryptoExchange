// NOVA
import SwiftUI

@main
struct CryptoExchangeApp: App {
    var body: some Scene {
        WindowGroup {
            ExchangeListScreen(
                viewModel: ExchangeListViewModel(
                    getExchangeListUseCase: DependencyContainer.shared.getExchangeListUseCase
                )
            )
        }
    }
}
