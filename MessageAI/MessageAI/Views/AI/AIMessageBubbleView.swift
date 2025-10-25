//
//  AIMessageBubbleView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// SwiftUI view for displaying AI message bubbles
struct AIMessageBubbleView: View {
    
    // MARK: - Properties
    
    let message: AIMessage
    let isFromCurrentUser: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: AIConstants.smallPadding) {
                // Message content
                Text(message.content)
                    .font(AIConstants.messageFont)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(AIConstants.messagePadding)
                    .background(
                        RoundedRectangle(cornerRadius: AIConstants.messageCornerRadius)
                            .fill(isFromCurrentUser ? AIConstants.userMessageColor : AIConstants.assistantMessageColor)
                    )
                    .shadow(color: AIConstants.messageShadow, radius: 2, x: 0, y: 1)
                
                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(AIConstants.timestampFont)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, AIConstants.smallPadding)
                
                // Sources (if available)
                if let sources = message.sources, !sources.isEmpty {
                    sourcesView(sources)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * AIConstants.messageMaxWidth, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, AIConstants.standardPadding)
        .padding(.vertical, AIConstants.smallPadding)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func sourcesView(_ sources: [MessageSource]) -> some View {
        VStack(alignment: .leading, spacing: AIConstants.smallPadding) {
            Text("Sources:")
                .font(AIConstants.secondaryFont)
                .foregroundColor(.secondary)
            
            ForEach(sources, id: \.id) { source in
                HStack {
                    Image(systemName: sourceIcon(for: source.type))
                        .foregroundColor(AIConstants.aiBrandColor)
                        .frame(width: AIConstants.iconSize, height: AIConstants.iconSize)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(source.title ?? source.id)
                            .font(AIConstants.secondaryFont)
                            .foregroundColor(.primary)
                        
                        if let relevance = source.relevance {
                            Text("Relevance: \(Int(relevance * 100))%")
                                .font(AIConstants.timestampFont)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, AIConstants.smallPadding)
                .padding(.vertical, AIConstants.smallPadding / 2)
                .background(
                    RoundedRectangle(cornerRadius: AIConstants.smallPadding)
                        .fill(AIConstants.aiSecondaryColor.opacity(0.3))
                )
            }
        }
        .padding(.top, AIConstants.smallPadding)
    }
    
    // MARK: - Private Methods
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func sourceIcon(for type: String) -> String {
        switch type {
        case "conversation":
            return "message"
        case "document":
            return "doc.text"
        case "web":
            return "globe"
        case "knowledge":
            return "book"
        default:
            return "questionmark.circle"
        }
    }
}

// MARK: - Preview

struct AIMessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // User message
            AIMessageBubbleView(
                message: AIMessage(
                    id: "1",
                    role: .user,
                    content: "Hello, can you help me with my project?",
                    timestamp: Date(),
                    sources: nil
                ),
                isFromCurrentUser: true
            )
            
            // Assistant message
            AIMessageBubbleView(
                message: AIMessage(
                    id: "2",
                    role: .assistant,
                    content: "Of course! I'd be happy to help you with your project. What specific aspect would you like assistance with?",
                    timestamp: Date(),
                    sources: [
                        MessageSource(
                            type: "conversation",
                            id: "conv-123",
                            title: "Previous Project Discussion",
                            relevance: 0.85
                        )
                    ]
                ),
                isFromCurrentUser: false
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
