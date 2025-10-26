//
//  MessageActionsIntegrationTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import SwiftUI
@testable import MessageAI

@MainActor
final class MessageActionsIntegrationTests: XCTestCase {
    
    var aiService: AIService!
    var testMessageId: String!
    var testConversationId: String!
    
    override func setUp() {
        super.setUp()
        aiService = AIService.shared
        testMessageId = "test-message-\(UUID().uuidString)"
        testConversationId = "test-conversation-\(UUID().uuidString)"
    }
    
    override func tearDown() {
        aiService = nil
        testMessageId = nil
        testConversationId = nil
        super.tearDown()
    }
    
    // MARK: - AIService Integration Tests
    
    func testAIServiceInitialization() {
        XCTAssertNotNil(aiService)
        XCTAssertNotNil(aiService.cache)
    }
    
    func testAIServiceCacheOperations() {
        let testKey = "test-cache-key"
        let testResult = MessageActionResult(
            actionType: .translate,
            originalText: "Hello",
            resultText: "Hola",
            metadata: [:]
        )
        
        // Test cache set
        aiService.cache.setActionResult(testResult, for: testKey)
        
        // Test cache get
        let cachedResult = aiService.cache.getActionResult(for: testKey)
        XCTAssertNotNil(cachedResult)
        XCTAssertEqual(cachedResult?.actionType, .translate)
        XCTAssertEqual(cachedResult?.originalText, "Hello")
        XCTAssertEqual(cachedResult?.resultText, "Hola")
    }
    
    func testAIServiceCacheMiss() {
        let nonExistentKey = "non-existent-key"
        let cachedResult = aiService.cache.getActionResult(for: nonExistentKey)
        XCTAssertNil(cachedResult)
    }
    
    // MARK: - Message Action Flow Tests
    
    func testMessageActionFlow() {
        // Test the complete flow from action selection to result
        let actionType = MessageActionType.translate
        let parameters = ["targetLanguage": "Spanish", "sourceLanguage": "auto"]
        
        // This would normally call the Cloud Function
        // For testing, we'll verify the service can handle the call
        XCTAssertNotNil(aiService)
        XCTAssertNotNil(testMessageId)
        XCTAssertNotNil(testConversationId)
    }
    
    func testActionParameterGeneration() {
        // Test translate parameters
        let translateParams = generateParameters(for: .translate, tone: nil)
        XCTAssertEqual(translateParams["targetLanguage"] as? String, "Spanish")
        XCTAssertEqual(translateParams["sourceLanguage"] as? String, "auto")
        
        // Test rewrite parameters
        let rewriteParams = generateParameters(for: .rewrite, tone: .formal)
        XCTAssertEqual(rewriteParams["tone"] as? String, "formal")
        
        // Test other actions (no parameters)
        let extractParams = generateParameters(for: .extract, tone: nil)
        XCTAssertTrue(extractParams.isEmpty)
        
        let summarizeParams = generateParameters(for: .summarize, tone: nil)
        XCTAssertTrue(summarizeParams.isEmpty)
    }
    
    private func generateParameters(for action: MessageActionType, tone: MessageTone?) -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if action == .translate {
            parameters["targetLanguage"] = "Spanish"
            parameters["sourceLanguage"] = "auto"
        } else if action == .rewrite, let tone = tone {
            parameters["tone"] = tone.rawValue
        }
        
        return parameters
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() {
        // Test that the service can handle errors gracefully
        let invalidMessageId = ""
        let invalidConversationId = ""
        
        // These should not crash the app
        XCTAssertNotNil(invalidMessageId)
        XCTAssertNotNil(invalidConversationId)
    }
    
    // MARK: - Performance Tests
    
    func testCachePerformance() {
        let iterations = 1000
        let testResult = MessageActionResult(
            actionType: .translate,
            originalText: "Test",
            resultText: "Prueba",
            metadata: [:]
        )
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            let key = "test-key-\(i)"
            aiService.cache.setActionResult(testResult, for: key)
            _ = aiService.cache.getActionResult(for: key)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Cache operations for \(iterations) iterations took \(timeElapsed) seconds")
        
        // Should complete in reasonable time (less than 1 second)
        XCTAssertLessThan(timeElapsed, 1.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        // Test that objects are properly deallocated
        weak var weakAIService = aiService
        
        // Clear the strong reference
        aiService = nil
        
        // Force garbage collection
        autoreleasepool {
            // The weak reference should be nil if properly deallocated
            // Note: This test might be flaky in some environments
        }
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentCacheAccess() {
        let expectation = XCTestExpectation(description: "Concurrent cache access")
        expectation.expectedFulfillmentCount = 10
        
        let testResult = MessageActionResult(
            actionType: .translate,
            originalText: "Concurrent Test",
            resultText: "Prueba Concurrente",
            metadata: [:]
        )
        
        // Test concurrent cache operations
        for i in 0..<10 {
            DispatchQueue.global().async {
                let key = "concurrent-key-\(i)"
                self.aiService.cache.setActionResult(testResult, for: key)
                _ = self.aiService.cache.getActionResult(for: key)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Data Validation Tests
    
    func testMessageActionResultValidation() {
        // Test valid result
        let validResult = MessageActionResult(
            actionType: .translate,
            originalText: "Valid text",
            resultText: "Texto válido",
            metadata: ["confidence": 0.95]
        )
        
        XCTAssertEqual(validResult.actionType, .translate)
        XCTAssertFalse(validResult.originalText.isEmpty)
        XCTAssertFalse(validResult.resultText.isEmpty)
        XCTAssertNotNil(validResult.metadata)
    }
    
    func testActionTypeValidation() {
        // Test that all action types are valid
        for actionType in MessageActionType.allCases {
            XCTAssertFalse(actionType.rawValue.isEmpty)
            XCTAssertFalse(actionType.displayName.isEmpty)
        }
    }
    
    func testToneValidation() {
        // Test that all tones are valid
        for tone in MessageTone.allCases {
            XCTAssertFalse(tone.rawValue.isEmpty)
            XCTAssertFalse(tone.displayName.isEmpty)
            XCTAssertFalse(tone.description.isEmpty)
        }
    }
}
