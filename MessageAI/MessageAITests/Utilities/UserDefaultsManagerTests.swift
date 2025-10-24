//
//  UserDefaultsManagerTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class UserDefaultsManagerTests: XCTestCase {
    
    var manager: UserDefaultsManager!
    let testKey = "test_key"
    
    override func setUp() {
        super.setUp()
        manager = UserDefaultsManager.shared
        // Clean up any existing test data
        manager.remove(forKey: testKey)
    }
    
    override func tearDown() {
        manager.remove(forKey: testKey)
        manager = nil
        super.tearDown()
    }
    
    // MARK: - String Tests
    
    func testSaveAndGetString() {
        // Given
        let testValue = "test string"
        
        // When
        manager.saveString(testValue, forKey: testKey)
        let retrieved = manager.getString(forKey: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Bool Tests
    
    func testSaveAndGetBool() {
        // Given
        let testValue = true
        
        // When
        manager.saveBool(testValue, forKey: testKey)
        let retrieved = manager.getBool(forKey: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Int Tests
    
    func testSaveAndGetInt() {
        // Given
        let testValue = 42
        
        // When
        manager.saveInt(testValue, forKey: testKey)
        let retrieved = manager.getInt(forKey: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Double Tests
    
    func testSaveAndGetDouble() {
        // Given
        let testValue = 3.14159
        
        // When
        manager.saveDouble(testValue, forKey: testKey)
        let retrieved = manager.getDouble(forKey: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testValue, accuracy: 0.00001)
    }
    
    // MARK: - Date Tests
    
    func testSaveAndGetDate() {
        // Given
        let testValue = Date()
        
        // When
        manager.saveDate(testValue, forKey: testKey)
        let retrieved = manager.getDate(forKey: testKey)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.timeIntervalSince1970, testValue.timeIntervalSince1970, accuracy: 1.0)
    }
    
    // MARK: - Codable Tests
    
    func testSaveAndRetrieveCodableObject() {
        // Given
        let testUser = User(
            id: "test-1",
            displayName: "Test User",
            email: "test@example.com"
        )
        
        // When
        manager.save(testUser, forKey: testKey)
        let retrieved = manager.retrieve(forKey: testKey, as: User.self)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, testUser.id)
        XCTAssertEqual(retrieved?.displayName, testUser.displayName)
        XCTAssertEqual(retrieved?.email, testUser.email)
    }
    
    // MARK: - Remove Tests
    
    func testRemove() {
        // Given
        manager.saveString("test", forKey: testKey)
        XCTAssertTrue(manager.exists(forKey: testKey))
        
        // When
        manager.remove(forKey: testKey)
        
        // Then
        XCTAssertFalse(manager.exists(forKey: testKey))
        XCTAssertNil(manager.getString(forKey: testKey))
    }
    
    // MARK: - Exists Tests
    
    func testExists() {
        // Given
        XCTAssertFalse(manager.exists(forKey: testKey))
        
        // When
        manager.saveString("test", forKey: testKey)
        
        // Then
        XCTAssertTrue(manager.exists(forKey: testKey))
    }
    
    // MARK: - App-Specific Tests
    
    func testHasCompletedOnboarding() {
        // Given
        XCTAssertFalse(manager.hasCompletedOnboarding)
        
        // When
        manager.hasCompletedOnboarding = true
        
        // Then
        XCTAssertTrue(manager.hasCompletedOnboarding)
    }
    
    func testLastSyncTimestamp() {
        // Given
        XCTAssertNil(manager.lastSyncTimestamp)
        
        // When
        let now = Date()
        manager.lastSyncTimestamp = now
        
        // Then
        XCTAssertNotNil(manager.lastSyncTimestamp)
        XCTAssertEqual(manager.lastSyncTimestamp?.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
    }
}

