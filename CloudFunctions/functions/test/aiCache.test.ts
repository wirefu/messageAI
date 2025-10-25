import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { AICacheService } from '../src/utils/aiCache';

// Mock Firebase Admin
jest.mock('firebase-admin', () => ({
  firestore: () => ({
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        get: jest.fn(() => Promise.resolve({ exists: false, data: () => ({}) })),
        set: jest.fn(() => Promise.resolve()),
        delete: jest.fn(() => Promise.resolve())
      })),
      where: jest.fn(() => ({
        get: jest.fn(() => Promise.resolve({ docs: [] }))
      }))
    })),
    batch: jest.fn(() => ({
      delete: jest.fn(),
      commit: jest.fn(() => Promise.resolve())
    }))
  }),
  FieldValue: {
    serverTimestamp: jest.fn(() => 'mock-timestamp')
  }
}));

describe('AICacheService', () => {
  let aiCacheService: AICacheService;
  const mockKey = 'test-key';
  const mockData = { message: 'test data', timestamp: new Date() };

  beforeEach(() => {
    aiCacheService = new AICacheService();
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('cacheResponse', () => {
    it('should cache response successfully', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        set: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => mockDoc)
      });

      await aiCacheService.cacheResponse(mockKey, mockData, 3600);

      expect(mockDoc.set).toHaveBeenCalledWith({
        data: mockData,
        expiresAt: expect.any(Date),
        createdAt: 'mock-timestamp'
      });
    });

    it('should handle cache errors gracefully', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      mockFirestore.collection.mockImplementation(() => {
        throw new Error('Firestore error');
      });

      // Should not throw error
      await expect(
        aiCacheService.cacheResponse(mockKey, mockData, 3600)
      ).resolves.not.toThrow();
    });
  });

  describe('getCachedResponse', () => {
    it('should return cached data when exists and not expired', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        exists: true,
        data: () => ({
          data: mockData,
          expiresAt: { toDate: () => new Date(Date.now() + 3600000) } // 1 hour from now
        })
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve(mockDoc))
        }))
      });

      const result = await aiCacheService.getCachedResponse(mockKey);

      expect(result).toEqual(mockData);
    });

    it('should return null when document does not exist', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        exists: false
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve(mockDoc))
        }))
      });

      const result = await aiCacheService.getCachedResponse(mockKey);

      expect(result).toBeNull();
    });

    it('should delete and return null when expired', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        exists: true,
        data: () => ({
          data: mockData,
          expiresAt: { toDate: () => new Date(Date.now() - 3600000) } // 1 hour ago
        }),
        delete: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve(mockDoc)),
          delete: jest.fn(() => Promise.resolve())
        }))
      });

      const result = await aiCacheService.getCachedResponse(mockKey);

      expect(result).toBeNull();
      expect(mockDoc.delete).toHaveBeenCalled();
    });

    it('should handle errors gracefully', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      mockFirestore.collection.mockImplementation(() => {
        throw new Error('Firestore error');
      });

      const result = await aiCacheService.getCachedResponse(mockKey);

      expect(result).toBeNull();
    });
  });

  describe('cacheEmbedding', () => {
    it('should cache embedding with 24 hour TTL', async () => {
      const mockEmbedding = [0.1, 0.2, 0.3, 0.4];
      const messageId = 'msg-123';

      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        set: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => mockDoc)
      });

      await aiCacheService.cacheEmbedding(messageId, mockEmbedding);

      expect(mockDoc.set).toHaveBeenCalledWith({
        data: mockEmbedding,
        expiresAt: expect.any(Date),
        createdAt: 'mock-timestamp'
      });
    });
  });

  describe('getCachedEmbedding', () => {
    it('should return cached embedding', async () => {
      const mockEmbedding = [0.1, 0.2, 0.3, 0.4];
      const messageId = 'msg-123';

      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        exists: true,
        data: () => ({
          data: mockEmbedding,
          expiresAt: { toDate: () => new Date(Date.now() + 86400000) } // 24 hours from now
        })
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve(mockDoc))
        }))
      });

      const result = await aiCacheService.getCachedEmbedding(messageId);

      expect(result).toEqual(mockEmbedding);
    });
  });

  describe('cacheSearchResults', () => {
    it('should cache search results with 30 minute TTL', async () => {
      const query = 'project timeline';
      const results = [
        { id: 'msg-1', content: 'Project timeline discussion', similarity: 0.85 }
      ];

      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        set: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => mockDoc)
      });

      await aiCacheService.cacheSearchResults(query, results);

      expect(mockDoc.set).toHaveBeenCalledWith({
        data: results,
        expiresAt: expect.any(Date),
        createdAt: 'mock-timestamp'
      });
    });
  });

  describe('invalidate', () => {
    it('should delete cache entry', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      const mockDoc = {
        delete: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        doc: jest.fn(() => mockDoc)
      });

      await aiCacheService.invalidate(mockKey);

      expect(mockDoc.delete).toHaveBeenCalled();
    });

    it('should handle deletion errors gracefully', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      mockFirestore.collection.mockImplementation(() => {
        throw new Error('Firestore error');
      });

      await expect(
        aiCacheService.invalidate(mockKey)
      ).resolves.not.toThrow();
    });
  });

  describe('invalidateUserCache', () => {
    it('should delete all user cache entries', async () => {
      const userId = 'user-123';
      const mockDocs = [
        { ref: { delete: jest.fn() } },
        { ref: { delete: jest.fn() } }
      ];

      const mockFirestore = require('firebase-admin').firestore();
      const mockBatch = {
        delete: jest.fn(),
        commit: jest.fn(() => Promise.resolve())
      };

      mockFirestore.collection.mockReturnValue({
        where: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve({ docs: mockDocs }))
        }))
      });

      mockFirestore.batch.mockReturnValue(mockBatch);

      await aiCacheService.invalidateUserCache(userId);

      expect(mockBatch.delete).toHaveBeenCalledTimes(2);
      expect(mockBatch.commit).toHaveBeenCalled();
    });
  });

  describe('getCacheStats', () => {
    it('should return cache statistics', async () => {
      const mockSnapshot = {
        size: 42
      };

      const mockFirestore = require('firebase-admin').firestore();
      mockFirestore.collection.mockReturnValue({
        get: jest.fn(() => Promise.resolve(mockSnapshot))
      });

      const result = await aiCacheService.getCacheStats();

      expect(result).toEqual({
        totalEntries: 42,
        timestamp: expect.any(String)
      });
    });

    it('should return null on error', async () => {
      const mockFirestore = require('firebase-admin').firestore();
      mockFirestore.collection.mockImplementation(() => {
        throw new Error('Firestore error');
      });

      const result = await aiCacheService.getCacheStats();

      expect(result).toBeNull();
    });
  });
});
