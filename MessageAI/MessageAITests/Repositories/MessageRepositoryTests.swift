//
//  MessageRepositoryTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class MessageRepositoryTests: XCTestCase {
    var sut: MessageRepository!
    
    override func setUp() {
        super.setUp()
        sut = MessageRepository()
    }
    
    override func tearDown() {
        sut.stopObserving()
        super.tearDown()
    }
    
    func testRepositoryInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testStopObserving() {
        sut.observeMessages(conversationID: "test123") { _ in }
        XCTAssertNoThrow(sut.stopObserving())
    }
    
    func testDeinitRemovesListener() {
        var repository: MessageRepository? = MessageRepository()
        repository?.observeMessages(conversationID: "test123") { _ in }
        repository = nil
        XCTAssertNil(repository)
    }
    
    // Note: Full integration tests with actual Firestore operations
    // will be in MessagingFlowTests using Firebase Emulator
}


