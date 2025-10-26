//
//  MessageInputViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Tests for MessageInputViewModel
@MainActor
final class MessageInputViewModelTests: XCTestCase {
    var sut: MessageInputViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = MessageInputViewModel()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(sut.messageText, "")
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.isCheckingClarity)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    // MARK: - Message Text Tests
    
    func testMessageText_ShortMessage() {
        // Given
        let shortMessage = "Hi"
        
        // When
        sut.messageText = shortMessage
        
        // Then - Should not trigger clarity check (too short)
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    func testMessageText_MinimumLengthForCheck() {
        // Given
        let message = "1234567890" // Exactly 10 characters
        
        // When
        sut.messageText = message
        
        // Then - Should be long enough for check
        // (Actual check happens async with debounce)
    }
    
    // MARK: - Accept Suggestion Tests
    
    func testAcceptSuggestion_ReplacesMessageText() {
        // Given
        sut.messageText = "Original message"
        sut.claritySuggestion = AISuggestion(
            clarityIssues: ["Issue"],
            suggestedRevision: "Improved message",
            toneWarning: nil,
            alternativePhrasing: nil
        )
        sut.showClaritySuggestion = true
        
        // When
        sut.acceptSuggestion()
        
        // Then
        XCTAssertEqual(sut.messageText, "Improved message")
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    func testAcceptSuggestion_NoSuggestion() {
        // Given
        sut.messageText = "Original message"
        sut.claritySuggestion = nil
        
        // When
        sut.acceptSuggestion()
        
        // Then - Message should not change
        XCTAssertEqual(sut.messageText, "Original message")
    }
    
    func testAcceptSuggestion_NoRevision() {
        // Given
        sut.messageText = "Original message"
        sut.claritySuggestion = AISuggestion(
            clarityIssues: ["Issue"],
            suggestedRevision: nil, // No revision provided
            toneWarning: nil,
            alternativePhrasing: nil
        )
        
        // When
        sut.acceptSuggestion()
        
        // Then - Message should not change
        XCTAssertEqual(sut.messageText, "Original message")
    }
    
    // MARK: - Dismiss Suggestion Tests
    
    func testDismissSuggestion_ClearsSuggestion() {
        // Given
        sut.claritySuggestion = AISuggestion(
            clarityIssues: ["Issue"],
            suggestedRevision: "Revision",
            toneWarning: nil,
            alternativePhrasing: nil
        )
        sut.showClaritySuggestion = true
        
        // When
        sut.dismissSuggestion()
        
        // Then
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    // MARK: - Clear Message Tests
    
    func testClearMessage_ResetsAllState() {
        // Given
        sut.messageText = "Test message"
        sut.claritySuggestion = AISuggestion(
            clarityIssues: ["Issue"],
            suggestedRevision: "Revision",
            toneWarning: nil,
            alternativePhrasing: nil
        )
        sut.showClaritySuggestion = true
        
        // When
        sut.clearMessage()
        
        // Then
        XCTAssertEqual(sut.messageText, "")
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    // MARK: - Trigger Clarity Check Tests
    
    func testTriggerClarityCheck_ManualTrigger() async {
        // Given
        sut.messageText = "Test message for clarity check"
        
        // When
        await sut.triggerClarityCheck()
        
        // Then
        // (Requires network/Cloud Functions to actually return suggestion)
        // Integration tests will verify actual behavior
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyMessage_NoCheck() {
        // Given
        sut.messageText = ""
        
        // Then - Should not have any suggestion
        XCTAssertNil(sut.claritySuggestion)
        XCTAssertFalse(sut.showClaritySuggestion)
    }
    
    func testWhitespaceMessage_NoCheck() {
        // Given
        sut.messageText = "   "
        
        // Then - Should not trigger for whitespace
        XCTAssertNil(sut.claritySuggestion)
    }
    
    func testVeryLongMessage_HandlesGracefully() {
        // Given
        let longMessage = String(repeating: "A", count: 10000)
        
        // When
        sut.messageText = longMessage
        
        // Then - Should not crash
        XCTAssertEqual(sut.messageText.count, 10000)
    }
    
    func testRapidMessageChanges_Debounces() async {
        // Given
        let messages = ["H", "He", "Hel", "Hell", "Hello"]
        
        // When - Type rapidly
        for message in messages {
            sut.messageText = message
        }
        
        // Then - Should only check final message after debounce
        // (Tested in integration tests with timing)
    }
}

