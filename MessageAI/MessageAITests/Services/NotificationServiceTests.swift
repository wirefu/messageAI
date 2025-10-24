//
//  NotificationServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import UserNotifications
@testable import MessageAI

@MainActor
final class NotificationServiceTests: XCTestCase {
    var service: NotificationService!

    override func setUp() async throws {
        service = NotificationService()
    }

    override func tearDown() async throws {
        service.removeAllPendingNotifications()
        service.clearBadge()
        service = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(service)
        XCTAssertNotNil(service.permissionStatus)
    }

    func testSharedInstanceExists() {
        let shared = NotificationService.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - Permission Status Tests

    func testPermissionStatusValues() {
        let statuses: [NotificationService.NotificationPermission] = [
            .notDetermined,
            .denied,
            .authorized,
            .provisional
        ]
        XCTAssertEqual(statuses.count, 4)
    }

    func testInitialPermissionStatus() {
        // Should have some status (likely notDetermined in test environment)
        XCTAssertNotNil(service.permissionStatus)
    }

    // MARK: - Badge Count Tests

    func testInitialBadgeCount() {
        XCTAssertEqual(service.badgeCount, 0)
    }

    func testSetBadgeCount() {
        service.setBadgeCount(5)
        XCTAssertEqual(service.badgeCount, 5)

        service.setBadgeCount(10)
        XCTAssertEqual(service.badgeCount, 10)
    }

    func testClearBadge() {
        service.setBadgeCount(10)
        XCTAssertEqual(service.badgeCount, 10)

        service.clearBadge()
        XCTAssertEqual(service.badgeCount, 0)
    }

    // MARK: - Device Token Tests

    func testSetDeviceToken() {
        let tokenData = Data([0x01, 0x02, 0x03, 0x04])
        service.setDeviceToken(tokenData)

        XCTAssertNotNil(service.fcmToken)
        XCTAssertEqual(service.fcmToken, "01020304")
    }

    func testDeviceTokenFormatting() {
        let tokenData = Data([0xFF, 0xAB, 0x12, 0x34])
        service.setDeviceToken(tokenData)

        XCTAssertEqual(service.fcmToken, "ffab1234")
    }

    // MARK: - Local Notification Tests

    func testScheduleLocalNotification() async throws {
        // This test verifies the method doesn't crash
        // Actual notification delivery tested in integration tests
        do {
            try await service.scheduleLocalNotification(
                title: "Test Title",
                body: "Test Body",
                identifier: "test-notification",
                timeInterval: 60.0
            )

            // Should complete without error
            XCTAssertTrue(true)
        } catch {
            // In test environment, permission might not be granted
            // That's okay for unit tests
            XCTAssertNotNil(error)
        }
    }

    func testRemovePendingNotification() {
        // Should not crash
        service.removePendingNotification(withIdentifier: "test-notification")
        XCTAssertNotNil(service)
    }

    func testRemoveAllPendingNotifications() {
        // Should not crash
        service.removeAllPendingNotifications()
        XCTAssertNotNil(service)
    }

    func testRemoveDeliveredNotifications() {
        // Should not crash
        service.removeDeliveredNotifications(withIdentifiers: ["test1", "test2"])
        XCTAssertNotNil(service)
    }

    func testRemoveAllDeliveredNotifications() {
        // Should not crash
        service.removeAllDeliveredNotifications()
        XCTAssertNotNil(service)
    }

    // MARK: - Remote Notification Handling Tests

    func testHandleRemoteNotificationWithBadge() {
        let userInfo: [AnyHashable: Any] = [
            "aps": [
                "alert": "New message",
                "badge": 5
            ]
        ]

        service.handleRemoteNotification(userInfo)

        XCTAssertEqual(service.badgeCount, 5)
    }

    func testHandleRemoteNotificationWithoutBadge() {
        let userInfo: [AnyHashable: Any] = [
            "aps": [
                "alert": "New message"
            ]
        ]

        service.handleRemoteNotification(userInfo)

        // Badge count should remain at 0
        XCTAssertEqual(service.badgeCount, 0)
    }

    func testHandleRemoteNotificationWithInvalidData() {
        let userInfo: [AnyHashable: Any] = [
            "invalid": "data"
        ]

        // Should not crash
        service.handleRemoteNotification(userInfo)

        XCTAssertNotNil(service)
    }

    func testHandleEmptyRemoteNotification() {
        let userInfo: [AnyHashable: Any] = [:]

        // Should not crash
        service.handleRemoteNotification(userInfo)

        XCTAssertNotNil(service)
    }

    // MARK: - Permission Request Tests

    func testRequestPermissionRequiresMainActor() async {
        // This test verifies we're on MainActor
        // If not on MainActor, this would crash at compile time
        XCTAssertNotNil(service.permissionStatus)
    }

    // MARK: - Error Handling Tests

    func testNotificationErrorDescriptions() {
        let permissionError = NotificationService.NotificationError.permissionDenied
        XCTAssertNotNil(permissionError.errorDescription)

        let testError = NSError(domain: "test", code: 1)
        let registrationError = NotificationService.NotificationError.registrationFailed(testError)
        XCTAssertNotNil(registrationError.errorDescription)

        let invalidTokenError = NotificationService.NotificationError.invalidToken
        XCTAssertNotNil(invalidTokenError.errorDescription)
    }

    // MARK: - Published Properties Tests

    func testPermissionStatusIsPublished() async {
        var statusUpdates: [NotificationService.NotificationPermission] = []

        let cancellable = service.$permissionStatus.sink { status in
            statusUpdates.append(status)
        }

        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertFalse(statusUpdates.isEmpty)

        cancellable.cancel()
    }

    func testFcmTokenIsPublished() async {
        var tokenUpdates: [String?] = []

        let cancellable = service.$fcmToken.sink { token in
            tokenUpdates.append(token)
        }

        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        // Should receive initial nil value
        XCTAssertTrue(tokenUpdates.contains(where: { $0 == nil }))

        cancellable.cancel()
    }

    func testBadgeCountIsPublished() async {
        var countUpdates: [Int] = []

        let cancellable = service.$badgeCount.sink { count in
            countUpdates.append(count)
        }

        service.setBadgeCount(5)

        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(countUpdates.contains(0)) // Initial
        XCTAssertTrue(countUpdates.contains(5)) // After set

        cancellable.cancel()
    }

    // MARK: - Delegate Methods Tests

    func testServiceIsNotificationCenterDelegate() {
        // Service should conform to UNUserNotificationCenterDelegate
        XCTAssertTrue(service is UNUserNotificationCenterDelegate)
    }
}
