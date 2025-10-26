//
//  SuggestionViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import Combine
@testable import MessageAI

@MainActor
final class SuggestionViewModelTests: XCTestCase {
    
    var viewModel: SuggestionViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        viewModel = SuggestionViewModel(userId: "test-user-id")
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.activeSuggestion)
        XCTAssertTrue(viewModel.suggestionQueue.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDismissSuggestion() async {
        // Given
        let suggestion = createMockSuggestion()
        viewModel.activeSuggestion = suggestion
        
        // When
        await viewModel.dismissSuggestion(id: suggestion.id)
        
        // Then
        XCTAssertNil(viewModel.activeSuggestion)
        XCTAssertFalse(viewModel.suggestionQueue.contains { $0.id == suggestion.id })
    }
    
    func testTakeSuggestionAction() async {
        // Given
        let suggestion = createMockSuggestion()
        viewModel.activeSuggestion = suggestion
        
        // When
        await viewModel.takeSuggestionAction(id: suggestion.id, action: "test-action")
        
        // Then
        XCTAssertNil(viewModel.activeSuggestion)
        XCTAssertFalse(viewModel.suggestionQueue.contains { $0.id == suggestion.id })
    }
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testTimezoneActionHandling() async {
        // Given
        let timezoneSuggestion = createMockTimezoneSuggestion()
        viewModel.activeSuggestion = timezoneSuggestion
        
        // When
        await viewModel.takeSuggestionAction(id: timezoneSuggestion.id, action: "Clarify Timezone")
        
        // Then
        XCTAssertNil(viewModel.activeSuggestion)
    }
    
    func testReferenceActionHandling() async {
        // Given
        let referenceSuggestion = createMockReferenceSuggestion()
        viewModel.activeSuggestion = referenceSuggestion
        
        // When
        await viewModel.takeSuggestionAction(id: referenceSuggestion.id, action: "Add Context")
        
        // Then
        XCTAssertNil(viewModel.activeSuggestion)
    }
    
    func testFollowupActionHandling() async {
        // Given
        let followupSuggestion = createMockFollowupSuggestion()
        viewModel.activeSuggestion = followupSuggestion
        
        // When
        await viewModel.takeSuggestionAction(id: followupSuggestion.id, action: "Follow Up")
        
        // Then
        XCTAssertNil(viewModel.activeSuggestion)
    }
    
    // MARK: - Helper Methods
    
    private func createMockSuggestion() -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "test-suggestion-1",
            type: .timezoneAmbiguity,
            priority: .high,
            title: "Test Suggestion",
            message: "This is a test suggestion",
            actionText: "Test Action",
            dismissText: "Dismiss",
            metadata: SuggestionMetadata(
                conversationId: "test-conv-1",
                messageId: "test-msg-1",
                detectedAt: "2025-01-26T10:00:00Z",
                userTimezone: "America/New_York",
                recipientTimezone: "America/Los_Angeles",
                originalText: "Let's meet at 3pm tomorrow",
                suggestedClarification: "Consider clarifying timezone"
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
    
    private func createMockTimezoneSuggestion() -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "timezone-suggestion-1",
            type: .timezoneAmbiguity,
            priority: .high,
            title: "Timezone Ambiguity Detected",
            message: "Time mentioned without timezone",
            actionText: "Clarify Timezone",
            dismissText: "Dismiss",
            metadata: SuggestionMetadata(
                conversationId: "test-conv-1",
                messageId: "test-msg-1",
                detectedAt: "2025-01-26T10:00:00Z",
                userTimezone: "America/New_York",
                recipientTimezone: "America/Los_Angeles",
                originalText: "Let's meet at 3pm tomorrow",
                suggestedClarification: "Consider clarifying timezone"
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
    
    private func createMockReferenceSuggestion() -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "reference-suggestion-1",
            type: .unclearReference,
            priority: .medium,
            title: "Unclear Reference Detected",
            message: "Reference might be unclear",
            actionText: "Add Context",
            dismissText: "Dismiss",
            metadata: SuggestionMetadata(
                conversationId: "test-conv-1",
                messageId: "test-msg-1",
                detectedAt: "2025-01-26T10:00:00Z",
                userTimezone: nil,
                recipientTimezone: nil,
                originalText: "Can you review the document?",
                suggestedClarification: "Consider being more specific"
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
    
    private func createMockFollowupSuggestion() -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "followup-suggestion-1",
            type: .missedFollowup,
            priority: .low,
            title: "Follow-up Reminder",
            message: "Consider following up",
            actionText: "Follow Up",
            dismissText: "Dismiss",
            metadata: SuggestionMetadata(
                conversationId: "test-conv-1",
                messageId: "test-msg-1",
                detectedAt: "2025-01-26T10:00:00Z",
                userTimezone: nil,
                recipientTimezone: nil,
                originalText: "I'll follow up on this",
                suggestedClarification: nil
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
}
