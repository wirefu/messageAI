//
//  AIChatViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

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
    private let messageRepository = MessageRepository()
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
        
        // Call the AI Chat Interface Cloud Function
        Task {
            await callAIChatInterface(userMessage)
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
    
    /// Get conversation context from recent messages across all conversations
    private func getConversationContext() async -> [[String: Any]] {
        do {
            // Get all conversations for the current user
            let conversationsSnapshot = try await db.collection("conversations")
                .whereField("participants", arrayContains: "current-user") // TODO: Replace with actual user ID
                .getDocuments()
            
            var allContext: [[String: Any]] = []
            
            // Get recent messages from each conversation
            for conversationDoc in conversationsSnapshot.documents {
                let conversationId = conversationDoc.documentID
                
                do {
                    // Get recent messages for AI context (last 5 messages per conversation)
                    let recentMessages = try await messageRepository.getAIContext(for: conversationId, limit: 5)
                    
                    // Convert messages to context format
                    let conversationContext = recentMessages.map { message in
                        [
                            "id": message.id,
                            "content": message.content,
                            "senderId": message.senderID,
                            "timestamp": message.timestamp.timeIntervalSince1970,
                            "conversationId": conversationId
                        ]
                    }
                    
                    allContext.append(contentsOf: conversationContext)
                } catch {
                    print("Failed to get context for conversation \(conversationId): \(error)")
                    // Continue with other conversations
                }
            }
            
            // Sort by timestamp (most recent first) and limit to last 20 messages
            let sortedContext = allContext.sorted { 
                ($0["timestamp"] as? TimeInterval ?? 0) > ($1["timestamp"] as? TimeInterval ?? 0) 
            }
            
            return Array(sortedContext.prefix(20))
            
        } catch {
            print("Failed to get conversation context: \(error)")
            return []
        }
    }
    
    private func callAIChatInterface(_ userMessage: AIChatMessage) async {
        do {
            // Import Firebase Functions
            let functions = Functions.functions()
            
            // Get conversation context from recent messages
            let conversationContext = await getConversationContext()
            
            // Prepare the data for the Cloud Function
            let data: [String: Any] = [
                "message": userMessage.content,
                "sessionId": userMessage.sessionID,
                "conversationContext": conversationContext
            ]
            
            // Call the aiChatInterface Cloud Function
            let result = try await functions.httpsCallable("aiChatInterface").call(data)
            
            // Parse the response
            guard let responseData = result.data as? [String: Any] else {
                throw AppError.networkUnavailable
            }
            
            // Extract the AI response
            let aiResponse = responseData["response"] as? String ?? "I'm sorry, I couldn't process that request."
            let suggestions = responseData["suggestions"] as? [String] ?? []
            let actions = responseData["actions"] as? [[String: Any]] ?? []
            
            // Create the AI message
            let aiMessage = AIChatMessage(
                id: UUID().uuidString,
                sessionID: userMessage.sessionID,
                userID: "ai",
                content: aiResponse,
                role: .assistant,
                timestamp: Date(),
                aiMetadata: nil
            )
            
            // Update the UI on the main thread
            await MainActor.run {
                self.messages.append(aiMessage)
                self.isLoading = false
                self.proactiveSuggestions = suggestions
                self.availableActions = self.parseActions(from: actions)
            }
            
        } catch {
            // Handle errors
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to get AI response: \(error.localizedDescription)"
            }
        }
    }
    
    private func parseActions(from actionsData: [[String: Any]]) -> [AIChatAction] {
        return actionsData.compactMap { actionData in
            guard let id = actionData["id"] as? String,
                  let name = actionData["name"] as? String,
                  let description = actionData["description"] as? String else {
                return nil
            }
            
            return AIChatAction(
                id: id,
                name: name,
                description: description,
                parameters: actionData["parameters"] as? [String: String]
            )
        }
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