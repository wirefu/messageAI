# AI Chat Assistant - RAG Implementation Task List

**Project:** MessengerAI - AI Chat Assistant Feature  
**Timeline:** 4 weeks (13 Pull Requests)  
**Total Estimated Hours:** ~54 hours

---

## 📋 Project Overview

This task list breaks down the AI Chat Assistant implementation into 13 pull requests. Each PR contains detailed subtasks with specific files to create or modify. Complete each PR in order, commit after each subtask, and push to GitHub after completing the entire PR.

---

## Project File Structure

```
MessengerAI/
├── Models/
│   ├── AIMessage.swift
│   ├── AISession.swift
│   ├── MessageAction.swift
│   ├── ProactiveSuggestion.swift
│   └── AIUsageStats.swift
├── Views/
│   ├── AI/
│   │   ├── AIChatView.swift
│   │   ├── AIMessageBubbleView.swift
│   │   ├── MessageActionSheet.swift
│   │   └── ProactiveSuggestionBanner.swift
│   └── Messages/
│       └── MessageBubbleView.swift (update)
├── ViewModels/
│   ├── AIChatViewModel.swift
│   └── SuggestionViewModel.swift
├── Services/
│   └── AIAssistantService.swift
├── Repositories/
│   └── AIMessageRepository.swift
└── Utils/
    └── AIConstants.swift

functions/
├── package.json
├── .env
└── src/
    ├── index.ts
    ├── handlers/
    │   ├── conversationSearch.ts
    │   ├── messageActions.ts
    │   └── proactiveSuggestions.ts
    ├── utils/
    │   ├── bedrock.ts
    │   ├── openai.ts
    │   ├── vectordb.ts
    │   └── cache.ts
    └── triggers/
        └── indexMessage.ts

firestore.rules (update)
```

---

## 🔄 Git Workflow

**After each subtask:**
```bash
git add <modified-files>
git commit -m "feat: <subtask description>"
```

**After completing each PR:**
```bash
git push origin feature/pr-<number>-<description>
# Create Pull Request on GitHub
# Merge to main
# Delete feature branch
```

---

## ⏱️ Timeline

- **Week 1:** PR #1-4 (Foundation & Vector DB)
- **Week 2:** PR #5-6 (Conversational Search)
- **Week 3:** PR #7-8 (Message Actions)
- **Week 3-4:** PR #9-10 (Proactive Suggestions)
- **Week 4:** PR #11-13 (Testing, Optimization, Documentation)

---

# Pull Requests

## PR #1: AI Infrastructure Setup ⏱️ 4 hours

**Branch:** `feature/pr-01-ai-infrastructure-setup`  
**Goal:** Set up Cloud Functions project with OpenAI and Bedrock SDKs

### Subtasks:

- [ ] **1.1 Initialize Firebase Cloud Functions**
  - Navigate to project root
  - Run: `firebase init functions`
  - Select TypeScript
  - Install dependencies
  - **Files created:**
    - `functions/package.json`
    - `functions/tsconfig.json`
    - `functions/src/index.ts`
  - **Commit:** `feat: initialize Firebase Cloud Functions with TypeScript`

- [ ] **1.2 Install AI SDKs**
  - Install OpenAI SDK: `npm install openai --prefix functions`
  - Install AWS SDK for Bedrock: `npm install @aws-sdk/client-bedrock-runtime --prefix functions`
  - Install Pinecone SDK: `npm install @pinecone-database/pinecone --prefix functions`
  - **Files modified:**
    - `functions/package.json`
  - **Commit:** `feat: add OpenAI, Bedrock, and Pinecone SDKs`

- [ ] **1.3 Create environment variables**
  - Create `.env` file in functions directory
  - Add keys:
    ```
    OPENAI_API_KEY=your_key_here
    AWS_ACCESS_KEY_ID=your_key_here
    AWS_SECRET_ACCESS_KEY=your_key_here
    AWS_REGION=us-east-1
    PINECONE_API_KEY=your_key_here
    PINECONE_ENVIRONMENT=your_env_here
    PINECONE_INDEX_NAME=messagevectors-prod
    ```
  - Add `.env` to `.gitignore`
  - **Files created:**
    - `functions/.env`
  - **Files modified:**
    - `functions/.gitignore`
  - **Commit:** `feat: add environment variables for AI services`

- [ ] **1.4 Create basic Cloud Function structure**
  - Create main handler in `functions/src/index.ts`
  - Export `aiChatHandler` function
  - Add authentication check
  - Add basic error handling
  - **Files modified:**
    - `functions/src/index.ts`
  - **Commit:** `feat: create aiChatHandler with authentication`

- [ ] **1.5 Deploy and test**
  - Run: `firebase deploy --only functions`
  - Test function responds with 200
  - Verify authentication works
  - **Commit:** `feat: deploy initial Cloud Functions`

**PR Completion:**
```bash
git push origin feature/pr-01-ai-infrastructure-setup
# Create PR on GitHub
# Merge to main
```

---

## PR #2: Data Models & Schemas ⏱️ 3 hours

**Branch:** `feature/pr-02-data-models-schemas`  
**Goal:** Create Swift models and Firestore schemas for AI features

### Subtasks:

- [ ] **2.1 Create AIMessage model**
  - Create file: `MessengerAI/Models/AIMessage.swift`
  - Define `AIMessage` struct with:
    - `id: String`
    - `role: AIMessageRole` (enum: user, assistant, system)
    - `content: String`
    - `timestamp: Date`
    - `sources: [MessageSource]?`
  - Define `MessageSource` struct
  - Conform to `Identifiable`, `Codable`
  - **Files created:**
    - `MessengerAI/Models/AIMessage.swift`
  - **Commit:** `feat: create AIMessage model`

