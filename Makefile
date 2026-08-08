SHELL := /bin/bash

CHROME_EXECUTABLE ?= /Applications/Brave Browser.app/Contents/MacOS/Brave Browser

.PHONY: help install install-core install-frontend \
	frontend dev \
	test test-core test-frontend \
	analyze arch-test clean

help:
	@echo "Available targets:"
	@echo "  make install          Install dependencies for core and frontend"
	@echo "  make frontend         Run the Flutter web app in Chrome"
	@echo "  make dev              Run the frontend in Docker (docker compose up)"
	@echo "  make test             Run tests for core and frontend"
	@echo "  make analyze          Run static analysis on all packages"
	@echo "  make arch-test        Enforce frontend's hexagonal layer boundaries"
	@echo "  make clean            Clean build artifacts for all packages"

## --- Install ---

install: install-core install-frontend

install-core:
	cd core && dart pub get

install-frontend:
	cd frontend && flutter pub get

## --- Run ---

frontend:
	cd frontend && CHROME_EXECUTABLE='$(CHROME_EXECUTABLE)' flutter run -d chrome --web-port=8081

# Build and run the frontend in Docker. Ctrl-C stops the container.
dev:
	docker compose up --build

## --- Tests ---

test: test-core test-frontend

test-core:
	cd core && dart test

test-frontend: arch-test
	cd frontend && flutter test

## --- Misc ---

analyze:
	cd core && dart analyze
	cd frontend && flutter analyze

arch-test:
	cd frontend && dart run tool/arch_test.dart

clean:
	rm -rf core/.dart_tool
	cd frontend && flutter clean
