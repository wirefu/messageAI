//
//  NetworkMonitorTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class NetworkMonitorTests: XCTestCase {
    var sut: NetworkMonitor!
    
    override func setUp() {
        super.setUp()
        sut = NetworkMonitor.shared
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNetworkMonitorInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testIsConnectedProperty() {
        // Should have a value (true or false)
        XCTAssertNotNil(sut.isConnected)
    }
    
    func testConnectionTypeProperty() {
        // Should have a connection type
        XCTAssertNotNil(sut.connectionType)
    }
    
    // Note: Full network state testing requires network simulation
    // These tests verify basic functionality and initialization
}


