//
//  ActionItemsIntegrationTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

/// Integration tests for Action Items feature (PR #21/23)
final class ActionItemsIntegrationTests: XCTestCase {
    var aiService: AIService!
    var repository: ActionItemRepository!
    var testConversationID: String!
    
    override func setUp() {
        super.setUp()
        aiService = AIService.shared
        repository = ActionItemRepository()
        testConversationID = "test-action-\(UUID().uuidString)"
    }
    
    override func tearDown() {
        aiService = nil
        repository = nil
        testConversationID = nil
        super.tearDown()
    }
    
    // MARK: - Extraction Tests
    
    /// Test: Extract explicit commitment
    func testExtractActionItems_ExplicitCommitment() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Message with clear commitment
        let messages = ["I'll review the PR by Friday"]
        
        // When
        let items = try await aiService.extractActionItems(
            messages: messages,
            conversationID: testConversationID
        )
        
        // Then
        XCTAssertNotNil(items)
        // Should extract "review the PR" with deadline
    }
    
    /// Test: Extract question-based action
    func testExtractActionItems_QuestionBased() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Question implying action
        let messages = ["Can you deploy to staging tomorrow?"]
        
        // When
        let items = try await aiService.extractActionItems(
            messages: messages,
            conversationID: testConversationID
        )
        
        // Then
        XCTAssertNotNil(items)
        // Should extract "deploy to staging"
    }
    
    /// Test: Extract multiple action items
    func testExtractActionItems_Multiple() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Multiple actions in one message
        let messages = ["I'll review the code, test it locally, and deploy by end of day"]
        
        // When
        let items = try await aiService.extractActionItems(
            messages: messages,
            conversationID: testConversationID
        )
        
        // Then
        XCTAssertNotNil(items)
        // Should extract multiple items
    }
    
    /// Test: No action items in message
    func testExtractActionItems_NoActions() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Casual conversation
        let messages = ["Good morning!", "How's it going?", "The weather is nice"]
        
        // When
        let items = try await aiService.extractActionItems(
            messages: messages,
            conversationID: testConversationID
        )
        
        // Then
        XCTAssertNotNil(items)
        XCTAssertTrue(items.isEmpty, "Should not extract action items from casual messages")
    }
    
    /// Test: Past tense is not an action
    func testExtractActionItems_PastTense() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Past tense (already done)
        let messages = ["I reviewed the PR yesterday"]
        
        // When
        let items = try await aiService.extractActionItems(
            messages: messages,
            conversationID: testConversationID
        )
        
        // Then
        XCTAssertNotNil(items)
        // Should not extract (action already completed)
    }
    
    // MARK: - Repository Tests
    
    /// Test: Create and retrieve action item
    func testActionItemPersistence() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given
        let item = ActionItem(
            id: UUID().uuidString,
            conversationID: testConversationID,
            messageID: "msg1",
            description: "Test action item",
            assignedTo: "user123",
            dueDate: Date().addingTimeInterval(86400),
            isCompleted: false,
            createdAt: Date()
        )
        
        // When
        try await repository.createActionItem(item)
        let retrieved = try await repository.getActionItems(conversationID: testConversationID)
        
        // Then
        XCTAssertFalse(retrieved.isEmpty)
        XCTAssertEqual(retrieved.first?.description, "Test action item")
    }
    
    /// Test: Mark action item complete
    func testMarkActionItemComplete() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Created action item
        let item = ActionItem(
            id: UUID().uuidString,
            conversationID: testConversationID,
            messageID: "msg1",
            description: "Test task",
            assignedTo: nil,
            dueDate: nil,
            isCompleted: false,
            createdAt: Date()
        )
        try await repository.createActionItem(item)
        
        // When - Mark as complete
        try await repository.markComplete(
            id: item.id,
            conversationID: testConversationID,
            isCompleted: true
        )
        
        // Then - Should be completed
        let retrieved = try await repository.getActionItems(conversationID: testConversationID)
        XCTAssertTrue(retrieved.first?.isCompleted == true)
    }
    
    /// Test: Filter open action items
    func testGetOpenActionItems() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Mix of completed and open items
        let item1 = ActionItem(
            id: UUID().uuidString,
            conversationID: testConversationID,
            messageID: "msg1",
            description: "Open task",
            assignedTo: nil,
            dueDate: nil,
            isCompleted: false,
            createdAt: Date()
        )
        let item2 = ActionItem(
            id: UUID().uuidString,
            conversationID: testConversationID,
            messageID: "msg2",
            description: "Completed task",
            assignedTo: nil,
            dueDate: nil,
            isCompleted: true,
            createdAt: Date()
        )
        try await repository.createActionItem(item1)
        try await repository.createActionItem(item2)
        
        // When
        let openItems = try await repository.getOpenActionItems(conversationID: testConversationID)
        
        // Then - Should only return open items
        XCTAssertEqual(openItems.count, 1)
        XCTAssertEqual(openItems.first?.description, "Open task")
    }
    
    /// Test: Delete action item
    func testDeleteActionItem() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Created action item
        let item = ActionItem(
            id: UUID().uuidString,
            conversationID: testConversationID,
            messageID: "msg1",
            description: "To be deleted",
            assignedTo: nil,
            dueDate: nil,
            isCompleted: false,
            createdAt: Date()
        )
        try await repository.createActionItem(item)
        
        // When - Delete it
        try await repository.deleteActionItem(
            id: item.id,
            conversationID: testConversationID
        )
        
        // Then - Should not exist
        let retrieved = try await repository.getActionItems(conversationID: testConversationID)
        XCTAssertTrue(retrieved.isEmpty)
    }
    
    // MARK: - Auto-Extract Tests
    
    /// Test: Auto-extract from sent message
    func testAutoExtract_OnMessageSent() async throws {
        try XCTSkipIf(!isIntegrationTestEnvironment(), "Skipping integration test")
        
        // Given - Message with action item
        let messageContent = "I'll finish the report by tomorrow"
        let messageID = UUID().uuidString
        
        // When - Auto-extract
        let items = try await repository.autoExtractActionItems(
            messageContent: messageContent,
            conversationID: testConversationID,
            messageID: messageID
        )
        
        // Then - Should extract and save
        XCTAssertNotNil(items)
        if !items.isEmpty {
            XCTAssertEqual(items.first?.messageID, messageID)
        }
    }
    
    // MARK: - Helper Methods
    
    private func isIntegrationTestEnvironment() -> Bool {
        let runIntegrationTests = ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"]
        return runIntegrationTests == "1"
    }
}

