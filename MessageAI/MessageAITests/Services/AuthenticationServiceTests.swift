//
//  AuthenticationServiceTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!
    
    override func setUp() {
        super.setUp()
        sut = AuthenticationService.shared
    }
    
    override func tearDown() {
        try? sut.signOut()
        super.tearDown()
    }
    
    // MARK: - Validation Tests
    
    func testSignUpWithInvalidEmail() async {
        do {
            _ = try await sut.signUp(email: "invalid-email", password: "password123")
            XCTFail("Should throw invalid email error")
        } catch let error as AppError {
            XCTAssertEqual(error, .invalidEmail)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignUpWithWeakPassword() async {
        do {
            _ = try await sut.signUp(email: "test@example.com", password: "weak")
            XCTFail("Should throw weak password error")
        } catch let error as AppError {
            XCTAssertEqual(error, .weakPassword)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignInWithInvalidEmail() async {
        do {
            _ = try await sut.signIn(email: "invalid", password: "password123")
            XCTFail("Should throw invalid email error")
        } catch let error as AppError {
            XCTAssertEqual(error, .invalidEmail)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testSignInWithEmptyPassword() async {
        do {
            _ = try await sut.signIn(email: "test@example.com", password: "")
            XCTFail("Should throw invalid credentials error")
        } catch let error as AppError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testCurrentUserIDWhenNotAuthenticated() {
        try? sut.signOut()
        XCTAssertNil(sut.currentUserID)
    }
    
    func testIsAuthenticatedWhenNotSignedIn() {
        try? sut.signOut()
        XCTAssertFalse(sut.isAuthenticated)
    }
}


