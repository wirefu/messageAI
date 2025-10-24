//
//  MessageInputView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Message input view with send button and optional clarity checking
struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let isLoading: Bool
    let enableClarityCheck: Bool
    
    // Clarity checking support (only created if enabled)
    @StateObject private var viewModel = MessageInputViewModel()
    
    init(
        messageText: Binding<String>,
        onSend: @escaping () -> Void,
        isLoading: Bool,
        enableClarityCheck: Bool = false
    ) {
        self._messageText = messageText
        self.onSend = onSend
        self.isLoading = isLoading
        self.enableClarityCheck = enableClarityCheck
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Clarity Suggestion (if enabled and has suggestion)
            if enableClarityCheck && viewModel.showClaritySuggestion, let suggestion = viewModel.claritySuggestion {
                ClaritySuggestionView(
                    suggestion: suggestion,
                    onAccept: {
                        viewModel.acceptSuggestion()
                        messageText = viewModel.messageText
                    },
                    onDismiss: {
                        viewModel.dismissSuggestion()
                    }
                )
                .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
                .padding(.top, AppConstants.UIConfig.smallSpacing)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Message Input
            HStack(alignment: .bottom, spacing: AppConstants.UIConfig.smallSpacing) {
                TextField("Message", text: bindingForTextField, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .disabled(isLoading)
                
                // Clarity indicator
                if enableClarityCheck && viewModel.isCheckingClarity {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                }
                
                Button(action: handleSend) {
                    if isLoading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(effectiveMessageText.isNotEmpty ? .blue : .gray)
                    }
                }
                .disabled(!effectiveMessageText.isNotEmpty || isLoading)
                .frame(width: AppConstants.UIConfig.minTouchTarget, height: AppConstants.UIConfig.minTouchTarget)
            }
            .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            .padding(.vertical, AppConstants.UIConfig.smallSpacing)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Computed Properties
    
    private var bindingForTextField: Binding<String> {
        if enableClarityCheck {
            // Sync with ViewModel for clarity checking
            return Binding(
                get: { viewModel.messageText },
                set: { newValue in
                    viewModel.messageText = newValue
                    messageText = newValue
                }
            )
        } else {
            // Direct binding when clarity is disabled
            return $messageText
        }
    }
    
    private var effectiveMessageText: String {
        enableClarityCheck ? viewModel.messageText : messageText
    }
    
    // MARK: - Actions
    
    private func handleSend() {
        // Clear ViewModel state if using clarity
        if enableClarityCheck {
            viewModel.clearMessage()
        }
        onSend()
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            messageText: .constant("Test message"),
            onSend: { print("Send tapped") },
            isLoading: false
        )
    }
}

