//
//  SuggestionViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions
import Combine

@MainActor
class SuggestionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var activeSuggestion: ProactiveSuggestionBackend?
    @Published var suggestionQueue: [ProactiveSuggestionBackend] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    private var suggestionListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    private let userId: String
    
    // MARK: - Initialization
    
    init(userId: String) {
        self.userId = userId
        setupSuggestionListener()
    }
    
    deinit {
        suggestionListener?.remove()
    }
    
    // MARK: - Public Methods
    
    /// Check for new proactive suggestions
    func checkForSuggestions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await functions.httpsCallable("checkProactiveSuggestions").call()
            
            guard let resultData = result.data as? [String: Any],
                  let success = resultData["success"] as? Bool,
                  success else {
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            
            if let suggestionData = resultData["suggestion"] as? [String: Any] {
                let suggestion = try self.parseSuggestion(from: suggestionData)
                await MainActor.run {
                    self.activeSuggestion = suggestion
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to check suggestions: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Dismiss a suggestion
    func dismissSuggestion(id: String) async {
        do {
            // Update Firestore
            try await db.collection("users")
                .document(userId)
                .collection("proactiveSuggestions")
                .document(id)
                .updateData(["dismissed": true])
            
            // Remove from active suggestion
            if activeSuggestion?.id == id {
                activeSuggestion = nil
            }
            
            // Remove from queue
            suggestionQueue.removeAll { $0.id == id }
            
        } catch {
            errorMessage = "Failed to dismiss suggestion: \(error.localizedDescription)"
        }
    }
    
    /// Take action on a suggestion
    func takeSuggestionAction(id: String, action: String) async {
        do {
            // Update Firestore
            try await db.collection("users")
                .document(userId)
                .collection("proactiveSuggestions")
                .document(id)
                .updateData(["actionTaken": true])
            
            // Handle specific actions based on suggestion type
            if let suggestion = activeSuggestion, suggestion.id == id {
                await handleSuggestionAction(suggestion, action: action)
            }
            
            // Remove from active suggestion
            if activeSuggestion?.id == id {
                activeSuggestion = nil
            }
            
            // Remove from queue
            suggestionQueue.removeAll { $0.id == id }
            
        } catch {
            errorMessage = "Failed to take action: \(error.localizedDescription)"
        }
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// Setup Firestore listener for suggestions
    private func setupSuggestionListener() {
        suggestionListener = db.collection("users")
            .document(userId)
            .collection("proactiveSuggestions")
            .whereField("dismissed", isEqualTo: false)
            .whereField("actionTaken", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "Failed to listen for suggestions: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let suggestions = documents.compactMap { doc in
                    ProactiveSuggestionBackend.from(document: doc)
                }
                
                Task { @MainActor in
                    self.suggestionQueue = suggestions
                    
                    // Set the most recent suggestion as active
                    if let mostRecent = suggestions.sorted(by: { $0.createdAt > $1.createdAt }).first {
                        self.activeSuggestion = mostRecent
                    } else {
                        self.activeSuggestion = nil
                    }
                }
            }
    }
    
    /// Parse suggestion from Cloud Function response
    private func parseSuggestion(from data: [String: Any]) throws -> ProactiveSuggestionBackend {
        guard let id = data["id"] as? String,
              let type = data["type"] as? String,
              let priority = data["priority"] as? String,
              let title = data["title"] as? String,
              let message = data["message"] as? String,
              let actionText = data["actionText"] as? String,
              let dismissText = data["dismissText"] as? String,
              let metadataData = data["metadata"] as? [String: Any] else {
            throw SuggestionError.invalidData
        }
        
        let metadata = SuggestionMetadata(
            conversationId: metadataData["conversationId"] as? String ?? "",
            messageId: metadataData["messageId"] as? String ?? "",
            detectedAt: metadataData["detectedAt"] as? String ?? "",
            userTimezone: metadataData["userTimezone"] as? String,
            recipientTimezone: metadataData["recipientTimezone"] as? String,
            originalText: metadataData["originalText"] as? String,
            suggestedClarification: metadataData["suggestedClarification"] as? String
        )
        
        return ProactiveSuggestionBackend(
            id: id,
            type: SuggestionTypeBackend(rawValue: type) ?? .timezoneAmbiguity,
            priority: SuggestionPriority(rawValue: priority) ?? .low,
            title: title,
            message: message,
            actionText: actionText,
            dismissText: dismissText,
            metadata: metadata,
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
    
    /// Handle specific suggestion actions
    private func handleSuggestionAction(_ suggestion: ProactiveSuggestionBackend, action: String) async {
        switch suggestion.type {
        case .timezoneAmbiguity:
            await handleTimezoneAction(suggestion)
        case .unclearReference:
            await handleReferenceAction(suggestion)
        case .missedFollowup:
            await handleFollowupAction(suggestion)
        }
    }
    
    /// Handle timezone suggestion action
    private func handleTimezoneAction(_ suggestion: ProactiveSuggestionBackend) async {
        // For now, just log the action
        // In a full implementation, this would open a clarification dialog
        print("Timezone clarification requested for: \(suggestion.metadata.originalText ?? "")")
    }
    
    /// Handle unclear reference suggestion action
    private func handleReferenceAction(_ suggestion: ProactiveSuggestionBackend) async {
        // For now, just log the action
        // In a full implementation, this would open an add context dialog
        print("Context addition requested for: \(suggestion.metadata.originalText ?? "")")
    }
    
    /// Handle missed followup suggestion action
    private func handleFollowupAction(_ suggestion: ProactiveSuggestionBackend) async {
        // For now, just log the action
        // In a full implementation, this would open a followup dialog
        print("Followup action requested for: \(suggestion.metadata.originalText ?? "")")
    }
}

// MARK: - Error Types

enum SuggestionError: LocalizedError {
    case invalidData
    case networkError(Error)
    case authenticationError
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid suggestion data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationError:
            return "Authentication required"
        }
    }
}
