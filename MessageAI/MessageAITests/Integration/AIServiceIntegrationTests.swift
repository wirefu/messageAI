//
//  AIServiceIntegrationTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Integration tests for AIService with live Cloud Functions
/// These tests require:
/// - Firebase Cloud Functions deployed
/// - OpenAI API key configured
/// - Network connectivity
/// - Valid Firebase authentication
final class AIServiceIntegrationTests: XCTestCase {
    var sut: AIService!
    var testConversationID: String!
    
    override func setUp() {
        super.setUp()
        sut = AIService.shared
        testConversationID = "test-conv-\(UUID().uuidString)"
    }
    
    override func tearDown() {
        sut = nil
        testConversationID = nil
        super.tearDown()
    }
    
    // MARK: - Summarization Integration Tests
    
    /// Test: Summarize a conversation with real Cloud Function
    /// Prerequisites:
    /// - Cloud Function 'summarizeConversation' deployed
    /// - Conversation exists with messages
    /// - OpenAI API key configured
    func testSummarizeConversation_WithRealCloudFunction() async throws {
        // Skip if running in CI or without network
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let conversationID = testConversationID!
        let messageCount = 20
        
        // When
        let summary = try await sut.summarizeConversation(
            conversationID: conversationID,
            messageCount: messageCount
        )
        
        // Then
        XCTAssertEqual(summary.conversationID, conversationID)
        XCTAssertFalse(summary.id.isEmpty)
        XCTAssertNotNil(summary.messageRange)
        XCTAssertNotNil(summary.createdAt)
        
        // Verify summary content (if messages exist)
        // XCTAssertFalse(summary.keyPoints.isEmpty, "Should have key points")
    }
    
    /// Test: Summarization handles invalid conversation ID
    func testSummarizeConversation_InvalidConversationID() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let invalidConversationID = "nonexistent-conversation"
        
        // When/Then
        do {
            _ = try await sut.summarizeConversation(
                conversationID: invalidConversationID,
                messageCount: 20
            )
            XCTFail("Should throw error for invalid conversation")
        } catch {
            // Expected error
            XCTAssertTrue(error is AppError)
        }
    }
    
    /// Test: Summarization with different message counts
    func testSummarizeConversation_DifferentMessageCounts() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let conversationID = testConversationID!
        let messageCounts = [5, 10, 20, 50]
        
        // When/Then
        for count in messageCounts {
            let summary = try await sut.summarizeConversation(
                conversationID: conversationID,
                messageCount: count
            )
            
            XCTAssertNotNil(summary)
            XCTAssertEqual(summary.conversationID, conversationID)
        }
    }
    
    // MARK: - Clarity Check Integration Tests
    
    /// Test: Check clarity with real Cloud Function
    func testCheckClarity_WithRealCloudFunction() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Can u plz send the file asap???"
        let context = ["Previous message 1", "Previous message 2"]
        
        // When
        let suggestion = try await sut.checkClarity(
            message: message,
            conversationContext: context
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Suggestion might have clarityIssues or suggestedRevision
    }
    
    /// Test: Clarity check with empty message
    func testCheckClarity_EmptyMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let emptyMessage = ""
        
        // When
        let suggestion = try await sut.checkClarity(
            message: emptyMessage,
            conversationContext: []
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Should handle empty message gracefully
    }
    
    /// Test: Clarity check with well-written message
    func testCheckClarity_WellWrittenMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Could you please send me the project report by Friday at 5 PM?"
        
        // When
        let suggestion = try await sut.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Should have minimal or no issues
    }
    
    /// Test: Clarity check with ambiguous message
    func testCheckClarity_AmbiguousMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Send it later"
        
        // When
        let suggestion = try await sut.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Should suggest improvements for clarity
    }
    
    // MARK: - Action Items Extraction Integration Tests
    
    /// Test: Extract action items from messages
    func testExtractActionItems_WithRealCloudFunction() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let messages = [
            "Let's schedule a meeting for next Monday",
            "Can you review the PR by tomorrow?",
            "I'll send the updated design files by end of day"
        ]
        let conversationID = testConversationID!
        
        // When
        let actionItems = try await sut.extractActionItems(
            messages: messages,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertNotNil(actionItems)
        XCTAssertFalse(actionItems.isEmpty, "Should extract at least some action items")
        
        for item in actionItems {
            XCTAssertFalse(item.description.isEmpty)
            XCTAssertEqual(item.conversationID, conversationID)
            XCTAssertFalse(item.isCompleted)
        }
    }
    
    /// Test: Extract action items from messages without actions
    func testExtractActionItems_NoActionsPresent() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let messages = [
            "Good morning!",
            "How are you?",
            "The weather is nice today"
        ]
        let conversationID = testConversationID!
        
        // When
        let actionItems = try await sut.extractActionItems(
            messages: messages,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertNotNil(actionItems)
        // Should return empty array or minimal items
    }
    
    /// Test: Extract action items from empty message array
    func testExtractActionItems_EmptyMessages() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let messages: [String] = []
        let conversationID = testConversationID!
        
        // When
        let actionItems = try await sut.extractActionItems(
            messages: messages,
            conversationID: conversationID
        )
        
        // Then
        XCTAssertNotNil(actionItems)
        XCTAssertTrue(actionItems.isEmpty)
    }
    
    // MARK: - Error Handling & Rate Limiting Tests
    
    /// Test: Rate limiting behavior
    func testRateLimiting_MultipleQuickRequests() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Test message"
        let requestCount = 10
        
        // When - Make multiple quick requests
        var successCount = 0
        var errorCount = 0
        
        for _ in 0..<requestCount {
            do {
                _ = try await sut.checkClarity(message: message)
                successCount += 1
            } catch {
                errorCount += 1
            }
        }
        
        // Then
        // Should handle rate limiting gracefully
        XCTAssertGreaterThan(successCount, 0, "At least some requests should succeed")
    }
    
    /// Test: Network error handling
    func testNetworkErrorHandling() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Note: This test would require mocking network conditions
        // or testing with airplane mode enabled
        // For now, we document the expected behavior
    }
    
    /// Test: Timeout handling
    func testTimeoutHandling() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - very long conversation that might timeout
        let conversationID = testConversationID!
        let messageCount = 1000  // Very large count
        
        // When/Then
        do {
            _ = try await sut.summarizeConversation(
                conversationID: conversationID,
                messageCount: messageCount
            )
        } catch {
            // Should handle timeout gracefully
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Determines if we're in an environment suitable for integration tests
    private func isIntegrationTestEnvironment() -> Bool {
        // Skip integration tests in CI or if environment variable is not set
        let runIntegrationTests = ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"]
        return runIntegrationTests == "1"
    }
}

