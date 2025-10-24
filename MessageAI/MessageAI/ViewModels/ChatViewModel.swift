//
//  ChatViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

/// ViewModel for managing chat state and messaging operations
@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var conversation: Conversation?
    
    // MARK: - Dependencies
    
    private let messageRepository: MessageRepositoryProtocol
    private let conversationRepository: ConversationRepositoryProtocol
    private let currentUserID: String
    private let conversationID: String
    
    private var lastDocument: DocumentSnapshot?
    private var hasMoreMessages = true
    
    // MARK: - Initialization
    
    init(
        conversationID: String,
        currentUserID: String,
        messageRepository: MessageRepositoryProtocol = MessageRepository(),
        conversationRepository: ConversationRepositoryProtocol = ConversationRepository()
    ) {
        self.conversationID = conversationID
        self.currentUserID = currentUserID
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        
        Task {
            await loadConversation()
            await loadInitialMessages()
            startObserving()
        }
    }
    
    // MARK: - Data Loading
    
    /// Loads conversation details
    private func loadConversation() async {
        do {
            conversation = try await conversationRepository.getConversation(id: conversationID)
        } catch {
            self.error = .conversationNotFound
        }
    }
    
    /// Loads initial messages
    private func loadInitialMessages() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await messageRepository.getMessagesPaginated(
                conversationID: conversationID,
                limit: AppConstants.Messaging.messagesPerPage,
                lastDocument: nil
            )
            
            messages = result.messages.reversed() // Show oldest first in UI
            lastDocument = result.lastDocument
            hasMoreMessages = result.messages.count == AppConstants.Messaging.messagesPerPage
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .firestoreError("Failed to load messages")
        }
    }
    
    /// Loads more messages (pagination)
    func loadMoreMessages() async {
        guard !isLoading && hasMoreMessages else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await messageRepository.getMessagesPaginated(
                conversationID: conversationID,
                limit: AppConstants.Messaging.messagesPerPage,
                lastDocument: lastDocument
            )
            
            let newMessages = result.messages.reversed()
            messages.insert(contentsOf: newMessages, at: 0)
            lastDocument = result.lastDocument
            hasMoreMessages = result.messages.count == AppConstants.Messaging.messagesPerPage
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .firestoreError("Failed to load more messages")
        }
    }
    
    /// Starts observing messages in real-time
    private func startObserving() {
        messageRepository.observeMessages(conversationID: conversationID) { [weak self] messages in
            Task { @MainActor in
                self?.messages = messages
            }
        }
    }
    
    /// Stops observing messages
    nonisolated func stopObserving() {
        if let repo = messageRepository as? MessageRepository {
            repo.stopObserving()
        }
    }
    
    // MARK: - Message Operations
    
    /// Sends a message
    func sendMessage(content: String) async {
        guard content.isNotEmpty else {
            error = .emptyMessage
            return
        }
        
        guard content.hasMaximumLength(AppConstants.Messaging.maxMessageLength) else {
            error = .messageTooLong
            return
        }
        
        let message = Message(
            id: UUID().uuidString,
            conversationID: conversationID,
            senderID: currentUserID,
            content: content.trimmed,
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        // Optimistic UI update
        messages.append(message)
        
        do {
            try await messageRepository.sendMessage(message, to: conversationID)
            
            // Update status to sent
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].status = .sent
            }
        } catch let appError as AppError {
            error = appError
            
            // Remove from UI on failure
            messages.removeAll { $0.id == message.id }
        } catch {
            self.error = .sendFailed
            messages.removeAll { $0.id == message.id }
        }
    }
    
    /// Marks messages as read
    func markMessagesAsRead() async {
        let unreadMessages = messages.filter { !$0.isRead && !$0.isFromCurrentUser(currentUserID) }
        let messageIDs = unreadMessages.map { $0.id }
        
        guard !messageIDs.isEmpty else { return }
        
        do {
            try await messageRepository.markAsRead(messageIDs: messageIDs, conversationID: conversationID)
            
            // Update UI
            for id in messageIDs {
                if let index = messages.firstIndex(where: { $0.id == id }) {
                    messages[index].status = .read
                    messages[index].readAt = Date()
                }
            }
            
            // Reset unread count in conversation
            try await conversationRepository.resetUnreadCount(conversationID: conversationID, userID: currentUserID)
        } catch {
            // Silent fail - not critical
        }
    }
    
    /// Clears error state
    func clearError() {
        error = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopObserving()
    }
}
