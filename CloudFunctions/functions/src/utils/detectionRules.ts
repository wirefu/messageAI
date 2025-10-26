//
//  detectionRules.ts
//  MessageAI Cloud Functions
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import * as admin from 'firebase-admin';

// Types for suggestion detection
export interface ProactiveSuggestion {
  id: string;
  type: 'timezone_ambiguity' | 'unclear_reference' | 'missed_followup';
  priority: 'low' | 'medium' | 'high';
  title: string;
  message: string;
  actionText: string;
  dismissText: string;
  metadata: {
    conversationId: string;
    messageId: string;
    detectedAt: string;
    userTimezone?: string;
    recipientTimezone?: string;
    originalText?: string;
    suggestedClarification?: string;
  };
}

export interface Message {
  id: string;
  content: string;
  timestamp: admin.firestore.Timestamp;
  senderId: string;
  conversationId: string;
}

export interface UserTimezone {
  userId: string;
  timezone: string;
}

/**
 * Detection Rules Utility
 * Contains pattern matching and detection logic for proactive suggestions
 */
export class DetectionRules {
  
  // Time patterns for timezone detection
  private static readonly TIME_PATTERNS = [
    /\b(\d{1,2}):?(\d{2})?\s*(am|pm|AM|PM)\b/g,
    /\b(at\s+)?(\d{1,2}):?(\d{2})?\s*(am|pm|AM|PM)\b/g,
    /\b(tomorrow|today|yesterday)\s+(at\s+)?(\d{1,2}):?(\d{2})?\s*(am|pm|AM|PM)\b/g,
    /\b(\d{1,2}):?(\d{2})?\s*(am|pm|AM|PM)\s+(tomorrow|today|yesterday)\b/g
  ];

  // Vague reference patterns
  private static readonly VAGUE_REFERENCE_PATTERNS = [
    /\b(the\s+document|that\s+document|this\s+document)\b/gi,
    /\b(the\s+file|that\s+file|this\s+file)\b/gi,
    /\b(the\s+project|that\s+project|this\s+project)\b/gi,
    /\b(the\s+meeting|that\s+meeting|this\s+meeting)\b/gi,
    /\b(it|this|that)\b/gi
  ];

  /**
   * Detect timezone ambiguity in messages
   * @param messages Array of recent messages
   * @param userTz User's timezone
   * @param recipientTz Recipient's timezone
   * @returns ProactiveSuggestion if timezone ambiguity detected, null otherwise
   */
  static detectTimezoneAmbiguity(
    messages: Message[],
    userTz: string,
    recipientTz: string
  ): ProactiveSuggestion | null {
    // Skip if timezones are the same
    if (userTz === recipientTz) {
      return null;
    }

    // Check recent messages for time patterns
    for (const message of messages) {
      const timeMatches = this.findTimePatterns(message.content);
      
      if (timeMatches.length > 0) {
        // Check if time lacks timezone indicator
        const hasTimezoneIndicator = /\b(EST|PST|CST|MST|UTC|GMT|PDT|EDT|CDT|MDT)\b/i.test(message.content);
        
        if (!hasTimezoneIndicator) {
          return {
            id: `timezone_${message.id}_${Date.now()}`,
            type: 'timezone_ambiguity',
            priority: 'high',
            title: 'Timezone Ambiguity Detected',
            message: `"${message.content}" mentions a time but doesn't specify timezone. You're in ${userTz}, recipient is in ${recipientTz}.`,
            actionText: 'Clarify Timezone',
            dismissText: 'Dismiss',
            metadata: {
              conversationId: message.conversationId,
              messageId: message.id,
              detectedAt: new Date().toISOString(),
              userTimezone: userTz,
              recipientTimezone: recipientTz,
              originalText: message.content,
              suggestedClarification: this.generateTimezoneClarification(message.content, userTz, recipientTz)
            }
          };
        }
      }
    }

    return null;
  }

