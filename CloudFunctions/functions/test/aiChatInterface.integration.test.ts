import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { aiChatInterface, executeAIChatAction, getAIChatSuggestions, searchAIConversations } from '../src/aiChatInterface';
import { aiChatService } from '../src/services/aiChatService';
import { vectorDB } from '../src/utils/vectordb';
import { aiCache } from '../src/utils/aiCache';

// Mock dependencies
jest.mock('../src/services/aiChatService');
jest.mock('../src/utils/vectordb');
jest.mock('../src/utils/aiCache');

describe('AI Chat Interface Integration Tests', () => {
  const mockUserId = 'test-user-123';
  const mockSessionId = 'test-session-456';
  const mockContext = {
    auth: { uid: mockUserId }
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('aiChatInterface', () => {
    it('should process AI chat message successfully', async () => {
      const mockData = {
        message: 'What did we discuss about the project?',
        sessionId: mockSessionId,
        conversationId: 'conversation-123'
      };

      const mockResult = {
        response: 'Based on your conversation history, you discussed project timelines.',
        suggestions: [
          { type: 'action', suggestion: 'Create a project timeline', confidence: 0.8 }
        ],
        actions: [
          { id: 'translate', name: 'Translate', description: 'Translate this message' }
        ],
        context: 'Previous discussion about project timelines'
      };

      (aiChatService.processChatMessage as jest.Mock).mockResolvedValue(mockResult);

      const result = await aiChatInterface(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.response).toBe(mockResult.response);
      expect(result.suggestions).toEqual(mockResult.suggestions);
      expect(result.actions).toEqual(mockResult.actions);
      expect(result.context).toBe(mockResult.context);
      expect(result.timestamp).toBeDefined();
    });

    it('should throw error when not authenticated', async () => {
      const mockData = {
        message: 'Test message',
        sessionId: mockSessionId
      };

      const unauthenticatedContext = { auth: null };

      await expect(
        aiChatInterface(mockData, unauthenticatedContext)
      ).rejects.toThrow('Must be authenticated');
    });

    it('should throw error when message is empty', async () => {
      const mockData = {
        message: '',
        sessionId: mockSessionId
      };

      await expect(
        aiChatInterface(mockData, mockContext)
      ).rejects.toThrow('Message is required');
    });

    it('should throw error when sessionId is missing', async () => {
      const mockData = {
        message: 'Test message'
      };

      await expect(
        aiChatInterface(mockData, mockContext)
      ).rejects.toThrow('Session ID is required');
    });

    it('should handle AI service errors', async () => {
      const mockData = {
        message: 'Test message',
        sessionId: mockSessionId
      };

      (aiChatService.processChatMessage as jest.Mock).mockRejectedValue(
        new Error('AI service error')
      );

      await expect(
        aiChatInterface(mockData, mockContext)
      ).rejects.toThrow('Failed to process AI chat message');
    });
  });

  describe('executeAIChatAction', () => {
    it('should execute translate action successfully', async () => {
      const mockData = {
        actionId: 'translate',
        messageId: 'message-123',
        parameters: { targetLanguage: 'Spanish' }
      };

      const mockResult = {
        success: true,
        actionId: 'translate',
        result: '¿Qué discutimos sobre el proyecto?',
        timestamp: '2024-01-01T00:00:00Z'
      };

      (aiChatService.executeAction as jest.Mock).mockResolvedValue(mockResult);

      const result = await executeAIChatAction(mockData, mockContext);

      expect(result).toEqual(mockResult);
      expect(aiChatService.executeAction).toHaveBeenCalledWith(
        'translate',
        'message-123',
        { targetLanguage: 'Spanish' },
        mockUserId
      );
    });

    it('should execute rewrite action successfully', async () => {
      const mockData = {
        actionId: 'rewrite',
        messageId: 'message-123',
        parameters: { tone: 'formal' }
      };

      const mockResult = {
        success: true,
        actionId: 'rewrite',
        result: 'We discussed the project timeline and deliverables.',
        timestamp: '2024-01-01T00:00:00Z'
      };

      (aiChatService.executeAction as jest.Mock).mockResolvedValue(mockResult);

      const result = await executeAIChatAction(mockData, mockContext);

      expect(result).toEqual(mockResult);
    });

    it('should throw error when not authenticated', async () => {
      const mockData = {
        actionId: 'translate',
        messageId: 'message-123',
        parameters: {}
      };

      const unauthenticatedContext = { auth: null };

      await expect(
        executeAIChatAction(mockData, unauthenticatedContext)
      ).rejects.toThrow('Must be authenticated');
    });

    it('should throw error when actionId is missing', async () => {
      const mockData = {
        messageId: 'message-123',
        parameters: {}
      };

      await expect(
        executeAIChatAction(mockData, mockContext)
      ).rejects.toThrow('Action ID and Message ID are required');
    });

    it('should throw error when messageId is missing', async () => {
      const mockData = {
        actionId: 'translate',
        parameters: {}
      };

      await expect(
        executeAIChatAction(mockData, mockContext)
      ).rejects.toThrow('Action ID and Message ID are required');
    });
  });

  describe('getAIChatSuggestions', () => {
    it('should get AI chat suggestions successfully', async () => {
      const mockData = {
        conversationId: 'conversation-123'
      };

      const mockSuggestions = [
        { type: 'action', suggestion: 'Schedule follow-up meeting', confidence: 0.9 }
      ];

      (aiChatService.getConversationSuggestions as jest.Mock).mockResolvedValue(mockSuggestions);

      const result = await getAIChatSuggestions(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.suggestions).toEqual(mockSuggestions);
      expect(result.timestamp).toBeDefined();
    });

    it('should throw error when not authenticated', async () => {
      const mockData = {
        conversationId: 'conversation-123'
      };

      const unauthenticatedContext = { auth: null };

      await expect(
        getAIChatSuggestions(mockData, unauthenticatedContext)
      ).rejects.toThrow('Must be authenticated');
    });

    it('should throw error when conversationId is missing', async () => {
      const mockData = {};

      await expect(
        getAIChatSuggestions(mockData, mockContext)
      ).rejects.toThrow('Conversation ID is required');
    });

    it('should handle AI service errors', async () => {
      const mockData = {
        conversationId: 'conversation-123'
      };

      (aiChatService.getConversationSuggestions as jest.Mock).mockRejectedValue(
        new Error('AI service error')
      );

      await expect(
        getAIChatSuggestions(mockData, mockContext)
      ).rejects.toThrow('Failed to get AI suggestions');
    });
  });

  describe('searchAIConversations', () => {
    it('should search conversations successfully', async () => {
      const mockData = {
        query: 'project timeline',
        limit: 10
      };

      const mockResults = [
        {
          messageId: 'msg-1',
          content: 'Project timeline discussion',
          conversationId: 'conv-1',
          relevance: 0.85
        }
      ];

      (aiChatService.searchConversations as jest.Mock).mockResolvedValue(mockResults);

      const result = await searchAIConversations(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.results).toEqual(mockResults);
      expect(result.query).toBe('project timeline');
      expect(result.timestamp).toBeDefined();
    });

    it('should use default limit when not provided', async () => {
      const mockData = {
        query: 'project timeline'
      };

      const mockResults = [];

      (aiChatService.searchConversations as jest.Mock).mockResolvedValue(mockResults);

      const result = await searchAIConversations(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(aiChatService.searchConversations).toHaveBeenCalledWith(
        mockUserId,
        'project timeline',
        10
      );
    });

    it('should throw error when not authenticated', async () => {
      const mockData = {
        query: 'project timeline'
      };

      const unauthenticatedContext = { auth: null };

      await expect(
        searchAIConversations(mockData, unauthenticatedContext)
      ).rejects.toThrow('Must be authenticated');
    });

  describe('getAIUsageStats', () => {
    it('should get AI usage statistics successfully', async () => {
      const mockData = {};

      const mockStats = {
        totalInteractions: 10,
        actionsExecuted: 5,
        suggestionsProvided: 3,
        lastActive: '2024-01-01T00:00:00Z'
      };

      (aiChatService.getUserAIStats as jest.Mock).mockResolvedValue(mockStats);

      const result = await getAIUsageStats(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.stats).toEqual(mockStats);
      expect(result.timestamp).toBeDefined();
    });

    it('should throw error when not authenticated', async () => {
      const mockData = {};
      const unauthenticatedContext = { auth: null };

      await expect(
        getAIUsageStats(mockData, unauthenticatedContext)
      ).rejects.toThrow('Must be authenticated');
    });
  });

  describe('indexMessageForAI', () => {
    it('should index message successfully', async () => {
      const mockData = {
        messageId: 'message-123',
        content: 'Project timeline discussion',
        conversationId: 'conversation-123',
        metadata: { userId: mockUserId }
      };

      (vectorDB.indexMessage as jest.Mock).mockResolvedValue(undefined);

      const result = await indexMessageForAI(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.messageId).toBe('message-123');
      expect(result.indexed).toBe(true);
      expect(result.timestamp).toBeDefined();
    });

    it('should handle indexing errors gracefully', async () => {
      const mockData = {
        messageId: 'message-123',
        content: 'Project timeline discussion'
      };

      (vectorDB.indexMessage as jest.Mock).mockRejectedValue(
        new Error('Indexing error')
      );

      const result = await indexMessageForAI(mockData, mockContext);

      expect(result.success).toBe(false);
      expect(result.error).toBe('Failed to index message for AI search');
    });

    it('should throw error when messageId is missing', async () => {
      const mockData = {
        content: 'Project timeline discussion'
      };

      await expect(
        indexMessageForAI(mockData, mockContext)
      ).rejects.toThrow('Message ID and content are required');
    });
  });

  describe('getAIChatHistory', () => {
    it('should get AI chat history successfully', async () => {
      const mockData = {
        sessionId: mockSessionId
      };

      const mockHistory = [
        { role: 'user', content: 'What did we discuss?' },
        { role: 'assistant', content: 'You discussed project timelines.' }
      ];

      (aiCache.getCachedChatSession as jest.Mock).mockResolvedValue(mockHistory);

      const result = await getAIChatHistory(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.history).toEqual(mockHistory);
      expect(result.sessionId).toBe(mockSessionId);
    });

    it('should return empty history when not cached', async () => {
      const mockData = {
        sessionId: mockSessionId
      };

      (aiCache.getCachedChatSession as jest.Mock).mockResolvedValue(null);

      const result = await getAIChatHistory(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.history).toEqual([]);
    });
  });

  describe('clearAIChatSession', () => {
    it('should clear AI chat session successfully', async () => {
      const mockData = {
        sessionId: mockSessionId
      };

      (aiCache.invalidate as jest.Mock).mockResolvedValue(undefined);

      const result = await clearAIChatSession(mockData, mockContext);

      expect(result.success).toBe(true);
      expect(result.sessionId).toBe(mockSessionId);
      expect(result.timestamp).toBeDefined();
    });

    it('should throw error when sessionId is missing', async () => {
      const mockData = {};

      await expect(
        clearAIChatSession(mockData, mockContext)
      ).rejects.toThrow('Session ID is required');
    });
  });
});
