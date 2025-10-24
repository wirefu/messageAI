//
//  ChatView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main chat view for a conversation
struct ChatView: View {
    let conversation: Conversation
    let currentUserID: String
    
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var otherUser: User?
    
    init(conversation: Conversation, currentUserID: String) {
        self.conversation = conversation
        self.currentUserID = currentUserID
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            conversationID: conversation.id,
            currentUserID: currentUserID
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppConstants.UIConfig.smallSpacing) {
                        if viewModel.isLoading && viewModel.messages.isEmpty {
                            LoadingView(message: "Loading messages...")
                        } else if viewModel.messages.isEmpty {
                            EmptyStateView(
                                icon: "message",
                                title: "No Messages",
                                message: "Send your first message to start the conversation"
                            )
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(
                                    message: message,
                                    isFromCurrentUser: message.isFromCurrentUser(currentUserID)
                                )
                                .id(message.id)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteMessage(message)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, AppConstants.UIConfig.smallSpacing)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Message Input
            MessageInputView(
                messageText: $messageText,
                onSend: {
                    let textToSend = messageText
                    messageText = "" // Clear immediately
                    Task {
                        await viewModel.sendMessage(content: textToSend)
                    }
                },
                isLoading: viewModel.isLoading
            )
        }
        .navigationTitle(otherUser?.displayName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOtherUser()
            await viewModel.markMessagesAsRead()
        }
        .onDisappear {
            viewModel.stopObserving()
        }
        .errorAlert(error: Binding(
            get: { viewModel.error },
            set: { _ in viewModel.clearError() }
        ))
    }
    
    private func loadOtherUser() async {
        guard let otherUserID = conversation.otherParticipantID(currentUserID: currentUserID) else {
            return
        }
        
        let repository = UserRepository()
        otherUser = try? await repository.getUser(id: otherUserID)
    }
}

#Preview {
    NavigationView {
        ChatView(
            conversation: Conversation(
                id: "conv123",
                participants: ["user1", "user2"],
                lastMessage: nil,
                lastMessageTimestamp: Date(),
                unreadCount: [:],
                createdAt: Date()
            ),
            currentUserID: "user1"
        )
    }
}
