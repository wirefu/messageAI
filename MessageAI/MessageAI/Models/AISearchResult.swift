//
//  AISearchResult.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Represents a search result from AI-powered conversation search
struct AISearchResult: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// ID of the original message
    let messageID: String
    
    /// ID of the conversation containing this message
    let conversationID: String
    
    /// Message content
    var content: String
    
    /// ID of the message sender
    let senderID: String
    
    /// When the message was created
    var timestamp: Date
    
    /// Relevance score (0.0 - 1.0)
    var relevance: Double
    
    /// Search query that matched this result
    var searchQuery: String
    
    /// Additional context from the conversation
    var context: String?
    
    /// Message metadata
    var metadata: AISearchMetadata?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case messageID
        case conversationID
        case content
        case senderID
        case timestamp
        case relevance
        case searchQuery
        case context
        case metadata
    }
}

/// AI Search metadata
struct AISearchMetadata: Codable, Equatable {
    /// Type of search performed
    var searchType: AISearchType
    
    /// AI model used for search
    var model: String?
    
    /// Search execution time in milliseconds
    var searchTime: Int?
    
    /// Number of results found
    var totalResults: Int?
    
    /// Search filters applied
    var filters: [String: String]?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case searchType
        case model
        case searchTime
        case totalResults
        case filters
    }
}

/// Type of AI search performed
enum AISearchType: String, Codable, CaseIterable {
    case semantic
    case keyword
    case hybrid
    case vector
}

// MARK: - Firestore Extensions

extension AISearchResult {
    /// Converts AI search result to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            FirebaseConstants.AISearchFields.id: id,
            FirebaseConstants.AISearchFields.messageID: messageID,
            FirebaseConstants.AISearchFields.conversationID: conversationID,
            FirebaseConstants.AISearchFields.content: content,
            FirebaseConstants.AISearchFields.senderID: senderID,
            FirebaseConstants.AISearchFields.timestamp: Timestamp(date: timestamp),
            FirebaseConstants.AISearchFields.relevance: relevance,
            FirebaseConstants.AISearchFields.searchQuery: searchQuery
        ]
        
        if let context = context {
            data[FirebaseConstants.AISearchFields.context] = context
        }
        
        if let metadata = metadata,
           let metadataData = try? JSONEncoder().encode(metadata),
           let metadataDict = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] {
            data[FirebaseConstants.AISearchFields.metadata] = metadataDict
        }
        
        return data
    }
    
    /// Creates AI search result from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: AISearchResult instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> AISearchResult? {
        guard let data = document.data() else { return nil }
        
        var metadata: AISearchMetadata?
        if let metadataDict = data[FirebaseConstants.AISearchFields.metadata] as? [String: Any],
           let metadataData = try? JSONSerialization.data(withJSONObject: metadataDict) {
            metadata = try? JSONDecoder().decode(AISearchMetadata.self, from: metadataData)
        }
        
        return AISearchResult(
            id: document.documentID,
            messageID: data[FirebaseConstants.AISearchFields.messageID] as? String ?? "",
            conversationID: data[FirebaseConstants.AISearchFields.conversationID] as? String ?? "",
            content: data[FirebaseConstants.AISearchFields.content] as? String ?? "",
            senderID: data[FirebaseConstants.AISearchFields.senderID] as? String ?? "",
            timestamp: (data[FirebaseConstants.AISearchFields.timestamp] as? Timestamp)?.dateValue() ?? Date(),
            relevance: data[FirebaseConstants.AISearchFields.relevance] as? Double ?? 0.0,
            searchQuery: data[FirebaseConstants.AISearchFields.searchQuery] as? String ?? "",
            context: data[FirebaseConstants.AISearchFields.context] as? String,
            metadata: metadata
        )
    }
}

// MARK: - Helpers

extension AISearchResult {
    /// Whether this result is highly relevant (relevance > 0.8)
    var isHighlyRelevant: Bool {
        relevance > 0.8
    }
    
    /// Whether this result is moderately relevant (relevance > 0.5)
    var isModeratelyRelevant: Bool {
        relevance > 0.5
    }
    
    /// Whether this result is low relevance (relevance < 0.3)
    var isLowRelevance: Bool {
        relevance < 0.3
    }
    
    /// Relevance level description
    var relevanceLevel: String {
        if isHighlyRelevant {
            return "Highly Relevant"
        } else if isModeratelyRelevant {
            return "Moderately Relevant"
        } else if isLowRelevance {
            return "Low Relevance"
        } else {
            return "Somewhat Relevant"
        }
    }
    
    /// Whether this result has context
    var hasContext: Bool {
        context?.isEmpty == false
    }
    
    /// Whether this result has metadata
    var hasMetadata: Bool {
        metadata != nil
    }
}

extension AISearchMetadata {
    /// Whether any metadata is present
    var hasMetadata: Bool {
        model != nil ||
        searchTime != nil ||
        totalResults != nil ||
        filters?.isEmpty == false
    }
    
    /// Search performance score (0.0 - 1.0)
    var performanceScore: Double {
        guard let searchTime = searchTime, let totalResults = totalResults else { return 0.0 }
        
        // Lower search time and higher results = better performance
        let timeScore = max(0.0, 1.0 - Double(searchTime) / 1000.0) // Normalize to 1 second
        let resultsScore = min(1.0, Double(totalResults) / 10.0) // Normalize to 10 results
        
        return (timeScore + resultsScore) / 2.0
    }
}
