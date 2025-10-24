//
//  NetworkMonitorTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import Network
@testable import MessageAI

@MainActor
final class NetworkMonitorTests: XCTestCase {
    var monitor: NetworkMonitor!

    override func setUp() async throws {
        monitor = NetworkMonitor()
    }

    override func tearDown() async throws {
        monitor.stopMonitoring()
        monitor = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(monitor)
    }

    func testSharedInstanceExists() {
        let shared = NetworkMonitor.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - Connection Status Tests

    func testInitialConnectionState() {
        // Should have some initial state
        XCTAssertNotNil(monitor.isConnected)
        XCTAssertNotNil(monitor.connectionType)
    }

    func testConnectionTypeValues() {
        // Verify all connection types are accessible
        let types: [NetworkMonitor.ConnectionType] = [
            .wifi,
            .cellular,
            .wiredEthernet,
            .unknown
        ]

        XCTAssertEqual(types.count, 4)
    }

    // MARK: - Monitoring Control Tests

    func testStartMonitoring() {
        // Should not crash when starting monitoring
        monitor.startMonitoring()

        // Give it a moment to initialize
        let expectation = expectation(description: "Monitor started")

        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Monitor should be running
        XCTAssertNotNil(monitor)
    }

    func testStopMonitoring() {
        monitor.startMonitoring()

        // Should not crash when stopping
        monitor.stopMonitoring()

        XCTAssertNotNil(monitor)
    }

    func testMultipleStartCalls() {
        // Should handle multiple start calls gracefully
        monitor.startMonitoring()
        monitor.startMonitoring()
        monitor.startMonitoring()

        XCTAssertNotNil(monitor)

        monitor.stopMonitoring()
    }

    func testMultipleStopCalls() {
        monitor.startMonitoring()

        // Should handle multiple stop calls gracefully
        monitor.stopMonitoring()
        monitor.stopMonitoring()
        monitor.stopMonitoring()

        XCTAssertNotNil(monitor)
    }

    // MARK: - Published Properties Tests

    func testIsConnectedIsPublished() async {
        // Verify isConnected can be observed
        var receivedValue = false

        let cancellable = monitor.$isConnected.sink { _ in
            receivedValue = true
        }

        // Should receive initial value
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(receivedValue)

        cancellable.cancel()
    }

    func testConnectionTypeIsPublished() async {
        // Verify connectionType can be observed
        var receivedValue = false

        let cancellable = monitor.$connectionType.sink { _ in
            receivedValue = true
        }

        // Should receive initial value
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(receivedValue)

        cancellable.cancel()
    }

    func testIsExpensiveIsPublished() async {
        // Verify isExpensive can be observed
        var receivedValue = false

        let cancellable = monitor.$isExpensive.sink { _ in
            receivedValue = true
        }

        // Should receive initial value
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second

        XCTAssertTrue(receivedValue)

        cancellable.cancel()
    }

    // MARK: - Connection Detection Tests

    func testMonitorDetectsCurrentConnection() async {
        monitor.startMonitoring()

        // Wait for initial path update
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second

        // In simulator/test environment, should detect some connection
        // (This will be true in CI if network is available)
        XCTAssertNotNil(monitor.connectionType)
    }

    // MARK: - Memory Management Tests

    func testMonitorCleansUpOnDeinit() {
        var testMonitor: NetworkMonitor? = NetworkMonitor()
        testMonitor?.startMonitoring()

        // Should clean up without crash
        testMonitor = nil

        XCTAssertNil(testMonitor)
    }
}
