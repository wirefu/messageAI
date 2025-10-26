//
//  proactiveSuggestions.test.ts
//  MessageAI Cloud Functions Tests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import { describe, it, expect } from '@jest/globals';
import { DetectionRules, Message } from '../src/utils/detectionRules';

describe('Proactive Suggestions - Detection Rules', () => {
  
  describe('detectTimezoneAmbiguity', () => {
    it('should detect timezone ambiguity when users are in different timezones', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'Let\'s meet at 3pm tomorrow',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectTimezoneAmbiguity(
        messages,
        'America/New_York',
        'America/Los_Angeles'
      );
      
      expect(suggestion).not.toBeNull();
      expect(suggestion?.type).toBe('timezone_ambiguity');
      expect(suggestion?.priority).toBe('high');
      expect(suggestion?.title).toBe('Timezone Ambiguity Detected');
      expect(suggestion?.message).toContain('3pm tomorrow');
      expect(suggestion?.message).toContain('America/New_York');
      expect(suggestion?.message).toContain('America/Los_Angeles');
    });

    it('should not detect timezone ambiguity when users are in same timezone', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'Let\'s meet at 3pm tomorrow',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectTimezoneAmbiguity(
        messages,
        'America/New_York',
        'America/New_York'
      );
      
      expect(suggestion).toBeNull();
    });

    it('should not detect timezone ambiguity when timezone is specified', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'Let\'s meet at 3pm EST tomorrow',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectTimezoneAmbiguity(
        messages,
        'America/New_York',
        'America/Los_Angeles'
      );
      
      expect(suggestion).toBeNull();
    });

    it('should detect various time patterns', () => {
      const timePatterns = [
        'Let\'s meet at 3pm',
        'at 3:30pm',
        'tomorrow at 2pm',
        '3pm today'
      ];
      
      timePatterns.forEach(pattern => {
        const messages: Message[] = [
          {
            id: 'msg1',
            content: pattern,
            timestamp: {} as any,
            senderId: 'user1',
            conversationId: 'conv1'
          }
        ];
        
        const suggestion = DetectionRules.detectTimezoneAmbiguity(
          messages,
          'America/New_York',
          'America/Los_Angeles'
        );
        
        expect(suggestion).not.toBeNull();
        expect(suggestion?.type).toBe('timezone_ambiguity');
      });
    });
  });

  describe('detectUnclearReferences', () => {
    it('should detect unclear references without context', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'Can you review the document?',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectUnclearReferences(messages);
      
      expect(suggestion).not.toBeNull();
      expect(suggestion?.type).toBe('unclear_reference');
      expect(suggestion?.priority).toBe('medium');
      expect(suggestion?.title).toBe('Unclear Reference Detected');
      expect(suggestion?.message).toContain('the document');
    });

    it('should not detect unclear references when context exists', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'I uploaded the budget report file',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        },
        {
          id: 'msg2',
          content: 'Can you review the document?',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectUnclearReferences(messages);
      
      expect(suggestion).toBeNull();
    });

    it('should detect various vague reference patterns', () => {
      const vaguePatterns = [
        'the document',
        'that file',
        'the project',
        'the meeting',
        'it'
      ];
      
      vaguePatterns.forEach(pattern => {
        const messages: Message[] = [
          {
            id: 'msg1',
            content: `Can you check ${pattern}?`,
            timestamp: {} as any,
            senderId: 'user1',
            conversationId: 'conv1'
          }
        ];
        
        const suggestion = DetectionRules.detectUnclearReferences(messages);
        
        expect(suggestion).not.toBeNull();
        expect(suggestion?.type).toBe('unclear_reference');
      });
    });
  });

  describe('detectMissedFollowups', () => {
    it('should return null (placeholder implementation)', () => {
      const messages: Message[] = [
        {
          id: 'msg1',
          content: 'Can you do this task?',
          timestamp: {} as any,
          senderId: 'user1',
          conversationId: 'conv1'
        }
      ];
      
      const suggestion = DetectionRules.detectMissedFollowups('user1', messages);
      
      expect(suggestion).toBeNull();
    });
  });
});

