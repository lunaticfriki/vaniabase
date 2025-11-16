.PHONY: help build run release test clean start watch

help: ## Show this help message
	@echo "Rust Mock Server - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build in debug mode
	cargo build

release: ## Build in release mode (optimized)
	cargo build --release

run: ## Run the server in debug mode
	cargo run

start: release ## Build and run in release mode
	cargo run --release

update-covers: ## Run the update-covers script
	cargo run --bin update-covers

fix-covers: ## Run the fix-missing-covers script
	cargo run --bin fix-missing-covers

test: ## Run all tests
	cargo test

test-verbose: ## Run tests with output
	cargo test -- --nocapture

integration-test: ## Run the integration test script
	./test.sh

watch: ## Run with auto-reload on file changes (requires cargo-watch)
	cargo watch -x run

watch-test: ## Run tests on file changes
	cargo watch -x test

clean: ## Clean build artifacts
	cargo clean

check: ## Check for errors without building
	cargo check

fmt: ## Format code
	cargo fmt

install-watch: ## Install cargo-watch for development
	cargo install cargo-watch
