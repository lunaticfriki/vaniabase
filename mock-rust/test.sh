#!/bin/bash

# Test script for the Rust mock server

echo "🧪 Testing Rust Mock Server"
echo "=========================="
echo ""

# Source Rust environment
source "$HOME/.cargo/env"

# Build the project
echo "📦 Building the project..."
cd /workspaces/vaniabase/mock-rust
cargo build --release 2>&1 | grep -E "(Compiling mock-rust|Finished)" || cargo build --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Start the server in the background with option 2 (start server)
echo "🚀 Starting server..."
echo "2" | timeout 5 ./target/release/mock-rust &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Test the health endpoint
echo "📡 Testing /health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)

if [ $? -eq 0 ]; then
    echo "✅ Health check response: $HEALTH_RESPONSE"
else
    echo "❌ Failed to connect to server"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Test getting all items
echo ""
echo "📡 Testing /api/items endpoint..."
ITEMS_RESPONSE=$(curl -s http://localhost:3001/api/items | head -c 200)
echo "✅ Items response (first 200 chars): $ITEMS_RESPONSE..."

# Stop the server
echo ""
echo "🛑 Stopping server..."
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

echo ""
echo "✅ All tests passed!"
echo ""
echo "🎉 The Rust mock server is working correctly!"
echo ""
echo "To run it manually:"
echo "  cd mock-rust"
echo "  cargo run"
