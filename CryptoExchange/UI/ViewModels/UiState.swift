//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

enum UiState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case error(AppError)
}
