import { BedrockRuntimeClient } from '@aws-sdk/client-bedrock-runtime';
import { BedrockClient as BedrockManagementClient } from '@aws-sdk/client-bedrock';
import * as functions from 'firebase-functions';

/**
 * Amazon Bedrock Configuration Service
 * Handles AWS credentials and service initialization
 */
export class BedrockConfig {
  private static instance: BedrockConfig;
  private bedrockRuntime: BedrockRuntimeClient;
  private bedrockManagement: BedrockManagementClient;
  private readonly region: string;

  private constructor() {
    this.region = this.getRegionFromConfig();
    this.bedrockRuntime = this.createBedrockRuntimeClient();
    this.bedrockManagement = this.createBedrockManagementClient();
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): BedrockConfig {
    if (!BedrockConfig.instance) {
      BedrockConfig.instance = new BedrockConfig();
    }
    return BedrockConfig.instance;
  }

  /**
   * Get Bedrock Runtime Client for embedding and text generation
   */
  public getBedrockRuntimeClient(): BedrockRuntimeClient {
    return this.bedrockRuntime;
  }

  /**
   * Get Bedrock Management Client for model access
   */
  public getBedrockManagementClient(): BedrockManagementClient {
    return this.bedrockManagement;
  }

  /**
   * Get AWS region
   */
  public getRegion(): string {
    return this.region;
  }

  /**
   * Create Bedrock Runtime Client with credentials
   */
  private createBedrockRuntimeClient(): BedrockRuntimeClient {
    const credentials = this.getAWSCredentials();
    
    return new BedrockRuntimeClient({
      region: this.region,
      credentials: credentials,
      maxAttempts: 3,
      retryMode: 'adaptive'
    });
  }

  /**
   * Create Bedrock Management Client with credentials
   */
  private createBedrockManagementClient(): BedrockManagementClient {
    const credentials = this.getAWSCredentials();
    
    return new BedrockManagementClient({
      region: this.region,
      credentials: credentials,
      maxAttempts: 3,
      retryMode: 'adaptive'
    });
  }

  /**
   * Get AWS region from environment or config
   */
  private getRegionFromConfig(): string {
    // Try environment variable first
    if (process.env.AWS_REGION) {
      return process.env.AWS_REGION;
    }
    
    // Try Firebase Functions config
    try {
      const config = functions.config();
      if (config.aws?.region) {
        return config.aws.region;
      }
    } catch (error) {
      functions.logger.warn('Could not access Firebase config:', error);
    }
    
    // Default to us-east-1
    return 'us-east-1';
  }

  /**
   * Get AWS credentials from environment or Firebase config
   */
  private getAWSCredentials() {
    // Try environment variables first (for local development)
    if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
      return {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
      };
    }
    
    // Try Firebase Functions config (for production)
    try {
      const config = functions.config();
      if (config.aws?.access_key_id && config.aws?.secret_access_key) {
        return {
          accessKeyId: config.aws.access_key_id,
          secretAccessKey: config.aws.secret_access_key
        };
      }
    } catch (error) {
      functions.logger.warn('Could not access Firebase config:', error);
    }
    
    // Try AWS SDK default credential chain (for EC2/ECS/Lambda)
    return undefined; // Let AWS SDK handle default credentials
  }

  /**
   * Test Bedrock service availability
   */
  public async testConnection(): Promise<boolean> {
    try {
      const { ListFoundationModelsCommand } = await import('@aws-sdk/client-bedrock');
      const command = new ListFoundationModelsCommand({});
      await this.bedrockManagement.send(command);
      return true;
    } catch (error) {
      functions.logger.error('Bedrock connection test failed:', error);
      return false;
    }
  }

  /**
   * Get available embedding models
   */
  public async getAvailableEmbeddingModels(): Promise<string[]> {
    try {
      const { ListFoundationModelsCommand } = await import('@aws-sdk/client-bedrock');
      const command = new ListFoundationModelsCommand({
        byProvider: 'Amazon'
      });
      
      const response = await this.bedrockManagement.send(command);
      return response.modelSummaries
        ?.filter(model => model.modelId?.includes('embed'))
        .map(model => model.modelId!)
        || [];
    } catch (error) {
      functions.logger.error('Error getting available models:', error);
      return [];
    }
  }

  /**
   * Validate AWS credentials
   */
  public async validateCredentials(): Promise<{ valid: boolean; error?: string }> {
    try {
      const isConnected = await this.testConnection();
      if (isConnected) {
        return { valid: true };
      } else {
        return { valid: false, error: 'Could not connect to Bedrock service' };
      }
    } catch (error) {
      return { 
        valid: false, 
        error: `Credential validation failed: ${error}` 
      };
    }
  }
}

/**
 * Cloud Function: Test Bedrock connection
 */
export const testBedrockConnection = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const config = BedrockConfig.getInstance();
    
    // Test connection
    const isConnected = await config.testConnection();
    
    if (!isConnected) {
      return {
        success: false,
        error: 'Could not connect to Bedrock service',
        region: config.getRegion()
      };
    }
    
    // Get available models
    const embeddingModels = await config.getAvailableEmbeddingModels();
    
    return {
      success: true,
      region: config.getRegion(),
      availableEmbeddingModels: embeddingModels,
      message: 'Bedrock service is ready!'
    };
  } catch (error) {
    functions.logger.error('Error testing Bedrock connection:', error);
    throw new functions.https.HttpsError('internal', 'Failed to test Bedrock connection');
  }
});

/**
 * Cloud Function: Validate AWS credentials
 */
export const validateAWSCredentials = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const config = BedrockConfig.getInstance();
    const validation = await config.validateCredentials();
    
    return {
      success: validation.valid,
      error: validation.error,
      region: config.getRegion()
    };
  } catch (error) {
    functions.logger.error('Error validating AWS credentials:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate AWS credentials');
  }
});
