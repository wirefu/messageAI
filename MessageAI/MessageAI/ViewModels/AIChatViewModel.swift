//
//  AIChatViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// ViewModel for AI Chat Interface
@MainActor
final class AIChatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Messages in the current AI session
    @Published var messages: [AIChatMessage] = []
    
    /// Whether the AI is currently processing a request
    @Published var isLoading: Bool = false
    
    /// Current error message, if any
    @Published var errorMessage: String?
    
    /// Current user query being typed
    @Published var currentQuery: String = ""
    
    /// Whether the session is active
    @Published var isSessionActive: Bool = false
    
    /// Current AI session ID
    @Published var sessionId: String?
    
    /// Available message actions
    @Published var availableActions: [AIChatAction] = []
    
    /// Proactive suggestions from AI
    @Published var proactiveSuggestions: [String] = []
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Initialization
    
    init() {
        createNewSession()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Public Methods
    
    /// Send a query to the AI assistant
    func sendQuery() {
        guard !currentQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = AIChatMessage(
            id: UUID().uuidString,
            sessionID: sessionId ?? "",
            userID: "current-user",
            content: currentQuery,
            role: .user,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        // Add user message immediately
        messages.append(userMessage)
        currentQuery = ""
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement actual AI response
        // For now, add a placeholder response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addPlaceholderResponse()
        }
    }
    
    /// Clear the current session
    func clearSession() {
        messages.removeAll()
        availableActions.removeAll()
        proactiveSuggestions.removeAll()
        errorMessage = nil
        createNewSession()
    }
    
    /// Retry the last failed request
    func retryLastRequest() {
        guard let lastUserMessage = messages.last(where: { $0.role == .user }) else {
            return
        }
        
        currentQuery = lastUserMessage.content
        sendQuery()
    }
    
    /// Dismiss an error message
    func dismissError() {
        errorMessage = nil
    }
    
    /// Dismiss a proactive suggestion
    func dismissSuggestion(_ suggestion: String) {
        proactiveSuggestions.removeAll { $0 == suggestion }
    }
    
    /// Execute a message action
    func executeAction(_ action: AIChatAction, on message: AIChatMessage) {
        // TODO: Implement action execution
        print("Executing action: \(action.name) on message: \(message.id)")
    }
    
    // MARK: - Private Methods
    
    private func createNewSession() {
        sessionId = UUID().uuidString
        isSessionActive = true
    }
    
    private func addPlaceholderResponse() {
        let aiResponse = AIChatMessage(
            id: UUID().uuidString,
            sessionID: sessionId ?? "",
            userID: "ai",
            content: "I'm a placeholder AI response. This will be replaced with actual AI functionality in the next phase.",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        messages.append(aiResponse)
        isLoading = false
        
        // Add some placeholder actions
        availableActions = [
            AIChatAction(
                id: "translate",
                name: "Translate",
                description: "Translate this message to another language",
                parameters: ["targetLanguage": "Spanish"]
            ),
            AIChatAction(
                id: "summarize",
                name: "Summarize",
                description: "Create a summary of this conversation",
                parameters: nil
            )
        ]
        
        // Add some placeholder suggestions
        proactiveSuggestions = [
            "Would you like me to explain this in more detail?",
            "Should I translate this to another language?",
            "Would you like a summary of our conversation?"
        ]
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
}