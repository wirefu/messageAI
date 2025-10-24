import SwiftUI

/// Dedicated view for tone analysis results
struct ToneAnalysisView: View {
    let result: ToneAnalysisResult
    let onAcceptSuggestion: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(
        result: ToneAnalysisResult,
        onAcceptSuggestion: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.result = result
        self.onAcceptSuggestion = onAcceptSuggestion
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with severity indicator
            HStack {
                Image(systemName: severityIcon)
                    .foregroundColor(severityColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tone Analysis")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(severityText)
                        .font(.caption)
                        .foregroundColor(severityColor)
                }
                
                Spacer()
                
                if onDismiss != nil {
                    Button("Dismiss", action: onDismiss!)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tone warning
            if let warning = result.toneWarning {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Tone Issue")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    Text(warning)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                }
                .padding(.vertical, 4)
            }
            
            // Alternative phrasing suggestion
            if let alternative = result.alternativePhrasing {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text("Suggested Phrasing")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    Text(alternative)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    if onAcceptSuggestion != nil {
                        Button("Use This Phrasing") {
                            onAcceptSuggestion!()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.leading, 20)
                    }
                }
            }
            
            // Improvement suggestions
            if !result.improvementSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Improvement Tips")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    ForEach(result.improvementSuggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 20)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var severityIcon: String {
        switch result.severity {
        case .none:
            return "checkmark.circle.fill"
        case .low:
            return "exclamationmark.triangle.fill"
        case .medium:
            return "exclamationmark.triangle.fill"
        case .high:
            return "xmark.circle.fill"
        }
    }
    
    private var severityColor: Color {
        switch result.severity {
        case .none:
            return .green
        case .low:
            return .yellow
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    private var severityText: String {
        switch result.severity {
        case .none:
            return "No tone issues detected"
        case .low:
            return "Minor tone improvements suggested"
        case .medium:
            return "Moderate tone concerns"
        case .high:
            return "Significant tone issues detected"
        }
    }
}

// MARK: - Preview
struct ToneAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // No issues
            ToneAnalysisView(
                result: ToneAnalysisResult(
                    toneWarning: nil,
                    alternativePhrasing: nil,
                    improvementSuggestions: [],
                    severity: .none
                )
            )
            
            // Minor issues
            ToneAnalysisView(
                result: ToneAnalysisResult(
                    toneWarning: "This might sound a bit abrupt",
                    alternativePhrasing: "Could you please review this when you have a moment?",
                    improvementSuggestions: [
                        "Consider adding a greeting",
                        "Be more specific about the request"
                    ],
                    severity: .low
                )
            )
            
            // Significant issues
            ToneAnalysisView(
                result: ToneAnalysisResult(
                    toneWarning: "This message could come across as dismissive or rude",
                    alternativePhrasing: "I understand your concern. Let me look into this and get back to you with a solution.",
                    improvementSuggestions: [
                        "Acknowledge the other person's perspective",
                        "Offer to help rather than just saying no",
                        "Provide alternative solutions"
                    ],
                    severity: .high
                )
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
