//
//  StringExtensionsTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class StringExtensionsTests: XCTestCase {

    // MARK: - Trimming Tests

    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
        XCTAssertEqual("\n\nhello\n\n".trimmed, "hello")
        XCTAssertEqual("hello".trimmed, "hello")
        XCTAssertEqual("   ".trimmed, "")
    }

    func testIsBlank() {
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("\n\n".isBlank)
        XCTAssertFalse("hello".isBlank)
        XCTAssertFalse("  hello  ".isBlank)
    }

    // MARK: - Email Validation Tests

    func testIsValidEmail() {
        // Valid emails
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name@example.com".isValidEmail)
        XCTAssertTrue("user+tag@example.co.uk".isValidEmail)

        // Invalid emails
        XCTAssertFalse("invalid".isValidEmail)
        XCTAssertFalse("@example.com".isValidEmail)
        XCTAssertFalse("user@".isValidEmail)
        XCTAssertFalse("user @example.com".isValidEmail)
        XCTAssertFalse("".isValidEmail)
    }

    // MARK: - Password Validation Tests

    func testIsValidPassword() {
        // Valid passwords
        XCTAssertTrue("password123".isValidPassword)
        XCTAssertTrue("123456".isValidPassword)
        XCTAssertTrue("secure_password_2024".isValidPassword)

        // Invalid passwords
        XCTAssertFalse("short".isValidPassword)
        XCTAssertFalse("12345".isValidPassword)
        XCTAssertFalse("".isValidPassword)
    }

    // MARK: - Display Name Validation Tests

    func testIsValidDisplayName() {
        // Valid display names
        XCTAssertTrue("John Doe".isValidDisplayName)
        XCTAssertTrue("AB".isValidDisplayName)
        XCTAssertTrue("A Very Long Name That Is Still Valid".isValidDisplayName)

        // Invalid display names
        XCTAssertFalse("A".isValidDisplayName)
        XCTAssertFalse(" ".isValidDisplayName)
        XCTAssertFalse("".isValidDisplayName)
        XCTAssertFalse(String(repeating: "A", count: 51).isValidDisplayName)
    }

    // MARK: - Message Validation Tests

    func testIsValidMessage() {
        // Valid messages
        XCTAssertTrue("Hello!".isValidMessage)
        XCTAssertTrue("A".isValidMessage)

        // Invalid messages
        XCTAssertFalse("".isValidMessage)
        XCTAssertFalse("   ".isValidMessage)
        XCTAssertFalse(String(repeating: "A", count: 10001).isValidMessage)
    }

    // MARK: - Truncation Tests

    func testTruncated() {
        let longText = "This is a very long text that needs to be truncated"
        XCTAssertEqual(longText.truncated(to: 10), "This is a ...")
        XCTAssertEqual("Short".truncated(to: 10), "Short")
        XCTAssertEqual(longText.truncated(to: 10, trailing: ">>"), "This is a >>")
    }

    // MARK: - Initials Tests

    func testFirstLetter() {
        XCTAssertEqual("Hello".firstLetter, "H")
        XCTAssertEqual("a".firstLetter, "A")
        XCTAssertEqual("".firstLetter, "")
    }

    func testInitials() {
        XCTAssertEqual("John Doe".initials, "JD")
        XCTAssertEqual("Jane".initials, "J")
        XCTAssertEqual("Bob Smith Johnson".initials, "BS")
        XCTAssertEqual("".initials, "")
    }

    // MARK: - URL Extraction Tests

    func testExtractedURLs() {
        let text1 = "Check out https://example.com for more info"
        let urls1 = text1.extractedURLs
        XCTAssertEqual(urls1.count, 1)
        XCTAssertEqual(urls1.first?.absoluteString, "https://example.com")

        let text2 = "No URLs here"
        XCTAssertTrue(text2.extractedURLs.isEmpty)

        let text3 = "Multiple: https://example.com and http://test.com"
        XCTAssertEqual(text3.extractedURLs.count, 2)
    }

    // MARK: - Hash Tests

    func testStableHash() {
        let string1 = "test"
        let string2 = "test"
        let string3 = "different"

        XCTAssertEqual(string1.stableHash, string2.stableHash)
        XCTAssertNotEqual(string1.stableHash, string3.stableHash)
        XCTAssertGreaterThan(string1.stableHash, 0)
    }
}
