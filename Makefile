# TenX Development Makefile
# Run 'make help' to see available commands

.PHONY: help setup generate build test lint format clean

# Default target
help:
	@echo "TenX Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup      - Install dependencies (XcodeGen, SwiftLint, SwiftFormat)"
	@echo "  make generate   - Generate Xcode project from project.yml"
	@echo ""
	@echo "Development:"
	@echo "  make build      - Build the app for iOS Simulator"
	@echo "  make test       - Run unit tests"
	@echo "  make lint       - Run SwiftLint"
	@echo "  make format     - Format code with SwiftFormat"
	@echo "  make format-check - Check formatting without modifying files"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make open       - Open project in Xcode"
	@echo ""

# Install development dependencies
setup:
	@echo "Installing dependencies..."
	brew install xcodegen swiftlint swiftformat xcbeautify || true
	@echo "Generating Xcode project..."
	xcodegen generate
	@echo "Setup complete!"

# Generate Xcode project
generate:
	xcodegen generate

# Build for iOS Simulator
build: generate
	xcodebuild build \
		-project TenX.xcodeproj \
		-scheme TenX \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		-configuration Debug \
		CODE_SIGNING_ALLOWED=NO \
		| xcbeautify

# Run tests
test: generate
	xcodebuild test \
		-project TenX.xcodeproj \
		-scheme TenX \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		-configuration Debug \
		CODE_SIGNING_ALLOWED=NO \
		| xcbeautify

# Run SwiftLint
lint:
	swiftlint lint --config .swiftlint.yml

# Fix SwiftLint issues where possible
lint-fix:
	swiftlint lint --fix --config .swiftlint.yml

# Format code with SwiftFormat
format:
	swiftformat . --config .swiftformat

# Check formatting without modifying
format-check:
	swiftformat --lint . --config .swiftformat

# Run all checks (lint + format-check)
check: lint format-check
	@echo "All checks passed!"

# Clean build artifacts
clean:
	rm -rf DerivedData
	rm -rf .build
	rm -rf TenXShared/.build
	xcodebuild clean -project TenX.xcodeproj -scheme TenX 2>/dev/null || true
	@echo "Cleaned!"

# Open in Xcode
open: generate
	open TenX.xcodeproj

# CI simulation (run what CI would run)
ci: lint format-check build test
	@echo "CI simulation complete!"

# Install pre-commit hook
install-hooks:
	@echo "Installing pre-commit hook..."
	@mkdir -p .git/hooks
	@echo '#!/bin/sh' > .git/hooks/pre-commit
	@echo 'set -e' >> .git/hooks/pre-commit
	@echo 'echo "Running pre-commit checks..."' >> .git/hooks/pre-commit
	@echo 'make lint' >> .git/hooks/pre-commit
	@echo 'make format-check' >> .git/hooks/pre-commit
	@echo 'echo "Pre-commit checks passed!"' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed!"

# Uninstall pre-commit hook
uninstall-hooks:
	rm -f .git/hooks/pre-commit
	@echo "Pre-commit hook removed!"
