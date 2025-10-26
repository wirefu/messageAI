//
//  proactiveSuggestions.ts
//  MessageAI Cloud Functions
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import * as admin from 'firebase-admin';
import { DetectionRules, ProactiveSuggestion, Message } from '../utils/detectionRules';

interface SuggestionFrequency {
  conversationId: string;
  lastSuggestionTime: admin.firestore.Timestamp;
  suggestionCount: number;
}

interface UserTimezone {
  userId: string;
  timezone: string;
}

/**
 * Proactive Suggestions Handler
 * Generates and manages proactive suggestions for users
 */
export class ProactiveSuggestionsHandler {
  private db: admin.firestore.Firestore;
  private readonly RECENT_MESSAGES_HOURS = 24; // Look back 24 hours

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Generate proactive suggestions for a user
   * @param userId User ID to generate suggestions for
   * @returns Generated suggestion or null if none found
   */
  async generateProactiveSuggestions(userId: string): Promise<ProactiveSuggestion | null> {
    try {
      console.log(`🔍 Generating proactive suggestions for user: ${userId}`);

      // Check suggestion frequency limits
      const canGenerateSuggestion = await this.checkSuggestionFrequency(userId);
      if (!canGenerateSuggestion) {
        console.log(`⏸️ Suggestion frequency limit reached for user: ${userId}`);
        return null;
      }

      // Fetch recent messages
      const recentMessages = await this.fetchRecentMessages(userId);
      if (recentMessages.length === 0) {
        console.log(`📭 No recent messages found for user: ${userId}`);
        return null;
      }

      // Get user timezone information
      const userTimezone = await this.getUserTimezone(userId);
      if (!userTimezone) {
        console.log(`🌍 No timezone information found for user: ${userId}`);
        return null;
      }

      // Run detection rules
      const suggestions = await this.runDetectionRules(recentMessages, userTimezone);
      
      if (suggestions.length === 0) {
        console.log(`✅ No suggestions generated for user: ${userId}`);
        return null;
      }

      // Select highest priority suggestion
      const selectedSuggestion = this.selectHighestPrioritySuggestion(suggestions);
      
      // Save suggestion to Firestore
      await this.saveSuggestionToFirestore(userId, selectedSuggestion);
      
      // Update suggestion frequency tracking
      await this.updateSuggestionFrequency(userId, selectedSuggestion.metadata.conversationId);
      
      console.log(`✅ Generated suggestion for user: ${userId}, type: ${selectedSuggestion.type}`);
      return selectedSuggestion;

    } catch (error) {
      console.error(`❌ Error generating proactive suggestions for user ${userId}:`, error);
      return null;
    }
  }

  /**
   * Check if user can receive more suggestions based on frequency limits
   * @param userId User ID
   * @returns True if can generate suggestion, false otherwise
   */
  private async checkSuggestionFrequency(userId: string): Promise<boolean> {
    try {
      const frequencyDoc = await this.db
        .collection('users')
        .doc(userId)
        .collection('suggestionFrequency')
        .doc('current')
        .get();

      if (!frequencyDoc.exists) {
        return true; // No previous suggestions, allow first one
      }

      const frequency = frequencyDoc.data() as SuggestionFrequency;
      const now = admin.firestore.Timestamp.now();
      const timeDiff = now.seconds - frequency.lastSuggestionTime.seconds;
      const hoursSinceLastSuggestion = timeDiff / 3600;

      // Allow suggestion if it's been more than 2 hours since last suggestion
      return hoursSinceLastSuggestion > 2;

    } catch (error) {
      console.error('Error checking suggestion frequency:', error);
      return true; // Allow suggestion on error
    }
  }

  /**
   * Fetch recent messages for suggestion analysis
   * @param userId User ID
   * @returns Array of recent messages
   */
  private async fetchRecentMessages(userId: string): Promise<Message[]> {
    try {
      const cutoffTime = new Date();
      cutoffTime.setHours(cutoffTime.getHours() - this.RECENT_MESSAGES_HOURS);

      const messagesSnapshot = await this.db
        .collectionGroup('messages')
        .where('senderId', '==', userId)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffTime))
        .orderBy('timestamp', 'desc')
        .limit(50) // Limit to last 50 messages
        .get();

      const messages: Message[] = [];
      messagesSnapshot.forEach(doc => {
        const data = doc.data();
        messages.push({
          id: doc.id,
          content: data.content,
          timestamp: data.timestamp,
          senderId: data.senderId,
          conversationId: data.conversationId
        });
      });

