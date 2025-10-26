//
//  UITestSetup.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

/// Base class for UI tests with Firebase emulator setup
@MainActor
class UITestSetup: XCTestCase {
    
    // MARK: - Test Configuration
    
    /// Test user credentials
    struct TestCredentials {
        static let email = "uitest@example.com"
        static let password = "testpassword123"
        static let displayName = "UI Test User"
    }
    
    /// Test conversation data
    struct TestConversation {
        static let title = "Test Conversation"
        static let messages = [
            "Hello! This is a test message.",
            "How are you doing today?",
            "I'm testing the UI functionality.",
            "This should help with our UI tests."
        ]
    }
    
    // MARK: - Setup and Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Configure Firebase for testing
        TestFirebaseConfig.configureForTesting()
        
        // Wait for emulators to be ready
        let emulatorReady = await TestFirebaseConfig.checkEmulatorStatus()
        guard emulatorReady else {
            XCTFail("Firebase emulators are not running. Please start them with: firebase emulators:start")
            return
        }
        
        // Clear any existing test data
        try await TestFirebaseConfig.clearTestData()
        
        print("🧪 UI Test setup complete")
    }
    
    override func tearDown() async throws {
        // Clean up test data
        try? await TestFirebaseConfig.clearTestData()
        
        // Sign out any test user
        try? await TestFirebaseConfig.signOutUser()
        
        try await super.tearDown()
        print("🧹 UI Test teardown complete")
    }
    
    // MARK: - Test Helper Methods
    
    /// Creates and signs in a test user
    func createAndSignInTestUser() async throws {
        do {
            // Try to create new user
            _ = try await TestFirebaseConfig.createTestUser(
                email: TestCredentials.email,
                password: TestCredentials.password
            )
        } catch {
            // If user already exists, just sign in
            _ = try await TestFirebaseConfig.signInTestUser(
                email: TestCredentials.email,
                password: TestCredentials.password
            )
        }
        
        // Create sample test data
        try await TestFirebaseConfig.createSampleTestData()
    }
    
    /// Waits for the app to navigate to a specific screen
    func waitForNavigationToScreen(_ screenName: String, timeout: TimeInterval = 10.0) {
        let app = XCUIApplication()
        let navigationBar = app.navigationBars[screenName]
        
        let exists = navigationBar.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Should navigate to \(screenName) screen")
    }
    
    /// Waits for a specific UI element to appear
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element should exist: \(element)")
    }
    
    /// Taps an element and waits for it to be hittable
    func tapElement(_ element: XCUIElement) {
        waitForElement(element)
        XCTAssertTrue(element.isHittable, "Element should be hittable: \(element)")
        element.tap()
    }
    
    /// Types text into a text field
    func typeText(_ text: String, into textField: XCUIElement) {
        waitForElement(textField)
        textField.tap()
        textField.typeText(text)
    }
    
    /// Waits for the app to be idle
    func waitForAppToBeIdle() {
        let app = XCUIApplication()
        _ = app.wait(for: .runningForeground, timeout: 5.0)
    }
    
    // MARK: - Authentication Test Helpers
    
    /// Performs complete sign-up flow
    func performSignUpFlow() {
        let app = XCUIApplication()
        
        // Tap Sign Up button
        let signUpButton = app.buttons["Sign Up"]
        tapElement(signUpButton)
        
        // Wait for sign-up form
        let createAccountText = app.staticTexts["Create Account"]
        waitForElement(createAccountText)
        
        // Fill out sign-up form
        let nameField = app.textFields["Your name"]
        typeText(TestCredentials.displayName, into: nameField)
        
        let emailField = app.textFields["your.email@company.com"]
        typeText(TestCredentials.email, into: emailField)
        
        let passwordField = app.secureTextFields["At least 8 characters"]
        typeText(TestCredentials.password, into: passwordField)
        
        let confirmPasswordField = app.secureTextFields["Re-enter password"]
        typeText(TestCredentials.password, into: confirmPasswordField)
        
        // Submit form
        let createAccountButton = app.buttons["Create Account"]
        tapElement(createAccountButton)
        
        // Wait for navigation to Messages screen
        waitForNavigationToScreen("Messages")
    }
    
    /// Performs complete sign-in flow
    func performSignInFlow() {
        let app = XCUIApplication()
        
        // Fill out sign-in form
        let emailField = app.textFields["your.email@company.com"]
        typeText(TestCredentials.email, into: emailField)
        
        let passwordField = app.secureTextFields["At least 8 characters"]
        typeText(TestCredentials.password, into: passwordField)
        
        // Submit form
        let loginButton = app.buttons["Login"]
        tapElement(loginButton)
        
        // Wait for navigation to Messages screen
        waitForNavigationToScreen("Messages")
    }
    
    // MARK: - Debug Helpers
    
    /// Prints current UI hierarchy for debugging
    func printUIHierarchy() {
        let app = XCUIApplication()
        print("📱 Current UI Hierarchy:")
        print(app.debugDescription)
    }
    
    /// Takes a screenshot for debugging
    func takeScreenshot(name: String) {
        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
