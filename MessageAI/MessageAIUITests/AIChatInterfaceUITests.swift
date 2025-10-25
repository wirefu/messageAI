//
//  AIChatInterfaceUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

class AIChatInterfaceUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testAIChatTabIsVisible() throws {
        // Navigate to AI Chat tab
        let aiChatTab = app.tabBars.buttons["AI Chat"]
        XCTAssertTrue(aiChatTab.exists, "AI Chat tab should be visible")
        aiChatTab.tap()
        
        // Verify we're on the AI Chat interface
        let aiChatView = app.navigationBars["AI Chat"]
        XCTAssertTrue(aiChatView.exists, "AI Chat navigation bar should be visible")
    }
    
    func testAIChatInterfaceElements() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Check for key UI elements
        let newSessionButton = app.buttons["New Session"]
        XCTAssertTrue(newSessionButton.exists, "New Session button should be visible")
        
        let searchField = app.searchFields["Search AI conversations"]
        XCTAssertTrue(searchField.exists, "Search field should be visible")
        
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.exists, "Settings button should be visible")
    }
    
    // MARK: - New Session Tests
    
    func testCreateNewAISession() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Tap New Session button
        app.buttons["New Session"].tap()
        
        // Verify New Session view appears
        let newSessionView = app.navigationBars["New AI Session"]
        XCTAssertTrue(newSessionView.exists, "New AI Session view should appear")
        
        // Check for session creation elements
        let titleField = app.textFields["Session Title"]
        XCTAssertTrue(titleField.exists, "Title field should be visible")
        
        let descriptionField = app.textViews["Session Description (Optional)"]
        XCTAssertTrue(descriptionField.exists, "Description field should be visible")
        
        let createButton = app.buttons["Create Session"]
        XCTAssertTrue(createButton.exists, "Create button should be visible")
        
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should be visible")
    }
    
    func testCreateAISessionWithTitle() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create new session
        app.buttons["New Session"].tap()
        
        // Enter session title
        let titleField = app.textFields["Session Title"]
        titleField.tap()
        titleField.typeText("Test AI Session")
        
        // Create the session
        app.buttons["Create Session"].tap()
        
        // Verify we're back to AI Chat interface
        let aiChatView = app.navigationBars["AI Chat"]
        XCTAssertTrue(aiChatView.exists, "Should return to AI Chat interface")
    }
    
    func testCancelNewSession() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create new session
        app.buttons["New Session"].tap()
        
        // Cancel the session
        app.buttons["Cancel"].tap()
        
        // Verify we're back to AI Chat interface
        let aiChatView = app.navigationBars["AI Chat"]
        XCTAssertTrue(aiChatView.exists, "Should return to AI Chat interface")
    }
    
    // MARK: - Chat Interface Tests
    
    func testAIChatMessageInput() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create a new session first
        app.buttons["New Session"].tap()
        app.textFields["Session Title"].tap()
        app.textFields["Session Title"].typeText("Test Chat")
        app.buttons["Create Session"].tap()
        
        // Wait for chat interface to load
        sleep(2)
        
        // Check for message input elements
        let messageInput = app.textViews["Type your message..."]
        XCTAssertTrue(messageInput.exists, "Message input should be visible")
        
        let sendButton = app.buttons["Send"]
        XCTAssertTrue(sendButton.exists, "Send button should be visible")
    }
    
    func testSendAIMessage() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create a new session
        app.buttons["New Session"].tap()
        app.textFields["Session Title"].tap()
        app.textFields["Session Title"].typeText("Test Message")
        app.buttons["Create Session"].tap()
        
        // Wait for chat interface
        sleep(2)
        
        // Type a message
        let messageInput = app.textViews["Type your message..."]
        messageInput.tap()
        messageInput.typeText("Hello AI, how are you?")
        
        // Send the message
        app.buttons["Send"].tap()
        
        // Verify message appears in chat
        let messageText = app.staticTexts["Hello AI, how are you?"]
        XCTAssertTrue(messageText.waitForExistence(timeout: 5), "User message should appear in chat")
    }
    
    // MARK: - AI Actions Tests
    
    func testAIActionsAreVisible() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create a new session
        app.buttons["New Session"].tap()
        app.textFields["Session Title"].tap()
        app.textFields["Session Title"].typeText("Test Actions")
        app.buttons["Create Session"].tap()
        
        // Wait for chat interface
        sleep(2)
        
        // Send a message
        let messageInput = app.textViews["Type your message..."]
        messageInput.tap()
        messageInput.typeText("Please summarize this conversation")
        app.buttons["Send"].tap()
        
        // Wait for AI response
        sleep(3)
        
        // Check for AI action buttons
        let translateButton = app.buttons["Translate"]
        let summarizeButton = app.buttons["Summarize"]
        let extractButton = app.buttons["Extract Action Items"]
        
        // At least one action should be available
        let hasActions = translateButton.exists || summarizeButton.exists || extractButton.exists
        XCTAssertTrue(hasActions, "AI action buttons should be visible")
    }
    
    // MARK: - Settings Tests
    
    func testAIChatSettings() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Open settings
        app.buttons["Settings"].tap()
        
        // Verify settings view appears
        let settingsView = app.navigationBars["AI Chat Settings"]
        XCTAssertTrue(settingsView.exists, "Settings view should appear")
        
        // Check for settings options
        let includeContextToggle = app.switches["Include Context"]
        let enableSuggestionsToggle = app.switches["Enable Suggestions"]
        let enableActionsToggle = app.switches["Enable Actions"]
        
        XCTAssertTrue(includeContextToggle.exists, "Include Context toggle should be visible")
        XCTAssertTrue(enableSuggestionsToggle.exists, "Enable Suggestions toggle should be visible")
        XCTAssertTrue(enableActionsToggle.exists, "Enable Actions toggle should be visible")
    }
    
    // MARK: - Search Tests
    
    func testAIChatSearch() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Use search field
        let searchField = app.searchFields["Search AI conversations"]
        searchField.tap()
        searchField.typeText("test query")
        
        // Verify search is working
        XCTAssertTrue(searchField.value as? String == "test query", "Search field should contain typed text")
    }
    
    // MARK: - Error Handling Tests
    
    func testAIChatErrorHandling() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Create a new session
        app.buttons["New Session"].tap()
        app.textFields["Session Title"].tap()
        app.textFields["Session Title"].typeText("Error Test")
        app.buttons["Create Session"].tap()
        
        // Wait for chat interface
        sleep(2)
        
        // Send a message that might cause an error
        let messageInput = app.textViews["Type your message..."]
        messageInput.tap()
        messageInput.typeText("This is a test message for error handling")
        app.buttons["Send"].tap()
        
        // Wait for response
        sleep(3)
        
        // Check for error states or loading indicators
        let loadingIndicator = app.activityIndicators.firstMatch
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'error'")).firstMatch
        
        // Either loading should complete or error should be handled gracefully
        let hasResponse = !loadingIndicator.exists || errorMessage.exists
        XCTAssertTrue(hasResponse, "Should handle errors gracefully")
    }
    
    // MARK: - Accessibility Tests
    
    func testAIChatAccessibility() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Check accessibility labels
        let aiChatTab = app.tabBars.buttons["AI Chat"]
        XCTAssertTrue(aiChatTab.isHittable, "AI Chat tab should be accessible")
        
        let newSessionButton = app.buttons["New Session"]
        XCTAssertTrue(newSessionButton.isHittable, "New Session button should be accessible")
        
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.isHittable, "Settings button should be accessible")
    }
    
    // MARK: - Performance Tests
    
    func testAIChatPerformance() throws {
        // Navigate to AI Chat tab
        app.tabBars.buttons["AI Chat"].tap()
        
        // Measure time to load AI Chat interface
        let startTime = Date()
        
        // Create a new session
        app.buttons["New Session"].tap()
        app.textFields["Session Title"].tap()
        app.textFields["Session Title"].typeText("Performance Test")
        app.buttons["Create Session"].tap()
        
        // Wait for chat interface to load
        let messageInput = app.textViews["Type your message..."]
        XCTAssertTrue(messageInput.waitForExistence(timeout: 10), "Chat interface should load within 10 seconds")
        
        let loadTime = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(loadTime, 10.0, "AI Chat interface should load quickly")
    }
}
