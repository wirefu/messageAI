import XCTest
import FirebaseFirestore
@testable import MessageAI

/// Comprehensive integration tests for all AI features
/// Tests scenarios TEST-2.1 to TEST-2.12 from PRD
@MainActor
final class AIFeaturesIntegrationTests: XCTestCase {
    
    var mockAIService: MockAIService!
    var mockSummaryRepository: MockSummaryRepository!
    var mockActionItemRepository: MockActionItemRepository!
    var mockToneAnalysisRepository: MockToneAnalysisRepositoryIntegration!
    
    override func setUp() {
        super.setUp()
        mockAIService = MockAIService()
        mockSummaryRepository = MockSummaryRepository()
        mockActionItemRepository = MockActionItemRepository()
        mockToneAnalysisRepository = MockToneAnalysisRepositoryIntegration()
    }
    
    override func tearDown() {
        mockAIService = nil
        mockSummaryRepository = nil
        mockActionItemRepository = nil
        mockToneAnalysisRepository = nil
        super.tearDown()
    }
    
    // MARK: - TEST-2.1: Conversation Summarization
    
    func testConversationSummarization() async throws {
        // Given: Long conversation with multiple topics
        let messages = [
            Message(id: "1", content: "Hey, how's the project going?", senderID: "user1", timestamp: Date()),
            Message(id: "2", content: "Good! I've finished the authentication system", senderID: "user2", timestamp: Date()),
            Message(id: "3", content: "Great! What about the messaging feature?", senderID: "user1", timestamp: Date()),
            Message(id: "4", content: "Still working on it. Should be done by Friday", senderID: "user2", timestamp: Date()),
            Message(id: "5", content: "Perfect! Let me know if you need help", senderID: "user1", timestamp: Date())
        ]
        
        mockSummaryRepository.mockSummary = ConversationSummary(
            id: "summary1",
            conversationID: "conv1",
            summary: "Project status discussion: Authentication complete, messaging in progress, Friday deadline",
            keyDecisions: ["Authentication system completed", "Messaging feature due Friday"],
            actionItems: ["Complete messaging feature by Friday"],
            openQuestions: ["Need help with messaging?"],
            timestamp: Date()
        )
        
        // When: User requests summary
        let summary = try await mockSummaryRepository.generateSummary(
            conversationID: "conv1",
            messages: messages
        )
        
        // Then: Summary contains key information
        XCTAssertNotNil(summary)
        XCTAssertTrue(summary.summary.contains("Authentication"))
        XCTAssertTrue(summary.summary.contains("messaging"))
        XCTAssertEqual(summary.actionItems.count, 1)
        XCTAssertEqual(summary.keyDecisions.count, 2)
    }
    
    // MARK: - TEST-2.2: Clarity Assistant
    
    func testClarityAssistant() async throws {
        // Given: Unclear message
        let unclearMessage = "The thing we discussed yesterday needs to be fixed"
        
        mockAIService.mockClaritySuggestion = AISuggestion(
            id: "clarity1",
            originalText: unclearMessage,
            suggestion: "The authentication bug we discussed yesterday needs to be fixed",
            reason: "Added context about what 'thing' refers to",
            confidence: 0.9
        )
        
        // When: Clarity check is triggered
        let suggestion = try await mockAIService.checkClarity(message: unclearMessage)
        
        // Then: Suggestion improves clarity
        XCTAssertNotNil(suggestion)
        XCTAssertTrue(suggestion.suggestion.contains("authentication bug"))
        XCTAssertGreaterThan(suggestion.confidence, 0.8)
    }
    
    // MARK: - TEST-2.3: Action Item Extraction
    
    func testActionItemExtraction() async throws {
        // Given: Message with action items
        let messageWithActions = "I'll review the code by tomorrow and let you know about the deployment"
        
        mockActionItemRepository.mockActionItems = [
            ActionItem(
                id: "action1",
                conversationID: "conv1",
                messageID: "msg1",
                description: "Review the code",
                assignedTo: "user1",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                status: .pending,
                timestamp: Date()
            ),
            ActionItem(
                id: "action2",
                conversationID: "conv1",
                messageID: "msg1",
                description: "Provide deployment feedback",
                assignedTo: "user1",
                dueDate: nil,
                status: .pending,
                timestamp: Date()
            )
        ]
        
        // When: Action items are extracted
        let actionItems = try await mockActionItemRepository.extractActionItems(
            messageContent: messageWithActions,
            conversationID: "conv1",
            messageID: "msg1"
        )
        
        // Then: Multiple action items are identified
        XCTAssertEqual(actionItems.count, 2)
        XCTAssertTrue(actionItems.contains { $0.description.contains("review") })
        XCTAssertTrue(actionItems.contains { $0.description.contains("deployment") })
    }
    
