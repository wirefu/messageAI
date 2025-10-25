# AWS Bedrock Setup Guide
**Getting API Keys and Setting Up Amazon Bedrock for AI Chat Interface**

## 🚀 Quick Setup (5 minutes)

### Step 1: Enable Amazon Bedrock
1. **Go to AWS Console**: https://console.aws.amazon.com/bedrock/
2. **Sign in** with your AWS account
3. **Click "Get Started"** or "Enable Bedrock"
4. **Accept the terms** and enable the service

### Step 2: Enable Amazon Titan Models
1. **In Bedrock Console**, go to **"Model access"** in the left sidebar
2. **Click "Request model access"**
3. **Select these models**:
   - ✅ `amazon.titan-embed-text-v1` (for embeddings)
   - ✅ `amazon.titan-text-express-v1` (for text generation)
4. **Click "Request access"**
5. **Wait for approval** (usually instant for new accounts)

### Step 3: Get Your API Credentials
1. **Go to AWS IAM Console**: https://console.aws.amazon.com/iam/
2. **Click "Users"** in the left sidebar
3. **Click "Create user"**
4. **User name**: `bedrock-ai-chat-service`
5. **Click "Next"**

### Step 4: Attach Permissions
1. **Click "Attach policies directly"**
2. **Search and select**:
   - ✅ `AmazonBedrockFullAccess`
   - ✅ `AmazonBedrockInvokeModel`
3. **Click "Next"**
4. **Click "Create user"**

### Step 5: Create Access Keys
1. **Click on your new user** (`bedrock-ai-chat-service`)
2. **Go to "Security credentials" tab**
3. **Click "Create access key"**
4. **Select "Application running outside AWS"**
5. **Click "Next"**
6. **Add description**: "AI Chat Interface Service"
7. **Click "Create access key"**

### Step 6: Copy Your Credentials
**IMPORTANT**: Copy these values immediately (you won't see them again):

```
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
```

## 🔧 Environment Setup

### Option 1: Firebase Functions Environment (Recommended)
```bash
# In your Cloud Functions directory
cd CloudFunctions/functions

# Set environment variables
firebase functions:config:set aws.access_key_id="YOUR_ACCESS_KEY_ID"
firebase functions:config:set aws.secret_access_key="YOUR_SECRET_ACCESS_KEY"
firebase functions:config:set aws.region="us-east-1"
```

### Option 2: Local Development
```bash
# Create .env file in CloudFunctions/functions/
echo "AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY_ID" >> .env
echo "AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY" >> .env
echo "AWS_REGION=us-east-1" >> .env
```

## 🧪 Test Your Setup

### Quick Test Script
```bash
# Test Bedrock access
node -e "
const { BedrockClient, ListFoundationModelsCommand } = require('@aws-sdk/client-bedrock');
const client = new BedrockClient({ region: 'us-east-1' });
client.send(new ListFoundationModelsCommand({}))
  .then(() => console.log('✅ Bedrock access confirmed!'))
  .catch(err => console.error('❌ Error:', err.message));
"
```

## 💰 Cost Estimation

### Monthly Costs (5 users, 250 messages/month):
- **Embeddings**: ~$0.25/month
- **Vector Storage**: ~$0.01/month
- **Text Generation**: ~$0.04/month
- **Total**: ~$0.30/month

### Free Tier:
- **First 1,000 requests/month**: Free
- **Perfect for prototype testing**

## 🚨 Security Notes

### Best Practices:
- ✅ **Use IAM roles** instead of access keys when possible
- ✅ **Rotate keys regularly** (every 90 days)
- ✅ **Limit permissions** to only what's needed
- ✅ **Monitor usage** in AWS CloudTrail

### Key Security:
- 🔒 **Never commit keys to git**
- 🔒 **Use environment variables**
- 🔒 **Restrict to specific regions**
- 🔒 **Monitor for unusual activity**

## 🎯 What You'll Get

### Enabled Features:
- ✅ **Message embeddings** using Amazon Titan
- ✅ **Semantic search** across conversations
- ✅ **Cross-user sharing** with team knowledge
- ✅ **Batch processing** for performance
- ✅ **Real-time AI responses** < 1 second

### API Endpoints Ready:
- `generateMessageEmbedding` - Embed single message
- `generateConversationEmbeddings` - Batch embed conversation
- `searchConversationMessages` - Search within conversation
- `searchAllTeamMessages` - Cross-user semantic search
- `findSimilarMessages` - Find related messages

## 🚀 Next Steps

1. **Get your API credentials** (follow steps above)
2. **Share them with me** (I'll configure the service)
3. **Deploy Cloud Functions** with Bedrock integration
4. **Test the embedding and search** functionality
5. **Move to Phase 2** - AI Chat Interface implementation

## 📞 Need Help?

### Common Issues:
- **"Access Denied"**: Check IAM permissions
- **"Model not available"**: Request model access
- **"Region not supported"**: Use `us-east-1`
- **"Rate limit exceeded"**: Wait and retry

### Support:
- AWS Documentation: https://docs.aws.amazon.com/bedrock/
- AWS Support: https://console.aws.amazon.com/support/
- Community: https://repost.aws/tags/TAf8Qy8K2Q

---

**Ready to get your API keys?** Follow the steps above and share your credentials with me for automatic setup! 🚀
