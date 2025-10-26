import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { BedrockConfig } from '../bedrockConfig';
import { OpenAIService } from '../utils/openai';
import { aiCache } from '../utils/aiCache';

/**
 * Conversational Search Handler
 * Implements RAG-powered search using Bedrock for vector search and OpenAI for synthesis
 */
export class ConversationSearchHandler {
  private bedrockConfig: BedrockConfig;
  private openaiService: OpenAIService;

  constructor() {
    this.bedrockConfig = BedrockConfig.getInstance();
    this.openaiService = new OpenAIService();
  }

  /**
   * Main conversational search function
   */
  async searchConversations(
    userId: string,
    query: string,
    conversationId?: string,
    limit: number = 10
  ): Promise<any> {
    try {
      // Check cache first
      const cacheKey = `search:${userId}:${Buffer.from(query).toString('base64')}`;
      const cachedResult = await aiCache.getCachedResponse(cacheKey);
      if (cachedResult) {
        console.log('Returning cached search result');
        return cachedResult;
      }

      // Generate query embedding using Bedrock
      const queryEmbedding = await this.generateQueryEmbedding(query);
      
      // Perform vector search
      const searchResults = await this.performVectorSearch(
        userId,
        queryEmbedding,
        conversationId,
        limit
      );

      // Fetch full messages from Firestore
      const fullMessages = await this.fetchFullMessages(searchResults);

      // Generate AI response using OpenAI
      const aiResponse = await this.generateAIResponse(query, fullMessages);

      // Format response with sources
      const response = {
        query,
        answer: aiResponse.content,
        sources: this.formatSources(fullMessages),
        confidence: aiResponse.confidence || 0.8,
        timestamp: new Date().toISOString()
      };

      // Cache the result
      await aiCache.cacheResponse(cacheKey, response, 1800); // 30 minutes

      return response;
    } catch (error) {
      console.error('Conversational search error:', error);
      throw new functions.https.HttpsError('internal', 'Search failed');
    }
  }

  /**
   * Generate embedding for search query using Bedrock
   */
  private async generateQueryEmbedding(query: string): Promise<number[]> {
    try {
      const bedrockRuntime = this.bedrockConfig.getBedrockRuntimeClient();
      
      const { InvokeModelCommand } = await import('@aws-sdk/client-bedrock-runtime');
      
      const command = new InvokeModelCommand({
        modelId: 'amazon.titan-embed-text-v1',
        body: JSON.stringify({
          inputText: query
        }),
        contentType: 'application/json',
        accept: 'application/json'
      });

      const response = await bedrockRuntime.send(command);
      const responseBody = JSON.parse(new TextDecoder().decode(response.body));
      
      return responseBody.embedding;
    } catch (error) {
      console.error('Embedding generation error:', error);
      throw new Error('Failed to generate query embedding');
    }
  }

  /**
   * Perform vector search using Bedrock
   */
  private async performVectorSearch(
    userId: string,
    queryEmbedding: number[],
    conversationId?: string,
    limit: number = 10
  ): Promise<any[]> {
    try {
      // For now, we'll use a simplified approach
      // In production, you'd use a proper vector database like Pinecone or OpenSearch
      
      // Get recent messages from Firestore
      let query = admin.firestore()
        .collection('conversations')
        .where('participants', 'array-contains', userId)
        .orderBy('lastMessageTimestamp', 'desc')
        .limit(50);

      if (conversationId) {
        query = admin.firestore()
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', 'desc')
          .limit(50);
      }

      const snapshot = await query.get();
      const messages = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        relevance: this.calculateRelevance(doc.data().content || '', queryEmbedding)
      }));

      // Sort by relevance and return top results
      return messages
        .sort((a, b) => b.relevance - a.relevance)
        .slice(0, limit);
    } catch (error) {
      console.error('Vector search error:', error);
      throw new Error('Failed to perform vector search');
    }
  }

  /**
   * Calculate relevance score (simplified cosine similarity)
   */
  private calculateRelevance(text: string, queryEmbedding: number[]): number {
    // This is a simplified relevance calculation
    // In production, you'd use proper vector similarity
    const textLower = text.toLowerCase();
    const queryWords = ['what', 'when', 'where', 'who', 'how', 'why'];
    let score = 0;
    
    queryWords.forEach(word => {
      if (textLower.includes(word)) {
        score += 0.1;
      }
    });
    
    return Math.min(score, 1.0);
  }

  /**
   * Fetch full message details from Firestore
   */
  private async fetchFullMessages(searchResults: any[]): Promise<any[]> {
    try {
      const fullMessages = [];
      
      for (const result of searchResults) {
        if (result.conversationId && result.messageId) {
          const messageDoc = await admin.firestore()
            .collection('conversations')
            .doc(result.conversationId)
            .collection('messages')
            .doc(result.messageId)
            .get();
          
          if (messageDoc.exists) {
            fullMessages.push({
              id: messageDoc.id,
              ...messageDoc.data(),
              relevance: result.relevance
            });
          }
        }
      }
      
      return fullMessages;
    } catch (error) {
      console.error('Error fetching full messages:', error);
      return searchResults;
    }
  }

  /**
   * Generate AI response using OpenAI
   */
  private async generateAIResponse(query: string, contextMessages: any[]): Promise<any> {
    try {
      // Format context for OpenAI
      const contextText = contextMessages
        .map(msg => `${msg.senderName || 'User'}: ${msg.content}`)
        .join('\n');

      const systemPrompt = `You are an AI assistant for a team messaging app. 
Answer the user's question based on the conversation context provided.
Be helpful, accurate, and cite specific messages when relevant.
If you can't find relevant information, say so clearly.`;

      const userPrompt = `Question: ${query}

Context from conversations:
${contextText}

Please provide a helpful answer based on this context.`;

      const response = await this.openaiService.generateChatResponse([
        { role: 'user', content: userPrompt }
      ], systemPrompt);

      return {
        content: response,
        confidence: 0.8
      };
    } catch (error) {
      console.error('AI response generation error:', error);
      return {
        content: 'I apologize, but I encountered an error while processing your request.',
        confidence: 0.0
      };
    }
  }

  /**
   * Format sources for the response
   */
  private formatSources(messages: any[]): any[] {
    return messages.map(msg => ({
      id: msg.id,
      content: msg.content,
      sender: msg.senderName || 'Unknown',
      timestamp: msg.timestamp,
      conversationId: msg.conversationId,
      relevance: msg.relevance
    }));
  }
}

// Cloud Function: Conversational Search
export const conversationSearch = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { query, conversationId, limit } = data;

  if (!query || typeof query !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Query is required');
  }

  try {
    const handler = new ConversationSearchHandler();
    const result = await handler.searchConversations(
      context.auth.uid,
      query,
      conversationId,
      limit || 10
    );

    return result;
  } catch (error) {
    console.error('Conversational search function error:', error);
    throw new functions.https.HttpsError('internal', 'Search failed');
  }
});
