//
//  AIChatSession.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents an AI Chat session
struct AIChatSession: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// ID of the user who owns this session
    var userID: String
    
    /// Session title (auto-generated or user-defined)
    var title: String
    
    /// Session description (optional)
    var description: String?
    
    /// When the session was created
    var createdAt: Date
    
    /// When the session was last updated
    var lastUpdated: Date
    
    /// Whether the session is active
    var isActive: Bool
    
    /// Session settings
    var settings: AIChatSettings
    
    /// Session statistics
    var statistics: AIChatStatistics?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case title
        case description
        case createdAt
        case lastUpdated
        case isActive
        case settings
        case statistics
    }
}

/// AI Chat session settings
struct AIChatSettings: Codable, Equatable {
    /// Whether to include conversation context
    var includeContext: Bool
    
    /// Whether to provide proactive suggestions
    var enableSuggestions: Bool
    
    /// Whether to enable message actions
    var enableActions: Bool
    
    /// Preferred AI model
    var preferredModel: String?
    
    /// Response style preference
    var responseStyle: AIChatResponseStyle
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case includeContext
        case enableSuggestions
        case enableActions
        case preferredModel
        case responseStyle
    }
}

/// AI Chat response style
enum AIChatResponseStyle: String, Codable, CaseIterable {
    case professional
    case casual
    case technical
    case friendly
}

/// AI Chat session statistics
struct AIChatStatistics: Codable, Equatable {
    /// Total number of messages in session
    var totalMessages: Int
    
    /// Number of user messages
    var userMessages: Int
    
    /// Number of assistant messages
    var assistantMessages: Int
    
    /// Total response time in milliseconds
    var totalResponseTime: Int
    
    /// Average response time in milliseconds
    var averageResponseTime: Int
    
    /// Number of suggestions provided
    var suggestionsProvided: Int
    
    /// Number of actions executed
    var actionsExecuted: Int
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case totalMessages
        case userMessages
        case assistantMessages
        case totalResponseTime
        case averageResponseTime
        case suggestionsProvided
        case actionsExecuted
    }
}

// MARK: - Firestore Extensions

extension AIChatSession {
    /// Converts AI chat session to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.AIChatSessionFields.id: id,
            FirebaseConstants.AIChatSessionFields.userID: userID,
            FirebaseConstants.AIChatSessionFields.title: title,
            FirebaseConstants.AIChatSessionFields.createdAt: Timestamp(date: createdAt),
            FirebaseConstants.AIChatSessionFields.lastUpdated: Timestamp(date: lastUpdated),
            FirebaseConstants.AIChatSessionFields.isActive: isActive,
            FirebaseConstants.AIChatSessionFields.settings: [
                FirebaseConstants.AIChatSessionFields.includeContext: settings.includeContext,
                FirebaseConstants.AIChatSessionFields.enableSuggestions: settings.enableSuggestions,
                FirebaseConstants.AIChatSessionFields.enableActions: settings.enableActions,
                FirebaseConstants.AIChatSessionFields.responseStyle: settings.responseStyle.rawValue
            ]
        ]
        
        if let description = description {
            data[FirebaseConstants.AIChatSessionFields.description] = description
        }
        
        if let preferredModel = settings.preferredModel {
            data[FirebaseConstants.AIChatSessionFields.preferredModel] = preferredModel
        }
        
        if let statistics = statistics,
           let statisticsData = try? JSONEncoder().encode(statistics),
           let statisticsDict = try? JSONSerialization.jsonObject(with: statisticsData) as? [String: Any] {
            data[FirebaseConstants.AIChatSessionFields.statistics] = statisticsDict
        }
        
        return data
    }
    
    /// Creates AI chat session from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: AIChatSession instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> AIChatSession? {
        guard let data = document.data() else { return nil }
        
        let settingsData = data[FirebaseConstants.AIChatSessionFields.settings] as? [String: Any] ?? [:]
        let settings = AIChatSettings(
            includeContext: settingsData[FirebaseConstants.AIChatSessionFields.includeContext] as? Bool ?? true,
            enableSuggestions: settingsData[FirebaseConstants.AIChatSessionFields.enableSuggestions] as? Bool ?? true,
            enableActions: settingsData[FirebaseConstants.AIChatSessionFields.enableActions] as? Bool ?? true,
            preferredModel: settingsData[FirebaseConstants.AIChatSessionFields.preferredModel] as? String,
            responseStyle: AIChatResponseStyle(
                rawValue: settingsData[FirebaseConstants.AIChatSessionFields.responseStyle] as? String ?? "professional"
            ) ?? .professional
        )
        
        var statistics: AIChatStatistics?
        if let statisticsDict = data[FirebaseConstants.AIChatSessionFields.statistics] as? [String: Any],
           let statisticsData = try? JSONSerialization.data(withJSONObject: statisticsDict) {
            statistics = try? JSONDecoder().decode(AIChatStatistics.self, from: statisticsData)
        }
        
        return AIChatSession(
            id: document.documentID,
            userID: data[FirebaseConstants.AIChatSessionFields.userID] as? String ?? "",
            title: data[FirebaseConstants.AIChatSessionFields.title] as? String ?? "AI Chat",
            description: data[FirebaseConstants.AIChatSessionFields.description] as? String,
            createdAt: (data[FirebaseConstants.AIChatSessionFields.createdAt] as? Timestamp)?.dateValue() ?? Date(),
            lastUpdated: (data[FirebaseConstants.AIChatSessionFields.lastUpdated] as? Timestamp)?.dateValue() ?? Date(),
            isActive: data[FirebaseConstants.AIChatSessionFields.isActive] as? Bool ?? true,
            settings: settings,
            statistics: statistics
        )
    }
}

// MARK: - Helpers

extension AIChatSession {
    /// Whether the session has any messages
    var hasMessages: Bool {
        statistics?.totalMessages ?? 0 > 0
    }
    
    /// Whether the session is recent (within last 24 hours)
    var isRecent: Bool {
        Date().timeIntervalSince(lastUpdated) < 86400 // 24 hours
    }
    
    /// Session duration in minutes
    var durationMinutes: Int {
        Int(lastUpdated.timeIntervalSince(createdAt) / 60)
    }
}

extension AIChatStatistics {
    /// Whether any statistics are available
    var hasStatistics: Bool {
        totalMessages > 0
    }
    
    /// Average response time in seconds
    var averageResponseTimeSeconds: Double {
        Double(averageResponseTime) / 1000.0
    }
    
    /// User message percentage
    var userMessagePercentage: Double {
        guard totalMessages > 0 else { return 0.0 }
        return Double(userMessages) / Double(totalMessages) * 100.0
    }
    
    /// Assistant message percentage
    var assistantMessagePercentage: Double {
        guard totalMessages > 0 else { return 0.0 }
        return Double(assistantMessages) / Double(totalMessages) * 100.0
    }
}
