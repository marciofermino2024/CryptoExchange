//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI

struct MarketPairRowView: View {
    let pair: ExchangeMarketPair

    private var pairLabel: String {
        "\(pair.marketPairBase.currencySymbol)/\(pair.marketPairQuote.currencySymbol)"
    }

    private var formattedPrice: String {
        // Funciona tanto se pair.priceUSD for Double quanto Double?
        let price: Double? = pair.priceUSD
        guard let price else {
            return NSLocalizedString("not_available", comment: "")
        }
        if price >= 1 {
            return String(format: "$%.2f", price)
        }
        return String(format: "$%.6f", price)
    }

    private var formattedVolume: String {
        // Funciona tanto se pair.volumeUSD24h for Double quanto Double?
        let vol: Double? = pair.volumeUSD24h
        guard let vol else {
            return NSLocalizedString("not_available", comment: "")
        }
        let millions = vol / 1_000_000
        return String(format: "$%.2fM", millions)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(pairLabel)
                    .font(.headline)

                Text(String(format: NSLocalizedString("volume_24h_label", comment: ""), formattedVolume))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedPrice)
                    .font(.headline)
                    .foregroundColor(.accentColor)

                Text(NSLocalizedString("price_usd_label", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#if DEBUG

// PreviewProvider (compatível com projetos que não suportam #Preview)
struct MarketPairRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MarketPairRowView(pair: PreviewFixtures.marketPair)
                .padding()
                .preferredColorScheme(.light)
                .environment(\.locale, Locale(identifier: "pt_BR"))

            MarketPairRowView(pair: PreviewFixtures.marketPair)
                .padding()
                .preferredColorScheme(.dark)

            MarketPairRowView(pair: PreviewFixtures.marketPair)
                .padding()
                .dynamicTypeSize(.accessibility3)
        }
    }
}

#endif

#if DEBUG && compiler(>=5.9)
// #Preview (só compila em Swift 5.9+ / Xcode 15+)
#Preview("MarketPairRowView · Light") {
    MarketPairRowView(pair: PreviewFixtures.marketPair)
        .padding()
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("MarketPairRowView · Dark") {
    MarketPairRowView(pair: PreviewFixtures.marketPair)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("MarketPairRowView · A11y") {
    MarketPairRowView(pair: PreviewFixtures.marketPair)
        .padding()
        .dynamicTypeSize(.accessibility3)
}
#endif
