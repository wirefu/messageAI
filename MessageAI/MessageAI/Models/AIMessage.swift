//
//  AIMessage.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a message in an AI conversation
struct AIMessage: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// Role of the message sender
    var role: AIMessageRole
    
    /// Message content
    var content: String
    
    /// When the message was created
    var timestamp: Date
    
    /// Optional sources for the message (for RAG context)
    var sources: [MessageSource]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case timestamp
        case sources
    }
}

/// Role of the message sender in AI conversation
enum AIMessageRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system
}

/// Source information for a message (used in RAG context)
struct MessageSource: Codable, Equatable {
    /// Type of source (conversation, document, etc.)
    var type: String
    
    /// Source identifier
    var id: String
    
    /// Source title or description
    var title: String?
    
    /// Relevance score (0.0 - 1.0)
    var relevance: Double?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case title
        case relevance
    }
}

// MARK: - Firestore Extensions

extension AIMessage {
    /// Converts AIMessage to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.AIMessageFields.id: id,
            FirebaseConstants.AIMessageFields.role: role.rawValue,
            FirebaseConstants.AIMessageFields.content: content,
            FirebaseConstants.AIMessageFields.timestamp: Timestamp(date: timestamp)
        ]
        
        if let sources = sources,
           let sourcesData = try? JSONEncoder().encode(sources),
           let sourcesArray = try? JSONSerialization.jsonObject(with: sourcesData) as? [[String: Any]] {
            data[FirebaseConstants.AIMessageFields.sources] = sourcesArray
        }
        
        return data
    }
    
    /// Creates AIMessage from Firestore document
    static func from(document: DocumentSnapshot) -> AIMessage? {
        guard let data = document.data() else { return nil }
        
        var sources: [MessageSource]?
        if let sourcesArray = data[FirebaseConstants.AIMessageFields.sources] as? [[String: Any]],
           let sourcesData = try? JSONSerialization.data(withJSONObject: sourcesArray) {
            sources = try? JSONDecoder().decode([MessageSource].self, from: sourcesData)
        }
        
        return AIMessage(
            id: document.documentID,
            role: AIMessageRole(rawValue: data[FirebaseConstants.AIMessageFields.role] as? String ?? "") ?? .user,
            content: data[FirebaseConstants.AIMessageFields.content] as? String ?? "",
            timestamp: (data[FirebaseConstants.AIMessageFields.timestamp] as? Timestamp)?.dateValue() ?? Date(),
            sources: sources
        )
    }
}
