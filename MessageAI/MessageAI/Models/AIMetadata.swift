//
//  AIMetadata.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// AI metadata for a message (tokens, cost, model used, etc.)
struct AIMetadata: Codable, Equatable {
    /// Model used for generation
    var model: String?
    
    /// Number of input tokens
    var inputTokens: Int?
    
    /// Number of output tokens
    var outputTokens: Int?
    
    /// Cost in cents
    var costCents: Double?
    
    /// Generation time in milliseconds
    var generationTimeMs: Int?
    
    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case model
        case inputTokens
        case outputTokens
        case costCents
        case generationTimeMs
    }
}

// MARK: - Helpers

extension AIMetadata {
    /// Total tokens used
    var totalTokens: Int {
        (inputTokens ?? 0) + (outputTokens ?? 0)
    }
    
    /// Cost in dollars
    var costDollars: Double {
        (costCents ?? 0.0) / 100.0
    }
}
