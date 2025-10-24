//
//  AuthenticationUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
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
    
    func testCompleteSignUpFlow() {
        // Navigate to sign up
        app.buttons["Sign Up"].tap()
        
        // Wait for sign up screen
        XCTAssertTrue(app.staticTexts["Create Account"].waitForExistence(timeout: 2))
        
        // Fill in form
        let displayNameField = app.textFields["Your name"]
        displayNameField.tap()
        displayNameField.typeText("UI Test User")
        
        let emailField = app.textFields.matching(identifier: "your.email@company.com").firstMatch
        emailField.tap()
        emailField.typeText("uitest@example.com")
        
        let passwordField = app.secureTextFields["At least 8 characters"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        let confirmPasswordField = app.secureTextFields["Re-enter password"]
        confirmPasswordField.tap()
        confirmPasswordField.typeText("password123")
        
        // Tap create account button
        let createButton = app.buttons["Create Account"]
        XCTAssertTrue(createButton.isEnabled, "Create Account button should be enabled with valid input")
        createButton.tap()
        
        // Wait for navigation to Messages screen (with timeout for Firebase)
        let messagesTitle = app.navigationBars["Messages"]
        XCTAssertTrue(messagesTitle.waitForExistence(timeout: 10), "Should navigate to Messages screen after sign up")
        
        // Verify we're on the messages screen
        XCTAssertTrue(app.staticTexts["No Conversations"].exists || app.navigationBars["Messages"].exists)
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

