//
//  ConversationRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Protocol defining conversation data operations
protocol ConversationRepositoryProtocol {
    func createConversation(participants: [String]) async throws -> String
    func getConversations(for userID: String) async throws -> [Conversation]
    func getConversation(id: String) async throws -> Conversation?
    func observeConversations(for userID: String, completion: @escaping ([Conversation]) -> Void)
    func updateLastMessage(conversationID: String, message: Message) async throws
    func updateUnreadCount(conversationID: String, userID: String, increment: Bool) async throws
    func resetUnreadCount(conversationID: String, userID: String) async throws
}

/// Repository for conversation data operations with Firestore
final class ConversationRepository: ConversationRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func createConversation(participants: [String]) async throws -> String {
        guard participants.count == 2 else {
            throw AppError.invalidData
        }
        
        let existingConversations = try await getConversations(for: participants[0])
        if let existing = existingConversations.first(where: { $0.participants.sorted() == participants.sorted() }) {
            return existing.id
        }
        
        let conversation = Conversation(
            id: UUID().uuidString,
            participants: participants,
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: [:],
            createdAt: Date()
        )
        
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversation.id)
                .setData(conversation.toFirestore())
            
            return conversation.id
        } catch {
            throw AppError.firestoreError("Failed to create conversation: \(error.localizedDescription)")
        }
    }
    
    func getConversations(for userID: String) async throws -> [Conversation] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.conversationsCollection)
                .whereField(FirebaseConstants.ConversationFields.participants, arrayContains: userID)
                .order(by: FirebaseConstants.ConversationFields.lastMessageTimestamp, descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { Conversation.from(document: $0) }
        } catch {
            throw AppError.firestoreError("Failed to fetch conversations: \(error.localizedDescription)")
        }
    }
    
    func getConversation(id: String) async throws -> Conversation? {
        do {
            let document = try await db.collection(FirebaseConstants.conversationsCollection)
                .document(id)
                .getDocument()
            
            return Conversation.from(document: document)
        } catch {
            throw AppError.firestoreError("Failed to fetch conversation: \(error.localizedDescription)")
        }
    }
    
    func observeConversations(for userID: String, completion: @escaping ([Conversation]) -> Void) {
        listener = db.collection(FirebaseConstants.conversationsCollection)
            .whereField(FirebaseConstants.ConversationFields.participants, arrayContains: userID)
            .order(by: FirebaseConstants.ConversationFields.lastMessageTimestamp, descending: true)
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let conversations = documents.compactMap { Conversation.from(document: $0) }
                completion(conversations)
            }
    }
    
    func stopObserving() {
        listener?.remove()
        listener = nil
    }
    
    func updateLastMessage(conversationID: String, message: Message) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .updateData([
                    FirebaseConstants.ConversationFields.lastMessage: message.toFirestore(),
                    FirebaseConstants.ConversationFields.lastMessageTimestamp: Timestamp(date: message.timestamp)
                ])
        } catch {
            throw AppError.firestoreError("Failed to update last message: \(error.localizedDescription)")
        }
    }
    
    func updateUnreadCount(conversationID: String, userID: String, increment: Bool) async throws {
        let conversation = try await getConversation(id: conversationID)
        var unreadCount = conversation?.unreadCount ?? [:]
        
        let currentCount = unreadCount[userID] ?? 0
        unreadCount[userID] = increment ? currentCount + 1 : max(0, currentCount - 1)
        
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .updateData([
                    FirebaseConstants.ConversationFields.unreadCount: unreadCount
                ])
        } catch {
            throw AppError.firestoreError("Failed to update unread count: \(error.localizedDescription)")
        }
    }
    
    func resetUnreadCount(conversationID: String, userID: String) async throws {
        let conversation = try await getConversation(id: conversationID)
        var unreadCount = conversation?.unreadCount ?? [:]
        unreadCount[userID] = 0
        
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .updateData([
                    FirebaseConstants.ConversationFields.unreadCount: unreadCount
                ])
        } catch {
            throw AppError.firestoreError("Failed to reset unread count: \(error.localizedDescription)")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