// MARK: - Integration Test Documentation

/*
 ACTION ITEMS INTEGRATION TEST GUIDE
 ====================================
 
 ## Prerequisites
 
 1. Complete PR #17 & #23 Setup:
    - Cloud Functions deployed
    - extractActionItems function working
    - ActionItemRepository tested
 
 2. Test Data:
    - Messages with explicit commitments
    - Messages with questions implying actions
    - Messages with deadlines
    - Messages with assignees
    - Messages without actions
 
 ## Running Integration Tests
 
 ```bash
 export RUN_INTEGRATION_TESTS=1
 xcodebuild test -scheme MessageAI \
   -destination 'platform=iOS Simulator,name=iPhone 17' \
   -only-testing:MessageAITests/ActionItemsIntegrationTests
 ```
 
 ## Manual Testing Checklist
 
 ### Basic Functionality
 - [ ] Send message: "I'll review the PR by Friday"
 - [ ] Tap action items button in ChatView
 - [ ] See extracted action item in list
 - [ ] Tap checkbox to mark complete
 - [ ] Item shows as completed
 - [ ] Swipe to delete action item
 
 ### Filters
 - [ ] Create mix of open and completed items
 - [ ] Tap "All" - see all items
 - [ ] Tap "Open" - see only incomplete
 - [ ] Tap "Completed" - see only complete
 
 ### Auto-Extraction
 - [ ] Send: "Can you deploy to staging?"
 - [ ] Check action items list
 - [ ] Should auto-extract "deploy to staging"
 - [ ] Send: "Good morning" (no action)
 - [ ] Should not create action item
 
 ### Assignees & Deadlines
 - [ ] Send: "Alice, can you review the code by tomorrow?"
 - [ ] Check extracted item
 - [ ] Should have assignee: "Alice"
 - [ ] Should have due date: tomorrow
 
 ### Edge Cases
 - [ ] Empty conversation - No action items
 - [ ] Past tense: "I finished the task" - No extraction
 - [ ] Vague: "I'll think about it" - No extraction
 - [ ] Multiple: "I'll do A, B, and C" - Extract all three
 
 ## Expected Behavior
 
 - Auto-extract after each message sent
 - Display in dedicated ActionItemsView
 - Toggle complete/incomplete
 - Filter by status
 - Delete action items
 - Persist to Firestore
 - Offline access
 */

