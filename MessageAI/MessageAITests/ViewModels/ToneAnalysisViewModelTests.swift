import XCTest
@testable import MessageAI

/// Unit tests for ToneAnalysisViewModel
@MainActor
final class ToneAnalysisViewModelTests: XCTestCase {
    var viewModel: ToneAnalysisViewModel!
    var mockRepository: MockToneAnalysisRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockToneAnalysisRepository()
        viewModel = ToneAnalysisViewModel(toneRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Analysis Tests
    
    func testAnalyzeToneSuccess() async {
        // Given
        let message = "This is a test message"
        let expectedResult = ToneAnalysisResult(
            toneWarning: "Minor tone issue",
            alternativePhrasing: "Here's a better way to say it",
            improvementSuggestions: ["Be more specific"],
            severity: .low
        )
        mockRepository.mockResult = expectedResult
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertFalse(viewModel.isAnalyzing)
        XCTAssertNil(viewModel.error)
        XCTAssertNotNil(viewModel.analysisResult)
        XCTAssertEqual(viewModel.analysisResult?.toneWarning, "Minor tone issue")
        XCTAssertTrue(viewModel.shouldShowAnalysis)
        XCTAssertFalse(viewModel.shouldShowWarning)
    }
    
    func testAnalyzeToneWithWarning() async {
        // Given
        let message = "That's wrong"
        let expectedResult = ToneAnalysisResult(
            toneWarning: "This could sound dismissive",
            alternativePhrasing: "I see a different approach",
            improvementSuggestions: ["Acknowledge the other person"],
            severity: .high
        )
        mockRepository.mockResult = expectedResult
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.shouldShowAnalysis)
        XCTAssertTrue(viewModel.shouldShowWarning)
    }
    
    func testAnalyzeToneNoIssues() async {
        // Given
        let message = "Hi there! How are you doing?"
        let expectedResult = ToneAnalysisResult(
            toneWarning: nil,
            alternativePhrasing: nil,
            improvementSuggestions: [],
            severity: .none
        )
        mockRepository.mockResult = expectedResult
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.shouldShowAnalysis)
        XCTAssertFalse(viewModel.shouldShowWarning)
    }
    
    func testAnalyzeToneEmptyMessage() async {
        // Given
        let message = ""
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Then
        XCTAssertNil(viewModel.analysisResult)
        XCTAssertFalse(viewModel.isAnalyzing)
    }
    
    func testAnalyzeToneWhitespaceOnly() async {
        // Given
        let message = "   \n  "
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Then
        XCTAssertNil(viewModel.analysisResult)
        XCTAssertFalse(viewModel.isAnalyzing)
    }
    
    func testAnalyzeToneError() async {
        // Given
        let message = "Test message"
        mockRepository.shouldFail = true
        mockRepository.mockError = AppError.networkError("Test error")
        
        // When
        viewModel.analyzeTone(message: message)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isAnalyzing)
        XCTAssertNotNil(viewModel.error)
        XCTAssertNil(viewModel.analysisResult)
    }
    
    func testClearAnalysis() async {
        // Given
        let message = "Test message"
        let expectedResult = ToneAnalysisResult(
            toneWarning: "Test warning",
            alternativePhrasing: "Test alternative",
            improvementSuggestions: ["Test suggestion"],
            severity: .medium
        )
        mockRepository.mockResult = expectedResult
        
        viewModel.analyzeTone(message: message)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        viewModel.clearAnalysis()
        
        // Then
        XCTAssertNil(viewModel.analysisResult)
        XCTAssertNil(viewModel.error)
    }
    
    func testAnalyzeToneWithContext() async {
        // Given
        let message = "This is broken"
        let context = "Previous discussion about bugs"
        let recipientRole = "engineer"
        
        let expectedResult = ToneAnalysisResult(
            toneWarning: "This might sound terse",
            alternativePhrasing: "I found an issue that needs attention",
            improvementSuggestions: ["Provide more context"],
            severity: .medium
        )
        mockRepository.mockResult = expectedResult
        
        // When
        viewModel.analyzeTone(
            message: message,
            conversationContext: context,
            recipientRole: recipientRole
        )
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.analysisResult)
        XCTAssertEqual(viewModel.analysisResult?.severity, .medium)
        XCTAssertTrue(viewModel.shouldShowWarning)
    }
}

// MARK: - Mock Repository

class MockToneAnalysisRepository: ToneAnalysisRepository {
    var mockResult: ToneAnalysisResult?
    var shouldFail = false
    var mockError: Error?
    
    override func analyzeTone(
        message: String,
        conversationContext: String? = nil,
        recipientRole: String? = nil
    ) async throws -> ToneAnalysisResult {
        if shouldFail {
            throw mockError ?? AppError.networkError("Mock error")
        }
        
        guard let result = mockResult else {
            throw AppError.networkError("No mock result set")
        }
        
        return result
    }
}
