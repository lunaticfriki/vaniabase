#!/bin/bash

# Quick start script for the Rust mock server

echo "🦀 Starting Rust Mock Server..."
echo ""

# Source Rust environment
source "$HOME/.cargo/env"

cd "$(dirname "$0")"

# Run the server (default binary is mock-rust)
cargo run --release
