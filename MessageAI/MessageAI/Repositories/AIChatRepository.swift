//
//  AIChatRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

/// Repository for AI Chat Interface data access
final class AIChatRepository: AIChatRepositoryProtocol {
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    
    // MARK: - Session Management
    
    func getSessions(for userID: String) async throws -> [AIChatSession] {
        let snapshot = try await db.collection("aiSessions")
            .whereField("userID", isEqualTo: userID)
            .order(by: "lastUpdated", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            AIChatSession.from(document: document)
        }
    }
    
    func createSession(_ session: AIChatSession) async throws -> AIChatSession {
        var sessionToCreate = session
        sessionToCreate.userID = getCurrentUserID()
        
        try await db.collection("aiSessions")
            .document(session.id)
            .setData(session.toFirestore())
        
        return sessionToCreate
    }
    
    func deleteSession(_ session: AIChatSession) async throws {
        try await db.collection("aiSessions")
            .document(session.id)
            .delete()
    }
    
    // MARK: - Message Management
    
    func getMessages(for sessionID: String) async throws -> [AIChatMessage] {
        let snapshot = try await db.collection("aiSessions")
            .document(sessionID)
            .collection("messages")
            .order(by: "timestamp")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            AIChatMessage.from(document: document)
        }
    }
    
    func sendMessage(_ message: AIChatMessage) async throws -> AIChatResponse {
        // Call the AI Chat Interface Cloud Function
        let data: [String: Any] = [
            "message": message.content,
            "sessionId": message.sessionID
            // conversationId is optional and not included if nil
        ]
        
        let result = try await functions.httpsCallable("aiChatInterface").call(data)
        
        guard let responseData = result.data as? [String: Any] else {
            throw AppError.networkUnavailable
        }
        
        // Parse the AI response message
        let aiMessage = AIChatMessage(
            id: UUID().uuidString,
            sessionID: message.sessionID,
            userID: "assistant",
            content: responseData["response"] as? String ?? "I'm sorry, I couldn't process that request.",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: parseAIMetadata(from: responseData)
        )
        
        return AIChatResponse(
            aiMessage: aiMessage,
            suggestions: responseData["suggestions"] as? [String],
            actions: parseActions(from: responseData),
            context: responseData["context"] as? String
        )
    }
    
    func clearSession(_ sessionID: String) async throws {
        _ = try await functions.httpsCallable("clearAIChatSession").call([
            "sessionId": sessionID
        ])
    }
    
    // MARK: - Suggestions and Actions
    
    func getSuggestions(for sessionID: String) async throws -> [String] {
        let result = try await functions.httpsCallable("getAIChatSuggestions").call([
            "sessionId": sessionID
        ])
        
        guard let responseData = result.data as? [String: Any],
              let suggestions = responseData["suggestions"] as? [String] else {
            return []
        }
        
        return suggestions
    }
    
    func executeAction(_ action: AIChatAction, on message: AIChatMessage) async throws -> Any {
        let data: [String: Any] = [
            "actionId": action.id,
            "messageId": message.id,
            "parameters": action.parameters ?? [:]
        ]
        
        let result = try await functions.httpsCallable("executeAIChatAction").call(data)
        
        guard let responseData = result.data as? [String: Any] else {
            throw AppError.networkUnavailable
        }
        
        return responseData["result"] ?? "Action completed"
    }
    
    // MARK: - Private Helpers
    
    private func getCurrentUserID() -> String {
        // This should get the current authenticated user ID
        // For now, return a placeholder
        return "current-user-id"
    }
    
    private func parseAIMetadata(from data: [String: Any]) -> AIChatMetadata? {
        guard let metadata = data["aiMetadata"] as? [String: Any] else {
            return nil
        }
        
        return AIChatMetadata(
            model: metadata["model"] as? String,
            responseTime: metadata["responseTime"] as? Int,
            confidence: metadata["confidence"] as? Double,
            context: data["context"] as? String,
            suggestions: parseSuggestions(from: data),
            actions: parseActions(from: data)
        )
    }
    
    private func parseSuggestions(from data: [String: Any]) -> [AIChatSuggestion]? {
        guard let suggestionsData = data["suggestions"] as? [String] else {
            return nil
        }
        
        return suggestionsData.map { suggestion in
            AIChatSuggestion(
                type: "general",
                suggestion: suggestion,
                confidence: 0.8
            )
        }
    }
    
    private func parseActions(from data: [String: Any]) -> [AIChatAction]? {
        guard let actionsData = data["actions"] as? [[String: Any]] else {
            return nil
        }
        
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
}

// MARK: - Protocol Definition

protocol AIChatRepositoryProtocol {
    func getSessions(for userID: String) async throws -> [AIChatSession]
    func createSession(_ session: AIChatSession) async throws -> AIChatSession
    func deleteSession(_ session: AIChatSession) async throws
    func getMessages(for sessionID: String) async throws -> [AIChatMessage]
    func sendMessage(_ message: AIChatMessage) async throws -> AIChatResponse
    func clearSession(_ sessionID: String) async throws
    func getSuggestions(for sessionID: String) async throws -> [String]
    func executeAction(_ action: AIChatAction, on message: AIChatMessage) async throws -> Any
}

// MARK: - Response Models

struct AIChatResponse {
    let aiMessage: AIChatMessage?
    let suggestions: [String]?
    let actions: [AIChatAction]?
    let context: String?
}
