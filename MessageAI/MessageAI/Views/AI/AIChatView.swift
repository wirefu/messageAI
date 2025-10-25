//
//  AIChatView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main AI Chat Interface view
struct AIChatView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages area
                messagesArea
                
                // Input area
                inputArea
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearSession()
                    }
                    .foregroundColor(AIConstants.aiBrandColor)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AIConstants.smallPadding) {
                    // Welcome message
                    if viewModel.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        AIMessageBubbleView(
                            message: message,
                            isFromCurrentUser: message.role == .user
                        )
                        .id(message.id)
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        loadingIndicator
                    }
                    
                    // Proactive suggestions
                    if !viewModel.proactiveSuggestions.isEmpty {
                        suggestionsSection
                    }
                }
                .padding(.vertical, AIConstants.standardPadding)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeInOut(duration: AIConstants.standardAnimationDuration)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var welcomeMessage: some View {
        VStack(spacing: AIConstants.standardPadding) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(AIConstants.aiBrandColor)
            
            Text("Welcome to AI Assistant")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Ask me anything! I can help with questions, translations, summaries, and more.")
                .font(AIConstants.messageFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AIConstants.largePadding)
        }
        .padding(.vertical, AIConstants.largePadding)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        HStack {
            Spacer()
            
            HStack(spacing: AIConstants.smallPadding) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(AIConstants.aiBrandColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(viewModel.isLoading ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: AIConstants.typingAnimationDuration)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: viewModel.isLoading
                        )
                }
            }
            .padding(AIConstants.messagePadding)
            .background(
                RoundedRectangle(cornerRadius: AIConstants.messageCornerRadius)
                    .fill(AIConstants.assistantMessageColor)
            )
            .shadow(color: AIConstants.messageShadow, radius: 2, x: 0, y: 1)
            
            Spacer()
        }
        .padding(.horizontal, AIConstants.standardPadding)
    }
    
    @ViewBuilder
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: AIConstants.smallPadding) {
            Text("Suggestions")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, AIConstants.standardPadding)
            
            ForEach(viewModel.proactiveSuggestions) { suggestion in
                SuggestionCardView(
                    suggestion: suggestion,
                    onDismiss: {
                        viewModel.dismissSuggestion(suggestion)
                    }
                )
            }
        }
        .padding(.top, AIConstants.standardPadding)
    }
    
    @ViewBuilder
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AIConstants.smallPadding) {
                // Input field
                TextField("Type your message...", text: $viewModel.currentQuery, axis: .vertical)
                    .font(AIConstants.inputFont)
                    .padding(AIConstants.inputPadding)
                    .background(
                        RoundedRectangle(cornerRadius: AIConstants.inputCornerRadius)
                            .fill(Color(.systemGray6))
                    )
                    .focused($isInputFocused)
                    .onSubmit {
                        if !viewModel.currentQuery.isEmpty {
                            viewModel.sendQuery()
                        }
                    }
                
                // Send button
                Button(action: {
                    viewModel.sendQuery()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: AIConstants.iconSize))
                        .foregroundColor(.white)
                        .frame(width: AIConstants.sendButtonSize, height: AIConstants.sendButtonSize)
                        .background(
                            Circle()
                                .fill(viewModel.currentQuery.isEmpty ? Color.gray : AIConstants.aiBrandColor)
                        )
                }
                .disabled(viewModel.currentQuery.isEmpty || viewModel.isLoading)
            }
            .padding(AIConstants.standardPadding)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Supporting Views

struct SuggestionCardView: View {
    let suggestion: ProactiveSuggestion
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AIConstants.smallPadding) {
                Text(suggestion.suggestion)
                    .font(AIConstants.messageFont)
                    .foregroundColor(.primary)
                
                if let action = suggestion.action {
                    Button(action: {
                        // TODO: Execute action
                    }) {
                        Text(action.title)
                            .font(AIConstants.buttonFont)
                            .foregroundColor(AIConstants.aiBrandColor)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: AIConstants.iconSize))
                    .foregroundColor(.secondary)
            }
        }
        .padding(AIConstants.messagePadding)
        .background(
            RoundedRectangle(cornerRadius: AIConstants.messageCornerRadius)
                .fill(AIConstants.aiSecondaryColor.opacity(0.5))
        )
        .padding(.horizontal, AIConstants.standardPadding)
    }
}

// MARK: - Preview

struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
    }
}