describe('Proactive Suggestions - Suggestion Structure', () => {
  
  it('should have correct suggestion structure for timezone ambiguity', () => {
    const messages: Message[] = [
      {
        id: 'msg1',
        content: 'Let\'s meet at 3pm tomorrow',
        timestamp: {} as any,
        senderId: 'user1',
        conversationId: 'conv1'
      }
    ];
    
    const suggestion = DetectionRules.detectTimezoneAmbiguity(
      messages,
      'America/New_York',
      'America/Los_Angeles'
    );
    
    expect(suggestion).not.toBeNull();
    expect(suggestion?.id).toMatch(/^timezone_msg1_\d+$/);
    expect(suggestion?.type).toBe('timezone_ambiguity');
    expect(suggestion?.priority).toBe('high');
    expect(suggestion?.title).toBe('Timezone Ambiguity Detected');
    expect(suggestion?.message).toBeDefined();
    expect(suggestion?.actionText).toBe('Clarify Timezone');
    expect(suggestion?.dismissText).toBe('Dismiss');
    expect(suggestion?.metadata).toBeDefined();
    expect(suggestion?.metadata.conversationId).toBe('conv1');
    expect(suggestion?.metadata.messageId).toBe('msg1');
    expect(suggestion?.metadata.userTimezone).toBe('America/New_York');
    expect(suggestion?.metadata.recipientTimezone).toBe('America/Los_Angeles');
    expect(suggestion?.metadata.originalText).toBe('Let\'s meet at 3pm tomorrow');
    expect(suggestion?.metadata.suggestedClarification).toBeDefined();
  });

  it('should have correct suggestion structure for unclear references', () => {
    const messages: Message[] = [
      {
        id: 'msg1',
        content: 'Can you review the document?',
        timestamp: {} as any,
        senderId: 'user1',
        conversationId: 'conv1'
      }
    ];
    
    const suggestion = DetectionRules.detectUnclearReferences(messages);
    
    expect(suggestion).not.toBeNull();
    expect(suggestion?.id).toMatch(/^reference_msg1_\d+$/);
    expect(suggestion?.type).toBe('unclear_reference');
    expect(suggestion?.priority).toBe('medium');
    expect(suggestion?.title).toBe('Unclear Reference Detected');
    expect(suggestion?.message).toBeDefined();
    expect(suggestion?.actionText).toBe('Add Context');
    expect(suggestion?.dismissText).toBe('Dismiss');
    expect(suggestion?.metadata).toBeDefined();
    expect(suggestion?.metadata.conversationId).toBe('conv1');
    expect(suggestion?.metadata.messageId).toBe('msg1');
    expect(suggestion?.metadata.originalText).toBe('Can you review the document?');
    expect(suggestion?.metadata.suggestedClarification).toBeDefined();
  });
});

describe('Proactive Suggestions - Edge Cases', () => {
  
  it('should handle empty messages array', () => {
    const messages: Message[] = [];
    
    const timezoneSuggestion = DetectionRules.detectTimezoneAmbiguity(
      messages,
      'America/New_York',
      'America/Los_Angeles'
    );
    
    const referenceSuggestion = DetectionRules.detectUnclearReferences(messages);
    
    expect(timezoneSuggestion).toBeNull();
    expect(referenceSuggestion).toBeNull();
  });

  it('should handle messages without time patterns', () => {
    const messages: Message[] = [
      {
        id: 'msg1',
        content: 'Hello, how are you?',
        timestamp: {} as any,
        senderId: 'user1',
        conversationId: 'conv1'
      }
    ];
    
    const suggestion = DetectionRules.detectTimezoneAmbiguity(
      messages,
      'America/New_York',
      'America/Los_Angeles'
    );
    
    expect(suggestion).toBeNull();
  });

  it('should handle messages without vague references', () => {
    const messages: Message[] = [
      {
        id: 'msg1',
        content: 'Hello, how are you?',
        timestamp: {} as any,
        senderId: 'user1',
        conversationId: 'conv1'
      }
    ];
    
    const suggestion = DetectionRules.detectUnclearReferences(messages);
    
    expect(suggestion).toBeNull();
  });
});
