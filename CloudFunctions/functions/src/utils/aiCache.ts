import * as admin from 'firebase-admin';

/**
 * AI Cache Service for Firebase-based caching
 * Provides caching for AI responses, embeddings, and search results
 */
export class AICacheService {
  private db: admin.firestore.Firestore;
  private readonly CACHE_TTL = 3600; // 1 hour default TTL

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Cache AI response with TTL
   */
  async cacheResponse(key: string, data: any, ttl: number = this.CACHE_TTL): Promise<void> {
    try {
      const expiresAt = new Date(Date.now() + ttl * 1000);
      await this.db.collection('aiCache').doc(key).set({
        data,
        expiresAt,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    } catch (error) {
      console.error('Cache set error:', error);
      // Don't throw - caching is not critical
    }
  }

  /**
   * Get cached AI response
   */
  async getCachedResponse(key: string): Promise<any | null> {
    try {
      const doc = await this.db.collection('aiCache').doc(key).get();
      if (!doc.exists) return null;
      
      const data = doc.data();
      if (data?.expiresAt && data.expiresAt.toDate() < new Date()) {
        // Expired, delete and return null
        await this.db.collection('aiCache').doc(key).delete();
        return null;
      }
      
      return data?.data || null;
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  }

  /**
   * Cache embedding vector
   */
  async cacheEmbedding(messageId: string, embedding: number[]): Promise<void> {
    const key = `embedding:${messageId}`;
    await this.cacheResponse(key, embedding, 86400); // 24 hours
  }

  /**
   * Get cached embedding
   */
  async getCachedEmbedding(messageId: string): Promise<number[] | null> {
    const key = `embedding:${messageId}`;
    return await this.getCachedResponse(key);
  }

  /**
   * Cache search results
   */
  async cacheSearchResults(query: string, results: any[]): Promise<void> {
    const key = `search:${Buffer.from(query).toString('base64')}`;
    await this.cacheResponse(key, results, 1800); // 30 minutes
  }

  /**
   * Get cached search results
   */
  async getCachedSearchResults(query: string): Promise<any[] | null> {
    const key = `search:${Buffer.from(query).toString('base64')}`;
    return await this.getCachedResponse(key);
  }

  /**
   * Cache AI chat session
   */
  async cacheChatSession(sessionId: string, messages: any[]): Promise<void> {
    const key = `chat:${sessionId}`;
    await this.cacheResponse(key, messages, 3600); // 1 hour
  }

  /**
   * Get cached chat session
   */
  async getCachedChatSession(sessionId: string): Promise<any[] | null> {
    const key = `chat:${sessionId}`;
    return await this.getCachedResponse(key);
  }

  /**
   * Invalidate cache entry
   */
  async invalidate(key: string): Promise<void> {
    try {
      await this.db.collection('aiCache').doc(key).delete();
    } catch (error) {
      console.error('Cache invalidation error:', error);
    }
  }

  /**
   * Invalidate all cache entries for a user
   */
  async invalidateUserCache(userId: string): Promise<void> {
    try {
      const snapshot = await this.db
        .collection('aiCache')
        .where('userId', '==', userId)
        .get();
      
      const batch = this.db.batch();
      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
    } catch (error) {
      console.error('User cache invalidation error:', error);
    }
  }

  /**
   * Get cache statistics
   */
  async getCacheStats(): Promise<any> {
    try {
      const snapshot = await this.db.collection('aiCache').get();
      return {
        totalEntries: snapshot.size,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Cache stats error:', error);
      return null;
    }
  }
}

// Singleton instance
export const aiCache = new AICacheService();
