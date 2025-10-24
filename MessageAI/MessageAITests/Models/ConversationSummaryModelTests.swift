//
//  ConversationSummaryModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class ConversationSummaryModelTests: XCTestCase {
    func testConversationSummaryEncoding() throws {
        let dateRange = ConversationSummary.DateRange(
            start: Date().addingTimeInterval(-3600),
            end: Date()
        )

        let summary = ConversationSummary(
            id: "summary123",
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["Point 1", "Point 2"],
            decisions: ["Decision 1"],
            actionItems: ["Action 1", "Action 2"],
            openQuestions: ["Question 1"],
            createdAt: Date()
        )

        let encoded = try JSONEncoder().encode(summary)
        let decoded = try JSONDecoder().decode(ConversationSummary.self, from: encoded)

        XCTAssertEqual(summary, decoded)
    }

    func testHasContent() {
        let dateRange = ConversationSummary.DateRange(start: Date(), end: Date())

        let empty = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertFalse(empty.hasContent)

        let withContent = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["Point 1"],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertTrue(withContent.hasContent)
    }

    func testTotalItems() {
        let dateRange = ConversationSummary.DateRange(start: Date(), end: Date())
        let summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["Point 1", "Point 2"],
            decisions: ["Decision 1"],
            actionItems: ["Action 1", "Action 2", "Action 3"],
            openQuestions: ["Question 1"],
            createdAt: Date()
        )

        XCTAssertEqual(summary.totalItems, 7)
    }
    
    // MARK: - Firestore Serialization Tests
    
    func testToFirestore() {
        // Given
        let startDate = Date().addingTimeInterval(-3600)
        let endDate = Date()
        let dateRange = ConversationSummary.DateRange(start: startDate, end: endDate)
        let createdAt = Date()
        
        let summary = ConversationSummary(
            id: "summary123",
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["Point 1", "Point 2"],
            decisions: ["Decision 1"],
            actionItems: ["Action 1"],
            openQuestions: ["Question 1"],
            createdAt: createdAt
        )
        
        // When
        let firestoreData = summary.toFirestore()
        
        // Then
        XCTAssertEqual(firestoreData["conversationID"] as? String, "conv123")
        XCTAssertEqual((firestoreData["keyPoints"] as? [String])?.count, 2)
        XCTAssertEqual((firestoreData["decisions"] as? [String])?.count, 1)
        XCTAssertEqual((firestoreData["actionItems"] as? [String])?.count, 1)
        XCTAssertEqual((firestoreData["openQuestions"] as? [String])?.count, 1)
        XCTAssertNotNil(firestoreData["messageRange"])
        XCTAssertNotNil(firestoreData["createdAt"])
    }
    
    func testToFirestore_EmptyArrays() {
        // Given
        let dateRange = ConversationSummary.DateRange(start: Date(), end: Date())
        let summary = ConversationSummary(
            id: "summary123",
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        
        // When
        let firestoreData = summary.toFirestore()
        
        // Then
        XCTAssertEqual((firestoreData["keyPoints"] as? [String])?.count, 0)
        XCTAssertEqual((firestoreData["decisions"] as? [String])?.count, 0)
        XCTAssertEqual((firestoreData["actionItems"] as? [String])?.count, 0)
        XCTAssertEqual((firestoreData["openQuestions"] as? [String])?.count, 0)
    }
    
    // MARK: - Helper Method Tests
    
    func testHasContent_AllSections() {
        let dateRange = ConversationSummary.DateRange(start: Date(), end: Date())
        
        // Test keyPoints
        var summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["Point"],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertTrue(summary.hasContent, "Should have content with keyPoints")
        
        // Test decisions
        summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: ["Decision"],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertTrue(summary.hasContent, "Should have content with decisions")
        
        // Test actionItems
        summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: [],
            actionItems: ["Action"],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertTrue(summary.hasContent, "Should have content with actionItems")
        
        // Test openQuestions
        summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: [],
            actionItems: [],
            openQuestions: ["Question"],
            createdAt: Date()
        )
        XCTAssertTrue(summary.hasContent, "Should have content with openQuestions")
    }
    
    func testTotalItems_EdgeCases() {
        let dateRange = ConversationSummary.DateRange(start: Date(), end: Date())
        
        // Empty summary
        var summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: [],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertEqual(summary.totalItems, 0, "Empty summary should have 0 items")
        
        // Single item
        summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: ["One point"],
            decisions: [],
            actionItems: [],
            openQuestions: [],
            createdAt: Date()
        )
        XCTAssertEqual(summary.totalItems, 1, "Should count single item")
        
        // Many items
        summary = ConversationSummary(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageRange: dateRange,
            keyPoints: Array(repeating: "Point", count: 10),
            decisions: Array(repeating: "Decision", count: 5),
            actionItems: Array(repeating: "Action", count: 15),
            openQuestions: Array(repeating: "Question", count: 8),
            createdAt: Date()
        )
        XCTAssertEqual(summary.totalItems, 38, "Should count all items correctly")
    }
    
    // MARK: - DateRange Tests
    
    func testDateRangeEncoding() throws {
        // Given
        let startDate = Date().addingTimeInterval(-7200)
        let endDate = Date()
        let dateRange = ConversationSummary.DateRange(start: startDate, end: endDate)
        
        // When
        let encoded = try JSONEncoder().encode(dateRange)
        let decoded = try JSONDecoder().decode(ConversationSummary.DateRange.self, from: encoded)
        
        // Then
        XCTAssertEqual(dateRange, decoded)
        XCTAssertEqual(dateRange.start.timeIntervalSince1970, decoded.start.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(dateRange.end.timeIntervalSince1970, decoded.end.timeIntervalSince1970, accuracy: 0.001)
    }
}
