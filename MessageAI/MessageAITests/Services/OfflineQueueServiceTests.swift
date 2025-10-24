//
//  OfflineQueueServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

@MainActor
final class OfflineQueueServiceTests: XCTestCase {
    var service: OfflineQueueService!
    var testUserDefaults: UserDefaults!

    override func setUp() async throws {
        // Use a unique suite name for testing
        testUserDefaults = UserDefaults(suiteName: "com.messageai.test.\(UUID().uuidString)")!
        service = OfflineQueueService(userDefaults: testUserDefaults)
    }

    override func tearDown() async throws {
        service.clearQueue()
        testUserDefaults.removeSuite(named: testUserDefaults.suiteName!)
        service = nil
        testUserDefaults = nil
    }

    // MARK: - Test Helpers

    struct TestOperation: QueueableOperation {
        let id: String
        let timestamp: Date
        let operationType: String = "TestOperation"
        let message: String
    }

    struct AnotherOperation: QueueableOperation {
        let id: String
        let timestamp: Date
        let operationType: String = "AnotherOperation"
        let value: Int
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(service)
        XCTAssertEqual(service.pendingCount, 0)
        XCTAssertFalse(service.isProcessing)
    }

    func testSharedInstanceExists() {
        let shared = OfflineQueueService.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - Enqueue Tests

    func testEnqueueSingleOperation() throws {
        let operation = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )

        try service.enqueue(operation)

        XCTAssertEqual(service.pendingCount, 1)
    }

    func testEnqueueMultipleOperations() throws {
        for index in 1...5 {
            let operation = TestOperation(
                id: "test\(index)",
                timestamp: Date(),
                message: "Message \(index)"
            )
            try service.enqueue(operation)
        }

        XCTAssertEqual(service.pendingCount, 5)
    }

    func testEnqueueDifferentTypes() throws {
        let testOp = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )
        let anotherOp = AnotherOperation(
            id: "another1",
            timestamp: Date(),
            value: 42
        )

        try service.enqueue(testOp)
        try service.enqueue(anotherOp)

