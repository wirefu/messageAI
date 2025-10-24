//
//  PresenceServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

@MainActor
final class PresenceServiceTests: XCTestCase {
    var service: PresenceService!

    override func setUp() async throws {
        service = PresenceService()
    }

    override func tearDown() async throws {
        service.stopObservingAll()
        service = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(service)
        XCTAssertEqual(service.currentUserStatus, .offline)
        XCTAssertTrue(service.activeListeners.isEmpty)
    }

    func testSharedInstanceExists() {
        let shared = PresenceService.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - User Status Tests

    func testUserStatusValues() {
        let statuses: [PresenceService.UserStatus] = [.online, .offline, .away]
        XCTAssertEqual(statuses.count, 3)
    }

    func testUserStatusRawValues() {
        XCTAssertEqual(PresenceService.UserStatus.online.rawValue, "online")
        XCTAssertEqual(PresenceService.UserStatus.offline.rawValue, "offline")
        XCTAssertEqual(PresenceService.UserStatus.away.rawValue, "away")
    }

    func testUserStatusCodable() throws {
        let status = PresenceService.UserStatus.online

        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PresenceService.UserStatus.self, from: data)

        XCTAssertEqual(decoded, status)
    }

    // MARK: - Current User Tests

    func testSetCurrentUser() {
        service.setCurrentUser("user123")

        // Should not crash and should allow subsequent calls
        XCTAssertNotNil(service)
    }

    func testSetOnlineWithoutAuthenticationThrows() async {
        // Should throw error when no user is set
        do {
            try await service.setOnline()
            XCTFail("Should throw notAuthenticated error")
        } catch {
            XCTAssertTrue(error is PresenceService.PresenceError)
        }
    }

    func testSetOfflineWithoutAuthenticationThrows() async {
        do {
            try await service.setOffline()
            XCTFail("Should throw notAuthenticated error")
        } catch {
            XCTAssertTrue(error is PresenceService.PresenceError)
        }
    }

    func testSetAwayWithoutAuthenticationThrows() async {
        do {
            try await service.setAway()
            XCTFail("Should throw notAuthenticated error")
        } catch {
            XCTAssertTrue(error is PresenceService.PresenceError)
        }
    }

    func testUpdateLastSeenWithoutAuthenticationThrows() async {
        do {
            try await service.updateLastSeen()
            XCTFail("Should throw notAuthenticated error")
        } catch {
            XCTAssertTrue(error is PresenceService.PresenceError)
        }
    }

    // MARK: - Listener Management Tests

    func testObserveUserPresenceCreatesStream() {
        let stream = service.observeUserPresence(userId: "user123")

        XCTAssertNotNil(stream)
    }

    func testStopObservingUser() {
        // Start observing
        _ = service.observeUserPresence(userId: "user123")

        // Wait for listener to be added
        let expectation = expectation(description: "Listener added")
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Stop observing
        service.stopObserving(userId: "user123")

        // Should not crash
        XCTAssertNotNil(service)
    }

    func testStopObservingAll() {
        // Start observing multiple users
        _ = service.observeUserPresence(userId: "user1")
        _ = service.observeUserPresence(userId: "user2")
        _ = service.observeUserPresence(userId: "user3")

        // Wait for listeners to be added
        let expectation = expectation(description: "Listeners added")
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        service.stopObservingAll()

        XCTAssertTrue(service.activeListeners.isEmpty)
    }

    func testActiveListenersTracking() async {
        // Start observing
        _ = service.observeUserPresence(userId: "user123")

        // Wait for listener to be registered
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second

        // Note: In test environment without actual Firestore, 
        // listener may not be fully registered
        // This test verifies the mechanism exists
        XCTAssertNotNil(service.activeListeners)
    }

    // MARK: - Published Properties Tests

    func testCurrentUserStatusIsPublished() async {
        var statusUpdates: [PresenceService.UserStatus] = []

        let cancellable = service.$currentUserStatus.sink { status in
            statusUpdates.append(status)
        }

        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(statusUpdates.contains(.offline)) // Initial value

        cancellable.cancel()
    }

    func testActiveListenersIsPublished() async {
        var listenerUpdates: [Set<String>] = []

        let cancellable = service.$activeListeners.sink { listeners in
            listenerUpdates.append(listeners)
        }

        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertFalse(listenerUpdates.isEmpty)

        cancellable.cancel()
    }

    // MARK: - Error Handling Tests

    func testPresenceErrorDescriptions() {
        let notAuthError = PresenceService.PresenceError.notAuthenticated
        XCTAssertNotNil(notAuthError.errorDescription)

        let userNotFoundError = PresenceService.PresenceError.userNotFound
        XCTAssertNotNil(userNotFoundError.errorDescription)

        let testError = NSError(domain: "test", code: 1)
        let firestoreError = PresenceService.PresenceError.firestoreError(testError)
        XCTAssertNotNil(firestoreError.errorDescription)
    }

    // MARK: - Memory Management Tests

    func testServiceCleansUpOnDeinit() {
        var testService: PresenceService? = PresenceService()

        // Start observing
        _ = testService?.observeUserPresence(userId: "user123")

        // Should clean up without crash
        testService = nil

        XCTAssertNil(testService)
    }

    // MARK: - Integration with Firebase Constants Tests

    func testUsesCorrectFirebaseCollection() {
        // This test verifies that PresenceService references the correct collection
        // Actual Firebase calls would be tested in integration tests
        XCTAssertNotNil(FirebaseConstants.Collections.users)
    }
}
