//
//  AISuggestionsView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View for displaying AI suggestions
struct AISuggestionsView: View {
    @Environment(\.dismiss) var dismiss
    
    let suggestions: [String]
    let onSuggestionTapped: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSuggestionTapped(suggestion)
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.yellow)
                            
                            Text(suggestion)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("AI Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
