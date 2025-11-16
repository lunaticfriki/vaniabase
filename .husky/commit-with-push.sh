#!/bin/bash

# Interactive commit script with type selection and testing

echo ""
echo "🚀 Interactive Commit Helper"
echo "=============================="
echo ""

# Commit type selection
echo "Select commit type:"
echo "1) feat     - A new feature"
echo "2) fix      - A bug fix"
echo "3) refactor - Code refactoring"
echo "4) test     - Adding or updating tests"
echo "5) docs     - Documentation changes"
echo "6) style    - Code style changes (formatting, etc.)"
echo "7) chore    - Maintenance tasks"
echo "8) perf     - Performance improvements"
echo ""
read -p "Enter number (1-8): " type_choice

case $type_choice in
    1) commit_type="feat";;
    2) commit_type="fix";;
    3) commit_type="refactor";;
    4) commit_type="test";;
    5) commit_type="docs";;
    6) commit_type="style";;
    7) commit_type="chore";;
    8) commit_type="perf";;
    *) echo "❌ Invalid choice. Aborting."; exit 1;;
esac

echo ""
read -p "Enter commit description: " commit_description

if [ -z "$commit_description" ]; then
    echo "❌ Commit description cannot be empty. Aborting."
    exit 1
fi

# Format the commit message
commit_message="${commit_type}: ${commit_description}"

echo ""
echo "📋 Commit message: $commit_message"
echo ""

# Run tests
echo "🧪 Running tests..."
pnpm test:ci

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Tests failed! Commit aborted."
    exit 1
fi

echo ""
echo "✅ Tests passed!"
echo ""

# Stage all changes
echo "📦 Staging changes..."
git add .

# Commit
echo "💾 Creating commit..."
git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Commit created successfully!"
    git push
else
    echo ""
    echo "❌ Commit failed!"
    exit 1
fi
