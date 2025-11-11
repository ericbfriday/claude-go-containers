# Development Guide

Complete guide to developing in the claude-go-containers environment with AI-powered tools.

---

## Table of Contents

- [Development Environment](#development-environment)
- [Daily Development Workflow](#daily-development-workflow)
- [Code Writing Guidelines](#code-writing-guidelines)
- [Testing Strategy](#testing-strategy)
- [AI-Assisted Development](#ai-assisted-development)
- [Debugging Techniques](#debugging-techniques)
- [Performance Optimization](#performance-optimization)
- [Code Review Process](#code-review-process)
- [Troubleshooting](#troubleshooting)

---

## Development Environment

### Initial Setup

1. **Prerequisites Check**:
```bash
# Verify Docker is running
docker --version

# Verify VS Code with Dev Containers extension
code --version
```

2. **Container Startup**:
```bash
# VS Code Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
> Dev Containers: Reopen in Container

# Wait for build (first time: ~5 minutes)
# Subsequent starts: ~30 seconds
```

3. **Environment Verification**:
```bash
# Check all tools
go version        # Should show Go 1.24.9
claude --version  # Claude CLI
crush --version   # Crush AI
gopls version     # Language server
dlv version       # Debugger
staticcheck -version  # Linter

# Verify project setup
make help         # Show available commands
```

### Directory Structure

```
/workspace/
├── .devcontainer/          # Container configuration
│   ├── Dockerfile          # Container image definition
│   └── devcontainer.json   # VS Code integration
├── .claude.json            # Claude Code configuration
├── docs/                   # Documentation
│   ├── API_REFERENCE.md    # Function documentation
│   ├── ARCHITECTURE.md     # System design
│   ├── DEVELOPMENT_GUIDE.md # This file
│   └── go-in-2025-guide.md # Ecosystem guide
├── examples/               # Learning code
│   ├── hello.go           # Example functions
│   └── hello_test.go      # Table-driven tests
├── main.go                # Application entry point
├── go.mod                 # Module definition
├── Makefile               # Build automation
├── CLAUDE.md              # AI assistant guidance
├── README.md              # Project overview
└── QUICKSTART.md          # Getting started
```

---

## Daily Development Workflow

### Standard Development Cycle

```bash
# 1. Start your session
git status                    # Check current state
git checkout -b feature/name  # Create feature branch

# 2. Write code
# Edit files in VS Code with gopls assistance

# 3. Format code (always before committing)
make fmt                      # Or: go fmt ./...

# 4. Run tests
make test                     # Or: go test -v ./...

# 5. Check for issues
make lint                     # Or: staticcheck ./...

# 6. Build
make build                    # Creates ./app executable

# 7. Run
./app                        # Or: make run

# 8. Commit
git add .
git commit -m "feat: descriptive message"

# 9. Push
git push origin feature/name
```

### Quick Iteration Cycle

```bash
# Fast feedback loop for active development
go test -v ./examples        # Test specific package
go run main.go               # Quick run without building
go test -run TestGreet       # Run specific test
go test -v -count=1 ./...    # Disable test caching
```

---

## Code Writing Guidelines

### File Organization

**Creating New Packages**:
```bash
# 1. Create package directory
mkdir -p mypackage

# 2. Create implementation file
cat > mypackage/mypackage.go << 'EOF'
package mypackage

// Exported function: PascalCase
func ProcessData(input string) string {
    return helper(input)
}

// Unexported function: camelCase
func helper(input string) string {
    // Implementation
}
EOF

# 3. Create test file
cat > mypackage/mypackage_test.go << 'EOF'
package mypackage

import "testing"

func TestProcessData(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"basic", "test", "expected"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := ProcessData(tt.input)
            if result != tt.expected {
                t.Errorf("got %q, want %q", result, tt.expected)
            }
        })
    }
}
EOF
```

### Naming Conventions

```go
// Exported (public) - PascalCase
func ProcessRequest()     // Functions
type UserData struct{}    // Types
const MaxRetries = 3      // Constants
var GlobalConfig Config   // Variables

// Unexported (private) - camelCase
func validateInput()      // Functions
type internalState struct{}  // Types
const defaultTimeout = 30    // Constants
var httpClient *http.Client  // Variables

// Interfaces - End with "er"
type Reader interface{}
type Writer interface{}
type Processor interface{}

// Test functions - Test prefix
func TestFunctionName()
func BenchmarkFunctionName()
```

### Documentation Comments

```go
// Package mypackage provides utilities for data processing.
//
// This package demonstrates best practices for Go documentation
// with clear, concise descriptions.
package mypackage

// ProcessData transforms input according to business rules.
//
// It accepts a raw input string and returns the processed result.
// If input is empty, returns empty string.
//
// Example:
//
//     result := ProcessData("raw data")
//     fmt.Println(result) // Outputs: "processed: raw data"
//
func ProcessData(input string) string {
    // Implementation
}
```

### Error Handling Patterns

```go
// Pattern 1: Return errors
func ReadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("failed to read config: %w", err)
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("failed to parse config: %w", err)
    }

    return &cfg, nil
}

// Pattern 2: Handle once - either log OR return
func ProcessRequest(w http.ResponseWriter, r *http.Request) {
    data, err := ReadConfig("config.json")
    if err != nil {
        // Log and end request (don't return error)
        log.Printf("config error: %v", err)
        http.Error(w, "Internal error", 500)
        return
    }

    // Use data...
}

// Pattern 3: Error checking with custom types
type ValidationError struct {
    Field string
    Issue string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation failed for %s: %s", e.Field, e.Issue)
}

func ValidateUser(u User) error {
    if u.Email == "" {
        return ValidationError{"email", "required"}
    }
    return nil
}
```

---

## Testing Strategy

### Table-Driven Tests (Required Pattern)

```go
func TestGreet(t *testing.T) {
    // Define test cases
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"with name", "Alice", "Hello, Alice!"},
        {"empty name", "", "Hello, World!"},
        {"special chars", "世界", "Hello, 世界!"},
    }

    // Execute test cases
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Greet(tt.input)
            if result != tt.expected {
                t.Errorf("Greet(%q) = %q, want %q",
                    tt.input, result, tt.expected)
            }
        })
    }
}
```

### Running Tests

```bash
# Run all tests
make test                    # Verbose output
go test ./...               # Standard output

# Run specific package
go test -v ./examples

# Run specific test
go test -v -run TestGreet ./examples
go test -v -run TestGreet/empty_name  # Specific subtest

# Disable test caching
go test -v -count=1 ./...

# Run with race detector
go test -race ./...

# Coverage
make test-coverage          # Generates HTML report
go test -cover ./...        # Simple percentage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Test Organization

```go
// Internal tests (package mypackage)
// Can test unexported functions
package mypackage

func TestInternalHelper(t *testing.T) {
    result := helper("test")  // Can access unexported
    // ...
}

// External tests (package mypackage_test)
// Tests public API only
package mypackage_test

import "github.com/user/project/mypackage"

func TestPublicAPI(t *testing.T) {
    result := mypackage.ProcessData("test")
    // ...
}
```

### Benchmarking

```go
func BenchmarkGreet(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Greet("Alice")
    }
}

// Run benchmarks
go test -bench=. ./...
go test -bench=BenchmarkGreet -benchmem ./examples
```

---

## AI-Assisted Development

### Claude CLI Usage

**Quick Questions**:
```bash
# Concept explanations
claude "Explain Go interfaces"
claude "What are goroutines?"

# Code review
claude "Review this for best practices" < examples/hello.go

# Generate code
claude "Write a function to reverse a string in Go"

# Debug assistance
claude "Why might this code panic?" < myfile.go

# Best practices
claude "What's the idiomatic Go way to handle this error?"
```

### Crush AI Usage

**Interactive Sessions**:
```bash
# Start interactive session
crush

# Then in Crush:
> "Help me design a package structure for a web API"
> "Review the error handling in examples/hello.go"
> "Explain how to use context for cancellation"
> "Debug this test failure" (with LSP context)

# Single-shot usage
crush run "Explain the table-driven test pattern"

# Debug mode (more context)
crush -d
```

### AI Tool Selection Guide

| Task | Tool | Reason |
|------|------|--------|
| Syntax question | Claude CLI | Fast, simple output |
| Concept explanation | Claude CLI | Direct answer |
| Code review | Claude CLI | Pipe file, get feedback |
| Multi-step debugging | Crush | Interactive, LSP context |
| Architecture design | Crush | Back-and-forth discussion |
| Write tests | Either | Depends on complexity |
| Error explanation | Claude CLI | Quick feedback |
| Learning session | Crush | Interactive exploration |

### AI-Powered Workflow Example

```bash
# 1. Design with Crush
crush
> "I need to add HTTP handlers. What's the best structure?"
# (Interactive discussion of architecture)

# 2. Generate boilerplate with Claude
claude "Generate an HTTP handler with error handling"

# 3. Write tests (AI-assisted)
claude "Write table-driven tests for this handler" < handler.go

# 4. Review with Claude
claude "Review for Go best practices" < handler.go

# 5. Debug with Crush if issues
crush -d
> "The test is failing with nil pointer, help debug"
```

---

## Debugging Techniques

### Using Delve Debugger

```bash
# Debug main.go
dlv debug

# Debug specific test
dlv test ./examples -- -test.run TestGreet

# Common dlv commands:
# (dlv) break main.main      # Set breakpoint
# (dlv) continue             # Continue execution
# (dlv) next                 # Step over
# (dlv) step                 # Step into
# (dlv) print varName        # Print variable
# (dlv) list                 # Show source code
# (dlv) quit                 # Exit debugger
```

### Print Debugging

```go
import (
    "fmt"
    "log"
)

// Simple debug prints
fmt.Printf("DEBUG: value = %v\n", value)
fmt.Printf("DEBUG: value = %+v\n", structValue)  // With field names
fmt.Printf("DEBUG: value = %#v\n", value)         // Go syntax

// Logging
log.Printf("Processing item: %v", item)
log.Printf("Error occurred: %v", err)

// Structured logging (Go 1.21+)
import "log/slog"
logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
logger.Info("processing",
    "item", item,
    "count", count,
)
```

### Common Debugging Scenarios

**Nil Pointer Dereference**:
```go
// Problem
var data *Config
fmt.Println(data.Value)  // PANIC!

// Debug
if data == nil {
    log.Printf("DEBUG: data is nil!")
}

// Fix
if data != nil {
    fmt.Println(data.Value)
}
```

**Test Failure Investigation**:
```bash
# Run with verbose output
go test -v ./examples

# Run specific failing test
go test -v -run TestGreet/empty_name ./examples

# Add debug prints to test
func TestGreet(t *testing.T) {
    input := ""
    result := Greet(input)
    t.Logf("DEBUG: input=%q, result=%q", input, result)
    // ...
}
```

---

## Performance Optimization

### Profiling

```bash
# CPU profiling
go test -cpuprofile=cpu.prof -bench=. ./...
go tool pprof cpu.prof
# (pprof) top10      # Top 10 functions
# (pprof) list Func  # Show source
# (pprof) web        # Graphical view (needs graphviz)

# Memory profiling
go test -memprofile=mem.prof -bench=. ./...
go tool pprof mem.prof

# HTTP server profiling
import _ "net/http/pprof"

http.ListenAndServe("localhost:6060", nil)
# Visit: http://localhost:6060/debug/pprof/
# Download: go tool pprof http://localhost:6060/debug/pprof/profile
```

### Benchmarking

```go
func BenchmarkStringConcat(b *testing.B) {
    for i := 0; i < b.N; i++ {
        s := "Hello"
        for j := 0; j < 100; j++ {
            s += " World"
        }
    }
}

func BenchmarkStringBuilder(b *testing.B) {
    for i := 0; i < b.N; i++ {
        var sb strings.Builder
        sb.WriteString("Hello")
        for j := 0; j < 100; j++ {
            sb.WriteString(" World")
        }
        _ = sb.String()
    }
}

// Run comparison
go test -bench=. -benchmem ./...
```

### Common Optimizations

```go
// Pre-allocate slices
// Slow
var items []Item
for i := 0; i < 1000; i++ {
    items = append(items, Item{})  // Multiple reallocations
}

// Fast
items := make([]Item, 0, 1000)  // Pre-allocated capacity
for i := 0; i < 1000; i++ {
    items = append(items, Item{})  // No reallocation
}

// Use strings.Builder for concatenation
// Slow
s := ""
for _, word := range words {
    s += word  // Creates new string each time
}

// Fast
var sb strings.Builder
for _, word := range words {
    sb.WriteString(word)  // Efficient buffer
}
result := sb.String()
```

---

## Code Review Process

### Self-Review Checklist

Before committing:

```bash
# 1. Format code
make fmt

# 2. Run tests
make test

# 3. Run linter
make lint

# 4. Check test coverage
go test -cover ./...

# 5. AI-assisted review
claude "Review for best practices" < myfile.go

# 6. Build check
make build
```

### Code Review Focus Areas

1. **Go Idioms**: Does it follow Go conventions?
2. **Error Handling**: Are all errors handled appropriately?
3. **Testing**: Are there table-driven tests?
4. **Documentation**: Are exported items documented?
5. **Naming**: Are names clear and follow conventions?
6. **Simplicity**: Is the solution as simple as possible?

### Using AI for Code Review

```bash
# Full file review
claude "Review this Go code for best practices" < examples/hello.go

# Specific aspect review
claude "Check error handling in this code" < handler.go
claude "Review test coverage completeness" < handler_test.go

# Interactive review with Crush
crush
> "Review examples/hello.go and suggest improvements"
```

---

## Troubleshooting

### Common Issues

**Issue: Tests fail with "permission denied"**
```bash
# Solution: Check file permissions
ls -la examples/
chmod +x ./script.sh  # If script needs execution
```

**Issue: Import cycle detected**
```bash
# Solution: Reorganize packages
# Package A should not import package B if B imports A
# Consider creating a third package for shared code
```

**Issue: gopls not working in VS Code**
```bash
# Solution: Restart language server
# Command Palette: "Go: Restart Language Server"

# Or reinstall gopls
go install golang.org/x/tools/gopls@latest
```

**Issue: Tests pass individually but fail together**
```bash
# Likely: Tests sharing global state
# Solution: Use t.Parallel() carefully or remove shared state

# Disable test caching to verify
go test -count=1 ./...
```

**Issue: Race condition detected**
```bash
# Run with race detector
go test -race ./...

# Fix: Add proper synchronization
var mu sync.Mutex
mu.Lock()
// Access shared state
mu.Unlock()
```

### Getting Help

1. **Check documentation**:
   - [API_REFERENCE.md](API_REFERENCE.md) - Function docs
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System design
   - [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Ecosystem guide

2. **Use AI tools**:
   ```bash
   claude "Why might this error occur?"
   crush  # Interactive debugging session
   ```

3. **Check Go documentation**:
   ```bash
   go doc fmt.Printf
   go doc -all strings
   ```

4. **Online resources**:
   - [Go by Example](https://gobyexample.com/)
   - [Effective Go](https://go.dev/doc/effective_go)
   - [Go FAQ](https://go.dev/doc/faq)

---

## Best Practices Summary

### Do's
✅ Use table-driven tests
✅ Run `make fmt` before committing
✅ Handle all errors explicitly
✅ Document exported functions
✅ Write simple, clear code
✅ Use `make test` frequently
✅ Leverage AI tools for learning
✅ Follow Go naming conventions
✅ Keep packages focused
✅ Start simple, add complexity only when needed

### Don'ts
❌ Don't ignore errors
❌ Don't use panic for regular errors
❌ Don't create huge packages
❌ Don't over-engineer
❌ Don't skip tests
❌ Don't use generic package names (util, helpers)
❌ Don't commit unformatted code
❌ Don't write tests without table-driven structure
❌ Don't add dependencies without reason
❌ Don't forget to clean up resources

---

## Quick Reference Commands

```bash
# Development
make help           # Show available commands
make build          # Build executable
make run            # Run application
make test           # Run tests
make fmt            # Format code
make lint           # Run linter
make clean          # Clean artifacts

# Go Commands
go run main.go              # Run without building
go build -o app             # Build with custom name
go test ./...               # Test all packages
go test -v ./examples       # Verbose test output
go test -run TestName       # Run specific test
go test -bench=.            # Run benchmarks
go test -cover              # Show coverage
go test -race               # Race detection
go mod tidy                 # Clean dependencies
go fmt ./...                # Format code
go doc package.Function     # Show documentation

# AI Tools
claude "question"           # Quick AI help
crush                       # Interactive AI session
crush run "question"        # Single AI query
crush -d                    # Debug mode

# Git Workflow
git status                  # Check status
git checkout -b feature/x   # New branch
git add .                   # Stage changes
git commit -m "message"     # Commit
git push origin branch      # Push
```

---

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - AI assistant configuration
- [API_REFERENCE.md](API_REFERENCE.md) - Function documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [README.md](../README.md) - Project overview
- [QUICKSTART.md](../QUICKSTART.md) - Quick start guide
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Go ecosystem guide
