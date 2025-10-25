//
//  NewAISessionView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View for creating a new AI chat session
struct NewAISessionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AIChatViewModel()
    
    let onSessionCreated: (AIChatSession) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var responseStyle: AIChatResponseStyle = .professional
    @State private var includeContext = true
    @State private var enableSuggestions = true
    @State private var enableActions = true
    @State private var preferredModel: String = "gpt-4o-mini"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    TextField("Session Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Section("AI Settings") {
                    Picker("Response Style", selection: $responseStyle) {
                        ForEach(AIChatResponseStyle.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("AI Model", selection: $preferredModel) {
                        Text("GPT-4o Mini (Fast & Cost-effective)").tag("gpt-4o-mini")
                        Text("GPT-4o (High Quality)").tag("gpt-4o")
                        Text("Claude 3 Haiku (Fast)").tag("claude-3-haiku")
                        Text("Claude 3 Sonnet (Balanced)").tag("claude-3-sonnet")
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Features") {
                    Toggle("Include Conversation Context", isOn: $includeContext)
                        .help("Allow AI to access your message history for better responses")
                    
                    Toggle("Enable Proactive Suggestions", isOn: $enableSuggestions)
                        .help("AI will suggest helpful follow-up questions and actions")
                    
                    Toggle("Enable AI Actions", isOn: $enableActions)
                        .help("Allow AI to perform actions like translation, summarization, etc.")
                }
            }
            .navigationTitle("New AI Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createSession()
                        }
                    }
                    .disabled(title.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
    
    private func createSession() async {
        let settings = AIChatSettings(
            includeContext: includeContext,
            enableSuggestions: enableSuggestions,
            enableActions: enableActions,
            preferredModel: preferredModel,
            responseStyle: responseStyle
        )
        
        let session = AIChatSession(
            id: UUID().uuidString,
            userID: "", // Will be set by the repository
            title: title.isEmpty ? "New AI Chat" : title,
            description: description.isEmpty ? nil : description,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: settings,
            statistics: AIChatStatistics(
                totalMessages: 0,
                userMessages: 0,
                assistantMessages: 0,
                totalResponseTime: 0,
                averageResponseTime: 0,
                suggestionsProvided: 0,
                actionsExecuted: 0
            )
        )
        
        do {
            let createdSession = try await viewModel.createSession(session)
            onSessionCreated(createdSession)
        } catch {
            // Handle error - could show alert
            print("Failed to create session: \(error)")
        }
    }
}
