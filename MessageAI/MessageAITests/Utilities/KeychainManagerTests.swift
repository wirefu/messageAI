//
//  KeychainManagerTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class KeychainManagerTests: XCTestCase {
    
    var manager: KeychainManager!
    let testKey = "test_keychain_key"
    
    override func setUp() {
        super.setUp()
        manager = KeychainManager.shared
        // Clean up any existing test data
        manager.delete(forKey: testKey)
    }
    
    override func tearDown() {
        manager.delete(forKey: testKey)
        manager = nil
        super.tearDown()
    }
    
    // MARK: - String Tests
    
    func testSaveAndGetString() {
        // Given
        let testValue = "test_secret_value"
        
        // When
        let saveResult = manager.save(testValue, forKey: testKey)
        let retrieved = manager.getString(forKey: testKey)
        
        // Then
        XCTAssertTrue(saveResult)
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Data Tests
    
    func testSaveAndGetData() {
        // Given
        let testValue = "test data".data(using: .utf8)!
        
        // When
        let saveResult = manager.save(testValue, forKey: testKey)
        let retrieved = manager.getData(forKey: testKey)
        
        // Then
        XCTAssertTrue(saveResult)
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Codable Tests
    
    func testSaveAndRetrieveCodableObject() {
        // Given
        struct TestCredentials: Codable, Equatable {
            let username: String
            let password: String
        }
        let testValue = TestCredentials(username: "test", password: "secret")
        
        // When
        let saveResult = manager.save(testValue, forKey: testKey)
        let retrieved = manager.retrieve(forKey: testKey, as: TestCredentials.self)
        
        // Then
        XCTAssertTrue(saveResult)
        XCTAssertEqual(retrieved, testValue)
    }
    
    // MARK: - Update Tests
    
    func testUpdateString() {
        // Given
        manager.save("original", forKey: testKey)
        
        // When
        let updateResult = manager.update("updated", forKey: testKey)
        let retrieved = manager.getString(forKey: testKey)
        
        // Then
        XCTAssertTrue(updateResult)
        XCTAssertEqual(retrieved, "updated")
    }
    
    func testUpdateNonExistentItem() {
        // Given
        XCTAssertFalse(manager.exists(forKey: testKey))
        
        // When
        let updateResult = manager.update("new_value", forKey: testKey)
        
        // Then
        XCTAssertTrue(updateResult) // Should save as new
        XCTAssertEqual(manager.getString(forKey: testKey), "new_value")
    }
    
    // MARK: - Delete Tests
    
    func testDelete() {
        // Given
        manager.save("test", forKey: testKey)
        XCTAssertTrue(manager.exists(forKey: testKey))
        
        // When
        let deleteResult = manager.delete(forKey: testKey)
        
        // Then
        XCTAssertTrue(deleteResult)
        XCTAssertFalse(manager.exists(forKey: testKey))
    }
    
    func testDeleteNonExistentItem() {
        // Given
        XCTAssertFalse(manager.exists(forKey: testKey))
        
        // When
        let deleteResult = manager.delete(forKey: testKey)
        
        // Then
        XCTAssertTrue(deleteResult) // Should succeed even if item doesn't exist
    }
    
    // MARK: - Exists Tests
    
    func testExists() {
        // Given
        XCTAssertFalse(manager.exists(forKey: testKey))
        
        // When
        manager.save("test", forKey: testKey)
        
        // Then
        XCTAssertTrue(manager.exists(forKey: testKey))
    }
    
    // MARK: - App-Specific Tests
    
    func testAuthToken() {
        // Given
        XCTAssertNil(manager.authToken)
        
        // When
        manager.authToken = "test_auth_token_12345"
        
        // Then
        XCTAssertEqual(manager.authToken, "test_auth_token_12345")
        
        // Clean up
        manager.authToken = nil
        XCTAssertNil(manager.authToken)
    }
    
    func testRefreshToken() {
        // Given
        XCTAssertNil(manager.refreshToken)
        
        // When
        manager.refreshToken = "test_refresh_token_67890"
        
        // Then
        XCTAssertEqual(manager.refreshToken, "test_refresh_token_67890")
        
        // Clean up
        manager.refreshToken = nil
        XCTAssertNil(manager.refreshToken)
    }
}

