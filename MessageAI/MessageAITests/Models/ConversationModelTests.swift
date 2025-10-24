//
//  ConversationModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class ConversationModelTests: XCTestCase {
    func testConversationEncoding() throws {
        let conversation = Conversation(
            id: "conv123",
            participants: ["user1", "user2"],
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: ["user1": 5, "user2": 0],
            createdAt: Date()
        )

        let encoded = try JSONEncoder().encode(conversation)
        let decoded = try JSONDecoder().decode(Conversation.self, from: encoded)

        XCTAssertEqual(conversation, decoded)
    }

    func testOtherParticipantID() {
        let conversation = Conversation(
            id: "conv123",
            participants: ["user1", "user2"],
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: [:],
            createdAt: Date()
        )

        XCTAssertEqual(conversation.otherParticipantID(currentUserID: "user1"), "user2")
        XCTAssertEqual(conversation.otherParticipantID(currentUserID: "user2"), "user1")
    }

    func testUnreadCountForUser() {
        let conversation = Conversation(
            id: "conv123",
            participants: ["user1", "user2"],
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: ["user1": 5, "user2": 0],
            createdAt: Date()
        )

        XCTAssertEqual(conversation.unreadCount(for: "user1"), 5)
        XCTAssertEqual(conversation.unreadCount(for: "user2"), 0)
        XCTAssertEqual(conversation.unreadCount(for: "user3"), 0)
    }

    func testIncludesUser() {
        let conversation = Conversation(
            id: "conv123",
            participants: ["user1", "user2"],
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: [:],
            createdAt: Date()
        )

        XCTAssertTrue(conversation.includes(userID: "user1"))
        XCTAssertTrue(conversation.includes(userID: "user2"))
        XCTAssertFalse(conversation.includes(userID: "user3"))
    }
}

