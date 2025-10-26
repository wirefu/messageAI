#!/bin/bash

# Firebase Emulators Setup Script for UI Tests
# This script starts Firebase emulators for UI testing

echo "🧪 Starting Firebase Emulators for UI Tests..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "firebase.json" ]; then
    echo "❌ firebase.json not found. Please run this script from the project root."
    exit 1
fi

# Start emulators
echo "🚀 Starting Firebase emulators..."
firebase emulators:start --only auth,firestore,functions,storage

echo "✅ Firebase emulators started!"
echo "📱 Auth Emulator: http://localhost:9099"
echo "🗄️  Firestore Emulator: http://localhost:8080"
echo "⚡ Functions Emulator: http://localhost:5001"
echo "📦 Storage Emulator: http://localhost:9199"
echo "🎛️  Emulator UI: http://localhost:4000"
echo ""
echo "🧪 You can now run UI tests with:"
echo "   xcodebuild test -scheme MessageAI -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:MessageAIUITests"
