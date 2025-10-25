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
    
    /// AI Chat sessions subcollection (within users)
    static let aiSessionsSubcollection = "aiSessions"
    
    /// AI Chat messages subcollection (within AI sessions)
    static let aiMessagesSubcollection = "aiMessages"
    
    /// AI Usage stats subcollection (within users)
    static let aiUsageStatsSubcollection = "aiUsageStats"
    
    /// AI Cache collection
    static let aiCacheCollection = "aiCache"

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
        static let isAIGenerated = "isAIGenerated"
        static let aiSources = "aiSources"
        static let aiMetadata = "aiMetadata"
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

    // MARK: - AI Chat Fields

    enum AIChatFields {
        static let id = "id"
        static let sessionID = "sessionID"
        static let userID = "userID"
        static let content = "content"
        static let role = "role"
        static let timestamp = "timestamp"
        static let aiMetadata = "aiMetadata"
    }

    // MARK: - AI Chat Session Fields

    enum AIChatSessionFields {
        static let id = "id"
        static let userID = "userID"
        static let title = "title"
        static let description = "description"
        static let createdAt = "createdAt"
        static let lastUpdated = "lastUpdated"
        static let isActive = "isActive"
        static let settings = "settings"
        static let statistics = "statistics"
        static let includeContext = "includeContext"
        static let enableSuggestions = "enableSuggestions"
        static let enableActions = "enableActions"
        static let preferredModel = "preferredModel"
        static let responseStyle = "responseStyle"
    }

    // MARK: - AI Usage Fields

    enum AIUsageFields {
        static let id = "id"
        static let totalInteractions = "totalInteractions"
        static let actionsExecuted = "actionsExecuted"
        static let suggestionsProvided = "suggestionsProvided"
        static let searchesPerformed = "searchesPerformed"
        static let totalTokensUsed = "totalTokensUsed"
        static let totalCostCents = "totalCostCents"
        static let lastUpdated = "lastUpdated"
        static let dailyUsage = "dailyUsage"
        static let featureUsage = "featureUsage"
    }

    // MARK: - AI Search Fields

    enum AISearchFields {
        static let id = "id"
        static let messageID = "messageID"
        static let conversationID = "conversationID"
        static let content = "content"
        static let senderID = "senderID"
        static let timestamp = "timestamp"
        static let relevance = "relevance"
        static let searchQuery = "searchQuery"
        static let context = "context"
        static let metadata = "metadata"
    }

    // MARK: - Cloud Function Names

    enum CloudFunctions {
        static let summarizeConversation = "summarizeConversation"
        static let checkClarity = "checkClarity"
        static let extractActionItems = "extractActionItems"
        static let aiChatInterface = "aiChatInterface"
        static let executeAIChatAction = "executeAIChatAction"
        static let getAIChatSuggestions = "getAIChatSuggestions"
        static let searchAIConversations = "searchAIConversations"
        static let getAIUsageStats = "getAIUsageStats"
        static let indexMessageForAI = "indexMessageForAI"
        static let getAIChatHistory = "getAIChatHistory"
        static let clearAIChatSession = "clearAIChatSession"
    }
    
    // MARK: - AI Message Fields
    
    enum AIMessageFields {
        static let id = "id"
        static let role = "role"
        static let content = "content"
        static let timestamp = "timestamp"
        static let sources = "sources"
    }
    
    // MARK: - AI Session Fields
    
    enum AISessionFields {
        static let id = "id"
        static let userId = "userId"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let messages = "messages"
        static let isActive = "isActive"
    }
    
    // MARK: - Message Action Fields
    
    enum MessageActionFields {
        static let id = "id"
        static let type = "type"
        static let name = "name"
        static let description = "description"
        static let isAvailable = "isAvailable"
        static let parameters = "parameters"
    }
    
    // MARK: - Proactive Suggestion Fields
    
    enum ProactiveSuggestionFields {
        static let id = "id"
        static let type = "type"
        static let suggestion = "suggestion"
        static let severity = "severity"
        static let isActionable = "isActionable"
        static let action = "action"
        static let createdAt = "createdAt"
        static let isDismissed = "isDismissed"
    }
}
