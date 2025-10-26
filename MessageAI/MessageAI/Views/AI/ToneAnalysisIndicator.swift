//
//  ToneAnalysisIndicator.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Visual indicator for tone analysis status in message input
struct ToneAnalysisIndicator: View {
    let severity: ToneAnalysisResult.ToneSeverity
    let isAnalyzing: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            if isAnalyzing {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(severityColor)
            } else {
                Image(systemName: severityIcon)
                    .font(.caption)
                    .foregroundColor(severityColor)
            }
            
            Text(severityText)
                .font(.caption)
                .foregroundColor(severityColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(severityColor.opacity(0.1))
        )
    }
    
    // MARK: - Computed Properties
    
    private var severityIcon: String {
        switch severity {
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
        switch severity {
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
        switch severity {
        case .none:
            return "Good tone"
        case .low:
            return "Minor issues"
        case .medium:
            return "Tone concerns"
        case .high:
            return "Tone issues"
        }
    }
}

/// Enhanced tone analysis view with better animations and visual feedback
struct EnhancedToneAnalysisView: View {
    let result: ToneAnalysisResult
    let onAcceptSuggestion: (() -> Void)?
    let onDismiss: (() -> Void)?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact header (always visible)
            compactHeader
            
            // Expanded content (animated)
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onAppear {
            // Auto-expand for medium/high severity
            if result.severity == .medium || result.severity == .high {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = true
                    }
                }
            }
        }
    }
    
    // MARK: - Compact Header
    
    private var compactHeader: some View {
        HStack {
            // Severity indicator
            HStack(spacing: 6) {
                Image(systemName: severityIcon)
                    .font(.title3)
                    .foregroundColor(severityColor)
                
                Text(severityText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(severityColor)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                if onDismiss != nil {
                    Button("Dismiss") {
                        onDismiss!()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Button(isExpanded ? "Less" : "More") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(AIConstants.aiBrandColor)
            }
        }
        .padding(16)
    }
    
    // MARK: - Expanded Content
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            // Tone warning
            if let warning = result.toneWarning {
                toneWarningSection(warning)
            }
            
            // Alternative phrasing
            if let alternative = result.alternativePhrasing {
                alternativePhrasingSection(alternative)
            }
            
            // Improvement suggestions
            if !result.improvementSuggestions.isEmpty {
                improvementSuggestionsSection
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Content Sections
    
    private func toneWarningSection(_ warning: String) -> some View {
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
    }
    
    private func alternativePhrasingSection(_ alternative: String) -> some View {
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
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.leading, 20)
            
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
    
    private var improvementSuggestionsSection: some View {
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

/// Floating tone analysis badge for message bubbles
struct ToneAnalysisBadge: View {
    let severity: ToneAnalysisResult.ToneSeverity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: severityIcon)
                .font(.caption)
                .foregroundColor(severityColor)
                .padding(4)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var severityIcon: String {
        switch severity {
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
        switch severity {
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
}

// MARK: - Preview

struct ToneAnalysisIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Different severity levels
            ToneAnalysisIndicator(severity: .none, isAnalyzing: false)
            ToneAnalysisIndicator(severity: .low, isAnalyzing: false)
            ToneAnalysisIndicator(severity: .medium, isAnalyzing: false)
            ToneAnalysisIndicator(severity: .high, isAnalyzing: false)
            ToneAnalysisIndicator(severity: .medium, isAnalyzing: true)
            
            Divider()
            
            // Enhanced view
            EnhancedToneAnalysisView(
                result: ToneAnalysisResult(
                    toneWarning: "This message might sound a bit abrupt",
                    alternativePhrasing: "Could you please review this when you have a moment?",
                    improvementSuggestions: [
                        "Consider adding a greeting",
                        "Be more specific about the request"
                    ],
                    severity: .medium
                ),
                onAcceptSuggestion: { print("Accept suggestion") },
                onDismiss: { print("Dismiss") }
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
