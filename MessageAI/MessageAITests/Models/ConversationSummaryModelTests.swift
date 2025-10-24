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
}
