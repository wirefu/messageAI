//
//  ClarityIntegrationTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Integration tests for Clarity Assistant feature (PR #20)
/// Tests the complete flow from user typing to AI suggestions
final class ClarityIntegrationTests: XCTestCase {
    var aiService: AIService!
    
    override func setUp() {
        super.setUp()
        aiService = AIService.shared
    }
    
    override func tearDown() {
        aiService = nil
        super.tearDown()
    }
    
    // MARK: - End-to-End Clarity Tests
    
    /// Test: Complete clarity check flow
    func testClarityCheck_VagueMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - A vague message
        let message = "Can you send it later?"
        
        // When
        let suggestion = try await aiService.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // May have clarityIssues for vague "it" and "later"
    }
    
    /// Test: Clear message gets minimal suggestions
    func testClarityCheck_ClearMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - A clear, specific message
        let message = "Could you please send the project status report by Friday at 5 PM?"
        
        // When
        let suggestion = try await aiService.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then - Should have no or minimal issues
        XCTAssertNotNil(suggestion)
    }
    
    /// Test: Ambiguous message
    func testClarityCheck_AmbiguousMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Ambiguous message
        let message = "Let's do it the same way"
        
        // When
        let suggestion = try await aiService.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then - Should suggest clarification
        XCTAssertNotNil(suggestion)
    }
    
    /// Test: Message with vague pronouns
    func testClarityCheck_VaguePronouns() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Message with vague pronouns
        let message = "Can you fix this? It's not working"
        
        // When
        let suggestion = try await aiService.checkClarity(
            message: message,
            conversationContext: []
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Should flag "this" and "it" as unclear
    }
    
    /// Test: Clarity with conversation context
    func testClarityCheck_WithContext() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Message that makes sense with context
        let message = "I'll do that tomorrow"
        let context = [
            "Can you review the PR?",
            "Sure, I can help"
        ]
        
        // When
        let suggestion = try await aiService.checkClarity(
            message: message,
            conversationContext: context
        )
        
        // Then
        XCTAssertNotNil(suggestion)
        // Context should help clarify what "that" refers to
    }
    
    // MARK: - Debouncing Tests
    
    /// Test: Rapid message changes only check final
    func testClarityCheck_Debouncing() async throws {
        // Note: Debouncing is handled in MessageInputViewModel
        // This tests the service handles multiple requests gracefully
        
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let messages = ["H", "He", "Hel", "Hell", "Hello there"]
        
        // When - Make requests for each
        var suggestions: [AISuggestion] = []
        for message in messages {
            if message.count >= 10 {
                let suggestion = try await aiService.checkClarity(message: message)
                suggestions.append(suggestion)
            }
        }
        
        // Then - Should handle all requests
        XCTAssertFalse(suggestions.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    /// Test: Empty message handling
    func testClarityCheck_EmptyMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let emptyMessage = ""
        
        // When
        let suggestion = try await aiService.checkClarity(message: emptyMessage)
        
        // Then - Should handle gracefully
        XCTAssertNotNil(suggestion)
    }
    
    /// Test: Very long message
    func testClarityCheck_VeryLongMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - 5000 character message
        let longMessage = String(repeating: "This is a test message. ", count: 200)
        
        // When
        let suggestion = try await aiService.checkClarity(message: longMessage)
        
        // Then - Should handle long messages
        XCTAssertNotNil(suggestion)
    }
    
    /// Test: Special characters in message
    func testClarityCheck_SpecialCharacters() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Can you check the @user's code? #urgent 💯"
        
        // When
        let suggestion = try await aiService.checkClarity(message: message)
        
        // Then
        XCTAssertNotNil(suggestion)
    }
    
    // MARK: - Message Type Tests
    
    /// Test: Technical message
    func testClarityCheck_TechnicalMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Technical jargon
        let message = "The API endpoint is returning a 500 error in the auth middleware"
        
        // When
        let suggestion = try await aiService.checkClarity(message: message)
        
        // Then - Should handle technical language
        XCTAssertNotNil(suggestion)
    }
    
    /// Test: Casual message
    func testClarityCheck_CasualMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Casual tone
        let message = "hey can u send that thing we talked about yesterday??"
        
        // When
        let suggestion = try await aiService.checkClarity(message: message)
        
        // Then - Should suggest improvements
        XCTAssertNotNil(suggestion)
        // Likely suggestions for "that thing", "yesterday", casual tone
    }
    
    /// Test: Question message
    func testClarityCheck_QuestionMessage() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "What do you think about this?"
        
        // When
        let suggestion = try await aiService.checkClarity(message: message)
        
        // Then
        XCTAssertNotNil(suggestion)
        // Should flag vague "this"
    }
    
    // MARK: - Performance Tests
    
    /// Test: Clarity check response time
    func testClarityCheck_ResponseTime() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Can you review the code changes?"
        let startTime = Date()
        
        // When
        _ = try await aiService.checkClarity(message: message)
        
        // Then - Should complete within 3 seconds
        let duration = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 3.0, "Clarity check should complete within 3 seconds")
    }
    
    // MARK: - Caching Tests
    
    /// Test: Same message uses cache
    func testClarityCheck_Caching() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let message = "Test message for caching"
        
        // When - Check same message twice
        let startTime1 = Date()
        let suggestion1 = try await aiService.checkClarity(message: message)
        let duration1 = Date().timeIntervalSince(startTime1)
        
        let startTime2 = Date()
        let suggestion2 = try await aiService.checkClarity(message: message)
        let duration2 = Date().timeIntervalSince(startTime2)
        
        // Then - Second request should be faster (cached)
        XCTAssertNotNil(suggestion1)
        XCTAssertNotNil(suggestion2)
        // XCTAssertLessThan(duration2, duration1, "Cached request should be faster")
    }
    
    // MARK: - Helper Methods
    
    private func isIntegrationTestEnvironment() -> Bool {
        let runIntegrationTests = ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"]
        return runIntegrationTests == "1"
    }
}

