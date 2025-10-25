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
    private let networkMonitor = NetworkMonitor.shared
    
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
            observeNetworkChanges()
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
                guard let self = self else { return }
                
                // Update messages from Firestore
                self.messages = messages
                
                // Mark messages from other users as delivered (this device received them)
                let receivedMessages = messages.filter { 
                    !$0.isFromCurrentUser(self.currentUserID) && 
                    $0.status == .sent 
                }
                
                for message in receivedMessages {
                    try? await self.messageRepository.updateMessageStatus(
                        messageID: message.id,
                        conversationID: self.conversationID,
                        status: .delivered
                    )
                }
                
                // Automatically mark received messages as read when they arrive
                await self.markMessagesAsRead()
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
        // Write debug info to a file for easier debugging
        let debugMessage = "🚀 ChatViewModel: sendMessage called with content: '\(content)'\n"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let debugFileURL = documentsPath.appendingPathComponent("messageai_debug.log")
        try? debugMessage.write(to: debugFileURL, atomically: true, encoding: .utf8)
        
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
            
            // Update status to sent (stays grey until actually delivered)
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].status = .sent
            }
            
            // Auto-extract action items from the message
            Task {
                do {
                    // Write debug info to a file for easier debugging
                    let debugMessage = "🤖 Starting action item extraction for: '\(content.trimmed)'\n"
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let debugFileURL = documentsPath.appendingPathComponent("messageai_debug.log")
                    try debugMessage.write(to: debugFileURL, atomically: true, encoding: .utf8)
                    
                    let actionItemRepository = ActionItemRepository()
                    let extractedItems = try await actionItemRepository.autoExtractActionItems(
                        messageContent: content.trimmed,
                        conversationID: conversationID,
                        messageID: message.id
                    )
                    
                    let successMessage = "✅ Extracted \(extractedItems.count) action items: \(extractedItems.map { $0.description })\n"
                    try successMessage.write(to: debugFileURL, atomically: false, encoding: .utf8)
                } catch {
                    let errorMessage = "❌ Action item extraction failed: \(error.localizedDescription)\n"
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let debugFileURL = documentsPath.appendingPathComponent("messageai_debug.log")
                    try? errorMessage.write(to: debugFileURL, atomically: false, encoding: .utf8)
                }
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
    
    /// Marks messages as read and updates status
    func markMessagesAsRead() async {
        // Mark unread messages as read
        let unreadMessages = messages.filter { !$0.isRead && !$0.isFromCurrentUser(currentUserID) }
        let messageIDs = unreadMessages.map { $0.id }
        
        if !messageIDs.isEmpty {
            do {
                try await messageRepository.markAsRead(messageIDs: messageIDs, conversationID: conversationID)
                
                // Update UI
                for id in messageIDs {
                    if let index = messages.firstIndex(where: { $0.id == id }) {
                        messages[index].status = .read
                        messages[index].readAt = Date()
                    }
                }
                
                // Reset unread count
                try await conversationRepository.resetUnreadCount(conversationID: conversationID, userID: currentUserID)
            } catch {
                // Silent fail - not critical
            }
        }
        
        // Update status of sent messages to delivered (when recipient is online)
        let sentMessages = messages.filter { 
            $0.isFromCurrentUser(currentUserID) && 
            $0.status == .sent 
        }
        
        for message in sentMessages {
            do {
                try await messageRepository.updateMessageStatus(
                    messageID: message.id,
                    conversationID: conversationID,
                    status: .delivered
                )
                
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index].status = .delivered
                    messages[index].deliveredAt = Date()
                }
            } catch {
                // Silent fail
            }
        }
    }
    
    /// Deletes a message from the conversation
    /// - Parameter message: Message to delete
    func deleteMessage(_ message: Message) async {
        // Optimistic UI update - remove immediately
        messages.removeAll { $0.id == message.id }
        
        do {
            try await messageRepository.deleteMessage(
                messageID: message.id,
                conversationID: conversationID
            )
        } catch {
            // On error, reload messages
            await loadInitialMessages()
        }
    }
    
    /// Clears error state
    func clearError() {
        error = nil
    }
    
    // MARK: - Cleanup
    
    // MARK: - Network Handling
    
    /// Observes network changes and processes queue when online
    private func observeNetworkChanges() {
        // When network comes back online, process offline queue and update message status
        Task {
            for await _ in NotificationCenter.default.notifications(
                named: NSNotification.Name(AppConstants.Notifications.networkStatusChanged)
            ) {
                if networkMonitor.isConnected {
                    // Process any queued messages
                    if let repo = messageRepository as? MessageRepository {
                        await repo.processOfflineQueue()
                    }
                    
                    // Update message statuses (sent → delivered when recipient comes online)
                    await markMessagesAsRead()
                }
            }
        }
    }
    
    deinit {
        stopObserving()
    }
}
