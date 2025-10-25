//
//  FirebaseConfig.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

/// Firebase configuration and setup utilities
enum FirebaseConfig {
    // MARK: - Firestore Settings

    /// Configures Firestore with optimal settings for MessengerAI
    static func configureFirestore() {
        let settings = Firestore.firestore().settings

        // Enable offline persistence for better UX
        settings.isPersistenceEnabled = true

        // Unlimited cache size for message history
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited

        Firestore.firestore().settings = settings
    }

    // MARK: - Environment

    /// Current Firebase environment
    enum Environment {
        case development
        case staging
        case production

        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }

    /// Checks if running in debug mode
    static var isDebug: Bool {
        Environment.current == .development
    }

    // MARK: - Logging

    /// Logs Firebase configuration status
    static func logConfiguration() {
        #if DEBUG
        print("🔧 Firebase Environment: \(Environment.current)")
        print("🔧 Offline Persistence: Enabled")
        print("🔧 Cache Size: Unlimited")
        #endif
    }
}
