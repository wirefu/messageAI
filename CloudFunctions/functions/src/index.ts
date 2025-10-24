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
 * Checks message clarity using GPT-4
 */
export const checkClarity = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { message, context: conversationContext } = data;

  if (!message || message.trim().length === 0) {
    // Empty message - no need to check
    return {
      clarityIssues: [],
      suggestedRevision: null,
      toneWarning: null,
      alternativePhrasing: null,
    };
  }

  try {
    // Call OpenAI GPT-4 for clarity analysis
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a professional writing assistant for a team messaging app.

Analyze the message for:
1. Clarity Issues - vague references, unclear language, missing context
2. Grammar/spelling errors
3. Tone problems - aggressive, unprofessional, or overly casual for work
4. Improvements - how to make it clearer and more professional

Return ONLY valid JSON (no markdown):
{
  "clarityIssues": ["issue1", "issue2"],
  "suggestedRevision": "improved version of the message",
  "toneWarning": "tone issue if any",
  "alternativePhrasing": "alternative way to say it"
}

If message is clear and professional, return empty arrays and nulls.`,
        },
        {
          role: 'user',
          content: `Analyze this message:\n\n"${message}"`,
        },
      ],
      temperature: 0.3,
      max_tokens: 500,
    });

    // Parse response
    const responseText = completion.choices[0]?.message?.content || '{}';
    const cleanedText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const analysis = JSON.parse(cleanedText);

    return {
      clarityIssues: analysis.clarityIssues || [],
      suggestedRevision: analysis.suggestedRevision || null,
      toneWarning: analysis.toneWarning || null,
      alternativePhrasing: analysis.alternativePhrasing || null,
    };
  } catch (error) {
    console.error('Clarity check error:', error);
    // Return empty on error (don't block sending)
    return {
      clarityIssues: [],
      suggestedRevision: null,
      toneWarning: null,
      alternativePhrasing: null,
    };
  }
});

/**
 * Extracts action items using GPT-4
 */
export const extractActionItems = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { messages, conversationID } = data;

  if (!messages || !Array.isArray(messages) || messages.length === 0) {
    return { actionItems: [] };
  }

  try {
    // Format messages for analysis
    const conversationText = messages.join('\n');

    // Call OpenAI GPT-4 to extract action items
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Using mini for cost efficiency
      messages: [
        {
          role: 'system',
          content: `You are an action item extractor for a team messaging app.

Analyze the conversation and extract commitments, tasks, and to-dos.

Look for:
- Explicit commitments ("I will...", "I'll...")
- Assigned tasks ("Can you...", "Please...")
- Deadlines and due dates
- Who is responsible

Return ONLY valid JSON (no markdown):
{
  "actionItems": [
    {
      "description": "what needs to be done",
      "assignedTo": "person's name if mentioned",
      "dueDate": "deadline if mentioned",
      "messageID": ""
    }
  ]
}

If no action items found, return empty array.`,
        },
        {
          role: 'user',
          content: `Extract action items from this conversation:\n\n${conversationText}`,
        },
      ],
      temperature: 0.2,
      max_tokens: 800,
    });

    // Parse response
    const responseText = completion.choices[0]?.message?.content || '{}';
    const cleanedText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const result = JSON.parse(cleanedText);

    return {
      actionItems: result.actionItems || [],
    };
  } catch (error) {
    console.error('Action items extraction error:', error);
    return { actionItems: [] };
  }
});

// Export tone analysis function
export { analyzeTone } from './toneAnalysis';

