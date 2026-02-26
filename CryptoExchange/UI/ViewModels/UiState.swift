// NOVA
import Foundation

enum UiState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case error(AppError)
}
