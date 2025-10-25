//
//  AISession.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents an AI conversation session
struct AISession: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// ID of the user who owns this session
    var userId: String
    
    /// When the session was created
    var createdAt: Date
    
    /// When the session was last updated
    var updatedAt: Date
    
    /// Messages in this session
    var messages: [AIMessage]
    
    /// Whether the session is currently active
    var isActive: Bool
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case createdAt
        case updatedAt
        case messages
        case isActive
    }
}

// MARK: - Firestore Extensions

extension AISession {
    /// Converts AISession to Firestore dictionary
    func toFirestore() -> [String: Any] {
        let messagesData = messages.map { $0.toFirestore() }
        
        return [
            FirebaseConstants.AISessionFields.id: id,
            FirebaseConstants.AISessionFields.userId: userId,
            FirebaseConstants.AISessionFields.createdAt: Timestamp(date: createdAt),
            FirebaseConstants.AISessionFields.updatedAt: Timestamp(date: updatedAt),
            FirebaseConstants.AISessionFields.messages: messagesData,
            FirebaseConstants.AISessionFields.isActive: isActive
        ]
    }
    
    /// Creates AISession from Firestore document
    static func from(document: DocumentSnapshot) -> AISession? {
        guard let data = document.data() else { return nil }
        
        let messagesData = data[FirebaseConstants.AISessionFields.messages] as? [[String: Any]] ?? []
        let messages = messagesData.compactMap { messageData in
            // Create a mock document for each message
            let mockDocument = MockDocumentSnapshot(documentID: messageData["id"] as? String ?? "", data: messageData)
            return AIMessage.from(document: mockDocument)
        }
        
        return AISession(
            id: document.documentID,
            userId: data[FirebaseConstants.AISessionFields.userId] as? String ?? "",
            createdAt: (data[FirebaseConstants.AISessionFields.createdAt] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data[FirebaseConstants.AISessionFields.updatedAt] as? Timestamp)?.dateValue() ?? Date(),
            messages: messages,
            isActive: data[FirebaseConstants.AISessionFields.isActive] as? Bool ?? true
        )
    }
}

// MARK: - Mock Document for Testing

struct MockDocumentSnapshot {
    let documentID: String
    let data: [String: Any]
}
