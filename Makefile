# Makefile for Lux Netrunner SDK

# Variables
VERSION := $(shell git describe --tags --always --dirty="-dev" 2>/dev/null || echo "unknown")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date +%FT%T%z)

# Go build flags
GOARCH := $(shell go env GOARCH)
GOOS := $(shell go env GOOS)

# Proto files
PROTO_DIR := proto
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto' 2>/dev/null)

# Default target
.PHONY: all
all: proto test

# Generate protobuf code
.PHONY: proto
proto:
	@echo "Generating protobuf code..."
	@if [ -f ./genproto.sh ]; then \
		./genproto.sh; \
	else \
		echo "Warning: genproto.sh not found, skipping proto generation"; \
	fi

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	go test -v ./...

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests with race detector
.PHONY: test-race
test-race:
	@echo "Running tests with race detector..."
	go test -race -v ./...

# Run specific test package
.PHONY: test-pkg
test-pkg:
	@if [ -z "$(PKG)" ]; then \
		echo "Usage: make test-pkg PKG=<package>"; \
		exit 1; \
	fi
	@echo "Testing package: $(PKG)"
	go test -v ./$(PKG)/...

# Run benchmarks
.PHONY: bench
bench:
	@echo "Running benchmarks..."
	go test -bench=. -benchmem ./...

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Run linter
.PHONY: lint
lint:
	@echo "Running linter..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
		exit 1; \
	fi

# Generate mocks
.PHONY: mocks
mocks:
	@echo "Generating mocks..."
	@if command -v mockgen >/dev/null 2>&1; then \
		go generate ./...; \
	else \
		echo "mockgen not installed. Install with: go install github.com/golang/mock/mockgen@latest"; \
		exit 1; \
	fi

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -f coverage.out coverage.html
	@echo "Clean complete"

# Run security checks
.PHONY: security
security:
	@echo "Running security checks..."
	@if command -v gosec >/dev/null 2>&1; then \
		gosec ./...; \
	else \
		echo "gosec not installed. Install with: go install github.com/securego/gosec/v2/cmd/gosec@latest"; \
		exit 1; \
	fi

# Run static analysis
.PHONY: staticcheck
staticcheck:
	@echo "Running static analysis..."
	@if command -v staticcheck >/dev/null 2>&1; then \
		staticcheck ./...; \
	else \
		echo "staticcheck not installed. Install with: go install honnef.co/go/tools/cmd/staticcheck@latest"; \
		exit 1; \
	fi

# Update dependencies
.PHONY: deps
deps:
	@echo "Updating dependencies..."
	go mod download
	go mod tidy

# Verify dependencies
.PHONY: verify
verify:
	@echo "Verifying dependencies..."
	go mod verify

# Run all checks (fmt, lint, test)
.PHONY: check
check: fmt lint test

# Check for outdated dependencies
.PHONY: deps-check
deps-check:
	@echo "Checking for outdated dependencies..."
	@if command -v go-mod-outdated >/dev/null 2>&1; then \
		go list -u -m -json all | go-mod-outdated -update -direct; \
	else \
		echo "go-mod-outdated not installed. Install with: go install github.com/psampaz/go-mod-outdated@latest"; \
		go list -u -m all; \
	fi

# Install required tools
.PHONY: tools
tools:
	@echo "Installing required tools..."
	@go install github.com/golang/mock/mockgen@latest
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@go install honnef.co/go/tools/cmd/staticcheck@latest
	@go install github.com/securego/gosec/v2/cmd/gosec@latest
	@go install github.com/psampaz/go-mod-outdated@latest
	@echo "Tools installed"

# Generate documentation
.PHONY: docs
docs:
	@echo "Generating documentation..."
	@if command -v godoc >/dev/null 2>&1; then \
		echo "Documentation server starting at http://localhost:6060"; \
		godoc -http=:6060; \
	else \
		echo "godoc not installed. Install with: go install golang.org/x/tools/cmd/godoc@latest"; \
		exit 1; \
	fi

# Display version information
.PHONY: version
version:
	@echo "Lux Netrunner SDK"
	@echo "Version: $(VERSION)"
	@echo "Commit: $(COMMIT)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Go Version: $(shell go version)"
	@echo "OS/Arch: $(GOOS)/$(GOARCH)"

# List all available targets
.PHONY: list
list:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Help message
.PHONY: help
help:
	@echo "Lux Netrunner SDK Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all          - Generate proto and run tests (default)"
	@echo "  proto        - Generate protobuf code"
	@echo "  test         - Run tests"
	@echo "  test-coverage - Run tests with coverage report"
	@echo "  test-race    - Run tests with race detector"
	@echo "  test-pkg     - Run tests for specific package (PKG=path/to/pkg)"
	@echo "  bench        - Run benchmarks"
	@echo "  fmt          - Format code"
	@echo "  lint         - Run linter"
	@echo "  mocks        - Generate mocks"
	@echo "  clean        - Clean build artifacts"
	@echo "  security     - Run security checks"
	@echo "  staticcheck  - Run static analysis"
	@echo "  deps         - Update dependencies"
	@echo "  verify       - Verify dependencies"
	@echo "  check        - Run fmt, lint, and test"
	@echo "  deps-check   - Check for outdated dependencies"
	@echo "  tools        - Install required development tools"
	@echo "  docs         - Start documentation server"
	@echo "  version      - Display version information"
	@echo "  list         - List all available targets"
	@echo "  help         - Display this help message"