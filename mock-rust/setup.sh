#!/bin/bash

# Complete setup and test script for Rust mock server

set -e

echo "🦀 Rust Mock Server - Complete Setup"
echo "====================================="
echo ""

# Source Rust environment
source "$HOME/.cargo/env"

cd "$(dirname "$0")"

# Build all binaries
echo "📦 Building all binaries..."
cargo build --release

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📂 Available binaries:"
echo "  - mock-rust          (Main server)"
echo "  - update-covers      (Update covers from APIs)"
echo "  - fix-missing-covers (Fix broken cover URLs)"
echo ""
echo "📋 Quick Commands:"
echo ""
echo "  Start server:"
echo "    cargo run"
echo "    OR: ./start.sh"
echo "    OR: make run"
echo ""
echo "  Update covers:"
echo "    cargo run --bin update-covers"
echo "    OR: make update-covers"
echo ""
echo "  Fix missing covers:"
echo "    cargo run --bin fix-missing-covers"
echo "    OR: make fix-covers"
echo ""
echo "🎉 Setup complete! Run 'cargo run' to start."
