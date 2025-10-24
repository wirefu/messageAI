//
//  MessagingEndToEndTests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

/// End-to-end tests for complete messaging flow
final class MessagingEndToEndTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Complete User Journey
    
    func testCompleteMessagingJourney() {
        // Test 1: Sign Up
        signUpNewUser(name: "E2E Test User", email: "e2etest@example.com", password: "password123")
        
        // Test 2: Verify Messages Screen
        verifyMessagesScreenAppears()
        
        // Test 3: Sign Out
        signOut()
        
        // Test 4: Login
        login(email: "e2etest@example.com", password: "password123")
        
        // Test 5: Verify back on Messages screen
        verifyMessagesScreenAppears()
    }
    
    func testSignUpAndViewEmptyConversations() {
        // Sign up
        signUpNewUser(name: "Test User 2", email: "test2@example.com", password: "password123")
        
        // Should see empty conversations
        XCTAssertTrue(app.staticTexts["No Conversations"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Start a conversation to begin messaging with your team"].exists)
        XCTAssertTrue(app.buttons["New Conversation"].exists)
    }
    
    func testNavigateToNewConversationSheet() {
        // Login first
        login(email: "test@messengerai.com", password: "password123")
        
        // Wait for Messages screen
        XCTAssertTrue(app.navigationBars["Messages"].waitForExistence(timeout: 10))
        
        // Wait for screen to stabilize
        sleep(2)
        
        // Tap new conversation button
        let newConversationButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'square.and.pencil'")).firstMatch
        if newConversationButton.exists && newConversationButton.isHittable {
            newConversationButton.tap()
            
            // Verify sheet appears
            XCTAssertTrue(app.navigationBars["New Conversation"].waitForExistence(timeout: 5))
            
            // Cancel and go back - ensure we're back to Messages
            app.buttons["Cancel"].tap()
            
            // Wait for navigation back
            XCTAssertTrue(app.navigationBars["Messages"].waitForExistence(timeout: 5))
        }
    }
    
    func testProfileMenuAndSignOut() {
        // Login
        login(email: "test@messengerai.com", password: "password123")
        
        // Wait for Messages screen
        XCTAssertTrue(app.navigationBars["Messages"].waitForExistence(timeout: 10))
        
        // Tap profile button
        let profileButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'person.circle'")).firstMatch
        if profileButton.exists {
            profileButton.tap()
            
            // Wait for menu
            sleep(1)
            
            // Tap Sign Out
            app.buttons["Sign Out"].tap()
            
            // Should return to login
            XCTAssertTrue(app.staticTexts["Welcome Back"].waitForExistence(timeout: 5))
        }
    }
    
    // MARK: - Helper Methods
    
    private func signUpNewUser(name: String, email: String, password: String) {
        // Check if already on sign up screen
        if !app.staticTexts["Create Account"].exists {
            // Navigate to sign up
            if app.buttons["Sign Up"].exists {
                app.buttons["Sign Up"].tap()
            }
        }
        
        // Wait for sign up screen
        XCTAssertTrue(app.staticTexts["Create Account"].waitForExistence(timeout: 5))
        
        // Clear any existing text first
        let displayNameField = app.textFields["Your name"]
        if displayNameField.exists {
            displayNameField.tap()
            displayNameField.press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            displayNameField.typeText(name)
        }
        
        let emailField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'company.com'")).firstMatch
        if emailField.exists {
            emailField.tap()
            emailField.press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            emailField.typeText(email)
        }
        
        let passwordFields = app.secureTextFields.allElementsBoundByIndex
        if passwordFields.count >= 2 {
            passwordFields[0].tap()
            passwordFields[0].press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            passwordFields[0].typeText(password)
            
            passwordFields[1].tap()
            passwordFields[1].press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            passwordFields[1].typeText(password)
        }
        
        // Wait for form to be ready
        sleep(1)
        
        // Tap create account
        let createButton = app.buttons["Create Account"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        
        // Wait for button to be enabled
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: createButton, handler: nil)
        waitForExpectations(timeout: 5)
        
        createButton.tap()
        
        // Wait for navigation to Messages with longer timeout
        XCTAssertTrue(
            app.navigationBars["Messages"].waitForExistence(timeout: 20),
            "Should navigate to Messages screen after sign up"
        )
        
        // Wait for screen to stabilize
        sleep(2)
    }
    
    private func login(email: String, password: String) {
        // Should be on login screen
        XCTAssertTrue(app.staticTexts["Welcome Back"].waitForExistence(timeout: 5))
        
        // Clear and fill in email
        let emailField = app.textFields["Enter your email"]
        if emailField.exists {
            emailField.tap()
            emailField.press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            emailField.typeText(email)
        }
        
        // Clear and fill in password
        let passwordField = app.secureTextFields["Enter your password"]
        if passwordField.exists {
            passwordField.tap()
            passwordField.press(forDuration: 1.0)
            app.menuItems["Select All"].tap()
            passwordField.typeText(password)
        }
        
        // Wait for form to be ready
        sleep(1)
        
        // Tap login
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.isEnabled)
        loginButton.tap()
        
        // Wait for Messages screen with longer timeout
        XCTAssertTrue(
            app.navigationBars["Messages"].waitForExistence(timeout: 20),
            "Should navigate to Messages screen after login"
        )
        
        // Wait for screen to stabilize
        sleep(2)
    }
    
    private func signOut() {
        // Wait for screen to be stable
        sleep(2)
        
        // Tap profile button (person icon)
        let profileButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'person.circle'")).firstMatch
        
        if profileButton.waitForExistence(timeout: 5) && profileButton.isHittable {
            profileButton.tap()
            
            // Wait for menu to appear
            sleep(2)
            
            // Tap Sign Out
            if app.buttons["Sign Out"].exists {
                app.buttons["Sign Out"].tap()
                
                // Wait for sign out to complete
                sleep(2)
            }
            
            // Verify returned to login
            XCTAssertTrue(
                app.staticTexts["Welcome Back"].waitForExistence(timeout: 10),
                "Should return to login screen after sign out"
            )
        }
    }
    
    private func verifyMessagesScreenAppears() {
        // Wait for screen to stabilize
        sleep(2)
        
        XCTAssertTrue(
            app.navigationBars["Messages"].exists,
            "Messages screen should be visible"
        )
        
        // Additional verification - check for key elements
        let hasMessagesTitle = app.navigationBars["Messages"].exists
        let hasNewConversationButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'square.and.pencil'")).firstMatch.exists
        
        XCTAssertTrue(hasMessagesTitle, "Messages navigation bar should exist")
        XCTAssertTrue(hasNewConversationButton, "New conversation button should exist")
    }
}


