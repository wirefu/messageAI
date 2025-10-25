//
//  AIChatViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import FirebaseFirestore
@testable import MessageAI

@MainActor
final class AIChatViewModelTests: XCTestCase {
    
    var viewModel: AIChatViewModel!
    var mockRepository: MockAIChatRepositoryViewModel!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAIChatRepositoryViewModel()
        viewModel = AIChatViewModel(sessionID: "test-session", aiChatRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testSendMessage() async throws {
        // Given
        let testMessage = "Hello AI, how are you?"
        let aiResponse = AIChatMessage(
            id: "ai-msg-1",
            sessionID: "test-session",
            userID: "ai",
            content: "Hello! I'm doing well, thank you for asking.",
            role: .assistant,
            timestamp: Date(),
            aiMetadata: nil
        )
        mockRepository.mockResponse = AIChatResponse(
            aiMessage: aiResponse,
            suggestions: ["Ask about the weather", "Request a summary"],
            actions: nil,
            context: nil
        )
        
        // When
        await viewModel.sendMessage(testMessage)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.messages.count, 2) // User message + AI response
        XCTAssertEqual(viewModel.messages.first?.content, testMessage)
        XCTAssertEqual(viewModel.messages.last?.content, "Hello! I'm doing well, thank you for asking.")
        XCTAssertEqual(viewModel.currentSuggestions.count, 2)
    }
    
    func testSendMessageWithError() async throws {
        // Given
        let testMessage = "Hello AI"
        mockRepository.shouldFail = true
        
        // When
        await viewModel.sendMessage(testMessage)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testCreateSession() async throws {
        // Given
        let session = AIChatSession(
            id: "session123",
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
        mockRepository.mockSession = session
        
        // When
        let createdSession = try await viewModel.createSession(session)
        
        // Then
        XCTAssertEqual(createdSession.id, "session123")
        XCTAssertEqual(createdSession.title, "Test Session")
    }
    
    func testClearSession() async throws {
        // Given
        viewModel.messages = [
            AIChatMessage(
                id: "msg1",
                sessionID: "test-session",
                userID: "user1",
                content: "Test message",
                role: .user,
                timestamp: Date(),
                aiMetadata: nil
            )
        ]
        
        // When
        await viewModel.clearSession()
        
        // Then
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.currentSuggestions.isEmpty)
    }
}

// MARK: - Mock Classes

class MockAIChatRepositoryViewModel: AIChatRepositoryProtocol {
    var mockResponse: AIChatResponse?
    var mockSession: AIChatSession?
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
        return mockSession ?? session
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
        return mockResponse ?? AIChatResponse(
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