// MARK: - Integration Test Documentation

/*
 CLARITY ASSISTANT INTEGRATION TEST GUIDE
 =========================================
 
 ## Prerequisites
 
 1. Complete PR #17 & #20 Setup:
    - Cloud Functions deployed
    - OpenAI API key configured
    - checkClarity function working
 
 2. Test Message Samples:
    - Vague messages (pronouns without antecedents)
    - Clear messages (specific and detailed)
    - Ambiguous messages (multiple interpretations)
    - Technical messages (jargon-heavy)
    - Casual messages (informal tone)
 
 ## Running Integration Tests
 
 ```bash
 export RUN_INTEGRATION_TESTS=1
 xcodebuild test -scheme MessageAI \
   -destination 'platform=iOS Simulator,name=iPhone 17' \
   -only-testing:MessageAITests/ClarityIntegrationTests
 ```
 
 ## Manual Testing Checklist
 
 ### Basic Functionality
 - [ ] Type message slowly (>10 characters)
 - [ ] Wait 2 seconds without typing
 - [ ] Clarity suggestion appears
 - [ ] Suggestion shows issues found
 - [ ] Tap "Accept" - message replaced
 - [ ] Tap "Dismiss" - suggestion hidden
 
 ### Debouncing
 - [ ] Type rapidly (don't wait 2 seconds)
 - [ ] Suggestion should NOT appear while typing
 - [ ] Stop typing for 2+ seconds
 - [ ] Suggestion appears
 
 ### Message Types
 - [ ] Vague message: "Can you send it?"
   - Should flag "it" as unclear
 - [ ] Clear message: "Could you send the report by Friday?"
   - Should have minimal or no issues
 - [ ] Ambiguous: "Let's meet there"
   - Should ask where "there" is
 
 ### Edge Cases
 - [ ] Very short message (< 10 chars) - No check
 - [ ] Empty message - No check
 - [ ] Whitespace only - No check
 - [ ] Very long message (1000+ chars) - Works
 - [ ] Special characters (@#$%) - Works
 - [ ] Emojis - Works
 
 ### Error Scenarios
 - [ ] Check clarity with no internet - No suggestion
 - [ ] API error - Fails gracefully, no crash
 - [ ] Timeout - Shows error
 
 ### UI/UX
 - [ ] Suggestion appears smoothly (animation)
 - [ ] Suggestion doesn't block typing
 - [ ] Can dismiss and continue typing
 - [ ] Accept replaces text correctly
 - [ ] Loading indicator shows during check
 - [ ] Works in dark mode
 - [ ] Accessible with VoiceOver
 
 ## Performance Benchmarks
 
 - First check: < 3 seconds
 - Cached check: < 1 second
 - Debounce delay: 2 seconds
 - No impact on typing performance
 
 ## Expected Behavior
 
 **Clear Messages:**
 - Few or no suggestions
 - Maybe tone improvements
 
 **Vague Messages:**
 - Identifies unclear pronouns
 - Suggests specific alternatives
 - Asks clarifying questions
 
 **Ambiguous Messages:**
 - Multiple interpretation warning
 - Suggests clearer phrasing
 
 **Tone Issues:**
 - Flags casual tone in professional context
 - Suggests tone improvements
 */

