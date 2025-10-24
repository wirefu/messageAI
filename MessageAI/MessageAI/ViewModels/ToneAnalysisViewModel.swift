import Foundation
import Combine

/// ViewModel for tone analysis functionality
@MainActor
class ToneAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisResult: ToneAnalysisResult?
    @Published var error: Error?
    
    private let toneRepository: ToneAnalysisRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(toneRepository: ToneAnalysisRepository = ToneAnalysisRepository()) {
        self.toneRepository = toneRepository
    }
    
    /// Analyzes the tone of a message
    /// - Parameters:
    ///   - message: The message to analyze
    ///   - conversationContext: Additional context about the conversation
    ///   - recipientRole: Role of the message recipient
    func analyzeTone(
        message: String,
        conversationContext: String? = nil,
        recipientRole: String? = nil
    ) {
        // Don't analyze empty messages
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            analysisResult = nil
            return
        }
        
        isAnalyzing = true
        error = nil
        
        Task {
            do {
                let result = try await toneRepository.analyzeTone(
                    message: message,
                    conversationContext: conversationContext,
                    recipientRole: recipientRole
                )
                
                await MainActor.run {
                    self.analysisResult = result
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isAnalyzing = false
                    self.analysisResult = nil
                }
            }
        }
    }
    
    /// Clears the current analysis result
    func clearAnalysis() {
        analysisResult = nil
        error = nil
    }
    
    /// Whether tone analysis should be shown
    var shouldShowAnalysis: Bool {
        guard let result = analysisResult else { return false }
        return result.hasIssues
    }
    
    /// Whether a warning should be displayed
    var shouldShowWarning: Bool {
        guard let result = analysisResult else { return false }
        return result.shouldShowWarning
    }
}
