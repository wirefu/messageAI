//
//  messageActions.ts
//  MessageAI Cloud Functions
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import * as admin from 'firebase-admin';
import { OpenAIService } from '../utils/openai';
import { aiCache } from '../utils/aiCache';

/**
 * Message Actions Handler
 * Implements translate, rewrite, extract, summarize actions for messages
 */

interface MessageActionPayload {
  actionType: 'translate' | 'rewrite' | 'extract' | 'summarize';
  messageId: string;
  conversationId: string;
  parameters?: {
    targetLanguage?: string;
    tone?: 'formal' | 'casual' | 'technical' | 'friendly';
    sourceLanguage?: string;
    messageContent?: string; // For AI chat messages
  };
}

interface MessageActionResult {
  success: boolean;
  result: any;
  metadata: {
    actionType: string;
    messageId: string;
    timestamp: string;
    processingTime: number;
  };
  error?: string;
}

/**
 * Main message action handler
 * Routes different action types to appropriate handlers
 */
export async function performMessageAction(
  userId: string,
  payload: MessageActionPayload
): Promise<MessageActionResult> {
  const startTime = Date.now();
  
  try {
    // Validate required fields
    if (!payload.actionType || !payload.messageId || !payload.conversationId) {
      throw new Error('Missing required fields: actionType, messageId, conversationId');
    }

    // Check cache first
    const cacheKey = `${userId}_${payload.messageId}_${payload.actionType}`;
    const cachedResult = await aiCache.getCachedResponse(cacheKey);
    if (cachedResult) {
      console.log(`Cache hit for action ${payload.actionType} on message ${payload.messageId}`);
      return {
        success: true,
        result: cachedResult,
        metadata: {
          actionType: payload.actionType,
          messageId: payload.messageId,
          timestamp: new Date().toISOString(),
          processingTime: Date.now() - startTime
        }
      };
    }

    // Route to appropriate action handler
    let result: any;
    switch (payload.actionType) {
      case 'translate':
        result = await translateMessage(userId, payload);
        break;
      case 'rewrite':
        result = await rewriteMessage(userId, payload);
        break;
      case 'extract':
        result = await extractEntities(userId, payload);
        break;
      case 'summarize':
        result = await summarizeThread(userId, payload);
        break;
      default:
        throw new Error(`Unsupported action type: ${payload.actionType}`);
    }

    // Cache the result
    await aiCache.cacheResponse(cacheKey, result, 86400); // 24 hours

    return {
      success: true,
      result,
      metadata: {
        actionType: payload.actionType,
        messageId: payload.messageId,
        timestamp: new Date().toISOString(),
        processingTime: Date.now() - startTime
      }
    };

  } catch (error) {
    console.error('Message action error:', error);
    return {
      success: false,
      result: null,
      metadata: {
        actionType: payload.actionType,
        messageId: payload.messageId,
        timestamp: new Date().toISOString(),
        processingTime: Date.now() - startTime
      },
      error: error instanceof Error ? error.message : 'Unknown error'
    };
  }
}

/**
 * Translate message to target language
 */
async function translateMessage(
  userId: string,
  payload: MessageActionPayload
): Promise<any> {
  const db = admin.firestore();
  
  let messageText = '';
  
  // Handle AI chat messages differently
  if (payload.conversationId === 'ai-chat') {
    // For AI chat, we need to get the message content from the client
    // Since we can't fetch from Firestore, we'll need to pass it in the payload
    messageText = payload.parameters?.messageContent || '';
    if (!messageText) {
      throw new Error('Message content not provided for AI chat');
    }
  } else {
    // Fetch message from Firestore for regular conversations
    const messageDoc = await db
      .collection('conversations')
      .doc(payload.conversationId)
      .collection('messages')
      .doc(payload.messageId)
      .get();
      
    if (!messageDoc.exists) {
      throw new Error('Message not found');
    }
    
    const messageData = messageDoc.data();
    if (!messageData) {
      throw new Error('Message data not found');
    }
    
    messageText = messageData.content || '';
  }
  
  const targetLanguage = payload.parameters?.targetLanguage || 'Spanish';
  const sourceLanguage = payload.parameters?.sourceLanguage || 'auto';
  
  // Create system prompt for translation
  const systemPrompt = `You are a professional translator. Translate the following message to ${targetLanguage}. 
  ${sourceLanguage !== 'auto' ? `The source language is ${sourceLanguage}.` : 'Auto-detect the source language.'}
  
  Return only the translated text, maintaining the original tone and context.`;
  
  // Call OpenAI for translation
  const openaiService = new OpenAIService();
  const translatedText = await openaiService.generateChatResponse([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: messageText }
  ]);
  
  return {
    originalText: messageText,
    translatedText: translatedText,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    messageId: payload.messageId,
    timestamp: new Date().toISOString()
  };
}

/**
 * Rewrite message with specified tone
 */
