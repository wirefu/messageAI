//
//  MessageBubbleView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Individual message bubble view
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(AppConstants.UIConfig.messageBubblePadding)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
                
                HStack(spacing: 4) {
                    Text(message.timestamp.timeString())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if isFromCurrentUser {
                        statusIcon
                    }
                }
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch message.status {
        case .sending:
            Image(systemName: "clock")
                .font(.caption2)
                .foregroundColor(.secondary)
        case .sent:
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundColor(.secondary)
        case .delivered:
            Image(systemName: "checkmark.circle")
                .font(.caption2)
                .foregroundColor(.secondary)
        case .read:
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundColor(.blue)
        case .failed:
            Image(systemName: "exclamationmark.circle")
                .font(.caption2)
                .foregroundColor(.red)
        }
    }
}

#Preview("Sent Message") {
    MessageBubbleView(
        message: Message(
            id: "1",
            conversationID: "conv1",
            senderID: "user1",
            content: "Hey! How's it going?",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sent,
            aiSuggestions: nil
        ),
        isFromCurrentUser: true
    )
}

#Preview("Received Message") {
    MessageBubbleView(
        message: Message(
            id: "2",
            conversationID: "conv1",
            senderID: "user2",
            content: "Great! Just finished the feature. Want to review?",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: Date(),
            status: .read,
            aiSuggestions: nil
        ),
        isFromCurrentUser: false
    )
}
