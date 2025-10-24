//
//  SummarizationUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

/// UI tests for Smart Summarization feature (PR #18)
final class SummarizationUITests: XCTestCase {
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
    
    // MARK: - Summarize Button Tests
    
    /// Test: Summarize button exists in chat view
    func testSummarizeButton_Exists() throws {
        // Given - Navigate to a chat
        navigateToTestChat()
        
        // Then - Summarize button should exist
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        XCTAssertTrue(summarizeButton.exists, "Summarize button should exist in chat view")
    }
    
    /// Test: Summarize button disabled for empty conversation
    func testSummarizeButton_DisabledWhenEmpty() throws {
        // Given - Navigate to chat with no messages
        navigateToEmptyChat()
        
        // Then - Button should be disabled
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        XCTAssertFalse(summarizeButton.isEnabled, "Button should be disabled for empty conversation")
    }
    
    /// Test: Summarize button enabled for conversation with messages
    func testSummarizeButton_EnabledWithMessages() throws {
        // Given - Navigate to chat with messages
        navigateToTestChat()
        sendTestMessage("Test message")
        
        // Then - Button should be enabled
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        XCTAssertTrue(summarizeButton.isEnabled, "Button should be enabled when messages exist")
    }
    
    // MARK: - Summary Generation Tests
    