async function rewriteMessage(
  userId: string,
  payload: MessageActionPayload
): Promise<any> {
  const db = admin.firestore();
  
  let messageText = '';
  
  // Handle AI chat messages differently
  if (payload.conversationId === 'ai-chat') {
    messageText = payload.parameters?.messageContent || '';
    if (!messageText) {
      throw new Error('Message content not provided for AI chat');
    }
  } else {
    // Fetch message from Firestore for regular conversations
    const messageDoc = await db
      .collection('conversations')
      .doc(payload.conversationId)
      .collection('messages')
      .doc(payload.messageId)
      .get();
      
    if (!messageDoc.exists) {
      throw new Error('Message not found');
    }
    
    const messageData = messageDoc.data();
    if (!messageData) {
      throw new Error('Message data not found');
    }
    
    messageText = messageData.content || '';
  }
  
  const tone = payload.parameters?.tone || 'formal';
  
  // Create tone-specific system prompts
  const tonePrompts = {
    formal: `Rewrite the following message in a formal, professional tone. Use proper business language and maintain professionalism while keeping the core meaning intact.`,
    casual: `Rewrite the following message in a casual, friendly tone. Make it sound natural and conversational while keeping the original meaning.`,
    technical: `Rewrite the following message in a technical, precise tone. Use appropriate technical terminology and maintain accuracy while being clear and concise.`,
    friendly: `Rewrite the following message in a warm, friendly tone. Make it sound approachable and personable while maintaining the original intent.`
  };
  
  const systemPrompt = tonePrompts[tone] || tonePrompts.formal;
  
  // Call OpenAI for rewriting
  const openaiService = new OpenAIService();
  const rewrittenText = await openaiService.generateChatResponse([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: messageText }
  ]);
  
  return {
    originalText: messageText,
    rewrittenText: rewrittenText,
    tone: tone,
    messageId: payload.messageId,
    timestamp: new Date().toISOString()
  };
}

/**
 * Extract entities from message
 */
async function extractEntities(
  userId: string,
  payload: MessageActionPayload
): Promise<any> {
  const db = admin.firestore();
  
  let messageText = '';
  
  // Handle AI chat messages differently
  if (payload.conversationId === 'ai-chat') {
    messageText = payload.parameters?.messageContent || '';
    if (!messageText) {
      throw new Error('Message content not provided for AI chat');
    }
  } else {
    // Fetch message from Firestore for regular conversations
    const messageDoc = await db
      .collection('conversations')
      .doc(payload.conversationId)
      .collection('messages')
      .doc(payload.messageId)
      .get();
      
    if (!messageDoc.exists) {
      throw new Error('Message not found');
    }
    
    const messageData = messageDoc.data();
    if (!messageData) {
      throw new Error('Message data not found');
    }
    
    messageText = messageData.content || '';
  }
  
  // Create system prompt for entity extraction
  const systemPrompt = `Extract the following entities from the message and return them as a JSON object:

  {
    "dates": ["list of dates mentioned"],
    "actionItems": ["list of action items or tasks"],
    "decisions": ["list of decisions made"],
    "people": ["list of people mentioned"],
    "locations": ["list of locations mentioned"],
    "topics": ["list of main topics discussed"]
  }

  Return only the JSON object, no additional text.`;
  
  // Call OpenAI for entity extraction
  const openaiService = new OpenAIService();
  const extractionResult = await openaiService.generateChatResponse([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: messageText }
  ]);
  
  // Parse JSON result
  let entities;
  try {
    entities = JSON.parse(extractionResult);
  } catch (error) {
    console.error('Failed to parse entity extraction result:', error);
    entities = {
      dates: [],
      actionItems: [],
      decisions: [],
      people: [],
      locations: [],
      topics: []
    };
  }
  
  return {
    originalText: messageText,
    entities: entities,
    messageId: payload.messageId,
    timestamp: new Date().toISOString()
  };
}

/**
 * Summarize message thread
 */
async function summarizeThread(
  userId: string,
  payload: MessageActionPayload
): Promise<any> {
  const db = admin.firestore();
  
  // Fetch message thread from Firestore
  const messagesSnapshot = await db
    .collection('conversations')
    .doc(payload.conversationId)
    .collection('messages')
    .orderBy('timestamp', 'asc')
    .limit(50) // Limit to last 50 messages for performance
    .get();
    
  if (messagesSnapshot.empty) {
    throw new Error('No messages found in conversation');
  }
  
  // Format messages for summarization
  const messages = messagesSnapshot.docs.map(doc => {
    const data = doc.data();
    return {
      id: doc.id,
      content: data.content || '',
      sender: data.senderName || 'Unknown',
      timestamp: data.timestamp?.toDate() || new Date(),
      role: data.senderId === userId ? 'user' : 'other'
    };
  });
  
  // Create formatted text for summarization
  const threadText = messages.map(msg => 
    `${msg.sender}: ${msg.content}`
  ).join('\n\n');
  
  // Create system prompt for summarization
  const systemPrompt = `Summarize the following conversation thread in a concise manner. 
  Focus on:
  - Key decisions made
  - Important action items
  - Main topics discussed
  - Any deadlines or dates mentioned
  
  Keep the summary to maximum 5 sentences and maintain a professional tone.`;
  
  // Call OpenAI for summarization
  const openaiService = new OpenAIService();
  const summary = await openaiService.generateChatResponse([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: threadText }
  ]);
  
  return {
    summary: summary,
    messageCount: messages.length,
    conversationId: payload.conversationId,
    timestamp: new Date().toISOString()
  };
}