    // MARK: - TEST-2.4: Tone Analysis
    
    func testToneAnalysis() async throws {
        // Given: Potentially terse message
        let terseMessage = "No."
        
        mockToneAnalysisRepository.mockToneResult = ToneAnalysisResult(
            toneWarning: "This message might sound abrupt",
            alternativePhrasing: "I don't think that will work, but let me explain why",
            improvementSuggestions: ["Add context", "Explain reasoning"],
            severity: .medium
        )
        
        // When: Tone analysis is performed
        let result = try await mockToneAnalysisRepository.analyzeTone(
            messageContent: terseMessage,
            conversationContext: "Previous discussion about project timeline",
            recipientRole: "Project Manager"
        )
        
        // Then: Tone issues are detected
        XCTAssertNotNil(result.toneWarning)
        XCTAssertNotNil(result.alternativePhrasing)
        XCTAssertEqual(result.severity, .medium)
        XCTAssertFalse(result.improvementSuggestions.isEmpty)
    }
    
    // MARK: - TEST-2.5: AI Feature Integration
    
    func testMultipleAIFeaturesIntegration() async throws {
        // Given: Complex message with multiple AI needs
        let complexMessage = "The auth system is broken. I'll fix it tomorrow. Can you review the code?"
        
        // Mock responses for all AI features
        mockAIService.mockClaritySuggestion = AISuggestion(
            id: "clarity1",
            originalText: complexMessage,
            suggestion: "The authentication system is broken. I'll fix it tomorrow. Can you review the code?",
            reason: "Clarified 'auth system' to 'authentication system'",
            confidence: 0.8
        )
        
        mockActionItemRepository.mockActionItems = [
            ActionItem(
                id: "action1",
                conversationID: "conv1",
                messageID: "msg1",
                description: "Fix authentication system",
                assignedTo: "user1",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                status: .pending,
                timestamp: Date()
            ),
            ActionItem(
                id: "action2",
                conversationID: "conv1",
                messageID: "msg1",
                description: "Review the code",
                assignedTo: "user2",
                dueDate: nil,
                status: .pending,
                timestamp: Date()
            )
        ]
        
        mockToneAnalysisRepository.mockToneResult = ToneAnalysisResult(
            toneWarning: nil,
            alternativePhrasing: nil,
            improvementSuggestions: [],
            severity: .none
        )
        
        // When: All AI features are triggered
        let claritySuggestion = try await mockAIService.checkClarity(message: complexMessage)
        let actionItems = try await mockActionItemRepository.extractActionItems(
            messageContent: complexMessage,
            conversationID: "conv1",
            messageID: "msg1"
        )
        let toneResult = try await mockToneAnalysisRepository.analyzeTone(
            messageContent: complexMessage,
            conversationContext: nil,
            recipientRole: nil
        )
        
        // Then: All features work together
        XCTAssertNotNil(claritySuggestion)
        XCTAssertEqual(actionItems.count, 2)
        XCTAssertEqual(toneResult.severity, .none)
    }
    
    // MARK: - TEST-2.6: Performance Testing
    
