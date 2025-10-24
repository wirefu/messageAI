//
//  AISuggestionModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AISuggestionModelTests: XCTestCase {
    func testAISuggestionEncoding() throws {
        let suggestion = AISuggestion(
            clarityIssues: ["Issue 1", "Issue 2"],
            suggestedRevision: "Better version",
            toneWarning: "Might sound abrupt",
            alternativePhrasing: "Try this instead"
        )

        let encoded = try JSONEncoder().encode(suggestion)
        let decoded = try JSONDecoder().decode(AISuggestion.self, from: encoded)

        XCTAssertEqual(suggestion, decoded)
    }

    func testHasSuggestions() {
        let suggestion = AISuggestion(clarityIssues: ["Issue 1"], suggestedRevision: nil, toneWarning: nil, alternativePhrasing: nil)
        XCTAssertTrue(suggestion.hasSuggestions)

        let empty = AISuggestion(clarityIssues: nil, suggestedRevision: nil, toneWarning: nil, alternativePhrasing: nil)
        XCTAssertFalse(empty.hasSuggestions)
    }

    func testSuggestionCount() {
        let multiple = AISuggestion(
            clarityIssues: ["Issue 1", "Issue 2"],
            suggestedRevision: "Better",
            toneWarning: "Warning",
            alternativePhrasing: nil
        )
        XCTAssertEqual(multiple.suggestionCount, 4)
    }
}

