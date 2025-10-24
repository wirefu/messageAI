import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Summarizes a conversation using mock AI response
 * In production, this would call OpenAI GPT-4
 */
export const summarizeConversation = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { conversationID, messageCount } = data;

  if (!conversationID) {
    throw new functions.https.HttpsError('invalid-argument', 'conversationID required');
  }

  try {
    // Fetch messages from Firestore
    const messagesSnapshot = await admin.firestore()
      .collection('conversations')
      .doc(conversationID)
      .collection('messages')
      .orderBy('timestamp', 'desc')
      .limit(messageCount || 20)
      .get();

    // For emulator: Return mock summary
    // In production: Would fetch and analyze messages with OpenAI
    // const messages = messagesSnapshot.docs.map(...)
    const summary = {
      conversationID,
      keyPoints: [
        'Discussing project timeline and status',
        'Evaluating different AI model options',
        'Planning Cloud Functions implementation',
      ],
      decisions: [
        'Agreed to use mixed AI approach',
        'GPT-4 for summaries, GPT-4o-mini for simple tasks',
      ],
      actionItems: [
        'Set up Cloud Functions by end of week',
        'Deploy by Friday',
      ],
      openQuestions: [
        'How to handle offline message sync?',
      ],
    };

    return summary;
  } catch (error) {
    console.error('Summarization error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate summary');
  }
});

/**
 * Checks message clarity - mock implementation
 */
export const checkClarity = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  // Mock clarity response
  return {
    clarityIssues: [],
    suggestedRevision: null,
    toneWarning: null,
    alternativePhrasing: null,
  };
});

/**
 * Extracts action items - mock implementation
 */
export const extractActionItems = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  // Mock action items response
  return {
    actionItems: [],
  };
});

