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
        let messages: [AIMessage] = messagesData.compactMap { messageData -> AIMessage? in
            // Create AIMessage directly from data instead of using mock document
            guard let id = messageData["id"] as? String,
                  let content = messageData["content"] as? String,
                  let timestamp = messageData["timestamp"] as? Date else {
                return nil
            }
            
            let role = AIMessageRole(rawValue: messageData["role"] as? String ?? "user") ?? .user
            let sources = messageData["sources"] as? [[String: Any]] ?? []
            let messageSources = sources.compactMap { sourceData -> MessageSource? in
                guard let title = sourceData["title"] as? String else { return nil }
                return MessageSource(
                    type: sourceData["type"] as? String ?? "document",
                    id: sourceData["id"] as? String ?? UUID().uuidString,
                    title: title,
                    relevance: sourceData["relevance"] as? Double
                )
            }
            
            return AIMessage(
                id: id,
                role: role,
                content: content,
                timestamp: timestamp,
                sources: messageSources.isEmpty ? nil : messageSources
            )
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
