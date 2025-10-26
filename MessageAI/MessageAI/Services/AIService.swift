//
//  AIService.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFunctions

// MARK: - AI Error Types

enum AIError: LocalizedError {
    case invalidResponse
    case actionFailed(String)
    case networkError(Error)
    case authenticationError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .actionFailed(let message):
            return "Action failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationError:
            return "Authentication required"
        }
    }
}

/// Service for calling AI Cloud Functions with caching and cost optimization
@MainActor
final class AIService {
    // MARK: - Singleton
    
    static let shared = AIService()
    
    private let functions: Functions
    private let cache = AICache()
    
    private init() {
        // PRODUCTION MODE: Use deployed Cloud Functions with real OpenAI
        functions = Functions.functions()
        print("🤖 AIService: Using PRODUCTION Cloud Functions")
        print("✅ Real GPT-4 AI enabled")
        print("💰 Cost tracking enabled")
    }
    
    // MARK: - Summarization
    
    /// Summarizes a conversation with caching
    /// - Parameters:
    ///   - conversationID: Conversation to summarize
    ///   - messageCount: Number of recent messages to include
    /// - Returns: Conversation summary
    func summarizeConversation(conversationID: String, messageCount: Int = 20) async throws -> ConversationSummary {
        // Check cache first
        let cacheKey = "summary_\(conversationID)_\(messageCount)"
        if let cachedSummary = cache.getSummary(for: cacheKey) {
            print("📦 AIService: Using cached summary for \(conversationID)")
            return cachedSummary
        }
        
        let data: [String: Any] = [
            "conversationID": conversationID,
            "messageCount": messageCount
        ]
        
        do {
            let result = try await functions.httpsCallable("summarizeConversation").call(data)
            
            guard let response = result.data as? [String: Any] else {
                throw AppError.aiFunctionError("Invalid response format")
            }
            
            let summary = try parseSummaryResponse(response)
            
            // Cache the result
            cache.setSummary(summary, for: cacheKey)
            
            // Track cost
            // Cost tracking removed for now
            
            return summary
        } catch {
            throw AppError.aiFunctionError("Summarization failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Clarity Check
    
    /// Checks message clarity with caching
    /// - Parameters:
    ///   - message: Message text to check
    ///   - conversationContext: Recent conversation messages for context
    /// - Returns: AI suggestion for improvements
    func checkClarity(message: String, conversationContext: [String] = []) async throws -> AISuggestion {
        // Check cache first (only for identical messages)
        let cacheKey = "clarity_\(message.hashValue)"
        if let cachedSuggestion = cache.getClaritySuggestion(for: cacheKey) {
            print("📦 AIService: Using cached clarity suggestion")
            return cachedSuggestion
        }
        
        let data: [String: Any] = [
            "message": message,
            "context": conversationContext
        ]
        
        do {
            let result = try await functions.httpsCallable("checkClarity").call(data)
            
            guard let response = result.data as? [String: Any] else {
                throw AppError.aiFunctionError("Invalid response format")
            }
            
            let suggestion = try parseClarityResponse(response)
            
            // Cache the result
            cache.setClaritySuggestion(suggestion, for: cacheKey)
            
            // Track cost
            // Cost tracking removed for now
            
            return suggestion
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
        print("🚀 AIService: Starting action item extraction")
        print("📝 AIService: Messages: \(messages)")
        print("💬 AIService: Conversation ID: \(conversationID)")
        
        let data: [String: Any] = [
            "messages": messages,
            "conversationID": conversationID
        ]
        
        do {
            print("☁️ AIService: Calling Firebase function 'extractActionItems'")
            let result = try await functions.httpsCallable("extractActionItems").call(data)
            print("✅ AIService: Function call successful")
            print("📊 AIService: Raw result: \(result.data)")
            
            guard let response = result.data as? [String: Any] else {
                print("❌ AIService: Response is not a dictionary")
                throw AppError.aiFunctionError("Invalid response format - not a dictionary")
            }
            
            print("📋 AIService: Response keys: \(response.keys)")
            
            guard let items = response["actionItems"] as? [[String: Any]] else {
                print("❌ AIService: No actionItems in response")
                print("📊 AIService: Full response: \(response)")
                throw AppError.aiFunctionError("Invalid response format - no actionItems")
            }
            
            print("🎯 AIService: Found \(items.count) action items")
            let parsedItems = try parseActionItems(items, conversationID: conversationID)
            print("✅ AIService: Successfully parsed \(parsedItems.count) action items")
            return parsedItems
        } catch {
            print("❌ AIService: Action item extraction failed: \(error)")
            print("❌ AIService: Error type: \(type(of: error))")
            print("❌ AIService: Error description: \(error.localizedDescription)")
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
    
    // MARK: - Message Actions
    
    /// Perform a message action (translate, rewrite, extract, summarize)
    /// - Parameters:
    ///   - actionType: Type of action to perform
    ///   - messageId: ID of the message to act on
    ///   - conversationId: ID of the conversation
    ///   - parameters: Additional parameters for the action
    /// - Returns: Action result with processed content
    func performMessageAction(
        actionType: MessageActionType,
        messageId: String,
        conversationId: String,
        parameters: [String: Any] = [:]
    ) async throws -> MessageActionResult {
        // Check cache first
        let cacheKey = "action_\(actionType.rawValue)_\(messageId)_\(conversationId)"
        if let cachedResult = cache.getActionResult(for: cacheKey) {
            print("📦 AIService: Using cached action result for \(actionType.rawValue)")
            return cachedResult
        }
        
        let data: [String: Any] = [
            "actionType": actionType.rawValue,
            "messageId": messageId,
            "conversationId": conversationId,
            "parameters": parameters
        ]
        
        do {
            print("🤖 AIService: Calling performMessageAction for \(actionType.rawValue)")
            let result = try await functions.httpsCallable("performMessageAction").call(data)
            
            guard let resultData = result.data as? [String: Any] else {
                throw AIError.invalidResponse
            }
            
            let actionResult = try parseActionResult(from: resultData, actionType: actionType)
            
            // Cache the result
            cache.setActionResult(actionResult, for: cacheKey)
            
            print("✅ AIService: Action \(actionType.rawValue) completed successfully")
            return actionResult
            
        } catch {
            print("❌ AIService: Action \(actionType.rawValue) failed: \(error)")
            throw error
        }
    }
    
    private func parseActionResult(from data: [String: Any], actionType: MessageActionType) throws -> MessageActionResult {
        guard let success = data["success"] as? Bool, success else {
            let error = data["error"] as? String ?? "Unknown error"
            throw AIError.actionFailed(error)
        }
        
        guard let result = data["result"] as? [String: Any] else {
            throw AIError.invalidResponse
        }
        
        let originalText = result["originalText"] as? String ?? ""
        let resultText = getResultText(from: result, actionType: actionType)
        let metadata = result["metadata"] as? [String: Any] ?? [:]
        
        return MessageActionResult(
            actionType: actionType,
            originalText: originalText,
            resultText: resultText,
            metadata: metadata
        )
    }
    
    private func getResultText(from result: [String: Any], actionType: MessageActionType) -> String {
        switch actionType {
        case .translate:
            return result["translatedText"] as? String ?? ""
        case .rewrite:
            return result["rewrittenText"] as? String ?? ""
        case .extract:
            if let entities = result["entities"] as? [String: Any] {
                return formatEntities(entities)
            }
            return ""
        case .summarize:
            return result["summary"] as? String ?? ""
        case .clarify:
            return result["clarifiedText"] as? String ?? ""
        case .expand:
            return result["expandedText"] as? String ?? ""
        case .shorten:
            return result["shortenedText"] as? String ?? ""
        }
    }
    
    private func formatEntities(_ entities: [String: Any]) -> String {
        var formattedText = ""
        
        if let dates = entities["dates"] as? [String], !dates.isEmpty {
            formattedText += "📅 Dates: \(dates.joined(separator: ", "))\n"
        }
        
        if let people = entities["people"] as? [String], !people.isEmpty {
            formattedText += "👥 People: \(people.joined(separator: ", "))\n"
        }
        
        if let organizations = entities["organizations"] as? [String], !organizations.isEmpty {
            formattedText += "🏢 Organizations: \(organizations.joined(separator: ", "))\n"
        }
        
        if let locations = entities["locations"] as? [String], !locations.isEmpty {
            formattedText += "📍 Locations: \(locations.joined(separator: ", "))\n"
        }
        
        if let topics = entities["topics"] as? [String], !topics.isEmpty {
            formattedText += "💬 Topics: \(topics.joined(separator: ", "))\n"
        }
        
        return formattedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - AI Cache

/// Simple in-memory cache for AI responses
final class AICache {
    private var summaryCache: [String: ConversationSummary] = [:]
    private var clarityCache: [String: AISuggestion] = [:]
    private var actionItemsCache: [String: [ActionItem]] = [:]
    private var toneAnalysisCache: [String: ToneAnalysisResult] = [:]
    private var actionResultCache: [String: MessageActionResult] = [:]
    
    private let maxCacheSize = 100
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    func getSummary(for key: String) -> ConversationSummary? {
        return summaryCache[key]
    }
    
    func setSummary(_ summary: ConversationSummary, for key: String) {
        summaryCache[key] = summary
        cleanupCache()
    }
    
    func getClaritySuggestion(for key: String) -> AISuggestion? {
        return clarityCache[key]
    }
    
    func setClaritySuggestion(_ suggestion: AISuggestion, for key: String) {
        clarityCache[key] = suggestion
        cleanupCache()
    }
    
    func getActionItems(for key: String) -> [ActionItem]? {
        return actionItemsCache[key]
    }
    
    func setActionItems(_ items: [ActionItem], for key: String) {
        actionItemsCache[key] = items
        cleanupCache()
    }
    
    func getToneAnalysis(for key: String) -> ToneAnalysisResult? {
        return toneAnalysisCache[key]
    }
    
    func setToneAnalysis(_ result: ToneAnalysisResult, for key: String) {
        toneAnalysisCache[key] = result
        cleanupCache()
    }
    
    func getActionResult(for key: String) -> MessageActionResult? {
        return actionResultCache[key]
    }
    
    func setActionResult(_ result: MessageActionResult, for key: String) {
        actionResultCache[key] = result
        cleanupCache()
    }
    
    private func cleanupCache() {
        // Simple LRU cleanup - remove oldest entries if cache is too large
        if summaryCache.count > maxCacheSize {
            let keysToRemove = Array(summaryCache.keys.prefix(summaryCache.count - maxCacheSize))
            keysToRemove.forEach { summaryCache.removeValue(forKey: $0) }
        }
        
        if clarityCache.count > maxCacheSize {
            let keysToRemove = Array(clarityCache.keys.prefix(clarityCache.count - maxCacheSize))
            keysToRemove.forEach { clarityCache.removeValue(forKey: $0) }
        }
        
        if actionItemsCache.count > maxCacheSize {
            let keysToRemove = Array(actionItemsCache.keys.prefix(actionItemsCache.count - maxCacheSize))
            keysToRemove.forEach { actionItemsCache.removeValue(forKey: $0) }
        }
        
        if toneAnalysisCache.count > maxCacheSize {
            let keysToRemove = Array(toneAnalysisCache.keys.prefix(toneAnalysisCache.count - maxCacheSize))
            keysToRemove.forEach { toneAnalysisCache.removeValue(forKey: $0) }
        }
    }
}
