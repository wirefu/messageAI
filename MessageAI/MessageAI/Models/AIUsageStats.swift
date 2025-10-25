//
//  AIUsageStats.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents AI usage statistics for a user
struct AIUsageStats: Codable, Identifiable, Equatable {
    /// Unique identifier (user ID)
    let id: String
    
    /// Total number of AI interactions
    var totalInteractions: Int
    
    /// Number of AI actions executed
    var actionsExecuted: Int
    
    /// Number of suggestions provided
    var suggestionsProvided: Int
    
    /// Number of searches performed
    var searchesPerformed: Int
    
    /// Total tokens used
    var totalTokensUsed: Int
    
    /// Total cost in cents
    var totalCostCents: Int
    
    /// When stats were last updated
    var lastUpdated: Date
    
    /// Daily usage breakdown
    var dailyUsage: [AIUsageDay]?
    
    /// Feature usage breakdown
    var featureUsage: AIFeatureUsage?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case totalInteractions
        case actionsExecuted
        case suggestionsProvided
        case searchesPerformed
        case totalTokensUsed
        case totalCostCents
        case lastUpdated
        case dailyUsage
        case featureUsage
    }
}

/// Daily AI usage breakdown
struct AIUsageDay: Codable, Equatable {
    /// Date of usage
    var date: Date
    
    /// Number of interactions on this day
    var interactions: Int
    
    /// Number of actions executed
    var actions: Int
    
    /// Number of suggestions provided
    var suggestions: Int
    
    /// Number of searches performed
    var searches: Int
    
    /// Tokens used on this day
    var tokensUsed: Int
    
    /// Cost in cents for this day
    var costCents: Int
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case date
        case interactions
        case actions
        case suggestions
        case searches
        case tokensUsed
        case costCents
    }
}

/// Feature usage breakdown
struct AIFeatureUsage: Codable, Equatable {
    /// Chat interface usage
    var chatInterface: Int
    
    /// Message actions usage
    var messageActions: Int
    
    /// Search functionality usage
    var search: Int
    
    /// Suggestions usage
    var suggestions: Int
    
    /// Translation usage
    var translation: Int
    
    /// Rewrite usage
    var rewrite: Int
    
    /// Action extraction usage
    var actionExtraction: Int
    
    /// Tone analysis usage
    var toneAnalysis: Int
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case chatInterface
        case messageActions
        case search
        case suggestions
        case translation
        case rewrite
        case actionExtraction
        case toneAnalysis
    }
}

// MARK: - Firestore Extensions

extension AIUsageStats {
    /// Converts AI usage stats to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.AIUsageFields.id: id,
            FirebaseConstants.AIUsageFields.totalInteractions: totalInteractions,
            FirebaseConstants.AIUsageFields.actionsExecuted: actionsExecuted,
            FirebaseConstants.AIUsageFields.suggestionsProvided: suggestionsProvided,
            FirebaseConstants.AIUsageFields.searchesPerformed: searchesPerformed,
            FirebaseConstants.AIUsageFields.totalTokensUsed: totalTokensUsed,
            FirebaseConstants.AIUsageFields.totalCostCents: totalCostCents,
            FirebaseConstants.AIUsageFields.lastUpdated: Timestamp(date: lastUpdated)
        ]
        
        if let dailyUsage = dailyUsage,
           let dailyUsageData = try? JSONEncoder().encode(dailyUsage),
           let dailyUsageDict = try? JSONSerialization.jsonObject(with: dailyUsageData) as? [String: Any] {
            data[FirebaseConstants.AIUsageFields.dailyUsage] = dailyUsageDict
        }
        
        if let featureUsage = featureUsage,
           let featureUsageData = try? JSONEncoder().encode(featureUsage),
           let featureUsageDict = try? JSONSerialization.jsonObject(with: featureUsageData) as? [String: Any] {
            data[FirebaseConstants.AIUsageFields.featureUsage] = featureUsageDict
        }
        
        return data
    }
    
    /// Creates AI usage stats from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: AIUsageStats instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> AIUsageStats? {
        guard let data = document.data() else { return nil }
        
        var dailyUsage: [AIUsageDay]?
        if let dailyUsageDict = data[FirebaseConstants.AIUsageFields.dailyUsage] as? [String: Any],
           let dailyUsageData = try? JSONSerialization.data(withJSONObject: dailyUsageDict) {
            dailyUsage = try? JSONDecoder().decode([AIUsageDay].self, from: dailyUsageData)
        }
        
        var featureUsage: AIFeatureUsage?
        if let featureUsageDict = data[FirebaseConstants.AIUsageFields.featureUsage] as? [String: Any],
           let featureUsageData = try? JSONSerialization.data(withJSONObject: featureUsageDict) {
            featureUsage = try? JSONDecoder().decode(AIFeatureUsage.self, from: featureUsageData)
        }
        
        return AIUsageStats(
            id: document.documentID,
            totalInteractions: data[FirebaseConstants.AIUsageFields.totalInteractions] as? Int ?? 0,
            actionsExecuted: data[FirebaseConstants.AIUsageFields.actionsExecuted] as? Int ?? 0,
            suggestionsProvided: data[FirebaseConstants.AIUsageFields.suggestionsProvided] as? Int ?? 0,
            searchesPerformed: data[FirebaseConstants.AIUsageFields.searchesPerformed] as? Int ?? 0,
            totalTokensUsed: data[FirebaseConstants.AIUsageFields.totalTokensUsed] as? Int ?? 0,
            totalCostCents: data[FirebaseConstants.AIUsageFields.totalCostCents] as? Int ?? 0,
            lastUpdated: (data[FirebaseConstants.AIUsageFields.lastUpdated] as? Timestamp)?.dateValue() ?? Date(),
            dailyUsage: dailyUsage,
            featureUsage: featureUsage
        )
    }
}

// MARK: - Helpers

extension AIUsageStats {
    /// Whether user has any AI usage
    var hasUsage: Bool {
        totalInteractions > 0
    }
    
    /// Total cost in dollars
    var totalCostDollars: Double {
        Double(totalCostCents) / 100.0
    }
    
    /// Average cost per interaction in cents
    var averageCostPerInteraction: Int {
        guard totalInteractions > 0 else { return 0 }
        return totalCostCents / totalInteractions
    }
    
    /// Usage efficiency score (0.0 - 1.0)
    var efficiencyScore: Double {
        guard totalInteractions > 0 else { return 0.0 }
        let actionRate = Double(actionsExecuted) / Double(totalInteractions)
        let suggestionRate = Double(suggestionsProvided) / Double(totalInteractions)
        return (actionRate + suggestionRate) / 2.0
    }
}

extension AIUsageDay {
    /// Cost in dollars for this day
    var costDollars: Double {
        Double(costCents) / 100.0
    }
    
    /// Whether this day had any usage
    var hasUsage: Bool {
        interactions > 0 || actions > 0 || suggestions > 0 || searches > 0
    }
}

extension AIFeatureUsage {
    /// Total feature usage
    var totalUsage: Int {
        chatInterface + messageActions + search + suggestions + translation + rewrite + actionExtraction + toneAnalysis
    }
    
    /// Most used feature
    var mostUsedFeature: String {
        let features = [
            "chatInterface": chatInterface,
            "messageActions": messageActions,
            "search": search,
            "suggestions": suggestions,
            "translation": translation,
            "rewrite": rewrite,
            "actionExtraction": actionExtraction,
            "toneAnalysis": toneAnalysis
        ]
        
        return features.max(by: { $0.value < $1.value })?.key ?? "chatInterface"
    }
}
