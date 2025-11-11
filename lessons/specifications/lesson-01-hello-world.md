# Lesson 01: Hello World & Basic Syntax

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 1-2 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Set up a basic Go program with proper package structure
- Understand the `main` package and `main()` function entry point
- Use `fmt` package for formatted output
- Write and run their first Go program
- Implement basic string formatting with `fmt.Sprintf`
- Follow Go naming conventions and code formatting standards
- Write table-driven tests for simple functions

## Prerequisites

- Go 1.20+ installed and configured
- Basic understanding of programming concepts (functions, variables)
- Development environment set up (VS Code or similar)
- Familiarity with command-line operations

## Core Concepts

### 1. Package Declaration
- Every Go file starts with a `package` declaration
- The `main` package is special - it defines an executable program
- Library packages use descriptive names (e.g., `examples`, `utils`)

### 2. Import Statements
- Use `import` to include external packages
- Standard library packages (e.g., `fmt`, `strings`) vs external packages
- Multiple imports use parentheses grouping
- Unused imports cause compilation errors (Go is strict)

### 3. The main() Function
- Entry point for executable programs
- Must be in the `main` package
- Signature: `func main()` with no parameters or return values

### 4. fmt Package Basics
- `fmt.Println()` - print with newline
- `fmt.Printf()` - formatted print
- `fmt.Sprintf()` - format to string (returns string, doesn't print)
- Format verbs: `%s` (string), `%d` (integer), `%v` (default format)

### 5. Go Naming Conventions
- Exported names start with uppercase (e.g., `Greet`)
- Unexported names start with lowercase (e.g., `helper`)
- Use camelCase for multi-word names
- Package names are lowercase, single word preferred

### 6. Go Idioms from Day One
- Use `go fmt` or `gofmt` for consistent formatting
- Run `go vet` to catch common mistakes
- Comments for exported functions: start with function name
- Keep functions small and focused (Single Responsibility)

## Challenge Description

### Part 1: Hello World Variations

Create a Go program that implements three greeting functions with increasing complexity:

1. **BasicGreet()**: Returns "Hello, World!"
2. **Greet(name string)**: Returns "Hello, [name]!" or "Hello, World!" if name is empty
3. **CustomGreet(name, greeting string)**: Returns "[greeting], [name]!" with defaults

### Part 2: Name Formatting

Implement a function `FormatName(first, last string) string` that:
- Combines first and last name with a space
- Handles empty strings gracefully
- Trims whitespace
- Returns "Anonymous" if both names are empty

### Part 3: Main Program

Create a `main()` function that:
- Calls all your functions with test data
- Prints results to demonstrate they work
- Shows proper program structure

## Test Requirements

Implement comprehensive table-driven tests that cover:

### BasicGreet Tests
```go
func TestBasicGreet(t *testing.T) {
    result := BasicGreet()
    expected := "Hello, World!"
    // Assert equality
}
```

### Greet Tests (Table-Driven Pattern)
```go
func TestGreet(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"with name", "Alice", "Hello, Alice!"},
        {"empty name", "", "Hello, World!"},
        {"with spaces", "  Bob  ", "Hello, Bob!"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Greet(tt.input)
            if result != tt.expected {
                t.Errorf("Greet(%q) = %q, want %q", tt.input, result, tt.expected)
            }
        })
    }
}
```

### CustomGreet Tests
- Test various greeting/name combinations
- Test with empty greeting (should default to "Hello")
- Test with empty name (should default to "World")
- Test with both empty

### FormatName Tests
- Test with both names provided
- Test with only first name
- Test with only last name
- Test with both empty (should return "Anonymous")
- Test with extra whitespace

## Input/Output Specifications

### BasicGreet
```go
Input:  (none)
Output: "Hello, World!"
```

### Greet
```go
Input:  "Alice"
Output: "Hello, Alice!"

Input:  ""
Output: "Hello, World!"

Input:  "  Bob  "
Output: "Hello, Bob!"
```

### CustomGreet
```go
Input:  greeting="Hi", name="Alice"
Output: "Hi, Alice!"

Input:  greeting="", name="Alice"
Output: "Hello, Alice!"

Input:  greeting="Hi", name=""
Output: "Hi, World!"

Input:  greeting="", name=""
Output: "Hello, World!"
```

### FormatName
```go
Input:  first="John", last="Doe"
Output: "John Doe"

Input:  first="Jane", last=""
Output: "Jane"

Input:  first="", last=""
Output: "Anonymous"

Input:  first="  Alice  ", last="  Smith  "
Output: "Alice Smith"
```

## Success Criteria

Your implementation must:

### Functional Requirements
- [ ] All functions return correct outputs for specified inputs
- [ ] Empty string handling works as specified
- [ ] Whitespace is properly trimmed
- [ ] Default values are applied correctly

### Code Quality Requirements
- [ ] Code passes `go fmt` (proper formatting)
- [ ] Code passes `go vet` (no common mistakes)
- [ ] All exported functions have documentation comments
- [ ] Documentation comments start with the function name
- [ ] Variable names are descriptive and follow Go conventions

### Testing Requirements
- [ ] All tests pass: `go test -v`
- [ ] Tests use table-driven pattern where appropriate
- [ ] Tests cover edge cases (empty strings, whitespace)
- [ ] Test names clearly describe what they test
- [ ] Subtests use `t.Run()` for better organization

### Project Structure
```
lesson-01/
├── main.go          # Main program entry point
├── greet.go         # Greeting functions
├── greet_test.go    # Tests for greeting functions
└── README.md        # Explanation of approach
```

## Common Pitfalls to Avoid

### 1. Forgetting Package Declaration
```go
// ❌ Wrong: No package declaration
import "fmt"
func main() { ... }

// ✅ Correct: Package declaration first
package main
import "fmt"
func main() { ... }
```

### 2. Unused Imports
```go
// ❌ Wrong: Importing unused packages
import (
    "fmt"
    "strings"  // Not used, will cause compile error
)

// ✅ Correct: Only import what you use
import "fmt"
```

### 3. Not Handling Empty Strings
```go
// ❌ Wrong: No empty string check
func Greet(name string) string {
    return fmt.Sprintf("Hello, %s!", name)  // Returns "Hello, !" for empty name
}

// ✅ Correct: Check for empty string
func Greet(name string) string {
    if name == "" {
        name = "World"
    }
    return fmt.Sprintf("Hello, %s!", name)
}
```

### 4. Missing Documentation Comments
```go
// ❌ Wrong: Missing or incorrect comment
// This function greets someone
func Greet(name string) string { ... }

// ✅ Correct: Comment starts with function name
// Greet returns a greeting message for the given name
func Greet(name string) string { ... }
```

### 5. Not Trimming Whitespace
```go
// ❌ Wrong: Doesn't handle extra spaces
func Greet(name string) string {
    if name == "" {
        name = "World"
    }
    return fmt.Sprintf("Hello, %s!", name)  // "  Alice  " → "Hello,   Alice  !"
}

// ✅ Correct: Trim whitespace
import "strings"
func Greet(name string) string {
    name = strings.TrimSpace(name)
    if name == "" {
        name = "World"
    }
    return fmt.Sprintf("Hello, %s!", name)
}
```

## Extension Challenges (Optional)

For learners who complete the core requirements quickly:

### 1. Capitalization Function
Implement `CapitalizeGreeting(greeting string) string` that:
- Capitalizes the first letter of the greeting
- Handles empty strings
- Preserves the rest of the string as-is

### 2. Multi-Name Greeting
Implement `GreetMany(names []string) string` that:
- Takes a slice of names
- Returns "Hello, Alice, Bob, and Charlie!"
- Handles empty slice ("Hello, World!")
- Handles single name ("Hello, Alice!")
- Handles two names ("Hello, Alice and Bob!")

### 3. Greeting Validation
Implement `IsValidGreeting(greeting string) bool` that:
- Returns true if greeting has no numbers or special characters
- Returns false for empty strings
- Returns false if greeting contains digits or punctuation

### 4. Benchmark Tests
Add benchmark tests to measure performance:
```go
func BenchmarkGreet(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Greet("Alice")
    }
}
```

## AI Provider Guidelines

### Allowed Packages
- Standard library only: `fmt`, `strings`, `testing`
- No external dependencies

### Expected Approach
1. Create separate file for greeting logic (`greet.go`)
2. Create test file using table-driven pattern (`greet_test.go`)
3. Create main program that demonstrates functionality (`main.go`)
4. Write clear documentation comments for all exported functions
5. Use `strings.TrimSpace()` for handling whitespace
6. Implement defensive checks for empty strings

### Code Quality Expectations
- Run `go fmt` before submitting
- Ensure `go vet` passes without warnings
- Follow [Effective Go](https://go.dev/doc/effective_go) guidelines
- Keep functions short and focused (< 10 lines preferred)
- Use meaningful variable names (avoid single letters except in loops)

### Testing Approach
- Use table-driven tests for functions with multiple test cases
- Include at least 3 test cases per function
- Test edge cases (empty strings, whitespace)
- Use descriptive test names
- Implement subtests with `t.Run()`

## Learning Resources

### Essential Reading
- [A Tour of Go - Basics](https://go.dev/tour/basics/1)
- [Effective Go - Formatting](https://go.dev/doc/effective_go#formatting)
- [Go by Example - Hello World](https://gobyexample.com/hello-world)

### Table-Driven Testing
- [Go Wiki - TableDrivenTests](https://github.com/golang/go/wiki/TableDrivenTests)
- [Example from standard library](https://github.com/golang/go/blob/master/src/strings/strings_test.go)

### Video Tutorials
- [Learn Go in 12 Minutes](https://www.youtube.com/watch?v=C8LgvuEBraI)
- [Go Tutorial for Beginners - FreeCodeCamp](https://www.youtube.com/watch?v=YS4e4q9oBaU)

## Validation Commands

```bash
# Format code
go fmt ./...

# Check for common mistakes
go vet ./...

# Run tests
go test -v

# Run tests with coverage
go test -cover

# Run the program
go run main.go

# Build executable
go build -o lesson01

# Run executable
./lesson01
```

---

**Next Lesson**: [Lesson 02: Variables, Data Types & Operators](lesson-02-variables.md)

**Estimated Completion Time**: 1-2 hours
**Difficulty Check**: If this takes >3 hours, review Go Tour basics first
