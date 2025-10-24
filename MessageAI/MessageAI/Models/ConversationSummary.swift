//
//  ConversationSummary.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// AI-generated summary of a conversation
struct ConversationSummary: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String

    /// ID of the conversation
    let conversationID: String

    /// Date range of messages covered by this summary
    var messageRange: DateRange

    /// Key points discussed
    var keyPoints: [String]

    /// Decisions made
    var decisions: [String]

    /// Action items identified
    var actionItems: [String]

    /// Open questions
    var openQuestions: [String]

    /// When the summary was created
    var createdAt: Date

    /// Coding keys for Firestore mapping
    enum CodingKeys: String, CodingKey {
        case id
        case conversationID
        case messageRange
        case keyPoints
        case decisions
        case actionItems
        case openQuestions
        case createdAt
    }

    /// Date range for summary coverage
    struct DateRange: Codable, Equatable {
        let start: Date
        let end: Date

        enum CodingKeys: String, CodingKey {
            case start
            case end
        }
    }
}

// MARK: - Firestore Extensions

extension ConversationSummary {
    /// Converts summary to Firestore dictionary
    /// - Returns: Dictionary representation for Firestore
    func toFirestore() -> [String: Any] {
        [
            FirebaseConstants.SummaryFields.conversationID: conversationID,
            FirebaseConstants.SummaryFields.messageRange: [
                "start": Timestamp(date: messageRange.start),
                "end": Timestamp(date: messageRange.end)
            ],
            FirebaseConstants.SummaryFields.keyPoints: keyPoints,
            FirebaseConstants.SummaryFields.decisions: decisions,
            FirebaseConstants.SummaryFields.actionItems: actionItems,
            FirebaseConstants.SummaryFields.openQuestions: openQuestions,
            FirebaseConstants.SummaryFields.createdAt: Timestamp(date: createdAt)
        ]
    }

    /// Creates summary from Firestore document
    /// - Parameter document: Firestore document snapshot
    /// - Returns: ConversationSummary instance or nil if decoding fails
    static func from(document: DocumentSnapshot) -> ConversationSummary? {
        guard let data = document.data() else { return nil }

        guard let rangeData = data[FirebaseConstants.SummaryFields.messageRange] as? [String: Any],
              let startTimestamp = rangeData["start"] as? Timestamp,
              let endTimestamp = rangeData["end"] as? Timestamp else {
            return nil
        }

        return ConversationSummary(
            id: document.documentID,
            conversationID: data[FirebaseConstants.SummaryFields.conversationID] as? String ?? "",
            messageRange: DateRange(
                start: startTimestamp.dateValue(),
                end: endTimestamp.dateValue()
            ),
            keyPoints: data[FirebaseConstants.SummaryFields.keyPoints] as? [String] ?? [],
            decisions: data[FirebaseConstants.SummaryFields.decisions] as? [String] ?? [],
            actionItems: data[FirebaseConstants.SummaryFields.actionItems] as? [String] ?? [],
            openQuestions: data[FirebaseConstants.SummaryFields.openQuestions] as? [String] ?? [],
            createdAt: (data[FirebaseConstants.SummaryFields.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}

// MARK: - Helpers

extension ConversationSummary {
    /// Whether the summary has any content
    var hasContent: Bool {
        !keyPoints.isEmpty || !decisions.isEmpty || !actionItems.isEmpty || !openQuestions.isEmpty
    }

    /// Total number of items in the summary
    var totalItems: Int {
        keyPoints.count + decisions.count + actionItems.count + openQuestions.count
    }
}

