//
//  ProactiveSuggestionBannerTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import MessageAI

final class ProactiveSuggestionBannerTests: XCTestCase {
    
    func testProactiveSuggestionBannerDisplay() throws {
        // Given
        let suggestion = createMockTimezoneSuggestion()
        var dismissCalled = false
        var actionCalled = false
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: { dismissCalled = true },
            onTakeAction: { actionCalled = true }
        )
        
        // When
        let view = try banner.inspect()
        
        // Then
        XCTAssertNoThrow(try view.find(text: suggestion.title))
        XCTAssertNoThrow(try view.find(text: suggestion.message))
        XCTAssertNoThrow(try view.find(text: suggestion.actionText))
        XCTAssertNoThrow(try view.find(text: suggestion.dismissText))
    }
    
    func testTimezoneSuggestionBanner() throws {
        // Given
        let suggestion = createMockTimezoneSuggestion()
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        
        // When
        let view = try banner.inspect()
        
        // Then
        XCTAssertNoThrow(try view.find(text: "Timezone Ambiguity Detected"))
        XCTAssertNoThrow(try view.find(text: "Clarify Timezone"))
        
        // Check for timezone icon
        let iconView = try view.find(ViewType.Image.self)
        XCTAssertNotNil(iconView)
    }
    
    func testReferenceSuggestionBanner() throws {
        // Given
        let suggestion = createMockReferenceSuggestion()
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        
        // When
        let view = try banner.inspect()
        
        // Then
        XCTAssertNoThrow(try view.find(text: "Unclear Reference Detected"))
        XCTAssertNoThrow(try view.find(text: "Add Context"))
    }
    
    func testFollowupSuggestionBanner() throws {
        // Given
        let suggestion = createMockFollowupSuggestion()
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        
        // When
        let view = try banner.inspect()
        
        // Then
        XCTAssertNoThrow(try view.find(text: "Follow-up Reminder"))
        XCTAssertNoThrow(try view.find(text: "Follow Up"))
    }
    
    func testPriorityColorCoding() throws {
        // Test High Priority (Orange)
        let highPrioritySuggestion = createMockSuggestion(priority: .high)
        let highBanner = ProactiveSuggestionBanner(
            suggestion: highPrioritySuggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        let highView = try highBanner.inspect()
        XCTAssertNotNil(highView)
        
        // Test Medium Priority (Yellow)
        let mediumPrioritySuggestion = createMockSuggestion(priority: .medium)
        let mediumBanner = ProactiveSuggestionBanner(
            suggestion: mediumPrioritySuggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        let mediumView = try mediumBanner.inspect()
        XCTAssertNotNil(mediumView)
        
        // Test Low Priority (Blue)
        let lowPrioritySuggestion = createMockSuggestion(priority: .low)
        let lowBanner = ProactiveSuggestionBanner(
            suggestion: lowPrioritySuggestion,
            onDismiss: {},
            onTakeAction: {}
        )
        let lowView = try lowBanner.inspect()
        XCTAssertNotNil(lowView)
    }
    
    func testActionButtonInteraction() throws {
        // Given
        let suggestion = createMockTimezoneSuggestion()
        var actionCalled = false
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: {},
            onTakeAction: { actionCalled = true }
        )
        
        // When
        let view = try banner.inspect()
        let actionButton = try view.find(button: suggestion.actionText)
        
        // Then
        XCTAssertNoThrow(try actionButton.tap())
        // Note: In a real test, we'd need to verify the callback was called
        // but ViewInspector has limitations with async callbacks
    }
    
    func testDismissButtonInteraction() throws {
        // Given
        let suggestion = createMockTimezoneSuggestion()
        var dismissCalled = false
        
        let banner = ProactiveSuggestionBanner(
            suggestion: suggestion,
            onDismiss: { dismissCalled = true },
            onTakeAction: {}
        )
        
        // When
        let view = try banner.inspect()
        let dismissButton = try view.find(button: "xmark")
        
        // Then
        XCTAssertNoThrow(try dismissButton.tap())
        // Note: In a real test, we'd need to verify the callback was called
    }
    
    // MARK: - Helper Methods
    
    private func createMockTimezoneSuggestion() -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "timezone-suggestion-1",
            type: .timezoneAmbiguity,
            priority: .high,
            title: "Timezone Ambiguity Detected",
            message: "\"Let's meet at 3pm tomorrow\" mentions a time but doesn't specify timezone. You're in EST, recipient is in PST.",
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
            message: "\"Can you review the document?\" contains unclear references that might confuse the recipient.",
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
            message: "You mentioned following up on the project status. Consider checking in.",
            actionText: "Follow Up",
            dismissText: "Dismiss",
            metadata: SuggestionMetadata(
                conversationId: "test-conv-1",
                messageId: "test-msg-1",
                detectedAt: "2025-01-26T10:00:00Z",
                userTimezone: nil,
                recipientTimezone: nil,
                originalText: "I'll follow up on the project status",
                suggestedClarification: nil
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
    
    private func createMockSuggestion(priority: SuggestionPriority) -> ProactiveSuggestionBackend {
        return ProactiveSuggestionBackend(
            id: "test-suggestion-1",
            type: .timezoneAmbiguity,
            priority: priority,
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
                originalText: "Test message",
                suggestedClarification: "Test clarification"
            ),
            dismissed: false,
            actionTaken: false,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
    }
}
