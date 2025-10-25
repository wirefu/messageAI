/**
 * Jest setup file for Cloud Functions tests
 */

// Mock Firebase Admin SDK
jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  apps: [],
  app: jest.fn(() => ({
    firestore: jest.fn(() => ({
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          get: jest.fn(),
          set: jest.fn(),
          update: jest.fn(),
          delete: jest.fn()
        })),
        add: jest.fn(),
        where: jest.fn(() => ({
          get: jest.fn(),
          orderBy: jest.fn(() => ({
            get: jest.fn()
          }))
        }))
      }))
    }))
  }))
}));

// Mock AWS SDK
jest.mock('@aws-sdk/client-bedrock-runtime', () => ({
  BedrockRuntimeClient: jest.fn(() => ({
    send: jest.fn()
  })),
  InvokeModelCommand: jest.fn()
}));

jest.mock('@aws-sdk/client-bedrock', () => ({
  BedrockClient: jest.fn(() => ({
    send: jest.fn()
  })),
  BedrockManagementClient: jest.fn(() => ({
    send: jest.fn()
  }))
}));

// Mock OpenAI
jest.mock('openai', () => ({
  OpenAI: jest.fn(() => ({
    chat: {
      completions: {
        create: jest.fn()
      }
    },
    embeddings: {
      create: jest.fn()
    }
  }))
}));

// Global test timeout
jest.setTimeout(30000);
