//
//  UserRepositoryTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class UserRepositoryTests: XCTestCase {
    var sut: UserRepository!
    
    override func setUp() {
        super.setUp()
        sut = UserRepository()
    }
    
    override func tearDown() {
        sut.stopObserving()
        super.tearDown()
    }
    
    func testRepositoryInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testStopObserving() {
        sut.observeUser(id: "test123") { _ in }
        XCTAssertNoThrow(sut.stopObserving())
    }
    
    func testDeinitRemovesListener() {
        var repository: UserRepository? = UserRepository()
        repository?.observeUser(id: "test123") { _ in }
        repository = nil
        XCTAssertNil(repository)
    }
}


