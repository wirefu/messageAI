//
//  Message.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a message in a conversation
struct Message: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String

    /// ID of the conversation this message belongs to
    let conversationID: String

    /// ID of the message sender
    let senderID: String

    /// Message content
    var content: String

    /// When the message was created
    var timestamp: Date

    /// When the message was delivered to recipient
    var deliveredAt: Date?

    /// When the message was read by recipient
    var readAt: Date?

    /// Current delivery status
    var status: MessageStatus

    /// AI-powered suggestions for this message
    var aiSuggestions: AISuggestion?

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case conversationID
        case senderID
        case content
        case timestamp
        case deliveredAt
        case readAt
        case status
        case aiSuggestions
    }
}

// MARK: - Firestore Extensions

extension Message {
    /// Converts message to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.MessageFields.id: id,
            FirebaseConstants.MessageFields.conversationID: conversationID,
            FirebaseConstants.MessageFields.senderID: senderID,
            FirebaseConstants.MessageFields.content: content,
            FirebaseConstants.MessageFields.timestamp: Timestamp(date: timestamp),
            FirebaseConstants.MessageFields.status: status.rawValue
        ]

        if let deliveredAt = deliveredAt {
            data[FirebaseConstants.MessageFields.deliveredAt] = Timestamp(date: deliveredAt)
        }

        if let readAt = readAt {
            data[FirebaseConstants.MessageFields.readAt] = Timestamp(date: readAt)
        }

        if let aiSuggestions = aiSuggestions,
           let suggestionData = try? JSONEncoder().encode(aiSuggestions),
           let suggestionDict = try? JSONSerialization.jsonObject(with: suggestionData) as? [String: Any] {
            data[FirebaseConstants.MessageFields.aiSuggestions] = suggestionDict
        }

        return data
    }

    /// Creates message from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: Message instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> Message? {
        guard let data = document.data() else { return nil }

        var aiSuggestions: AISuggestion?
        if let suggestionDict = data[FirebaseConstants.MessageFields.aiSuggestions] as? [String: Any],
           let suggestionData = try? JSONSerialization.data(withJSONObject: suggestionDict) {
            aiSuggestions = try? JSONDecoder().decode(AISuggestion.self, from: suggestionData)
        }

        return Message(
            id: document.documentID,
            conversationID: data[FirebaseConstants.MessageFields.conversationID] as? String ?? "",
            senderID: data[FirebaseConstants.MessageFields.senderID] as? String ?? "",
            content: data[FirebaseConstants.MessageFields.content] as? String ?? "",
            timestamp: (data[FirebaseConstants.MessageFields.timestamp] as? Timestamp)?.dateValue() ?? Date(),
            deliveredAt: (data[FirebaseConstants.MessageFields.deliveredAt] as? Timestamp)?.dateValue(),
            readAt: (data[FirebaseConstants.MessageFields.readAt] as? Timestamp)?.dateValue(),
            status: MessageStatus(
                rawValue: data[FirebaseConstants.MessageFields.status] as? String ?? ""
            ) ?? .sending,
            aiSuggestions: aiSuggestions
        )
    }
}

// MARK: - Helpers

extension Message {
    /// Whether this message has been read
    var isRead: Bool {
        status == .read
    }

    /// Whether this message is from the current user
    /// - Parameter currentUserID: Current user's ID
    /// - Returns: True if message is from current user
    func isFromCurrentUser(_ currentUserID: String) -> Bool {
        senderID == currentUserID
    }
}

