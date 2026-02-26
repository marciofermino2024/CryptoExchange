//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI

struct ErrorView: View {
    let error: AppError
    let onRetry: () -> Void

    @State private var showDebugSheet = false

    private var debugContext: ErrorContext? {
        #if DEBUG
        guard let log = CMCLogger.shared.lastErrorContext else { return nil }
        return ErrorContext(
            requestID: log.requestID,
            url: log.url,
            statusCode: log.statusCode,
            technicalError: log.error ?? error.technicalDescription,
            jsonSnippet: log.jsonSnippet
        )
        #else
        return nil
        #endif
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(LocalizedStringKey("error_title"))
                .font(.title2)
                .bold()

            Text(error.errorDescription ?? NSLocalizedString("error_unknown", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onRetry) {
                Text(LocalizedStringKey("retry_button"))
                    .bold()
                    .frame(minWidth: 160)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityIdentifier("retry_button")

            #if DEBUG
            if debugContext != nil {
                Button(action: { showDebugSheet = true }) {
                    Label(NSLocalizedString("error_debug_details", comment: ""), systemImage: "ladybug")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityIdentifier("debug_details_button")
            }
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("error_view")
        .sheet(isPresented: $showDebugSheet) {
            if let ctx = debugContext {
                DebugSheetView(context: ctx)
            }
        }
    }
}

// MARK: - Debug Sheet (DEBUG only)

#if DEBUG
struct DebugSheetView: View {
    let context: ErrorContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    debugRow(label: "Request ID", value: context.requestID)
                    debugRow(label: "URL", value: context.url)
                    debugRow(label: "Status Code", value: context.statusCode.map { "\($0)" } ?? "—")
                    debugRow(label: "Error", value: context.technicalError)

                    if let snippet = context.jsonSnippet {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("JSON Snippet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal) {
                                Text(snippet)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("🐛 API Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func debugRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
        }
    }
}
#endif

#if DEBUG

#Preview("ErrorView · Light") {
    ErrorView(error: .unknown("Preview error"), onRetry: {})
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("ErrorView · Dark") {
    ErrorView(error: .unknown("Preview error"), onRetry: {})
        .preferredColorScheme(.dark)
}

#Preview("ErrorView · A11y") {
    ErrorView(error: .unknown("Preview error"), onRetry: {})
        .dynamicTypeSize(.accessibility3)
}

#Preview("DebugSheetView · Light") {
    DebugSheetView(context: ErrorContext(
        requestID: "REQ-123",
        url: "https://api.example.com/v1/exchanges",
        statusCode: 500,
        technicalError: "Internal Server Error",
        jsonSnippet: "{\n  \"status\": \"error\"\n}"
    ))
    .preferredColorScheme(.light)
}

#endif
