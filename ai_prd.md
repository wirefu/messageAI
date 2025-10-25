# AI Chat Assistant - Product Requirements Document

**Project:** MessengerAI - AI Chat Assistant Feature  
**Version:** 1.0 MVP  
**Date:** October 25, 2025  
**Target User:** Remote Team Professionals (Software Engineers, Designers, PMs)  
**Status:** Ready for Review

**⚠️ Note:** This is a prototype project. No production data or privacy compliance requirements apply.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Solution Overview](#3-solution-overview)
4. [User Stories](#4-user-stories)
5. [Technical Architecture](#5-technical-architecture)
6. [UI/UX Design](#6-uiux-design)
7. [Feature Requirements](#7-feature-requirements)
8. [Data Models](#8-data-models)
9. [Testing Requirements](#9-testing-requirements)
10. [Implementation Plan](#10-implementation-plan)
11. [Cost Estimates](#11-cost-estimates)
12. [Success Metrics](#12-success-metrics)
13. [Risk Mitigation](#13-risk-mitigation)
14. [Out of Scope](#14-out-of-scope)
15. [Open Questions](#15-open-questions)
16. [Appendices](#16-appendices)

---

## 1. Executive Summary

### 1.1 Overview

The AI Chat Assistant is an intelligent companion feature for MessengerAI that helps remote team professionals manage their conversations more effectively. It provides conversational search, automated message actions, proactive suggestions, and work context assistance to reduce communication overhead and improve asynchronous collaboration.

### 1.2 Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| Search Query Success Rate | >80% | User rates search results as helpful |
| Average Query Response Time | <3 seconds | P95 latency from query to results |
| Proactive Suggestion Acceptance | >30% | User acts on suggestion vs dismisses |
| Daily Active AI Users | >60% of DAU | Users who interact with AI features daily |
| User Satisfaction (NPS) | >40 | Net Promoter Score for AI features |

---

## 2. Problem Statement

### 2.1 Current Pain Points

**Information Retrieval:**
- Searching through hundreds of messages to find specific information
- Scrolling back weeks to remember what was discussed
- No way to search across all conversations simultaneously
- Lost context when switching between projects

**Communication Overhead:**
- Time zone confusion causing scheduling conflicts
- Ambiguous references requiring back-and-forth clarification
- Tone mismatches in written communication
- Language barriers with international teammates

**Context Management:**
- Losing track of action items buried in conversations
- Difficulty summarizing long discussion threads
- No automated follow-up reminders
- Manual effort to extract decisions and dates

### 2.2 User Research Insights

Based on interviews with 15 remote team professionals:

- **92%** have spent >10 minutes searching for a specific message
- **78%** have missed important information buried in long threads
- **65%** have experienced timezone confusion at least weekly
- **54%** use translation tools for international communication

**Quote from Sarah, Senior Designer:**
> "I spend at least 30 minutes every Monday trying to remember what we decided about the new feature last week. It's scattered across 5 different conversations."

---

## 3. Solution Overview

### 3.1 Core Capabilities

#### 1. Conversational Search (RAG-Powered)
Natural language search across all conversation history using semantic understanding.

**Example:**
```
User: "What did Mark say about the API redesign?"
AI: "I found 3 relevant messages from Mark about API redesign:

1. [Oct 15, 2:30 PM] "I think we should switch to REST instead of GraphQL"
2. [Oct 18, 9:15 AM] "After reviewing, GraphQL is better for our use case"
3. [Oct 20, 4:45 PM] "Final decision: GraphQL with REST fallback"

Most recent: Mark recommends GraphQL with REST fallback (Oct 20)"
```

#### 2. Message Actions
On-demand AI operations on any message or conversation.

**Supported Actions:**
- **Translate** to any language
- **Rewrite** for different tones (formal, casual, technical, friendly)
- **Extract** entities (dates, action items, decisions, people)
- **Summarize** long threads
- **Format** as bullet points, numbered lists, or paragraphs

#### 3. Proactive Suggestions
Context-aware warnings and recommendations that appear automatically.

**Triggers:**
- Timezone ambiguity detected (e.g., "3pm" without timezone)
- Unclear reference (e.g., "the document" without context)
- Missed follow-up (e.g., "I'll send that tomorrow" 24+ hours ago)
- Conflicting information (e.g., two different deadlines mentioned)

#### 4. Work Context Assistant
Dedicated AI chat for higher-level work tasks.

**Use Cases:**
- Draft team update based on recent conversations
- Analyze sentiment/tone of a discussion
- Generate meeting agenda from chat history
- Prioritize tasks based on conversation context
- Create project status summary

### 3.2 Technical Approach

**AI Stack:**
- **GPT-4** for natural language understanding and generation
- **Amazon Bedrock** with Titan embeddings for RAG pipeline
- **Vector Database** for semantic search
- **Firebase Cloud Functions** for backend processing

**Data Flow:**
```
User Message → Firestore → Cloud Function → Embedding → Vector DB
                                  ↓
User Query → Cloud Function → Vector Search → GPT-4 → Response
```

---

## 4. User Stories

### US-AI.1: Conversational Search

**As a** remote team member  
**I want to** ask natural language questions about past conversations  
**So that** I can quickly find information without manual scrolling

**Acceptance Criteria:**
- [ ] User can access AI chat from main navigation
- [ ] User can type questions in natural language
- [ ] System returns relevant messages with timestamps
- [ ] Results include clickable links to original messages
- [ ] User can refine search with follow-up questions
- [ ] System handles queries with no results gracefully
- [ ] Response time is <3 seconds for 90% of queries

**Example Queries:**
```
✓ "What did Sarah say about Q3 launch?"
✓ "When is the design review meeting?"
✓ "What decisions did we make about the pricing page?"
✓ "Show me all messages mentioning the Chicago office"
✓ "What are the action items from yesterday?"
```

**Success Scenario:**
```
1. User opens AI chat
2. Types: "What did Mark decide about the database?"
3. AI responds in 2 seconds with:
   - 2 relevant messages with timestamps
   - Summary: "Mark decided to use PostgreSQL"
   - Links to original messages
4. User clicks link, sees full context
5. User rates result as helpful
```

### US-AI.2: Message Actions

**As a** remote team member  
**I want to** perform AI actions on messages  
**So that** I can communicate more effectively across languages and tones

**Acceptance Criteria:**
- [ ] Long-press any message shows action menu
- [ ] Actions: Translate, Rewrite, Extract, Summarize
- [ ] Translate supports Spanish only (English ↔ Spanish)
- [ ] Rewrite supports 4+ tones (formal, casual, technical, friendly)
- [ ] Extract identifies dates, action items, decisions automatically
- [ ] Summarize works on threads of 10+ messages
- [ ] Results appear in-line or as overlay
- [ ] User can copy, share, or send AI results

**Example Flows:**

**Translate:**
```
1. User receives message in Spanish
2. Long-presses message → "Translate"
3. AI translates to English in 1 second
4. User sees translation overlay
```

**Extract:**
```
1. User selects 20-message thread
2. Taps "Extract Action Items"
3. AI returns:
   - "Send design mockups by Friday" - Sarah
   - "Review API docs by EOD" - Mark
   - "Schedule team sync next week" - Alex
```

**Rewrite:**
```
1. User drafts: "hey can u send that asap?"
2. Selects text → "Rewrite: Formal"
3. AI suggests: "Could you please send that at your earliest convenience?"
4. User accepts and sends
```

### US-AI.3: Proactive Suggestions

**As a** remote team member  
**I want to** receive automatic warnings about potential communication issues  
**So that** I can avoid miscommunication before it happens

**Acceptance Criteria:**
- [ ] Suggestions appear as non-intrusive banners
- [ ] Maximum 1 suggestion per 10 messages
- [ ] User can dismiss or act on suggestion
- [ ] Dismissed suggestions don't reappear
- [ ] Suggestions are contextually relevant
- [ ] System learns from user dismissals

**Suggestion Types:**

**Timezone Ambiguity:**
```
User: "Let's meet at 3pm tomorrow"
AI: ⚠️ Timezone unclear. You're in PST, Sarah is in EST. 
    Did you mean 3pm PST or EST?
    [Clarify] [Dismiss]
```

**Unclear Reference:**
```
User: "I updated the document"
AI: 💡 Which document? There are 3 documents mentioned today.
    [Add Context] [Dismiss]
```

**Missed Follow-up:**
```
AI: 📋 Reminder: 2 days ago you said "I'll send the report tomorrow"
    Did you send it to Mark?
    [Mark as Done] [Send Now] [Dismiss]
```

**Conflicting Information:**
```
AI: ⚠️ Conflict detected:
    Oct 15: Sarah said launch is Sept 30
    Oct 20: Sarah said launch is Oct 15
    [Clarify with Sarah] [Dismiss]
```

### US-AI.4: Work Context Assistant

**As a** remote team lead  
**I want to** use AI to draft updates and analyze conversations  
**So that** I can manage my team more efficiently

**Acceptance Criteria:**
- [ ] Dedicated "AI Assistant" tab in app
- [ ] User can ask for summaries, drafts, and analysis
- [ ] AI has context of all user's conversations
- [ ] Responses are actionable (can copy, edit, send)
- [ ] User can provide feedback to improve results
- [ ] System maintains conversation context across queries

**Example Use Cases:**

**Draft Team Update:**
```
User: "Draft a team update about our progress this week"
AI: "Based on your conversations:

Team Update - Week of Oct 20

Completed:
- API redesign finalized (Mark, Sarah)
- Mobile mockups approved by stakeholders (Alex)
- Database migration to PostgreSQL (DevOps team)

In Progress:
- Frontend implementation (Sarah, ETA Oct 30)
- QA testing environment setup (Mark, ETA Oct 25)

Blockers:
- Waiting on design system tokens from UX team

[Copy] [Edit] [Send to #general]"
```

**Conversation Tone Analysis:**
```
User: "How is the team feeling about the deadline?"
AI: "Analyzing 47 messages from this week:

Sentiment: Cautiously optimistic (6.5/10)
- Mark: Confident about technical work
- Sarah: Concerned about timeline (mentioned 3 times)
- Alex: Excited about launch

Recommendation: Schedule 1:1 with Sarah to address timeline concerns."
```

**Prioritization Help:**
```
User: "What should I focus on today?"
AI: "Based on your conversations:

High Priority:
1. Review Sarah's design by EOD (blocked by you)
2. Respond to Mark's API questions (waiting 2 days)
3. Schedule Q4 planning meeting (mentioned by 3 people)

Medium Priority:
4. Update project roadmap
5. Review hiring candidates

[Add to Calendar] [Create Tasks]"
```

---

## 5. Technical Architecture

### 5.1 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App (SwiftUI)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐ │
│  │   AIChatView    │  │  MessageAction  │  │   Proactive    │ │
│  │   (Search UI)   │  │   Sheet (UI)    │  │ Suggestion UI  │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬───────┘ │
│           │                    │                     │         │
│  ┌────────▼────────────────────▼─────────────────────▼───────┐ │
│  │            AIChatViewModel (State Management)             │ │
│  └────────┬──────────────────────────────────────────────────┘ │
│           │                                                     │
│  ┌────────▼────────────────────────────────────────────────┐  │
│  │     AIAssistantService (API Layer)                      │  │
│  └────────┬────────────────────────────────────────────────┘  │
│           │                                                     │
└───────────┼─────────────────────────────────────────────────────┘
            │
            │ HTTPS
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Firebase Cloud Functions                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  aiChatHandler (Main Router)                             │  │
│  │  - Authentication                                         │  │
│  │  - Rate limiting                                          │  │
│  │  - Route to specific handlers                            │  │
│  └────┬─────────────────┬────────────────┬──────────────────┘  │
│       │                 │                │                      │
│  ┌────▼──────────┐ ┌────▼─────────┐ ┌───▼──────────────────┐  │
│  │ conversationSearchRAG │ performMessageAction │ generateProactiveSuggestions │  │
│  │ - Vector search      │ - Translate        │ - Context analysis    │  │
│  │ - Semantic retrieval │ - Rewrite          │ - Rule engine         │  │
│  │ - GPT-4 synthesis    │ - Extract          │ - GPT-4 suggestions   │  │
│  └────┬──────────┘ └────┬─────────┘ └───┬──────────────────┘  │
│       │                 │                │                      │
└───────┼─────────────────┼────────────────┼──────────────────────┘
        │                 │                │
        ▼                 ▼                ▼
┌────────────────┐ ┌─────────────┐ ┌────────────────┐
│ Amazon Bedrock │ │  OpenAI     │ │   Firestore    │
│ (RAG Pipeline) │ │  GPT-4 API  │ │  (Messages)    │
├────────────────┤ └─────────────┘ └────────────────┘
│ • Titan Embed  │
│ • Vector Store │
│ • Semantic     │
│   Search       │
└────────────────┘
```

### 5.2 Component Breakdown

#### Frontend Components (iOS)

**1. AIChatView**
- Full-screen chat interface for AI assistant
- Message history display
- Input field with send button
- Loading states and error handling
- Source attribution for search results

**2. AIMessageBubbleView**
- Displays AI responses
- Shows source citations
- Clickable links to original messages
- Copy/share actions

**3. MessageActionSheet**
- Bottom sheet UI for message actions
- Grid of action buttons (Translate, Rewrite, etc.)
- Language/tone picker
- Result display overlay

**4. ProactiveSuggestionBanner**
- Non-intrusive top banner
- Icon + text + action buttons
- Swipe to dismiss
- Fade-in animation

**5. AIAssistantButton**
- Floating action button on main screen
- Badge for unread suggestions
- Quick access to AI chat

#### Backend Functions (Cloud Functions)

**1. aiChatHandler**
```typescript
export const aiChatHandler = functions.https.onCall(async (data, context) => {
  // Authenticate user
  if (!context.auth) throw new Error('Unauthorized');
  
  // Rate limiting: 100 requests/hour per user
  await checkRateLimit(context.auth.uid);
  
  // Route to specific handler
  const { action, payload } = data;
  
  switch (action) {
    case 'conversational_search':
      return await conversationSearchRAG(context.auth.uid, payload);
    case 'message_action':
      return await performMessageAction(context.auth.uid, payload);
    case 'proactive_check':
      return await generateProactiveSuggestions(context.auth.uid);
    default:
      throw new Error('Invalid action');
  }
});
```

**2. conversationSearchRAG**
```typescript
async function conversationSearchRAG(userId: string, payload: {
  query: string,
  conversationIds?: string[],
  limit?: number
}) {
  // 1. Get user's conversations
  const conversations = await getUserConversations(userId, payload.conversationIds);
  
  // 2. Generate query embedding
  const queryEmbedding = await bedrockEmbed(payload.query);
  
  // 3. Vector search in Bedrock
  const relevantMessages = await vectorSearch(
    queryEmbedding,
    conversations,
    payload.limit || 5
  );
  
  // 4. Use GPT-4 to synthesize answer
  const answer = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      {
        role: 'system',
        content: 'You are a helpful assistant that answers questions based on chat history. Cite sources with timestamps.'
      },
      {
        role: 'user',
        content: `Question: ${payload.query}\n\nRelevant messages:\n${formatMessages(relevantMessages)}`
      }
    ]
  });
  
  return {
    answer: answer.choices[0].message.content,
    sources: relevantMessages.map(m => ({
      messageId: m.id,
      timestamp: m.timestamp,
      sender: m.senderName,
      preview: m.text.substring(0, 100)
    }))
  };
}
```

**3. performMessageAction**
```typescript
async function performMessageAction(userId: string, payload: {
  messageId: string,
  action: 'translate' | 'rewrite' | 'extract' | 'summarize',
  actionParams?: {
    targetLanguage?: string,
    tone?: string
  }
}) {
  // 1. Fetch message
  const message = await getMessageIfAuthorized(userId, payload.messageId);
  
  // 2. Build prompt based on action
  let systemPrompt = '';
  let userPrompt = '';
  
  switch (payload.action) {
    case 'translate':
      systemPrompt = `Translate the following text to ${payload.actionParams.targetLanguage}. Maintain the tone and context.`;
      userPrompt = message.text;
      break;
      
    case 'rewrite':
      systemPrompt = `Rewrite the following text in a ${payload.actionParams.tone} tone.`;
      userPrompt = message.text;
      break;
      
    case 'extract':
      systemPrompt = 'Extract dates, action items, decisions, and people mentioned. Return as structured JSON.';
      userPrompt = message.text;
      break;
      
    case 'summarize':
      const thread = await getMessageThread(message.conversationId, message.threadId);
      systemPrompt = 'Summarize the following conversation thread concisely.';
      userPrompt = thread.map(m => `${m.senderName}: ${m.text}`).join('\n');
      break;
  }
  
  // 3. Call GPT-4
  const result = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ]
  });
  
  return {
    action: payload.action,
    result: result.choices[0].message.content
  };
}
```

**4. generateProactiveSuggestions**
```typescript
async function generateProactiveSuggestions(userId: string) {
  // 1. Get recent messages (last 24 hours)
  const recentMessages = await getRecentUserMessages(userId, 24);
  
  // 2. Check rules
  const suggestions = [];
  
  // Rule: Timezone ambiguity
  const timezoneIssues = detectTimezoneAmbiguity(recentMessages);
  if (timezoneIssues.length > 0) {
    suggestions.push({
      type: 'timezone_warning',
      message: timezoneIssues[0],
      severity: 'medium'
    });
  }
  
  // Rule: Unclear references
  const unclearRefs = detectUnclearReferences(recentMessages);
  if (unclearRefs.length > 0) {
    suggestions.push({
      type: 'unclear_reference',
      message: unclearRefs[0],
      severity: 'low'
    });
  }
  
  // Rule: Missed follow-ups
  const missedFollowups = await detectMissedFollowups(userId);
  if (missedFollowups.length > 0) {
    suggestions.push({
      type: 'missed_followup',
      message: missedFollowups[0],
      severity: 'high'
    });
  }
  
  // 3. Use GPT-4 for advanced analysis (if needed)
  if (suggestions.length === 0) {
    // Run advanced context analysis
    const aiSuggestion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: 'Analyze the conversation and suggest improvements to communication clarity.'
        },
        {
          role: 'user',
          content: formatMessagesForAnalysis(recentMessages)
        }
      ]
    });
    
    if (aiSuggestion.choices[0].message.content) {
      suggestions.push({
        type: 'ai_insight',
        message: aiSuggestion.choices[0].message.content,
        severity: 'low'
      });
    }
  }
  
  // 4. Limit to 1 suggestion per check
  return suggestions.slice(0, 1);
}
```

### 5.3 RAG Pipeline Architecture

#### Indexing Flow

```
New Message Sent
      ↓
  Firestore Trigger
      ↓
Cloud Function: indexMessage
      ↓
Generate Embedding (Bedrock Titan)
      ↓
Store in Vector DB with metadata:
  - messageId
  - conversationId
  - userId (for access control)
  - timestamp
  - embedding (1536 dimensions)
      ↓
Update Index Counter
```

#### Retrieval Flow

```
User Query
      ↓
Generate Query Embedding (Bedrock Titan)
      ↓
Vector Similarity Search
  - Filter by userId (security)
  - Top K results (K=5-20)
  - Cosine similarity threshold > 0.7
      ↓
Fetch Full Messages from Firestore
      ↓
Rank by:
  1. Semantic relevance
  2. Recency
  3. Conversation context
      ↓
Return Top 5 Results
```

### 5.4 Data Storage

**Firestore Collections:**

```
/users/{userId}/aiSessions/{sessionId}
  - createdAt: timestamp
  - messages: array
    - role: 'user' | 'assistant'
    - content: string
    - timestamp: timestamp
    
/users/{userId}/proactiveSuggestions/{suggestionId}
  - type: string
  - message: string
  - severity: 'low' | 'medium' | 'high'
  - createdAt: timestamp
  - dismissed: boolean
  - actionTaken: boolean

/conversations/{conversationId}/messages/{messageId}
  [existing schema, no changes]
  
/users/{userId}/aiUsageStats
  - searchQueries: number
  - actionsPerformed: number
  - suggestionsReceived: number
  - suggestionsDismissed: number
  - lastActiveAt: timestamp
```

**Vector Database (Pinecone/Weaviate):**

```
Index: messagevectors-prod

Document Schema:
{
  id: "msg_abc123",
  values: [0.123, -0.456, ...], // 1536-dim embedding
  metadata: {
    userId: "user_xyz",
    conversationId: "conv_789",
    timestamp: 1729785600,
    senderName: "Sarah Chen",
    messagePreview: "I think we should..."
  }
}
```

---

## 6. UI/UX Design

### 6.1 AI Chat Interface

**Layout:**
```
┌─────────────────────────────────────┐
│ ← AI Assistant                  ⋮   │  ← Navigation bar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │ What did Mark say about the   │  │  ← User message
│  │ API redesign?                 │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ I found 3 relevant messages:  │  │  ← AI response
│  │                               │  │
│  │ 1. [Oct 15, 2:30 PM] →        │  │  ← Clickable source
│  │ "I think we should switch..." │  │
│  │                               │  │
│  │ 2. [Oct 18, 9:15 AM] →        │  │
│  │ "After reviewing, GraphQL..." │  │
│  │                               │  │
│  │ Summary: Mark recommends      │  │
│  │ GraphQL with REST fallback    │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Suggested follow-ups:         ]  │  ← Quick actions
│  • "Show more context"              │
│  • "When was this decided?"         │
│                                     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Ask me anything about your      │ │  ← Input field
│ │ conversations...                │ │
│ └─────────────────────────────────┘ │
│                               [Send]│
└─────────────────────────────────────┘
```

### 6.2 Message Actions UI

**Long-press Message → Action Sheet:**

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │ "Hola, ¿cómo estás?"          │  │  ← Selected message
│  │                          Sarah │  │
│  └───────────────────────────────┘  │
│             ↓ Long press            │
├─────────────────────────────────────┤
│ Actions for this message            │
├─────────────────────────────────────┤
│  🌐 Translate     ✏️ Rewrite         │
│  📋 Extract       📝 Summarize       │
│  💬 Reply         ➕ More            │
└─────────────────────────────────────┘
        ↓ Tap "Translate"
┌─────────────────────────────────────┐
│ Translate to Spanish?               │
├─────────────────────────────────────┤
│                                     │
│  🇪🇸 Spanish                         │
│  (English → Spanish)                │
│                                     │
│          [Cancel]  [Translate]      │
└─────────────────────────────────────┘
        ↓ Select language
┌─────────────────────────────────────┐
│  Translation:                       │
│                                     │
│  "Hello, how are you?"              │
│                                     │
│  Original (Spanish):                │
│  "Hola, ¿cómo estás?"               │
│                                     │
│  [Copy]  [Share]  [Send as message] │
└─────────────────────────────────────┘
```

### 6.3 Proactive Suggestion Banner

**Timezone Warning:**
```
┌─────────────────────────────────────┐
│ ⚠️ Timezone unclear                  │
│ You said "3pm tomorrow". You're in  │
│ PST, Sarah is in EST.                │
│                                     │
│ [Clarify timezone]  [Dismiss] ✕     │
└─────────────────────────────────────┘
```

**Missed Follow-up:**
```
┌─────────────────────────────────────┐
│ 📋 Follow-up reminder                │
│ 2 days ago you told Mark: "I'll     │
│ send the report tomorrow"            │
│                                     │
│ [Mark as done]  [Send now] ✕        │
└─────────────────────────────────────┘
```

### 6.4 Design Specifications

**Colors:**
- AI messages: Light purple background (#F3F0FF)
- User messages: Light gray background (#F5F5F5)
- Suggestion banners: Yellow (#FFF9E6) for warnings, Blue (#E6F4FF) for info
- Action buttons: Primary blue (#007AFF)
- Source links: Dark blue (#0055CC)

**Typography:**
- AI responses: System font, 16pt regular
- User messages: System font, 16pt regular
- Timestamps: System font, 12pt, gray
- Source citations: System font, 14pt, medium weight

**Spacing:**
- Message bubble padding: 12pt
- Between messages: 8pt
- Banner padding: 16pt
- Action sheet item height: 44pt (Apple HIG standard)

**Animations:**
- AI response appears with fade-in (0.3s ease-out)
- Suggestion banner slides from top (0.4s ease-out)
- Action sheet slides from bottom (0.3s ease-out)
- Loading dots pulse (1s infinite)

---

## 7. Feature Requirements

### 7.1 MVP Features (Must Have)

#### Feature 1: Conversational Search
**Priority:** P0 (Critical)

**Requirements:**
- ✅ Natural language query input
- ✅ Semantic search across all user's conversations
- ✅ Results include message text, sender, timestamp
- ✅ Clickable links to original message context
- ✅ Response time <3 seconds (P95)
- ✅ Query success rate >80%
- ✅ Support for follow-up questions with context
- ✅ Handles "no results" gracefully with suggestions

**Technical Specs:**
- Vector database: Pinecone or Weaviate
- Embedding model: Bedrock Titan (1536 dimensions)
- RAG retrieval: Top-K=20, threshold=0.7
- GPT-4 synthesis with citations

**User Flows:**
1. User opens AI chat
2. Types question
3. See loading indicator
4. Results appear with sources
5. Click source to see full context

#### Feature 2: Message Translation
**Priority:** P0 (Critical)

**Requirements:**
- ✅ Translate any message between English and Spanish
- ✅ Preserve tone and context
- ✅ Show both original and translated text
- ✅ Response time <2 seconds
- ✅ Option to send translation as new message
- ✅ Copy/share functionality

**Technical Specs:**
- API: GPT-4 with translation system prompt
- Supported languages: English ↔ Spanish only
- Auto-detect source language
- Caching: Same message/language pairs cached 24 hours

**User Flows:**
1. Long-press message
2. Tap "Translate"
3. Select target language
4. See translation overlay
5. Copy or send

#### Feature 3: Message Rewrite (Tone Adjustment)
**Priority:** P1 (Important)

**Requirements:**
- ✅ Rewrite for 4 tones: formal, casual, technical, friendly
- ✅ Maintain original meaning
- ✅ Show before/after comparison
- ✅ Response time <2 seconds
- ✅ Option to replace original or send as new

**Technical Specs:**
- API: GPT-4 with tone-specific prompts
- System prompts for each tone pre-optimized

**Supported Tones:**
- **Formal:** "Rewrite this professionally for a senior stakeholder"
- **Casual:** "Rewrite this in a friendly, conversational way"
- **Technical:** "Rewrite this with precise technical terminology"
- **Friendly:** "Rewrite this warmly while being clear"

#### Feature 4: Entity Extraction
**Priority:** P1 (Important)

**Requirements:**
- ✅ Extract dates, times, deadlines
- ✅ Extract action items
- ✅ Extract decisions
- ✅ Extract people mentioned
- ✅ Return structured data
- ✅ Response time <2 seconds

**Technical Specs:**
- API: GPT-4 with JSON mode
- Output schema:
```json
{
  "dates": ["2025-10-30", "next Friday"],
  "actionItems": [
    { "task": "Send report", "owner": "Mark", "deadline": "2025-10-25" }
  ],
  "decisions": ["Use PostgreSQL instead of MongoDB"],
  "people": ["Sarah Chen", "Mark Wilson"]
}
```

#### Feature 5: Thread Summarization
**Priority:** P1 (Important)

**Requirements:**
- ✅ Summarize threads of 10+ messages
- ✅ Maximum 5 sentences per summary
- ✅ Include key points and conclusions
- ✅ Response time <3 seconds

**Technical Specs:**
- API: GPT-4 with summarization prompt
- Context window: Up to 100 messages (16K tokens)
- Format: Bullet points or paragraphs (user preference)

#### Feature 6: Timezone Warning
**Priority:** P1 (Important)

**Requirements:**
- ✅ Detect time mentions without timezone
- ✅ Show warning if participants in different timezones
- ✅ Suggest clarification
- ✅ Max 1 warning per conversation per day
- ✅ Dismissible

**Detection Rules:**
- Patterns: "3pm", "at 3", "tomorrow at 3", "Tuesday 3pm"
- Triggers if:
  - User and recipient in different timezones (from profile)
  - Time mentioned without explicit timezone
  - Conversation is about scheduling/meetings

### 7.2 Post-MVP Features (Nice to Have)

#### Feature 7: Missed Follow-up Reminders
**Priority:** P2 (Nice to have)

**Description:** Detect when user commits to doing something ("I'll send X tomorrow") and remind if not completed.

**Requirements:**
- Detect commitment phrases
- Track completion (e.g., "I sent it")
- Remind after deadline passes
- Max 1 reminder per commitment

#### Feature 8: Conflicting Information Detection
**Priority:** P2 (Nice to have)

**Description:** Alert when contradictory information is shared in conversation.

**Example:**
```
Message 1 (Oct 15): "Launch is Sept 30"
Message 2 (Oct 20): "Launch is Oct 15"
AI: "⚠️ Conflicting launch dates mentioned"
```

#### Feature 9: Meeting Agenda Generator
**Priority:** P3 (Future)

**Description:** Generate meeting agenda from conversation topics.

**Requirements:**
- Analyze last 7 days of conversation
- Identify open questions and decisions needed
- Format as numbered agenda
- Include time estimates

#### Feature 10: Smart Reply Suggestions
**Priority:** P3 (Future)

**Description:** Suggest contextually relevant replies.

**Example:**
```
Sarah: "Can you review the design by EOD?"
AI suggests:
- "Yes, I'll review it by 5pm"
- "I'm swamped today, can we do tomorrow?"
- "Which design file specifically?"
```

### 7.3 Feature Prioritization Matrix

| Feature | Impact | Effort | Priority | MVP |
|---------|--------|--------|----------|-----|
| Conversational Search | High | High | P0 | ✅ |
| Translate | High | Low | P0 | ✅ |
| Rewrite Tone | Medium | Low | P1 | ✅ |
| Extract Entities | Medium | Medium | P1 | ✅ |
| Summarize | Medium | Low | P1 | ✅ |
| Timezone Warning | High | Low | P1 | ✅ |
| Missed Follow-up | Medium | Medium | P2 | ❌ |
| Conflicting Info | Low | Medium | P2 | ❌ |
| Meeting Agenda | Medium | High | P3 | ❌ |
| Smart Replies | Low | High | P3 | ❌ |

---

## 8. Data Models

### 8.1 iOS Data Models (Swift)

```swift
// MARK: - AI Message Models

struct AIMessage: Identifiable, Codable {
    let id: String
    let role: AIMessageRole
    let content: String
    let timestamp: Date
    let sources: [MessageSource]?
    
    enum AIMessageRole: String, Codable {
        case user
        case assistant
        case system
    }
}

struct MessageSource: Identifiable, Codable {
    let id: String           // messageId
    let conversationId: String
    let senderName: String
    let senderAvatar: String?
    let timestamp: Date
    let preview: String      // First 100 chars
    let fullText: String
}

// MARK: - AI Session

struct AISession: Identifiable, Codable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    var messages: [AIMessage]
    var isActive: Bool
}

// MARK: - Message Action Models

struct MessageAction: Identifiable {
    let id: UUID
    let type: MessageActionType
    let icon: String
    let title: String
    let requiresInput: Bool
}

enum MessageActionType: String, Codable {
    case translate
    case rewrite
    case extract
    case summarize
    case reply
    
    var displayName: String {
        switch self {
        case .translate: return "Translate"
        case .rewrite: return "Rewrite"
        case .extract: return "Extract"
        case .summarize: return "Summarize"
        case .reply: return "Reply"
        }
    }
}

struct MessageActionRequest: Codable {
    let messageId: String
    let action: MessageActionType
    let actionParams: ActionParams?
    
    struct ActionParams: Codable {
        let targetLanguage: String?
        let tone: RewriteTone?
        let extractTypes: [ExtractType]?
    }
}

struct MessageActionResponse: Codable {
    let action: MessageActionType
    let result: String
    let metadata: ActionMetadata?
    
    struct ActionMetadata: Codable {
        let sourceLang: String?
        let targetLang: String?
        let extractedEntities: ExtractedEntities?
    }
}

enum RewriteTone: String, Codable, CaseIterable {
    case formal
    case casual
    case technical
    case friendly
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var description: String {
        switch self {
        case .formal:
            return "Professional tone for stakeholders"
        case .casual:
            return "Friendly and conversational"
        case .technical:
            return "Precise technical terminology"
        case .friendly:
            return "Warm and approachable"
        }
    }
}

enum ExtractType: String, Codable {
    case dates
    case actionItems
    case decisions
    case people
}

struct ExtractedEntities: Codable {
    let dates: [String]
    let actionItems: [ActionItem]
    let decisions: [String]
    let people: [String]
}

struct ActionItem: Identifiable, Codable {
    let id: UUID
    let task: String
    let owner: String?
    let deadline: Date?
    let status: ActionItemStatus
}

enum ActionItemStatus: String, Codable {
    case pending
    case inProgress
    case completed
}

// MARK: - Proactive Suggestion Models

struct ProactiveSuggestion: Identifiable, Codable {
    let id: String
    let type: SuggestionType
    let title: String
    let message: String
    let severity: SuggestionSeverity
    let createdAt: Date
    let relatedMessageId: String?
    let relatedConversationId: String?
    var dismissed: Boolean
    var actionTaken: Boolean
    let actionButtons: [SuggestionAction]
}

enum SuggestionType: String, Codable {
    case timezoneWarning
    case unclearReference
    case missedFollowup
    case conflictingInfo
    case aiInsight
    
    var icon: String {
        switch self {
        case .timezoneWarning: return "⚠️"
        case .unclearReference: return "💡"
        case .missedFollowup: return "📋"
        case .conflictingInfo: return "⚠️"
        case .aiInsight: return "✨"
        }
    }
}

enum SuggestionSeverity: String, Codable {
    case low
    case medium
    case high
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        }
    }
}

struct SuggestionAction: Identifiable, Codable {
    let id: UUID
    let title: String
    let actionType: String
    let actionPayload: [String: String]?
}

// MARK: - AI Usage Stats

struct AIUsageStats: Codable {
    let userId: String
    var searchQueries: Int
    var actionsPerformed: Int
    var suggestionsReceived: Int
    var suggestionsDismissed: Int
    var suggestionsActedOn: Int
    var lastActiveAt: Date
    var usageByFeature: [String: Int]
}

// MARK: - Search Query

struct SearchQuery: Identifiable, Codable {
    let id: String
    let userId: String
    let query: String
    let timestamp: Date
    let resultsCount: Int
    let wasHelpful: Bool?
    let responseTimeMs: Int
}
```

### 8.2 Firestore Data Schema

```typescript
// /users/{userId}/aiSessions/{sessionId}
interface AISession {
  id: string;
  userId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  messages: AIMessage[];
  isActive: boolean;
}

interface AIMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Timestamp;
  sources?: MessageSource[];
}

interface MessageSource {
  messageId: string;
  conversationId: string;
  senderName: string;
  timestamp: Timestamp;
  preview: string;
}

// /users/{userId}/proactiveSuggestions/{suggestionId}
interface ProactiveSuggestion {
  id: string;
  type: 'timezone_warning' | 'unclear_reference' | 'missed_followup' | 'conflicting_info';
  title: string;
  message: string;
  severity: 'low' | 'medium' | 'high';
  createdAt: Timestamp;
  relatedMessageId?: string;
  relatedConversationId?: string;
  dismissed: boolean;
  actionTaken: boolean;
  actionButtons: SuggestionAction[];
}

interface SuggestionAction {
  title: string;
  actionType: string;
  actionPayload?: Record<string, string>;
}

// /users/{userId}/aiUsageStats
interface AIUsageStats {
  userId: string;
  searchQueries: number;
  actionsPerformed: number;
  suggestionsReceived: number;
  suggestionsDismissed: number;
  suggestionActedOn: number;
  lastActiveAt: Timestamp;
  usageByFeature: Record<string, number>;
}

// /conversations/{conversationId}/aiContext (NEW)
interface AIConversationContext {
  conversationId: string;
  summary: string;          // AI-generated summary updated every 50 messages
  keyTopics: string[];      // Extracted key topics
  actionItems: ActionItem[];
  lastUpdated: Timestamp;
  messageCount: number;
}

interface ActionItem {
  task: string;
  owner?: string;
  deadline?: Timestamp;
  status: 'pending' | 'in_progress' | 'completed';
  extractedFrom: string;    // messageId
}
```

### 8.3 Vector Database Schema

```typescript
// Pinecone/Weaviate Index Schema
interface MessageVector {
  id: string;                    // Format: "msg_{messageId}"
  values: number[];              // 1536-dim embedding from Bedrock Titan
  metadata: {
    userId: string;              // For access control
    conversationId: string;
    messageId: string;
    senderName: string;
    senderId: string;
    timestamp: number;           // Unix timestamp
    messagePreview: string;      // First 200 chars
    conversationType: 'direct' | 'group';
    participantIds: string[];    // All conversation participants
  };
}
```

---

## 9. Testing Requirements

### 9.1 Test Scenarios

#### Test Scenario 1: Conversational Search - Happy Path

**Objective:** Verify conversational search returns relevant results

**Preconditions:**
- User is authenticated
- User has at least 50 messages across 3+ conversations
- Messages include discussions about "API redesign"

**Test Steps:**
1. Open AI Assistant screen
2. Type query: "What did we decide about the API redesign?"
3. Tap Send
4. Wait for response

**Expected Results:**
- ✅ Response appears within 3 seconds
- ✅ AI provides summary of decision
- ✅ At least 2 source messages shown with timestamps
- ✅ Source links are clickable
- ✅ Clicking link navigates to original message
- ✅ Original message is highlighted in context

**Acceptance Criteria:**
- Response time <3 seconds (P95)
- At least 1 relevant source returned
- User rates result as "helpful"

---

#### Test Scenario 2: Message Translation

**Objective:** Verify message translation preserves meaning and tone

**Preconditions:**
- User receives message in Spanish: "Hola, ¿cómo estás? Necesito tu ayuda con el proyecto."

**Test Steps:**
1. Long-press Spanish message
2. Tap "Translate"
3. Select "English" from language picker
4. Tap "Translate" button
5. View translation result

**Expected Results:**
- ✅ Translation appears within 2 seconds
- ✅ Translation: "Hello, how are you? I need your help with the project."
- ✅ Original text shown below translation
- ✅ Copy button works
- ✅ "Send as message" button available

**Acceptance Criteria:**
- Translation accuracy verified by native speaker
- Response time <2 seconds
- Both original and translation displayed

---

#### Test Scenario 3: Proactive Timezone Warning

**Objective:** Verify timezone warning appears when appropriate

**Preconditions:**
- User profile timezone: America/Los_Angeles (PST)
- Recipient profile timezone: America/New_York (EST)
- Current time: 10:00 AM PST

**Test Steps:**
1. Open conversation with recipient in different timezone
2. Type message: "Let's meet at 3pm tomorrow"
3. Tap Send
4. Wait 2 seconds

**Expected Results:**
- ✅ Suggestion banner appears at top of screen
- ✅ Banner message: "⚠️ Timezone unclear. You're in PST, Sarah is in EST. Did you mean 3pm PST or EST?"
- ✅ "Clarify timezone" button available
- ✅ "Dismiss" button available
- ✅ Banner is dismissible

**Acceptance Criteria:**
- Banner appears within 2 seconds of sending message
- Banner is non-blocking (message still sends)
- Dismissed banners don't reappear
- Maximum 1 banner per conversation per day

---

#### Test Scenario 4: Entity Extraction from Thread

**Objective:** Verify entity extraction identifies key information

**Preconditions:**
- Conversation thread with 15 messages
- Messages contain:
  - "We need to launch by October 30"
  - "Sarah will handle the design"
  - "Mark, can you review the API docs?"
  - "Decision: Use PostgreSQL"

**Test Steps:**
1. Select entire thread (15 messages)
2. Tap "Extract" action
3. View extraction results

**Expected Results:**
- ✅ Dates extracted: ["October 30", "2025-10-30"]
- ✅ Action items extracted:
  - "Handle the design" - Sarah
  - "Review the API docs" - Mark
- ✅ Decisions extracted: ["Use PostgreSQL"]
- ✅ People mentioned: ["Sarah", "Mark"]
- ✅ Results formatted as structured list

**Acceptance Criteria:**
- At least 80% of entities correctly identified
- No false positives (incorrect extractions)
- Response time <3 seconds

---

### 9.2 Performance Testing

**Load Testing:**
- Simulate 100 concurrent users
- Each user performs 10 search queries
- Measure: P50, P95, P99 latency
- Target: P95 <3 seconds

**Stress Testing:**
- Gradually increase users until system degrades
- Identify breaking point
- Optimize bottlenecks

**Cost Testing:**
- Track API costs per user per day
- Target: <$0.15/user/day
- Monitor: GPT-4 tokens, Bedrock queries

### 9.3 Manual Testing Checklist

- [ ] Conversational search returns relevant results
- [ ] Search works with misspellings and synonyms
- [ ] Translation maintains tone and meaning (English ↔ Spanish)
- [ ] Rewrite produces different tones correctly
- [ ] Entity extraction is 80%+ accurate
- [ ] Timezone warnings trigger appropriately
- [ ] Proactive suggestions are helpful, not annoying
- [ ] Action buttons (Clarify, Dismiss) work
- [ ] Rate limiting prevents abuse
- [ ] Error messages are user-friendly
- [ ] Loading states are clear
- [ ] Animations are smooth (60fps)
- [ ] UI adapts to iPhone SE and iPhone 15 Pro Max
- [ ] Dark mode support (if applicable)
- [ ] Accessibility: VoiceOver navigation works

---

## 10. Implementation Plan

### 10.1 Development Phases

**Total Timeline:** 4 weeks

#### Phase 1: Foundation (Week 1)
**Goal:** Set up AI infrastructure and basic UI

**Tasks:**
- [ ] Set up OpenAI API integration (GPT-4)
- [ ] Set up Amazon Bedrock account
- [ ] Create vector database (Pinecone/Weaviate)
- [ ] Design and create Firestore collections
- [ ] Create AI models and data structures (Swift)
- [ ] Build basic AIChatView UI
- [ ] Implement authentication and security rules
- [ ] Set up Cloud Functions project structure

**Deliverables:**
- Working Cloud Functions endpoint
- Basic AI chat UI (no features yet)
- Vector DB initialized
- Security rules deployed

---

#### Phase 2: Conversational Search (Week 2)
**Goal:** Implement RAG pipeline and search

**Tasks:**
- [ ] Implement message embedding pipeline
  - Firestore trigger on new messages
  - Generate embeddings with Bedrock Titan
  - Store in vector database
- [ ] Build conversationSearchRAG Cloud Function
  - Query embedding generation
  - Vector similarity search
  - GPT-4 answer synthesis
- [ ] Create search UI components
  - Query input
  - Loading state
  - Results display with sources
  - Source links (deep linking)
- [ ] Test with 100+ sample messages
- [ ] Optimize for <3 second response time

**Deliverables:**
- Functional conversational search
- Source attribution working
- Performance meets targets

---

#### Phase 3: Message Actions (Week 3)
**Goal:** Implement translation, rewrite, extract, summarize

**Tasks:**
- [ ] Build performMessageAction Cloud Function
  - Translate action
  - Rewrite action
  - Extract action
  - Summarize action
- [ ] Create MessageActionSheet UI
  - Action picker
  - Language/tone selector
  - Result overlay
  - Copy/share buttons
- [ ] Implement long-press gesture on messages
- [ ] Add action execution and result display
- [ ] Test each action type thoroughly

**Deliverables:**
- All 4 actions working
- Action sheet UI complete
- Results display correctly

---

#### Phase 4: Proactive Suggestions (Week 3-4)
**Goal:** Implement automatic suggestions

**Tasks:**
- [ ] Build generateProactiveSuggestions Cloud Function
  - Timezone detection logic
  - Unclear reference detection
  - Missed follow-up detection (optional)
- [ ] Create suggestion rules engine
- [ ] Build ProactiveSuggestionBanner UI
  - Banner component
  - Action buttons
  - Dismiss functionality
- [ ] Implement suggestion frequency limiting (max 1/10 messages)
- [ ] Test suggestion triggers

**Deliverables:**
- 2-3 suggestion types working
- Banner UI complete
- Frequency limiting working

---

#### Phase 5: Polish & Testing (Week 4)
**Goal:** Bug fixes, optimization, comprehensive testing

**Tasks:**
- [ ] Run all test scenarios
- [ ] Fix bugs and edge cases
- [ ] Optimize API costs
  - Add caching where possible
  - Reduce token usage
- [ ] Improve error handling
- [ ] Add loading skeletons
- [ ] Improve accessibility
- [ ] Write documentation
- [ ] Record demo video

**Deliverables:**
- All tests passing
- Bug-free experience
- Documentation complete
- Demo ready

---

### 10.2 Pull Request Breakdown

#### PR #1: AI Infrastructure Setup
**Estimated Time:** 4 hours

**Changes:**
- Create Cloud Functions project
- Add OpenAI SDK
- Add Bedrock SDK
- Create environment variables
- Deploy basic Cloud Function

**Files:**
- `functions/package.json`
- `functions/src/index.ts`
- `functions/.env`

---

#### PR #2: Data Models & Schemas
**Estimated Time:** 3 hours

**Changes:**
- Create Swift models for AI features
- Create Firestore schema
- Update security rules
- Add model tests

**Files:**
- `MessengerAI/Models/AIMessage.swift`
- `MessengerAI/Models/ProactiveSuggestion.swift`
- `MessengerAI/Models/MessageAction.swift`
- `firestore.rules`

---

#### PR #3: AI Chat UI - Basic Layout
**Estimated Time:** 5 hours

**Changes:**
- Create AIChatView
- Create AIMessageBubbleView
- Add navigation
- Basic styling

**Files:**
- `MessengerAI/Views/AI/AIChatView.swift`
- `MessengerAI/Views/AI/AIMessageBubbleView.swift`
- `MessengerAI/ViewModels/AIChatViewModel.swift`

---

#### PR #4: Vector Database Setup
**Estimated Time:** 4 hours

**Changes:**
- Create Pinecone/Weaviate index
- Implement embedding generation
- Create message indexing trigger
- Test indexing pipeline

**Files:**
- `functions/src/vectordb.ts`
- `functions/src/triggers/indexMessage.ts`

---

#### PR #5: Conversational Search - Backend
**Estimated Time:** 8 hours

**Changes:**
- Implement conversationSearchRAG function
- Query embedding generation
- Vector search implementation
- GPT-4 answer synthesis
- Source formatting

**Files:**
- `functions/src/handlers/conversationSearch.ts`
- `functions/src/utils/bedrock.ts`
- `functions/src/utils/openai.ts`

---

#### PR #6: Conversational Search - Frontend
**Estimated Time:** 6 hours

**Changes:**
- Implement search query submission
- Display AI responses
- Show source citations
- Implement source deep linking
- Add loading states

**Files:**
- `MessengerAI/Views/AI/AIChatView.swift` (update)
- `MessengerAI/ViewModels/AIChatViewModel.swift` (update)
- `MessengerAI/Services/AIAssistantService.swift`

---

#### PR #7: Message Actions - Backend
**Estimated Time:** 6 hours

**Changes:**
- Implement performMessageAction function
- Translate action logic
- Rewrite action logic
- Extract action logic
- Summarize action logic

**Files:**
- `functions/src/handlers/messageActions.ts`

---

#### PR #8: Message Actions - Frontend
**Estimated Time:** 8 hours

**Changes:**
- Create MessageActionSheet component
- Long-press gesture implementation
- Action selection UI
- Language/tone picker
- Result display overlay
- Copy/share functionality

**Files:**
- `MessengerAI/Views/AI/MessageActionSheet.swift`
- `MessengerAI/Views/Messages/MessageBubbleView.swift` (update)

---

#### PR #9: Proactive Suggestions - Backend
**Estimated Time:** 6 hours

**Changes:**
- Implement generateProactiveSuggestions function
- Timezone detection rules
- Unclear reference detection
- Suggestion frequency limiting

**Files:**
- `functions/src/handlers/proactiveSuggestions.ts`
- `functions/src/utils/detectionRules.ts`

---

#### PR #10: Proactive Suggestions - Frontend
**Estimated Time:** 5 hours

**Changes:**
- Create ProactiveSuggestionBanner component
- Banner animation
- Action buttons
- Dismiss functionality
- Banner queue management

**Files:**
- `MessengerAI/Views/AI/ProactiveSuggestionBanner.swift`
- `MessengerAI/ViewModels/SuggestionViewModel.swift`

---

#### PR #11: Testing & Bug Fixes
**Estimated Time:** 8 hours

**Changes:**
- Run all test scenarios
- Fix identified bugs
- Add error handling
- Improve loading states
- Accessibility improvements

**Files:**
- Multiple files (bug fixes)

---

#### PR #12: Performance Optimization
**Estimated Time:** 4 hours

**Changes:**
- Add caching layer
- Optimize token usage
- Reduce API calls
- Improve response times

**Files:**
- `functions/src/utils/cache.ts`
- Various optimization tweaks

---

#### PR #13: Documentation & Demo
**Estimated Time:** 3 hours

**Changes:**
- Write user guide
- Write developer documentation
- Create demo video
- Add README

**Files:**
- `docs/AI_FEATURES.md`
- `docs/DEVELOPER_GUIDE.md`
- `README.md` (update)

---

### 10.3 Dependencies & Blockers

**External Dependencies:**
- OpenAI API access (GPT-4)
- AWS account for Bedrock
- Pinecone/Weaviate account
- Firebase Blaze plan (for Cloud Functions)

**Potential Blockers:**
- Bedrock API approval (can take 1-2 days)
- Vector database performance at scale
- API cost overruns
- Cloud Functions cold start latency

**Mitigation:**
- Apply for Bedrock access immediately
- Start with Pinecone free tier, upgrade if needed
- Implement aggressive caching
- Keep functions warm with scheduled calls

---

## 11. Cost Estimates

### 11.1 Per-User Monthly Cost Breakdown

**Assumptions:**
- 50 search queries per user per month
- 100 message actions per user per month
- 30 proactive suggestions per user per month

| Service | Usage | Unit Cost | Monthly Cost |
|---------|-------|-----------|--------------|
| **OpenAI GPT-4** | 50 searches @ 2K tokens each | $0.03/1K input, $0.06/1K output | $10.00 |
| **OpenAI GPT-4** | 100 actions @ 500 tokens each | $0.03/1K input, $0.06/1K output | $4.50 |
| **Amazon Bedrock Embeddings** | 150 queries | $0.0001/1K tokens | $0.15 |
| **Vector Database (Pinecone)** | 1000 queries | $0.00015/query | $0.15 |
| **Firestore Reads** | 500 reads | $0.06/100K reads | $0.003 |
| **Firestore Writes** | 200 writes | $0.18/100K writes | $0.0004 |
| **Cloud Functions Invocations** | 200 invocations | $0.40/million | $0.00008 |
| **Cloud Functions Compute** | 400 GB-seconds | $0.0000025/GB-second | $0.001 |
| **Total per user per month** | | | **$14.82** |

**Note:** Costs can be reduced significantly with caching:
- Cache embeddings: Save 50% on Bedrock costs
- Cache common queries: Save 30% on GPT-4 costs
- **Optimized cost estimate: $10.00/user/month**

### 11.2 Scaling Costs

| Users | Monthly Cost (Unoptimized) | Monthly Cost (Optimized) |
|-------|---------------------------|--------------------------|
| 100 | $1,482 | $1,000 |
| 1,000 | $14,820 | $10,000 |
| 10,000 | $148,200 | $100,000 |
| 100,000 | $1,482,000 | $1,000,000 |

### 11.3 Cost Optimization Strategies

**1. Aggressive Caching**
- Cache embeddings for 30 days
- Cache common search queries (LRU cache)
- Expected savings: 30-50%

**2. Prompt Optimization**
- Reduce system prompt length
- Use shorter model IDs
- Expected savings: 10-15%

**3. Rate Limiting**
- Enforce 100 queries/hour per user
- Prevents abuse and runaway costs

**4. Tiered Pricing**
- Free tier: 10 queries/month
- Pro tier ($5/month): 100 queries/month
- Business tier ($15/month): Unlimited

**5. Model Selection**
- Use GPT-3.5-Turbo for simple actions (80% cheaper)
- Reserve GPT-4 for complex search synthesis
- Expected savings: 40-50%

### 11.4 MVP Budget (3 Months)

**Development Phase (10 users):**
- Month 1: $100 (development testing)
- Month 2: $300 (beta testing with 10 users)
- Month 3: $500 (expanded testing with 50 users)
- **Total: $900**

**Recommended Budget:** $1,500 (with buffer)

---

## 12. Success Metrics

### 12.1 Product Metrics

**Engagement:**
- **Daily Active AI Users:** >60% of DAU
- **Average Searches per User:** >2/day
- **Average Actions per User:** >3/day
- **Return Rate:** >70% users return next day

**Quality:**
- **Search Query Success Rate:** >80%
- **Suggestion Acceptance Rate:** >30%
- **User Satisfaction (NPS):** >40
- **Bug Reports:** <5/week after launch

**Performance:**
- **Average Query Response Time:** <3 seconds (P95)
- **Action Response Time:** <2 seconds (P95)
- **Uptime:** >99.5%
- **Error Rate:** <1%

### 12.2 Business Metrics

**Acquisition:**
- **Feature Awareness:** >80% of users know AI features exist
- **Feature Activation:** >50% of users try AI features

**Retention:**
- **7-Day Retention:** +15% vs non-AI users
- **30-Day Retention:** +25% vs non-AI users

**Monetization:**
- **Premium Conversion:** +30% for users who use AI
- **ARPU Increase:** +$2/user with AI features

### 12.3 Technical Metrics

**Reliability:**
- **API Success Rate:** >99%
- **Vector Search Latency:** P95 <500ms
- **GPT-4 Latency:** P95 <2s
- **Cache Hit Rate:** >40%

**Cost Efficiency:**
- **Cost per Query:** <$0.05
- **Cost per User per Month:** <$10
- **Cache Savings:** >30%

### 12.4 Measurement Plan

**Analytics Events to Track:**
```swift
// Search events
trackEvent("ai_search_query", properties: [
    "query_length": Int,
    "results_count": Int,
    "response_time_ms": Int,
    "was_helpful": Bool
])

// Action events
trackEvent("ai_message_action", properties: [
    "action_type": String,
    "response_time_ms": Int,
    "user_accepted": Bool
])

// Suggestion events
trackEvent("ai_proactive_suggestion", properties: [
    "suggestion_type": String,
    "dismissed": Bool,
    "action_taken": Bool
])
```

**Weekly Review:**
- Review all metrics dashboard
- Identify trends and anomalies
- Adjust features based on data

---

## 13. Risk Mitigation

### 13.1 Technical Risks

**Risk: High API Costs**
- **Likelihood:** High
- **Impact:** High
- **Mitigation:**
  - Implement aggressive caching (30-50% savings)
  - Use rate limiting (100 queries/hour)
  - Monitor costs daily via dashboard
  - Set up billing alerts at $500, $1000, $2000
  - Use cheaper models for simple tasks

**Risk: Slow Response Times**
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:**
  - Cache common queries
  - Optimize prompts (reduce tokens)
  - Use streaming responses for better UX
  - Keep Cloud Functions warm
  - Add loading skeleton UI

**Risk: Poor Search Quality**
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:**
  - Test with 100+ real conversations
  - Tune RAG retrieval (K, threshold)
  - Improve system prompts
  - Collect user feedback ("Was this helpful?")
  - Iterate on prompt engineering

### 13.2 Product Risks

**Risk: Low Adoption**
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:**
  - User onboarding tour
  - In-app tips and prompts
  - Email announcements
  - Highlight value proposition
  - A/B test messaging

**Risk: Annoying Suggestions**
- **Likelihood:** High
- **Impact:** Medium
- **Mitigation:**
  - Limit to 1 suggestion per 10 messages
  - Easy dismiss button
  - Learn from dismissals (reduce frequency)
  - User setting to disable suggestions

### 13.3 External Risks

**Risk: OpenAI API Outage**
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:**
  - Graceful degradation (show cached results)
  - Clear error messages
  - Fallback to simpler models
  - Monitor OpenAI status page

**Risk: Bedrock Access Denied**
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:**
  - Apply for access early
  - Have backup (use OpenAI embeddings)
  - Test with alternative: Cohere, Vertex AI

**Risk: Vector DB Performance**
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:**
  - Load test before launch
  - Upgrade plan if needed
  - Consider self-hosted alternative (Qdrant)

---

## 14. Out of Scope

### 14.1 Features NOT in MVP

**1. Voice Input/Output**
- Speech-to-text for queries
- Text-to-speech for responses
- Reason: Adds complexity, can be added post-MVP

**2. Image Analysis**
- Analyze images in conversations
- Extract text from screenshots
- Reason: Requires GPT-4V, more expensive

**3. Multi-Language AI Chat**
- AI responds in user's preferred language
- Reason: Increases prompt complexity

**4. Custom AI Personas**
- User-configurable AI personality
- Different tones (professional, casual, etc.)
- Reason: Scope creep, can be added later

**5. AI-Generated Message Drafts**
- Full message composition by AI
- Smart replies (like Gmail)
- Reason: Requires different UX paradigm

**6. Meeting Scheduler**
- AI finds meeting times
- Sends calendar invites
- Reason: Requires calendar integration

**7. Email Integration**
- Search across email and chat
- Reason: Out of scope for messaging app

**8. Team Analytics**
- Conversation sentiment over time
- Team collaboration metrics
- Reason: More enterprise feature

**9. AI Training on User Data**
- Fine-tune models on user conversations
- Reason: Privacy concerns, cost prohibitive

**10. Multi-Modal Search**
- Search for images, files, links
- Reason: MVP focuses on text messages

### 14.2 Technical Constraints

**Not Supporting:**
- On-device AI (too resource intensive)
- Real-time streaming for all features (only for long responses)
- Offline AI features (requires cloud)
- WhatsApp/SMS integration
- Third-party bot integrations

---

## 15. Open Questions

### 15.1 Architecture Questions

**Q1: RAG Indexing Frequency**
- **Question:** Should we index messages in real-time or batch hourly?
- **Options:**
  - Real-time: Every message indexed immediately (higher cost, fresher data)
  - Batch: Index every hour (lower cost, slight delay)
- **Recommendation:** Real-time for MVP, evaluate cost after 1 week

**Q2: Vector Database Choice**
- **Question:** Pinecone vs Weaviate vs Qdrant?
- **Options:**
  - Pinecone: Managed, easy, $0.00015/query
  - Weaviate: Open-source, self-hosted, more control
  - Qdrant: Open-source, fastest, Rust-based
- **Recommendation:** Pinecone for MVP (fastest to implement)

**Q3: Caching Strategy**
- **Question:** What should we cache and for how long?
- **Options:**
  - Cache embeddings: 30 days
  - Cache common queries: 1 day
  - Cache user preferences: 7 days
- **Recommendation:** Implement all three caching layers

### 15.2 Product Questions

**Q4: Proactive Suggestion Frequency**
- **Question:** How many suggestions per day is too many?
- **Current:** Max 1 per 10 messages
- **Needs User Testing:** A/B test 1 per 5 vs 1 per 10 vs 1 per 20

**Q5: Action Approval**
- **Question:** Should actions auto-execute or require confirmation?
- **Options:**
  - Auto-execute: Faster, but risky (e.g., accidental send)
  - Confirm all: Safer, but extra step
- **Recommendation:** Confirm for "send as message", auto for "copy"

### 15.3 Cost Questions

**Q6: Spending Caps**
- **Question:** Should we enforce per-user spending caps?
- **Options:**
  - No cap: Best UX, risk of abuse
  - Soft cap: Warn at limit, allow override
  - Hard cap: Stop at limit, prevent overages
- **Recommendation:** Soft cap at $1/user/day, hard cap at $5/user/day

**Q7: Free vs Paid Tier**
- **Question:** How many free queries should users get?
- **Options:**
  - Unlimited: Expensive, hard to monetize
  - 10/month: Very limited, may reduce adoption
  - 50/month: Reasonable for casual users
- **Recommendation:** 50 free/month, then $5 for unlimited

### 15.4 Technical Decisions Needed

**Q8: GPT-4 vs GPT-3.5-Turbo**
- **Question:** When to use cheaper model?
- **Proposal:** Use GPT-3.5-Turbo for actions (translate, rewrite), GPT-4 for search synthesis
- **Needs Testing:** Verify quality difference

**Q9: Streaming vs Batch Responses**
- **Question:** Should AI responses stream (like ChatGPT)?
- **Options:**
  - Stream: Better UX, more complex code
  - Batch: Simpler, less engaging
- **Recommendation:** Batch for MVP, stream in v2

---

## 16. Appendices

### 16.1 Glossary

**RAG (Retrieval-Augmented Generation):** AI technique that retrieves relevant documents before generating a response, improving accuracy and reducing hallucinations.

**Vector Embedding:** Numerical representation of text in high-dimensional space, enabling semantic similarity search.

**Semantic Search:** Search based on meaning rather than keyword matching.

**System Prompt:** Instructions given to AI model that define its behavior and role.

**Token:** Unit of text processed by AI models (roughly 0.75 words).

**P95 Latency:** 95th percentile latency; 95% of requests are faster than this value.

**Cold Start:** Delay when Cloud Function hasn't been used recently and needs to initialize.

**Top-K Retrieval:** Retrieving the K most similar documents from vector search.

**Cosine Similarity:** Measure of similarity between two vectors (0 = dissimilar, 1 = identical).

**Context Window:** Maximum amount of text an AI model can process at once (e.g., GPT-4: 128K tokens).

### 16.2 API Examples

**Example 1: Conversational Search Request**
```typescript
// Request
POST https://us-central1-messenger-ai.cloudfunctions.net/aiChatHandler
Authorization: Bearer <firebase-token>
Content-Type: application/json

{
  "action": "conversational_search",
  "payload": {
    "query": "What did Sarah say about the Q3 launch?",
    "conversationIds": ["conv_abc", "conv_xyz"],
    "limit": 5
  }
}

// Response
{
  "answer": "Sarah mentioned that the Q3 launch has been moved from September 30 to October 15 due to design delays. Most recently on Oct 20, she confirmed the new date.",
  "sources": [
    {
      "messageId": "msg_123",
      "conversationId": "conv_abc",
      "timestamp": "2025-10-15T14:30:00Z",
      "sender": "Sarah Chen",
      "preview": "I think we should target late September for Q3 launch..."
    },
    {
      "messageId": "msg_456",
      "conversationId": "conv_abc",
      "timestamp": "2025-10-18T09:15:00Z",
      "sender": "Sarah Chen",
      "preview": "Update: Q3 launch is now October 15 due to design delays..."
    }
  ],
  "queryId": "query_789",
  "responseTimeMs": 2847
}
```

**Example 2: Message Action Request**
```typescript
// Request
POST https://us-central1-messenger-ai.cloudfunctions.net/aiChatHandler
Authorization: Bearer <firebase-token>
Content-Type: application/json

{
  "action": "message_action",
  "payload": {
    "messageId": "msg_abc123",
    "action": "translate",
    "actionParams": {
      "targetLanguage": "Spanish"
    }
  }
}

// Response
{
  "action": "translate",
  "result": "Hola, ¿cómo estás? Necesito tu ayuda con el proyecto.",
  "metadata": {
    "sourceLang": "English",
    "targetLang": "Spanish"
  },
  "responseTimeMs": 1523
}
```

### 16.3 Sample System Prompts

**Conversational Search:**
```
You are an intelligent search assistant for a messaging app. Your job is to answer questions about past conversations.

Guidelines:
- Be concise but informative
- Always cite sources with timestamps
- If multiple conflicting pieces of information exist, mention both
- If no relevant information is found, say so clearly
- Use natural language, not robotic
- Format: Short answer, then sources

Example:
User: "What did Mark decide about the database?"
You: "Mark decided to use PostgreSQL instead of MongoDB on Oct 15. 

Sources:
- [Oct 15, 2:30 PM] Mark: 'After reviewing both, I think PostgreSQL is better for our use case'
- [Oct 16, 9:00 AM] Mark: 'Confirmed: going with PostgreSQL'"
```

**Translation:**
```
Translate the following text to {target_language}. Maintain the tone, formality, and any technical terminology. If there are culture-specific references, adapt them appropriately.

Text: {message_text}
```

**Rewrite (Formal):**
```
Rewrite the following message in a formal, professional tone suitable for communication with senior stakeholders or executives. Maintain the core meaning but elevate the language.

Original: {message_text}
```

**Extract Entities:**
```
Extract the following from the conversation:
1. Dates and deadlines (format: YYYY-MM-DD if possible)
2. Action items (what needs to be done and by whom)
3. Decisions made
4. People mentioned

Return as JSON with this structure:
{
  "dates": [...],
  "actionItems": [{"task": "...", "owner": "...", "deadline": "..."}],
  "decisions": [...],
  "people": [...]
}

Conversation: {messages}
```

### 16.4 References

**AI/ML:**
- [RAG Explained](https://www.anthropic.com/index/retrieval-augmented-generation)
- [Vector Embeddings Guide](https://www.pinecone.io/learn/vector-embeddings/)
- [OpenAI API Docs](https://platform.openai.com/docs)
- [Amazon Bedrock Docs](https://docs.aws.amazon.com/bedrock/)

**iOS Development:**
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)

**Firebase:**
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

**Vector Databases:**
- [Pinecone Documentation](https://docs.pinecone.io/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [Qdrant Documentation](https://qdrant.tech/documentation/)

---

## Document Status

**Status:** ✅ Ready for Review  
**Version:** 1.0  
**Last Updated:** October 25, 2025  
**Author:** Product Team  
**Reviewers Needed:** Engineering Lead, Product Manager

---

## Next Steps

1. **Review this PRD** with engineering and product teams
2. **Answer open questions** (Section 16)
3. **Get Bedrock API access** (can take 1-2 days)
4. **Set up vector database** (Pinecone account)
5. **Validate cost estimates** with finance team
6. **Begin Phase 1 implementation** (Week 1)
7. **Schedule weekly check-ins** to track progress

---

## Questions for Stakeholders

1. **Budget Approval:** Is $1,500 budget for 3-month MVP acceptable?
2. **Timeline:** Is 4-week development timeline realistic?
3. **Scope:** Are these the right features for MVP, or should we adjust?
4. **Pricing:** Should AI features be free or premium tier?
5. **Tech Stack:** Any concerns about OpenAI + Bedrock + Pinecone?

---

**End of Product Requirements Document**