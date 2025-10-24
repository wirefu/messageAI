//
//  ClaritySuggestionView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View displaying AI-powered clarity suggestions for messages
struct ClaritySuggestionView: View {
    let suggestion: AISuggestion
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UIConfig.standardSpacing) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("Clarity Assistant")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                // Clarity Issues
                if let issues = suggestion.clarityIssues, !issues.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Issues Found:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(Array(issues.enumerated()), id: \.offset) { _, issue in
                            HStack(alignment: .top, spacing: 4) {
                                Text("•")
                                    .foregroundColor(.orange)
                                Text(issue)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // Tone Warning
                if let warning = suggestion.toneWarning {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(warning)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Suggested Revision
                if let revision = suggestion.suggestedRevision {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Suggested:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(revision)
                            .font(.subheadline)
                            .padding(AppConstants.UIConfig.smallSpacing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Alternative Phrasing
                if isExpanded, let alternative = suggestion.alternativePhrasing {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alternative:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(alternative)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: AppConstants.UIConfig.standardSpacing) {
                if suggestion.suggestedRevision != nil {
                    Button {
                        onAccept()
                    } label: {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                
                if suggestion.alternativePhrasing != nil {
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Text(isExpanded ? "Less" : "More")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Dismiss")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(AppConstants.UIConfig.standardSpacing)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        ClaritySuggestionView(
            suggestion: AISuggestion(
                clarityIssues: [
                    "The pronoun 'it' is unclear",
                    "Missing specific timeline"
                ],
                suggestedRevision: "Could you send the updated design files by Friday at 5 PM?",
                toneWarning: "Message may sound too casual for this context",
                alternativePhrasing: "Would you be able to share the updated design files by end of week?"
            ),
            onAccept: { print("Accepted") },
            onDismiss: { print("Dismissed") }
        )
        .padding()
        
        Spacer()
    }
}

