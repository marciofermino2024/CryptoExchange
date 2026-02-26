//  ExchangeListScreen.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//
import SwiftUI

struct ExchangeListScreen: View {
    @StateObject private var viewModel: ExchangeListViewModel
    @State private var showImageDebug = false

    init(viewModel: ExchangeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear { viewModel.loadInitial() }
                case .loading:
                    LoadingView()
                case .success(let exchanges):
                    listView(exchanges: exchanges)
                case .empty:
                    EmptyStateView()
                case .error(let error):
                    ErrorView(error: error, onRetry: viewModel.retry)
                }
            }
            .navigationTitle(Text(LocalizedStringKey("nav_title_exchanges")))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showImageDebug = true }) {
                        Image(systemName: "ladybug")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("debug_img_button")
                }
                #endif
            }
            .sheet(isPresented: $showImageDebug) {
                #if DEBUG
                ImageDebugSheetView()
                #endif
            }
        }
        .accessibilityIdentifier("exchange_list_screen")
    }

    @ViewBuilder
    private func listView(exchanges: [Exchange]) -> some View {
        List {
            ForEach(exchanges) { exchange in
                NavigationLink(destination: ExchangeDetailScreen(
                    viewModel: ExchangeDetailViewModel(
                        exchangeID: exchange.id,
                        getExchangeDetailUseCase: DependencyContainer.shared.getExchangeDetailUseCase,
                        getExchangeMarketPairsUseCase: DependencyContainer.shared.getExchangeMarketPairsUseCase
                    )
                )) {
                    ExchangeRowView(exchange: exchange)
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: exchange)
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { viewModel.loadInitial() }
        .accessibilityIdentifier("exchange_list")
    }
}

// MARK: - Image Debug Sheet (DEBUG only)

#if DEBUG
struct ImageDebugSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [ImageLogEntry] = []

    var body: some View {
        NavigationStack {
            List(logs.indices, id: \.self) { i in
                let log = logs[i]
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: log.cacheHit ? "checkmark.circle.fill" : "arrow.down.circle")
                            .foregroundColor(log.cacheHit ? .green : .blue)
                        Text(log.cacheHit ? "CACHE HIT" : "NETWORK")
                            .font(.caption2).bold()
                        Spacer()
                        if let code = log.statusCode {
                            Text("\(code)")
                                .font(.caption2)
                                .foregroundColor(code == 200 ? .green : .red)
                        }
                        Text(String(format: "%.0fms", log.latencyMS))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let reason = log.failureReason {
                        Text("✖ \(reason)")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    Text(log.url)
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            .navigationTitle("🖼️ Image Logs (last 20)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            logs = CMCLogger.shared.imageLogs
        }
    }
}
#endif
