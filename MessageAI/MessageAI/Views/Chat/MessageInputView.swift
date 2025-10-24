//
//  MessageInputView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Message input view with send button
struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let isLoading: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppConstants.UIConfig.smallSpacing) {
            TextField("Message", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .disabled(isLoading)
            
            Button(action: onSend) {
                if isLoading {
                    ProgressView()
                        .tint(.blue)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isNotEmpty ? .blue : .gray)
                }
            }
            .disabled(!messageText.isNotEmpty || isLoading)
            .frame(width: AppConstants.UIConfig.minTouchTarget, height: AppConstants.UIConfig.minTouchTarget)
        }
        .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
        .padding(.vertical, AppConstants.UIConfig.smallSpacing)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            messageText: .constant("Test message"),
            onSend: { print("Send tapped") },
            isLoading: false
        )
    }
}
