//
//  AIChatView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main AI Chat view for individual AI chat sessions
struct AIChatView: View {
    let session: AIChatSession
    let currentUserID: String
    
    @StateObject private var viewModel: AIChatViewModel
    @State private var messageText = ""
    @State private var showingSuggestions = false
    @State private var showingActions = false
    @State private var selectedAction: AIChatAction?
    
    init(session: AIChatSession, currentUserID: String) {
        self.session = session
        self.currentUserID = currentUserID
        _viewModel = StateObject(wrappedValue: AIChatViewModel(sessionID: session.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            AIChatMessageView(
                                message: message,
                                isFromCurrentUser: message.userID == currentUserID
                            )
                            .id(message.id)
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Message Input
            AIChatInputView(
                messageText: $messageText,
                onSend: {
                    let textToSend = messageText
                    messageText = ""
                    Task {
                        await viewModel.sendMessage(textToSend)
                    }
                },
                isLoading: viewModel.isLoading,
                suggestions: viewModel.currentSuggestions,
                onSuggestionTapped: { suggestion in
                    messageText = suggestion
                }
            )
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingSuggestions = true
                    } label: {
                        Label("Get Suggestions", systemImage: "lightbulb")
                    }
                    
                    Button {
                        Task {
                            await viewModel.clearSession()
                        }
                    } label: {
                        Label("Clear Session", systemImage: "trash")
                    }
                    
                    Divider()
                    
                    Button {
                        // Show session settings
                    } label: {
                        Label("Session Settings", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingSuggestions) {
            AISuggestionsView(
                suggestions: viewModel.currentSuggestions,
                onSuggestionTapped: { suggestion in
                    messageText = suggestion
                    showingSuggestions = false
                }
            )
        }
        .sheet(isPresented: $showingActions) {
            if let action = selectedAction {
                AIActionView(
                    action: action,
                    messageContent: messageText,
                    onActionExecuted: { result in
                        // Handle action result
                        showingActions = false
                    }
                )
            }
        }
        .task {
            await viewModel.loadMessages()
        }
    }
}

/// Individual AI chat message view
struct AIChatMessageView: View {
    let message: AIChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                // Show AI metadata for assistant messages
                if !isFromCurrentUser, let metadata = message.aiMetadata {
                    AIChatMetadataView(metadata: metadata)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

/// AI chat metadata view showing model info, tokens, cost, etc.
struct AIChatMetadataView: View {
    let metadata: AIChatMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let model = metadata.model {
                Text("Model: \(model)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
            }
            
        }
        .padding(.horizontal, 8)
    }
}
