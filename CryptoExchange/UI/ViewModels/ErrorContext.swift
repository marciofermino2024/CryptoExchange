// NOVA
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
