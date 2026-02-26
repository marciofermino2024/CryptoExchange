//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

/// Carries debug information about the last failed request.
/// Only populated in DEBUG builds via CMCLogger.shared.lastErrorContext.
struct ErrorContext {
    let requestID: String
    let url: String
    let statusCode: Int?
    let technicalError: String
    let jsonSnippet: String?
}
