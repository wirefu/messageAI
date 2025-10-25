//
//  AIChatMessageTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AIChatMessageTests: XCTestCase {
    
    var aiChatMessage: AIChatMessage!
    var aiMetadata: AIChatMetadata!
    var suggestion: AIChatSuggestion!
    var action: AIChatAction!
    
    override func setUp() {
        super.setUp()
        
        suggestion = AIChatSuggestion(
            type: "action",
            suggestion: "Create a project timeline",
            confidence: 0.8
        )
        
        action = AIChatAction(
            id: "translate",
            name: "Translate",
            description: "Translate this message",
            parameters: ["targetLanguage": "Spanish"]
        )
        
        aiMetadata = AIChatMetadata(
            model: "gpt-4o-mini",
            responseTime: 1500,
            confidence: 0.9,
            context: "Previous discussion about project timelines",
            suggestions: [suggestion],
            actions: [action]
        )
        
        aiChatMessage = AIChatMessage(
            id: "msg-123",
            sessionID: "session-456",
            userID: "user-789",
            content: "What did we discuss about the project?",
            role: .user,
            timestamp: Date(),
            aiMetadata: nil
        )
    }
    
    override func tearDown() {
        aiChatMessage = nil
        aiMetadata = nil
        suggestion = nil
        action = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAIChatMessageInitialization() {
        XCTAssertEqual(aiChatMessage.id, "msg-123")
        XCTAssertEqual(aiChatMessage.sessionID, "session-456")
        XCTAssertEqual(aiChatMessage.userID, "user-789")
        XCTAssertEqual(aiChatMessage.content, "What did we discuss about the project?")
        XCTAssertEqual(aiChatMessage.role, .user)
        XCTAssertNotNil(aiChatMessage.timestamp)
        XCTAssertNil(aiChatMessage.aiMetadata)
    }
    
    func testAIChatMessageWithMetadata() {
        let messageWithMetadata = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "Based on your conversation history, you discussed project timelines.",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: aiMetadata
        )
        
        XCTAssertEqual(messageWithMetadata.role, .assistant)
        XCTAssertNotNil(messageWithMetadata.aiMetadata)
        XCTAssertEqual(messageWithMetadata.aiMetadata?.model, "gpt-4o-mini")
        XCTAssertEqual(messageWithMetadata.aiMetadata?.confidence, 0.9)
    }
    
    // MARK: - Role Tests
    
    func testAIChatRoleCases() {
        XCTAssertEqual(AIChatRole.user.rawValue, "user")
        XCTAssertEqual(AIChatRole.assistant.rawValue, "assistant")
        XCTAssertEqual(AIChatRole.system.rawValue, "system")
        
        let allCases = AIChatRole.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.user))
        XCTAssertTrue(allCases.contains(.assistant))
        XCTAssertTrue(allCases.contains(.system))
    }
    
    // MARK: - Helper Tests
    
    func testIsFromUser() {
        XCTAssertTrue(aiChatMessage.isFromUser)
        
        let assistantMessage = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "AI response",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        XCTAssertFalse(assistantMessage.isFromUser)
    }
    
    func testIsFromAssistant() {
        XCTAssertFalse(aiChatMessage.isFromAssistant)
        
        let assistantMessage = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "AI response",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        XCTAssertTrue(assistantMessage.isFromAssistant)
    }
    
    func testHasAIMetadata() {
        XCTAssertFalse(aiChatMessage.hasAIMetadata)
        
        let messageWithMetadata = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "AI response",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: aiMetadata
        )
        
        XCTAssertTrue(messageWithMetadata.hasAIMetadata)
    }
    
    func testHasSuggestions() {
        XCTAssertFalse(aiChatMessage.hasSuggestions)
        
        let messageWithMetadata = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "AI response",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: aiMetadata
        )
        
        XCTAssertTrue(messageWithMetadata.hasSuggestions)
    }
    
    func testHasActions() {
        XCTAssertFalse(aiChatMessage.hasActions)
        
        let messageWithMetadata = AIChatMessage(
            id: "msg-456",
            sessionID: "session-789",
            userID: "user-123",
            content: "AI response",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: aiMetadata
        )
        
        XCTAssertTrue(messageWithMetadata.hasActions)
    }
    
    // MARK: - AIChatMetadata Tests
    
    func testAIChatMetadataInitialization() {
        XCTAssertEqual(aiMetadata.model, "gpt-4o-mini")
        XCTAssertEqual(aiMetadata.responseTime, 1500)
        XCTAssertEqual(aiMetadata.confidence, 0.9)
        XCTAssertEqual(aiMetadata.context, "Previous discussion about project timelines")
        XCTAssertEqual(aiMetadata.suggestions?.count, 1)
        XCTAssertEqual(aiMetadata.actions?.count, 1)
    }
    
    func testAIChatMetadataHasMetadata() {
        XCTAssertTrue(aiMetadata.hasMetadata)
        
        let emptyMetadata = AIChatMetadata(
            model: nil,
            responseTime: nil,
            confidence: nil,
            context: nil,
            suggestions: nil,
            actions: nil
        )
        
        XCTAssertFalse(emptyMetadata.hasMetadata)
    }
    
    // MARK: - AIChatSuggestion Tests
    
    func testAIChatSuggestionInitialization() {
        XCTAssertEqual(suggestion.type, "action")
        XCTAssertEqual(suggestion.suggestion, "Create a project timeline")
        XCTAssertEqual(suggestion.confidence, 0.8)
    }
    
    // MARK: - AIChatAction Tests
    
    func testAIChatActionInitialization() {
        XCTAssertEqual(action.id, "translate")
        XCTAssertEqual(action.name, "Translate")
        XCTAssertEqual(action.description, "Translate this message")
        XCTAssertEqual(action.parameters?["targetLanguage"], "Spanish")
    }
    
    // MARK: - Codable Tests
    
    func testAIChatMessageCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(aiChatMessage)
            let decodedMessage = try decoder.decode(AIChatMessage.self, from: data)
            
            XCTAssertEqual(decodedMessage.id, aiChatMessage.id)
            XCTAssertEqual(decodedMessage.sessionID, aiChatMessage.sessionID)
            XCTAssertEqual(decodedMessage.userID, aiChatMessage.userID)
            XCTAssertEqual(decodedMessage.content, aiChatMessage.content)
            XCTAssertEqual(decodedMessage.role, aiChatMessage.role)
        } catch {
            XCTFail("Failed to encode/decode AIChatMessage: \(error)")
        }
    }
    
    func testAIChatMetadataCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(aiMetadata)
            let decodedMetadata = try decoder.decode(AIChatMetadata.self, from: data)
            
            XCTAssertEqual(decodedMetadata.model, aiMetadata.model)
            XCTAssertEqual(decodedMetadata.responseTime, aiMetadata.responseTime)
            XCTAssertEqual(decodedMetadata.confidence, aiMetadata.confidence)
            XCTAssertEqual(decodedMetadata.context, aiMetadata.context)
        } catch {
            XCTFail("Failed to encode/decode AIChatMetadata: \(error)")
        }
    }
    
    // MARK: - Equatable Tests
    
    func testAIChatMessageEquatable() {
        let message1 = AIChatMessage(
            id: "msg-123",
            sessionID: "session-456",
            userID: "user-789",
            content: "Test message",
            role: .user,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        let message2 = AIChatMessage(
            id: "msg-123",
            sessionID: "session-456",
            userID: "user-789",
            content: "Test message",
            role: .user,
            timestamp: message1.timestamp,
            aiMetadata: nil
        )
        
        XCTAssertEqual(message1, message2)
    }
    
    func testAIChatMetadataEquatable() {
        let metadata1 = AIChatMetadata(
            model: "gpt-4o-mini",
            responseTime: 1500,
            confidence: 0.9,
            context: "Test context",
            suggestions: nil,
            actions: nil
        )
        
        let metadata2 = AIChatMetadata(
            model: "gpt-4o-mini",
            responseTime: 1500,
            confidence: 0.9,
            context: "Test context",
            suggestions: nil,
            actions: nil
        )
        
        XCTAssertEqual(metadata1, metadata2)
    }
}
