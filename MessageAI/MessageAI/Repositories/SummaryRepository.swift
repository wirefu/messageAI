//
//  SummaryRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Protocol defining summary data operations
protocol SummaryRepositoryProtocol {
    func getSummary(conversationID: String) async throws -> ConversationSummary?
    func requestSummary(conversationID: String, messageCount: Int) async throws -> ConversationSummary
    func cacheSummary(_ summary: ConversationSummary) async throws
    func deleteSummary(id: String, conversationID: String) async throws
    func getAllSummaries(conversationID: String) async throws -> [ConversationSummary]
}

/// Repository for conversation summary operations with Firestore
final class SummaryRepository: SummaryRepositoryProtocol {
    private let db = Firestore.firestore()
    private let aiService = AIService.shared
    private let cacheExpirationHours = 24 // Cache valid for 24 hours
    
    // MARK: - Get Summary
    
    /// Gets the most recent summary for a conversation
    /// - Parameter conversationID: Conversation ID
    /// - Returns: ConversationSummary or nil if no cached summary
    /// - Throws: AppError if fetch fails
    func getSummary(conversationID: String) async throws -> ConversationSummary? {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.summariesSubcollection)
                .order(by: FirebaseConstants.SummaryFields.createdAt, descending: true)
                .limit(to: 1)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            let summary = ConversationSummary.from(document: document)
            
            // Check if cache is still valid
            if let summary = summary, isSummaryValid(summary) {
                return summary
            }
            
            return nil
        } catch {
            throw AppError.firestoreError("Failed to fetch summary: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request New Summary
    
    /// Requests a new summary from AI service
    /// - Parameters:
    ///   - conversationID: Conversation ID
    ///   - messageCount: Number of messages to include
    /// - Returns: Newly generated ConversationSummary
    /// - Throws: AppError if generation fails
    func requestSummary(conversationID: String, messageCount: Int) async throws -> ConversationSummary {
        do {
            // Call AI service to generate summary
            let summary = try await aiService.summarizeConversation(
                conversationID: conversationID,
                messageCount: messageCount
            )
            
            // Cache the summary
            try await cacheSummary(summary)
            
            return summary
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError.aiFunctionError("Failed to generate summary: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Summary
    
    /// Caches a summary to Firestore
    /// - Parameter summary: ConversationSummary to cache
    /// - Throws: AppError if caching fails
    func cacheSummary(_ summary: ConversationSummary) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(summary.conversationID)
                .collection(FirebaseConstants.summariesSubcollection)
                .document(summary.id)
                .setData(summary.toFirestore())
        } catch {
            throw AppError.firestoreError("Failed to cache summary: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Summary
    
    /// Deletes a summary
    /// - Parameters:
    ///   - id: Summary ID
    ///   - conversationID: Conversation ID
    /// - Throws: AppError if deletion fails
    func deleteSummary(id: String, conversationID: String) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.summariesSubcollection)
                .document(id)
                .delete()
        } catch {
            throw AppError.firestoreError("Failed to delete summary: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get All Summaries
    
    /// Gets all summaries for a conversation
    /// - Parameter conversationID: Conversation ID
    /// - Returns: Array of summaries ordered by creation date
    /// - Throws: AppError if fetch fails
    func getAllSummaries(conversationID: String) async throws -> [ConversationSummary] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.summariesSubcollection)
                .order(by: FirebaseConstants.SummaryFields.createdAt, descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { ConversationSummary.from(document: $0) }
        } catch {
            throw AppError.firestoreError("Failed to fetch summaries: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a summary is still valid (not expired)
    /// - Parameter summary: Summary to check
    /// - Returns: True if summary is valid, false if expired
    private func isSummaryValid(_ summary: ConversationSummary) -> Bool {
        let expirationDate = summary.createdAt.addingTimeInterval(
            TimeInterval(cacheExpirationHours * 3600)
        )
        return Date() < expirationDate
    }
    
    /// Invalidates cached summaries when new messages arrive
    /// - Parameter conversationID: Conversation ID
    func invalidateCache(conversationID: String) async throws {
        // Delete all cached summaries for this conversation
        let summaries = try await getAllSummaries(conversationID: conversationID)
        for summary in summaries {
            try await deleteSummary(id: summary.id, conversationID: conversationID)
        }
    }
}

