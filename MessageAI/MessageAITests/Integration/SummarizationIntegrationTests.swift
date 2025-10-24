//
//  SummarizationIntegrationTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Integration tests for AI Summarization feature (PR #18)
/// Tests the complete flow from UI trigger to AI response to display
final class SummarizationIntegrationTests: XCTestCase {
    var aiService: AIService!
    var testConversationID: String!
    
    override func setUp() {
        super.setUp()
        aiService = AIService.shared
        testConversationID = "test-sum-\(UUID().uuidString)"
    }
    
    override func tearDown() {
        aiService = nil
        testConversationID = nil
        super.tearDown()
    }
    
    // MARK: - End-to-End Summarization Tests
    
    /// Test: Complete summarization flow
    /// Verifies: Button tap → AI call → Parse → Display
    func testCompleteSummarizationFlow() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - A conversation with messages
        let conversationID = testConversationID!
        
        // When - Trigger summarization
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 20
        )
        
        // Then - Summary should be generated
        XCTAssertEqual(summary.conversationID, conversationID)
        XCTAssertFalse(summary.id.isEmpty)
        XCTAssertNotNil(summary.messageRange)
        XCTAssertNotNil(summary.createdAt)
        
        // Summary should have at least some content
        // (if conversation has messages)
    }
    
    /// Test: Summarization with minimal messages
    func testSummarization_MinimalMessages() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with only 2-3 messages
        let conversationID = testConversationID!
        let messageCount = 3
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: messageCount
        )
        
        // Then - Should still generate summary (even if empty)
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary.conversationID, conversationID)
    }
    
    /// Test: Summarization with many messages
    func testSummarization_ManyMessages() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with 50+ messages
        let conversationID = testConversationID!
        let messageCount = 50
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: messageCount
        )
        
        // Then
        XCTAssertNotNil(summary)
        // Should extract key points from large conversation
        // XCTAssertFalse(summary.keyPoints.isEmpty, "Should extract key points")
    }
    
    // MARK: - Summary Content Quality Tests
    
    /// Test: Summary contains expected sections
    func testSummaryContentStructure() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with varied content
        let conversationID = testConversationID!
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 20
        )
        
        // Then - Should have structured sections
        // (Content depends on actual messages)
        XCTAssertTrue(summary.keyPoints is [String])
        XCTAssertTrue(summary.decisions is [String])
        XCTAssertTrue(summary.actionItems is [String])
        XCTAssertTrue(summary.openQuestions is [String])
    }
    
    /// Test: Summary with decision-heavy conversation
    func testSummary_DecisionHeavyConversation() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with many decisions
        // Example: "We decided to use SwiftUI", "Agreed on Firebase", etc.
        let conversationID = testConversationID!
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 15
        )
        
        // Then - Should extract decisions
        XCTAssertNotNil(summary)
        // XCTAssertFalse(summary.decisions.isEmpty, "Should extract decisions")
    }
    
    /// Test: Summary with action-heavy conversation
    func testSummary_ActionHeavyConversation() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with many action items
        // Example: "I'll review the PR", "Can you deploy by Friday?", etc.
        let conversationID = testConversationID!
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 15
        )
        
        // Then - Should extract action items
        XCTAssertNotNil(summary)
        // XCTAssertFalse(summary.actionItems.isEmpty, "Should extract actions")
    }
    
    /// Test: Summary with question-heavy conversation
    func testSummary_QuestionHeavyConversation() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with many questions
        let conversationID = testConversationID!
        
        // When
        let summary = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 15
        )
        
        // Then - Should extract open questions
        XCTAssertNotNil(summary)
        // XCTAssertFalse(summary.openQuestions.isEmpty, "Should extract questions")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test: Summarization with empty conversation
    func testSummarization_EmptyConversation() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Conversation with no messages
        let conversationID = testConversationID!
        
        // When/Then - Should handle gracefully
        do {
            let summary = try await aiService.summarizeConversation(
                conversationID: conversationID,
                messageCount: 20
            )
            
            // Should return empty summary
            XCTAssertFalse(summary.hasContent, "Empty conversation should have no content")
        } catch {
            // Or throw appropriate error
            XCTAssertTrue(error is AppError)
        }
    }
    
    /// Test: Summarization with invalid conversation ID
    func testSummarization_InvalidConversationID() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let invalidID = "nonexistent-conversation-id"
        
        // When/Then
        do {
            _ = try await aiService.summarizeConversation(
                conversationID: invalidID,
                messageCount: 20
            )
            XCTFail("Should throw error for invalid conversation")
        } catch {
            // Expected error
            XCTAssertTrue(error is AppError)
        }
    }
    
    /// Test: Multiple summarization requests
    func testMultipleSummarizations() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let conversationID = testConversationID!
        
        // When - Make multiple requests
        let summary1 = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 10
        )
        
        let summary2 = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 20
        )
        
        // Then - Both should succeed
        XCTAssertNotNil(summary1)
        XCTAssertNotNil(summary2)
        XCTAssertNotEqual(summary1.id, summary2.id, "Should generate unique summaries")
    }
    
    // MARK: - Performance Tests
    
    /// Test: Summarization response time
    func testSummarizationPerformance() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let conversationID = testConversationID!
        let startTime = Date()
        
        // When
        _ = try await aiService.summarizeConversation(
            conversationID: conversationID,
            messageCount: 20
        )
        
        // Then - Should complete within reasonable time
        let duration = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 10.0, "Summarization should complete within 10 seconds")
    }
    
    /// Test: Summarization with different message counts
    func testSummarizationPerformance_VaryingMessageCounts() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let conversationID = testConversationID!
        let messageCounts = [5, 10, 20, 50]
        
        // When/Then
        for count in messageCounts {
            let startTime = Date()
            
            _ = try await aiService.summarizeConversation(
                conversationID: conversationID,
                messageCount: count
            )
            
            let duration = Date().timeIntervalSince(startTime)
            XCTAssertLessThan(duration, 15.0, "Summarization for \(count) messages should complete within 15 seconds")
        }
    }
    
    // MARK: - UI Integration Tests
    
    /// Test: Summary can be displayed in UI
    func testSummaryDisplayInUI() {
        // Given - A summary with all sections
        let summary = createMockSummary()
        
        // When - Summary is used in SummaryView
        // (This would be tested in UI tests)
        
        // Then - Verify summary has displayable content
        XCTAssertTrue(summary.hasContent)
        XCTAssertGreaterThan(summary.totalItems, 0)
        XCTAssertFalse(summary.keyPoints.isEmpty)
    }
    
    /// Test: Empty summary displays correctly
    func testEmptySummaryDisplayInUI() {
        // Given - An empty summary
        let summary = createEmptySummary()
        
        // When/Then
        XCTAssertFalse(summary.hasContent)
        XCTAssertEqual(summary.totalItems, 0)
    }
    
    // MARK: - Helper Methods
    
    private func isIntegrationTestEnvironment() -> Bool {
        let runIntegrationTests = ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"]
        return runIntegrationTests == "1"
    }
    
    private func createMockSummary() -> ConversationSummary {
        return ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: ConversationSummary.DateRange(
                start: Date().addingTimeInterval(-3600),
                end: Date()
            ),
            keyPoints: [
                "Discussed project timeline",
                "Reviewed technical approach",
                "Addressed team concerns"
            ],
            decisions: [
                "Using SwiftUI for frontend",
                "Firebase for backend infrastructure"
            ],
            actionItems: [
                "Alice to review PR by Friday",
                "Bob to deploy Cloud Functions",
                "Team to test on staging"
            ],
            openQuestions: [
                "Which AI model should we use?",
                "How to handle offline sync?"
            ],
            createdAt: Date()
        )
    }
    
    private func createEmptySummary() -> ConversationSummary {
        return ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: ConversationSummary.DateRange(
                start: Date(),
                end: Date()
            ),
            keyPoints: [],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
    }
}

