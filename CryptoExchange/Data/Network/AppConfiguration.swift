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
                ❌ CoinMarketCap API Key not configured.
                
                Please follow the README instructions:
                1. Copy Secrets.xcconfig.example to Secrets.xcconfig
                2. Set CMC_API_KEY = your_key_here
                3. Re-build the project.
                """
            )
        }
        return key
    }
}
