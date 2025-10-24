# Cursor Rules for MessengerAI

This directory contains modular Cursor rules organized by topic. Cursor will automatically load all `.mdc` files from this directory.

## Rule Files

1. **swift-basics.mdc** - Swift fundamentals, async/await, error handling, documentation
2. **swiftui-patterns.mdc** - SwiftUI best practices, property wrappers, UI/UX guidelines
3. **mvvm-architecture.mdc** - MVVM pattern, Repository pattern, layer responsibilities
4. **firebase-integration.mdc** - Firebase patterns, real-time listeners, Cloud Functions
5. **hot-reload-setup.mdc** - InjectionNext configuration and usage
6. **testing-patterns.mdc** - Unit testing, mocking, test organization
7. **file-organization.mdc** - Project structure, naming conventions, file headers
8. **sweetpad-commands.mdc** - Build commands, npm scripts, debugging
9. **dev-workflow.mdc** - Testing automation (90% automated!), minimal manual prompts, git workflow, commit protocol

## Usage

Cursor automatically loads these rules when you work on Swift files in this project. The AI will follow these patterns and best practices when:

- Writing new code
- Suggesting improvements
- Refactoring existing code
- Answering questions about architecture

## Organization Benefits

- **Modular**: Easy to update specific topics
- **Clear**: Each file focuses on one area
- **Maintainable**: Add or remove rules without affecting others
- **Searchable**: Find specific guidance quickly

## Legacy

The root `.cursorrules` file is kept for backward compatibility but these `.mdc` files take precedence.