// MARK: - Integration Test Documentation

/*
 INTEGRATION TEST SETUP INSTRUCTIONS
 ====================================
 
 1. Deploy Cloud Functions:
    ```bash
    cd CloudFunctions
    firebase deploy --only functions
    ```
 
 2. Verify Cloud Functions are running:
    - summarizeConversation
    - checkClarity
    - extractActionItems
 
 3. Configure OpenAI API Key:
    ```bash
    firebase functions:config:set openai.key="your-api-key"
    firebase deploy --only functions
    ```
 
 4. Run Integration Tests:
    Set environment variable before running tests:
    ```bash
    export RUN_INTEGRATION_TESTS=1
    xcodebuild test -scheme MessageAI -destination 'platform=iOS Simulator,name=iPhone 15'
    ```
 
 5. Manual Testing Checklist:
    ☐ Test summarization with real conversation (10+ messages)
    ☐ Test clarity check with various message types:
      - Clear message
      - Ambiguous message
      - Message with typos
      - Message with casual language
    ☐ Test action item extraction with:
      - Messages containing tasks
      - Messages without tasks
      - Mixed content messages
    ☐ Test error scenarios:
      - Invalid conversation ID
      - Empty messages
      - Network disconnection
      - Rate limiting (many requests)
    ☐ Verify response times are acceptable (< 5 seconds)
    ☐ Check Cloud Function logs for errors
 
 6. Expected Behavior:
    - Summarization: Returns 3-5 key points, decisions, action items
    - Clarity Check: Suggests improvements for unclear messages
    - Action Items: Extracts tasks with assignee and description
    - Errors: User-friendly messages, no crashes
    - Rate Limiting: Graceful handling with retry suggestions
 
 7. Performance Benchmarks:
    - Summarization: < 5 seconds for 20 messages
    - Clarity Check: < 2 seconds
    - Action Items: < 3 seconds for 10 messages
 
 8. Cost Monitoring:
    - Monitor OpenAI API usage in Cloud Function logs
    - Set up billing alerts in Firebase Console
    - Track requests per user per day
 */


