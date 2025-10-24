//
//  MessageRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Protocol defining message data operations
protocol MessageRepositoryProtocol {
    func sendMessage(_ message: Message, to conversationID: String) async throws
    func observeMessages(conversationID: String, completion: @escaping ([Message]) -> Void)
    func getMessagesPaginated(
        conversationID: String,
        limit: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (messages: [Message], lastDocument: DocumentSnapshot?)
    func updateMessageStatus(messageID: String, conversationID: String, status: MessageStatus) async throws
    func markAsRead(messageIDs: [String], conversationID: String) async throws
    func deleteMessage(messageID: String, conversationID: String) async throws
}

/// Repository for message data operations with Firestore
final class MessageRepository: MessageRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let networkMonitor = NetworkMonitor.shared
    private let offlineQueue = OfflineQueueService.shared
    
    // MARK: - Send
    
    /// Sends a message to a conversation
    func sendMessage(_ message: Message, to conversationID: String) async throws {
        // If offline, queue the message
        guard networkMonitor.isConnected else {
            offlineQueue.enqueue(message)
            throw AppError.networkUnavailable
        }
        
        do {
            // Save message
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.messagesSubcollection)
                .document(message.id)
                .setData(message.toFirestore())
            
            // Update conversation's last message
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .updateData([
                    FirebaseConstants.ConversationFields.lastMessage: message.toFirestore(),
                    FirebaseConstants.ConversationFields.lastMessageTimestamp: Timestamp(date: message.timestamp)
                ])
        } catch {
            // Queue on failure
            offlineQueue.enqueue(message)
            throw AppError.firestoreError("Failed to send message: \(error.localizedDescription)")
        }
    }
    
    /// Processes offline queue when connection is restored
    func processOfflineQueue() async {
        guard networkMonitor.isConnected else { return }
        
        let queuedMessages = offlineQueue.dequeueAll()
        
        for message in queuedMessages {
            try? await sendMessage(message, to: message.conversationID)
        }
    }
    
    // MARK: - Observe
    
    /// Observes real-time messages in a conversation
    func observeMessages(conversationID: String, completion: @escaping ([Message]) -> Void) {
        listener = db.collection(FirebaseConstants.conversationsCollection)
            .document(conversationID)
            .collection(FirebaseConstants.messagesSubcollection)
            .order(by: FirebaseConstants.MessageFields.timestamp, descending: false)
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let messages = documents.compactMap { Message.from(document: $0) }
                completion(messages)
            }
    }
    
    /// Stops observing messages
    func stopObserving() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Pagination
    
    /// Fetches messages with pagination
    func getMessagesPaginated(
        conversationID: String,
        limit: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (messages: [Message], lastDocument: DocumentSnapshot?) {
        do {
            var query = db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.messagesSubcollection)
                .order(by: FirebaseConstants.MessageFields.timestamp, descending: true)
                .limit(to: limit)
            
            if let lastDocument = lastDocument {
                query = query.start(afterDocument: lastDocument)
            }
            
            let snapshot = try await query.getDocuments()
            let messages = snapshot.documents.compactMap { Message.from(document: $0) }
            
            return (messages: messages, lastDocument: snapshot.documents.last)
        } catch {
            throw AppError.firestoreError("Failed to fetch messages: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update
    
    /// Updates message status
    func updateMessageStatus(
        messageID: String,
        conversationID: String,
        status: MessageStatus
    ) async throws {
        do {
            var updateData: [String: Any] = [
                FirebaseConstants.MessageFields.status: status.rawValue
            ]
            
            switch status {
            case .delivered:
                updateData[FirebaseConstants.MessageFields.deliveredAt] = Timestamp(date: Date())
            case .read:
                updateData[FirebaseConstants.MessageFields.readAt] = Timestamp(date: Date())
            default:
                break
            }
            
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.messagesSubcollection)
                .document(messageID)
                .updateData(updateData)
        } catch {
            throw AppError.firestoreError("Failed to update message status: \(error.localizedDescription)")
        }
    }
    
    /// Marks multiple messages as read
    func markAsRead(messageIDs: [String], conversationID: String) async throws {
        guard !messageIDs.isEmpty else { return }
        
        do {
            let batch = db.batch()
            
            for messageID in messageIDs {
                let messageRef = db.collection(FirebaseConstants.conversationsCollection)
                    .document(conversationID)
                    .collection(FirebaseConstants.messagesSubcollection)
                    .document(messageID)
                
                batch.updateData([
                    FirebaseConstants.MessageFields.status: MessageStatus.read.rawValue,
                    FirebaseConstants.MessageFields.readAt: Timestamp(date: Date())
                ], forDocument: messageRef)
            }
            
            try await batch.commit()
        } catch {
            throw AppError.firestoreError("Failed to mark messages as read: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a message from a conversation
    func deleteMessage(messageID: String, conversationID: String) async throws {
        do {
            try await db.collection(FirebaseConstants.conversationsCollection)
                .document(conversationID)
                .collection(FirebaseConstants.messagesSubcollection)
                .document(messageID)
                .delete()
        } catch {
            throw AppError.firestoreError("Failed to delete message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        listener?.remove()
    }
}
