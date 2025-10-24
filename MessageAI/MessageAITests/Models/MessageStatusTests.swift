//
//  MessageStatusTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class MessageStatusTests: XCTestCase {
    // MARK: - Enum Cases Tests

    func testAllCases() {
        XCTAssertEqual(MessageStatus.sending.rawValue, "sending")
        XCTAssertEqual(MessageStatus.sent.rawValue, "sent")
        XCTAssertEqual(MessageStatus.delivered.rawValue, "delivered")
        XCTAssertEqual(MessageStatus.read.rawValue, "read")
        XCTAssertEqual(MessageStatus.failed.rawValue, "failed")
    }

    // MARK: - Codable Tests

    func testEncodeDecode() throws {
        let status = MessageStatus.delivered
        let encoded = try JSONEncoder().encode(status)
        let decoded = try JSONDecoder().decode(MessageStatus.self, from: encoded)
        XCTAssertEqual(status, decoded)
    }

    // MARK: - Status Helpers Tests

    func testIsSuccessful() {
        XCTAssertFalse(MessageStatus.sending.isSuccessful)
        XCTAssertTrue(MessageStatus.sent.isSuccessful)
        XCTAssertTrue(MessageStatus.delivered.isSuccessful)
        XCTAssertTrue(MessageStatus.read.isSuccessful)
        XCTAssertFalse(MessageStatus.failed.isSuccessful)
    }

    func testCanRetry() {
        XCTAssertFalse(MessageStatus.sending.canRetry)
        XCTAssertFalse(MessageStatus.sent.canRetry)
        XCTAssertFalse(MessageStatus.delivered.canRetry)
        XCTAssertFalse(MessageStatus.read.canRetry)
        XCTAssertTrue(MessageStatus.failed.canRetry)
    }

    func testDisplayText() {
        XCTAssertEqual(MessageStatus.sending.displayText, "Sending...")
        XCTAssertEqual(MessageStatus.sent.displayText, "Sent")
        XCTAssertEqual(MessageStatus.delivered.displayText, "Delivered")
        XCTAssertEqual(MessageStatus.read.displayText, "Read")
        XCTAssertEqual(MessageStatus.failed.displayText, "Failed to send")
    }
}