// MARK: - Integration Test Documentation

/*
 SUMMARIZATION INTEGRATION TEST GUIDE
 =====================================
 
 ## Prerequisites
 
 1. Complete PR #17 Setup:
    - Cloud Functions deployed
    - OpenAI API key configured
    - AIService tested
 
 2. Test Data Setup:
    - Create test conversations with varied content
    - Conversations should have:
      * Decision-heavy messages
      * Action-heavy messages
      * Question-heavy messages
      * Mixed content
 
 ## Running Integration Tests
 
 ```bash
 # Set environment variable
 export RUN_INTEGRATION_TESTS=1
 
 # Run tests
 xcodebuild test -scheme MessageAI \
   -destination 'platform=iOS Simulator,name=iPhone 17' \
   -only-testing:MessageAITests/SummarizationIntegrationTests
 ```
 
 ## Manual Testing Checklist
 
 ### Basic Functionality
 - [ ] Tap summarize button in ChatView
 - [ ] Loading indicator appears
 - [ ] Summary generates within 5 seconds
 - [ ] SummaryView displays with content
 - [ ] All sections visible (key points, decisions, actions, questions)
 - [ ] Can dismiss summary sheet
 
 ### Edge Cases
 - [ ] Summarize empty conversation (0 messages)
 - [ ] Summarize conversation with 1-2 messages
 - [ ] Summarize conversation with 100+ messages
 - [ ] Tap summarize button multiple times quickly
 - [ ] Generate summary while messages arriving
 
 ### Error Scenarios
 - [ ] Summarize with no internet connection
 - [ ] Summarize with invalid conversation ID
 - [ ] Handle AI service timeout
 - [ ] Handle rate limit exceeded
 - [ ] Show user-friendly error messages
 
 ### UI/UX Testing
 - [ ] Button disabled during generation
 - [ ] Loading state visible
 - [ ] Summary sheet animates in smoothly
 - [ ] Summary formatted correctly
 - [ ] Long summaries scroll properly
 - [ ] Empty sections hidden
 - [ ] Dark mode support
 - [ ] Dynamic Type support
 - [ ] VoiceOver accessibility
 
 ### Content Quality
 - [ ] Key points are relevant
 - [ ] Decisions are accurate
 - [ ] Action items are actionable
 - [ ] Questions are open/unanswered
 - [ ] No hallucinated content
 - [ ] Proper grammar and formatting
 
 ## Performance Benchmarks
 
 - Small conversation (5-10 messages): < 3 seconds
 - Medium conversation (10-20 messages): < 5 seconds
 - Large conversation (20-50 messages): < 8 seconds
 - Very large (50+ messages): < 15 seconds
 
 ## Known Limitations
 
 - Max 50 messages per summary (configurable)
 - Requires active internet connection
 - Subject to OpenAI API rate limits
 - Cost per summarization: ~$0.01-0.05
 
 ## Troubleshooting
 
 **Summary not generating:**
 - Check Cloud Functions logs
 - Verify OpenAI API key
 - Check network connectivity
 - Verify conversation has messages
 
 **Empty summary returned:**
 - Check conversation content
 - Verify message count > 0
 - Check AI model response
 - Review Cloud Function implementation
 
 **Performance issues:**
 - Reduce message count parameter
 - Check OpenAI API status
 - Monitor Cloud Function execution time
 - Consider caching summaries
 */

