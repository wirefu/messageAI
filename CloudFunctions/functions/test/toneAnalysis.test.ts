import * as admin from 'firebase-admin';
import * as test from 'firebase-functions-test';
import { analyzeTone } from '../src/toneAnalysis';

// Initialize test environment
const testEnv = test();

describe('Tone Analysis Cloud Function', () => {
  let wrappedFunction: any;

  beforeEach(() => {
    // Mock the function
    wrappedFunction = testEnv.wrap(analyzeTone);
  });

  afterEach(() => {
    testEnv.cleanup();
  });

  describe('Authentication', () => {
    it('should reject unauthenticated requests', async () => {
      const data = {
        message: 'Test message',
        conversationContext: '',
        recipientRole: ''
      };

      await expect(wrappedFunction(data, { auth: null }))
        .rejects
        .toThrow('Must be authenticated');
    });

    it('should accept authenticated requests', async () => {
      const data = {
        message: 'Test message',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };
      
      // Mock OpenAI response
      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: null,
              alternativePhrasing: null,
              improvementSuggestions: [],
              severity: 'none'
            })
          }
        }]
      };

      // Mock OpenAI
      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      // Replace the OpenAI import
      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);
      
      expect(result).toHaveProperty('toneWarning');
      expect(result).toHaveProperty('severity');
    });
  });

  describe('Message Analysis', () => {
    it('should handle empty messages', async () => {
      const data = {
        message: '',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };
      const result = await wrappedFunction(data, context);

      expect(result).toEqual({
        toneWarning: null,
        alternativePhrasing: null,
        improvementSuggestions: [],
        severity: 'none'
      });
    });

    it('should handle whitespace-only messages', async () => {
      const data = {
        message: '   \n  ',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };
      const result = await wrappedFunction(data, context);

      expect(result).toEqual({
        toneWarning: null,
        alternativePhrasing: null,
        improvementSuggestions: [],
        severity: 'none'
      });
    });

    it('should detect terse messages', async () => {
      const data = {
        message: 'No.',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: 'This might sound abrupt',
              alternativePhrasing: 'I\'m not sure about that. Could you provide more details?',
              improvementSuggestions: ['Consider adding context', 'Be more specific'],
              severity: 'low'
            })
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      expect(result.toneWarning).toBe('This might sound abrupt');
      expect(result.alternativePhrasing).toContain('I\'m not sure about that');
      expect(result.severity).toBe('low');
    });

    it('should detect potential rudeness', async () => {
      const data = {
        message: 'That\'s completely wrong and you should know better.',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: 'This message could come across as dismissive or rude',
              alternativePhrasing: 'I see a different approach here. Could we discuss this further?',
              improvementSuggestions: [
                'Acknowledge the other person\'s perspective',
                'Offer constructive feedback'
              ],
              severity: 'high'
            })
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      expect(result.toneWarning).toContain('dismissive or rude');
      expect(result.severity).toBe('high');
    });

    it('should detect jargon for non-technical recipients', async () => {
      const data = {
        message: 'The API endpoint is returning a 500 error due to database connection pooling issues.',
        conversationContext: '',
        recipientRole: 'designer'
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: 'This contains technical jargon that might confuse a designer',
              alternativePhrasing: 'The system is having trouble connecting to the database, which is causing errors.',
              improvementSuggestions: [
                'Use simpler language',
                'Explain technical terms'
              ],
              severity: 'medium'
            })
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      expect(result.toneWarning).toContain('technical jargon');
      expect(result.severity).toBe('medium');
    });

    it('should handle neutral messages with no issues', async () => {
      const data = {
        message: 'Hi there! How are you doing today? I hope you\'re having a great day.',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: null,
              alternativePhrasing: null,
              improvementSuggestions: [],
              severity: 'none'
            })
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      expect(result.toneWarning).toBeNull();
      expect(result.alternativePhrasing).toBeNull();
      expect(result.improvementSuggestions).toEqual([]);
      expect(result.severity).toBe('none');
    });

    it('should consider conversation context', async () => {
      const data = {
        message: 'This is broken',
        conversationContext: 'Previous discussion about a bug in the system that needs immediate attention',
        recipientRole: 'engineer'
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: JSON.stringify({
              toneWarning: 'This might sound terse without the full context',
              alternativePhrasing: 'I found an issue with the system that needs immediate attention.',
              improvementSuggestions: [
                'Provide more context about what\'s broken',
                'Explain the urgency level'
              ],
              severity: 'low'
            })
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      expect(result.toneWarning).toContain('terse without the full context');
      expect(result.severity).toBe('low');
    });
  });

  describe('Error Handling', () => {
    it('should handle OpenAI API errors gracefully', async () => {
      const data = {
        message: 'Test message',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockRejectedValue(new Error('OpenAI API error'))
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      // Should return safe defaults on error
      expect(result).toEqual({
        toneWarning: null,
        alternativePhrasing: null,
        improvementSuggestions: [],
        severity: 'none'
      });
    });

    it('should handle malformed OpenAI responses', async () => {
      const data = {
        message: 'Test message',
        conversationContext: '',
        recipientRole: ''
      };

      const context = { auth: { uid: 'test-user' } };

      const mockCompletion = {
        choices: [{
          message: {
            content: 'Invalid JSON response'
          }
        }]
      };

      const mockOpenAI = {
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue(mockCompletion)
          }
        }
      };

      jest.doMock('openai', () => ({
        __esModule: true,
        default: jest.fn().mockImplementation(() => mockOpenAI)
      }));

      const result = await wrappedFunction(data, context);

      // Should return safe defaults on parsing error
      expect(result).toEqual({
        toneWarning: null,
        alternativePhrasing: null,
        improvementSuggestions: [],
        severity: 'none'
      });
    });
  });

  describe('Severity Levels', () => {
    it('should correctly categorize severity levels', async () => {
      const testCases = [
        { message: 'Hi there!', expectedSeverity: 'none' },
        { message: 'No.', expectedSeverity: 'low' },
        { message: 'That\'s wrong.', expectedSeverity: 'medium' },
        { message: 'You\'re an idiot.', expectedSeverity: 'high' }
      ];

      for (const testCase of testCases) {
        const data = {
          message: testCase.message,
          conversationContext: '',
          recipientRole: ''
        };

        const context = { auth: { uid: 'test-user' } };

        const mockCompletion = {
          choices: [{
            message: {
              content: JSON.stringify({
                toneWarning: testCase.expectedSeverity !== 'none' ? 'Test warning' : null,
                alternativePhrasing: testCase.expectedSeverity !== 'none' ? 'Test alternative' : null,
                improvementSuggestions: testCase.expectedSeverity !== 'none' ? ['Test suggestion'] : [],
                severity: testCase.expectedSeverity
              })
            }
          }]
        };

        const mockOpenAI = {
          chat: {
            completions: {
              create: jest.fn().mockResolvedValue(mockCompletion)
            }
          }
        };

        jest.doMock('openai', () => ({
          __esModule: true,
          default: jest.fn().mockImplementation(() => mockOpenAI)
        }));

        const result = await wrappedFunction(data, context);
        expect(result.severity).toBe(testCase.expectedSeverity);
      }
    });
  });
});
