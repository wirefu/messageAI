//
//  AIChatViewTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import SwiftUI
@testable import MessageAI

@MainActor
final class AIChatViewTests: XCTestCase {
    
    func testAIChatViewInitialization() {
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
        let currentUserID = "user123"
        
        // When
        let view = AIChatView(session: session, currentUserID: currentUserID)
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testAIChatViewWithSession() {
        // Given
        let session = AIChatSession(
            id: "test-session",
            userID: "user123",
            title: "Test Session",
            description: "A test session for AI chat",
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
        let currentUserID = "user123"
        
        // When
        let view = AIChatView(session: session, currentUserID: currentUserID)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertEqual(view.session.id, "test-session")
        XCTAssertEqual(view.session.title, "Test Session")
        XCTAssertEqual(view.currentUserID, "user123")
    }
    
    func testAIChatViewWithDifferentSettings() {
        // Given
        let session = AIChatSession(
            id: "test-session-2",
            userID: "user456",
            title: "Casual Chat",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: AIChatSettings(
                includeContext: false,
                enableSuggestions: false,
                enableActions: true,
                preferredModel: "claude-v3",
                responseStyle: .casual
            ),
            statistics: nil
        )
        let currentUserID = "user456"
        
        // When
        let view = AIChatView(session: session, currentUserID: currentUserID)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertEqual(view.session.settings.responseStyle, .casual)
        XCTAssertEqual(view.session.settings.preferredModel, "claude-v3")
        XCTAssertFalse(view.session.settings.includeContext)
    }
    
    func testAIChatViewWithStatistics() {
        // Given
        let statistics = AIChatStatistics(
            totalMessages: 10,
            userMessages: 5,
            assistantMessages: 5,
            totalResponseTime: 1000,
            averageResponseTime: 100,
            suggestionsProvided: 3,
            actionsExecuted: 2
        )
        let session = AIChatSession(
            id: "test-session-3",
            userID: "user789",
            title: "Active Session",
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
            statistics: statistics
        )
        let currentUserID = "user789"
        
        // When
        let view = AIChatView(session: session, currentUserID: currentUserID)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertNotNil(view.session.statistics)
        XCTAssertEqual(view.session.statistics?.totalMessages, 10)
        XCTAssertEqual(view.session.statistics?.actionsExecuted, 2)
    }
}

// MARK: - Mock Repository for UI Tests

class MockAIChatRepositoryView: AIChatRepositoryProtocol {
    var shouldFail = false
    
    func getSessions(for userID: String) async throws -> [AIChatSession] {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return []
    }
    
    func createSession(_ session: AIChatSession) async throws -> AIChatSession {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return session
    }
    
    func deleteSession(_ session: AIChatSession) async throws {
        if shouldFail {
            throw AppError.networkUnavailable
        }
    }
    
    func getMessages(for sessionID: String) async throws -> [AIChatMessage] {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return []
    }
    
    func sendMessage(_ message: AIChatMessage) async throws -> AIChatResponse {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return AIChatResponse(
            aiMessage: nil,
            suggestions: nil,
            actions: nil,
            context: nil
        )
    }
    
    func clearSession(_ sessionID: String) async throws {
        if shouldFail {
            throw AppError.networkUnavailable
        }
    }
    
    func getSuggestions(for sessionID: String) async throws -> [String] {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return []
    }
    
    func executeAction(_ action: AIChatAction, on message: AIChatMessage) async throws -> Any {
        if shouldFail {
            throw AppError.networkUnavailable
        }
        return "Mock action result"
    }
}
