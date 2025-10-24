//
//  SummaryAutoTriggerView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Prompt view for auto-triggered summaries
struct SummaryAutoTriggerView: View {
    @Environment(\.dismiss) var dismiss
    
    let conversationID: String
    let unreadMessageCount: Int
    let onViewSummary: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.UIConfig.largeSpacing) {
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Title
            Text("Catch Up with AI Summary")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Message
            VStack(spacing: AppConstants.UIConfig.smallSpacing) {
                Text("You have **\(unreadMessageCount) unread messages**")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Text("Would you like an AI-generated summary to catch up quickly?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Buttons
            VStack(spacing: AppConstants.UIConfig.standardSpacing) {
                Button {
                    dismiss()
                    onViewSummary()
                } label: {
                    Text("View Summary")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
                }
                
                Button {
                    dismiss()
                    onDismiss()
                } label: {
                    Text("Read Messages")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(AppConstants.UIConfig.largeSpacing)
    }
}

#Preview {
    SummaryAutoTriggerView(
        conversationID: "conv123",
        unreadMessageCount: 24,
        onViewSummary: { print("View summary tapped") },
        onDismiss: { print("Dismiss tapped") }
    )
}

