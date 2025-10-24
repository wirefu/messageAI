//
//  MessageModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class MessageModelTests: XCTestCase {
    func testMessageEncoding() throws {
        let message = Message(
            id: "msg123",
            conversationID: "conv123",
            senderID: "user123",
            content: "Test message",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sent,
            aiSuggestions: nil
        )

        let encoded = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(Message.self, from: encoded)

        XCTAssertEqual(message, decoded)
    }

    func testMessageWithAllStatuses() throws {
        let statuses: [MessageStatus] = [.sending, .sent, .delivered, .read, .failed]

        for status in statuses {
            let message = Message(
                id: UUID().uuidString,
                conversationID: "conv123",
                senderID: "user123",
                content: "Test",
                timestamp: Date(),
                deliveredAt: nil,
                readAt: nil,
                status: status,
                aiSuggestions: nil
            )

            let encoded = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(Message.self, from: encoded)

            XCTAssertEqual(decoded.status, status)
        }
    }

    func testIsRead() {
        let readMessage = Message(
            id: UUID().uuidString,
            conversationID: "conv123",
            senderID: "user123",
            content: "Test",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: Date(),
            status: .read,
            aiSuggestions: nil
        )
        XCTAssertTrue(readMessage.isRead)
    }

    func testIsFromCurrentUser() {
        let message = Message(
            id: UUID().uuidString,
            conversationID: "conv123",
            senderID: "user123",
            content: "Test",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )

        XCTAssertTrue(message.isFromCurrentUser("user123"))
        XCTAssertFalse(message.isFromCurrentUser("user456"))
    }
}