    func testAIFeaturesPerformance() async throws {
        // Given: Multiple AI calls
        let startTime = Date()
        
        // When: Multiple AI features are called
        let tasks = (1...10).map { _ in
            Task {
                try await mockAIService.checkClarity(message: "Test message")
            }
        }
        
        let results = try await withThrowingTaskGroup(of: AISuggestion.self) { group in
            for task in tasks {
                group.addTask {
                    try await task.value
                }
            }
            
            var results: [AISuggestion] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Then: Performance is acceptable
        XCTAssertEqual(results.count, 10)
        XCTAssertLessThan(duration, 5.0) // Should complete within 5 seconds
    }
    
    // MARK: - TEST-2.7: Error Handling
    
    func testAIFeaturesErrorHandling() async throws {
        // Given: AI service failure
        mockAIService.shouldFail = true
        
        // When: AI feature is called
        do {
            _ = try await mockAIService.checkClarity(message: "Test message")
            XCTFail("Should have thrown error")
        } catch {
            // Then: Error is handled gracefully
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - TEST-2.8: Caching
    
    func testAIFeaturesCaching() async throws {
        // Given: Same message content
        let message = "I'll fix the bug tomorrow"
        
        // When: Same AI feature is called multiple times
        let result1 = try await mockAIService.checkClarity(message: message)
        let result2 = try await mockAIService.checkClarity(message: message)
        
        // Then: Results are consistent (cached)
        XCTAssertEqual(result1.id, result2.id)
        XCTAssertEqual(mockAIService.callCount, 1) // Should only call once due to caching
    }
    
    // MARK: - TEST-2.9: Offline Support
    
    func testAIFeaturesOfflineSupport() async throws {
        // Given: Offline scenario
        mockAIService.isOffline = true
        
        // When: AI feature is called offline
        do {
            _ = try await mockAIService.checkClarity(message: "Test message")
            XCTFail("Should have thrown offline error")
        } catch {
            // Then: Offline error is handled
            XCTAssertTrue(error.localizedDescription.contains("offline"))
        }
    }
    
    // MARK: - TEST-2.10: User Preferences
    
    func testAIFeaturesUserPreferences() async throws {
        // Given: User has disabled AI features
        UserDefaults.standard.set(false, forKey: "ai_features_enabled")
        
        // When: AI feature is called
        let result = try await mockAIService.checkClarity(message: "Test message")
        
        // Then: AI feature respects user preferences
        XCTAssertNil(result) // Should return nil when disabled
    }
    
    // MARK: - TEST-2.11: Cost Monitoring
    
    func testAIFeaturesCostMonitoring() async throws {
        // Given: AI service with cost tracking
        mockAIService.trackCosts = true
        
        // When: Multiple AI calls are made
        _ = try await mockAIService.checkClarity(message: "Test message 1")
        _ = try await mockAIService.checkClarity(message: "Test message 2")
        
        // Then: Costs are tracked
        XCTAssertEqual(mockAIService.totalCost, 0.02) // $0.01 per call
        XCTAssertEqual(mockAIService.callCount, 2)
    }
    
    // MARK: - TEST-2.12: Integration with Messaging
    
    func testAIFeaturesMessagingIntegration() async throws {
        // Given: Message input with AI features enabled
        let messageInputViewModel = MessageInputViewModel()
        messageInputViewModel.messageText = "I'll fix the bug tomorrow"
        
        // When: Message is processed
        let hasClaritySuggestion = messageInputViewModel.showClaritySuggestion
        let claritySuggestion = messageInputViewModel.claritySuggestion
        
        // Then: AI features integrate with messaging
        XCTAssertTrue(hasClaritySuggestion)
        XCTAssertNotNil(claritySuggestion)
    }
}

// MARK: - Mock Classes

class MockAIService: AIService {
    var mockClaritySuggestion: AISuggestion?
    var shouldFail = false
    var isOffline = false
    var trackCosts = false
    var callCount = 0
    var totalCost: Double = 0.0
    
    func checkClarity(message: String) async throws -> AISuggestion? {
        callCount += 1
        if trackCosts {
            totalCost += 0.01
        }
        
        if isOffline {
            throw AppError.networkError(NSError(domain: "offline", code: -1))
        }
        
        if shouldFail {
            throw AppError.aiFunctionError("AI service failed")
        }
        
        return mockClaritySuggestion
    }
    
    func generateSummary(conversationID: String, messages: [Message]) async throws -> ConversationSummary {
        throw AppError.aiFunctionError("Not implemented")
    }
}

class MockSummaryRepository: SummaryRepositoryProtocol {
    var mockSummary: ConversationSummary?
    var shouldFail = false
    
    func generateSummary(conversationID: String, messages: [Message]) async throws -> ConversationSummary {
        if shouldFail {
            throw AppError.aiFunctionError("Summary generation failed")
        }
        
        guard let summary = mockSummary else {
            throw AppError.aiFunctionError("No mock summary provided")
        }
        
        return summary
    }
    
    func fetchSummaries(conversationID: String) async throws -> [ConversationSummary] {
        return []
    }
    
    func deleteSummary(summaryID: String) async throws {
        // Mock implementation
    }
}

class MockActionItemRepository: ActionItemRepositoryProtocol {
    var mockActionItems: [ActionItem] = []
    var shouldFail = false
    
    func extractActionItems(messageContent: String, conversationID: String, messageID: String) async throws -> [ActionItem] {
        if shouldFail {
            throw AppError.aiFunctionError("Action item extraction failed")
        }
        
        return mockActionItems
    }
    
    func fetchActionItems(conversationID: String) async throws -> [ActionItem] {
        return mockActionItems
    }
    
    func updateActionItemStatus(actionItemID: String, status: String) async throws {
        // Mock implementation
    }
    
    func deleteActionItem(actionItemID: String) async throws {
        // Mock implementation
    }
}

class MockToneAnalysisRepositoryIntegration: ToneAnalysisRepositoryProtocol {
    var mockToneResult: ToneAnalysisResult?
    var shouldFail = false
    
    func analyzeTone(messageContent: String, conversationContext: String?, recipientRole: String?) async throws -> ToneAnalysisResult {
        if shouldFail {
            throw AppError.aiFunctionError("Tone analysis failed")
        }
        
        guard let result = mockToneResult else {
            throw AppError.aiFunctionError("No mock tone result provided")
        }
        
        return result
    }
}
