import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime';
import { BedrockClient, ListFoundationModelsCommand } from '@aws-sdk/client-bedrock';
import * as functions from 'firebase-functions';

/**
 * Amazon Bedrock Embedding Service
 * Handles message embeddings using Amazon Titan models
 */
export class BedrockEmbeddingService {
  private bedrockRuntime: BedrockRuntimeClient;
  private bedrock: BedrockClient;
  // private readonly _region: string;

  constructor(_region: string = 'us-east-1') {
    // this._region = _region;
    this.bedrockRuntime = new BedrockRuntimeClient({ region: _region });
    this.bedrock = new BedrockClient({ region: _region });
  }

  /**
   * Generate embedding for a message using Amazon Titan
   */
  async generateEmbedding(text: string): Promise<number[]> {
    try {
      const command = new InvokeModelCommand({
        modelId: 'amazon.titan-embed-text-v1',
        contentType: 'application/json',
        body: JSON.stringify({
          inputText: text
        })
      });

      const response = await this.bedrockRuntime.send(command);
      const responseBody = JSON.parse(new TextDecoder().decode(response.body));
      
      return responseBody.embedding;
    } catch (error) {
      functions.logger.error('Error generating embedding:', error);
      throw new Error(`Failed to generate embedding: ${error}`);
    }
  }

  /**
   * Generate embeddings for multiple messages in batch
   */
  async generateBatchEmbeddings(texts: string[]): Promise<number[][]> {
    try {
      const embeddings: number[][] = [];
      
      // Process in batches of 10 to avoid rate limits
      const batchSize = 10;
      for (let i = 0; i < texts.length; i += batchSize) {
        const batch = texts.slice(i, i + batchSize);
        const batchPromises = batch.map(text => this.generateEmbedding(text));
        const batchEmbeddings = await Promise.all(batchPromises);
        embeddings.push(...batchEmbeddings);
      }
      
      return embeddings;
    } catch (error) {
      functions.logger.error('Error generating batch embeddings:', error);
      throw new Error(`Failed to generate batch embeddings: ${error}`);
    }
  }

  /**
   * Check if Bedrock service is available and models are accessible
   */
  async checkServiceAvailability(): Promise<boolean> {
    try {
      const command = new ListFoundationModelsCommand({});
      await this.bedrock.send(command);
      return true;
    } catch (error) {
      functions.logger.error('Bedrock service not available:', error);
      return false;
    }
  }

  /**
   * Get available embedding models
   */
  async getAvailableModels(): Promise<string[]> {
    try {
      const command = new ListFoundationModelsCommand({
        byProvider: 'Amazon'
      });
      
      const response = await this.bedrock.send(command);
      return response.modelSummaries
        ?.filter(model => model.modelId?.includes('embed'))
        .map(model => model.modelId!)
        || [];
    } catch (error) {
      functions.logger.error('Error getting available models:', error);
      return [];
    }
  }
}

/**
 * Cloud Function: Generate message embedding
 */
export const generateMessageEmbedding = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { message, messageId, conversationId } = data;
  
  if (!message || !messageId || !conversationId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    const embeddingService = new BedrockEmbeddingService();
    
    // Check service availability
    const isAvailable = await embeddingService.checkServiceAvailability();
    if (!isAvailable) {
      throw new functions.https.HttpsError('unavailable', 'Bedrock service not available');
    }

    // Generate embedding
    const embedding = await embeddingService.generateEmbedding(message);
    
    // Store embedding in Firestore
    const admin = require('firebase-admin');
    const db = admin.firestore();
    
    await db.collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .doc(messageId)
      .update({
        embedding: embedding,
        embeddingGeneratedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    return {
      success: true,
      embedding: embedding,
      messageId: messageId
    };
  } catch (error) {
    functions.logger.error('Error in generateMessageEmbedding:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate embedding');
  }
});

/**
 * Cloud Function: Generate batch embeddings for conversation
 */
export const generateConversationEmbeddings = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { conversationId, messages } = data;
  
  if (!conversationId || !messages || !Array.isArray(messages)) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    const embeddingService = new BedrockEmbeddingService();
    
    // Check service availability
    const isAvailable = await embeddingService.checkServiceAvailability();
    if (!isAvailable) {
      throw new functions.https.HttpsError('unavailable', 'Bedrock service not available');
    }

    // Extract message texts
    const messageTexts = messages.map((msg: any) => msg.content || '');
    
    // Generate batch embeddings
    const embeddings = await embeddingService.generateBatchEmbeddings(messageTexts);
    
    // Store embeddings in Firestore
    const admin = require('firebase-admin');
    const db = admin.firestore();
    
    const batch = db.batch();
    
    messages.forEach((message: any, index: number) => {
      const messageRef = db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id);
      
      batch.update(messageRef, {
        embedding: embeddings[index],
        embeddingGeneratedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
    
    await batch.commit();

    return {
      success: true,
      embeddingsGenerated: embeddings.length,
      conversationId: conversationId
    };
  } catch (error) {
    functions.logger.error('Error in generateConversationEmbeddings:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate batch embeddings');
  }
});
