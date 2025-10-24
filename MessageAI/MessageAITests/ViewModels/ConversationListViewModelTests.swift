//
//  ConversationListViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

@MainActor
final class ConversationListViewModelTests: XCTestCase {
    var sut: ConversationListViewModel!
    var mockRepository: MockConversationRepository!
    var mockUserRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockConversationRepository()
        mockUserRepository = MockUserRepository()
        sut = ConversationListViewModel(
            repository: mockRepository,
            userRepository: mockUserRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockUserRepository = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testClearError() {
        sut.error = .firestoreError("Test error")
        XCTAssertNotNil(sut.error)
        
        sut.clearError()
        XCTAssertNil(sut.error)
    }
    
    func testGetUnreadCount() {
        let conversation = Conversation(
            id: "conv123",
            participants: ["user1", "user2"],
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: ["user1": 5, "user2": 0],
            createdAt: Date()
        )
        
        sut.conversations = [conversation]
        
        XCTAssertEqual(sut.getUnreadCount(conversationID: "conv123", userID: "user1"), 5)
        XCTAssertEqual(sut.getUnreadCount(conversationID: "conv123", userID: "user2"), 0)
        XCTAssertEqual(sut.getUnreadCount(conversationID: "nonexistent", userID: "user1"), 0)
    }
}

// MARK: - Mock Conversation Repository

class MockConversationRepository: ConversationRepositoryProtocol {
    var mockConversations: [Conversation] = []
    var shouldFail = false
    
    func createConversation(participants: [String]) async throws -> String {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        let id = UUID().uuidString
        let conversation = Conversation(
            id: id,
            participants: participants,
            lastMessage: nil,
            lastMessageTimestamp: Date(),
            unreadCount: [:],
            createdAt: Date()
        )
        mockConversations.append(conversation)
        return id
    }
    
    func getConversations(for userID: String) async throws -> [Conversation] {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        return mockConversations.filter { $0.participants.contains(userID) }
    }
    
    func getConversation(id: String) async throws -> Conversation? {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        return mockConversations.first { $0.id == id }
    }
    
    func observeConversations(for userID: String, completion: @escaping ([Conversation]) -> Void) {
        completion(mockConversations.filter { $0.participants.contains(userID) })
    }
    
    func updateLastMessage(conversationID: String, message: Message) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
    
    func updateUnreadCount(conversationID: String, userID: String, increment: Bool) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
    
    func resetUnreadCount(conversationID: String, userID: String) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
}

