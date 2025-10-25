import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { aiChatService } from './services/aiChatService';
import { vectorDB } from './utils/vectordb';
import { aiCache } from './utils/aiCache';

/**
 * AI Chat Interface - Main entry point for AI Chat Assistant
 * Processes user messages and generates AI responses with context
 */
export const aiChatInterface = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { message, sessionId, conversationId } = data;
  const userId = context.auth.uid;

  if (!message || message.trim().length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Message is required');
  }

  if (!sessionId) {
    throw new functions.https.HttpsError('invalid-argument', 'Session ID is required');
  }

  try {
    // Process the AI chat message
    const result = await aiChatService.processChatMessage(
      userId,
      message,
      sessionId,
      conversationId
    );

    // Log the interaction for analytics
    await logAIInteraction(userId, sessionId, 'chat_message');

    return {
      success: true,
      response: result.response,
      suggestions: result.suggestions,
      actions: result.actions,
      context: result.context,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI Chat Interface error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to process AI chat message');
  }
});

/**
 * Execute AI action (translate, rewrite, extract, etc.)
 */
export const executeAIChatAction = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { actionId, messageId, parameters } = data;
  const userId = context.auth.uid;

  if (!actionId || !messageId) {
    throw new functions.https.HttpsError('invalid-argument', 'Action ID and Message ID are required');
  }

  try {
    // Execute the AI action
    const result = await aiChatService.executeAction(
      actionId,
      messageId,
      parameters,
      userId
    );

    // Log the action execution
    await logAIInteraction(userId, messageId, `action_${actionId}`);

    return result;
  } catch (error) {
    console.error('AI Action execution error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to execute AI action');
  }
});

/**
 * Get AI chat suggestions for a conversation
 */
export const getAIChatSuggestions = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { conversationId } = data;
  const userId = context.auth.uid;

  if (!conversationId) {
    throw new functions.https.HttpsError('invalid-argument', 'Conversation ID is required');
  }

  try {
    // Get proactive suggestions
    const suggestions = await aiChatService.getConversationSuggestions(
      conversationId,
      userId
    );

    return {
      success: true,
      suggestions,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI Suggestions error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get AI suggestions');
  }
});

/**
 * Search across user's conversations using AI
 */
export const searchAIConversations = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { query, limit = 10 } = data;
  const userId = context.auth.uid;

  if (!query || query.trim().length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Search query is required');
  }

  try {
    // Search conversations using vector search
    const results = await aiChatService.searchConversations(
      userId,
      query,
      limit
    );

    // Log the search for analytics
    await logAIInteraction(userId, 'search', 'conversation_search');

    return {
      success: true,
      results,
      query,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI Search error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to search conversations');
  }
});

/**
 * Get AI usage statistics for a user
 */
export const getAIUsageStats = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const userId = context.auth.uid;

  try {
    // Get AI usage statistics
    const stats = await aiChatService.getUserAIStats(userId);

    return {
      success: true,
      stats,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI Stats error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get AI usage statistics');
  }
});

/**
 * Index a message for AI search (called when messages are sent)
 */
export const indexMessageForAI = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { messageId, content, conversationId, metadata = {} } = data;
  const userId = context.auth.uid;

  if (!messageId || !content) {
    throw new functions.https.HttpsError('invalid-argument', 'Message ID and content are required');
  }

  try {
    // Index the message for vector search
    await vectorDB.indexMessage(messageId, content, {
      ...metadata,
      userId,
      conversationId,
      timestamp: new Date().toISOString()
    });

    return {
      success: true,
      messageId,
      indexed: true,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Message indexing error:', error);
    // Don't throw error - indexing is not critical for message sending
    return {
      success: false,
      error: 'Failed to index message for AI search',
      timestamp: new Date().toISOString()
    };
  }
});

/**
 * Get AI chat session history
 */
export const getAIChatHistory = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { sessionId } = data;

  if (!sessionId) {
    throw new functions.https.HttpsError('invalid-argument', 'Session ID is required');
  }

  try {
    // Get chat history from cache or Firestore
    const history = await aiCache.getCachedChatSession(sessionId);

    return {
      success: true,
      history: history || [],
      sessionId,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI Chat History error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get AI chat history');
  }
});

/**
 * Clear AI chat session
 */
export const clearAIChatSession = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { sessionId } = data;
  const userId = context.auth.uid;

  if (!sessionId) {
    throw new functions.https.HttpsError('invalid-argument', 'Session ID is required');
  }

  try {
    // Clear the chat session
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('aiSessions')
      .doc(sessionId)
      .delete();

    // Clear from cache
    await aiCache.invalidate(`chat:${sessionId}`);

    return {
      success: true,
      sessionId,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Clear AI Chat Session error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to clear AI chat session');
  }
});

/**
 * Log AI interaction for analytics
 */
async function logAIInteraction(
  userId: string,
  sessionId: string,
  interactionType: string
): Promise<void> {
  try {
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('aiUsageStats')
      .doc('stats')
      .set({
        totalInteractions: admin.firestore.FieldValue.increment(1),
        lastActive: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

    // Log individual interaction
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('aiInteractions')
      .add({
        sessionId,
        interactionType,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
  } catch (error) {
    console.error('Error logging AI interaction:', error);
    // Don't throw - logging is not critical
  }
}
