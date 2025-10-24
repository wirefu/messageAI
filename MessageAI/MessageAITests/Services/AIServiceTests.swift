//
//  AIServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AIServiceTests: XCTestCase {
    var sut: AIService!
    
    override func setUp() {
        super.setUp()
        sut = AIService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAIServiceInitialization() {
        XCTAssertNotNil(sut)
    }
    
    // Note: Full Cloud Function integration tests require:
    // - OpenAI API key configured
    // - Cloud Functions deployed
    // - Network connectivity
    // These will be tested manually and in integration tests
}

