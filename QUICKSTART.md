# Quick Start Guide

Welcome to AI-powered Go development! This guide will help you get started quickly with Go programming using Claude CLI and OpenCode AI.

## First Steps

### 1. Verify Your Setup

Open a terminal in VS Code (inside the dev container) and run:

```bash
# Check Go installation
go version

# Check Claude CLI
claude --version

# Check OpenCode AI
opencode --version
```

### 2. Run Your First Go Program

```bash
# Run the main program
go run main.go
```

You should see:
```
Hello from Go + AI Development Environment!
This workspace includes:
  • Go development tools (latest)
  • Claude CLI for quick AI assistance
  • OpenCode AI for terminal-based coding workflows

Try: 'claude --help' or 'opencode --help' to get started!
```

### 3. Run Tests

```bash
# Run all tests
go test ./...

# Run with verbose output
go test -v ./...
```

## Basic Go Concepts

### Variables and Types

```go
// Variable declaration
var name string = "Alice"
age := 25  // Short declaration with type inference

// Basic types
var integer int = 42
var floating float64 = 3.14
var boolean bool = true
var text string = "Hello"
```

### Functions

```go
// Simple function
func greet(name string) string {
    return "Hello, " + name
}

// Multiple return values
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}
```

### Loops

```go
// For loop (the only loop in Go!)
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

// While-style loop
for condition {
    // do something
}

// Infinite loop
for {
    // do something forever
}
```

### Working with Slices

```go
// Create a slice
numbers := []int{1, 2, 3, 4, 5}

// Append to slice
numbers = append(numbers, 6)

// Iterate over slice
for i, num := range numbers {
    fmt.Printf("Index %d: %d\n", i, num)
}
```

## Common Tasks

### Create a New Package

```bash
# Create directory
mkdir mypackage

# Create file
cat > mypackage/mypackage.go << 'EOF'
package mypackage

func MyFunction() string {
    return "Hello from my package!"
}
EOF

# Create test file
cat > mypackage/mypackage_test.go << 'EOF'
package mypackage

import "testing"

func TestMyFunction(t *testing.T) {
    result := MyFunction()
    expected := "Hello from my package!"
    if result != expected {
        t.Errorf("got %q, want %q", result, expected)
    }
}
EOF
```

### Add a Dependency

```bash
# Add a popular package (example: gorilla/mux)
go get github.com/gorilla/mux

# Update go.mod and go.sum
go mod tidy
```

### Format Your Code

```bash
# Format all Go files
go fmt ./...

# Or use the Makefile
make fmt
```

### Build and Run

```bash
# Build the binary
go build -o myapp

# Run it
./myapp

# Or use the Makefile
make build
make run
```

## AI-Powered Learning Tools

### Claude CLI - Quick Questions

Use Claude CLI for fast, one-off questions:

```bash
# Learn about a concept
claude "Explain goroutines and channels in Go"

# Get code examples
claude "Show me examples of error handling in Go"

# Understand syntax
claude "What's the difference between := and var in Go?"

# Review your code
claude "Review this code for best practices" < examples/hello.go

# Debug issues
claude "Why might this code cause a panic?" < main.go
```

### OpenCode AI - Interactive Coding

Use OpenCode for AI-powered coding workflows:

```bash
# Start interactive coding session
opencode

# Work with specific file
opencode examples/hello.go

# Get help
opencode --help
```

**With OpenCode, you can:**
- Get AI assistance in your coding workflow
- Leverage LSP integration for Go code understanding
- Work with context-aware AI suggestions
- Analyze code structure and patterns
- Debug issues with AI assistance

### When to Use Which Tool

- **Claude CLI**: Quick questions, code reviews, generating snippets
- **OpenCode**: AI-powered coding workflows, interactive development, code analysis

## Next Steps

1. **Explore the Examples**: Look at `examples/hello.go` and `examples/hello_test.go`
2. **Modify the Code**: Change the functions and see what happens
3. **Write Tests**: Practice test-driven development
4. **Use AI Tools**: Use Claude CLI for quick questions, OpenCode for interactive workflows
5. **Build Something**: Create your own package or small project

## Resources

- [Official Go Documentation](https://go.dev/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Tour](https://go.dev/tour/)

## Getting Help

- Use `claude "your question"` for quick AI assistance
- Use `opencode` for AI-powered coding workflows
- See [OPENCODE_SETUP.md](docs/guides/OPENCODE_SETUP.md) for detailed AI tools guide
- Check `make help` for available commands
- Read the main [README.md](README.md) for detailed information
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

Happy coding! 🚀
