//
//  AIChatRepositoryTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import FirebaseFirestore
@testable import MessageAI

@MainActor
final class AIChatRepositoryTests: XCTestCase {
    
    var repository: AIChatRepository!
    
    override func setUp() {
        super.setUp()
        repository = AIChatRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    func testCreateSession() async throws {
        // Given
        let session = AIChatSession(
            id: "test-session",
            userID: "user123",
            title: "Test Session",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: AIChatSettings(
                includeContext: true,
                enableSuggestions: true,
                enableActions: true,
                preferredModel: "gpt-4o-mini",
                responseStyle: .professional
            ),
            statistics: nil
        )
        
        // When
        let createdSession = try await repository.createSession(session)
        
        // Then
        XCTAssertEqual(createdSession.id, "test-session")
        XCTAssertEqual(createdSession.title, "Test Session")
        XCTAssertEqual(createdSession.userID, "user123")
        XCTAssertTrue(createdSession.isActive)
        XCTAssertEqual(createdSession.settings.responseStyle, .professional)
    }
    
    func testGetSessions() async throws {
        // Given
        let userID = "user123"
        
        // When
        let sessions = try await repository.getSessions(for: userID)
        
        // Then
        XCTAssertTrue(sessions.isEmpty) // No sessions in mock
    }
    
    func testGetMessages() async throws {
        // Given
        let sessionID = "test-session"
        
        // When
        let messages = try await repository.getMessages(for: sessionID)
        
        // Then
        XCTAssertTrue(messages.isEmpty) // No messages in mock
    }
    
    func testGetSuggestions() async throws {
        // Given
        let sessionID = "test-session"
        
        // When
        let suggestions = try await repository.getSuggestions(for: sessionID)
        
        // Then
        XCTAssertTrue(suggestions.isEmpty) // No suggestions in mock
    }
    
    func testExecuteAction() async throws {
        // Given
        let action = AIChatAction(
            id: "translate",
            name: "Translate",
            description: "Translate this message",
            parameters: ["targetLanguage": "Spanish"]
        )
        let message = AIChatMessage(
            id: "msg1",
            sessionID: "session1",
            userID: "user1",
            content: "Hello world",
            role: .user,
            timestamp: Date(),
            aiMetadata: nil
        )
        
        // When
        let result = try await repository.executeAction(action, on: message)
        
        // Then
        XCTAssertNotNil(result)
    }
}
