import OpenAI from 'openai';

/**
 * OpenAI Service for AI Chat Assistant
 * Provides OpenAI API integration for conversational AI
 */
export class OpenAIService {
  private client: OpenAI;

  constructor() {
    this.client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  /**
   * Generate AI response for chat
   */
  async generateChatResponse(
    messages: Array<{role: 'user' | 'assistant' | 'system', content: string}>,
    context?: string
  ): Promise<string> {
    try {
      const systemMessage = context 
        ? `You are an AI assistant for a team messaging app. Use this context to provide helpful responses: ${context}`
        : 'You are an AI assistant for a team messaging app. Help users with their conversations, provide insights, and suggest actions.';

      const chatMessages = [
        { role: 'system' as const, content: systemMessage },
        ...messages
      ];

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: chatMessages,
        max_tokens: 1000,
        temperature: 0.7,
      });

      return response.choices[0]?.message?.content || 'Sorry, I could not generate a response.';
    } catch (error) {
      console.error('OpenAI API error:', error);
      throw new Error('Failed to generate AI response');
    }
  }

  /**
   * Generate proactive suggestions based on conversation context
   */
  async generateProactiveSuggestions(
    conversationContext: string,
    recentMessages: string[]
  ): Promise<Array<{type: string, suggestion: string, confidence: number}>> {
    try {
      const prompt = `Based on this conversation context: "${conversationContext}" and recent messages: ${recentMessages.join(', ')}, generate 3 proactive suggestions for the user. Each suggestion should be actionable and relevant. Format as JSON array with type, suggestion, and confidence (0-1).`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are an AI assistant that generates proactive suggestions for team conversations. Return only valid JSON.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.5,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        return [];
      }

      try {
        return JSON.parse(content);
      } catch (parseError) {
        console.error('Error parsing suggestions JSON:', parseError);
        return [];
      }
    } catch (error) {
      console.error('Error generating proactive suggestions:', error);
      return [];
    }
  }

  /**
   * Analyze message tone and provide suggestions
   */
  async analyzeMessageTone(message: string): Promise<{
    tone: string,
    sentiment: 'positive' | 'neutral' | 'negative',
    suggestions: string[]
  }> {
    try {
      const prompt = `Analyze the tone of this message: "${message}". Return JSON with tone (formal/casual/urgent/friendly), sentiment (positive/neutral/negative), and suggestions for improvement if needed.`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are an AI assistant that analyzes message tone. Return only valid JSON.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.3,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        return { tone: 'neutral', sentiment: 'neutral', suggestions: [] };
      }

      try {
        return JSON.parse(content);
      } catch (parseError) {
        console.error('Error parsing tone analysis JSON:', parseError);
        return { tone: 'neutral', sentiment: 'neutral', suggestions: [] };
      }
    } catch (error) {
      console.error('Error analyzing message tone:', error);
      return { tone: 'neutral', sentiment: 'neutral', suggestions: [] };
    }
  }

  /**
   * Extract action items from conversation
   */
  async extractActionItems(conversationText: string): Promise<Array<{
    action: string,
    assignee?: string,
    dueDate?: string,
    priority: 'high' | 'medium' | 'low'
  }>> {
    try {
      const prompt = `Extract action items from this conversation: "${conversationText}". Return JSON array with action, assignee (if mentioned), dueDate (if mentioned), and priority (high/medium/low).`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are an AI assistant that extracts action items from conversations. Return only valid JSON.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.3,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        return [];
      }

      try {
        return JSON.parse(content);
      } catch (parseError) {
        console.error('Error parsing action items JSON:', parseError);
        return [];
      }
    } catch (error) {
      console.error('Error extracting action items:', error);
      return [];
    }
  }

  /**
   * Generate conversation summary
   */
  async generateSummary(conversationText: string): Promise<{
    summary: string,
    keyPoints: string[],
    decisions: string[],
    nextSteps: string[]
  }> {
    try {
      const prompt = `Summarize this conversation: "${conversationText}". Return JSON with summary, keyPoints array, decisions array, and nextSteps array.`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are an AI assistant that summarizes conversations. Return only valid JSON.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 800,
        temperature: 0.4,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        return { summary: '', keyPoints: [], decisions: [], nextSteps: [] };
      }

      try {
        return JSON.parse(content);
      } catch (parseError) {
        console.error('Error parsing summary JSON:', parseError);
        return { summary: '', keyPoints: [], decisions: [], nextSteps: [] };
      }
    } catch (error) {
      console.error('Error generating summary:', error);
      return { summary: '', keyPoints: [], decisions: [], nextSteps: [] };
    }
  }

  /**
   * Translate text to target language
   */
  async translateText(text: string, targetLanguage: string): Promise<string> {
    try {
      const prompt = `Translate this text to ${targetLanguage}: "${text}". Return only the translation.`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are a professional translator. Return only the translated text.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.1,
      });

      return response.choices[0]?.message?.content || text;
    } catch (error) {
      console.error('Error translating text:', error);
      return text;
    }
  }

  /**
   * Rewrite text with different tone
   */
  async rewriteText(text: string, tone: 'formal' | 'casual' | 'technical' | 'friendly'): Promise<string> {
    try {
      const prompt = `Rewrite this text in a ${tone} tone: "${text}". Return only the rewritten text.`;

      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are a professional writer. Return only the rewritten text.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      return response.choices[0]?.message?.content || text;
    } catch (error) {
      console.error('Error rewriting text:', error);
      return text;
    }
  }
}

// Singleton instance
export const openaiService = new OpenAIService();
