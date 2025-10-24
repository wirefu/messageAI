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
    
    console.log(`📨 Summarizing ${messagesSnapshot.docs.length} messages`);
    console.log(`💬 Full conversation being sent to GPT-4:`);
    console.log(messageTexts);
    console.log(`--- End of conversation ---`);

    // Call OpenAI GPT-4 for summarization
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a conversation summarizer for a messaging app.

Analyze the COMPLETE conversation chronologically. Look at the FLOW of the discussion - how the conversation progresses from start to finish.

DO NOT focus only on the longest message. Treat short messages and long messages equally.
The RECENT messages and conversational back-and-forth are often more important than a single long message.

Extract:
1. Key Points - What are they actually talking about? (look at ALL messages, especially recent ones)
2. Decisions Made - What did they agree on or decide?
3. Action Items - What needs to be done? Who will do it?
4. Open Questions - What's unresolved?

Return ONLY valid JSON (no markdown):
{
  "keyPoints": ["topic1", "topic2"],
  "decisions": ["decision1"],
  "actionItems": ["action1"],
  "openQuestions": ["question1"]
}

Focus on the conversation's PURPOSE and OUTCOME, not just the first or longest message.`,
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

