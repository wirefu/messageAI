//
//  ChatViewLoader.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Loads conversation data and displays ChatView
struct ChatViewLoader: View {
    let conversationID: String
    let currentUserID: String
    
    @State private var conversation: Conversation?
    @State private var isLoading = true
    
    private let repository = ConversationRepository()
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView(message: "Loading chat...")
            } else if let conversation = conversation {
                ChatView(
                    conversation: conversation,
                    currentUserID: currentUserID
                )
            } else {
                ErrorView(error: .conversationNotFound)
            }
        }
        .task {
            await loadConversation()
        }
    }
    
    private func loadConversation() async {
        do {
            conversation = try await repository.getConversation(id: conversationID)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
