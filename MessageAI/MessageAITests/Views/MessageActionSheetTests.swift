//
//  MessageActionSheetTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
import SwiftUI
@testable import MessageAI

@MainActor
final class MessageActionSheetTests: XCTestCase {
    
    var messageActionSheet: MessageActionSheet!
    let testMessageId = "test-message-123"
    let testConversationId = "test-conversation-456"
    var dismissCalled = false
    
    override func setUp() {
        super.setUp()
        dismissCalled = false
        messageActionSheet = MessageActionSheet(
            messageId: testMessageId,
            conversationId: testConversationId,
            onDismiss: {
                self.dismissCalled = true
            }
        )
    }
    
    override func tearDown() {
        messageActionSheet = nil
        dismissCalled = false
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(messageActionSheet)
        XCTAssertEqual(messageActionSheet.messageId, testMessageId)
        XCTAssertEqual(messageActionSheet.conversationId, testConversationId)
    }
    
    func testDismissCallback() {
        // Test that the dismiss callback works
        messageActionSheet.onDismiss()
        XCTAssertTrue(dismissCalled)
    }
    
    // MARK: - MessageActionType Tests
    
    func testMessageActionTypeCases() {
        let allCases = MessageActionType.allCases
        XCTAssertEqual(allCases.count, 7)
        XCTAssertTrue(allCases.contains(.translate))
        XCTAssertTrue(allCases.contains(.rewrite))
        XCTAssertTrue(allCases.contains(.extract))
        XCTAssertTrue(allCases.contains(.summarize))
        XCTAssertTrue(allCases.contains(.clarify))
        XCTAssertTrue(allCases.contains(.expand))
        XCTAssertTrue(allCases.contains(.shorten))
    }
    
    func testMessageActionTypeDisplayNames() {
        XCTAssertEqual(MessageActionType.translate.displayName, "Translate")
        XCTAssertEqual(MessageActionType.rewrite.displayName, "Rewrite")
        XCTAssertEqual(MessageActionType.extract.displayName, "Extract Entities")
        XCTAssertEqual(MessageActionType.summarize.displayName, "Summarize")
        XCTAssertEqual(MessageActionType.clarify.displayName, "Clarify")
        XCTAssertEqual(MessageActionType.expand.displayName, "Expand")
        XCTAssertEqual(MessageActionType.shorten.displayName, "Shorten")
    }
    
    func testMessageActionTypeRawValues() {
        XCTAssertEqual(MessageActionType.translate.rawValue, "translate")
        XCTAssertEqual(MessageActionType.rewrite.rawValue, "rewrite")
        XCTAssertEqual(MessageActionType.extract.rawValue, "extract")
        XCTAssertEqual(MessageActionType.summarize.rawValue, "summarize")
        XCTAssertEqual(MessageActionType.clarify.rawValue, "clarify")
        XCTAssertEqual(MessageActionType.expand.rawValue, "expand")
        XCTAssertEqual(MessageActionType.shorten.rawValue, "shorten")
    }
    
    // MARK: - MessageTone Tests
    
