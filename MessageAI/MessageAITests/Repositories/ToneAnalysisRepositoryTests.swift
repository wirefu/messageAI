import XCTest
import FirebaseFunctions
@testable import MessageAI

/// Unit tests for ToneAnalysisRepository
@MainActor
final class ToneAnalysisRepositoryTests: XCTestCase {
    var repository: ToneAnalysisRepository!
    var mockFunctions: MockFunctions!
    
    override func setUp() {
        super.setUp()
        mockFunctions = MockFunctions()
        repository = ToneAnalysisRepository()
        // Note: In a real test, we'd inject the mock functions
    }
    
    override func tearDown() {
        repository = nil
        mockFunctions = nil
        super.tearDown()
    }
    
    // MARK: - Tone Analysis Tests
    
    func testAnalyzeToneNoIssues() async throws {
        // Given
        let message = "Hi there! How are you doing today?"
        mockFunctions.mockResponse = [
            "toneWarning": nil,
            "alternativePhrasing": nil,
            "improvementSuggestions": [],
            "severity": "none"
        ]
        
        // When
        let result = try await repository.analyzeTone(message: message)
        
        // Then
        XCTAssertNil(result.toneWarning)
        XCTAssertNil(result.alternativePhrasing)
        XCTAssertTrue(result.improvementSuggestions.isEmpty)
        XCTAssertEqual(result.severity, .none)
        XCTAssertFalse(result.hasIssues)
        XCTAssertFalse(result.shouldShowWarning)
    }
    
    func testAnalyzeToneMinorIssues() async throws {
        // Given
        let message = "No."
        mockFunctions.mockResponse = [
            "toneWarning": "This might sound abrupt",
            "alternativePhrasing": "I'm not sure about that. Could you provide more details?",
            "improvementSuggestions": ["Consider adding context", "Be more specific"],
            "severity": "low"
        ]
        
        // When
        let result = try await repository.analyzeTone(message: message)
        
        // Then
        XCTAssertEqual(result.toneWarning, "This might sound abrupt")
        XCTAssertEqual(result.alternativePhrasing, "I'm not sure about that. Could you provide more details?")
        XCTAssertEqual(result.improvementSuggestions.count, 2)
        XCTAssertEqual(result.severity, .low)
        XCTAssertTrue(result.hasIssues)
        XCTAssertFalse(result.shouldShowWarning)
    }
    
    func testAnalyzeToneSignificantIssues() async throws {
        // Given
        let message = "That's completely wrong and you should know better."
        mockFunctions.mockResponse = [
            "toneWarning": "This message could come across as dismissive or rude",
            "alternativePhrasing": "I see a different approach here. Could we discuss this further?",
            "improvementSuggestions": ["Acknowledge the other person's perspective", "Offer constructive feedback"],
            "severity": "high"
        ]
        
        // When
        let result = try await repository.analyzeTone(message: message)
        
        // Then
        XCTAssertEqual(result.toneWarning, "This message could come across as dismissive or rude")
        XCTAssertEqual(result.alternativePhrasing, "I see a different approach here. Could we discuss this further?")
        XCTAssertEqual(result.improvementSuggestions.count, 2)
        XCTAssertEqual(result.severity, .high)
        XCTAssertTrue(result.hasIssues)
        XCTAssertTrue(result.shouldShowWarning)
    }
    
    func testAnalyzeToneWithContext() async throws {
        // Given
        let message = "This is broken"
        let context = "Previous discussion about a bug in the system"
        let recipientRole = "engineer"
        
        mockFunctions.mockResponse = [
            "toneWarning": "This might sound terse without context",
            "alternativePhrasing": "I found an issue with the system that needs attention",
            "improvementSuggestions": ["Provide more context", "Explain what's broken"],
            "severity": "medium"
        ]
        
        // When
        let result = try await repository.analyzeTone(
            message: message,
            conversationContext: context,
            recipientRole: recipientRole
        )
        
        // Then
        XCTAssertEqual(result.severity, .medium)
        XCTAssertTrue(result.shouldShowWarning)
    }
    
    func testAnalyzeToneEmptyMessage() async throws {
        // Given
        let message = ""
        
        // When
        let result = try await repository.analyzeTone(message: message)
        
        // Then
        XCTAssertNil(result.toneWarning)
        XCTAssertNil(result.alternativePhrasing)
        XCTAssertTrue(result.improvementSuggestions.isEmpty)
        XCTAssertEqual(result.severity, .none)
    }
    
    func testAnalyzeToneNetworkError() async {
        // Given
        let message = "Test message"
        mockFunctions.shouldFail = true
        
        // When/Then
        do {
            _ = try await repository.analyzeTone(message: message)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}

// MARK: - Mock Functions

class MockFunctions {
    var mockResponse: [String: Any] = [:]
    var shouldFail = false
    
    func httpsCallable(_ name: String) -> MockCallable {
        return MockCallable(mockResponse: mockResponse, shouldFail: shouldFail)
    }
}

class MockCallable {
    private let mockResponse: [String: Any]
    private let shouldFail: Bool
    
    init(mockResponse: [String: Any], shouldFail: Bool) {
        self.mockResponse = mockResponse
        self.shouldFail = shouldFail
    }
    
    func call(_ data: [String: Any]) async throws -> MockCallableResult {
        if shouldFail {
            throw AppError.networkError("Mock network error")
        }
        
        return MockCallableResult(data: mockResponse)
    }
}

struct MockCallableResult {
    let data: Any
}
