//
//  User.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a user in the MessengerAI system
struct User: Codable, Identifiable, Equatable {
    /// Unique identifier (Firebase Auth UID)
    let id: String

    /// User's display name
    var displayName: String

    /// User's email address
    var email: String

    /// Optional avatar URL
    var avatarURL: String?

    /// Whether user is currently online
    var isOnline: Bool

    /// Last seen timestamp
    var lastSeen: Date

    /// FCM token for push notifications
    var fcmToken: String?

    /// Account creation timestamp
    var createdAt: Date

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case email
        case avatarURL
        case isOnline
        case lastSeen
        case fcmToken
        case createdAt
    }
}

// MARK: - Firestore Extensions

extension User {
    /// Converts user to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.UserFields.id: id,
            FirebaseConstants.UserFields.displayName: displayName,
            FirebaseConstants.UserFields.email: email,
            FirebaseConstants.UserFields.isOnline: isOnline,
            FirebaseConstants.UserFields.lastSeen: Timestamp(date: lastSeen),
            FirebaseConstants.UserFields.createdAt: Timestamp(date: createdAt)
        ]

        if let avatarURL = avatarURL {
            data[FirebaseConstants.UserFields.avatarURL] = avatarURL
        }

        if let fcmToken = fcmToken {
            data[FirebaseConstants.UserFields.fcmToken] = fcmToken
        }

        return data
    }

    /// Creates user from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: User instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }

        return User(
            id: document.documentID,
            displayName: data[FirebaseConstants.UserFields.displayName] as? String ?? "",
            email: data[FirebaseConstants.UserFields.email] as? String ?? "",
            avatarURL: data[FirebaseConstants.UserFields.avatarURL] as? String,
            isOnline: data[FirebaseConstants.UserFields.isOnline] as? Bool ?? false,
            lastSeen: (data[FirebaseConstants.UserFields.lastSeen] as? Timestamp)?.dateValue() ?? Date(),
            fcmToken: data[FirebaseConstants.UserFields.fcmToken] as? String,
            createdAt: (data[FirebaseConstants.UserFields.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}

