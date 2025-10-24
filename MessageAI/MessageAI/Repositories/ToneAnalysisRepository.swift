import Foundation
import FirebaseFunctions

/// Repository for tone analysis operations
@MainActor
class ToneAnalysisRepository: ObservableObject {
    private let functions = Functions.functions()
    
    /// Analyzes message tone for potential issues
    /// - Parameters:
    ///   - message: The message to analyze
    ///   - conversationContext: Additional context about the conversation
    ///   - recipientRole: Role of the message recipient (e.g., "engineer", "designer", "manager")
    /// - Returns: Tone analysis result with warnings and suggestions
    func analyzeTone(
        message: String,
        conversationContext: String? = nil,
        recipientRole: String? = nil
    ) async throws -> ToneAnalysisResult {
        let data: [String: Any] = [
            "message": message,
            "conversationContext": conversationContext ?? "",
            "recipientRole": recipientRole ?? ""
        ]
        
        let callable = functions.httpsCallable("analyzeTone")
        let result = try await callable.call(data)
        
        guard let data = result.data as? [String: Any] else {
            throw AppError.aiFunctionError("Invalid response from tone analysis")
        }
        
        return ToneAnalysisResult.from(data: data)
    }
}

/// Result of tone analysis
struct ToneAnalysisResult: Codable {
    let toneWarning: String?
    let alternativePhrasing: String?
    let improvementSuggestions: [String]
    let severity: ToneSeverity
    
    enum ToneSeverity: String, Codable, CaseIterable {
        case none
        case low
        case medium
        case high
        
        var displayName: String {
            switch self {
            case .none: return "No Issues"
            case .low: return "Minor"
            case .medium: return "Moderate"
            case .high: return "Significant"
            }
        }
        
        var color: String {
            switch self {
            case .none: return "green"
            case .low: return "yellow"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
    
    /// Creates ToneAnalysisResult from Firebase response data
    static func from(data: [String: Any]) -> ToneAnalysisResult {
        let toneWarning = data["toneWarning"] as? String
        let alternativePhrasing = data["alternativePhrasing"] as? String
        let improvementSuggestions = data["improvementSuggestions"] as? [String] ?? []
        let severityString = data["severity"] as? String ?? "none"
        let severity = ToneSeverity(rawValue: severityString) ?? .none
        
        return ToneAnalysisResult(
            toneWarning: toneWarning,
            alternativePhrasing: alternativePhrasing,
            improvementSuggestions: improvementSuggestions,
            severity: severity
        )
    }
    
    /// Whether there are any tone issues
    var hasIssues: Bool {
        return severity != .none
    }
    
    /// Whether the tone issues are significant enough to show a warning
    var shouldShowWarning: Bool {
        return severity == .medium || severity == .high
    }
}
