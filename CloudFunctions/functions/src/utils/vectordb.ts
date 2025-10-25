import { BedrockEmbeddingService } from '../bedrockEmbeddingService';
import { BedrockVectorSearchService } from '../bedrockVectorSearchService';
import { aiCache } from './aiCache';

/**
 * Vector Database Service
 * Provides unified interface for vector operations using Bedrock
 */
export class VectorDatabaseService {
  private embeddingService: BedrockEmbeddingService;
  private vectorSearchService: BedrockVectorSearchService;

  constructor() {
    this.embeddingService = new BedrockEmbeddingService();
    this.vectorSearchService = new BedrockVectorSearchService();
  }

  /**
   * Generate and cache embedding for a message
   */
  async indexMessage(messageId: string, content: string, metadata: any = {}): Promise<void> {
    try {
      // Check cache first
      const cachedEmbedding = await aiCache.getCachedEmbedding(messageId);
      if (cachedEmbedding) {
        console.log(`Using cached embedding for message ${messageId}`);
        return;
      }

      // Generate new embedding
      const embedding = await this.embeddingService.generateEmbedding(content);
      
      // Cache the embedding
      await aiCache.cacheEmbedding(messageId, embedding);
      
      console.log(`Indexed message ${messageId} with embedding`);
    } catch (error) {
      console.error(`Error indexing message ${messageId}:`, error);
      throw error;
    }
  }

  /**
   * Search for similar messages using vector similarity
   */
  async searchSimilarMessages(
    query: string, 
    userId: string, 
    limit: number = 10
  ): Promise<any[]> {
    try {
      // Check cache first
      const cachedResults = await aiCache.getCachedSearchResults(query);
      if (cachedResults) {
        console.log(`Using cached search results for query: ${query}`);
        return cachedResults;
      }

      // Perform vector search
      const results = await this.vectorSearchService.searchAllTeamMessages(query, userId, limit);
      
      // Cache the results
      await aiCache.cacheSearchResults(query, results);
      
      return results;
    } catch (error) {
      console.error(`Error searching similar messages:`, error);
      throw error;
    }
  }

  /**
   * Search within a specific conversation
   */
  async searchConversationMessages(
    query: string,
    conversationId: string,
    limit: number = 5
  ): Promise<any[]> {
    try {
      const results = await this.vectorSearchService.searchConversationMessages(
        query, 
        conversationId, 
        limit
      );
      
      return results;
    } catch (error) {
      console.error(`Error searching conversation ${conversationId}:`, error);
      throw error;
    }
  }

  /**
   * Find similar messages to a specific message
   */
  async findSimilarMessages(
    messageId: string,
    conversationId: string,
    limit: number = 5
  ): Promise<any[]> {
    try {
      const results = await this.vectorSearchService.findSimilarMessages(
        messageId,
        conversationId,
        limit
      );
      
      return results;
    } catch (error) {
      console.error(`Error finding similar messages to ${messageId}:`, error);
      throw error;
    }
  }

  /**
   * Batch index multiple messages
   */
  async batchIndexMessages(messages: Array<{id: string, content: string, metadata?: any}>): Promise<void> {
    try {
      const promises = messages.map(message => 
        this.indexMessage(message.id, message.content, message.metadata)
      );
      
      await Promise.all(promises);
      console.log(`Batch indexed ${messages.length} messages`);
    } catch (error) {
      console.error('Error batch indexing messages:', error);
      throw error;
    }
  }

  /**
   * Get embedding for a text
   */
  async getEmbedding(text: string): Promise<number[]> {
    try {
      return await this.embeddingService.generateEmbedding(text);
    } catch (error) {
      console.error('Error generating embedding:', error);
      throw error;
    }
  }

  /**
   * Calculate similarity between two texts
   */
  async calculateSimilarity(text1: string, text2: string): Promise<number> {
    try {
      const [embedding1, embedding2] = await Promise.all([
        this.getEmbedding(text1),
        this.getEmbedding(text2)
      ]);
      
      return this.cosineSimilarity(embedding1, embedding2);
    } catch (error) {
      console.error('Error calculating similarity:', error);
      throw error;
    }
  }

  /**
   * Calculate cosine similarity between two vectors
   */
  private cosineSimilarity(vecA: number[], vecB: number[]): number {
    if (vecA.length !== vecB.length) {
      throw new Error('Vectors must have the same length');
    }

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
      normA += vecA[i] * vecA[i];
      normB += vecB[i] * vecB[i];
    }

    const magnitude = Math.sqrt(normA) * Math.sqrt(normB);
    return magnitude === 0 ? 0 : dotProduct / magnitude;
  }

  /**
   * Get vector database statistics
   */
  async getStats(): Promise<any> {
    try {
      const cacheStats = await aiCache.getCacheStats();
      return {
        cache: cacheStats,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Error getting vector database stats:', error);
      return null;
    }
  }
}

// Singleton instance
export const vectorDB = new VectorDatabaseService();
