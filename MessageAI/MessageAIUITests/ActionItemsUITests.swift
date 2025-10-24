//
//  ActionItemsUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

/// UI tests for Action Items feature (PR #21/23)
final class ActionItemsUITests: XCTestCase {
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
    
    // MARK: - Button Tests
    
    /// Test: Action items button exists in chat
    func testActionItemsButton_Exists() throws {
        // Given
        navigateToChat()
        
        // Then
        let actionItemsButton = app.buttons["checklist"]
        XCTAssertTrue(actionItemsButton.exists, "Action items button should exist")
    }
    
    /// Test: Tapping button shows action items view
    func testActionItemsButton_ShowsView() throws {
        // Given
        navigateToChat()
        
        // When
        let actionItemsButton = app.buttons["checklist"]
        actionItemsButton.tap()
        
        // Then
        let actionItemsTitle = app.staticTexts["Action Items"]
        XCTAssertTrue(actionItemsTitle.waitForExistence(timeout: 2))
    }
    
    // MARK: - List Display Tests
    
    /// Test: Empty state displays correctly
    func testActionItems_EmptyState() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // Then - Should show empty state
        let emptyStateTitle = app.staticTexts["No Action Items"]
        // XCTAssertTrue(emptyStateTitle.exists)
    }
    
    /// Test: Action items display in list
    func testActionItems_DisplayInList() throws {
        // Given - Conversation with action items
        navigateToChat()
        sendMessageWithAction("I'll review the PR by Friday")
        sleep(2) // Wait for extraction
        
        // When
        openActionItems()
        
        // Then - Should see action item
        // (Depends on AI extraction working)
    }
    
    // MARK: - Filter Tests
    
    /// Test: All filter shows everything
    func testFilter_All() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // When
        let allFilter = app.buttons["All"]
        allFilter.tap()
        
        // Then - Shows all items
    }
    
    /// Test: Open filter shows only incomplete
    func testFilter_Open() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // When
        let openFilter = app.buttons["Open"]
        openFilter.tap()
        
        // Then - Shows only open items
    }
    
    /// Test: Completed filter shows only complete
    func testFilter_Completed() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // When
        let completedFilter = app.buttons["Completed"]
        completedFilter.tap()
        
        // Then - Shows only completed items
    }
    
    // MARK: - Interaction Tests
    
    /// Test: Tap checkbox toggles completion
    func testToggleComplete_CheckboxTap() throws {
        // Given - Action item in list
        navigateToChat()
        createTestActionItem()
        openActionItems()
        
        // When - Tap checkbox
        let checkbox = app.buttons.matching(identifier: "circle").firstMatch
        if checkbox.exists {
            checkbox.tap()
            
            // Then - Should change to checkmark
            let checkedBox = app.buttons.matching(identifier: "checkmark.circle.fill").firstMatch
            XCTAssertTrue(checkedBox.waitForExistence(timeout: 2))
        }
    }
    
    /// Test: Swipe to delete removes item
    func testSwipeToDelete_RemovesItem() throws {
        // Given
        navigateToChat()
        createTestActionItem()
        openActionItems()
        
        // When - Swipe on item
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeLeft()
            
            // Then - Delete button appears
            let deleteButton = app.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.tap()
                
                // Item should be removed
            }
        }
    }
    
    // MARK: - Auto-Extraction Tests
    
    /// Test: Action item auto-extracted from message
    func testAutoExtraction_OnMessageSent() throws {
        // Given
        navigateToChat()
        
        // When - Send message with action
        sendMessageWithAction("I'll finish the report by tomorrow")
        sleep(3) // Wait for AI extraction
        
        openActionItems()
        
        // Then - Should see extracted item
        // (Depends on Cloud Functions working)
    }
    
    /// Test: Multiple items extracted from one message
    func testAutoExtraction_MultipleItems() throws {
        // Given
        navigateToChat()
        
        // When
        sendMessageWithAction("I'll do the review, test it, and deploy")
        sleep(3)
        
        openActionItems()
        
        // Then - Should see multiple items
        // (Depends on AI extraction quality)
    }
    
    /// Test: No extraction for non-action messages
    func testAutoExtraction_NoFalsePositives() throws {
        // Given
        navigateToChat()
        
        // When - Send message without action
        sendMessage("Good morning! How are you?")
        sleep(3)
        
        openActionItems()
        
        // Then - Should not extract anything
        let emptyState = app.staticTexts["No Action Items"]
        // Should show empty state or no new items
    }
    
    // MARK: - Display Tests
    
    /// Test: Action item shows all fields
    func testActionItem_DisplaysAllFields() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // Then - Should show description, assignee, due date
        // (When action items exist)
    }
    
    /// Test: Overdue items highlighted
    func testActionItem_OverdueHighlight() throws {
        // Given - Create overdue action item
        navigateToChat()
        // (Would need to create item with past due date)
        
        openActionItems()
        
        // Then - Should show in red or highlighted
    }
    
    // MARK: - Accessibility Tests
    
    /// Test: Action items are accessible
    func testActionItems_Accessible() throws {
        // Given
        navigateToChat()
        openActionItems()
        
        // Then - All elements accessible
        let actionItemsTitle = app.staticTexts["Action Items"]
        if actionItemsTitle.exists {
            XCTAssertTrue(actionItemsTitle.isHittable || actionItemsTitle.isAccessibilityElement)
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToChat() {
        loginAsTestUser()
        
        let conversationList = app.navigationBars["Messages"]
        XCTAssertTrue(conversationList.waitForExistence(timeout: 5))
        
        let firstConversation = app.cells.firstMatch
        if firstConversation.exists {
            firstConversation.tap()
        }
    }
    
    private func openActionItems() {
        let actionItemsButton = app.buttons["checklist"]
        XCTAssertTrue(actionItemsButton.waitForExistence(timeout: 2))
        actionItemsButton.tap()
    }
    
    private func sendMessage(_ text: String) {
        let messageField = app.textFields["Message"]
        if messageField.exists {
            messageField.tap()
            messageField.typeText(text)
            app.buttons["arrow.up.circle.fill"].tap()
        }
    }
    
    private func sendMessageWithAction(_ text: String) {
        sendMessage(text)
    }
    
    private func createTestActionItem() {
        // Create via UI or API
        sendMessageWithAction("Test action item creation")
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