- [ ] **2.2 Create AISession model**
  - Create file: `MessengerAI/Models/AISession.swift`
  - Define `AISession` struct with:
    - `id: String`
    - `userId: String`
    - `createdAt: Date`
    - `updatedAt: Date`
    - `messages: [AIMessage]`
    - `isActive: Bool`
  - **Files created:**
    - `MessengerAI/Models/AISession.swift`
  - **Commit:** `feat: create AISession model`

- [ ] **2.3 Create MessageAction models**
  - Create file: `MessengerAI/Models/MessageAction.swift`
  - Define `MessageAction` struct
  - Define `MessageActionType` enum (translate, rewrite, extract, summarize)
  - Define `MessageActionRequest` struct
  - Define `MessageActionResponse` struct
  - Define `RewriteTone` enum (formal, casual, technical, friendly)
  - Define `ExtractedEntities` struct
  - **Files created:**
    - `MessengerAI/Models/MessageAction.swift`
  - **Commit:** `feat: create MessageAction models`

- [ ] **2.4 Create ProactiveSuggestion model**
  - Create file: `MessengerAI/Models/ProactiveSuggestion.swift`
  - Define `ProactiveSuggestion` struct
  - Define `SuggestionType` enum
  - Define `SuggestionSeverity` enum
  - Define `SuggestionAction` struct
  - **Files created:**
    - `MessengerAI/Models/ProactiveSuggestion.swift`
  - **Commit:** `feat: create ProactiveSuggestion model`

- [ ] **2.5 Create AIUsageStats model**
  - Create file: `MessengerAI/Models/AIUsageStats.swift`
  - Define `AIUsageStats` struct
  - **Files created:**
    - `MessengerAI/Models/AIUsageStats.swift`
  - **Commit:** `feat: create AIUsageStats model`

- [ ] **2.6 Update Firestore security rules**
  - Open `firestore.rules`
  - Add rules for AI collections:
    - `/users/{userId}/aiSessions/{sessionId}`
    - `/users/{userId}/proactiveSuggestions/{suggestionId}`
    - `/users/{userId}/aiUsageStats`
  - **Files modified:**
    - `firestore.rules`
  - **Commit:** `feat: add Firestore security rules for AI collections`

- [ ] **2.7 Deploy Firestore rules**
  - Run: `firebase deploy --only firestore:rules`
  - Verify rules in Firebase Console
  - **Commit:** `chore: deploy Firestore security rules`

**PR Completion:**
```bash
git push origin feature/pr-02-data-models-schemas
# Create PR, merge to main
```

---

## PR #3: AI Chat UI - Basic Layout ⏱️ 5 hours

**Branch:** `feature/pr-03-ai-chat-ui-basic`  
**Goal:** Create basic AI chat interface without functionality

### Subtasks:

- [ ] **3.1 Create AI constants**
  - Create file: `MessengerAI/Utils/AIConstants.swift`
  - Define colors, fonts, spacing constants
  - Define animation durations
  - **Files created:**
    - `MessengerAI/Utils/AIConstants.swift`
  - **Commit:** `feat: create AI design constants`

- [ ] **3.2 Create AIChatViewModel**
  - Create file: `MessengerAI/ViewModels/AIChatViewModel.swift`
  - Define `@Published` properties:
    - `messages: [AIMessage]`
    - `isLoading: Bool`
    - `errorMessage: String?`
    - `currentQuery: String`
  - Add placeholder methods:
    - `sendQuery()`
    - `clearSession()`
  - Conform to `ObservableObject`
  - **Files created:**
    - `MessengerAI/ViewModels/AIChatViewModel.swift`
  - **Commit:** `feat: create AIChatViewModel`

- [ ] **3.3 Create AIMessageBubbleView**
  - Create file: `MessengerAI/Views/AI/AIMessageBubbleView.swift`
  - Create SwiftUI view for AI message bubbles
  - Support user and assistant roles
  - Add different background colors
  - Add timestamp display
  - Add source citation area (placeholder)
  - **Files created:**
    - `MessengerAI/Views/AI/AIMessageBubbleView.swift`
  - **Commit:** `feat: create AIMessageBubbleView component`

- [ ] **3.4 Create AIChatView**
  - Create file: `MessengerAI/Views/AI/AIChatView.swift`
  - Create main AI chat screen with:
    - Navigation bar with title "AI Assistant"
    - ScrollView for messages
    - Input field at bottom
    - Send button
    - Loading indicator
  - Use `@StateObject` for `AIChatViewModel`
  - Display messages using `AIMessageBubbleView`
  - **Files created:**
    - `MessengerAI/Views/AI/AIChatView.swift`
  - **Commit:** `feat: create AIChatView main screen`

- [ ] **3.5 Add navigation to AI chat**
  - Open main `ContentView.swift` or navigation file
  - Add AI Assistant button/tab
  - Add navigation link to `AIChatView`
  - **Files modified:**
    - `MessengerAI/Views/ContentView.swift` (or your main navigation file)
  - **Commit:** `feat: add navigation to AI Assistant`

- [ ] **3.6 Add placeholder data for preview**
  - Add mock messages in `AIChatView` preview
  - Test light and dark mode
  - Verify UI on iPhone SE and iPhone 15 Pro Max simulators
  - **Commit:** `chore: add preview data and test UI`

**PR Completion:**
```bash
git push origin feature/pr-03-ai-chat-ui-basic
# Create PR, merge to main
```

