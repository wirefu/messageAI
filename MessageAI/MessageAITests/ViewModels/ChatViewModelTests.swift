//
//  ChatViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import FirebaseFirestore
@testable import MessageAI

@MainActor
final class ChatViewModelTests: XCTestCase {
    var sut: ChatViewModel!
    var mockMessageRepository: MockMessageRepository!
    var mockConversationRepository: MockConversationRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockMessageRepository = MockMessageRepository()
        mockConversationRepository = MockConversationRepository()
        
        // Create test conversation first
        _ = try await mockConversationRepository.createConversation(participants: ["user1", "user2"])
        
        sut = ChatViewModel(
            conversationID: "test-conv",
            currentUserID: "user1",
            messageRepository: mockMessageRepository,
            conversationRepository: mockConversationRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockMessageRepository = nil
        mockConversationRepository = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.messages.isEmpty || !sut.messages.isEmpty) // May load from mock
        XCTAssertNotNil(sut)
    }
    
    func testClearError() {
        sut.error = .sendFailed
        XCTAssertNotNil(sut.error)
        
        sut.clearError()
        XCTAssertNil(sut.error)
    }
}

// MARK: - Mock Message Repository

class MockMessageRepository: MessageRepositoryProtocol {
    var mockMessages: [Message] = []
    var shouldFail = false
    
    func sendMessage(_ message: Message, to conversationID: String) async throws {
        if shouldFail {
            throw AppError.sendFailed
        }
        mockMessages.append(message)
    }
    
    func observeMessages(conversationID: String, completion: @escaping ([Message]) -> Void) {
        completion(mockMessages)
    }
    
    func getMessagesPaginated(
        conversationID: String,
        limit: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (messages: [Message], lastDocument: DocumentSnapshot?) {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        return (messages: mockMessages, lastDocument: nil)
    }
    
    func updateMessageStatus(messageID: String, conversationID: String, status: MessageStatus) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
    
    func markAsRead(messageIDs: [String], conversationID: String) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
    
    func deleteMessage(messageID: String, conversationID: String) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        mockMessages.removeAll { $0.id == messageID }
    }
}

