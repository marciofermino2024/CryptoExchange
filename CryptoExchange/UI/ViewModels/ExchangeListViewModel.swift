// NOVA
import Foundation

@MainActor
final class ExchangeListViewModel: ObservableObject {
    @Published private(set) var state: UiState<[Exchange]> = .idle
    @Published private(set) var isLoadingMore = false

    private let getExchangeListUseCase: GetExchangeListUseCaseProtocol
    private var currentPage = 1
    private let pageSize = 20
    private var allExchanges: [Exchange] = []
    private var hasMore = true
    private var currentTask: Task<Void, Never>?

    init(getExchangeListUseCase: GetExchangeListUseCaseProtocol) {
        self.getExchangeListUseCase = getExchangeListUseCase
    }

    func loadInitial() {
        currentTask?.cancel()
        currentPage = 1
        allExchanges = []
        hasMore = true
        state = .loading
        currentTask = Task { await fetchPage(start: 1) }
    }

    func retry() {
        loadInitial()
    }

    func loadMoreIfNeeded(currentItem exchange: Exchange) {
        guard hasMore, !isLoadingMore, case .success(let list) = state else { return }
        let thresholdIndex = list.index(list.endIndex, offsetBy: -3, limitedBy: list.startIndex) ?? list.startIndex
        if let currentIndex = list.firstIndex(where: { $0.id == exchange.id }), currentIndex >= thresholdIndex {
            isLoadingMore = true
            currentPage += 1
            currentTask = Task { await fetchPage(start: (currentPage - 1) * pageSize + 1) }
        }
    }

    private func fetchPage(start: Int) async {
        do {
            let result = try await getExchangeListUseCase.execute(start: start, limit: pageSize)
            if Task.isCancelled { return }
            if result.isEmpty {
                hasMore = false
                if allExchanges.isEmpty {
                    state = .empty
                }
            } else {
                allExchanges.append(contentsOf: result)
                hasMore = result.count == pageSize
                state = .success(allExchanges)
            }
        } catch is CancellationError {
            // Cancelled — do nothing
        } catch let error as AppError {
            if allExchanges.isEmpty {
                state = .error(error)
            }
        } catch {
            if allExchanges.isEmpty {
                state = .error(.unknown(error.localizedDescription))
            }
        }
        isLoadingMore = false
    }
}
