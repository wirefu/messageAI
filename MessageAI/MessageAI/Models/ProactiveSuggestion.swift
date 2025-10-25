//
//  ProactiveSuggestion.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a proactive suggestion from the AI
struct ProactiveSuggestion: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// Type of suggestion
    var type: SuggestionType
    
    /// The suggestion text
    var suggestion: String
    
    /// Severity level of the suggestion
    var severity: SuggestionSeverity
    
    /// Whether the suggestion is actionable
    var isActionable: Bool
    
    /// Optional action associated with the suggestion
    var action: SuggestionAction?
    
    /// When the suggestion was created
    var createdAt: Date
    
    /// Whether the suggestion has been dismissed
    var isDismissed: Bool
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case suggestion
        case severity
        case isActionable
        case action
        case createdAt
        case isDismissed
    }
}

/// Types of proactive suggestions
enum SuggestionType: String, Codable, CaseIterable {
    case followUp
    case clarification
    case actionItem
    case reminder
    case summary
    case translation
    case rewrite
    case expand
}

/// Severity levels for suggestions
enum SuggestionSeverity: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical
}

/// Action associated with a suggestion
struct SuggestionAction: Codable, Equatable {
    /// Type of action
    var type: String
    
    /// Action title
    var title: String
    
    /// Action description
    var description: String
    
    /// Optional parameters for the action
    var parameters: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case parameters
    }
}

// MARK: - Firestore Extensions

extension ProactiveSuggestion {
    /// Converts ProactiveSuggestion to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.ProactiveSuggestionFields.id: id,
            FirebaseConstants.ProactiveSuggestionFields.type: type.rawValue,
            FirebaseConstants.ProactiveSuggestionFields.suggestion: suggestion,
            FirebaseConstants.ProactiveSuggestionFields.severity: severity.rawValue,
            FirebaseConstants.ProactiveSuggestionFields.isActionable: isActionable,
            FirebaseConstants.ProactiveSuggestionFields.createdAt: Timestamp(date: createdAt),
            FirebaseConstants.ProactiveSuggestionFields.isDismissed: isDismissed
        ]
        
        if let action = action,
           let actionData = try? JSONEncoder().encode(action),
           let actionDict = try? JSONSerialization.jsonObject(with: actionData) as? [String: Any] {
            data[FirebaseConstants.ProactiveSuggestionFields.action] = actionDict
        }
        
        return data
    }
    
    /// Creates ProactiveSuggestion from Firestore document
    static func from(document: DocumentSnapshot) -> ProactiveSuggestion? {
        guard let data = document.data() else { return nil }
        
        var action: SuggestionAction?
        if let actionDict = data[FirebaseConstants.ProactiveSuggestionFields.action] as? [String: Any],
           let actionData = try? JSONSerialization.data(withJSONObject: actionDict) {
            action = try? JSONDecoder().decode(SuggestionAction.self, from: actionData)
        }
        
        return ProactiveSuggestion(
            id: document.documentID,
            type: SuggestionType(rawValue: data[FirebaseConstants.ProactiveSuggestionFields.type] as? String ?? "") ?? .followUp,
            suggestion: data[FirebaseConstants.ProactiveSuggestionFields.suggestion] as? String ?? "",
            severity: SuggestionSeverity(rawValue: data[FirebaseConstants.ProactiveSuggestionFields.severity] as? String ?? "") ?? .low,
            isActionable: data[FirebaseConstants.ProactiveSuggestionFields.isActionable] as? Bool ?? false,
            action: action,
            createdAt: (data[FirebaseConstants.ProactiveSuggestionFields.createdAt] as? Timestamp)?.dateValue() ?? Date(),
            isDismissed: data[FirebaseConstants.ProactiveSuggestionFields.isDismissed] as? Bool ?? false
        )
    }
}
