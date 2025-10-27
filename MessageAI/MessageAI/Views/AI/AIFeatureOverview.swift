//
//  AIFeatureOverview.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Overview of all AI features available in the app
struct AIFeatureOverview: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedFeature: AIFeature?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header
                    headerSection
                    
                    // Core AI Features
                    featureSection(
                        title: "Core AI Features",
                        features: coreFeatures
                    )
                    
                    // Message Enhancement Features
                    featureSection(
                        title: "Message Enhancement",
                        features: enhancementFeatures
                    )
                    
                    // Advanced Features
                    featureSection(
                        title: "Advanced Features",
                        features: advancedFeatures
                    )
                }
                .padding()
            }
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedFeature) { feature in
                featureDetailView(for: feature)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(AIConstants.aiBrandColor)
            
            Text("AI-Powered Messaging")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Enhance your team communication with intelligent features")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Feature Sections
    
    private func featureSection(title: String, features: [AIFeature]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(features) { feature in
                    FeatureCard(feature: feature) {
                        selectedFeature = feature
                    }
                }
            }
        }
    }
    
    // MARK: - Feature Detail View
    
    @ViewBuilder
    private func featureDetailView(for feature: AIFeature) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Feature header
                    HStack {
                        Image(systemName: feature.icon)
                            .font(.system(size: 32))
                            .foregroundColor(feature.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(feature.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // Feature description
                    Text(feature.description)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(feature.howItWorks, id: \.self) { step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(feature.color)
                                    .font(.body)
                                
                                Text(step)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Benefits
                    if !feature.benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Benefits:")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(feature.benefits, id: \.self) { benefit in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(benefit)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(feature.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedFeature = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Feature Data
    
    private var coreFeatures: [AIFeature] {
        [
            AIFeature(
                id: "conversation-summary",
                title: "Smart Summaries",
                subtitle: "AI-powered conversation analysis",
                icon: "doc.text.magnifyingglass",
                color: .blue,
                description: "Get intelligent summaries of your conversations with key points, decisions, and action items automatically extracted.",
                howItWorks: [
                    "Tap the 🔍 button in any conversation",
                    "AI analyzes the entire conversation context",
                    "Get structured summary with key points, decisions, and action items",
                    "Auto-triggered for long conversations"
                ],
                benefits: [
                    "Never miss important details",
                    "Quickly catch up on missed conversations",
                    "Identify decisions and action items",
                    "Save time on lengthy discussions"
                ]
            ),
            AIFeature(
                id: "clarity-check",
                title: "Clarity Assistant",
                subtitle: "Pre-send message analysis",
                icon: "checkmark.circle",
                color: .green,
                description: "Get real-time suggestions to improve message clarity and professionalism before sending.",
                howItWorks: [
                    "Type your message as usual",
                    "AI analyzes clarity and professionalism",
                    "Get suggestions for improvements",
                    "Accept or dismiss suggestions"
                ],
                benefits: [
                    "Avoid misunderstandings",
                    "Improve professional communication",
                    "Catch grammar and clarity issues",
                    "Enhance team collaboration"
                ]
            ),
            AIFeature(
                id: "tone-analysis",
                title: "Tone Analysis",
                subtitle: "Professional communication guidance",
                icon: "exclamationmark.triangle",
                color: .orange,
                description: "Detect potential tone issues and get suggestions for more professional communication.",
                howItWorks: [
                    "AI analyzes message tone in real-time",
                    "Detects potential issues (terse, aggressive, unclear)",
                    "Provides alternative phrasing suggestions",
                    "Shows severity levels and improvement tips"
                ],
                benefits: [
                    "Prevent communication conflicts",
                    "Maintain professional relationships",
                    "Improve message effectiveness",
                    "Learn better communication patterns"
                ]
            ),
            AIFeature(
                id: "action-items",
                title: "Action Items",
                subtitle: "Automatic task extraction",
                icon: "list.bullet.clipboard",
                color: .purple,
                description: "Automatically extract and track action items from conversations with assignees and due dates.",
                howItWorks: [
                    "AI scans conversations for commitments",
                    "Extracts action items with assignees",
                    "Tracks due dates and priorities",
                    "Provides centralized action item management"
                ],
                benefits: [
                    "Never lose track of commitments",
                    "Clear accountability and deadlines",
                    "Improved project management",
                    "Better follow-through on tasks"
                ]
            )
        ]
    }
    
    private var enhancementFeatures: [AIFeature] {
        [
            AIFeature(
                id: "message-translate",
                title: "Smart Translation",
                subtitle: "Multi-language support",
                icon: "globe",
                color: .blue,
                description: "Translate messages to any language with context-aware accuracy.",
                howItWorks: [
                    "Long-press any message",
                    "Select 'Translate' from actions",
                    "Choose target language",
                    "Get contextually accurate translation"
                ],
                benefits: [
                    "Break language barriers",
                    "Context-aware translations",
                    "Support global teams",
                    "Real-time communication"
                ]
            ),
            AIFeature(
                id: "message-rewrite",
                title: "Message Rewrite",
                subtitle: "Tone and style adjustment",
                icon: "pencil",
                color: .green,
                description: "Rewrite messages with different tones and styles for better communication.",
                howItWorks: [
                    "Long-press any message",
                    "Select 'Rewrite' from actions",
                    "Choose desired tone (formal, casual, friendly)",
                    "Get professionally rewritten version"
                ],
                benefits: [
                    "Adapt message tone",
                    "Improve communication style",
                    "Professional message crafting",
                    "Better audience targeting"
                ]
            ),
            AIFeature(
                id: "entity-extraction",
                title: "Entity Extraction",
                subtitle: "Smart information parsing",
                icon: "doc.text.magnifyingglass",
                color: .orange,
                description: "Extract important entities like dates, people, locations, and topics from messages.",
                howItWorks: [
                    "Long-press any message",
                    "Select 'Extract' from actions",
                    "AI identifies key entities",
                    "Get structured information extraction"
                ],
                benefits: [
                    "Quick information retrieval",
                    "Structured data extraction",
                    "Better message organization",
                    "Enhanced search capabilities"
                ]
            )
        ]
    }
    
    private var advancedFeatures: [AIFeature] {
        [
            AIFeature(
                id: "ai-chat",
                title: "AI Assistant",
                subtitle: "Intelligent conversation partner",
                icon: "brain.head.profile",
                color: .purple,
                description: "Chat with AI for help, brainstorming, and intelligent assistance.",
                howItWorks: [
                    "Access AI Assistant from main menu",
                    "Ask questions or request help",
                    "Get intelligent responses and suggestions",
                    "Use for brainstorming and problem-solving"
                ],
                benefits: [
                    "24/7 intelligent assistance",
                    "Brainstorming and ideation",
                    "Problem-solving support",
                    "Learning and development"
                ]
            ),
            AIFeature(
                id: "proactive-suggestions",
                title: "Proactive Suggestions",
                subtitle: "Smart contextual recommendations",
                icon: "lightbulb",
                color: .yellow,
                description: "Get intelligent suggestions based on conversation context and patterns.",
                howItWorks: [
                    "AI monitors conversation patterns",
                    "Identifies opportunities for improvement",
                    "Provides contextual suggestions",
                    "Helps optimize communication"
                ],
                benefits: [
                    "Proactive communication improvement",
                    "Context-aware suggestions",
                    "Better conversation flow",
                    "Enhanced team productivity"
                ]
            ),
            AIFeature(
                id: "conversation-search",
                title: "Smart Search",
                subtitle: "AI-powered conversation search",
                icon: "magnifyingglass",
                color: .blue,
                description: "Search conversations using natural language with AI understanding.",
                howItWorks: [
                    "Use natural language queries",
                    "AI understands context and intent",
                    "Get relevant results across conversations",
                    "Find information quickly and accurately"
                ],
                benefits: [
                    "Natural language search",
                    "Context-aware results",
                    "Find information quickly",
                    "Better knowledge discovery"
                ]
            )
        ]
    }
}

// MARK: - Supporting Views

struct FeatureCard: View {
    let feature: AIFeature
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: feature.icon)
                        .font(.title2)
                        .foregroundColor(feature.color)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(feature.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
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

// MARK: - Data Models

// MARK: - Preview

struct AIFeatureOverview_Previews: PreviewProvider {
    static var previews: some View {
        AIFeatureOverview()
    }
}
