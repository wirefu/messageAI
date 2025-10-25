import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { VectorDatabaseService } from '../src/utils/vectordb';
import { BedrockEmbeddingService } from '../src/bedrockEmbeddingService';
import { BedrockVectorSearchService } from '../src/bedrockVectorSearchService';
import { aiCache } from '../src/utils/aiCache';

// Mock dependencies
jest.mock('../src/bedrockEmbeddingService');
jest.mock('../src/bedrockVectorSearchService');
jest.mock('../src/utils/aiCache');

describe('VectorDatabaseService', () => {
  let vectorDBService: VectorDatabaseService;
  const mockMessageId = 'msg-123';
  const mockContent = 'Project timeline discussion';
  const mockEmbedding = [0.1, 0.2, 0.3, 0.4, 0.5];
  const mockUserId = 'user-123';

  beforeEach(() => {
    vectorDBService = new VectorDatabaseService();
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('indexMessage', () => {
    it('should use cached embedding when available', async () => {
      (aiCache.getCachedEmbedding as jest.Mock).mockResolvedValue(mockEmbedding);
      (aiCache.cacheEmbedding as jest.Mock).mockResolvedValue(undefined);

      await vectorDBService.indexMessage(mockMessageId, mockContent);

      expect(aiCache.getCachedEmbedding).toHaveBeenCalledWith(mockMessageId);
      expect(aiCache.cacheEmbedding).not.toHaveBeenCalled();
    });

    it('should generate and cache new embedding when not cached', async () => {
      (aiCache.getCachedEmbedding as jest.Mock).mockResolvedValue(null);
      (aiCache.cacheEmbedding as jest.Mock).mockResolvedValue(undefined);

      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockResolvedValue(mockEmbedding);

      // Mock the embedding service instance
      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      await vectorDBService.indexMessage(mockMessageId, mockContent);

      expect(mockEmbeddingService.generateEmbedding).toHaveBeenCalledWith(mockContent);
      expect(aiCache.cacheEmbedding).toHaveBeenCalledWith(mockMessageId, mockEmbedding);
    });

    it('should handle embedding generation errors', async () => {
      (aiCache.getCachedEmbedding as jest.Mock).mockResolvedValue(null);

      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockRejectedValue(
        new Error('Bedrock API error')
      );

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      await expect(
        vectorDBService.indexMessage(mockMessageId, mockContent)
      ).rejects.toThrow('Bedrock API error');
    });
  });

  describe('searchSimilarMessages', () => {
    it('should use cached results when available', async () => {
      const mockCachedResults = [
        { id: 'msg-1', content: 'Project timeline', similarity: 0.85 }
      ];

      (aiCache.getCachedSearchResults as jest.Mock).mockResolvedValue(mockCachedResults);

      const result = await vectorDBService.searchSimilarMessages('project timeline', mockUserId, 5);

      expect(result).toEqual(mockCachedResults);
      expect(aiCache.getCachedSearchResults).toHaveBeenCalledWith('project timeline');
    });

    it('should perform vector search and cache results when not cached', async () => {
      const mockSearchResults = [
        { id: 'msg-1', content: 'Project timeline', similarity: 0.85 }
      ];

      (aiCache.getCachedSearchResults as jest.Mock).mockResolvedValue(null);
      (aiCache.cacheSearchResults as jest.Mock).mockResolvedValue(undefined);

      const mockVectorSearchService = new BedrockVectorSearchService();
      (mockVectorSearchService.searchAllTeamMessages as jest.Mock).mockResolvedValue(mockSearchResults);

      (BedrockVectorSearchService as jest.Mock).mockImplementation(() => mockVectorSearchService);

      const result = await vectorDBService.searchSimilarMessages('project timeline', mockUserId, 5);

      expect(result).toEqual(mockSearchResults);
      expect(mockVectorSearchService.searchAllTeamMessages).toHaveBeenCalledWith(
        'project timeline',
        mockUserId,
        5
      );
      expect(aiCache.cacheSearchResults).toHaveBeenCalledWith('project timeline', mockSearchResults);
    });

    it('should handle search errors gracefully', async () => {
      (aiCache.getCachedSearchResults as jest.Mock).mockResolvedValue(null);

      const mockVectorSearchService = new BedrockVectorSearchService();
      (mockVectorSearchService.searchAllTeamMessages as jest.Mock).mockRejectedValue(
        new Error('Vector search error')
      );

      (BedrockVectorSearchService as jest.Mock).mockImplementation(() => mockVectorSearchService);

      await expect(
        vectorDBService.searchSimilarMessages('project timeline', mockUserId, 5)
      ).rejects.toThrow('Vector search error');
    });
  });

  describe('searchConversationMessages', () => {
    it('should search within specific conversation', async () => {
      const mockResults = [
        { id: 'msg-1', content: 'Project timeline', similarity: 0.85 }
      ];

      const mockVectorSearchService = new BedrockVectorSearchService();
      (mockVectorSearchService.searchConversationMessages as jest.Mock).mockResolvedValue(mockResults);

      (BedrockVectorSearchService as jest.Mock).mockImplementation(() => mockVectorSearchService);

      const result = await vectorDBService.searchConversationMessages(
        'project timeline',
        'conversation-123',
        5
      );

      expect(result).toEqual(mockResults);
      expect(mockVectorSearchService.searchConversationMessages).toHaveBeenCalledWith(
        'project timeline',
        'conversation-123',
        5
      );
    });

    it('should handle conversation search errors', async () => {
      const mockVectorSearchService = new BedrockVectorSearchService();
      (mockVectorSearchService.searchConversationMessages as jest.Mock).mockRejectedValue(
        new Error('Conversation search error')
      );

      (BedrockVectorSearchService as jest.Mock).mockImplementation(() => mockVectorSearchService);

      await expect(
        vectorDBService.searchConversationMessages('project timeline', 'conversation-123', 5)
      ).rejects.toThrow('Conversation search error');
    });
  });

  describe('findSimilarMessages', () => {
    it('should find similar messages to a specific message', async () => {
      const mockResults = [
        { id: 'msg-2', content: 'Similar message', similarity: 0.75 }
      ];

      const mockVectorSearchService = new BedrockVectorSearchService();
      (mockVectorSearchService.findSimilarMessages as jest.Mock).mockResolvedValue(mockResults);

      (BedrockVectorSearchService as jest.Mock).mockImplementation(() => mockVectorSearchService);

      const result = await vectorDBService.findSimilarMessages(
        'msg-123',
        'conversation-123',
        5
      );

      expect(result).toEqual(mockResults);
      expect(mockVectorSearchService.findSimilarMessages).toHaveBeenCalledWith(
        'msg-123',
        'conversation-123',
        5
      );
    });
  });

  describe('batchIndexMessages', () => {
    it('should batch index multiple messages', async () => {
      const messages = [
        { id: 'msg-1', content: 'Message 1' },
        { id: 'msg-2', content: 'Message 2' }
      ];

      (aiCache.getCachedEmbedding as jest.Mock).mockResolvedValue(null);
      (aiCache.cacheEmbedding as jest.Mock).mockResolvedValue(undefined);

      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockResolvedValue(mockEmbedding);

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      await vectorDBService.batchIndexMessages(messages);

      expect(mockEmbeddingService.generateEmbedding).toHaveBeenCalledTimes(2);
      expect(aiCache.cacheEmbedding).toHaveBeenCalledTimes(2);
    });

    it('should handle batch indexing errors', async () => {
      const messages = [
        { id: 'msg-1', content: 'Message 1' }
      ];

      (aiCache.getCachedEmbedding as jest.Mock).mockResolvedValue(null);

      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockRejectedValue(
        new Error('Batch indexing error')
      );

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      await expect(
        vectorDBService.batchIndexMessages(messages)
      ).rejects.toThrow('Batch indexing error');
    });
  });

  describe('getEmbedding', () => {
    it('should get embedding for text', async () => {
      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockResolvedValue(mockEmbedding);

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      const result = await vectorDBService.getEmbedding('test text');

      expect(result).toEqual(mockEmbedding);
      expect(mockEmbeddingService.generateEmbedding).toHaveBeenCalledWith('test text');
    });
  });

  describe('calculateSimilarity', () => {
    it('should calculate similarity between two texts', async () => {
      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock)
        .mockResolvedValueOnce([1, 0, 0])
        .mockResolvedValueOnce([0, 1, 0]);

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      const result = await vectorDBService.calculateSimilarity('text1', 'text2');

      expect(typeof result).toBe('number');
      expect(result).toBeGreaterThanOrEqual(0);
      expect(result).toBeLessThanOrEqual(1);
    });

    it('should handle similarity calculation errors', async () => {
      const mockEmbeddingService = new BedrockEmbeddingService();
      (mockEmbeddingService.generateEmbedding as jest.Mock).mockRejectedValue(
        new Error('Embedding error')
      );

      (BedrockEmbeddingService as jest.Mock).mockImplementation(() => mockEmbeddingService);

      await expect(
        vectorDBService.calculateSimilarity('text1', 'text2')
      ).rejects.toThrow('Embedding error');
    });
  });

  describe('getStats', () => {
    it('should return vector database statistics', async () => {
      const mockCacheStats = {
        totalEntries: 42,
        timestamp: '2024-01-01T00:00:00Z'
      };

      (aiCache.getCacheStats as jest.Mock).mockResolvedValue(mockCacheStats);

      const result = await vectorDBService.getStats();

      expect(result).toEqual({
        cache: mockCacheStats,
        timestamp: expect.any(String)
      });
    });

    it('should return null on error', async () => {
      (aiCache.getCacheStats as jest.Mock).mockRejectedValue(new Error('Cache stats error'));

      const result = await vectorDBService.getStats();

      expect(result).toBeNull();
    });
  });
});
