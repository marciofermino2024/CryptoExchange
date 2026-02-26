//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

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
