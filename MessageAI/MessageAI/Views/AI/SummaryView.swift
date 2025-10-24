//
//  SummaryView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View displaying AI-generated conversation summary
struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    
    let summary: ConversationSummary
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.largeSpacing) {
                    if !summary.keyPoints.isEmpty {
                        summarySection(
                            title: "Key Points",
                            icon: "key.fill",
                            items: summary.keyPoints,
                            color: .blue
                        )
                    }
                    
                    if !summary.decisions.isEmpty {
                        summarySection(
                            title: "Decisions Made",
                            icon: "checkmark.circle.fill",
                            items: summary.decisions,
                            color: .green
                        )
                    }
                    
                    if !summary.actionItems.isEmpty {
                        summarySection(
                            title: "Action Items",
                            icon: "list.bullet.circle.fill",
                            items: summary.actionItems,
                            color: .orange
                        )
                    }
                    
                    if !summary.openQuestions.isEmpty {
                        summarySection(
                            title: "Open Questions",
                            icon: "questionmark.circle.fill",
                            items: summary.openQuestions,
                            color: .purple
                        )
                    }
                    
                    if !summary.hasContent {
                        EmptyStateView(
                            icon: "doc.text",
                            title: "No Summary Available",
                            message: "No significant items to summarize in this conversation"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Conversation Summary")
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
    
    @ViewBuilder
    private func summarySection(
        title: String,
        icon: String,
        items: [String],
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.UIConfig.standardSpacing) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: AppConstants.UIConfig.smallSpacing) {
                        Text("\(index + 1).")
                            .foregroundColor(.secondary)
                        Text(item)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
        }
    }
}

#Preview {
    SummaryView(
        summary: ConversationSummary(
            id: "sum1",
            conversationID: "conv1",
            messageRange: ConversationSummary.DateRange(
                start: Date().addingTimeInterval(-3600),
                end: Date()
            ),
            keyPoints: [
                "Discussed project timeline",
                "Agreed on MVP features",
                "Identified technical challenges"
            ],
            decisions: [
                "Using SwiftUI for frontend",
                "Firebase for backend"
            ],
            actionItems: [
                "Alice to review PR by Friday",
                "Bob to deploy Cloud Functions"
            ],
            openQuestions: [
                "Which AI model to use?",
                "How to handle offline sync?"
            ],
            createdAt: Date()
        )
    )
}
