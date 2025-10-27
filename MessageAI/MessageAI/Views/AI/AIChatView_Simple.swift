//
//  AIChatView_Simple.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Simplified AI Chat Interface view for testing
struct AIChatView_Simple: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showingMessageActionSheet = false
    @State private var selectedMessageForAction: AIChatMessage?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages area
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.messages.isEmpty {
                        Text("Welcome to AI Assistant!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
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
                        }
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
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Type your message...", text: $viewModel.currentQuery, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isInputFocused)
                    .onSubmit {
                        if !viewModel.currentQuery.isEmpty {
                            viewModel.sendQuery()
                        }
                    }
                
                Button(action: {
                    viewModel.sendQuery()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(viewModel.currentQuery.isEmpty ? Color.gray : AIConstants.aiBrandColor)
                        )
                }
                .disabled(viewModel.currentQuery.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
        .sheet(isPresented: $showingMessageActionSheet) {
            if let message = selectedMessageForAction {
                AIMessageActionSheet(
                    messageId: message.id,
                    conversationId: "current",
                    message: message
                )
            }
        }
    }
}

// MARK: - Preview

struct AIChatView_Simple_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView_Simple()
    }
}
