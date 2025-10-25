# AI Chat Interface - Prototype Architecture
**Simplified Advanced RAG for 5 Users, 50 Messages/User**

## 🎯 Prototype Requirements

- **Users**: 5 concurrent users
- **Message Volume**: 50 messages per user (250 total/month)
- **Response Time**: < 1 second
- **Scope**: Prototype (no cross-user sharing)
- **AWS Account**: Available

## 🏗️ Simplified Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AI CHAT INTERFACE (PROTOTYPE)             │
├─────────────────────────────────────────────────────────────┤
│  📱 SwiftUI Frontend                                        │
│  ├── AIChatView.swift                                      │
│  ├── AIChatViewModel.swift                                 │
│  └── AIActionSuggestionsView.swift                       │
├─────────────────────────────────────────────────────────────┤
│  🌐 API Layer (Cloud Functions)                            │
│  ├── aiChatInterface.ts                                    │
│  ├── semanticSearch.ts                                     │
│  └── actionExecution.ts                                    │
├─────────────────────────────────────────────────────────────┤
│  🔄 Service Layer (Simplified)                             │
│  ├── BedrockEmbeddingService                               │
│  ├── BedrockVectorSearchService                            │
│  └── SimpleContextAssemblyService                          │
├─────────────────────────────────────────────────────────────┤
│  📊 Data Layer (AWS)                                       │
│  ├── Amazon Bedrock (Vector DB)                           │
│  ├── Firestore (Messages)                                 │
│  └── Cloud Functions (Processing)                          │
└─────────────────────────────────────────────────────────────┘
```

## 🗄️ AWS Vector Database Options

### 1. 🥇 Amazon Bedrock (RECOMMENDED)
```typescript
// Managed vector database with built-in embeddings
const bedrock = new AWS.BedrockRuntimeClient({});

// Titan embeddings (built-in)
const embedding = await bedrock.invokeModel({
  modelId: 'amazon.titan-embed-text-v1',
  body: JSON.stringify({ inputText: message.content })
});
```

**Pros:**
- ✅ Managed service (no setup)
- ✅ Built-in Titan embeddings
- ✅ Serverless scaling
- ✅ Cost-effective for prototypes
- ✅ < 1 second response times

**Cons:**
- ❌ Newer service (less documentation)
- ❌ Limited customization

**Cost:** ~$0.30/month for prototype

### 2. 🥈 Amazon OpenSearch
```typescript
// Self-managed vector search
const opensearch = new AWS.OpenSearchClient({});

// Vector search capabilities
const searchResults = await opensearch.search({
  index: 'message-embeddings',
  body: {
    query: {
      knn: {
        field: 'embedding',
        vector: queryEmbedding,
        k: 10
      }
    }
  }
});
```

**Pros:**
- ✅ Mature service
- ✅ Full control
- ✅ Advanced search features

**Cons:**
- ❌ More complex setup
- ❌ Higher cost (~$15/month)

**Cost:** ~$15/month for prototype

### 3. 🥉 EC2 + Chroma (Open Source)
```python
# Self-hosted on EC2
import chromadb

# Local vector database
client = chromadb.Client()
collection = client.create_collection("messages")

# Embeddings with OpenAI
embeddings = openai.Embedding.create(
    model="text-embedding-ada-002",
    input=message.content
)
```

**Pros:**
- ✅ Free open source
- ✅ Full control
- ✅ No vendor lock-in

**Cons:**
- ❌ More setup required
- ❌ Self-managed infrastructure

**Cost:** ~$8.60/month (EC2 t3.micro)

## 🔧 Embedding Strategy Explanation

### 1. 📊 Real-Time Embedding
```typescript
// Generate embeddings immediately when message sent
async function embedMessageRealTime(message: Message) {
  const embedding = await bedrock.invokeModel({
    modelId: 'amazon.titan-embed-text-v1',
    body: JSON.stringify({ inputText: message.content })
  });
  
  // Store immediately in vector database
  await vectorDB.upsert({
    id: message.id,
    vector: embedding.embedding,
    metadata: { userId: message.senderID, timestamp: message.timestamp }
  });
}
```

**Pros:**
- ✅ Always up-to-date
- ✅ Instant search availability
- ✅ Real-time context

**Cons:**
- ❌ Higher cost (~$0.10 per 1K messages)
- ❌ Slower response times
- ❌ More API calls

### 2. 📦 Batch Embedding
```typescript
// Process messages in batches every hour
async function batchEmbedMessages() {
  const unprocessedMessages = await getUnprocessedMessages();
  
  // Batch process for cost efficiency
  const embeddings = await Promise.all(
    unprocessedMessages.map(msg => 
      bedrock.invokeModel({
        modelId: 'amazon.titan-embed-text-v1',
        body: JSON.stringify({ inputText: msg.content })
      })
    )
  );
  
  // Batch insert to vector database
  await vectorDB.batchUpsert(embeddings);
}
```

**Pros:**
- ✅ Much cheaper (~$0.01 per 1K messages)
- ✅ Faster processing
- ✅ Cost-effective for prototypes

**Cons:**
- ❌ Delayed search availability
- ❌ Not real-time
- ❌ Batch processing complexity

### 3. 🔄 Hybrid Approach (RECOMMENDED)
```typescript
// Recent messages: real-time, older: batch
async function hybridEmbedding(message: Message) {
  const isRecent = Date.now() - message.timestamp < 24 * 60 * 60 * 1000; // 24h
  
  if (isRecent) {
    // Real-time embedding for recent messages
    await embedMessageRealTime(message);
  } else {
    // Queue for batch processing
    await queueForBatchEmbedding(message);
  }
}
```

**Pros:**
- ✅ Best of both worlds
- ✅ Cost-effective (~$0.05 per 1K messages)
- ✅ Recent messages always available
- ✅ Optimized for prototypes

**Cons:**
- ❌ More complex logic
- ❌ Two processing paths

## 💰 Cost Estimation (Prototype)

### Monthly Costs (5 users, 50 messages/user = 250 messages/month)

#### 1. 🥇 Amazon Bedrock
```
Embeddings: $0.10/1M tokens ≈ $0.25/month
Vector storage: $0.10/1M vectors ≈ $0.01/month
Total: ~$0.30/month
```

#### 2. 🥈 Amazon OpenSearch
```
Serverless: $0.50/hour ≈ $15/month
Managed: $0.50/hour ≈ $15/month
Total: ~$15/month
```

#### 3. 🥉 EC2 + Chroma
```
t3.micro EC2: $8.50/month
Storage: $0.10/GB ≈ $0.10/month
Total: ~$8.60/month
```

## ⚡ Performance Optimization (< 1 Second)

### 1. 🚀 Caching Strategy
```typescript
// Redis cache for frequent queries
const cache = new Redis({
  host: 'your-redis-cluster',
  port: 6379
});