---

## PR #4: Vector Database Setup ⏱️ 4 hours

**Branch:** `feature/pr-04-vector-database-setup`  
**Goal:** Set up Pinecone and implement message indexing

### Subtasks:

- [ ] **4.1 Create Pinecone index**
  - Log into Pinecone dashboard
  - Create index named `messagevectors-prod`
  - Dimension: 1536 (for Bedrock Titan embeddings)
  - Metric: cosine
  - Note index URL and API key
  - **Commit:** `docs: add Pinecone index creation steps`

- [ ] **4.2 Create vector database utility**
  - Create file: `functions/src/utils/vectordb.ts`
  - Initialize Pinecone client
  - Export functions:
    - `initPinecone()`
    - `upsertVector(id, values, metadata)`
    - `queryVectors(vector, filter, topK)`
    - `deleteVector(id)`
  - **Files created:**
    - `functions/src/utils/vectordb.ts`
  - **Commit:** `feat: create Pinecone vector database utilities`

- [ ] **4.3 Create Bedrock embedding utility**
  - Create file: `functions/src/utils/bedrock.ts`
  - Initialize Bedrock client
  - Export function:
    - `generateEmbedding(text: string): Promise<number[]>`
  - Use Titan embedding model
  - **Files created:**
    - `functions/src/utils/bedrock.ts`
  - **Commit:** `feat: create Bedrock embedding utility`

- [ ] **4.4 Create message indexing trigger**
  - Create file: `functions/src/triggers/indexMessage.ts`
  - Create Firestore trigger on message creation
  - Path: `conversations/{conversationId}/messages/{messageId}`
  - Generate embedding for message text
  - Store in Pinecone with metadata:
    - `userId`, `conversationId`, `messageId`
    - `timestamp`, `senderName`, `messagePreview`
  - **Files created:**
    - `functions/src/triggers/indexMessage.ts`
  - **Commit:** `feat: create message indexing trigger`

- [ ] **4.5 Export trigger in index.ts**
  - Open `functions/src/index.ts`
  - Import and export `indexMessage` trigger
  - **Files modified:**
    - `functions/src/index.ts`
  - **Commit:** `feat: export message indexing trigger`

- [ ] **4.6 Deploy and test indexing**
  - Deploy: `firebase deploy --only functions`
  - Send a test message in app
  - Verify vector appears in Pinecone dashboard
  - **Commit:** `chore: test message indexing pipeline`

**PR Completion:**
```bash
git push origin feature/pr-04-vector-database-setup
# Create PR, merge to main
```

---

## PR #5: Conversational Search - Backend ⏱️ 8 hours

**Branch:** `feature/pr-05-conversational-search-backend`  
**Goal:** Implement RAG-powered conversational search

### Subtasks:

- [ ] **5.1 Create OpenAI utility**
  - Create file: `functions/src/utils/openai.ts`
  - Initialize OpenAI client
  - Export function:
    - `generateCompletion(messages, model, maxTokens)`
    - `generateChatResponse(systemPrompt, userPrompt)`
  - **Files created:**
    - `functions/src/utils/openai.ts`
  - **Commit:** `feat: create OpenAI utility functions`

- [ ] **5.2 Create cache utility**
  - Create file: `functions/src/utils/cache.ts`
  - Implement in-memory cache (or Redis if available)
  - Export functions:
    - `getCached(key)`
    - `setCached(key, value, ttl)`
  - **Files created:**
    - `functions/src/utils/cache.ts`
  - **Commit:** `feat: create caching utility`

- [ ] **5.3 Create conversational search handler - Part 1: Setup**
  - Create file: `functions/src/handlers/conversationSearch.ts`
  - Import dependencies (Bedrock, Pinecone, OpenAI)
  - Define function signature
  - Add authentication check
  - Extract query from payload
  - **Files created:**
    - `functions/src/handlers/conversationSearch.ts`
  - **Commit:** `feat: create conversationSearch handler structure`

- [ ] **5.4 Implement conversational search handler - Part 2: Retrieval**
  - In `conversationSearch.ts`:
  - Generate query embedding using Bedrock
  - Perform vector search in Pinecone
  - Filter by `userId` for security
  - Retrieve top 20 results with threshold 0.7
  - Fetch full messages from Firestore
  - **Files modified:**
    - `functions/src/handlers/conversationSearch.ts`
  - **Commit:** `feat: implement vector search retrieval`

- [ ] **5.5 Implement conversational search handler - Part 3: Synthesis**
  - In `conversationSearch.ts`:
  - Format retrieved messages for GPT-4
  - Create system prompt for answer synthesis
  - Call OpenAI GPT-4 with context
  - Parse response
  - Format sources with timestamps
  - **Files modified:**
    - `functions/src/handlers/conversationSearch.ts`
  - **Commit:** `feat: implement GPT-4 answer synthesis`

- [ ] **5.6 Add caching to search**
  - In `conversationSearch.ts`:
  - Check cache before processing
  - Cache embeddings for 24 hours
  - Cache common queries for 1 hour
  - **Files modified:**
    - `functions/src/handlers/conversationSearch.ts`
  - **Commit:** `feat: add caching to conversational search`

- [ ] **5.7 Add error handling and logging**
  - In `conversationSearch.ts`:
  - Wrap in try-catch blocks
  - Add detailed error messages
  - Log performance metrics
  - Add timeout handling
  - **Files modified:**
    - `functions/src/handlers/conversationSearch.ts`
  - **Commit:** `feat: add error handling and logging`

