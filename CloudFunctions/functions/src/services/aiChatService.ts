import * as admin from 'firebase-admin';
import { openaiService } from '../utils/openai';
import { vectorDB } from '../utils/vectordb';
import { aiCache } from '../utils/aiCache';

/**
 * AI Chat Service
 * Main service for AI Chat Assistant functionality
 */
export class AIChatService {
  private db: admin.firestore.Firestore;

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Process AI chat message and generate response
   */
  async processChatMessage(
    userId: string,
    message: string,
    sessionId: string,
    conversationId?: string
  ): Promise<{
    response: string,
    suggestions: Array<{type: string, suggestion: string, confidence: number}>,
    actions: Array<{id: string, name: string, description: string}>,
    context: string
  }> {
    try {
      // Get conversation context
      const context = await this.assembleContext(userId, message, conversationId);
      
      // Get chat history
      const chatHistory = await this.getChatHistory(sessionId);
      
      // Generate AI response
      const response = await openaiService.generateChatResponse(
        [
          ...chatHistory,
          { role: 'user' as const, content: message }
        ],
        context
      );

      // Generate proactive suggestions
      const suggestions = await openaiService.generateProactiveSuggestions(
        context,
        chatHistory.filter(m => m.role === 'user').map(m => m.content).slice(-5)
      );

      // Generate available actions
      const actions = this.generateAvailableActions(message, context);

      // Update chat history
      await this.updateChatHistory(sessionId, [
        { role: 'user' as const, content: message },
        { role: 'assistant' as const, content: response }
      ]);

      // Cache the response
      await aiCache.cacheResponse(`ai_response:${sessionId}:${Date.now()}`, {
        response,
        suggestions,
        actions,
        context
      }, 3600);

      return {
        response,
        suggestions,
        actions,
        context
      };
    } catch (error) {
      console.error('Error processing AI chat message:', error);
      throw new Error('Failed to process AI chat message');
    }
  }