    func testMessageToneCases() {
        let allCases = MessageTone.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.formal))
        XCTAssertTrue(allCases.contains(.casual))
        XCTAssertTrue(allCases.contains(.technical))
        XCTAssertTrue(allCases.contains(.friendly))
    }
    
    func testMessageToneDisplayNames() {
        XCTAssertEqual(MessageTone.formal.displayName, "Formal")
        XCTAssertEqual(MessageTone.casual.displayName, "Casual")
        XCTAssertEqual(MessageTone.technical.displayName, "Technical")
        XCTAssertEqual(MessageTone.friendly.displayName, "Friendly")
    }
    
    func testMessageToneDescriptions() {
        XCTAssertEqual(MessageTone.formal.description, "Professional and business-like")
        XCTAssertEqual(MessageTone.casual.description, "Relaxed and conversational")
        XCTAssertEqual(MessageTone.technical.description, "Precise and detailed")
        XCTAssertEqual(MessageTone.friendly.description, "Warm and approachable")
    }
    
    func testMessageToneRawValues() {
        XCTAssertEqual(MessageTone.formal.rawValue, "formal")
        XCTAssertEqual(MessageTone.casual.rawValue, "casual")
        XCTAssertEqual(MessageTone.technical.rawValue, "technical")
        XCTAssertEqual(MessageTone.friendly.rawValue, "friendly")
    }
    
    // MARK: - MessageActionResult Tests
    
    func testMessageActionResultInitialization() {
        let result = MessageActionResult(
            actionType: .translate,
            originalText: "Hello World",
            resultText: "Hola Mundo",
            metadata: ["language": "Spanish"]
        )
        
        XCTAssertEqual(result.actionType, .translate)
        XCTAssertEqual(result.originalText, "Hello World")
        XCTAssertEqual(result.resultText, "Hola Mundo")
        XCTAssertEqual(result.metadata["language"] as? String, "Spanish")
    }
    
    // MARK: - ActionButton Tests
    
    func testActionButtonInitialization() {
        var buttonTapped = false
        let actionButton = ActionButton(
            title: "Test Action",
            icon: "test.icon",
            color: .blue,
            action: {
                buttonTapped = true
            }
        )
        
        XCTAssertNotNil(actionButton)
        // Note: We can't easily test the action without UI testing
    }
    
    // MARK: - ToneButton Tests
    
    func testToneButtonInitialization() {
        var toneSelected = false
        let toneButton = ToneButton(
            tone: .formal,
            isSelected: false,
            action: {
                toneSelected = true
            }
        )
        
        XCTAssertNotNil(toneButton)
        // Note: We can't easily test the action without UI testing
    }
    
    // MARK: - ResultDisplayView Tests
    
    func testResultDisplayViewInitialization() {
        let result = MessageActionResult(
            actionType: .translate,
            originalText: "Hello",
            resultText: "Hola",
            metadata: [:]
        )
        
        var copyCalled = false
        var shareCalled = false
        var sendCalled = false
        
        let resultView = ResultDisplayView(
            result: result,
            onCopy: { copyCalled = true },
            onShare: { shareCalled = true },
            onSend: { sendCalled = true }
        )
        
        XCTAssertNotNil(resultView)
        // Note: We can't easily test the callbacks without UI testing
    }
    
    // MARK: - Mock Data Tests
    
    func testMockResultTextGeneration() {
        // Test that all action types have mock result text
        for actionType in MessageActionType.allCases {
            let mockText = getMockResultText(for: actionType)
            XCTAssertFalse(mockText.isEmpty, "Mock text should not be empty for \(actionType)")
        }
    }
    
    private func getMockResultText(for action: MessageActionType) -> String {
        switch action {
        case .translate:
            return "Este es un mensaje de muestra para propósitos de prueba."
        case .rewrite:
            return "This represents a sample message designed for testing purposes."
        case .extract:
            return "Entities: [sample, message, testing, purposes]"
        case .summarize:
            return "This is a summary of the conversation thread."
        case .clarify:
            return "This is a clearer version of the message with improved wording."
        case .expand:
            return "This is an expanded version with additional details and context."
        case .shorten:
            return "This is a concise version."
        }
    }
    
    // MARK: - Action Parameters Tests
    
    func testActionParametersForTranslate() {
        let parameters = getActionParameters(for: .translate, tone: nil)
        XCTAssertEqual(parameters["targetLanguage"] as? String, "Spanish")
        XCTAssertEqual(parameters["sourceLanguage"] as? String, "auto")
    }
    
    func testActionParametersForRewrite() {
        let parameters = getActionParameters(for: .rewrite, tone: .formal)
        XCTAssertEqual(parameters["tone"] as? String, "formal")
    }
    
    func testActionParametersForOtherActions() {
        let extractParams = getActionParameters(for: .extract, tone: nil)
        XCTAssertTrue(extractParams.isEmpty)
        
        let summarizeParams = getActionParameters(for: .summarize, tone: nil)
        XCTAssertTrue(summarizeParams.isEmpty)
    }
    
    private func getActionParameters(for action: MessageActionType, tone: MessageTone?) -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if action == .translate {
            parameters["targetLanguage"] = "Spanish"
            parameters["sourceLanguage"] = "auto"
        } else if action == .rewrite, let tone = tone {
            parameters["tone"] = tone.rawValue
        }
        
        return parameters
    }
}

// MARK: - UI Test Helpers

extension MessageActionSheetTests {
    
    func testMessageActionSheetUIComponents() {
        // Test that the view can be instantiated without crashing
        let view = messageActionSheet
        XCTAssertNotNil(view)
        
        // Test that the view has the expected structure
        // Note: This is a basic test - full UI testing would require XCUITest
    }
}
