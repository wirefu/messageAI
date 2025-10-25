//
//  MessageAction.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents an action that can be performed on a message
struct MessageAction: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// Type of action
    var type: MessageActionType
    
    /// Display name of the action
    var name: String
    
    /// Description of what the action does
    var description: String
    
    /// Whether the action is currently available
    var isAvailable: Bool
    
    /// Optional parameters for the action
    var parameters: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case description
        case isAvailable
        case parameters
    }
}

/// Types of actions that can be performed on messages
enum MessageActionType: String, Codable, CaseIterable {
    case translate
    case rewrite
    case extract
    case summarize
    case clarify
    case expand
    case shorten
}

/// Request for performing a message action
struct MessageActionRequest: Codable, Equatable {
    /// ID of the message to act upon
    var messageId: String
    
    /// Type of action to perform
    var actionType: MessageActionType
    
    /// Optional parameters for the action
    var parameters: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case messageId
        case actionType
        case parameters
    }
}

/// Response from performing a message action
struct MessageActionResponse: Codable, Equatable {
    /// Whether the action was successful
    var success: Bool
    
    /// Result of the action
    var result: String
    
    /// Optional metadata about the action
    var metadata: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case success
        case result
        case metadata
    }
}

/// Tone options for rewriting messages
enum RewriteTone: String, Codable, CaseIterable {
    case formal
    case casual
    case technical
    case friendly
    case professional
    case concise
}

/// Extracted entities from a message
struct ExtractedEntities: Codable, Equatable {
    /// List of action items found
    var actionItems: [String]
    
    /// List of people mentioned
    var people: [String]
    
    /// List of dates mentioned
    var dates: [String]
    
    /// List of topics mentioned
    var topics: [String]
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case actionItems
        case people
        case dates
        case topics
    }
}

// MARK: - Firestore Extensions

extension MessageAction {
    /// Converts MessageAction to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.MessageActionFields.id: id,
            FirebaseConstants.MessageActionFields.type: type.rawValue,
            FirebaseConstants.MessageActionFields.name: name,
            FirebaseConstants.MessageActionFields.description: description,
            FirebaseConstants.MessageActionFields.isAvailable: isAvailable
        ]
        
        if let parameters = parameters {
            data[FirebaseConstants.MessageActionFields.parameters] = parameters
        }
        
        return data
    }
    
    /// Creates MessageAction from Firestore document
    static func from(document: DocumentSnapshot) -> MessageAction? {
        guard let data = document.data() else { return nil }
        
        return MessageAction(
            id: document.documentID,
            type: MessageActionType(rawValue: data[FirebaseConstants.MessageActionFields.type] as? String ?? "") ?? .translate,
            name: data[FirebaseConstants.MessageActionFields.name] as? String ?? "",
            description: data[FirebaseConstants.MessageActionFields.description] as? String ?? "",
            isAvailable: data[FirebaseConstants.MessageActionFields.isAvailable] as? Bool ?? true,
            parameters: data[FirebaseConstants.MessageActionFields.parameters] as? [String: String]
        )
    }
}
