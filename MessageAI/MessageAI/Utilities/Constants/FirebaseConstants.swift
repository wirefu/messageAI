//
//  FirebaseConstants.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Firebase Firestore collection names and field keys
enum FirebaseConstants {
    // MARK: - Collection Names

    /// Users collection
    static let usersCollection = "users"

    /// Conversations collection
    static let conversationsCollection = "conversations"

    /// Messages subcollection (within conversations)
    static let messagesSubcollection = "messages"

    /// Action items subcollection (within conversations)
    static let actionItemsSubcollection = "actionItems"

    /// Summaries subcollection (within conversations)
    static let summariesSubcollection = "summaries"

    // MARK: - User Fields

    enum UserFields {
        static let id = "id"
        static let displayName = "displayName"
        static let email = "email"
        static let avatarURL = "avatarURL"
        static let isOnline = "isOnline"
        static let lastSeen = "lastSeen"
        static let fcmToken = "fcmToken"
        static let createdAt = "createdAt"
    }

    // MARK: - Conversation Fields

    enum ConversationFields {
        static let id = "id"
        static let participants = "participants"
        static let lastMessage = "lastMessage"
        static let lastMessageTimestamp = "lastMessageTimestamp"
        static let unreadCount = "unreadCount"
        static let createdAt = "createdAt"
    }

    // MARK: - Message Fields

    enum MessageFields {
        static let id = "id"
        static let conversationID = "conversationID"
        static let senderID = "senderID"
        static let content = "content"
        static let timestamp = "timestamp"
        static let deliveredAt = "deliveredAt"
        static let readAt = "readAt"
        static let status = "status"
        static let aiSuggestions = "aiSuggestions"
    }

    // MARK: - Action Item Fields

    enum ActionItemFields {
        static let id = "id"
        static let conversationID = "conversationID"
        static let messageID = "messageID"
        static let description = "description"
        static let assignedTo = "assignedTo"
        static let dueDate = "dueDate"
        static let isCompleted = "isCompleted"
        static let createdAt = "createdAt"
    }

    // MARK: - Summary Fields

    enum SummaryFields {
        static let conversationID = "conversationID"
        static let messageRange = "messageRange"
        static let keyPoints = "keyPoints"
        static let decisions = "decisions"
        static let actionItems = "actionItems"
        static let openQuestions = "openQuestions"
        static let createdAt = "createdAt"
    }

    // MARK: - Cloud Function Names

    enum CloudFunctions {
        static let summarizeConversation = "summarizeConversation"
        static let checkClarity = "checkClarity"
        static let extractActionItems = "extractActionItems"
    }
}

