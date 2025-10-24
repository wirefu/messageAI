import XCTest

/// UI tests for tone analysis functionality
final class ToneAnalysisUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Tone Analysis UI Tests
    
    func testToneAnalysisShowsForTerseMessage() throws {
        // Given: User is in a chat
        try loginAndNavigateToChat()
        
        // When: User types a terse message
        let messageInput = app.textFields["Message"]
        messageInput.tap()
        messageInput.typeText("No.")
        
        // Then: Tone analysis should appear
        let toneAnalysis = app.otherElements["Tone Analysis"]
        XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 5))
        
        // Verify tone warning is shown
        let toneWarning = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'abrupt' OR label CONTAINS 'terse'"))
        XCTAssertTrue(toneWarning.firstMatch.exists)
    }
    
    func testToneAnalysisShowsAlternativePhrasing() throws {
        // Given: User is in a chat
        try loginAndNavigateToChat()
        
        // When: User types a potentially rude message
        let messageInput = app.textFields["Message"]
        messageInput.tap()
        messageInput.typeText("That's completely wrong")
        
        // Then: Tone analysis should show alternative phrasing
        let toneAnalysis = app.otherElements["Tone Analysis"]
        XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 5))
        
        // Verify alternative phrasing is shown
        let alternativePhrasing = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Suggested Phrasing'"))
        XCTAssertTrue(alternativePhrasing.firstMatch.exists)
        
        // Verify "Use This Phrasing" button exists
        let usePhrasingButton = app.buttons["Use This Phrasing"]
        XCTAssertTrue(usePhrasingButton.exists)
    }
    
    func testToneAnalysisDismissal() throws {
        // Given: User is in a chat with tone analysis showing
        try loginAndNavigateToChat()
        
        let messageInput = app.textFields["Message"]
        messageInput.tap()
        messageInput.typeText("No.")
        
        let toneAnalysis = app.otherElements["Tone Analysis"]
        XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 5))
        
        // When: User taps dismiss
        let dismissButton = app.buttons["Dismiss"]
        XCTAssertTrue(dismissButton.exists)
        dismissButton.tap()
        
        // Then: Tone analysis should be hidden
        XCTAssertFalse(toneAnalysis.exists)
    }
    
    func testToneAnalysisSeverityLevels() throws {
        // Given: User is in a chat
        try loginAndNavigateToChat()
        
        // Test different severity levels
        let testCases = [
            ("Hi there!", "none"), // Should not show analysis
            ("No.", "low"),        // Should show minor warning
            ("That's wrong.", "medium"), // Should show moderate warning
            ("You're an idiot.", "high") // Should show significant warning
        ]
        
        for (message, expectedSeverity) in testCases {
            // Clear and type new message
            let messageInput = app.textFields["Message"]
            messageInput.tap()
            messageInput.press(forDuration: 1.0) // Select all
            messageInput.typeText(message)
            
            if expectedSeverity == "none" {
                // Should not show tone analysis
                let toneAnalysis = app.otherElements["Tone Analysis"]
                XCTAssertFalse(toneAnalysis.exists)
            } else {
                // Should show tone analysis
                let toneAnalysis = app.otherElements["Tone Analysis"]
                XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 3))
                
                // Verify severity indicator
                let severityText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(expectedSeverity.capitalized)'"))
                XCTAssertTrue(severityText.firstMatch.exists)
            }
        }
    }
    
    func testToneAnalysisWithContext() throws {
        // Given: User is in a chat with previous context
        try loginAndNavigateToChat()
        
        // Send a message to create context
        let messageInput = app.textFields["Message"]
        messageInput.tap()
        messageInput.typeText("I found a bug in the system")
        
        let sendButton = app.buttons["arrow.up.circle.fill"]
        sendButton.tap()
        
        // Wait for message to be sent
        try waitForMessageToAppear("I found a bug in the system")
        
        // When: User types a terse follow-up
        messageInput.tap()
        messageInput.typeText("This is broken")
        
        // Then: Tone analysis should consider context
        let toneAnalysis = app.otherElements["Tone Analysis"]
        XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 5))
        
        // Verify context-aware suggestions
        let improvementTips = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'context' OR label CONTAINS 'specific'"))
        XCTAssertTrue(improvementTips.firstMatch.exists)
    }
    
    func testToneAnalysisImprovementSuggestions() throws {
        // Given: User is in a chat
        try loginAndNavigateToChat()
        
        // When: User types a message with tone issues
        let messageInput = app.textFields["Message"]
        messageInput.tap()
        messageInput.typeText("You should have known better")
        
        // Then: Improvement suggestions should be shown
        let toneAnalysis = app.otherElements["Tone Analysis"]
        XCTAssertTrue(toneAnalysis.waitForExistence(timeout: 5))
        
        // Verify improvement tips section
        let improvementTips = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Improvement Tips'"))
        XCTAssertTrue(improvementTips.firstMatch.exists)
        
        // Verify bullet points for suggestions
        let bulletPoints = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH '•'"))
        XCTAssertTrue(bulletPoints.firstMatch.exists)
    }
    
    // MARK: - Helper Methods
    
    private func loginAndNavigateToChat() throws {
        // Login (assuming test user exists)
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Sign In"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Wait for login to complete
        let conversationList = app.navigationBars["Conversations"]
        XCTAssertTrue(conversationList.waitForExistence(timeout: 10))
        
        // Navigate to a chat
        let firstConversation = app.cells.firstMatch
        XCTAssertTrue(firstConversation.waitForExistence(timeout: 5))
        firstConversation.tap()
        
        // Wait for chat view to load
        let messageInput = app.textFields["Message"]
        XCTAssertTrue(messageInput.waitForExistence(timeout: 5))
    }
    
    private func waitForMessageToAppear(_ messageText: String) throws {
        let messageBubble = app.staticTexts[messageText]
        XCTAssertTrue(messageBubble.waitForExistence(timeout: 10))
    }
}
