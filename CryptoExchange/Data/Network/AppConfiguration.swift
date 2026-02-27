//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

enum AppConfiguration {
    /// Reads the CoinMarketCap API key from Info.plist (injected via Secrets.xcconfig).
    /// The app will terminate with a clear error message if the key is missing.
    static var cmcAPIKey: String {
        guard
            let key = Bundle.main.infoDictionary?["CMC_API_KEY"] as? String,
            !key.isEmpty,
            key != "$(CMC_API_KEY)"
        else {
            fatalError(
                """
                Erro Key API
                """
            )
        }
        return key
    }
}
