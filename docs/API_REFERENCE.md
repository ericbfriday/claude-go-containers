# API Reference

## Package: examples

The `examples` package provides basic Go functions demonstrating Go best practices and idiomatic patterns for learning purposes.

**Import Path:** `github.com/ericbfriday/claude-go-containers/examples`

---

### Functions

#### Greet

```go
func Greet(name string) string
```

**Description:**
Returns a personalized greeting message. If the name is empty, defaults to "World".

**Parameters:**
- `name` (string): The name to include in the greeting. If empty string, defaults to "World".

**Returns:**
- (string): A formatted greeting message in the form "Hello, {name}!"

**Examples:**
```go
// Basic usage
greeting := examples.Greet("Alice")
// Returns: "Hello, Alice!"

// Empty string handling
greeting := examples.Greet("")
// Returns: "Hello, World!"
```

**Related:**
- See [hello_test.go:5](../examples/hello_test.go#L5) for comprehensive test cases

---

#### Add

```go
func Add(a, b int) int
```

**Description:**
Returns the sum of two integers. Demonstrates basic arithmetic operations and pure function patterns.

**Parameters:**
- `a` (int): First integer
- `b` (int): Second integer

**Returns:**
- (int): The sum of a and b

**Examples:**
```go
// Basic addition
result := examples.Add(2, 3)
// Returns: 5

// Negative numbers
result := examples.Add(-2, -3)
// Returns: -5

// Mixed signs
result := examples.Add(-2, 3)
// Returns: 1
```

**Related:**
- See [hello_test.go:26](../examples/hello_test.go#L26) for comprehensive test cases

---

## Package: main

The main package provides the application entry point demonstrating the development environment setup.

**Import Path:** `github.com/ericbfriday/claude-go-containers`

---

### Functions

#### main

```go
func main()
```

**Description:**
Entry point for the application. Displays welcome message and environment information about available AI development tools.

**Parameters:** None

**Returns:** None

**Output:**
```
Hello from Go + AI Development Environment!
This workspace includes:
  • Go development tools (latest)
  • Claude CLI for quick AI assistance
  • Crush AI for interactive coding sessions

Try: 'claude --help' or 'crush --help' to get started!
```

**Related:**
- See [main.go](../main.go) for implementation
- See [QUICKSTART.md](../QUICKSTART.md) for usage instructions

---

## Testing Patterns

All packages follow Go's table-driven testing pattern. See comprehensive examples in:

- [examples/hello_test.go](../examples/hello_test.go) - Demonstrates table-driven test structure
- Run with: `go test -v ./examples` or `make test`

### Table-Driven Test Example Structure

```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    InputType
        expected OutputType
    }{
        {"test case 1", input1, expected1},
        {"test case 2", input2, expected2},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FunctionName(tt.input)
            if result != tt.expected {
                t.Errorf("got %v, want %v", result, tt.expected)
            }
        })
    }
}
```

---

## Error Handling Patterns

While current examples use simple return values, production Go code should follow these patterns:

### Returning Errors
```go
func ProcessData(input string) (string, error) {
    if input == "" {
        return "", fmt.Errorf("input cannot be empty")
    }
    // Process and return
    return result, nil
}
```

### Error Wrapping (Go 1.13+)
```go
func HighLevelFunc() error {
    if err := lowLevelFunc(); err != nil {
        return fmt.Errorf("high level operation failed: %w", err)
    }
    return nil
}
```

### Error Checking
```go
result, err := ProcessData(input)
if err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
// Use result
```

---

## Concurrency Patterns

For future development, follow these Go concurrency patterns:

### Goroutines with Context
```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

go func() {
    select {
    case <-ctx.Done():
        return
    case result := <-processChannel:
        // Handle result
    }
}()
```

### Error Group Pattern
```go
import "golang.org/x/sync/errgroup"

g, ctx := errgroup.WithContext(context.Background())

g.Go(func() error {
    return task1(ctx)
})

g.Go(func() error {
    return task2(ctx)
})

if err := g.Wait(); err != nil {
    return err
}
```

---

## References

- [Go Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Go by Example](https://gobyexample.com/)

See also:
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and structure
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Development workflows
- [CLAUDE.md](../CLAUDE.md) - AI assistant guidance