      console.log(`📨 Fetched ${messages.length} recent messages for user: ${userId}`);
      return messages;

    } catch (error) {
      console.error('Error fetching recent messages:', error);
      return [];
    }
  }

  /**
   * Get user timezone information
   * @param userId User ID
   * @returns User timezone or null if not found
   */
  private async getUserTimezone(userId: string): Promise<UserTimezone | null> {
    try {
      const userDoc = await this.db.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return null;
      }

      const userData = userDoc.data();
      const timezone = userData?.timezone || userData?.timeZone || 'UTC';
      
      return {
        userId,
        timezone
      };

    } catch (error) {
      console.error('Error getting user timezone:', error);
      return null;
    }
  }

  /**
   * Run all detection rules on messages
   * @param messages Array of messages
   * @param userTimezone User timezone information
   * @returns Array of generated suggestions
   */
  private async runDetectionRules(
    messages: Message[],
    userTimezone: UserTimezone
  ): Promise<ProactiveSuggestion[]> {
    const suggestions: ProactiveSuggestion[] = [];

    try {
      // Get recipient timezone (simplified - in real app, get from conversation participants)
      const recipientTimezone = await this.getRecipientTimezone(messages[0].conversationId, userTimezone.userId);
      
      // Run timezone ambiguity detection
      const timezoneSuggestion = DetectionRules.detectTimezoneAmbiguity(
        messages,
        userTimezone.timezone,
        recipientTimezone || userTimezone.timezone
      );
      if (timezoneSuggestion) {
        suggestions.push(timezoneSuggestion);
      }

      // Run unclear reference detection
      const referenceSuggestion = DetectionRules.detectUnclearReferences(messages);
      if (referenceSuggestion) {
        suggestions.push(referenceSuggestion);
      }

      // Run missed followup detection (optional)
      const followupSuggestion = DetectionRules.detectMissedFollowups(userTimezone.userId, messages);
      if (followupSuggestion) {
        suggestions.push(followupSuggestion);
      }

      console.log(`🔍 Generated ${suggestions.length} suggestions from detection rules`);
      return suggestions;

    } catch (error) {
      console.error('Error running detection rules:', error);
      return [];
    }
  }

  /**
   * Get recipient timezone for a conversation
   * @param conversationId Conversation ID
   * @param currentUserId Current user ID
   * @returns Recipient timezone or null if not found
   */
  private async getRecipientTimezone(conversationId: string, currentUserId: string): Promise<string | null> {
    try {
      const conversationDoc = await this.db.collection('conversations').doc(conversationId).get();
      
      if (!conversationDoc.exists) {
        return null;
      }

      const conversationData = conversationDoc.data();
      const participants = conversationData?.participants || [];
      
      // Find the other participant
      const otherParticipantId = participants.find((id: string) => id !== currentUserId);
      if (!otherParticipantId) {
        return null;
      }

      // Get other participant's timezone
      const otherUserDoc = await this.db.collection('users').doc(otherParticipantId).get();
      if (!otherUserDoc.exists) {
        return null;
      }

      const otherUserData = otherUserDoc.data();
      return otherUserData?.timezone || otherUserData?.timeZone || 'UTC';

    } catch (error) {
      console.error('Error getting recipient timezone:', error);
      return null;
    }
  }

  /**
   * Select the highest priority suggestion from available suggestions
   * @param suggestions Array of suggestions
   * @returns Highest priority suggestion
   */
  private selectHighestPrioritySuggestion(suggestions: ProactiveSuggestion[]): ProactiveSuggestion {
    // Priority order: high > medium > low
    const priorityOrder = { high: 3, medium: 2, low: 1 };
    
    return suggestions.reduce((highest, current) => {
      const currentPriority = priorityOrder[current.priority];
      const highestPriority = priorityOrder[highest.priority];
      
      return currentPriority > highestPriority ? current : highest;
    });
  }

  /**
   * Save suggestion to Firestore
   * @param userId User ID
   * @param suggestion Suggestion to save
   */
  private async saveSuggestionToFirestore(userId: string, suggestion: ProactiveSuggestion): Promise<void> {
    try {
      await this.db
        .collection('users')
        .doc(userId)
        .collection('proactiveSuggestions')
        .doc(suggestion.id)
        .set({
          ...suggestion,
          dismissed: false,
          actionTaken: false,
          createdAt: admin.firestore.Timestamp.now(),
          expiresAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days from now
          )
        });

      console.log(`💾 Saved suggestion ${suggestion.id} to Firestore for user: ${userId}`);

    } catch (error) {
      console.error('Error saving suggestion to Firestore:', error);
      throw error;
    }
  }

  /**
   * Update suggestion frequency tracking
   * @param userId User ID
   * @param conversationId Conversation ID
   */
  private async updateSuggestionFrequency(userId: string, conversationId: string): Promise<void> {
    try {
      const frequencyRef = this.db
        .collection('users')
        .doc(userId)
        .collection('suggestionFrequency')
        .doc('current');

      await frequencyRef.set({
        conversationId,
        lastSuggestionTime: admin.firestore.Timestamp.now(),
        suggestionCount: admin.firestore.FieldValue.increment(1)
      }, { merge: true });

      console.log(`📊 Updated suggestion frequency for user: ${userId}`);

    } catch (error) {
      console.error('Error updating suggestion frequency:', error);
    }
  }
}

// Export the main function
export const generateProactiveSuggestions = async (userId: string): Promise<ProactiveSuggestion | null> => {
  const handler = new ProactiveSuggestionsHandler();
  return await handler.generateProactiveSuggestions(userId);
};
