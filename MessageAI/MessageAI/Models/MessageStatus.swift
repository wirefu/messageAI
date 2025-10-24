//
//  MessageStatus.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Represents the delivery status of a message
enum MessageStatus: String, Codable {
    /// Message is being sent (local state)
    case sending

    /// Message successfully sent to server
    case sent

    /// Message delivered to recipient's device
    case delivered

    /// Message has been read by recipient
    case read

    /// Message failed to send
    case failed
}

// MARK: - Status Helpers

extension MessageStatus {
    /// Whether the status indicates a successful state
    var isSuccessful: Bool {
        switch self {
        case .sent, .delivered, .read:
            return true
        case .sending, .failed:
            return false
        }
    }

    /// Whether the message can be retried
    var canRetry: Bool {
        self == .failed
    }

    /// Display text for the status
    var displayText: String {
        switch self {
        case .sending:
            return "Sending..."
        case .sent:
            return "Sent"
        case .delivered:
            return "Delivered"
        case .read:
            return "Read"
        case .failed:
            return "Failed to send"
        }
    }
}

