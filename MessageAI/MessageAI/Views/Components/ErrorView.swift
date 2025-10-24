//
//  ErrorView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Reusable error display view with retry capability
struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    init(error: AppError, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: AppConstants.UIConfig.standardSpacing) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(error.errorDescription ?? "An error occurred")
                .font(.headline)
                .multilineTextAlignment(.center)

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
                }
                .padding(.top, AppConstants.UIConfig.smallSpacing)
            }
        }
        .padding(AppConstants.UIConfig.largeSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("With Retry") {
    ErrorView(error: .networkUnavailable) {
        print("Retry tapped")
    }
}

#Preview("Without Retry") {
    ErrorView(error: .invalidCredentials)
}

