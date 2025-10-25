//
//  AIChatMessage.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a message in an AI Chat session
struct AIChatMessage: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// ID of the AI chat session
    let sessionID: String
    
    /// ID of the user who sent the message
    let userID: String
    
    /// Message content
    var content: String
    
    /// Role of the message sender (user or assistant)
    var role: AIChatRole
    
    /// When the message was created
    var timestamp: Date
    
    /// AI response metadata (only for assistant messages)
    var aiMetadata: AIChatMetadata?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case sessionID
        case userID
        case content
        case role
        case timestamp
        case aiMetadata
    }
}

/// Role of the message sender in AI Chat
enum AIChatRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system
}

/// AI response metadata for assistant messages
struct AIChatMetadata: Codable, Equatable {
    /// AI model used for response
    var model: String?
    
    /// Response generation time in milliseconds
    var responseTime: Int?
    
    /// Confidence score of the response (0.0 - 1.0)
    var confidence: Double?
    
    /// Context used for generating the response
    var context: String?
    
    /// Suggestions provided with the response
    var suggestions: [AIChatSuggestion]?
    
    /// Actions available for this response
    var actions: [AIChatAction]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case model
        case responseTime
        case confidence
        case context
        case suggestions
        case actions
    }
}

/// AI Chat suggestion
struct AIChatSuggestion: Codable, Equatable {
    /// Type of suggestion
    var type: String
    
    /// Suggestion text
    var suggestion: String
    
    /// Confidence level (0.0 - 1.0)
    var confidence: Double
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case type
        case suggestion
        case confidence
    }
}

/// AI Chat action
struct AIChatAction: Codable, Equatable {
    /// Unique action identifier
    var id: String
    
    /// Action name
    var name: String
    
    /// Action description
    var description: String
    
    /// Action parameters (optional)
    var parameters: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case parameters
    }
}

// MARK: - Firestore Extensions

extension AIChatMessage {
    /// Converts AI chat message to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.AIChatFields.id: id,
            FirebaseConstants.AIChatFields.sessionID: sessionID,
            FirebaseConstants.AIChatFields.userID: userID,
            FirebaseConstants.AIChatFields.content: content,
            FirebaseConstants.AIChatFields.role: role.rawValue,
            FirebaseConstants.AIChatFields.timestamp: Timestamp(date: timestamp)
        ]
        
        if let aiMetadata = aiMetadata,
           let metadataData = try? JSONEncoder().encode(aiMetadata),
           let metadataDict = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] {
            data[FirebaseConstants.AIChatFields.aiMetadata] = metadataDict
        }
        
        return data
    }
    
    /// Creates AI chat message from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: AIChatMessage instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> AIChatMessage? {
        guard let data = document.data() else { return nil }
        
        var aiMetadata: AIChatMetadata?
        if let metadataDict = data[FirebaseConstants.AIChatFields.aiMetadata] as? [String: Any],
           let metadataData = try? JSONSerialization.data(withJSONObject: metadataDict) {
            aiMetadata = try? JSONDecoder().decode(AIChatMetadata.self, from: metadataData)
        }
        
        return AIChatMessage(
            id: document.documentID,
            sessionID: data[FirebaseConstants.AIChatFields.sessionID] as? String ?? "",
            userID: data[FirebaseConstants.AIChatFields.userID] as? String ?? "",
            content: data[FirebaseConstants.AIChatFields.content] as? String ?? "",
            role: AIChatRole(rawValue: data[FirebaseConstants.AIChatFields.role] as? String ?? "user") ?? .user,
            timestamp: (data[FirebaseConstants.AIChatFields.timestamp] as? Timestamp)?.dateValue() ?? Date(),
            aiMetadata: aiMetadata
        )
    }
}

// MARK: - Helpers

extension AIChatMessage {
    /// Whether this message is from the user
    var isFromUser: Bool {
        role == .user
    }
    
    /// Whether this message is from the AI assistant
    var isFromAssistant: Bool {
        role == .assistant
    }
    
    /// Whether this message has AI metadata
    var hasAIMetadata: Bool {
        aiMetadata != nil
    }
    
    /// Whether this message has suggestions
    var hasSuggestions: Bool {
        aiMetadata?.suggestions?.isEmpty == false
    }
    
    /// Whether this message has actions
    var hasActions: Bool {
        aiMetadata?.actions?.isEmpty == false
    }
}

extension AIChatMetadata {
    /// Whether any metadata is present
    var hasMetadata: Bool {
        model != nil ||
        responseTime != nil ||
        confidence != nil ||
        context != nil ||
        suggestions?.isEmpty == false ||
        actions?.isEmpty == false
    }
}
