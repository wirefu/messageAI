//
//  AIService.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFunctions

/// Service for calling AI Cloud Functions
final class AIService {
    // MARK: - Singleton
    
    static let shared = AIService()
    
    private let functions = Functions.functions()
    
    private init() {}
    
    // MARK: - Summarization
    
    /// Summarizes a conversation
    /// - Parameters:
    ///   - conversationID: Conversation to summarize
    ///   - messageCount: Number of recent messages to include
    /// - Returns: Conversation summary
    func summarizeConversation(conversationID: String, messageCount: Int = 20) async throws -> ConversationSummary {
        let data: [String: Any] = [
            "conversationID": conversationID,
            "messageCount": messageCount
        ]
        
        do {
            let result = try await functions.httpsCallable("summarizeConversation").call(data)
            
            guard let response = result.data as? [String: Any] else {
                throw AppError.aiFunctionError("Invalid response format")
            }
            
            return try parseSummaryResponse(response)
        } catch {
            throw AppError.aiFunctionError("Summarization failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Clarity Check
    
    /// Checks message clarity
    /// - Parameters:
    ///   - message: Message text to check
    ///   - conversationContext: Recent conversation messages for context
    /// - Returns: AI suggestion for improvements
    func checkClarity(message: String, conversationContext: [String] = []) async throws -> AISuggestion {
        let data: [String: Any] = [
            "message": message,
            "context": conversationContext
        ]
        
        do {
            let result = try await functions.httpsCallable("checkClarity").call(data)
            
            guard let response = result.data as? [String: Any] else {
                throw AppError.aiFunctionError("Invalid response format")
            }
            
            return try parseClarityResponse(response)
        } catch {
            throw AppError.aiFunctionError("Clarity check failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Action Items
    
    /// Extracts action items from messages
    /// - Parameters:
    ///   - messages: Messages to analyze
    ///   - conversationID: Conversation ID
    /// - Returns: Array of extracted action items
    func extractActionItems(messages: [String], conversationID: String) async throws -> [ActionItem] {
        let data: [String: Any] = [
            "messages": messages,
            "conversationID": conversationID
        ]
        
        do {
            let result = try await functions.httpsCallable("extractActionItems").call(data)
            
            guard let response = result.data as? [String: Any],
                  let items = response["actionItems"] as? [[String: Any]] else {
                throw AppError.aiFunctionError("Invalid response format")
            }
            
            return try parseActionItems(items, conversationID: conversationID)
        } catch {
            throw AppError.aiFunctionError("Action item extraction failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Response Parsing
    
    /// Parses summary response from Cloud Function
    /// Internal for testing purposes
    func parseSummaryResponse(_ response: [String: Any]) throws -> ConversationSummary {
        let conversationID = response["conversationID"] as? String ?? ""
        let keyPoints = response["keyPoints"] as? [String] ?? []
        let decisions = response["decisions"] as? [String] ?? []
        let actionItems = response["actionItems"] as? [String] ?? []
        let openQuestions = response["openQuestions"] as? [String] ?? []
        
        return ConversationSummary(
            id: UUID().uuidString,
            conversationID: conversationID,
            messageRange: ConversationSummary.DateRange(
                start: Date().addingTimeInterval(-3600),
                end: Date()
            ),
            keyPoints: keyPoints,
            decisions: decisions,
            actionItems: actionItems,
            openQuestions: openQuestions,
            createdAt: Date()
        )
    }
    
    /// Parses clarity response from Cloud Function
    /// Internal for testing purposes
    func parseClarityResponse(_ response: [String: Any]) throws -> AISuggestion {
        return AISuggestion(
            clarityIssues: response["clarityIssues"] as? [String],
            suggestedRevision: response["suggestedRevision"] as? String,
            toneWarning: response["toneWarning"] as? String,
            alternativePhrasing: response["alternativePhrasing"] as? String
        )
    }
    
    /// Parses action items from Cloud Function response
    /// Internal for testing purposes
    func parseActionItems(_ items: [[String: Any]], conversationID: String) throws -> [ActionItem] {
        return items.compactMap { item in
            guard let description = item["description"] as? String else { return nil }
            
            return ActionItem(
                id: UUID().uuidString,
                conversationID: conversationID,
                messageID: item["messageID"] as? String ?? "",
                description: description,
                assignedTo: item["assignedTo"] as? String,
                dueDate: nil,
                isCompleted: false,
                createdAt: Date()
            )
        }
    }
}
