//
//  OfflineQueueServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class OfflineQueueServiceTests: XCTestCase {
    var sut: OfflineQueueService!
    
    override func setUp() {
        super.setUp()
        sut = OfflineQueueService.shared
        sut.clearQueue()
    }
    
    override func tearDown() {
        sut.clearQueue()
        super.tearDown()
    }
    
    func testEnqueueMessage() {
        let message = Message(
            id: "msg1",
            conversationID: "conv1",
            senderID: "user1",
            content: "Test",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        sut.enqueue(message)
        
        XCTAssertFalse(sut.isEmpty())
        XCTAssertEqual(sut.count(), 1)
    }
    
    func testDequeueAll() {
        let message1 = Message(
            id: "msg1",
            conversationID: "conv1",
            senderID: "user1",
            content: "Test 1",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        let message2 = Message(
            id: "msg2",
            conversationID: "conv1",
            senderID: "user1",
            content: "Test 2",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        sut.enqueue(message1)
        sut.enqueue(message2)
        
        let dequeued = sut.dequeueAll()
        
        XCTAssertEqual(dequeued.count, 2)
        XCTAssertTrue(sut.isEmpty())
    }
    
    func testIsEmpty() {
        XCTAssertTrue(sut.isEmpty())
        
        let message = Message(
            id: "msg1",
            conversationID: "conv1",
            senderID: "user1",
            content: "Test",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        sut.enqueue(message)
        XCTAssertFalse(sut.isEmpty())
    }
    
    func testClearQueue() {
        let message = Message(
            id: "msg1",
            conversationID: "conv1",
            senderID: "user1",
            content: "Test",
            timestamp: Date(),
            deliveredAt: nil,
            readAt: nil,
            status: .sending,
            aiSuggestions: nil
        )
        
        sut.enqueue(message)
        XCTAssertFalse(sut.isEmpty())
        
        sut.clearQueue()
        XCTAssertTrue(sut.isEmpty())
    }
    
    func testQueueCount() {
        XCTAssertEqual(sut.count(), 0)
        
        for i in 1...5 {
            let message = Message(
                id: "msg\(i)",
                conversationID: "conv1",
                senderID: "user1",
                content: "Test \(i)",
                timestamp: Date(),
                deliveredAt: nil,
                readAt: nil,
                status: .sending,
                aiSuggestions: nil
            )
            sut.enqueue(message)
        }
        
        XCTAssertEqual(sut.count(), 5)
    }
}

