//
//  SummaryAutoTriggerServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Tests for SummaryAutoTriggerService
final class SummaryAutoTriggerServiceTests: XCTestCase {
    var sut: SummaryAutoTriggerService!
    var conversationID: String!
    
    override func setUp() {
        super.setUp()
        sut = SummaryAutoTriggerService.shared
        conversationID = "test-conv-\(UUID().uuidString)"
        
        // Clear any existing state
        sut.resetAutoTriggerPrompt(conversationID: conversationID)
    }
    
    override func tearDown() {
        sut.resetAutoTriggerPrompt(conversationID: conversationID)
        sut = nil
        conversationID = nil
        super.tearDown()
    }
    
    // MARK: - Auto-Trigger Condition Tests
    
    func testShouldAutoTrigger_BothConditionsMet() {
        // Given - 15+ unread messages AND 6+ hours offline
        let unreadCount = 20
        let lastOnline = Date().addingTimeInterval(-7 * 3600) // 7 hours ago
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger with 20 unread and 7 hours offline")
    }
    
    func testShouldAutoTrigger_NotEnoughUnreadMessages() {
        // Given - Only 10 unread messages, but 6+ hours offline
        let unreadCount = 10
        let lastOnline = Date().addingTimeInterval(-7 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger with only 10 unread messages")
    }
    
    func testShouldAutoTrigger_NotOfflineLongEnough() {
        // Given - 15+ unread messages, but only 3 hours offline
        let unreadCount = 20
        let lastOnline = Date().addingTimeInterval(-3 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger with only 3 hours offline")
    }
    
    func testShouldAutoTrigger_ExactThresholds() {
        // Given - Exactly 15 unread and exactly 6 hours offline
        let unreadCount = 15
        let lastOnline = Date().addingTimeInterval(-6 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger at exact thresholds")
    }
    
    func testShouldAutoTrigger_JustBelowThresholds() {
        // Given - 14 unread (just below) and 5.9 hours offline (just below)
        let unreadCount = 14
        let lastOnline = Date().addingTimeInterval(-5.9 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger just below thresholds")
    }
    
    func testShouldAutoTrigger_WellAboveThresholds() {
        // Given - 100 unread messages and 24 hours offline
        let unreadCount = 100
        let lastOnline = Date().addingTimeInterval(-24 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger well above thresholds")
    }
    
    func testShouldAutoTrigger_ZeroUnreadMessages() {
        // Given - 0 unread messages but 10 hours offline
        let unreadCount = 0
        let lastOnline = Date().addingTimeInterval(-10 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger with 0 unread messages")
    }
    
    func testShouldAutoTrigger_JustCameOnline() {
        // Given - 20 unread messages but just came online
        let unreadCount = 20
        let lastOnline = Date() // Now
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger if just came online")
    }
    
    // MARK: - Prompt State Management Tests
    
    func testHasShownPrompt_InitiallyFalse() {
        // When
        let hasShown = sut.hasShownAutoTriggerPrompt(conversationID: conversationID)
        
        // Then
        XCTAssertFalse(hasShown, "Initially should not have shown prompt")
    }
    
    func testMarkPromptShown_SetsFlag() {
        // When
        sut.markAutoTriggerPromptShown(conversationID: conversationID)
        
        // Then
        let hasShown = sut.hasShownAutoTriggerPrompt(conversationID: conversationID)
        XCTAssertTrue(hasShown, "Should mark prompt as shown")
    }
    
    func testResetPrompt_ClearsFlag() {
        // Given
        sut.markAutoTriggerPromptShown(conversationID: conversationID)
        XCTAssertTrue(sut.hasShownAutoTriggerPrompt(conversationID: conversationID))
        
        // When
        sut.resetAutoTriggerPrompt(conversationID: conversationID)
        
        // Then
        let hasShown = sut.hasShownAutoTriggerPrompt(conversationID: conversationID)
        XCTAssertFalse(hasShown, "Should reset prompt state")
    }
    
    func testPromptState_DifferentConversations() {
        // Given - Two different conversations
        let conversationID1 = "conv-1"
        let conversationID2 = "conv-2"
        
        // When - Mark prompt shown for conversation 1 only
        sut.markAutoTriggerPromptShown(conversationID: conversationID1)
        
        // Then
        XCTAssertTrue(sut.hasShownAutoTriggerPrompt(conversationID: conversationID1))
        XCTAssertFalse(sut.hasShownAutoTriggerPrompt(conversationID: conversationID2))
        
        // Cleanup
        sut.resetAutoTriggerPrompt(conversationID: conversationID1)
    }
    
    // MARK: - Message Count Recommendation Tests
    
    func testRecommendedMessageCount_SmallConversation() {
        // Given - 10 total messages
        let totalMessages = 10
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 10, "Should include all messages for small conversation")
    }
    
    func testRecommendedMessageCount_MediumConversation() {
        // Given - 30 total messages
        let totalMessages = 30
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 30, "Should include 30 messages for medium conversation")
    }
    
    func testRecommendedMessageCount_LargeConversation() {
        // Given - 100 total messages
        let totalMessages = 100
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 50, "Should cap at 50 messages for large conversation")
    }
    
    func testRecommendedMessageCount_AtThreshold() {
        // Given - Exactly 20 messages
        let totalMessages = 20
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 20, "Should include all 20 messages at threshold")
    }
    
    func testRecommendedMessageCount_AtUpperThreshold() {
        // Given - Exactly 50 messages
        let totalMessages = 50
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 30, "Should include 30 messages at upper threshold")
    }
    
    func testRecommendedMessageCount_JustAboveUpperThreshold() {
        // Given - 51 messages
        let totalMessages = 51
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 50, "Should cap at 50 messages")
    }
    
    // MARK: - Edge Case Tests
    
    func testShouldAutoTrigger_NegativeTime() {
        // Given - Future timestamp (edge case / clock skew)
        let unreadCount = 20
        let lastOnline = Date().addingTimeInterval(3600) // 1 hour in future
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger with future timestamp")
    }
    
    func testShouldAutoTrigger_VeryLargeUnreadCount() {
        // Given - Extreme unread count
        let unreadCount = 1000
        let lastOnline = Date().addingTimeInterval(-10 * 3600)
        
        // When
        let shouldTrigger = sut.shouldAutoTriggerSummary(
            unreadMessageCount: unreadCount,
            lastOnlineTimestamp: lastOnline,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger with very large unread count")
    }
    
    func testRecommendedMessageCount_ZeroMessages() {
        // Given - 0 messages
        let totalMessages = 0
        
        // When
        let recommended = sut.getRecommendedMessageCount(totalMessages: totalMessages)
        
        // Then
        XCTAssertEqual(recommended, 0, "Should return 0 for empty conversation")
    }
}


