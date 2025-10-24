import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import OpenAI from 'openai';

// Initialize Firebase Admin
admin.initializeApp();

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || functions.config().openai?.key || 'mock-key-for-testing',
});

/**
 * Summarizes a conversation using mock AI response
 * In production, this would call OpenAI GPT-4
 */
export const summarizeConversation = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { conversationID } = data;

  if (!conversationID) {
    throw new functions.https.HttpsError('invalid-argument', 'conversationID required');
  }

  try {
    // Fetch messages from Firestore
    const messagesSnapshot = await admin.firestore()
      .collection('conversations')
      .doc(conversationID)
      .collection('messages')
      .orderBy('timestamp', 'asc')
      .limit(data.messageCount || 50)
      .get();

    if (messagesSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'No messages in conversation');
    }

    // Get user display names for better readability
    const senderIDs = [...new Set(messagesSnapshot.docs.map(doc => doc.data().senderID))];
    const userDocs = await Promise.all(
      senderIDs.map(id => admin.firestore().collection('users').doc(id).get())
    );
    
    const userNames: {[key: string]: string} = {};
    userDocs.forEach(doc => {
      if (doc.exists) {
        userNames[doc.id] = doc.data()?.displayName || 'User';
      }
    });

    // Format messages with user names (not IDs) for OpenAI
    const messageTexts = messagesSnapshot.docs.map(doc => {
      const msgData = doc.data();
      const userName = userNames[msgData.senderID] || 'User';
      return `${userName}: ${msgData.content}`;
    }).join('\n');

    // Call OpenAI GPT-4 for summarization
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a professional conversation summarizer for a remote team messaging app.
Analyze the conversation and extract:
1. Key Points - main topics and important information discussed
2. Decisions Made - agreements, choices, and conclusions reached
3. Action Items - tasks committed to, with assignees and deadlines if mentioned
4. Open Questions - unresolved items needing discussion

Return ONLY valid JSON (no markdown, no code blocks) in this exact structure:
{
  "keyPoints": ["point1", "point2"],
  "decisions": ["decision1"],
  "actionItems": ["action1"],
  "openQuestions": ["question1"]
}

Be concise. Each item should be one clear sentence.`,
        },
        {
          role: 'user',
          content: `Summarize this conversation:\n\n${messageTexts}`,
        },
      ],
      temperature: 0.3,
      max_tokens: 1000,
    });

    // Parse OpenAI response
    const responseText = completion.choices[0]?.message?.content || '{}';
    const cleanedText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const aiSummary = JSON.parse(cleanedText);

    return {
      conversationID,
      keyPoints: aiSummary.keyPoints || [],
      decisions: aiSummary.decisions || [],
      actionItems: aiSummary.actionItems || [],
      openQuestions: aiSummary.openQuestions || [],
    };
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

