//
//  SummaryAutoTriggerService.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Service to handle auto-triggering of conversation summaries
final class SummaryAutoTriggerService {
    // MARK: - Singleton
    
    static let shared = SummaryAutoTriggerService()
    
    private init() {}
    
    // MARK: - Auto-Trigger Logic
    
    /// Determines if a summary should be auto-triggered
    /// - Parameters:
    ///   - unreadMessageCount: Number of unread messages
    ///   - lastOnlineTimestamp: When user was last online
    ///   - conversationID: Conversation ID to check
    /// - Returns: True if summary should be triggered
    func shouldAutoTriggerSummary(
        unreadMessageCount: Int,
        lastOnlineTimestamp: Date,
        conversationID: String
    ) -> Bool {
        // Trigger conditions:
        // 1. User has 15+ unread messages
        // 2. User has been offline for 6+ hours
        
        let hasEnoughUnreadMessages = unreadMessageCount >= 15
        let hoursOffline = Date().timeIntervalSince(lastOnlineTimestamp) / 3600
        let hasBeenOfflineLongEnough = hoursOffline >= 6
        
        return hasEnoughUnreadMessages && hasBeenOfflineLongEnough
    }
    
    /// Checks if user has already seen auto-trigger prompt for this conversation
    /// - Parameter conversationID: Conversation ID
    /// - Returns: True if prompt was already shown
    func hasShownAutoTriggerPrompt(conversationID: String) -> Bool {
        let key = "autoTriggerPromptShown_\(conversationID)"
        return UserDefaultsManager.shared.bool(forKey: key)
    }
    
    /// Marks that auto-trigger prompt was shown
    /// - Parameter conversationID: Conversation ID
    func markAutoTriggerPromptShown(conversationID: String) {
        let key = "autoTriggerPromptShown_\(conversationID)"
        UserDefaultsManager.shared.set(true, forKey: key)
    }
    
    /// Resets auto-trigger prompt state (e.g., after user reads messages)
    /// - Parameter conversationID: Conversation ID
    func resetAutoTriggerPrompt(conversationID: String) {
        let key = "autoTriggerPromptShown_\(conversationID)"
        UserDefaultsManager.shared.remove(forKey: key)
    }
    
    /// Gets recommended message count for auto-triggered summary
    /// - Parameter totalMessages: Total messages in conversation
    /// - Returns: Number of recent messages to include
    func getRecommendedMessageCount(totalMessages: Int) -> Int {
        // Include last 20-50 messages depending on total
        if totalMessages <= 20 {
            return totalMessages
        } else if totalMessages <= 50 {
            return 30
        } else {
            return 50 // Max for performance
        }
    }
}


