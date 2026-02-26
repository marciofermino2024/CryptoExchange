//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

@MainActor
final class ExchangeDetailViewModel: ObservableObject {
    @Published private(set) var detailState: UiState<Exchange> = .idle
    @Published private(set) var pairsState: UiState<[ExchangeMarketPair]> = .idle
    @Published private(set) var isLoadingMorePairs = false

    private let getExchangeDetailUseCase: GetExchangeDetailUseCaseProtocol
    private let getExchangeMarketPairsUseCase: GetExchangeMarketPairsUseCaseProtocol
    private let exchangeID: Int
    private var allPairs: [ExchangeMarketPair] = []
    private var currentPairsPage = 1
    private let pairsPageSize = 20
    private var hasMorePairs = true

    init(
        exchangeID: Int,
        getExchangeDetailUseCase: GetExchangeDetailUseCaseProtocol,
        getExchangeMarketPairsUseCase: GetExchangeMarketPairsUseCaseProtocol
    ) {
        self.exchangeID = exchangeID
        self.getExchangeDetailUseCase = getExchangeDetailUseCase
        self.getExchangeMarketPairsUseCase = getExchangeMarketPairsUseCase
    }

    func load() {
        detailState = .loading
        pairsState = .loading
        Task {
            await fetchDetail()
            await fetchPairs(start: 1)
        }
    }

    func retry() {
        load()
    }

    func loadMorePairsIfNeeded(currentItem pair: ExchangeMarketPair) {
        guard hasMorePairs, !isLoadingMorePairs, case .success(let list) = pairsState else { return }
        let thresholdIndex = list.index(list.endIndex, offsetBy: -3, limitedBy: list.startIndex) ?? list.startIndex
        if let currentIndex = list.firstIndex(where: { $0.id == pair.id }), currentIndex >= thresholdIndex {
            isLoadingMorePairs = true
            currentPairsPage += 1
            Task { await fetchPairs(start: (currentPairsPage - 1) * pairsPageSize + 1) }
        }
    }

    private func fetchDetail() async {
        do {
            let exchange = try await getExchangeDetailUseCase.execute(id: exchangeID)
            detailState = .success(exchange)
        } catch let error as AppError {
            detailState = .error(error)
        } catch {
            detailState = .error(.unknown(error.localizedDescription))
        }
    }

    private func fetchPairs(start: Int) async {
        do {
            let result = try await getExchangeMarketPairsUseCase.execute(
                exchangeID: exchangeID, start: start, limit: pairsPageSize
            )
            if result.isEmpty {
                hasMorePairs = false
                if allPairs.isEmpty { pairsState = .empty }
            } else {
                allPairs.append(contentsOf: result)
                hasMorePairs = result.count == pairsPageSize
                pairsState = .success(allPairs)
            }
        } catch let error as AppError {
            if allPairs.isEmpty { pairsState = .error(error) }
        } catch {
            if allPairs.isEmpty { pairsState = .error(.unknown(error.localizedDescription)) }
        }
        isLoadingMorePairs = false
    }
}
