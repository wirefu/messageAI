//
//  ConversationRowView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Row view for a single conversation in the list
struct ConversationRowView: View {
    let conversation: Conversation
    let currentUserID: String
    
    @State private var otherUser: User?
    
    var body: some View {
        HStack(spacing: AppConstants.UIConfig.standardSpacing) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    if let user = otherUser {
                        Text(user.displayName.prefix(1))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if otherUser?.isOnline == true {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            }
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.displayName ?? "Loading...")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.timestamp.timeString())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    let unreadCount = conversation.unreadCount(for: currentUserID)
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, AppConstants.UIConfig.smallSpacing)
        .task {
            await loadOtherUser()
        }
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
    let mockConversation = Conversation(
        id: "conv123",
        participants: ["user1", "user2"],
        lastMessage: Message(
            id: "msg123",
            conversationID: "conv123",
            senderID: "user2",
            content: "Hey, how's the project going?",
            timestamp: Date().addingTimeInterval(-3600),
            deliveredAt: nil,
            readAt: nil,
            status: .delivered,
            aiSuggestions: nil
        ),
        lastMessageTimestamp: Date().addingTimeInterval(-3600),
        unreadCount: ["user1": 3],
        createdAt: Date().addingTimeInterval(-86400)
    )
    
    List {
        ConversationRowView(conversation: mockConversation, currentUserID: "user1")
    }
}

