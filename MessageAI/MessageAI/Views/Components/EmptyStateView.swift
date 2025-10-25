//
//  EmptyStateView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Reusable empty state view with optional action
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: AppConstants.UIConfig.standardSpacing) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.UIConfig.largeSpacing)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .padding(.horizontal, AppConstants.UIConfig.largeSpacing)
                        .padding(.vertical, AppConstants.UIConfig.standardSpacing)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
                }
                .padding(.top, AppConstants.UIConfig.smallSpacing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("No Conversations") {
    EmptyStateView(
        icon: "bubble.left.and.bubble.right",
        title: "No Conversations",
        message: "Start a conversation to begin messaging with your team",
        actionTitle: "New Conversation"
    ) {
        print("New conversation tapped")
    }
}

#Preview("No Messages") {
    EmptyStateView(
        icon: "message",
        title: "No Messages",
        message: "Send your first message to start the conversation"
    )
}
