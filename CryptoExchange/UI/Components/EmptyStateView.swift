//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(LocalizedStringKey("empty_state_title"))
                .font(.title2)
                .bold()
            Text(LocalizedStringKey("empty_state_message"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("empty_view")
    }
}

#if DEBUG

#Preview("EmptyStateView · Light") {
    EmptyStateView()
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("EmptyStateView · Dark") {
    EmptyStateView()
        .preferredColorScheme(.dark)
}

#Preview("EmptyStateView · A11y") {
    EmptyStateView()
        .dynamicTypeSize(.accessibility3)
}

#endif
