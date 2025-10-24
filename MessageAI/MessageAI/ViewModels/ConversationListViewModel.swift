//
//  ConversationListViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Combine

/// ViewModel for managing conversation list
@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let repository: ConversationRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        repository: ConversationRepositoryProtocol = ConversationRepository(),
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.repository = repository
        self.userRepository = userRepository
    }
    
    func loadConversations(for userID: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            conversations = try await repository.getConversations(for: userID)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .firestoreError("Failed to load conversations")
        }
    }
    
    func startObserving(for userID: String) {
        repository.observeConversations(for: userID) { [weak self] conversations in
            Task { @MainActor in
                self?.conversations = conversations
            }
        }
    }
    
    nonisolated func stopObserving() {
        if let repo = repository as? ConversationRepository {
            repo.stopObserving()
        }
    }
    
    func createNewConversation(currentUserID: String, otherUserID: String) async throws -> String {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let conversationID = try await repository.createConversation(
                participants: [currentUserID, otherUserID]
            )
            return conversationID
        } catch let appError as AppError {
            error = appError
            throw appError
        } catch {
            let appError = AppError.firestoreError("Failed to create conversation")
            self.error = appError
            throw appError
        }
    }
    
    func getUnreadCount(conversationID: String, userID: String) -> Int {
        conversations.first { $0.id == conversationID }?.unreadCount(for: userID) ?? 0
    }
    
    func clearError() {
        error = nil
    }
    
    deinit {
        stopObserving()
    }
}
