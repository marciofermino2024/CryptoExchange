//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text(LocalizedStringKey("loading_message"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("loading_view")
    }
}

#if DEBUG

#Preview("LoadingView · Light") {
    LoadingView()
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

#Preview("LoadingView · Dark") {
    LoadingView()
        .preferredColorScheme(.dark)
}

#Preview("LoadingView · A11y") {
    LoadingView()
        .dynamicTypeSize(.accessibility3)
}

#endif
