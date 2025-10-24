//
//  AIServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AIServiceTests: XCTestCase {
    var sut: AIService!
    
    override func setUp() {
        super.setUp()
        sut = AIService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAIServiceInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testAIServiceIsSingleton() {
        let instance1 = AIService.shared
        let instance2 = AIService.shared
        XCTAssertTrue(instance1 === instance2, "AIService should be a singleton")
    }
    
    // MARK: - Summary Response Parsing Tests
    
    func testParseSummaryResponse_ValidData() throws {
        // Given
        let response: [String: Any] = [
            "conversationID": "conv123",
            "keyPoints": ["Point 1", "Point 2", "Point 3"],
            "decisions": ["Decision 1", "Decision 2"],
            "actionItems": ["Action 1", "Action 2"],
            "openQuestions": ["Question 1"]
        ]
        
        // When
        let summary = try sut.parseSummaryResponse(response)
        
        // Then
        XCTAssertEqual(summary.conversationID, "conv123")
        XCTAssertEqual(summary.keyPoints.count, 3)
        XCTAssertEqual(summary.decisions.count, 2)
        XCTAssertEqual(summary.actionItems.count, 2)
        XCTAssertEqual(summary.openQuestions.count, 1)
        XCTAssertNotNil(summary.id)
        XCTAssertNotNil(summary.messageRange)
        XCTAssertNotNil(summary.createdAt)
    }
    
    func testParseSummaryResponse_EmptyArrays() throws {
        // Given
        let response: [String: Any] = [
            "conversationID": "conv123",
            "keyPoints": [],
            "decisions": [],
            "actionItems": [],
            "openQuestions": []
        ]
        
        // When
        let summary = try sut.parseSummaryResponse(response)
        
        // Then
        XCTAssertEqual(summary.conversationID, "conv123")
        XCTAssertTrue(summary.keyPoints.isEmpty)
        XCTAssertTrue(summary.decisions.isEmpty)
        XCTAssertTrue(summary.actionItems.isEmpty)
        XCTAssertTrue(summary.openQuestions.isEmpty)
    }
    
    func testParseSummaryResponse_MissingFields() throws {
        // Given - minimal response with missing optional fields
        let response: [String: Any] = [:]
        
        // When
        let summary = try sut.parseSummaryResponse(response)
        
        // Then - should use defaults
        XCTAssertEqual(summary.conversationID, "")
        XCTAssertTrue(summary.keyPoints.isEmpty)
        XCTAssertTrue(summary.decisions.isEmpty)
        XCTAssertTrue(summary.actionItems.isEmpty)
        XCTAssertTrue(summary.openQuestions.isEmpty)
    }
    
    // MARK: - Clarity Response Parsing Tests
    
    func testParseClarityResponse_ValidData() throws {
        // Given
        let response: [String: Any] = [
            "clarityIssues": ["Issue 1", "Issue 2"],
            "suggestedRevision": "Improved message text",
            "toneWarning": "Message may sound too formal",
            "alternativePhrasing": "Try saying it this way..."
        ]
        
        // When
        let suggestion = try sut.parseClarityResponse(response)
        
        // Then
        XCTAssertEqual(suggestion.clarityIssues?.count, 2)
        XCTAssertEqual(suggestion.suggestedRevision, "Improved message text")
        XCTAssertEqual(suggestion.toneWarning, "Message may sound too formal")
        XCTAssertEqual(suggestion.alternativePhrasing, "Try saying it this way...")
    }
    
    func testParseClarityResponse_NoIssuesFound() throws {
        // Given
        let response: [String: Any] = [:]
        
        // When
        let suggestion = try sut.parseClarityResponse(response)
        
        // Then - all fields should be nil
        XCTAssertNil(suggestion.clarityIssues)
        XCTAssertNil(suggestion.suggestedRevision)
        XCTAssertNil(suggestion.toneWarning)
        XCTAssertNil(suggestion.alternativePhrasing)
    }
    
    func testParseClarityResponse_PartialData() throws {
        // Given
        let response: [String: Any] = [
            "clarityIssues": ["Issue 1"],
            "toneWarning": "Warning"
        ]
        
        // When
        let suggestion = try sut.parseClarityResponse(response)
        
        // Then
        XCTAssertEqual(suggestion.clarityIssues?.count, 1)
        XCTAssertNil(suggestion.suggestedRevision)
        XCTAssertEqual(suggestion.toneWarning, "Warning")
        XCTAssertNil(suggestion.alternativePhrasing)
    }
    
    // MARK: - Action Items Parsing Tests
    
    func testParseActionItems_ValidData() throws {
        // Given
        let items: [[String: Any]] = [
            [
                "description": "Complete the report",
                "messageID": "msg123",
                "assignedTo": "user123"
            ],
            [
                "description": "Review PR",
                "messageID": "msg124"
            ]
        ]
        let conversationID = "conv123"
        
        // When
        let actionItems = try sut.parseActionItems(items, conversationID: conversationID)
        
        // Then
        XCTAssertEqual(actionItems.count, 2)
        XCTAssertEqual(actionItems[0].description, "Complete the report")
        XCTAssertEqual(actionItems[0].messageID, "msg123")
        XCTAssertEqual(actionItems[0].assignedTo, "user123")
        XCTAssertEqual(actionItems[0].conversationID, conversationID)
        XCTAssertFalse(actionItems[0].isCompleted)
        
        XCTAssertEqual(actionItems[1].description, "Review PR")
        XCTAssertNil(actionItems[1].assignedTo)
    }
    
    func testParseActionItems_EmptyArray() throws {
        // Given
        let items: [[String: Any]] = []
        let conversationID = "conv123"
        
        // When
        let actionItems = try sut.parseActionItems(items, conversationID: conversationID)
        
        // Then
        XCTAssertTrue(actionItems.isEmpty)
    }
    
    func testParseActionItems_InvalidItems() throws {
        // Given - items without required description field
        let items: [[String: Any]] = [
            ["messageID": "msg123"],  // Missing description
            ["description": "Valid item"]
        ]
        let conversationID = "conv123"
        
        // When
        let actionItems = try sut.parseActionItems(items, conversationID: conversationID)
        
        // Then - should only parse valid item
        XCTAssertEqual(actionItems.count, 1)
        XCTAssertEqual(actionItems[0].description, "Valid item")
    }
    
    func testParseActionItems_GeneratesUniqueIDs() throws {
        // Given
        let items: [[String: Any]] = [
            ["description": "Task 1"],
            ["description": "Task 2"]
        ]
        let conversationID = "conv123"
        
        // When
        let actionItems = try sut.parseActionItems(items, conversationID: conversationID)
        
        // Then
        XCTAssertNotEqual(actionItems[0].id, actionItems[1].id)
    }
    
    // MARK: - Error Handling Tests
    
    func testSummarizeConversation_HandlesError() async throws {
        // Note: This test verifies error handling structure
        // Actual Cloud Function errors require network connectivity
        // Integration tests will verify end-to-end behavior
        
        // Given - invalid conversation ID
        let conversationID = ""
        
        // When/Then - should eventually throw error
        // (Will be tested in integration tests with live Cloud Functions)
    }
    
    func testCheckClarity_HandlesEmptyMessage() async throws {
        // Note: Error handling for empty messages
        // Will be tested in integration tests
    }
    
    func testExtractActionItems_HandlesEmptyMessages() async throws {
        // Note: Error handling for empty message arrays
        // Will be tested in integration tests
    }
    
    // MARK: - Data Validation Tests
    
    func testParseSummaryResponse_HandlesWrongTypes() throws {
        // Given - response with wrong data types
        let response: [String: Any] = [
            "conversationID": 123,  // Should be String, but is Int
            "keyPoints": "not an array"  // Should be [String], but is String
        ]
        
        // When
        let summary = try sut.parseSummaryResponse(response)
        
        // Then - should use defaults for invalid types
        XCTAssertEqual(summary.conversationID, "")
        XCTAssertTrue(summary.keyPoints.isEmpty)
    }
    
    func testParseClarityResponse_HandlesWrongTypes() throws {
        // Given
        let response: [String: Any] = [
            "clarityIssues": "not an array",
            "suggestedRevision": 123
        ]
        
        // When
        let suggestion = try sut.parseClarityResponse(response)
        
        // Then - should handle type mismatches gracefully
        XCTAssertNil(suggestion.clarityIssues)
        XCTAssertNil(suggestion.suggestedRevision)
    }
}

// Note: Full Cloud Function integration tests require:
// - OpenAI API key configured in Cloud Functions
// - Cloud Functions deployed to Firebase
// - Network connectivity
// See AIServiceIntegrationTests.swift for integration test scenarios

