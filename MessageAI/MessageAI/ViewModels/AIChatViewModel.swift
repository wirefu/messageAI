//
//  AIChatViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

/// ViewModel for managing AI Chat Interface state and operations
@MainActor
final class AIChatViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var sessions: [AIChatSession] = []
    @Published var messages: [AIChatMessage] = []
    @Published var currentSuggestions: [String] = []
    @Published var isLoading = false
    @Published var error: AppError?
    
    // MARK: - Dependencies
    
    private let aiChatRepository: AIChatRepositoryProtocol
    private let sessionID: String?
    
    // MARK: - Initialization
    
    init(
        sessionID: String? = nil,
        aiChatRepository: AIChatRepositoryProtocol = AIChatRepository()
    ) {
        self.sessionID = sessionID
        self.aiChatRepository = aiChatRepository
    }
    
    // MARK: - Session Management
    
    /// Loads AI chat sessions for a user
    func loadSessions(for userID: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            sessions = try await aiChatRepository.getSessions(for: userID)
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    /// Creates a new AI chat session
    func createSession(_ session: AIChatSession) async throws -> AIChatSession {
        return try await aiChatRepository.createSession(session)
    }
    
    /// Deletes an AI chat session
    func deleteSession(_ session: AIChatSession) async {
        do {
            try await aiChatRepository.deleteSession(session)
            sessions.removeAll { $0.id == session.id }
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    // MARK: - Message Management
    
    /// Loads messages for the current session
    func loadMessages() async {
        guard let sessionID = sessionID else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            messages = try await aiChatRepository.getMessages(for: sessionID)
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    /// Sends a message to the AI assistant
    func sendMessage(_ content: String) async {
        guard let sessionID = sessionID else { return }
        
        let message = AIChatMessage(
            id: UUID().uuidString,
            sessionID: sessionID,
            userID: "", // Will be set by repository
            content: content,
            role: .user,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        do {
            // Add user message immediately
            messages.append(message)
            
            // Send to AI and get response
            let response = try await aiChatRepository.sendMessage(message)
            
            // Add AI response
            if let aiMessage = response.aiMessage {
                messages.append(aiMessage)
            }
            
            // Update suggestions
            currentSuggestions = response.suggestions ?? []
            
        } catch {
            self.error = .networkUnavailable
            // Remove the user message if sending failed
            messages.removeAll { $0.id == message.id }
        }
    }
    
    /// Clears the current session
    func clearSession() async {
        guard let sessionID = sessionID else { return }
        
        do {
            try await aiChatRepository.clearSession(sessionID)
            messages.removeAll()
            currentSuggestions.removeAll()
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    /// Gets proactive suggestions for the current session
    func getSuggestions() async {
        guard let sessionID = sessionID else { return }
        
        do {
            currentSuggestions = try await aiChatRepository.getSuggestions(for: sessionID)
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    /// Executes an AI action
    func executeAction(_ action: AIChatAction, on message: AIChatMessage) async -> Any? {
        do {
            return try await aiChatRepository.executeAction(action, on: message)
        } catch {
            self.error = .networkUnavailable
            return nil
        }
    }
}
