//
//  AuthViewModelTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

@MainActor
final class AuthViewModelTests: XCTestCase {
    var sut: AuthViewModel!
    var mockUserRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        sut = AuthViewModel(userRepository: mockUserRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockUserRepository = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testClearError() {
        sut.error = .invalidCredentials
        XCTAssertNotNil(sut.error)
        
        sut.clearError()
        XCTAssertNil(sut.error)
    }
}

// MARK: - Mock User Repository

class MockUserRepository: UserRepositoryProtocol {
    var mockUsers: [String: User] = [:]
    var shouldFail = false
    
    func createUser(_ user: User) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        mockUsers[user.id] = user
    }
    
    func getUser(id: String) async throws -> User? {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        return mockUsers[id]
    }
    
    func updateUser(_ user: User) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        mockUsers[user.id] = user
    }
    
    func observeUser(id: String, completion: @escaping (User?) -> Void) {
        completion(mockUsers[id])
    }
    
    func setOnlineStatus(userID: String, isOnline: Bool) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        if var user = mockUsers[userID] {
            user.isOnline = isOnline
            mockUsers[userID] = user
        }
    }
    
    func updateLastSeen(userID: String) async throws {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
    }
    
    func getAllUsers(excludingUserID: String) async throws -> [User] {
        if shouldFail {
            throw AppError.firestoreError("Mock error")
        }
        return Array(mockUsers.values).filter { $0.id != excludingUserID }
    }
}