// Cache embeddings (24h TTL)
await cache.setex(`embedding:${messageId}`, 86400, JSON.stringify(embedding));

// Cache context (1h TTL)
await cache.setex(`context:${userId}`, 3600, JSON.stringify(context));
```

### 2. 🔄 Async Processing
```typescript
// Non-blocking embedding generation
async function processMessageAsync(message: Message) {
  // Return immediately to user
  const response = await generateQuickResponse(message);
  
  // Process embedding in background
  setImmediate(() => {
    embedMessageInBackground(message);
  });
  
  return response;
}
```

### 3. 📊 Optimized Queries
```typescript
// Limit search results and pre-filter
async function optimizedSearch(userId: string, query: string) {
  const results = await vectorDB.query({
    vector: queryEmbedding,
    filter: { userId }, // Pre-filter by user
    topK: 10, // Limit results
    includeMetadata: true
  });
  
  return results.slice(0, 5); // Return top 5 only
}
```

## 🏗️ Implementation Plan

### Phase 1 (Week 1): Foundation
**Goals**: Set up Amazon Bedrock and basic embedding

**Tasks:**
- [ ] Set up Amazon Bedrock service
- [ ] Implement BedrockEmbeddingService
- [ ] Create basic vector storage
- [ ] Implement user-scoped data isolation
- [ ] Test embedding generation

**Deliverables:**
- Bedrock service operational
- Message embeddings being generated
- Basic vector storage working

### Phase 2 (Week 2): Core Features
**Goals**: Implement AI chat interface and basic actions

**Tasks:**
- [ ] Create AIChatView (SwiftUI)
- [ ] Implement AIChatViewModel
- [ ] Build semantic search functionality
- [ ] Add basic action execution (translate, summarize)
- [ ] Implement context assembly

**Deliverables:**
- Working AI chat interface
- Semantic search across user's conversations
- Basic action execution

### Phase 3 (Week 3): Optimization
**Goals**: Achieve < 1 second response times

**Tasks:**
- [ ] Implement Redis caching
- [ ] Optimize vector queries
- [ ] Add async processing
- [ ] Performance testing and tuning
- [ ] Response time optimization

**Deliverables:**
- < 1 second response times
- Optimized caching system
- Performance-tuned prototype

## 🚀 Quick Start Implementation

### 1. Set up Amazon Bedrock
```bash
# Install AWS CLI
aws configure

# Enable Bedrock service
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{
    "textDataDeliveryEnabled": true,
    "imageDataDeliveryEnabled": false,
    "invocationLoggingConfiguration": {
      "cloudWatchLogGroupArn": "arn:aws:logs:us-east-1:123456789012:log-group:bedrock-logs"
    }
  }'
```

### 2. Basic Embedding Service
```typescript
// CloudFunctions/functions/src/bedrockEmbedding.ts
import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime';

export class BedrockEmbeddingService {
  private client: BedrockRuntimeClient;
  
  constructor() {
    this.client = new BedrockRuntimeClient({ region: 'us-east-1' });
  }
  
  async embedText(text: string): Promise<number[]> {
    const command = new InvokeModelCommand({
      modelId: 'amazon.titan-embed-text-v1',
      body: JSON.stringify({ inputText: text }),
      contentType: 'application/json',
    });
    
    const response = await this.client.send(command);
    const result = JSON.parse(new TextDecoder().decode(response.body));
    
    return result.embedding;
  }
}
```

### 3. SwiftUI AI Chat Interface
```swift
// MessageAI/MessageAI/Views/AI/AIChatView.swift
struct AIChatView: View {
    @StateObject private var viewModel: AIChatViewModel
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // Chat messages
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        AIChatMessageView(message: message)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Ask AI about your conversations...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    Task {
                        await viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("AI Assistant")
    }
}
```

## 💡 Recommendation

**For your prototype with AWS account:**

🥇 **USE AMAZON BEDROCK**
- Managed service (no setup complexity)
- Built-in Titan embeddings
- Serverless scaling
- Cost-effective (~$0.30/month)
- < 1 second response times achievable
- Perfect for prototype development

This architecture provides a solid foundation for your AI Chat Interface prototype while keeping costs low and complexity manageable.
