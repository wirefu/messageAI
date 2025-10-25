//
//  AISessionRowView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Row view for displaying AI chat sessions in the list
struct AISessionRowView: View {
    let session: AIChatSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let description = session.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.lastUpdated, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if session.isActive {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            HStack {
                // Statistics
                HStack(spacing: 16) {
                    Label("\(session.statistics?.totalMessages ?? 0)", systemImage: "bubble.left.and.bubble.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(session.statistics?.actionsExecuted ?? 0)", systemImage: "bolt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
                // Response style indicator
                Text(session.settings.responseStyle.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(styleColor.opacity(0.2))
                    .foregroundColor(styleColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var styleColor: Color {
        switch session.settings.responseStyle {
        case .professional:
            return .blue
        case .casual:
            return .green
        case .technical:
            return .orange
        case .friendly:
            return .pink
        }
    }
}
