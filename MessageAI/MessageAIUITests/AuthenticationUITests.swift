//
//  AuthenticationUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

@MainActor
final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    func testLoginViewDisplays() {
        XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
        XCTAssertTrue(app.staticTexts["Sign in to continue messaging"].exists)
        XCTAssertTrue(app.buttons["Login"].exists)
    }
    
    func testNavigateToSignUp() {
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Create Account"].exists)
    }
    
    func testNavigateBackToLogin() {
        app.buttons["Sign Up"].tap()
        app.buttons["Login"].tap()
        XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
    }
    
    func testSignUpViewDisplays() {
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Create Account"].exists)
        XCTAssertTrue(app.staticTexts["Join your team on MessengerAI"].exists)
        XCTAssertTrue(app.buttons["Create Account"].exists)
    }
    
    func testLoginButtonDisabledWithEmptyFields() {
        let loginButton = app.buttons["Login"]
        XCTAssertFalse(loginButton.isEnabled)
    }
    
    func testCompleteSignUpFlow() async throws {
        // Navigate to sign up
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Create Account"].waitForExistence(timeout: 2))
        
        // Fill out sign-up form
        app.textFields["Your name"].tap()
        app.textFields["Your name"].typeText("Test User")
        
        app.textFields.matching(identifier: "your.email@company.com").firstMatch.tap()
        app.textFields.matching(identifier: "your.email@company.com").firstMatch.typeText("test@example.com")
        
        app.secureTextFields["At least 8 characters"].tap()
        app.secureTextFields["At least 8 characters"].typeText("password123")
        
        app.secureTextFields["Re-enter password"].tap()
        app.secureTextFields["Re-enter password"].typeText("password123")
        
        // Submit form
        let createButton = app.buttons["Create Account"]
        XCTAssertTrue(createButton.isEnabled, "Create Account button should be enabled with valid input")
        createButton.tap()
        
        // Wait for navigation to Messages screen (with timeout for Firebase)
        XCTAssertTrue(app.navigationBars["Messages"].waitForExistence(timeout: 10), "Should navigate to Messages screen after sign up")
    }
    
    func testLoginWithTestAccount() {
        // Fill in login form
        let emailField = app.textFields["Enter your email"]
        emailField.tap()
        emailField.typeText("test@messengerai.com")
        
        let passwordField = app.secureTextFields["Enter your password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Tap login
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.isEnabled)
        loginButton.tap()
        
        // Wait for Messages screen
        let messagesTitle = app.navigationBars["Messages"]
        XCTAssertTrue(messagesTitle.waitForExistence(timeout: 10), "Should navigate to Messages after login")
    }
}

