//
//  ActionItem.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents an action item extracted from a conversation
struct ActionItem: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String

    /// ID of the conversation
    let conversationID: String

    /// ID of the message this action was extracted from
    var messageID: String

    /// Description of the action item
    var description: String

    /// User ID of person assigned (if mentioned)
    var assignedTo: String?

    /// Due date (if mentioned)
    var dueDate: Date?

    /// Whether the action item is completed
    var isCompleted: Bool

    /// When the action item was created
    var createdAt: Date

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case conversationID
        case messageID
        case description
        case assignedTo
        case dueDate
        case isCompleted
        case createdAt
    }
}

// MARK: - Firestore Extensions

extension ActionItem {
    /// Converts action item to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.ActionItemFields.id: id,
            FirebaseConstants.ActionItemFields.conversationID: conversationID,
            FirebaseConstants.ActionItemFields.messageID: messageID,
            FirebaseConstants.ActionItemFields.description: description,
            FirebaseConstants.ActionItemFields.isCompleted: isCompleted,
            FirebaseConstants.ActionItemFields.createdAt: Timestamp(date: createdAt)
        ]

        if let assignedTo = assignedTo {
            data[FirebaseConstants.ActionItemFields.assignedTo] = assignedTo
        }

        if let dueDate = dueDate {
            data[FirebaseConstants.ActionItemFields.dueDate] = Timestamp(date: dueDate)
        }

        return data
    }

    /// Creates action item from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: ActionItem instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> ActionItem? {
        guard let data = document.data() else { return nil }

        return ActionItem(
            id: document.documentID,
            conversationID: data[FirebaseConstants.ActionItemFields.conversationID] as? String ?? "",
            messageID: data[FirebaseConstants.ActionItemFields.messageID] as? String ?? "",
            description: data[FirebaseConstants.ActionItemFields.description] as? String ?? "",
            assignedTo: data[FirebaseConstants.ActionItemFields.assignedTo] as? String,
            dueDate: (data[FirebaseConstants.ActionItemFields.dueDate] as? Timestamp)?.dateValue(),
            isCompleted: data[FirebaseConstants.ActionItemFields.isCompleted] as? Bool ?? false,
            createdAt: (data[FirebaseConstants.ActionItemFields.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}

// MARK: - Helpers

extension ActionItem {
    /// Whether the action item is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }

    /// Whether the action item has an assignee
    var hasAssignee: Bool {
        assignedTo != nil
    }
}
