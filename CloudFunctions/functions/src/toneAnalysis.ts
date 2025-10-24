import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import OpenAI from 'openai';

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || functions.config().openai?.key || 'mock-key-for-testing',
});

/**
 * Analyzes message tone for potential issues
 * Dedicated tone analysis separate from clarity checking
 */
export const analyzeTone = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { message, conversationContext, recipientRole } = data;

  if (!message || message.trim().length === 0) {
    return {
      toneWarning: null,
      alternativePhrasing: null,
      improvementSuggestions: [],
      severity: 'none',
    };
  }

  try {
    // Call OpenAI GPT-4 for tone analysis
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a professional tone analyzer for a team messaging app.

Analyze the message for tone issues that could cause misunderstandings or hurt feelings in async communication.

Check for:
1. Terseness - overly brief, abrupt responses
2. Potential rudeness - harsh, dismissive, or aggressive language
3. Jargon confusion - technical terms that might confuse the recipient
4. Context awareness - consider the recipient's role and conversation history

Recipient Role: ${recipientRole || 'colleague'}

Return ONLY valid JSON (no markdown):
{
  "toneWarning": "specific tone issue if any",
  "alternativePhrasing": "suggested better phrasing",
  "improvementSuggestions": ["suggestion1", "suggestion2"],
  "severity": "none|low|medium|high"
}

Severity levels:
- none: No tone issues
- low: Minor improvements suggested
- medium: Some concern, alternative phrasing provided
- high: Significant tone issues that could cause problems

Be helpful but not patronizing. Focus on professional communication.`,
        },
        {
          role: 'user',
          content: `Analyze the tone of this message:\n\n"${message}"\n\nConversation context: ${conversationContext || 'No additional context'}`,
        },
      ],
      temperature: 0.3,
      max_tokens: 600,
    });

    // Parse response
    const responseText = completion.choices[0]?.message?.content || '{}';
    const cleanedText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const analysis = JSON.parse(cleanedText);

    return {
      toneWarning: analysis.toneWarning || null,
      alternativePhrasing: analysis.alternativePhrasing || null,
      improvementSuggestions: analysis.improvementSuggestions || [],
      severity: analysis.severity || 'none',
    };
  } catch (error) {
    console.error('Tone analysis error:', error);
    // Return safe defaults on error (don't block sending)
    return {
      toneWarning: null,
      alternativePhrasing: null,
      improvementSuggestions: [],
      severity: 'none',
    };
  }
});
