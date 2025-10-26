//
//  AIFeaturesHubView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Central hub for all AI features with quick access and status
struct AIFeaturesHubView: View {
    @State private var showingFeatureOverview = false
    @State private var selectedQuickAction: QuickAction?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Feature Status
                    featureStatusSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // AI Insights
                    aiInsightsSection
                }
                .padding()
            }
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Overview") {
                        showingFeatureOverview = true
                    }
                    .foregroundColor(AIConstants.aiBrandColor)
                }
            }
            .sheet(isPresented: $showingFeatureOverview) {
                AIFeatureOverview()
            }
            .sheet(item: $selectedQuickAction) { action in
                actionDetailView(for: action)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(AIConstants.aiBrandColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Features Hub")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Enhance your messaging experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // AI Status Indicator
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text("All AI features are active")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(quickActions) { action in
                    QuickActionCard(action: action) {
                        selectedQuickAction = action
                    }
                }
            }
        }
    }
    
    // MARK: - Feature Status Section
    
    private var featureStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feature Status")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                FeatureStatusRow(
                    title: "Smart Summaries",
                    status: .active,
                    icon: "doc.text.magnifyingglass",
                    color: .blue
                )
                
                FeatureStatusRow(
                    title: "Clarity Assistant",
                    status: .active,
                    icon: "checkmark.circle",
                    color: .green
                )
                
                FeatureStatusRow(
                    title: "Tone Analysis",
                    status: .active,
                    icon: "exclamationmark.triangle",
                    color: .orange
                )
                
                FeatureStatusRow(
                    title: "Action Items",
                    status: .active,
                    icon: "list.bullet.clipboard",
                    color: .purple
                )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ActivityRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Conversation summarized",
                    subtitle: "Team Standup - 2 min ago",
                    color: .blue
                )
                
                ActivityRow(
                    icon: "checkmark.circle",
                    title: "Clarity suggestion accepted",
                    subtitle: "Project Update - 5 min ago",
                    color: .green
                )
                
                ActivityRow(
                    icon: "exclamationmark.triangle",
                    title: "Tone warning shown",
                    subtitle: "Client Communication - 10 min ago",
                    color: .orange
                )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }
    
    // MARK: - AI Insights Section
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Insights")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "Communication Pattern",
                    description: "Your messages are 15% clearer than average",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                InsightCard(
                    title: "Tone Improvement",
                    description: "Professional tone usage increased by 20% this week",
                    icon: "arrow.up.circle",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Action Detail View
    
    @ViewBuilder
    private func actionDetailView(for action: QuickAction) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: action.icon)
                    .font(.system(size: 48))
                    .foregroundColor(action.color)
                
                Text(action.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(action.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle(action.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedQuickAction = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Data
    
    private var quickActions: [QuickAction] {
        [
            QuickAction(
                id: "new-ai-session",
                title: "New AI Session",
                description: "Start a new conversation with AI Assistant",
                icon: "plus.circle",
                color: .blue
            ),
            QuickAction(
                id: "view-summaries",
                title: "View Summaries",
                description: "Browse recent conversation summaries",
                icon: "doc.text.magnifyingglass",
                color: .green
            ),
            QuickAction(
                id: "action-items",
                title: "Action Items",
                description: "Manage your action items and tasks",
                icon: "list.bullet.clipboard",
                color: .purple
            ),
            QuickAction(
                id: "ai-settings",
                title: "AI Settings",
                description: "Configure AI features and preferences",
                icon: "gear",
                color: .gray
            )
        ]
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let action: QuickAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.title2)
                    .foregroundColor(action.color)
                
                Text(action.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeatureStatusRow: View {
    let title: String
    let status: FeatureStatus
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(status.color)
                    .frame(width: 6, height: 6)
                
                Text(status.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Data Models

struct QuickAction: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

enum FeatureStatus {
    case active
    case inactive
    case error
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .gray
        case .error: return .red
        }
    }
    
    var text: String {
        switch self {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .error: return "Error"
        }
    }
}

// MARK: - Preview

struct AIFeaturesHubView_Previews: PreviewProvider {
    static var previews: some View {
        AIFeaturesHubView()
    }
}
