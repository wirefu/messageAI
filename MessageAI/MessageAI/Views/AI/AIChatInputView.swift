//
//  AIChatInputView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Input view for AI chat with suggestions and actions
struct AIChatInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let isLoading: Bool
    let suggestions: [String]
    let onSuggestionTapped: (String) -> Void
    
    @State private var showingSuggestions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Suggestions bar
            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                onSuggestionTapped(suggestion)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.05))
            }
            
            // Input area
            HStack(alignment: .bottom, spacing: 12) {
                // Text input
                HStack {
                    TextField("Ask your AI assistant...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...6)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    
                    // Send button
                    Button(action: onSend) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                        }
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
        }
    }
}
