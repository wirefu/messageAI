//
//  AppConstants.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import SwiftUI

/// Application-wide constants for MessengerAI
enum AppConstants {
    // MARK: - App Information

    static let appName = "MessengerAI"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // MARK: - Messaging Configuration

    enum Messaging {
        /// Maximum message length in characters
        static let maxMessageLength = 10000

        /// Maximum messages to load per page
        static let messagesPerPage = 50

        /// Typing indicator timeout in seconds
        static let typingIndicatorTimeout: TimeInterval = 3.0

        /// Maximum messages in offline queue
        static let maxOfflineQueueSize = 100
    }

    // MARK: - AI Features Configuration

    enum AIFeatures {
        /// Minimum messages to trigger auto-summarization
        static let minMessagesForSummary = 15

        /// Minimum offline hours to trigger auto-summary
        static let minOfflineHoursForSummary: TimeInterval = 6 * 60 * 60 // 6 hours

        /// Debounce delay for clarity checks in seconds
        static let clarityCheckDebounce: TimeInterval = 2.0

        /// Summary cache duration in seconds
        static let summaryCacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours

        /// Clarity suggestion cache duration in seconds
        static let clarityCacheDuration: TimeInterval = 5 * 60 // 5 minutes
    }

    // MARK: - UI Configuration

    enum UIConfig {
        /// Message bubble corner radius
        static let messageBubbleRadius: CGFloat = 16

        /// Message bubble padding
        static let messageBubblePadding: CGFloat = 12

        /// Standard spacing
        static let standardSpacing: CGFloat = 16

        /// Small spacing
        static let smallSpacing: CGFloat = 8

        /// Large spacing
        static let largeSpacing: CGFloat = 24

        /// Minimum touch target size
        static let minTouchTarget: CGFloat = 44

        /// Animation duration
        static let animationDuration: TimeInterval = 0.3
    }

    // MARK: - Time Formats

    enum TimeFormats {
        static let messageTime = "h:mm a"
        static let messageDate = "MMM d, yyyy"
        static let fullDateTime = "MMM d, yyyy 'at' h:mm a"
        static let relativeDays = "EEEE" // Monday, Tuesday, etc.
    }

    // MARK: - Validation Rules

    enum Validation {
        /// Minimum password length
        static let minPasswordLength = 8

        /// Minimum display name length
        static let minDisplayNameLength = 2

        /// Maximum display name length
        static let maxDisplayNameLength = 50

        /// Email regex pattern
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }

    // MARK: - Notifications

    enum Notifications {
        static let userDidSignIn = "userDidSignIn"
        static let userDidSignOut = "userDidSignOut"
        static let networkStatusChanged = "networkStatusChanged"
        static let newMessageReceived = "newMessageReceived"
    }
}

