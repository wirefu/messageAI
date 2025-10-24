//
//  Conversation.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a conversation between users
struct Conversation: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String

    /// Array of participant user IDs (always 2 for MVP)
    let participants: [String]

    /// Last message in the conversation
    var lastMessage: Message?

    /// Timestamp of the last message
    var lastMessageTimestamp: Date

    /// Unread message count per user (userID: count)
    var unreadCount: [String: Int]

    /// Conversation creation timestamp
    var createdAt: Date

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case participants
        case lastMessage
        case lastMessageTimestamp
        case unreadCount
        case createdAt
    }
}

// MARK: - Firestore Extensions

extension Conversation {
    /// Converts conversation to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.ConversationFields.id: id,
            FirebaseConstants.ConversationFields.participants: participants,
            FirebaseConstants.ConversationFields.lastMessageTimestamp: Timestamp(date: lastMessageTimestamp),
            FirebaseConstants.ConversationFields.unreadCount: unreadCount,
            FirebaseConstants.ConversationFields.createdAt: Timestamp(date: createdAt)
        ]

        if let lastMessage = lastMessage {
            data[FirebaseConstants.ConversationFields.lastMessage] = lastMessage.toFirestore()
        }

        return data
    }

    /// Creates conversation from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: Conversation instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> Conversation? {
        guard let data = document.data() else { return nil }

        var lastMessage: Message?
        if let messageData = data[FirebaseConstants.ConversationFields.lastMessage] as? [String: Any],
           let messageJSON = try? JSONSerialization.data(withJSONObject: messageData),
           let decoded = try? JSONDecoder().decode(Message.self, from: messageJSON) {
            lastMessage = decoded
        }

        return Conversation(
            id: document.documentID,
            participants: data[FirebaseConstants.ConversationFields.participants] as? [String] ?? [],
            lastMessage: lastMessage,
            lastMessageTimestamp: (
                data[FirebaseConstants.ConversationFields.lastMessageTimestamp] as? Timestamp
            )?.dateValue() ?? Date(),
            unreadCount: data[FirebaseConstants.ConversationFields.unreadCount] as? [String: Int] ?? [:],
            createdAt: (data[FirebaseConstants.ConversationFields.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}

// MARK: - Helpers

extension Conversation {
    /// Gets the other participant's ID (for 1:1 conversations)
    /// - Parameter currentUserID: Current user's ID
    /// - Returns: Other participant's ID or nil
    func otherParticipantID(currentUserID: String) -> String? {
        participants.first { $0 != currentUserID }
    }

    /// Gets unread count for a specific user
    /// - Parameter userID: User ID to check
    /// - Returns: Unread count for the user
    func unreadCount(for userID: String) -> Int {
        unreadCount[userID] ?? 0
    }

    /// Whether this conversation includes a specific user
    /// - Parameter userID: User ID to check
    /// - Returns: True if user is a participant
    func includes(userID: String) -> Bool {
        participants.contains(userID)
    }
}
