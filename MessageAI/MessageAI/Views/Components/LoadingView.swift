//
//  LoadingView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Reusable loading indicator view
struct LoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: AppConstants.UIConfig.standardSpacing) {
            ProgressView()
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    LoadingView(message: "Loading messages...")
}

#Preview("Without Message") {
    LoadingView()
}
