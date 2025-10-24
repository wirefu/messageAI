//
//  ConversationRepositoryTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class ConversationRepositoryTests: XCTestCase {
    var sut: ConversationRepository!
    
    override func setUp() {
        super.setUp()
        sut = ConversationRepository()
    }
    
    override func tearDown() {
        sut.stopObserving()
        super.tearDown()
    }
    
    func testRepositoryInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testStopObserving() {
        sut.observeConversations(for: "user123") { _ in }
        XCTAssertNoThrow(sut.stopObserving())
    }
    
    func testDeinitRemovesListener() {
        var repository: ConversationRepository? = ConversationRepository()
        repository?.observeConversations(for: "user123") { _ in }
        repository = nil
        XCTAssertNil(repository)
    }
}