- [ ] **5.8 Integrate handler into main function**
  - Open `functions/src/index.ts`
  - Add route for `conversational_search` action
  - Call `conversationSearch` handler
  - **Files modified:**
    - `functions/src/index.ts`
  - **Commit:** `feat: integrate conversational search into main handler`

- [ ] **5.9 Deploy and test with Postman**
  - Deploy: `firebase deploy --only functions`
  - Test with Postman:
    - Send POST request with auth token
    - Query: "What did we discuss about the project?"
    - Verify response includes answer and sources
  - **Commit:** `test: verify conversational search backend`

**PR Completion:**
```bash
git push origin feature/pr-05-conversational-search-backend
# Create PR, merge to main
```

---

## PR #6: Conversational Search - Frontend ⏱️ 6 hours

**Branch:** `feature/pr-06-conversational-search-frontend`  
**Goal:** Connect iOS app to conversational search backend

### Subtasks:

- [ ] **6.1 Create AIAssistantService**
  - Create file: `MessengerAI/Services/AIAssistantService.swift`
  - Import Firebase Functions SDK
  - Create `AIAssistantService` class
  - Add method: `searchConversations(query:) async throws -> AISearchResponse`
  - Call Cloud Function `aiChatHandler`
  - **Files created:**
    - `MessengerAI/Services/AIAssistantService.swift`
  - **Commit:** `feat: create AIAssistantService`

- [ ] **6.2 Create AIMessageRepository**
  - Create file: `MessengerAI/Repositories/AIMessageRepository.swift`
  - Create `AIMessageRepository` class
  - Add methods:
    - `saveSession(_ session: AISession)`
    - `loadSession(sessionId:) async throws -> AISession?`
    - `loadRecentSessions() async throws -> [AISession]`
  - Use Firestore to persist AI sessions
  - **Files created:**
    - `MessengerAI/Repositories/AIMessageRepository.swift`
  - **Commit:** `feat: create AIMessageRepository`

- [ ] **6.3 Implement sendQuery in ViewModel**
  - Open `MessengerAI/ViewModels/AIChatViewModel.swift`
  - Implement `sendQuery()` method:
    - Set `isLoading = true`
    - Call `AIAssistantService.searchConversations()`
    - Parse response
    - Add user message to `messages` array
    - Add AI response to `messages` array
    - Set `isLoading = false`
    - Handle errors
  - **Files modified:**
    - `MessengerAI/ViewModels/AIChatViewModel.swift`
  - **Commit:** `feat: implement sendQuery in AIChatViewModel`

- [ ] **6.4 Update AIMessageBubbleView for sources**
  - Open `MessengerAI/Views/AI/AIMessageBubbleView.swift`
  - Add display for message sources
  - Show timestamp and sender name for each source
  - Make sources tappable (placeholder action)
  - **Files modified:**
    - `MessengerAI/Views/AI/AIMessageBubbleView.swift`
  - **Commit:** `feat: add source display to AIMessageBubbleView`

- [ ] **6.5 Implement source deep linking**
  - In `AIMessageBubbleView.swift`:
  - Add `onTapGesture` to source items
  - Navigate to original message in conversation
  - Highlight message when navigated to
  - **Files modified:**
    - `MessengerAI/Views/AI/AIMessageBubbleView.swift`
  - **Files may be modified:**
    - `MessengerAI/Views/Messages/ConversationView.swift` (to support highlighting)
  - **Commit:** `feat: implement source deep linking`

- [ ] **6.6 Add loading states to AIChatView**
  - Open `MessengerAI/Views/AI/AIChatView.swift`
  - Show loading indicator when `isLoading = true`
  - Add skeleton loader for AI response
  - Disable input field while loading
  - **Files modified:**
    - `MessengerAI/Views/AI/AIChatView.swift`
  - **Commit:** `feat: add loading states to AIChatView`

- [ ] **6.7 Add error handling UI**
  - In `AIChatView.swift`:
  - Show error alert when `errorMessage` is set
  - Add retry button
  - Clear error after displaying
  - **Files modified:**
    - `MessengerAI/Views/AI/AIChatView.swift`
  - **Commit:** `feat: add error handling UI`

- [ ] **6.8 Test end-to-end search**
  - Run app on simulator
  - Navigate to AI Assistant
  - Send query: "What did Mark say about the API?"
  - Verify response appears with sources
  - Click source link and verify navigation
  - Test error handling (airplane mode)
  - **Commit:** `test: verify end-to-end conversational search`

**PR Completion:**
```bash
git push origin feature/pr-06-conversational-search-frontend
# Create PR, merge to main
```

---

## PR #7: Message Actions - Backend ⏱️ 6 hours

**Branch:** `feature/pr-07-message-actions-backend`  
**Goal:** Implement translate, rewrite, extract, summarize actions

### Subtasks:

- [ ] **7.1 Create message actions handler structure**
  - Create file: `functions/src/handlers/messageActions.ts`
  - Define function: `performMessageAction(userId, payload)`
  - Extract action type and params from payload
  - Add switch statement for action routing
  - **Files created:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: create messageActions handler structure`

- [ ] **7.2 Implement translate action**
  - In `messageActions.ts`:
  - Add `translateMessage()` function
  - Fetch message from Firestore
  - Create system prompt: "Translate to Spanish/English"
  - Auto-detect source language
  - Call GPT-4
  - Return translated text with metadata
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: implement translate action (English ↔ Spanish)`

