import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { AIChatService } from '../src/services/aiChatService';
import { openaiService } from '../src/utils/openai';
import { vectorDB } from '../src/utils/vectordb';
import { aiCache } from '../src/utils/aiCache';

// Mock dependencies
jest.mock('../src/utils/openai');
jest.mock('../src/utils/vectordb');
jest.mock('../src/utils/aiCache');
jest.mock('firebase-admin', () => ({
  firestore: () => ({
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        get: jest.fn(() => Promise.resolve({ exists: false, data: () => ({}) })),
        set: jest.fn(() => Promise.resolve()),
        collection: jest.fn(() => ({
          add: jest.fn(() => Promise.resolve()),
          get: jest.fn(() => Promise.resolve({ docs: [] }))
        }))
      })),
      where: jest.fn(() => ({
        get: jest.fn(() => Promise.resolve({ docs: [] }))
      }))
    }))
  }),
  FieldValue: {
    serverTimestamp: jest.fn(() => 'mock-timestamp'),
    increment: jest.fn(() => 'mock-increment')
  }
}));

describe('AIChatService', () => {
  let aiChatService: AIChatService;
  const mockUserId = 'test-user-123';
  const mockSessionId = 'test-session-456';
  const mockMessage = 'What did we discuss about the project?';

  beforeEach(() => {
    aiChatService = new AIChatService();
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('processChatMessage', () => {
    it('should process AI chat message successfully', async () => {
      // Mock dependencies
      const mockResponse = 'Based on your conversation history, you discussed project timelines.';
      const mockSuggestions = [
        { type: 'action', suggestion: 'Create a project timeline', confidence: 0.8 }
      ];
      const mockActions = [
        { id: 'translate', name: 'Translate', description: 'Translate this message' }
      ];

      (openaiService.generateChatResponse as jest.Mock).mockResolvedValue(mockResponse);
      (openaiService.generateProactiveSuggestions as jest.Mock).mockResolvedValue(mockSuggestions);
      (aiCache.getCachedChatSession as jest.Mock).mockResolvedValue([]);
      (aiCache.cacheResponse as jest.Mock).mockResolvedValue(undefined);

      // Execute
      const result = await aiChatService.processChatMessage(
        mockUserId,
        mockMessage,
        mockSessionId
      );

      // Verify
      expect(result.response).toBe(mockResponse);
      expect(result.suggestions).toEqual(mockSuggestions);
      expect(result.actions).toEqual(mockActions);
      expect(openaiService.generateChatResponse).toHaveBeenCalled();
      expect(openaiService.generateProactiveSuggestions).toHaveBeenCalled();
    });

    it('should handle errors gracefully', async () => {
      // Mock error
      (openaiService.generateChatResponse as jest.Mock).mockRejectedValue(
        new Error('OpenAI API error')
      );

      // Execute and expect error
      await expect(
        aiChatService.processChatMessage(mockUserId, mockMessage, mockSessionId)
      ).rejects.toThrow('Failed to process AI chat message');
    });
  });

  describe('executeAction', () => {
    it('should execute translate action successfully', async () => {
      const mockTranslatedText = '¿Qué discutimos sobre el proyecto?';
      
      (openaiService.translateText as jest.Mock).mockResolvedValue(mockTranslatedText);

      const result = await aiChatService.executeAction(
        'translate',
        'message-123',
        { targetLanguage: 'Spanish' },
        mockUserId
      );

      expect(result.success).toBe(true);
      expect(result.actionId).toBe('translate');
      expect(result.result).toBe(mockTranslatedText);
      expect(openaiService.translateText).toHaveBeenCalledWith(
        'Sample message content',
        'Spanish'
      );
    });

    it('should execute rewrite action successfully', async () => {
      const mockRewrittenText = 'We discussed the project timeline and deliverables.';
      
      (openaiService.rewriteText as jest.Mock).mockResolvedValue(mockRewrittenText);

      const result = await aiChatService.executeAction(
        'rewrite',
        'message-123',
        { tone: 'formal' },
        mockUserId
      );

      expect(result.success).toBe(true);
      expect(result.actionId).toBe('rewrite');
      expect(result.result).toBe(mockRewrittenText);
    });

    it('should execute extract_actions action successfully', async () => {
      const mockActionItems = [
        { action: 'Review project timeline', assignee: 'John', priority: 'high' }
      ];
      
      (openaiService.extractActionItems as jest.Mock).mockResolvedValue(mockActionItems);

      const result = await aiChatService.executeAction(
        'extract_actions',
        'message-123',
        {},
        mockUserId
      );

      expect(result.success).toBe(true);
      expect(result.actionId).toBe('extract_actions');
      expect(result.result).toEqual(mockActionItems);
    });

    it('should handle unknown action', async () => {
      await expect(
        aiChatService.executeAction(
          'unknown_action',
          'message-123',
          {},
          mockUserId
        )
      ).rejects.toThrow('Unknown action: unknown_action');
    });
  });

  describe('getConversationSuggestions', () => {
    it('should get conversation suggestions successfully', async () => {
      const mockSuggestions = [
        { type: 'action', suggestion: 'Schedule follow-up meeting', confidence: 0.9 }
      ];

      (openaiService.generateProactiveSuggestions as jest.Mock).mockResolvedValue(mockSuggestions);

      const result = await aiChatService.getConversationSuggestions(
        'conversation-123',
        mockUserId
      );

      expect(result).toEqual(mockSuggestions);
      expect(openaiService.generateProactiveSuggestions).toHaveBeenCalled();
    });

    it('should return empty array on error', async () => {
      (openaiService.generateProactiveSuggestions as jest.Mock).mockRejectedValue(
        new Error('OpenAI API error')
      );

      const result = await aiChatService.getConversationSuggestions(
        'conversation-123',
        mockUserId
      );

      expect(result).toEqual([]);
    });
  });

  describe('searchConversations', () => {
    it('should search conversations successfully', async () => {
      const mockSearchResults = [
        {
          id: 'msg-1',
          content: 'Project timeline discussion',
          conversationId: 'conv-1',
          similarity: 0.85
        }
      ];

      (vectorDB.searchSimilarMessages as jest.Mock).mockResolvedValue(mockSearchResults);

      const result = await aiChatService.searchConversations(
        mockUserId,
        'project timeline',
        5
      );

      expect(result).toHaveLength(1);
      expect(result[0].messageId).toBe('msg-1');
      expect(result[0].relevance).toBe(0.85);
      expect(vectorDB.searchSimilarMessages).toHaveBeenCalledWith(
        'project timeline',
        mockUserId,
        5
      );
    });

    it('should return empty array on error', async () => {
      (vectorDB.searchSimilarMessages as jest.Mock).mockRejectedValue(
        new Error('Vector search error')
      );

      const result = await aiChatService.searchConversations(
        mockUserId,
        'test query',
        5
      );

      expect(result).toEqual([]);
    });
  });

  describe('getUserAIStats', () => {
    it('should return default stats when no data exists', async () => {
      const result = await aiChatService.getUserAIStats(mockUserId);

      expect(result.totalInteractions).toBe(0);
      expect(result.actionsExecuted).toBe(0);
      expect(result.suggestionsProvided).toBe(0);
      expect(typeof result.lastActive).toBe('string');
    });

    it('should return cached stats when data exists', async () => {
      // Mock Firestore response
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        exists: true,
        data: () => ({
          totalInteractions: 10,
          actionsExecuted: 5,
          suggestionsProvided: 3,
          lastActive: '2024-01-01T00:00:00Z'
        })
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve(mockDoc))
        }))
      });

      const result = await aiChatService.getUserAIStats(mockUserId);

      expect(result.totalInteractions).toBe(10);
      expect(result.actionsExecuted).toBe(5);
      expect(result.suggestionsProvided).toBe(3);
    });
  });
});
