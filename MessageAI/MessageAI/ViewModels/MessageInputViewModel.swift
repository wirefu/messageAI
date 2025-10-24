//
//  MessageInputViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Combine

/// ViewModel for message input with clarity checking
@MainActor
final class MessageInputViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var messageText: String = ""
    @Published var claritySuggestion: AISuggestion?
    @Published var isCheckingClarity = false
    @Published var showClaritySuggestion = false
    
    // MARK: - Dependencies
    
    private let aiService = AIService.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    private var debounceTask: Task<Void, Never>?
    
    // MARK: - Configuration
    
    private let debounceDelay: TimeInterval = 2.0 // 2 seconds
    private let minCharactersForCheck = 10
    private var lastCheckedMessage: String = ""
    
    // MARK: - Initialization
    
    init() {
        setupMessageObserver()
    }
    
    // MARK: - Setup
    
    /// Sets up observer for message text changes
    private func setupMessageObserver() {
        $messageText
            .removeDuplicates()
            .sink { [weak self] newText in
                self?.handleMessageTextChange(newText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Message Handling
    
    /// Handles message text changes with debouncing
    private func handleMessageTextChange(_ text: String) {
        // Cancel any pending check
        debounceTask?.cancel()
        
        // Clear suggestion if message is empty or too short
        guard text.count >= minCharactersForCheck else {
            claritySuggestion = nil
            showClaritySuggestion = false
            return
        }
        
        // Don't check if offline
        guard networkMonitor.isConnected else {
            return
        }
        
        // Don't check if same as last checked
        guard text != lastCheckedMessage else {
            return
        }
        
        // Debounced clarity check
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(self?.debounceDelay ?? 2.0 * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await self?.checkClarity(for: text)
        }
    }
    
    // MARK: - Clarity Checking
    
    /// Checks message clarity
    private func checkClarity(for message: String) async {
        guard !message.isEmpty else { return }
        
        isCheckingClarity = true
        defer { isCheckingClarity = false }
        
        do {
            let suggestion = try await aiService.checkClarity(
                message: message,
                conversationContext: []
            )
            
            lastCheckedMessage = message
            
            // Only show suggestion if there are actual issues
            if hasIssues(suggestion) {
                claritySuggestion = suggestion
                showClaritySuggestion = true
            } else {
                claritySuggestion = nil
                showClaritySuggestion = false
            }
        } catch {
            // Silent fail for clarity checks (non-critical feature)
            claritySuggestion = nil
            showClaritySuggestion = false
        }
    }
    
    // MARK: - Suggestion Actions
    
    /// Accepts the suggested revision
    func acceptSuggestion() {
        guard let suggestion = claritySuggestion,
              let revision = suggestion.suggestedRevision else {
            return
        }
        
        messageText = revision
        dismissSuggestion()
    }
    
    /// Dismisses the clarity suggestion
    func dismissSuggestion() {
        claritySuggestion = nil
        showClaritySuggestion = false
    }
    
    /// Clears the message text
    func clearMessage() {
        messageText = ""
        claritySuggestion = nil
        showClaritySuggestion = false
        lastCheckedMessage = ""
    }
    
    // MARK: - Helper Methods
    
    /// Checks if suggestion has actual issues
    private func hasIssues(_ suggestion: AISuggestion) -> Bool {
        return (suggestion.clarityIssues?.isEmpty == false) ||
               suggestion.suggestedRevision != nil ||
               suggestion.toneWarning != nil
    }
    
    /// Manually trigger clarity check (for testing)
    func triggerClarityCheck() async {
        await checkClarity(for: messageText)
    }
}

