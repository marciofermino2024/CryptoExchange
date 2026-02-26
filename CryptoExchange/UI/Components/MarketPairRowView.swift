// NOVA
import SwiftUI

struct MarketPairRowView: View {
    let pair: ExchangeMarketPair

    private var pairLabel: String {
        "\(pair.marketPairBase.currencySymbol)/\(pair.marketPairQuote.currencySymbol)"
    }

    private var formattedPrice: String {
        guard let price = pair.priceUSD else {
            return NSLocalizedString("not_available", comment: "")
        }
        if price >= 1 {
            return String(format: "$%.2f", price)
        }
        return String(format: "$%.6f", price)
    }

    private var formattedVolume: String {
        guard let vol = pair.volumeUSD24h else {
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
