//  ExchangeRowView.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//
import SwiftUI

struct ExchangeRowView: View {
    let exchange: Exchange

    private var formattedVolume: String {
        guard let vol = exchange.spotVolumeUSD else {
            return NSLocalizedString("not_available", comment: "")
        }
        let billions = vol / 1_000_000_000
        if billions >= 1 {
            return String(format: "$%.2fB", billions)
        }
        let millions = vol / 1_000_000
        if millions >= 1 {
            return String(format: "$%.2fM", millions)
        }
        return String(format: "$%.0f", vol)
    }

    private var formattedDate: String {
        guard let date = exchange.dateLaunched else {
            return NSLocalizedString("not_available", comment: "")
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Use CachedLogoView instead of AsyncImage:
            // - NSCache backed, no re-download on scroll
            // - Concurrency limited to 6 simultaneous
            // - Per-URL state machine: idle/loading/success/failure
            // - Logged via CMCLogger [IMG]
            CachedLogoView(url: exchange.logo, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(exchange.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                    Text(formattedVolume)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("exchange_row_\(exchange.id)")
    }
}