  /**
   * Execute AI action (translate, rewrite, extract, etc.)
   */
  async executeAction(
    actionId: string,
    messageId: string,
    parameters: any,
    userId: string
  ): Promise<any> {
    try {
      // Get the original message
      const message = await this.getMessageById(messageId);
      if (!message) {
        throw new Error('Message not found');
      }

      let result: any;

      switch (actionId) {
        case 'translate':
          result = await openaiService.translateText(
            message.content,
            parameters.targetLanguage || 'Spanish'
          );
          break;

        case 'rewrite':
          result = await openaiService.rewriteText(
            message.content,
            parameters.tone || 'formal'
          );
          break;

        case 'extract_actions':
          result = await openaiService.extractActionItems(message.content);
          break;

        case 'summarize':
          result = await openaiService.generateSummary(message.content);
          break;

        case 'analyze_tone':
          result = await openaiService.analyzeMessageTone(message.content);
          break;

        default:
          throw new Error(`Unknown action: ${actionId}`);
      }

      // Log the action execution
      await this.logActionExecution(userId, actionId, messageId, result);

      return {
        success: true,
        actionId,
        result,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error(`Error executing action ${actionId}:`, error);
      throw error;
    }
  }

  /**
   * Get AI chat suggestions for a conversation
   */
  async getConversationSuggestions(
    conversationId: string,
    userId: string
  ): Promise<Array<{type: string, suggestion: string, confidence: number}>> {
    try {
      // Get recent messages from conversation
      const messages = await this.getConversationMessages(conversationId, 10);
      const conversationText = messages.map(m => m.content).join(' ');

      // Generate suggestions based on conversation
      const suggestions = await openaiService.generateProactiveSuggestions(
        conversationText,
        messages.map(m => m.content)
      );

      return suggestions;
    } catch (error) {
      console.error('Error getting conversation suggestions:', error);
      return [];
    }
  }

  /**
   * Search across user's conversations
   */
  async searchConversations(
    userId: string,
    query: string,
    limit: number = 10
  ): Promise<any[]> {
    try {
      // Use vector search to find relevant messages
      const results = await vectorDB.searchSimilarMessages(query, userId, limit);
      
      // Format results for display
      return results.map(result => ({
        messageId: result.id,
        content: result.content,
        conversationId: result.conversationId,
        timestamp: result.timestamp,
        relevance: result.similarity || 0
      }));
    } catch (error) {
      console.error('Error searching conversations:', error);
      return [];
    }
  }

  /**
   * Get AI usage statistics for a user
   */
  async getUserAIStats(userId: string): Promise<{
    totalInteractions: number,
    actionsExecuted: number,
    suggestionsProvided: number,
    lastActive: string
  }> {
    try {
      const statsDoc = await this.db
        .collection('users')
        .doc(userId)
        .collection('aiUsageStats')
        .doc('stats')
        .get();

      if (!statsDoc.exists) {
        return {
          totalInteractions: 0,
          actionsExecuted: 0,
          suggestionsProvided: 0,
          lastActive: new Date().toISOString()
        };
      }

      const data = statsDoc.data();
      return {
        totalInteractions: data?.totalInteractions || 0,
        actionsExecuted: data?.actionsExecuted || 0,
        suggestionsProvided: data?.suggestionsProvided || 0,
        lastActive: data?.lastActive || new Date().toISOString()
      };
    } catch (error) {
      console.error('Error getting AI stats:', error);
      return {
        totalInteractions: 0,
        actionsExecuted: 0,
        suggestionsProvided: 0,
        lastActive: new Date().toISOString()
      };
    }
  }

  /**
   * Assemble context for AI response
   */
  private async assembleContext(
    userId: string,
    message: string,
    conversationId?: string
  ): Promise<string> {
    try {
      let context = '';

      // Get recent messages from current conversation
      if (conversationId) {
        const recentMessages = await this.getConversationMessages(conversationId, 5);
        context += `Recent conversation context: ${recentMessages.map(m => m.content).join(' ')}\n`;
      }

      // Search for related messages across all conversations
      const relatedMessages = await vectorDB.searchSimilarMessages(message, userId, 5);
      if (relatedMessages.length > 0) {
        context += `Related messages from other conversations: ${relatedMessages.map(m => m.content).join(' ')}\n`;
      }

      return context;
    } catch (error) {
      console.error('Error assembling context:', error);
      return '';
    }
  }

  /**
   * Get chat history for a session
   */
  private async getChatHistory(sessionId: string): Promise<Array<{role: 'user' | 'assistant' | 'system', content: string}>> {
    try {
      // Check cache first
      const cached = await aiCache.getCachedChatSession(sessionId);
      if (cached) {
        return cached;
      }

      // Get from Firestore
      const sessionDoc = await this.db
        .collection('aiSessions')
        .doc(sessionId)
        .get();

      if (!sessionDoc.exists) {
        return [];
      }

      const data = sessionDoc.data();
      return data?.messages || [];
    } catch (error) {
      console.error('Error getting chat history:', error);
      return [];
    }
  }

  /**
   * Update chat history
   */
  private async updateChatHistory(
    sessionId: string,
    newMessages: Array<{role: string, content: string}>
  ): Promise<void> {
    try {
      const currentHistory = await this.getChatHistory(sessionId);
      const updatedHistory = [...currentHistory, ...newMessages];

      // Update Firestore
      await this.db
        .collection('aiSessions')
        .doc(sessionId)
        .set({
          messages: updatedHistory,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

      // Update cache
      await aiCache.cacheChatSession(sessionId, updatedHistory);
    } catch (error) {
      console.error('Error updating chat history:', error);
    }
  }

  /**
   * Generate available actions based on message content
   */
  private generateAvailableActions(message: string, context: string): Array<{id: string, name: string, description: string}> {
    const actions = [];

    // Always available actions
    actions.push(
      { id: 'translate', name: 'Translate', description: 'Translate this message to another language' },
      { id: 'rewrite', name: 'Rewrite', description: 'Rewrite this message with different tone' },
      { id: 'summarize', name: 'Summarize', description: 'Generate a summary of this conversation' }
    );

    // Context-specific actions
    if (message.toLowerCase().includes('action') || message.toLowerCase().includes('todo')) {
      actions.push({ id: 'extract_actions', name: 'Extract Actions', description: 'Extract action items from this message' });
    }

    if (message.length > 100) {
      actions.push({ id: 'analyze_tone', name: 'Analyze Tone', description: 'Analyze the tone of this message' });
    }

    return actions;
  }

  /**
   * Get message by ID
   */
  private async getMessageById(messageId: string): Promise<any> {
    try {
      // This would need to be implemented based on your message structure
      // For now, return a mock message
      return {
        id: messageId,
        content: 'Sample message content',
        timestamp: new Date()
      };
    } catch (error) {
      console.error('Error getting message:', error);
      return null;
    }
  }

  /**
   * Get conversation messages
   */
  private async getConversationMessages(conversationId: string, limit: number): Promise<any[]> {
    try {
      const snapshot = await this.db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', 'desc')
        .limit(limit)
        .get();

      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error getting conversation messages:', error);
      return [];
    }
  }

  /**
   * Log action execution
   */
  private async logActionExecution(
    userId: string,
    actionId: string,
    messageId: string,
    result: any
  ): Promise<void> {
    try {
      await this.db
        .collection('users')
        .doc(userId)
        .collection('aiUsageStats')
        .doc('stats')
        .set({
          actionsExecuted: admin.firestore.FieldValue.increment(1),
          lastActive: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

      // Log individual action
      await this.db
        .collection('users')
        .doc(userId)
        .collection('aiActions')
        .add({
          actionId,
          messageId,
          result,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
    } catch (error) {
      console.error('Error logging action execution:', error);
    }
  }
}

// Singleton instance
export const aiChatService = new AIChatService();
