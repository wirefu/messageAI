//
//  ActionItemModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class ActionItemModelTests: XCTestCase {
    func testActionItemEncoding() throws {
        let dueDate = Date().addingTimeInterval(86400)
        let actionItem = ActionItem(
            id: "action123",
            conversationID: "conv123",
            messageID: "msg123",
            description: "Review PR",
            assignedTo: "user123",
            dueDate: dueDate,
            isCompleted: false,
            createdAt: Date()
        )

        let encoded = try JSONEncoder().encode(actionItem)
        let decoded = try JSONDecoder().decode(ActionItem.self, from: encoded)

        XCTAssertEqual(actionItem, decoded)
    }

    func testIsOverdue() {
        let pastDate = Date().addingTimeInterval(-86400)
        let futureDate = Date().addingTimeInterval(86400)

        let overdueItem = ActionItem(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageID: "msg123",
            description: "Test",
            assignedTo: nil,
            dueDate: pastDate,
            isCompleted: false,
            createdAt: Date()
        )
        XCTAssertTrue(overdueItem.isOverdue)

        let upcomingItem = ActionItem(
            id: UUID().uuidString,
            conversationID: "conv123",
            messageID: "msg123",
            description: "Test",
            assignedTo: nil,
            dueDate: futureDate,
            isCompleted: false,
            createdAt: Date()
        )
        XCTAssertFalse(upcomingItem.isOverdue)
    }
}