- [ ] **7.3 Implement rewrite action**
  - In `messageActions.ts`:
  - Add `rewriteMessage()` function
  - Support tones: formal, casual, technical, friendly
  - Create tone-specific system prompts
  - Call GPT-4
  - Return rewritten text
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: implement rewrite action with tone options`

- [ ] **7.4 Implement extract action**
  - In `messageActions.ts`:
  - Add `extractEntities()` function
  - Create system prompt for entity extraction
  - Use GPT-4 JSON mode
  - Parse and return structured data:
    - dates, actionItems, decisions, people
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: implement extract entities action`

- [ ] **7.5 Implement summarize action**
  - In `messageActions.ts`:
  - Add `summarizeThread()` function
  - Fetch message thread from Firestore
  - Format messages for summarization
  - Call GPT-4 with concise prompt
  - Return summary (max 5 sentences)
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: implement summarize thread action`

- [ ] **7.6 Add action caching**
  - In `messageActions.ts`:
  - Cache translation results (24 hours)
  - Cache entity extraction (24 hours)
  - Use message ID + action type as cache key
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `feat: add caching to message actions`

- [ ] **7.7 Integrate handler into main function**
  - Open `functions/src/index.ts`
  - Add route for `message_action` action
  - Call `performMessageAction` handler
  - **Files modified:**
    - `functions/src/index.ts`
  - **Commit:** `feat: integrate message actions into main handler`

- [ ] **7.8 Deploy and test with Postman**
  - Deploy: `firebase deploy --only functions`
  - Test each action:
    - Translate: English → Spanish
    - Translate: Spanish → English
    - Rewrite: Formal tone
    - Extract: Dates and action items
    - Summarize: 10-message thread
  - **Commit:** `test: verify message actions backend`

**PR Completion:**
```bash
git push origin feature/pr-07-message-actions-backend
# Create PR, merge to main
```

---

## PR #8: Message Actions - Frontend ⏱️ 8 hours

**Branch:** `feature/pr-08-message-actions-frontend`  
**Goal:** Create UI for message actions and integrate with backend

### Subtasks:

- [ ] **8.1 Create MessageActionSheet view**
  - Create file: `MessengerAI/Views/AI/MessageActionSheet.swift`
  - Create SwiftUI bottom sheet
  - Display action grid: Translate, Rewrite, Extract, Summarize
  - Add icons for each action
  - **Files created:**
    - `MessengerAI/Views/AI/MessageActionSheet.swift`
  - **Commit:** `feat: create MessageActionSheet component`

- [ ] **8.2 Add tone picker for rewrite**
  - In `MessageActionSheet.swift`:
  - Add second sheet for tone selection
  - Show tones: Formal, Casual, Technical, Friendly
  - Display tone descriptions
  - **Files modified:**
    - `MessengerAI/Views/AI/MessageActionSheet.swift`
  - **Commit:** `feat: add tone picker to MessageActionSheet`

- [ ] **8.3 Create result overlay view**
  - In `MessageActionSheet.swift`:
  - Create result display overlay
  - Show original text (collapsed)
  - Show result (expanded)
  - Add Copy, Share, Send buttons
  - **Files modified:**
    - `MessengerAI/Views/AI/MessageActionSheet.swift`
  - **Commit:** `feat: create action result overlay`

- [ ] **8.4 Add long-press gesture to messages**
  - Open `MessengerAI/Views/Messages/MessageBubbleView.swift`
  - Add `.onLongPressGesture` modifier
  - Show `MessageActionSheet` on long press
  - Pass message ID to sheet
  - **Files modified:**
    - `MessengerAI/Views/Messages/MessageBubbleView.swift`
  - **Commit:** `feat: add long-press gesture to messages`

- [ ] **8.5 Implement action execution in service**
  - Open `MessengerAI/Services/AIAssistantService.swift`
  - Add method: `performAction(messageId:, action:, params:) async throws -> ActionResult`
  - Call Cloud Function `aiChatHandler` with `message_action`
  - Parse response
  - **Files modified:**
    - `MessengerAI/Services/AIAssistantService.swift`
  - **Commit:** `feat: implement action execution in service`

- [ ] **8.6 Connect UI to backend**
  - In `MessageActionSheet.swift`:
  - Call `AIAssistantService.performAction()` on action tap
  - Show loading indicator during execution
  - Display result when complete
  - Handle errors
  - **Files modified:**
    - `MessengerAI/Views/AI/MessageActionSheet.swift`
  - **Commit:** `feat: connect action UI to backend`

- [ ] **8.7 Implement copy and share actions**
  - In `MessageActionSheet.swift`:
  - Implement Copy button (copy to clipboard)
  - Implement Share button (system share sheet)
  - Implement Send button (insert into message input)
  - **Files modified:**
    - `MessengerAI/Views/AI/MessageActionSheet.swift`
  - **Commit:** `feat: implement copy, share, and send actions`

- [ ] **8.8 Test all message actions**
  - Test Translate:
    - Long-press English message → Translate → Verify Spanish
    - Long-press Spanish message → Translate → Verify English
  - Test Rewrite:
    - Try all 4 tones
    - Verify tone changes
  - Test Extract:
    - Message with dates → Verify dates extracted
    - Message with action items → Verify extracted
  - Test Summarize:
    - Select thread → Verify summary
  - Test Copy, Share, Send buttons
  - **Commit:** `test: verify all message actions work`

**PR Completion:**
```bash
git push origin feature/pr-08-message-actions-frontend
# Create PR, merge to main
```

---

## PR #9: Proactive Suggestions - Backend ⏱️ 6 hours

**Branch:** `feature/pr-09-proactive-suggestions-backend`  
**Goal:** Implement suggestion generation logic

### Subtasks:

- [ ] **9.1 Create detection rules utility**
  - Create file: `functions/src/utils/detectionRules.ts`
  - Export functions:
    - `detectTimezoneAmbiguity(messages, userTz, recipientTz)`
    - `detectUnclearReferences(messages)`
    - `detectMissedFollowups(userId, messages)` (optional)
  - Use regex and pattern matching
  - **Files created:**
    - `functions/src/utils/detectionRules.ts`
  - **Commit:** `feat: create detection rules utility`

- [ ] **9.2 Implement timezone detection**
  - In `detectionRules.ts`:
  - Detect time patterns: "3pm", "at 3", "tomorrow at 3"
  - Check if time lacks timezone indicator
  - Check if users are in different timezones
  - Return suggestion object if detected
  - **Files modified:**
    - `functions/src/utils/detectionRules.ts`
  - **Commit:** `feat: implement timezone ambiguity detection`

- [ ] **9.3 Implement unclear reference detection**
  - In `detectionRules.ts`:
  - Detect vague references: "the document", "that file", "it"
  - Check if reference is unclear from context
  - Return suggestion object if detected
  - **Files modified:**
    - `functions/src/utils/detectionRules.ts`
  - **Commit:** `feat: implement unclear reference detection`

- [ ] **9.4 Create proactive suggestions handler**
  - Create file: `functions/src/handlers/proactiveSuggestions.ts`
  - Define function: `generateProactiveSuggestions(userId)`
  - Fetch recent messages (last 24 hours)
  - Run detection rules
  - Limit to 1 suggestion per check
  - Return highest priority suggestion
  - **Files created:**
    - `functions/src/handlers/proactiveSuggestions.ts`
  - **Commit:** `feat: create proactiveSuggestions handler`

- [ ] **9.5 Add suggestion frequency limiting**
  - In `proactiveSuggestions.ts`:
  - Track suggestions per conversation
  - Limit to 1 per 10 messages
  - Store suggestion count in Firestore
  - **Files modified:**
    - `functions/src/handlers/proactiveSuggestions.ts`
  - **Commit:** `feat: add suggestion frequency limiting`

- [ ] **9.6 Save suggestions to Firestore**
  - In `proactiveSuggestions.ts`:
  - Save generated suggestions to Firestore
  - Path: `/users/{userId}/proactiveSuggestions/{suggestionId}`
  - Set `dismissed: false`, `actionTaken: false`
  - **Files modified:**
    - `functions/src/handlers/proactiveSuggestions.ts`
  - **Commit:** `feat: save suggestions to Firestore`

- [ ] **9.7 Integrate handler into main function**
  - Open `functions/src/index.ts`
  - Add route for `proactive_check` action
  - Call `generateProactiveSuggestions` handler
  - **Files modified:**
    - `functions/src/index.ts`
  - **Commit:** `feat: integrate proactive suggestions handler`

- [ ] **9.8 Deploy and test**
  - Deploy: `firebase deploy --only functions`
  - Test timezone detection:
    - Send message with "3pm tomorrow"
    - Call proactive_check function
    - Verify suggestion returned
  - **Commit:** `test: verify proactive suggestions backend`

**PR Completion:**
```bash
git push origin feature/pr-09-proactive-suggestions-backend
# Create PR, merge to main
```

---

## PR #10: Proactive Suggestions - Frontend ⏱️ 5 hours

**Branch:** `feature/pr-10-proactive-suggestions-frontend`  
**Goal:** Display suggestion banners in UI

### Subtasks:

- [ ] **10.1 Create SuggestionViewModel**
  - Create file: `MessengerAI/ViewModels/SuggestionViewModel.swift`
  - Define `@Published` properties:
    - `activeSuggestion: ProactiveSuggestion?`
    - `suggestionQueue: [ProactiveSuggestion]`
  - Add methods:
    - `checkForSuggestions()`
    - `dismissSuggestion(id:)`
    - `takeSuggestionAction(id:, action:)`
  - **Files created:**
    - `MessengerAI/ViewModels/SuggestionViewModel.swift`
  - **Commit:** `feat: create SuggestionViewModel`

- [ ] **10.2 Create ProactiveSuggestionBanner component**
  - Create file: `MessengerAI/Views/AI/ProactiveSuggestionBanner.swift`
  - Create SwiftUI banner view
  - Display suggestion icon, message, action buttons
  - Add dismiss button (X)
  - Add slide-in animation
  - Color-code by severity (low: blue, medium: yellow, high: orange)
  - **Files created:**
    - `MessengerAI/Views/AI/ProactiveSuggestionBanner.swift`
  - **Commit:** `feat: create ProactiveSuggestionBanner component`

- [ ] **10.3 Add Firestore listener for suggestions**
  - In `SuggestionViewModel.swift`:
  - Listen to `/users/{userId}/proactiveSuggestions`
  - Filter for non-dismissed suggestions
  - Update `activeSuggestion` when new suggestion arrives
  - **Files modified:**
    - `MessengerAI/ViewModels/SuggestionViewModel.swift`
  - **Commit:** `feat: add Firestore listener for suggestions`

- [ ] **10.4 Integrate banner into ConversationView**
  - Open `MessengerAI/Views/Messages/ConversationView.swift`
  - Add `@StateObject` for `SuggestionViewModel`
  - Display `ProactiveSuggestionBanner` at top when `activeSuggestion != nil`
  - **Files modified:**
    - `MessengerAI/Views/Messages/ConversationView.swift`
  - **Commit:** `feat: integrate suggestion banner into ConversationView`

- [ ] **10.5 Implement dismiss action**
  - In `SuggestionViewModel.swift`:
  - Implement `dismissSuggestion(id:)`
  - Update Firestore: set `dismissed: true`
  - Remove from `activeSuggestion`
  - **Files modified:**
    - `MessengerAI/ViewModels/SuggestionViewModel.swift`
  - **Commit:** `feat: implement suggestion dismiss action`

- [ ] **10.6 Implement action buttons**
  - In `SuggestionViewModel.swift`:
  - Implement `takeSuggestionAction(id:, action:)`
  - For timezone: open clarification dialog
  - For unclear ref: open add context dialog
  - Update Firestore: set `actionTaken: true`
  - **Files modified:**
    - `MessengerAI/ViewModels/SuggestionViewModel.swift`
  - **Commit:** `feat: implement suggestion action buttons`

- [ ] **10.7 Test suggestion flow**
  - Send message with "3pm tomorrow"
  - Wait 2-3 seconds
  - Verify suggestion banner appears
  - Test dismiss button
  - Test action button
  - Verify suggestion doesn't reappear
  - **Commit:** `test: verify proactive suggestion flow`

**PR Completion:**
```bash
git push origin feature/pr-10-proactive-suggestions-frontend
# Create PR, merge to main
```

---

## PR #11: Testing & Bug Fixes ⏱️ 8 hours

**Branch:** `feature/pr-11-testing-bug-fixes`  
**Goal:** Run all test scenarios and fix bugs

### Subtasks:

- [ ] **11.1 Test Scenario 1: Conversational Search - Happy Path**
  - Follow test steps from PRD Section 9.1
  - Query: "What did Mark say about the API redesign?"
  - Verify response time <3 seconds
  - Verify sources displayed with timestamps
  - Verify source links work
  - Document any bugs found
  - **Commit:** `test: run conversational search test scenario`

- [ ] **11.2 Test Scenario 2: Message Translation**
  - Send Spanish message
  - Long-press → Translate
  - Verify English translation
  - Test reverse (English → Spanish)
  - Verify response time <2 seconds
  - Test copy/share buttons
  - Document any bugs
  - **Commit:** `test: run message translation test scenario`

- [ ] **11.3 Test Scenario 3: Proactive Timezone Warning**
  - Set user timezone to PST
  - Set recipient timezone to EST
  - Send: "Let's meet at 3pm tomorrow"
  - Wait for suggestion
  - Verify banner appears
  - Test clarify button
  - Test dismiss button
  - Document any bugs
  - **Commit:** `test: run timezone warning test scenario`

- [ ] **11.4 Test Scenario 4: Entity Extraction**
  - Create thread with:
    - "Launch by October 30"
    - "Sarah will handle design"
    - "Decision: Use PostgreSQL"
  - Long-press → Extract
  - Verify dates, action items, decisions extracted
  - Verify accuracy >80%
  - Document any bugs
  - **Commit:** `test: run entity extraction test scenario`

- [ ] **11.5 Fix identified bugs - Part 1**
  - Prioritize critical bugs
  - Fix UI bugs (layout, animations, colors)
  - Fix data bugs (parsing, formatting)
  - **Files modified:** (varies by bug)
  - **Commit:** `fix: resolve critical bugs from testing`

- [ ] **11.6 Fix identified bugs - Part 2**
  - Fix error handling issues
  - Fix loading state bugs
  - Fix edge cases
  - **Files modified:** (varies by bug)
  - **Commit:** `fix: resolve error handling and edge cases`

- [ ] **11.7 Improve error messages**
  - Make error messages user-friendly
  - Add specific guidance for common errors
  - Test error scenarios:
    - No internet connection
    - API timeout
    - Invalid query
  - **Files modified:**
    - Multiple ViewModel files
  - **Commit:** `feat: improve error messages and handling`

- [ ] **11.8 Performance optimization**
  - Profile app performance
  - Optimize slow queries
  - Reduce memory usage
  - Improve scroll performance
  - **Files modified:** (varies)
  - **Commit:** `perf: optimize app performance`

- [ ] **11.9 Accessibility improvements**
  - Add VoiceOver labels
  - Test with VoiceOver enabled
  - Ensure all buttons are tappable
  - Add haptic feedback
  - **Files modified:** (varies)
  - **Commit:** `feat: improve accessibility`

- [ ] **11.10 Final regression testing**
  - Re-run all 4 test scenarios
  - Test on iPhone SE and iPhone 15 Pro Max
  - Test in light and dark mode
  - Verify all bugs fixed
  - **Commit:** `test: final regression testing complete`

**PR Completion:**
```bash
git push origin feature/pr-11-testing-bug-fixes
# Create PR, merge to main
```

---

## PR #12: Performance Optimization ⏱️ 4 hours

**Branch:** `feature/pr-12-performance-optimization`  
**Goal:** Optimize costs and response times

### Subtasks:

- [ ] **12.1 Implement aggressive caching**
  - Update `functions/src/utils/cache.ts`
  - Cache embeddings for 30 days
  - Cache common queries for 1 day
  - Add cache hit metrics
  - **Files modified:**
    - `functions/src/utils/cache.ts`
    - `functions/src/handlers/conversationSearch.ts`
    - `functions/src/handlers/messageActions.ts`
  - **Commit:** `perf: implement aggressive caching strategy`

- [ ] **12.2 Optimize GPT-4 token usage**
  - Reduce system prompt length
  - Trim message previews to 100 chars
  - Use GPT-3.5-Turbo for simple actions
  - **Files modified:**
    - `functions/src/handlers/messageActions.ts`
    - `functions/src/utils/openai.ts`
  - **Commit:** `perf: optimize GPT-4 token usage`

- [ ] **12.3 Batch embedding generation**
  - Update message indexing trigger
  - Batch multiple messages for embedding
  - Reduce API calls
  - **Files modified:**
    - `functions/src/triggers/indexMessage.ts`
  - **Commit:** `perf: batch embedding generation`

- [ ] **12.4 Add performance monitoring**
  - Add timing logs to all Cloud Functions
  - Track: query time, embedding time, GPT-4 time
  - Log to Cloud Logging
  - **Files modified:**
    - `functions/src/handlers/*.ts`
  - **Commit:** `feat: add performance monitoring`

- [ ] **12.5 Optimize Firestore queries**
  - Add composite indexes where needed
  - Limit query results
  - Use pagination for large results
  - **Files modified:**
    - `firestore.indexes.json` (create if needed)
    - `MessengerAI/Repositories/AIMessageRepository.swift`
  - **Commit:** `perf: optimize Firestore queries`

- [ ] **12.6 Test cost savings**
  - Run 50 test queries
  - Measure cache hit rate (target >40%)
  - Calculate cost per query (target <$0.05)
  - Document results
  - **Commit:** `test: verify cost optimization results`

**PR Completion:**
```bash
git push origin feature/pr-12-performance-optimization
# Create PR, merge to main
```

---

## PR #13: Documentation & Demo ⏱️ 3 hours

**Branch:** `feature/pr-13-documentation-demo`  
**Goal:** Create documentation and demo video

### Subtasks:

- [ ] **13.1 Write AI features user guide**
  - Create file: `docs/AI_FEATURES_USER_GUIDE.md`
  - Document:
    - How to use conversational search
    - How to use message actions
    - How to respond to suggestions
  - Add screenshots
  - **Files created:**
    - `docs/AI_FEATURES_USER_GUIDE.md`
  - **Commit:** `docs: create AI features user guide`

- [ ] **13.2 Write developer documentation**
  - Create file: `docs/AI_DEVELOPER_GUIDE.md`
  - Document:
    - Architecture overview
    - How to add new actions
    - How to add new suggestion types
    - API reference
  - **Files created:**
    - `docs/AI_DEVELOPER_GUIDE.md`
  - **Commit:** `docs: create developer guide`

- [ ] **13.3 Update main README**
  - Open `README.md`
  - Add AI features section
  - Add setup instructions
  - Add API keys configuration
  - Add troubleshooting
  - **Files modified:**
    - `README.md`
  - **Commit:** `docs: update README with AI features`

- [ ] **13.4 Create demo script**
  - Create file: `docs/DEMO_SCRIPT.md`
  - Write 5-minute demo walkthrough
  - Include:
    - Conversational search demo
    - Translation demo
    - Proactive suggestion demo
  - **Files created:**
    - `docs/DEMO_SCRIPT.md`
  - **Commit:** `docs: create demo script`

- [ ] **13.5 Record demo video**
  - Follow demo script
  - Record screen using QuickTime or similar
  - Show all key features
  - Narrate key points
  - Export as MP4
  - **Commit:** `docs: add demo video`

- [ ] **13.6 Create API documentation**
  - Create file: `docs/API_REFERENCE.md`
  - Document Cloud Function endpoints:
    - `conversational_search`
    - `message_action`
    - `proactive_check`
  - Include request/response examples
  - **Files created:**
    - `docs/API_REFERENCE.md`
  - **Commit:** `docs: create API reference`

- [ ] **13.7 Add inline code comments**
  - Add JSDoc comments to Cloud Functions
  - Add Swift doc comments to models
  - Document complex logic
  - **Files modified:** (all code files)
  - **Commit:** `docs: add inline code documentation`

- [ ] **13.8 Final review**
  - Review all documentation
  - Test all links
  - Verify screenshots are up to date
  - Fix typos
  - **Commit:** `docs: final documentation review`

**PR Completion:**
```bash
git push origin feature/pr-13-documentation-demo
# Create PR, merge to main
```

---

## 🎉 Project Complete!

After merging PR #13, your AI Chat Assistant feature is complete and ready for demo!

---

## 📊 Project Summary

**Total PRs:** 13  
**Total Subtasks:** 118  
**Estimated Hours:** 54 hours  
**Timeline:** 4 weeks

### Milestone Checklist:

- [ ] Week 1 Complete (PR #1-4): Foundation & Vector DB
- [ ] Week 2 Complete (PR #5-6): Conversational Search
- [ ] Week 3 Complete (PR #7-8): Message Actions
- [ ] Week 3-4 Complete (PR #9-10): Proactive Suggestions
- [ ] Week 4 Complete (PR #11-13): Testing, Optimization, Documentation

---

## 🔧 Troubleshooting

**If you get stuck:**

1. Check Cloud Function logs: `firebase functions:log`
2. Check Firestore security rules
3. Verify API keys in `.env`
4. Check network requests in Xcode debugger
5. Review error messages in console

**Common Issues:**

- **"Permission denied"**: Check Firestore security rules
- **"Function timeout"**: Optimize query or increase timeout
- **"No results found"**: Check vector database indexing
- **"Invalid API key"**: Verify `.env` file and redeploy

---

## 📈 Success Metrics

Track these metrics after completion:

- [ ] Search query success rate >80%
- [ ] Average response time <3 seconds
- [ ] Suggestion acceptance rate >30%
- [ ] Zero critical bugs
- [ ] All test scenarios passing
- [ ] Documentation complete
- [ ] Demo video recorded

---

**Good luck with implementation! 🚀**