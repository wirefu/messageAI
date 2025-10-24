//
//  View+Extensions.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

extension View {
    // MARK: - Keyboard Management

    /// Dismisses the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    /// Adds tap gesture to dismiss keyboard
    /// - Returns: View with tap-to-dismiss keyboard functionality
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Conditional Modifiers

    /// Applies a modifier conditionally
    /// - Parameters:
    ///   - condition: Boolean condition
    ///   - transform: Transform to apply if condition is true
    /// - Returns: View with conditional modifier applied
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Loading States

    /// Shows a loading overlay when condition is true
    /// - Parameter isLoading: Boolean indicating loading state
    /// - Returns: View with loading overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }

    // MARK: - Error Handling

    /// Shows an error alert when error is present
    /// - Parameters:
    ///   - error: Binding to optional error
    ///   - dismissAction: Optional action to perform on dismiss
    /// - Returns: View with error alert
    func errorAlert(
        error: Binding<AppError?>,
        dismissAction: (() -> Void)? = nil
    ) -> some View {
        alert(
            "Error",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            ),
            presenting: error.wrappedValue
        ) { _ in
            Button("OK") {
                error.wrappedValue = nil
                dismissAction?()
            }
        } message: { err in
            if let description = err.errorDescription {
                Text(description)
            }
            if let suggestion = err.recoverySuggestion {
                Text(suggestion)
            }
        }
    }
}

