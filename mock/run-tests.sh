#!/bin/bash

# Mock Server Test Runner
# This script helps run the mock server tests with proper setup

echo "🧪 Mock Server Test Runner"
echo "=========================="
echo ""

# Check if the server is already running
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Mock server is already running"
    echo ""
    echo "Running tests..."
    echo ""
    pnpm test:mock
else
    echo "⚠️  Mock server is not running"
    echo ""
    echo "Please start the mock server in another terminal:"
    echo "  pnpm mock:server"
    echo "  (Then select option 2 to start the server)"
    echo ""
    echo "After the server is running, run this script again:"
    echo "  ./mock/run-tests.sh"
    echo ""
    exit 1
fi
