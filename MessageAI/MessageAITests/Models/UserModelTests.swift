//
//  UserModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class UserModelTests: XCTestCase {
    func testUserEncoding() throws {
        let user = User(
            id: "user123",
            displayName: "Test User",
            email: "test@example.com",
            avatarURL: "https://example.com/avatar.jpg",
            isOnline: true,
            lastSeen: Date(),
            fcmToken: "token123",
            createdAt: Date()
        )

        let encoded = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)

        XCTAssertEqual(user, decoded)
    }

    func testUserWithOptionalFields() throws {
        let user = User(
            id: "user123",
            displayName: "Test User",
            email: "test@example.com",
            avatarURL: nil,
            isOnline: false,
            lastSeen: Date(),
            fcmToken: nil,
            createdAt: Date()
        )

        let encoded = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)

        XCTAssertEqual(user.id, decoded.id)
        XCTAssertNil(decoded.avatarURL)
        XCTAssertNil(decoded.fcmToken)
    }

    func testToFirestore() {
        let user = User(
            id: "user123",
            displayName: "Test User",
            email: "test@example.com",
            avatarURL: nil,
            isOnline: true,
            lastSeen: Date(),
            fcmToken: nil,
            createdAt: Date()
        )

        let firestoreData = user.toFirestore()

        XCTAssertEqual(firestoreData["id"] as? String, "user123")
        XCTAssertEqual(firestoreData["displayName"] as? String, "Test User")
        XCTAssertEqual(firestoreData["email"] as? String, "test@example.com")
        XCTAssertEqual(firestoreData["isOnline"] as? Bool, true)
        XCTAssertNotNil(firestoreData["lastSeen"])
        XCTAssertNotNil(firestoreData["createdAt"])
    }
}

