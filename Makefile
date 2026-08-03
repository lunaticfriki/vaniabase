SHELL := /bin/bash

BACKEND_ENV := DB_HOST=localhost DB_PORT=5432 DB_NAME=vaniabase DB_USER=vaniabase DB_PASSWORD=vaniabase JWT_SECRET=dev-secret
CHROME_EXECUTABLE ?= /Applications/Brave Browser.app/Contents/MacOS/Brave Browser

.PHONY: help install install-core install-backend install-frontend \
	db db-down db-logs \
	backend frontend dev \
	test test-core test-backend test-frontend \
	analyze clean

help:
	@echo "Available targets:"
	@echo "  make install          Install dependencies for core, backend, and frontend"
	@echo "  make db               Start Postgres in the background (docker compose)"
	@echo "  make db-down          Stop Postgres"
	@echo "  make backend          Run the backend API server (needs 'make db' first)"
	@echo "  make frontend         Run the Flutter web app in Chrome"
	@echo "  make dev              Run backend and frontend together"
	@echo "  make test             Run tests for core, backend, and frontend"
	@echo "  make analyze          Run static analysis on all packages"
	@echo "  make clean            Clean build artifacts for all packages"

## --- Install ---

install: install-core install-backend install-frontend

install-core:
	cd core && dart pub get

install-backend:
	cd backend && dart pub get

install-frontend:
	cd frontend && flutter pub get

## --- Database ---

db:
	docker compose up -d postgres

db-down:
	docker compose down

db-logs:
	docker compose logs -f postgres

## --- Run ---

backend:
	cd backend && $(BACKEND_ENV) dart run bin/server.dart

frontend:
	cd frontend && CHROME_EXECUTABLE='$(CHROME_EXECUTABLE)' flutter run -d chrome

# Run backend and frontend concurrently in one terminal.
# Ctrl-C stops both (backend is killed via the EXIT trap).
dev:
	@trap 'kill 0' EXIT; \
	($(MAKE) backend) & \
	($(MAKE) frontend) & \
	wait

## --- Tests ---

test: test-core test-backend test-frontend

test-core:
	cd core && dart test

test-backend:
	cd backend && dart test

test-frontend:
	cd frontend && flutter test

## --- Misc ---

analyze:
	cd core && dart analyze
	cd backend && dart analyze
	cd frontend && flutter analyze

clean:
	rm -rf core/.dart_tool
	rm -rf backend/.dart_tool
	cd frontend && flutter clean
