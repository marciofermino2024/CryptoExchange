//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI

struct ExchangeDetailScreen: View {
    @StateObject private var viewModel: ExchangeDetailViewModel

    init(viewModel: ExchangeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.detailState {
            case .idle:
                Color.clear.onAppear { viewModel.load() }
            case .loading:
                LoadingView()
            case .success(let exchange):
                detailContent(exchange: exchange)
            case .empty:
                EmptyStateView()
            case .error(let error):
                ErrorView(error: error, onRetry: viewModel.retry)
            }
        }
        .accessibilityIdentifier("exchange_detail_screen")
    }

    @ViewBuilder
    private func detailContent(exchange: Exchange) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    AsyncImage(url: exchange.logo) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure:
                            Image(systemName: "building.2")
                                .foregroundColor(.secondary)
                        default:
                            ProgressView()
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exchange.name)
                            .font(.title2)
                            .bold()
                        Text("ID: \(exchange.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Divider()

                // Description
                if let description = exchange.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("detail_description"))
                            .font(.headline)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }

                // Info grid
                infoSection(exchange: exchange)

                // Website
                if let websiteURL = exchange.websiteURL {
                    Link(destination: websiteURL) {
                        HStack {
                            Image(systemName: "globe")
                            Text(LocalizedStringKey("detail_visit_website"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Divider()

                // Market Pairs
                Text(LocalizedStringKey("detail_market_pairs"))
                    .font(.headline)
                    .padding(.horizontal)

                pairsSection()
            }
            .padding(.vertical)
        }
        .navigationTitle(exchange.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func infoSection(exchange: Exchange) -> some View {
        VStack(spacing: 0) {
            infoRow(
                title: LocalizedStringKey("detail_date_launched"),
                value: exchange.dateLaunched.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
                    ?? NSLocalizedString("not_available", comment: "")
            )
            Divider().padding(.leading)
            infoRow(
                title: LocalizedStringKey("detail_volume_usd"),
                value: exchange.spotVolumeUSD.map { String(format: "$%.2f", $0) }
                    ?? NSLocalizedString("not_available", comment: "")
            )
            Divider().padding(.leading)
            infoRow(
                title: LocalizedStringKey("detail_maker_fee"),
                value: exchange.makerFee.map { String(format: "%.4f%%", $0) }
                    ?? NSLocalizedString("not_available", comment: "")
            )
            Divider().padding(.leading)
            infoRow(
                title: LocalizedStringKey("detail_taker_fee"),
                value: exchange.takerFee.map { String(format: "%.4f%%", $0) }
                    ?? NSLocalizedString("not_available", comment: "")
            )
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func infoRow(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .padding()
    }

    @ViewBuilder
    private func pairsSection() -> some View {
        switch viewModel.pairsState {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity).padding()
        case .empty:
            Text(LocalizedStringKey("pairs_empty"))
                .foregroundColor(.secondary)
                .padding()
        case .error(let error):
            VStack(spacing: 8) {
                Text(error.errorDescription ?? "")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Button(LocalizedStringKey("retry_button")) { viewModel.retry() }
                    .font(.caption)
            }
            .padding()
        case .success(let pairs):
            LazyVStack(spacing: 0) {
                ForEach(pairs) { pair in
                    MarketPairRowView(pair: pair)
                        .padding(.horizontal)
                        .onAppear { viewModel.loadMorePairsIfNeeded(currentItem: pair) }
                    Divider().padding(.leading)
                }
                if viewModel.isLoadingMorePairs {
                    ProgressView().padding()
                }
            }
        }
    }
}

#if DEBUG

private struct ExchangeDetailScreenPreviewHost: View {
    let detailMode: MockGetExchangeDetailUseCase.Mode
    let pairsMode: MockGetExchangeMarketPairsUseCase.Mode

    var body: some View {
        NavigationStack {
            ExchangeDetailScreen(
                viewModel: ExchangeDetailViewModel(
                    exchangeID: PreviewFixtures.exchange.id,
                    getExchangeDetailUseCase: MockGetExchangeDetailUseCase(mode: detailMode),
                    getExchangeMarketPairsUseCase: MockGetExchangeMarketPairsUseCase(mode: pairsMode)
                )
            )
        }
    }
}

#Preview("ExchangeDetailScreen · Light") {
    ExchangeDetailScreenPreviewHost(
        detailMode: .success(PreviewFixtures.exchange),
        pairsMode: .success(PreviewFixtures.marketPairs)
    )
    .preferredColorScheme(.light)
    .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("ExchangeDetailScreen · Dark") {
    ExchangeDetailScreenPreviewHost(
        detailMode: .success(PreviewFixtures.exchange),
        pairsMode: .success(PreviewFixtures.marketPairs)
    )
    .preferredColorScheme(.dark)
}

#Preview("ExchangeDetailScreen · A11y") {
    ExchangeDetailScreenPreviewHost(
        detailMode: .success(PreviewFixtures.exchange),
        pairsMode: .success(PreviewFixtures.marketPairs)
    )
    .dynamicTypeSize(.accessibility3)
}

#endif