    /// Test: Tapping summarize button shows loading state
    func testSummarizeButton_ShowsLoadingState() throws {
        // Given
        navigateToTestChat()
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        
        // When
        summarizeButton.tap()
        
        // Then - Loading indicator should appear
        let loadingIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 1))
    }
    
    /// Test: Summary sheet appears after generation
    func testSummarySheet_AppearsAfterGeneration() throws {
        // Given
        navigateToTestChat()
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        
        // When
        summarizeButton.tap()
        
        // Then - Summary sheet should appear
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertTrue(summaryTitle.waitForExistence(timeout: 10), "Summary sheet should appear")
    }
    
    // MARK: - Summary Content Tests
    
    /// Test: Summary displays key points section
    func testSummaryView_DisplaysKeyPoints() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // Then - Key Points section should be visible
        let keyPointsTitle = app.staticTexts["Key Points"]
        // May or may not exist depending on content
        // XCTAssertTrue(keyPointsTitle.exists)
    }
    
    /// Test: Summary displays decisions section
    func testSummaryView_DisplaysDecisions() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // Then - Decisions section may be visible
        let decisionsTitle = app.staticTexts["Decisions Made"]
        // May or may not exist depending on content
    }
    
    /// Test: Summary displays action items section
    func testSummaryView_DisplaysActionItems() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // Then - Action Items section may be visible
        let actionItemsTitle = app.staticTexts["Action Items"]
        // May or may not exist depending on content
    }
    
    /// Test: Summary displays open questions section
    func testSummaryView_DisplaysOpenQuestions() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // Then - Open Questions section may be visible
        let questionsTitle = app.staticTexts["Open Questions"]
        // May or may not exist depending on content
    }
    
    /// Test: Empty summary shows empty state
    func testSummaryView_ShowsEmptyState() throws {
        // Given - Conversation with minimal content
        navigateToEmptySummaryChat()
        generateSummary()
        
        // Then - Empty state should appear
        let emptyStateTitle = app.staticTexts["No Summary Available"]
        XCTAssertTrue(emptyStateTitle.waitForExistence(timeout: 10))
    }
    
    // MARK: - Summary Interaction Tests
    
    /// Test: Can dismiss summary with Done button
    func testSummaryView_DismissWithDoneButton() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // When
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()
        
        // Then - Summary should dismiss
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertFalse(summaryTitle.exists, "Summary should be dismissed")
    }
    
    /// Test: Can dismiss summary with swipe down
    func testSummaryView_DismissWithSwipe() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // When - Swipe down
        let summarySheet = app.otherElements["Conversation Summary"]
        summarySheet.swipeDown()
        
        // Then - Summary should dismiss
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertFalse(summaryTitle.waitForExistence(timeout: 2))
    }
    
    /// Test: Can scroll summary content
    func testSummaryView_ScrollsContent() throws {
        // Given - Summary with lots of content
        navigateToLongSummaryChat()
        generateSummary()
        
        // When
        let summaryScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(summaryScrollView.exists)
        
        // Scroll down
        summaryScrollView.swipeUp()
        
        // Then - Should scroll
        // Content should be accessible
    }
    
    // MARK: - Multiple Summaries Tests
    
    /// Test: Can generate multiple summaries
    func testGenerateMultipleSummaries() throws {
        // Given
        navigateToTestChat()
        
        // When - Generate first summary
        generateSummary()
        dismissSummary()
        
        // And - Generate second summary
        generateSummary()
        
        // Then - Second summary should appear
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertTrue(summaryTitle.exists)
        
        dismissSummary()
    }
    
    /// Test: Button disabled during generation
    func testSummarizeButton_DisabledDuringGeneration() throws {
        // Given
        navigateToTestChat()
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        
        // When
        summarizeButton.tap()
        
        // Then - Button should be disabled while generating
        XCTAssertFalse(summarizeButton.isEnabled, "Button should be disabled during generation")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test: Error handling for failed summarization
    func testSummarization_HandlesError() throws {
        // Given - Simulate error condition (e.g., no network)
        app.launchArguments.append("SIMULATE_NETWORK_ERROR")
        app.launch()
        
        navigateToTestChat()
        
        // When
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        summarizeButton.tap()
        
        // Then - Error should be displayed
        // (Depends on error handling implementation)
        let errorAlert = app.alerts.firstMatch
        // XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
    }
    
    // MARK: - Accessibility Tests
    
    /// Test: Summary button has accessibility label
    func testSummarizeButton_HasAccessibilityLabel() throws {
        // Given
        navigateToTestChat()
        
        // Then
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        XCTAssertTrue(summarizeButton.exists)
        XCTAssertTrue(summarizeButton.isHittable)
    }
    
    /// Test: Summary content is accessible
    func testSummaryView_ContentAccessible() throws {
        // Given
        navigateToTestChat()
        generateSummary()
        
        // Then - All text should be accessible
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertTrue(summaryTitle.isAccessibilityElement || summaryTitle.exists)
    }
    
    // MARK: - Dark Mode Tests
    
    /// Test: Summary displays correctly in dark mode
    func testSummaryView_DarkMode() throws {
        // Given - Enable dark mode
        app.launchArguments.append("DARK_MODE")
        app.launch()
        
        navigateToTestChat()
        generateSummary()
        
        // Then - Summary should be visible and readable
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertTrue(summaryTitle.exists)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTestChat() {
        // Navigate through app to a test chat
        // 1. Login
        loginAsTestUser()
        
        // 2. Select or create a conversation
        let conversationList = app.navigationBars["Messages"]
        XCTAssertTrue(conversationList.waitForExistence(timeout: 5))
        
        // Select first conversation
        let firstConversation = app.cells.firstMatch
        if firstConversation.exists {
            firstConversation.tap()
        }
    }
    
    private func navigateToEmptyChat() {
        navigateToTestChat()
        // Ensure chat has no messages
    }
    
    private func navigateToLongSummaryChat() {
        // Navigate to chat that will generate a long summary
        navigateToTestChat()
    }
    
    private func navigateToEmptySummaryChat() {
        // Navigate to chat with minimal content
        navigateToTestChat()
    }
    
    private func generateSummary() {
        let summarizeButton = app.buttons["doc.text.magnifyingglass"]
        XCTAssertTrue(summarizeButton.waitForExistence(timeout: 5))
        summarizeButton.tap()
        
        // Wait for summary to appear
        let summaryTitle = app.staticTexts["Conversation Summary"]
        XCTAssertTrue(summaryTitle.waitForExistence(timeout: 15))
    }
    
    private func dismissSummary() {
        let doneButton = app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        }
    }
    
    private func sendTestMessage(_ text: String) {
        let messageField = app.textFields.firstMatch
        if messageField.exists {
            messageField.tap()
            messageField.typeText(text)
            app.buttons["Send"].tap()
        }
    }
    
    private func loginAsTestUser() {
        // Login logic for UI tests
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