  /**
   * Detect unclear references in messages
   * @param messages Array of recent messages
   * @returns ProactiveSuggestion if unclear reference detected, null otherwise
   */
  static detectUnclearReferences(messages: Message[]): ProactiveSuggestion | null {
    // Check recent messages for vague references
    for (const message of messages) {
      const vagueMatches = this.findVagueReferences(message.content);
      
      if (vagueMatches.length > 0) {
        // Check if there's context in recent messages
        const hasContext = this.hasContextForReference(message, messages);
        
        if (!hasContext) {
          return {
            id: `reference_${message.id}_${Date.now()}`,
            type: 'unclear_reference',
            priority: 'medium',
            title: 'Unclear Reference Detected',
            message: `"${message.content}" contains unclear references that might confuse the recipient.`,
            actionText: 'Add Context',
            dismissText: 'Dismiss',
            metadata: {
              conversationId: message.conversationId,
              messageId: message.id,
              detectedAt: new Date().toISOString(),
              originalText: message.content,
              suggestedClarification: this.generateReferenceClarification(message.content, vagueMatches)
            }
          };
        }
      }
    }

    return null;
  }

  /**
   * Detect missed follow-ups (optional feature)
   * @param userId User ID
   * @param messages Array of recent messages
   * @returns ProactiveSuggestion if missed follow-up detected, null otherwise
   */
  static detectMissedFollowups(userId: string, messages: Message[]): ProactiveSuggestion | null {
    // This is a placeholder for future implementation
    // Could detect patterns like:
    // - Questions that weren't answered
    // - Action items that weren't followed up on
    // - Promises that weren't kept
    
    return null;
  }

  /**
   * Find time patterns in text
   * @param text Input text
   * @returns Array of matched time patterns
   */
  private static findTimePatterns(text: string): string[] {
    const matches: string[] = [];
    
    for (const pattern of this.TIME_PATTERNS) {
      const patternMatches = text.match(pattern);
      if (patternMatches) {
        matches.push(...patternMatches);
      }
    }
    
    return matches;
  }

  /**
   * Find vague references in text
   * @param text Input text
   * @returns Array of matched vague references
   */
  private static findVagueReferences(text: string): string[] {
    const matches: string[] = [];
    
    for (const pattern of this.VAGUE_REFERENCE_PATTERNS) {
      const patternMatches = text.match(pattern);
      if (patternMatches) {
        matches.push(...patternMatches);
      }
    }
    
    return matches;
  }

  /**
   * Check if there's context for a reference in recent messages
   * @param message Message with potential unclear reference
   * @param messages Array of recent messages
   * @returns True if context exists, false otherwise
   */
  private static hasContextForReference(message: Message, messages: Message[]): boolean {
    // Look for context in the last 5 messages before this one
    const messageIndex = messages.findIndex(m => m.id === message.id);
    if (messageIndex === -1) return false;
    
    const contextMessages = messages.slice(Math.max(0, messageIndex - 5), messageIndex);
    
    // Simple context detection - look for specific nouns that could be referenced
    const contextKeywords = [
      'document', 'file', 'project', 'meeting', 'report', 'proposal',
      'email', 'message', 'call', 'presentation', 'budget', 'plan'
    ];
    
    for (const contextMessage of contextMessages) {
      for (const keyword of contextKeywords) {
        if (contextMessage.content.toLowerCase().includes(keyword)) {
          return true;
        }
      }
    }
    
    return false;
  }

  /**
   * Generate timezone clarification suggestion
   * @param originalText Original message text
   * @param userTz User's timezone
   * @param recipientTz Recipient's timezone
   * @returns Suggested clarification text
   */
  private static generateTimezoneClarification(
    originalText: string,
    userTz: string,
    recipientTz: string
  ): string {
    // Simple timezone clarification
    return `Consider clarifying: "${originalText} (${userTz})" or "${originalText} (${recipientTz})"`;
  }

  /**
   * Generate reference clarification suggestion
   * @param originalText Original message text
   * @param vagueMatches Array of vague references found
   * @returns Suggested clarification text
   */
  private static generateReferenceClarification(
    originalText: string,
    vagueMatches: string[]
  ): string {
    const suggestions = vagueMatches.map(match => {
      switch (match.toLowerCase()) {
        case 'the document':
          return 'the [specific document name]';
        case 'that file':
          return 'the [filename] file';
        case 'the project':
          return 'the [project name] project';
        case 'it':
          return '[specific item]';
        default:
          return `[specific ${match}]`;
      }
    });
    
    return `Consider being more specific: ${suggestions.join(', ')}`;
  }
}

// Export individual functions for easier testing
export const detectTimezoneAmbiguity = DetectionRules.detectTimezoneAmbiguity;
export const detectUnclearReferences = DetectionRules.detectUnclearReferences;
export const detectMissedFollowups = DetectionRules.detectMissedFollowups;
