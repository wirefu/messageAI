//
//  ActionItemRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Protocol defining action item data operations
protocol ActionItemRepositoryProtocol {
    func getActionItems(conversationID: String) async throws -> [ActionItem]
    func createActionItem(_ item: ActionItem) async throws
    func updateActionItem(_ item: ActionItem) async throws
    func deleteActionItem(id: String, conversationID: String) async throws
    func markComplete(id: String, conversationID: String, isCompleted: Bool) async throws
    func getOpenActionItems(conversationID: String) async throws -> [ActionItem]
    func getCompletedActionItems(conversationID: String) async throws -> [ActionItem]
}

/// Repository for action item data operations with Firestore
final class ActionItemRepository: ActionItemRepositoryProtocol {
    private let db = Firestore.firestore()
    
    // MARK: - Get Action Items
    
    /// Gets all action items for a conversation
    /// - Parameter conversationID: Conversation ID
    /// - Returns: Array of action items ordered by creation date
    /// - Throws: AppError if fetch fails
    func getActionItems(conversationID: String) async throws -> [ActionItem] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .order(by: FirebaseConstants.ActionItemFields.createdAt, descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { ActionItem.from(document: $0) }
        } catch {
            throw AppError.firestoreError("Failed to fetch action items: \(error.localizedDescription)")
        }
    }
    
    /// Gets only open (incomplete) action items
    /// - Parameter conversationID: Conversation ID
    /// - Returns: Array of incomplete action items
    /// - Throws: AppError if fetch fails
    func getOpenActionItems(conversationID: String) async throws -> [ActionItem] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .whereField(FirebaseConstants.ActionItemFields.isCompleted, isEqualTo: false)
                .order(by: FirebaseConstants.ActionItemFields.createdAt, descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { ActionItem.from(document: $0) }
        } catch {
            throw AppError.firestoreError("Failed to fetch open action items: \(error.localizedDescription)")
        }
    }
    
    /// Gets only completed action items
    /// - Parameter conversationID: Conversation ID
    /// - Returns: Array of completed action items
    /// - Throws: AppError if fetch fails
    func getCompletedActionItems(conversationID: String) async throws -> [ActionItem] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .whereField(FirebaseConstants.ActionItemFields.isCompleted, isEqualTo: true)
                .order(by: FirebaseConstants.ActionItemFields.createdAt, descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { ActionItem.from(document: $0) }
        } catch {
            throw AppError.firestoreError("Failed to fetch completed action items: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create Action Item
    
    /// Creates a new action item
    /// - Parameter item: ActionItem to create
    /// - Throws: AppError if creation fails
    func createActionItem(_ item: ActionItem) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(item.conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .document(item.id)
                .setData(item.toFirestore())
        } catch {
            throw AppError.firestoreError("Failed to create action item: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Action Item
    
    /// Updates an existing action item
    /// - Parameter item: ActionItem with updated data
    /// - Throws: AppError if update fails
    func updateActionItem(_ item: ActionItem) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(item.conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .document(item.id)
                .updateData(item.toFirestore())
        } catch {
            throw AppError.firestoreError("Failed to update action item: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Action Item
    
    /// Deletes an action item
    /// - Parameters:
    ///   - id: Action item ID
    ///   - conversationID: Conversation ID
    /// - Throws: AppError if deletion fails
    func deleteActionItem(id: String, conversationID: String) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .document(id)
                .delete()
        } catch {
            throw AppError.firestoreError("Failed to delete action item: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Mark Complete
    
    /// Marks an action item as complete or incomplete
    /// - Parameters:
    ///   - id: Action item ID
    ///   - conversationID: Conversation ID
    ///   - isCompleted: Completion status
    /// - Throws: AppError if update fails
    func markComplete(id: String, conversationID: String, isCompleted: Bool) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.actionItemsSubcollection)
                .document(id)
                .updateData([
                    FirebaseConstants.ActionItemFields.isCompleted: isCompleted
                ])
        } catch {
            throw AppError.firestoreError("Failed to mark action item complete: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Auto-Extract
    
    /// Auto-extracts action items from message content
    /// - Parameters:
    ///   - messageContent: Message text to analyze
    ///   - conversationID: Conversation ID
    ///   - messageID: Message ID
    /// - Returns: Array of extracted action items
    /// - Throws: AppError if extraction fails
    func autoExtractActionItems(
        messageContent: String,
        conversationID: String,
        messageID: String
    ) async throws -> [ActionItem] {
        do {
            // Call AI service to extract action items
            let items = try await AIService.shared.extractActionItems(
                messages: [messageContent],
                conversationID: conversationID
            )
            
            // Save extracted items to Firestore
            for item in items {
                var updatedItem = item
                updatedItem.messageID = messageID
                try await createActionItem(updatedItem)
            }
            
            return items
        } catch {
            throw AppError.aiFunctionError("Failed to extract action items: \(error.localizedDescription)")
        }
    }
}

