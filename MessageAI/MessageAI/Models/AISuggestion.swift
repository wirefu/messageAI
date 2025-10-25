//
//  AISuggestion.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// AI-powered suggestions for message improvement
struct AISuggestion: Codable, Equatable {
    /// Potential clarity issues identified
    var clarityIssues: [String]?

    /// Suggested clearer version of the message
    var suggestedRevision: String?

    /// Warning about message tone (e.g., "might sound curt")
    var toneWarning: String?

    /// Alternative phrasing suggestion
    var alternativePhrasing: String?

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case clarityIssues
        case suggestedRevision
        case toneWarning
        case alternativePhrasing
    }
}

// MARK: - Helpers

extension AISuggestion {
    /// Whether any suggestions are present
    var hasSuggestions: Bool {
        (clarityIssues?.isEmpty == false) ||
        suggestedRevision != nil ||
        toneWarning != nil ||
        alternativePhrasing != nil
    }

    /// Count of total suggestions
    var suggestionCount: Int {
        var count = 0
        if let issues = clarityIssues, !issues.isEmpty {
            count += issues.count
        }
        if suggestedRevision != nil {
            count += 1
        }
        if toneWarning != nil {
            count += 1
        }
        if alternativePhrasing != nil {
            count += 1
        }
        return count
    }
}
