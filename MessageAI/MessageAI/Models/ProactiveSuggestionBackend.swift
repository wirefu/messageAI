//
//  ProactiveSuggestionBackend.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Backend Proactive Suggestion model matching Cloud Functions structure
struct ProactiveSuggestionBackend: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// Type of suggestion
    let type: SuggestionTypeBackend
    
    /// Priority level
    let priority: SuggestionPriority
    
    /// Suggestion title
    let title: String
    
    /// Suggestion message
    let message: String
    
    /// Action button text
    let actionText: String
    
    /// Dismiss button text
    let dismissText: String
    
    /// Additional metadata
    let metadata: SuggestionMetadata
    
    /// Whether the suggestion has been dismissed
    var dismissed: Bool
    
    /// Whether action has been taken
    var actionTaken: Bool
    
    /// When the suggestion was created
    let createdAt: Date
    
    /// When the suggestion expires
    let expiresAt: Date
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case priority
        case title
        case message
        case actionText
        case dismissText
        case metadata
        case dismissed
        case actionTaken
        case createdAt
        case expiresAt
    }
}

/// Backend suggestion types
enum SuggestionTypeBackend: String, Codable, CaseIterable {
    case timezoneAmbiguity = "timezone_ambiguity"
    case unclearReference = "unclear_reference"
    case missedFollowup = "missed_followup"
}

/// Suggestion priority levels
enum SuggestionPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        }
    }
}

/// Suggestion metadata
struct SuggestionMetadata: Codable, Equatable {
    let conversationId: String
    let messageId: String
    let detectedAt: String
    let userTimezone: String?
    let recipientTimezone: String?
    let originalText: String?
    let suggestedClarification: String?
}

// MARK: - Firestore Extensions

extension ProactiveSuggestionBackend {
    /// Converts ProactiveSuggestionBackend to Firestore dictionary
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "type": type.rawValue,
            "priority": priority.rawValue,
            "title": title,
            "message": message,
            "actionText": actionText,
            "dismissText": dismissText,
            "metadata": [
                "conversationId": metadata.conversationId,
                "messageId": metadata.messageId,
                "detectedAt": metadata.detectedAt,
                "userTimezone": metadata.userTimezone as Any,
                "recipientTimezone": metadata.recipientTimezone as Any,
                "originalText": metadata.originalText as Any,
                "suggestedClarification": metadata.suggestedClarification as Any
            ],
            "dismissed": dismissed,
            "actionTaken": actionTaken,
            "createdAt": Timestamp(date: createdAt),
            "expiresAt": Timestamp(date: expiresAt)
        ]
    }
    
    /// Creates ProactiveSuggestionBackend from Firestore document
    static func from(document: DocumentSnapshot) -> ProactiveSuggestionBackend? {
        guard let data = document.data() else { return nil }
        
        let metadataData = data["metadata"] as? [String: Any] ?? [:]
        
        return ProactiveSuggestionBackend(
            id: document.documentID,
            type: SuggestionTypeBackend(rawValue: data["type"] as? String ?? "") ?? .timezoneAmbiguity,
            priority: SuggestionPriority(rawValue: data["priority"] as? String ?? "") ?? .low,
            title: data["title"] as? String ?? "",
            message: data["message"] as? String ?? "",
            actionText: data["actionText"] as? String ?? "",
            dismissText: data["dismissText"] as? String ?? "",
            metadata: SuggestionMetadata(
                conversationId: metadataData["conversationId"] as? String ?? "",
                messageId: metadataData["messageId"] as? String ?? "",
                detectedAt: metadataData["detectedAt"] as? String ?? "",
                userTimezone: metadataData["userTimezone"] as? String,
                recipientTimezone: metadataData["recipientTimezone"] as? String,
                originalText: metadataData["originalText"] as? String,
                suggestedClarification: metadataData["suggestedClarification"] as? String
            ),
            dismissed: data["dismissed"] as? Bool ?? false,
            actionTaken: data["actionTaken"] as? Bool ?? false,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            expiresAt: (data["expiresAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
