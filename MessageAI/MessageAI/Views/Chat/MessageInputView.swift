//
//  MessageInputView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Message input view with send button and optional AI assistance
struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let isLoading: Bool
    let enableClarityCheck: Bool
    let enableToneAnalysis: Bool
    
    // AI assistance support (only created if enabled)
    @StateObject private var viewModel = MessageInputViewModel()
    @StateObject private var toneViewModel = ToneAnalysisViewModel()
    
    init(
        messageText: Binding<String>,
        onSend: @escaping () -> Void,
        isLoading: Bool,
        enableClarityCheck: Bool = false,
        enableToneAnalysis: Bool = false
    ) {
        self._messageText = messageText
        self.onSend = onSend
        self.isLoading = isLoading
        self.enableClarityCheck = enableClarityCheck
        self.enableToneAnalysis = enableToneAnalysis
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tone Analysis (if enabled and has issues)
            if enableToneAnalysis && toneViewModel.shouldShowAnalysis, let result = toneViewModel.analysisResult {
                ToneAnalysisView(
                    result: result,
                    onAcceptSuggestion: {
                        if let alternative = result.alternativePhrasing {
                            messageText = alternative
                            toneViewModel.clearAnalysis()
                        }
                    },
                    onDismiss: {
                        toneViewModel.clearAnalysis()
                    }
                )
                .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
                .padding(.top, AppConstants.UIConfig.smallSpacing)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
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
        if enableClarityCheck || enableToneAnalysis {
            // Sync with ViewModel for AI assistance
            return Binding(
                get: { viewModel.messageText },
                set: { newValue in
                    viewModel.messageText = newValue
                    messageText = newValue
                    
                    // Trigger tone analysis if enabled
                    if enableToneAnalysis {
                        toneViewModel.analyzeTone(message: newValue)
                    }
                }
            )
        } else {
            // Direct binding when AI assistance is disabled
            return $messageText
        }
    }
    
    private var effectiveMessageText: String {
        (enableClarityCheck || enableToneAnalysis) ? viewModel.messageText : messageText
    }
    
    // MARK: - Actions
    
    private func handleSend() {
        // Clear ViewModel state if using AI assistance
        if enableClarityCheck {
            viewModel.clearMessage()
        }
        if enableToneAnalysis {
            toneViewModel.clearAnalysis()
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
