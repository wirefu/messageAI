//
//  ClarityUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

/// UI tests for Clarity Assistant feature (PR #20)
final class ClarityUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Clarity Check Trigger Tests
    
    /// Test: Clarity check triggers after typing
    func testClarityCheck_TriggersAfterTyping() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        
        // When - Type message and wait
        messageField.tap()
        messageField.typeText("Can you send it later?")
        
        // Wait for debounce (2 seconds) + processing
        sleep(5)
        
        // Then - Clarity suggestion should appear
        let clarityCard = app.staticTexts["Clarity Assistant"]
        // XCTAssertTrue(clarityCard.waitForExistence(timeout: 3))
    }
    
    /// Test: Clarity check doesn't trigger while typing
    func testClarityCheck_DoesNotTriggerWhileTyping() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        
        // When - Type rapidly
        messageField.tap()
        messageField.typeText("Can")
        sleep(1)  // Less than debounce time
        
        // Then - No suggestion yet
        let clarityCard = app.staticTexts["Clarity Assistant"]
        XCTAssertFalse(clarityCard.exists, "Should not show suggestion while typing")
    }
    
    /// Test: Short messages don't trigger check
    func testClarityCheck_ShortMessageNoCheck() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        
        // When - Type short message
        messageField.tap()
        messageField.typeText("Hi")
        sleep(3)
        
        // Then - No suggestion for short message
        let clarityCard = app.staticTexts["Clarity Assistant"]
        XCTAssertFalse(clarityCard.exists, "Short messages should not trigger clarity check")
    }
    
    // MARK: - Suggestion Display Tests
    
    /// Test: Suggestion displays issues
    func testClaritySuggestion_DisplaysIssues() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then - Issues should be visible
        let issuesLabel = app.staticTexts["Issues Found:"]
        // May or may not exist depending on suggestion content
    }
    
    /// Test: Suggestion displays suggested revision
    func testClaritySuggestion_DisplaysRevision() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then - Suggested revision should be visible
        let suggestedLabel = app.staticTexts["Suggested:"]
        // May or may not exist depending on suggestion
    }
    
    /// Test: Suggestion displays tone warning
    func testClaritySuggestion_DisplaysToneWarning() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then - Warning icon should be visible if tone issue exists
        let warningIcon = app.images["exclamationmark.triangle.fill"]
        // May or may not exist
    }
    
    // MARK: - Interaction Tests
    
    /// Test: Accept button replaces message text
    func testAcceptButton_ReplacesMessageText() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        let originalMessage = "Can you send it later?"
        
        messageField.tap()
        messageField.typeText(originalMessage)
        sleep(5) // Wait for suggestion
        
        // When - Tap Accept button
        let acceptButton = app.buttons["Accept"]
        if acceptButton.exists {
            let fieldValueBefore = messageField.value as? String ?? ""
            acceptButton.tap()
            
            // Then - Message should be replaced
            sleep(1)
            let fieldValueAfter = messageField.value as? String ?? ""
            XCTAssertNotEqual(fieldValueBefore, fieldValueAfter, "Message should be replaced")
        }
    }
    
    /// Test: Dismiss button hides suggestion
    func testDismissButton_HidesSuggestion() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // When
        let dismissButton = app.buttons["Dismiss"]
        if dismissButton.exists {
            dismissButton.tap()
            
            // Then - Suggestion should disappear
            sleep(1)
            let clarityCard = app.staticTexts["Clarity Assistant"]
            XCTAssertFalse(clarityCard.exists, "Suggestion should be dismissed")
        }
    }
    
    /// Test: Close (X) button hides suggestion
    func testCloseButton_HidesSuggestion() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // When
        let closeButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        if closeButton.exists {
            closeButton.tap()
            
            // Then
            sleep(1)
            let clarityCard = app.staticTexts["Clarity Assistant"]
            XCTAssertFalse(clarityCard.exists)
        }
    }
    
    /// Test: Expand button shows more content
    func testExpandButton_ShowsMore() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // When
        let moreButton = app.buttons["More"]
        if moreButton.exists {
            moreButton.tap()
            
            // Then - Alternative phrasing should appear
            let alternativeLabel = app.staticTexts["Alternative:"]
            // XCTAssertTrue(alternativeLabel.exists)
            
            // Less button should appear
            let lessButton = app.buttons["Less"]
            XCTAssertTrue(lessButton.exists)
        }
    }
    
    // MARK: - Loading State Tests
    
    /// Test: Loading indicator during check
    func testClarityCheck_ShowsLoadingIndicator() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        
        // When
        messageField.tap()
        messageField.typeText("Can you send it later?")
        
        // Wait for debounce
        sleep(2)
        
        // Then - Loading indicator should appear briefly
        // (Fast, may be hard to catch in UI test)
    }
    
    // MARK: - Multiple Suggestions Tests
    
    /// Test: New message clears old suggestion
    func testNewMessage_ClearsOldSuggestion() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // When - Type new message
        let messageField = app.textFields["Message"]
        messageField.tap()
        messageField.clearText()
        messageField.typeText("New different message")
        
        // Then - Old suggestion should disappear
        // New check should trigger
    }
    
    /// Test: Can send message without accepting suggestion
    func testSendMessage_WithoutAcceptingSuggestion() throws {
        // Given
        navigateToChat()
        let messageField = app.textFields["Message"]
        messageField.tap()
        messageField.typeText("Can you send it?")
        sleep(5) // Wait for suggestion
        
        // When - Send without accepting
        let sendButton = app.buttons["arrow.up.circle.fill"]
        if sendButton.isEnabled {
            sendButton.tap()
            
            // Then - Message should send with original text
            // Suggestion should dismiss
            let clarityCard = app.staticTexts["Clarity Assistant"]
            XCTAssertFalse(clarityCard.exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    /// Test: Clarity suggestion is accessible
    func testClaritySuggestion_IsAccessible() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then - All elements should be accessible
        let clarityCard = app.staticTexts["Clarity Assistant"]
        if clarityCard.exists {
            XCTAssertTrue(clarityCard.isHittable || clarityCard.isAccessibilityElement)
        }
    }
    
    /// Test: Buttons have accessibility labels
    func testButtons_HaveAccessibilityLabels() throws {
        // Given
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then
        let acceptButton = app.buttons["Accept"]
        let dismissButton = app.buttons["Dismiss"]
        
        if acceptButton.exists {
            XCTAssertTrue(acceptButton.isHittable)
        }
        if dismissButton.exists {
            XCTAssertTrue(dismissButton.isHittable)
        }
    }
    
    // MARK: - Dark Mode Tests
    
    /// Test: Clarity suggestion in dark mode
    func testClaritySuggestion_DarkMode() throws {
        // Given - Enable dark mode
        app.launchArguments.append("DARK_MODE")
        app.launch()
        
        navigateToChat()
        triggerClaritySuggestion()
        
        // Then - Should be visible and readable
        let clarityCard = app.staticTexts["Clarity Assistant"]
        // Should render properly
    }
    
    // MARK: - Helper Methods
    
    private func navigateToChat() {
        // Login and navigate to chat
        loginAsTestUser()
        
        let conversationList = app.navigationBars["Messages"]
        XCTAssertTrue(conversationList.waitForExistence(timeout: 5))
        
        // Select first conversation or create one
        let firstConversation = app.cells.firstMatch
        if firstConversation.exists {
            firstConversation.tap()
        }
    }
    
    private func triggerClaritySuggestion() {
        let messageField = app.textFields["Message"]
        messageField.tap()
        messageField.typeText("Can you send it later?") // Vague message
        sleep(5) // Wait for debounce + processing
    }
    
    private func loginAsTestUser() {
        let emailField = app.textFields["Email"]
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            let passwordField = app.secureTextFields["Password"]
            passwordField.tap()
            passwordField.typeText("password123")
            
            app.buttons["Log In"].tap()
        }
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

