//
//  ProactiveSuggestionBanner.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Proactive suggestion banner that appears at the top of conversations
struct ProactiveSuggestionBanner: View {
    
    // MARK: - Properties
    
    let suggestion: ProactiveSuggestionBackend
    let onDismiss: () -> Void
    let onTakeAction: () -> Void
    
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icon
                suggestionIcon
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(suggestion.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Message
                    Text(suggestion.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Action Button
                    Button(action: onTakeAction) {
                        Text(suggestion.actionText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(priorityColor.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    // Dismiss Button
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : -50)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var suggestionIcon: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(priorityColor)
            .frame(width: 32, height: 32)
            .background(priorityColor.opacity(0.1))
            .clipShape(Circle())
    }
    
    private var iconName: String {
        switch suggestion.type {
        case .timezoneAmbiguity:
            return "clock.badge.exclamationmark"
        case .unclearReference:
            return "questionmark.circle"
        case .missedFollowup:
            return "bell.badge"
        }
    }
    
    private var priorityColor: Color {
        switch suggestion.priority {
        case .low:
            return .blue
        case .medium:
            return .yellow
        case .high:
            return .orange
        }
    }
    
    private var backgroundColor: Color {
        switch suggestion.priority {
        case .low:
            return Color.blue.opacity(0.05)
        case .medium:
            return Color.yellow.opacity(0.05)
        case .high:
            return Color.orange.opacity(0.05)
        }
    }
}

// MARK: - Preview

struct ProactiveSuggestionBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // High Priority - Timezone Ambiguity
            ProactiveSuggestionBanner(
                suggestion: ProactiveSuggestionBackend(
                    id: "1",
                    type: .timezoneAmbiguity,
                    priority: .high,
                    title: "Timezone Ambiguity Detected",
                    message: "\"Let's meet at 3pm tomorrow\" mentions a time but doesn't specify timezone. You're in EST, recipient is in PST.",
                    actionText: "Clarify Timezone",
                    dismissText: "Dismiss",
                    metadata: SuggestionMetadata(
                        conversationId: "conv1",
                        messageId: "msg1",
                        detectedAt: "2025-01-26T10:00:00Z",
                        userTimezone: "America/New_York",
                        recipientTimezone: "America/Los_Angeles",
                        originalText: "Let's meet at 3pm tomorrow",
                        suggestedClarification: "Consider clarifying: \"Let's meet at 3pm tomorrow (EST)\" or \"Let's meet at 3pm tomorrow (PST)\""
                    ),
                    dismissed: false,
                    actionTaken: false,
                    createdAt: Date(),
                    expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                ),
                onDismiss: {},
                onTakeAction: {}
            )
            
            // Medium Priority - Unclear Reference
            ProactiveSuggestionBanner(
                suggestion: ProactiveSuggestionBackend(
                    id: "2",
                    type: .unclearReference,
                    priority: .medium,
                    title: "Unclear Reference Detected",
                    message: "\"Can you review the document?\" contains unclear references that might confuse the recipient.",
                    actionText: "Add Context",
                    dismissText: "Dismiss",
                    metadata: SuggestionMetadata(
                        conversationId: "conv1",
                        messageId: "msg2",
                        detectedAt: "2025-01-26T10:00:00Z",
                        userTimezone: nil,
                        recipientTimezone: nil,
                        originalText: "Can you review the document?",
                        suggestedClarification: "Consider being more specific: the [specific document name]"
                    ),
                    dismissed: false,
                    actionTaken: false,
                    createdAt: Date(),
                    expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                ),
                onDismiss: {},
                onTakeAction: {}
            )
            
            // Low Priority - Missed Followup
            ProactiveSuggestionBanner(
                suggestion: ProactiveSuggestionBackend(
                    id: "3",
                    type: .missedFollowup,
                    priority: .low,
                    title: "Follow-up Reminder",
                    message: "You mentioned following up on the project status. Consider checking in.",
                    actionText: "Follow Up",
                    dismissText: "Dismiss",
                    metadata: SuggestionMetadata(
                        conversationId: "conv1",
                        messageId: "msg3",
                        detectedAt: "2025-01-26T10:00:00Z",
                        userTimezone: nil,
                        recipientTimezone: nil,
                        originalText: "I'll follow up on the project status",
                        suggestedClarification: nil
                    ),
                    dismissed: false,
                    actionTaken: false,
                    createdAt: Date(),
                    expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                ),
                onDismiss: {},
                onTakeAction: {}
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