        XCTAssertEqual(service.pendingCount, 2)
    }

    // MARK: - Dequeue Tests

    func testDequeueOperation() throws {
        let operation = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )

        try service.enqueue(operation)

        let dequeued = try service.dequeue(ofType: TestOperation.self)

        XCTAssertEqual(dequeued.id, operation.id)
        XCTAssertEqual(dequeued.message, operation.message)
        XCTAssertEqual(service.pendingCount, 0)
    }

    func testDequeueFromEmptyQueue() {
        XCTAssertThrowsError(try service.dequeue(ofType: TestOperation.self)) { error in
            XCTAssertTrue(error is OfflineQueueService.QueueError)
        }
    }

    func testDequeueWrongType() throws {
        let operation = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )

        try service.enqueue(operation)

        XCTAssertThrowsError(try service.dequeue(ofType: AnotherOperation.self)) { error in
            XCTAssertTrue(error is OfflineQueueService.QueueError)
        }

        // Original operation should still be in queue
        XCTAssertEqual(service.pendingCount, 1)
    }

    func testDequeueOrder() throws {
        let op1 = TestOperation(id: "1", timestamp: Date(), message: "First")
        let op2 = TestOperation(id: "2", timestamp: Date(), message: "Second")
        let op3 = TestOperation(id: "3", timestamp: Date(), message: "Third")

        try service.enqueue(op1)
        try service.enqueue(op2)
        try service.enqueue(op3)

        let first = try service.dequeue(ofType: TestOperation.self)
        XCTAssertEqual(first.id, "1")

        let second = try service.dequeue(ofType: TestOperation.self)
        XCTAssertEqual(second.id, "2")

        let third = try service.dequeue(ofType: TestOperation.self)
        XCTAssertEqual(third.id, "3")

        XCTAssertEqual(service.pendingCount, 0)
    }

    // MARK: - Peek Tests

    func testPeekOperation() throws {
        let operation = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )

        try service.enqueue(operation)

        let peeked = try service.peek(ofType: TestOperation.self)

        XCTAssertEqual(peeked.id, operation.id)
        XCTAssertEqual(peeked.message, operation.message)

        // Should not remove from queue
        XCTAssertEqual(service.pendingCount, 1)
    }

    func testPeekEmptyQueue() {
        XCTAssertThrowsError(try service.peek(ofType: TestOperation.self))
    }

    // MARK: - Get All Operations Tests

    func testGetAllOperations() throws {
        for index in 1...3 {
            let operation = TestOperation(
                id: "test\(index)",
                timestamp: Date(),
                message: "Message \(index)"
            )
            try service.enqueue(operation)
        }

        let operations = service.getAllOperations(ofType: TestOperation.self)

        XCTAssertEqual(operations.count, 3)
        XCTAssertEqual(operations[0].id, "test1")
        XCTAssertEqual(operations[1].id, "test2")
        XCTAssertEqual(operations[2].id, "test3")
    }

    func testGetAllOperationsFiltersTypes() throws {
        let testOp = TestOperation(id: "test1", timestamp: Date(), message: "Hello")
        let anotherOp = AnotherOperation(id: "another1", timestamp: Date(), value: 42)

        try service.enqueue(testOp)
        try service.enqueue(anotherOp)

        let testOps = service.getAllOperations(ofType: TestOperation.self)
        let anotherOps = service.getAllOperations(ofType: AnotherOperation.self)

        XCTAssertEqual(testOps.count, 1)
        XCTAssertEqual(anotherOps.count, 1)
    }

    func testGetAllOperationsEmptyQueue() {
        let operations = service.getAllOperations(ofType: TestOperation.self)
        XCTAssertTrue(operations.isEmpty)
    }

    // MARK: - Remove Operation Tests

    func testRemoveOperationById() throws {
        let op1 = TestOperation(id: "1", timestamp: Date(), message: "First")
        let op2 = TestOperation(id: "2", timestamp: Date(), message: "Second")
        let op3 = TestOperation(id: "3", timestamp: Date(), message: "Third")

        try service.enqueue(op1)
        try service.enqueue(op2)
        try service.enqueue(op3)

        service.removeOperation(withId: "2")

        XCTAssertEqual(service.pendingCount, 2)

        let remaining = service.getAllOperations(ofType: TestOperation.self)
        XCTAssertEqual(remaining.count, 2)
        XCTAssertEqual(remaining[0].id, "1")
        XCTAssertEqual(remaining[1].id, "3")
    }

    func testRemoveNonExistentOperation() throws {
        let operation = TestOperation(id: "test1", timestamp: Date(), message: "Hello")
        try service.enqueue(operation)

        service.removeOperation(withId: "nonexistent")

        XCTAssertEqual(service.pendingCount, 1)
    }

    // MARK: - Clear Queue Tests

    func testClearQueue() throws {
        for index in 1...5 {
            let operation = TestOperation(
                id: "test\(index)",
                timestamp: Date(),
                message: "Message \(index)"
            )
            try service.enqueue(operation)
        }

        XCTAssertEqual(service.pendingCount, 5)

        service.clearQueue()

        XCTAssertEqual(service.pendingCount, 0)
    }

    func testClearOperationsOfType() throws {
        let testOp1 = TestOperation(id: "test1", timestamp: Date(), message: "Hello")
        let testOp2 = TestOperation(id: "test2", timestamp: Date(), message: "World")
        let anotherOp = AnotherOperation(id: "another1", timestamp: Date(), value: 42)

        try service.enqueue(testOp1)
        try service.enqueue(anotherOp)
        try service.enqueue(testOp2)

        XCTAssertEqual(service.pendingCount, 3)

        service.clearOperations(ofType: TestOperation.self)

        XCTAssertEqual(service.pendingCount, 1)

        let remaining = service.getAllOperations(ofType: AnotherOperation.self)
        XCTAssertEqual(remaining.count, 1)
    }

    // MARK: - Persistence Tests

    func testQueuePersistsAcrossInstances() throws {
        let operation = TestOperation(
            id: "test1",
            timestamp: Date(),
            message: "Hello"
        )

        try service.enqueue(operation)

        // Create new instance with same UserDefaults
        let newService = OfflineQueueService(userDefaults: testUserDefaults)

        XCTAssertEqual(newService.pendingCount, 1)

        let retrieved = try newService.dequeue(ofType: TestOperation.self)
        XCTAssertEqual(retrieved.id, operation.id)
        XCTAssertEqual(retrieved.message, operation.message)
    }

    // MARK: - Published Properties Tests

    func testPendingCountIsPublished() async throws {
        var countUpdates: [Int] = []

        let cancellable = service.$pendingCount.sink { count in
            countUpdates.append(count)
        }

        let operation = TestOperation(id: "test1", timestamp: Date(), message: "Hello")
        try service.enqueue(operation)

        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(countUpdates.contains(0)) // Initial
        XCTAssertTrue(countUpdates.contains(1)) // After enqueue

        cancellable.cancel()
    }
}
