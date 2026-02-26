//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case missingAPIKey
    case networkOffline
    case timeout
    case httpError(statusCode: Int)
    case decodingError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return NSLocalizedString("error_missing_api_key", comment: "")
        case .networkOffline:
            return NSLocalizedString("error_network_offline", comment: "")
        case .timeout:
            return NSLocalizedString("error_timeout", comment: "")
        case .httpError(let code):
            return String(format: NSLocalizedString("error_http", comment: ""), code)
        case .decodingError:
            return NSLocalizedString("error_decoding", comment: "")
        case .unknown(let msg):
            return msg
        }
    }

    /// Technical description for debug sheet
    var technicalDescription: String {
        switch self {
        case .missingAPIKey: return "CMC_API_KEY missing from Info.plist / Secrets.xcconfig"
        case .networkOffline: return "URLError: not connected to internet"
        case .timeout: return "URLError: request timed out (>15s)"
        case .httpError(let code): return "HTTP \(code) - check API key validity and endpoint"
        case .decodingError: return "JSONDecoder failed — see console for keyNotFound/typeMismatch path"
        case .unknown(let msg): return msg
        }
    }
}
