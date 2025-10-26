//
//  MessageActionsUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

final class MessageActionsUITests: XCTestCase {
    
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
    
    func testNavigateToMessagesTab() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        XCTAssertTrue(messagesTab.exists)
        messagesTab.tap()
        
        // Wait for messages to load
        sleep(2)
    }
    
    func testNavigateToAIAssistantTab() throws {
        // Navigate to AI Assistant tab
        let aiTab = app.tabBars.buttons["AI Assistant"]
        XCTAssertTrue(aiTab.exists)
        aiTab.tap()
        
        // Wait for AI interface to load
        sleep(2)
    }
    
    // MARK: - Message Actions UI Tests
    
    func testMessageActionSheetPresentation() throws {
        // First navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Look for a message bubble to long press
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        
        if messageBubbles.count > 0 {
            let firstMessage = messageBubbles.firstMatch
            
            // Long press on the message
            firstMessage.press(forDuration: 1.0)
            
            // Check if action sheet appears
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists, "Message action sheet should appear after long press")
            
            // Check for action buttons
            XCTAssertTrue(actionSheet.buttons["Translate"].exists)
            XCTAssertTrue(actionSheet.buttons["Rewrite"].exists)
            XCTAssertTrue(actionSheet.buttons["Extract"].exists)
            XCTAssertTrue(actionSheet.buttons["Summarize"].exists)
            
            // Dismiss the sheet
            actionSheet.buttons["Cancel"].tap()
        } else {
            // If no messages exist, create one first
            createTestMessage()
            testMessageActionSheetPresentation()
        }
    }
    
    func testTranslateAction() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Long press on a message
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            // Tap Translate action
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists)
            
            actionSheet.buttons["Translate"].tap()
            
            // Wait for processing
            sleep(3)
            
            // Check if result view appears
            let resultView = app.otherElements.matching(identifier: "ResultDisplayView")
            XCTAssertTrue(resultView.count > 0, "Result view should appear after translation")
            
            // Check for action buttons in result
            XCTAssertTrue(app.buttons["Copy"].exists)
            XCTAssertTrue(app.buttons["Share"].exists)
            XCTAssertTrue(app.buttons["Send"].exists)
            
            // Dismiss
            app.buttons["Done"].tap()
        } else {
            createTestMessage()
            testTranslateAction()
        }
    }
    
    func testRewriteAction() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Long press on a message
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            // Tap Rewrite action
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists)
            
            actionSheet.buttons["Rewrite"].tap()
            
            // Check if tone picker appears
            sleep(1)
            XCTAssertTrue(app.buttons["Formal"].exists)
            XCTAssertTrue(app.buttons["Casual"].exists)
            XCTAssertTrue(app.buttons["Technical"].exists)
            XCTAssertTrue(app.buttons["Friendly"].exists)
            
            // Select a tone
            app.buttons["Formal"].tap()
            
            // Tap rewrite button
            app.buttons["Rewrite Message"].tap()
            
            // Wait for processing
            sleep(3)
            
            // Check if result view appears
            let resultView = app.otherElements.matching(identifier: "ResultDisplayView")
            XCTAssertTrue(resultView.count > 0, "Result view should appear after rewriting")
            
            // Dismiss
            app.buttons["Done"].tap()
        } else {
            createTestMessage()
            testRewriteAction()
        }
    }
    
    func testExtractAction() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Long press on a message
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            // Tap Extract action
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists)
            
            actionSheet.buttons["Extract"].tap()
            
            // Wait for processing
            sleep(3)
            
            // Check if result view appears
            let resultView = app.otherElements.matching(identifier: "ResultDisplayView")
            XCTAssertTrue(resultView.count > 0, "Result view should appear after extraction")
            
            // Dismiss
            app.buttons["Done"].tap()
        } else {
            createTestMessage()
            testExtractAction()
        }
    }
    
    func testSummarizeAction() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Long press on a message
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            // Tap Summarize action
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists)
            
            actionSheet.buttons["Summarize"].tap()
            
            // Wait for processing
            sleep(3)
            
            // Check if result view appears
            let resultView = app.otherElements.matching(identifier: "ResultDisplayView")
            XCTAssertTrue(resultView.count > 0, "Result view should appear after summarization")
            
            // Dismiss
            app.buttons["Done"].tap()
        } else {
            createTestMessage()
            testSummarizeAction()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestMessage() {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Look for a conversation to open
        let conversations = app.cells
        if conversations.count > 0 {
            conversations.firstMatch.tap()
            sleep(2)
            
            // Look for text input field
            let textField = app.textFields.firstMatch
            if textField.exists {
                textField.tap()
                textField.typeText("This is a test message for action testing")
                
                // Look for send button
                let sendButton = app.buttons["Send"]
                if sendButton.exists {
                    sendButton.tap()
                    sleep(2)
                }
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testMessageActionSheetAccessibility() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Long press on a message
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.exists)
            
            // Test accessibility labels
            XCTAssertTrue(actionSheet.buttons["Translate"].isHittable)
            XCTAssertTrue(actionSheet.buttons["Rewrite"].isHittable)
            XCTAssertTrue(actionSheet.buttons["Extract"].isHittable)
            XCTAssertTrue(actionSheet.buttons["Summarize"].isHittable)
            XCTAssertTrue(actionSheet.buttons["Cancel"].isHittable)
            
            // Dismiss
            actionSheet.buttons["Cancel"].tap()
        }
    }
    
    // MARK: - Performance Tests
    
    func testMessageActionPerformance() throws {
        // Navigate to Messages tab
        let messagesTab = app.tabBars.buttons["Messages"]
        messagesTab.tap()
        sleep(2)
        
        // Measure time for action sheet presentation
        let messageBubbles = app.otherElements.matching(identifier: "MessageBubble")
        if messageBubbles.count > 0 {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            messageBubbles.firstMatch.press(forDuration: 1.0)
            
            let actionSheet = app.sheets["Message Actions"]
            XCTAssertTrue(actionSheet.waitForExistence(timeout: 2.0))
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Action sheet presentation took \(timeElapsed) seconds")
            
            // Should appear within 2 seconds
            XCTAssertLessThan(timeElapsed, 2.0)
            
            // Dismiss
            actionSheet.buttons["Cancel"].tap()
        }
    }
}
