import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime';
import * as functions from 'firebase-functions';

/**
 * Amazon Bedrock Vector Search Service
 * Handles semantic search across message embeddings
 */
export class BedrockVectorSearchService {
  private bedrockRuntime: BedrockRuntimeClient;
  private readonly region: string;

  constructor(region: string = 'us-east-1') {
    this.region = region;
    this.bedrockRuntime = new BedrockRuntimeClient({ region });
  }

  /**
   * Perform semantic search across all messages in a conversation
   */
  async searchConversationMessages(
    query: string, 
    conversationId: string, 
    limit: number = 10
  ): Promise<any[]> {
    try {
      // Generate embedding for the query
      const queryEmbedding = await this.generateQueryEmbedding(query);
      
      // Get all messages with embeddings from Firestore
      const admin = require('firebase-admin');
      const db = admin.firestore();
      
      const messagesSnapshot = await db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('embedding', '!=', null)
        .get();
      
      if (messagesSnapshot.empty) {
        return [];
      }
      
      // Calculate similarity scores
      const messagesWithSimilarity = messagesSnapshot.docs.map(doc => {
        const messageData = doc.data();
        const messageEmbedding = messageData.embedding;
        const similarity = this.calculateCosineSimilarity(queryEmbedding, messageEmbedding);
        
        return {
          id: doc.id,
          ...messageData,
          similarity
        };
      });
      
      // Sort by similarity and return top results
      return messagesWithSimilarity
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, limit);
        
    } catch (error) {
      functions.logger.error('Error in searchConversationMessages:', error);
      throw new Error(`Failed to search conversation messages: ${error}`);
    }
  }

  /**
   * Perform cross-user semantic search across all team conversations
   */
  async searchAllTeamMessages(
    query: string, 
    userId: string,
    limit: number = 20
  ): Promise<any[]> {
    try {
      // Generate embedding for the query
      const queryEmbedding = await this.generateQueryEmbedding(query);
      
      // Get all conversations the user has access to
      const admin = require('firebase-admin');
      const db = admin.firestore();
      
      // Get user's conversations
      const conversationsSnapshot = await db.collection('conversations')
        .where('participants', 'array-contains', userId)
        .get();
      
      if (conversationsSnapshot.empty) {
        return [];
      }
      
      // Get all messages with embeddings from all conversations
      const allMessages: any[] = [];
      
      for (const conversationDoc of conversationsSnapshot.docs) {
        const messagesSnapshot = await db.collection('conversations')
          .doc(conversationDoc.id)
          .collection('messages')
          .where('embedding', '!=', null)
          .get();
        
        messagesSnapshot.docs.forEach(doc => {
          const messageData = doc.data();
          const messageEmbedding = messageData.embedding;
          const similarity = this.calculateCosineSimilarity(queryEmbedding, messageEmbedding);
          
          allMessages.push({
            id: doc.id,
            conversationId: conversationDoc.id,
            ...messageData,
            similarity
          });
        });
      }
      
      // Sort by similarity and return top results
      return allMessages
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, limit);
        
    } catch (error) {
      functions.logger.error('Error in searchAllTeamMessages:', error);
      throw new Error(`Failed to search team messages: ${error}`);
    }
  }

  /**
   * Generate embedding for a search query
   */
  private async generateQueryEmbedding(query: string): Promise<number[]> {
    try {
      const command = new InvokeModelCommand({
        modelId: 'amazon.titan-embed-text-v1',
        contentType: 'application/json',
        body: JSON.stringify({
          inputText: query
        })
      });

      const response = await this.bedrockRuntime.send(command);
      const responseBody = JSON.parse(new TextDecoder().decode(response.body));
      
      return responseBody.embedding;
    } catch (error) {
      functions.logger.error('Error generating query embedding:', error);
      throw new Error(`Failed to generate query embedding: ${error}`);
    }
  }

  /**
   * Calculate cosine similarity between two vectors
   */
  private calculateCosineSimilarity(vectorA: number[], vectorB: number[]): number {
    if (vectorA.length !== vectorB.length) {
      return 0;
    }
    
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;
    
    for (let i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }
    
    if (normA === 0 || normB === 0) {
      return 0;
    }
    
    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }

  /**
   * Find similar messages based on semantic similarity
   */
  async findSimilarMessages(
    messageId: string,
    conversationId: string,
    limit: number = 5
  ): Promise<any[]> {
    try {
      // Get the reference message
      const admin = require('firebase-admin');
      const db = admin.firestore();
      
      const messageDoc = await db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .get();
      
      if (!messageDoc.exists || !messageDoc.data()?.embedding) {
        return [];
      }
      
      const referenceEmbedding = messageDoc.data()!.embedding;
      
      // Get all other messages with embeddings
      const messagesSnapshot = await db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('embedding', '!=', null)
        .get();
      
      // Calculate similarity scores
      const messagesWithSimilarity = messagesSnapshot.docs
        .filter(doc => doc.id !== messageId)
        .map(doc => {
          const messageData = doc.data();
          const messageEmbedding = messageData.embedding;
          const similarity = this.calculateCosineSimilarity(referenceEmbedding, messageEmbedding);
          
          return {
            id: doc.id,
            ...messageData,
            similarity
          };
        });
      
      // Sort by similarity and return top results
      return messagesWithSimilarity
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, limit);
        
    } catch (error) {
      functions.logger.error('Error in findSimilarMessages:', error);
      throw new Error(`Failed to find similar messages: ${error}`);
    }
  }
}

/**
 * Cloud Function: Search conversation messages
 */
export const searchConversationMessages = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { query, conversationId, limit = 10 } = data;
  
  if (!query || !conversationId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    const searchService = new BedrockVectorSearchService();
    const results = await searchService.searchConversationMessages(query, conversationId, limit);
    
    return {
      success: true,
      results: results,
      query: query,
      conversationId: conversationId
    };
  } catch (error) {
    functions.logger.error('Error in searchConversationMessages:', error);
    throw new functions.https.HttpsError('internal', 'Failed to search conversation messages');
  }
});

/**
 * Cloud Function: Search all team messages (cross-user sharing)
 */
export const searchAllTeamMessages = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { query, limit = 20 } = data;
  const userId = context.auth.uid;
  
  if (!query) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing query');
  }

  try {
    const searchService = new BedrockVectorSearchService();
    const results = await searchService.searchAllTeamMessages(query, userId, limit);
    
    return {
      success: true,
      results: results,
      query: query,
      totalResults: results.length
    };
  } catch (error) {
    functions.logger.error('Error in searchAllTeamMessages:', error);
    throw new functions.https.HttpsError('internal', 'Failed to search team messages');
  }
});

/**
 * Cloud Function: Find similar messages
 */
export const findSimilarMessages = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { messageId, conversationId, limit = 5 } = data;
  
  if (!messageId || !conversationId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    const searchService = new BedrockVectorSearchService();
    const results = await searchService.findSimilarMessages(messageId, conversationId, limit);
    
    return {
      success: true,
      results: results,
      messageId: messageId,
      conversationId: conversationId
    };
  } catch (error) {
    functions.logger.error('Error in findSimilarMessages:', error);
    throw new functions.https.HttpsError('internal', 'Failed to find similar messages');
  }
});
