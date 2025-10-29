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
    @State private var showingMessageActionSheet = false
    @State private var selectedMessageForAction: AIChatMessage?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            messagesArea
            inputArea
        }
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Cost Monitor Button (only on AI Assistant screen)
                    #if DEBUG
                    SubtleCostMonitor()
                    #endif
                    
                    Button("Clear") {
                        viewModel.clearSession()
                    }
                    .foregroundColor(AIConstants.aiBrandColor)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingMessageActionSheet) {
            if let message = selectedMessageForAction {
                AIMessageActionSheet(
                    message: message,
                    onDismiss: {
                        showingMessageActionSheet = false
                        selectedMessageForAction = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AIConstants.smallPadding) {
                    welcomeMessage
                    messagesList
                    loadingIndicator
                    proactiveSuggestions
                }
                .padding(.horizontal, AIConstants.standardPadding)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var welcomeMessage: some View {
        if viewModel.messages.isEmpty {
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
    }
    
    @ViewBuilder
    private var messagesList: some View {
        ForEach(viewModel.messages) { message in
            AIMessageBubbleView(
                message: AIMessage(
                    id: message.id,
                    role: message.role == .user ? .user : .assistant,
                    content: message.content,
                    timestamp: message.timestamp,
                    sources: nil
                ),
                isFromCurrentUser: message.role == .user,
                onLongPress: {
                    selectedMessageForAction = message
                    showingMessageActionSheet = true
                }
            )
            .onTapGesture {
                selectedMessageForAction = message
                showingMessageActionSheet = true
            }
        }
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Spacer()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var proactiveSuggestions: some View {
        if !viewModel.proactiveSuggestions.isEmpty {
            VStack(spacing: 8) {
                ForEach(viewModel.proactiveSuggestions, id: \.self) { suggestion in
                    HStack {
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button("Dismiss") {
                            viewModel.dismissSuggestion(suggestion)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
        }
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
    let suggestion: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AIConstants.smallPadding) {
                Text(suggestion)
                    .font(AIConstants.messageFont)
                    .foregroundColor(.primary)
                
                Button(action: {
                    // TODO: Execute action
                }) {
                    Text("Try this")
                        .font(AIConstants.buttonFont)
                        .foregroundColor(AIConstants.aiBrandColor)
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