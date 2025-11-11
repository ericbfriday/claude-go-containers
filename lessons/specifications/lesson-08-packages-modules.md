# Lesson 08: Packages & Modules

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 2-3 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Organize code into packages for modularity and reusability
- Understand the difference between exported and unexported identifiers
- Create and use internal packages for package-private code
- Initialize Go modules with go.mod and manage dependencies
- Use go.sum for dependency verification and security
- Import and use third-party packages
- Apply semantic versioning for module versions
- Structure multi-package projects following Go conventions
- Build reusable libraries and command-line applications

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Completed Lesson 03: Control Flow - If, Switch, Loops
- Completed Lesson 04: Functions & Multiple Returns
- Completed Lesson 05: Structs & Methods
- Completed Lesson 06: Interfaces & Polymorphism
- Completed Lesson 07: Error Handling Patterns
- Understanding of code organization and modularity concepts

## Core Concepts

### 1. Package Basics

**Package Declaration:**
```go
// Every Go file starts with package declaration
package calculator

// Package name should match directory name
// Package main is special - creates executable
```

**Exported vs Unexported:**
```go
package mathutils

// Exported (starts with uppercase)
func Add(a, b int) int {
    return a + b
}

// Exported constant
const Pi = 3.14159

// Unexported (starts with lowercase)
func multiply(a, b int) int {
    return a * b
}

// Can use unexported within package
func Square(n int) int {
    return multiply(n, n)
}
```

### 2. Package Organization

**Standard Layout:**
```
myproject/
├── go.mod
├── go.sum
├── main.go                 # Main package (executable)
├── calculator/             # Package calculator
│   ├── calculator.go
│   └── calculator_test.go
├── utils/                  # Package utils
│   ├── strings.go
│   └── math.go
└── internal/               # Internal packages (private)
    └── helpers/
        └── helpers.go
```

**Import Paths:**
```go
// Importing from standard library
import (
    "fmt"
    "strings"
    "time"
)

// Importing from your module
import (
    "myproject/calculator"
    "myproject/utils"
)

// Import with alias
import (
    calc "myproject/calculator"
    str "strings"
)

// Blank import (for side effects, e.g., database drivers)
import _ "github.com/lib/pq"
```

### 3. Go Modules

**Initializing a Module:**
```bash
# Create new module
go mod init github.com/username/myproject

# Creates go.mod file:
# module github.com/username/myproject
#
# go 1.21
```

**go.mod File:**
```go
module github.com/username/myproject

go 1.21

require (
    github.com/gorilla/mux v1.8.0
    github.com/stretchr/testify v1.8.4
)

replace github.com/example/old => github.com/example/new v1.2.3

exclude github.com/broken/package v1.0.0
```

**Managing Dependencies:**
```bash
# Add dependency (automatically updates go.mod)
go get github.com/gorilla/mux

# Add specific version
go get github.com/gorilla/mux@v1.8.0

# Update all dependencies
go get -u ./...

# Remove unused dependencies
go mod tidy

# Verify dependencies
go mod verify

# Download dependencies
go mod download
```

### 4. Internal Packages

**Package Privacy:**
```
myproject/
├── main.go
├── internal/
│   └── auth/
│       └── auth.go        # Only accessible within myproject
└── pkg/
    └── calculator/
        └── calculator.go  # Publicly accessible
```

```go
// internal/auth/auth.go
package auth

// Only accessible within parent module
func ValidateToken(token string) bool {
    return true
}

// This can be imported by myproject/main.go
// But NOT by external packages
```

### 5. Package Initialization

**init() Function:**
```go
package config

import "fmt"

var Settings map[string]string

// init runs automatically before main
func init() {
    fmt.Println("Initializing config package")
    Settings = make(map[string]string)
    Settings["env"] = "development"
}

// Multiple init functions execute in order
func init() {
    fmt.Println("Second init")
}
```

**Import Order:**
1. Imported packages initialized first
2. Package-level variables initialized
3. init() functions executed
4. main() function runs (in main package)

### 6. Semantic Versioning

**Version Format:**
```
vMAJOR.MINOR.PATCH

v1.2.3
│ │ │
│ │ └─ Patch: Bug fixes (backwards compatible)
│ └─── Minor: New features (backwards compatible)
└───── Major: Breaking changes
```

**Version Tags:**
```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0

# Pre-release versions
git tag v2.0.0-beta.1
git tag v2.0.0-rc.1

# Import specific version
go get github.com/user/package@v1.2.3
```

### 7. Module Best Practices

**Module Path:**
```go
// Use domain/username/project format
module github.com/username/myproject
module gitlab.com/company/service
module example.com/mymodule
```

**Package Naming:**
- Use lowercase, no underscores
- Short, concise names
- Singular form (http, not https)
- Match directory name
- Avoid stutter (http.HTTPServer → http.Server)

**Directory Structure:**
```
myproject/
├── cmd/                    # Command-line applications
│   ├── server/
│   │   └── main.go
│   └── cli/
│       └── main.go
├── pkg/                    # Public libraries
│   └── calculator/
├── internal/               # Private code
│   └── database/
├── api/                    # API definitions
├── web/                    # Web assets
├── configs/                # Configuration files
├── scripts/                # Build/dev scripts
├── docs/                   # Documentation
└── tests/                  # Integration tests
```

## Challenge Description

### Part 1: Multi-Package Calculator

Create a calculator project with multiple packages:

```
calculator-project/
├── go.mod
├── main.go
├── calc/
│   ├── basic.go          # Basic operations
│   └── basic_test.go
├── stats/
│   ├── stats.go          # Statistics functions
│   └── stats_test.go
└── utils/
    ├── format.go         # Formatting utilities
    └── format_test.go
```

**calc/basic.go:**
```go
package calc

// Add returns the sum of two numbers
func Add(a, b float64) float64

// Subtract returns the difference
func Subtract(a, b float64) float64

// Multiply returns the product
func Multiply(a, b float64) float64

// Divide returns quotient and error
func Divide(a, b float64) (float64, error)

// Power returns a raised to power b
func Power(a, b float64) float64
```

**stats/stats.go:**
```go
package stats

// Mean calculates average
func Mean(numbers []float64) float64

// Median finds the middle value
func Median(numbers []float64) float64

// Mode finds most frequent value
func Mode(numbers []float64) float64

// StandardDeviation calculates std dev
func StandardDeviation(numbers []float64) float64

// Range returns min and max
func Range(numbers []float64) (min, max float64)
```

**utils/format.go:**
```go
package utils

// FormatNumber formats with specified decimals
func FormatNumber(num float64, decimals int) string

// FormatCurrency formats as currency
func FormatCurrency(amount float64, symbol string) string

// FormatPercent formats as percentage
func FormatPercent(value float64) string

// ParseNumber parses string to float64
func ParseNumber(str string) (float64, error)
```

**main.go:**
```go
package main

import (
    "calculator-project/calc"
    "calculator-project/stats"
    "calculator-project/utils"
)

func main() {
    // Interactive calculator CLI
    // Uses all three packages
}
```

### Part 2: Reusable Utility Package

Create a general-purpose utility library:

```
goutils/
├── go.mod
├── strings/
│   ├── strings.go
│   └── strings_test.go
├── slices/
│   ├── slices.go
│   └── slices_test.go
├── maps/
│   ├── maps.go
│   └── maps_test.go
└── files/
    ├── files.go
    └── files_test.go
```

**strings/strings.go:**
```go
package strings

// Reverse reverses a string
func Reverse(s string) string

// IsPalindrome checks if string is palindrome
func IsPalindrome(s string) bool

// Capitalize capitalizes first letter
func Capitalize(s string) string

// CountWords counts words in string
func CountWords(s string) int

// Truncate truncates string to length
func Truncate(s string, maxLen int) string
```

**slices/slices.go:**
```go
package slices

// Contains checks if slice contains value
func Contains[T comparable](slice []T, value T) bool

// Unique returns slice with unique values
func Unique[T comparable](slice []T) []T

// Reverse reverses a slice
func Reverse[T any](slice []T) []T

// Chunk splits slice into chunks
func Chunk[T any](slice []T, size int) [][]T

// Filter filters slice by predicate
func Filter[T any](slice []T, predicate func(T) bool) []T
```

**maps/maps.go:**
```go
package maps

// Keys returns all map keys
func Keys[K comparable, V any](m map[K]V) []K

// Values returns all map values
func Values[K comparable, V any](m map[K]V) []V

// Invert swaps keys and values
func Invert[K, V comparable](m map[K]V) map[V]K

// Merge combines multiple maps
func Merge[K comparable, V any](maps ...map[K]V) map[K]V

// Filter filters map by predicate
func Filter[K comparable, V any](m map[K]V, predicate func(K, V) bool) map[K]V
```

**files/files.go:**
```go
package files

// ReadLines reads file into slice of lines
func ReadLines(filename string) ([]string, error)

// WriteLines writes lines to file
func WriteLines(filename string, lines []string) error

// FileExists checks if file exists
func FileExists(filename string) bool

// CopyFile copies file from src to dst
func CopyFile(src, dst string) error

// ListFiles lists files in directory
func ListFiles(dir string) ([]string, error)
```

### Part 3: Internal Package Architecture

Create a project with internal packages:

```
webapp/
├── go.mod
├── main.go
├── internal/
│   ├── config/
│   │   └── config.go     # Private config
│   ├── database/
│   │   └── db.go         # Private DB
│   └── auth/
│       └── auth.go       # Private auth
└── api/
    ├── handlers.go        # Public API
    └── middleware.go
```

**internal/config/config.go:**
```go
package config

type Config struct {
    Port       int
    DBHost     string
    DBPort     int
    SecretKey  string
}

// LoadConfig loads configuration
func LoadConfig(filename string) (*Config, error)

// Validate validates configuration
func (c *Config) Validate() error
```

**internal/database/db.go:**
```go
package database

type DB struct {
    // Unexported fields
}

// Connect establishes database connection
func Connect(host string, port int) (*DB, error)

// Close closes database connection
func (db *DB) Close() error

// Query executes a query
func (db *DB) Query(sql string) ([]map[string]interface{}, error)
```

**api/handlers.go (public):**
```go
package api

// Handler is public interface
type Handler interface {
    HandleRequest(req Request) Response
}

// NewHandler creates new handler
func NewHandler(config Config) Handler

// Request represents API request
type Request struct {
    Method string
    Path   string
    Body   []byte
}

// Response represents API response
type Response struct {
    Status int
    Body   []byte
}
```

### Part 4: Module with Dependencies

Create a module that uses third-party packages:

```bash
# Initialize module
go mod init github.com/username/quotes-api

# Add dependencies
go get github.com/gorilla/mux
go get github.com/stretchr/testify
```

**Project structure:**
```
quotes-api/
├── go.mod
├── go.sum
├── main.go
├── quotes/
│   ├── quotes.go
│   └── quotes_test.go
└── server/
    ├── server.go
    └── routes.go
```

**Implement:**
- HTTP server using gorilla/mux
- Quote storage and retrieval
- Tests using testify assertions
- Proper error handling
- Package documentation

### Part 5: Phase 1 Milestone - Quiz Game

**🎯 MILESTONE PROJECT: Combine Lessons 1-8**

Build a complete quiz game application demonstrating all Phase 1 concepts:

```
quiz-game/
├── go.mod
├── main.go               # Entry point
├── quiz/
│   ├── question.go       # Question struct
│   ├── quiz.go           # Quiz logic
│   └── quiz_test.go
├── score/
│   ├── score.go          # Score tracking
│   └── score_test.go
├── file/
│   ├── loader.go         # CSV loading
│   └── loader_test.go
└── internal/
    └── ui/
        └── display.go    # Display formatting
```

**Requirements:**
- Load questions from CSV file
- Track player scores
- Multiple choice questions
- Timed quiz option
- Score statistics (mean, high score)
- Difficulty levels
- Error handling throughout
- Full test coverage
- Package documentation

**Features to Demonstrate:**
- [ ] Packages and imports (Lesson 8)
- [ ] Structs for questions, quiz, score (Lesson 5)
- [ ] Methods on structs (Lesson 5)
- [ ] Interfaces for question types (Lesson 6)
- [ ] Error handling with custom errors (Lesson 7)
- [ ] Functions with multiple returns (Lesson 4)
- [ ] Control flow (loops, conditionals) (Lesson 3)
- [ ] Variables and data types (Lesson 2)
- [ ] File I/O and CSV parsing
- [ ] User input and output (Lesson 1)
- [ ] Table-driven tests for all packages

## Test Requirements

### Package Tests

```go
// calc/basic_test.go
package calc

import "testing"

func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     float64
        expected float64
    }{
        {"positive", 2, 3, 5},
        {"negative", -2, 3, 1},
        {"zero", 0, 5, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%.2f, %.2f) = %.2f, want %.2f",
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

### Integration Tests

Test cross-package functionality:
```go
func TestCalculatorIntegration(t *testing.T) {
    // Test using calc, stats, and utils together
    result := calc.Add(5, 10)
    formatted := utils.FormatNumber(result, 2)

    if formatted != "15.00" {
        t.Errorf("Integration failed: got %s", formatted)
    }
}
```

### Module Tests

- Test imported dependencies work correctly
- Verify go.mod and go.sum are up to date
- Test that internal packages are truly private
- Verify all exported functions have tests

## Input/Output Specifications

### Calculator Package

```go
calc.Add(2, 3)              → 5.0
calc.Divide(10, 0)          → 0, error
stats.Mean([]float64{1,2,3}) → 2.0
utils.FormatCurrency(99.99, "$") → "$99.99"
```

### Utility Package

```go
strings.Reverse("hello")         → "olleh"
strings.IsPalindrome("racecar")  → true
slices.Unique([]int{1,2,2,3})    → []int{1,2,3}
maps.Keys(map[string]int{"a":1}) → []string{"a"}
```

### Quiz Game

```
Welcome to Quiz Game!
Loading questions... 10 questions loaded

Question 1/10: What is 2+2?
a) 3
b) 4
c) 5
d) 6

Your answer: b
Correct! ✓

Score: 1/1
Time remaining: 58 seconds

[... more questions ...]

Quiz Complete!
Final Score: 8/10 (80%)
Time: 2m 15s
```

## Success Criteria

### Functional Requirements
- [ ] Packages properly organized by functionality
- [ ] Exported/unexported identifiers used correctly
- [ ] go.mod contains all dependencies
- [ ] Internal packages are package-private
- [ ] All packages have tests
- [ ] Documentation for exported functions
- [ ] Quiz Game milestone fully functional

### Code Quality Requirements
- [ ] Package names are lowercase, singular
- [ ] No circular dependencies
- [ ] Clear separation of concerns
- [ ] Consistent package structure
- [ ] go fmt applied to all files
- [ ] go vet passes
- [ ] go mod tidy doesn't change files

### Testing Requirements
- [ ] Each package has *_test.go files
- [ ] Table-driven tests for functions
- [ ] Integration tests for package interactions
- [ ] Quiz Game has >80% test coverage
- [ ] All tests pass with go test ./...

## Common Pitfalls to Avoid

### 1. Package Naming Issues

```go
// ❌ Wrong: Package name doesn't match directory
// Directory: stringutils
package string_utils  // Should be stringutils

// ❌ Wrong: Stuttering names
package http
func HTTPServer() {}  // http.HTTPServer - stutters

// ✅ Correct
package http
func Server() {}      // http.Server - clean
```

### 2. Circular Dependencies

```go
// ❌ Wrong: Circular dependency
// package user imports package account
// package account imports package user
// Compile error!

// ✅ Correct: Use interfaces or extract common types
// package types (neither user nor account)
// Both user and account import types
```

### 3. Not Using go mod tidy

```bash
# ❌ Wrong: Leaving unused dependencies
# go.mod has packages you don't use

# ✅ Correct: Clean up regularly
go mod tidy  # Removes unused, adds missing
```

### 4. Hardcoding Import Paths

```go
// ❌ Wrong: Hardcoded import
import "myproject/pkg/calculator"

// If you rename module, imports break

// ✅ Correct: Use module path from go.mod
// go.mod: module github.com/user/myproject
import "github.com/user/myproject/pkg/calculator"
```

### 5. Exposing Internal Details

```go
// ❌ Wrong: Exposing internal state
package user

type User struct {
    ID       int
    Password string  // Exported password!
}

// ✅ Correct: Hide sensitive fields
type User struct {
    ID       int
    password string  // Unexported
}

func (u *User) SetPassword(pwd string) error {
    // Validation logic
    u.password = hashPassword(pwd)
    return nil
}
```

### 6. Not Using internal/ for Private Code

```go
// ❌ Wrong: No internal/ directory
myproject/
├── sensitive/
│   └── secrets.go    # Anyone can import this!

// ✅ Correct: Use internal/
myproject/
├── internal/
│   └── sensitive/
│       └── secrets.go  # Only myproject can import
```

## Extension Challenges (Optional)

### 1. Plugin System
Create a plugin architecture where packages can register and discover plugins.

### 2. Multi-Module Workspace
Use Go workspaces (go.work) to develop multiple related modules together.

### 3. Documentation Site
Generate and publish package documentation using godoc.

### 4. Performance Benchmarks
Add benchmark tests for all utility functions.

### 5. Release Automation
Create scripts to tag versions and publish releases.

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `strings`, `os`, `testing`, `encoding/csv`, `time`
- Third-party (for module exercise): `github.com/gorilla/mux`, `github.com/stretchr/testify`

### Expected Approach
1. Create multi-package project structure
2. Demonstrate exported/unexported identifiers
3. Show proper import usage
4. Initialize go.mod and add dependencies
5. Create internal packages for private code
6. Write tests for all packages
7. Build complete Quiz Game milestone
8. Document all exported functions

### Code Quality Expectations
- Proper package organization
- Clear package documentation
- Consistent naming conventions
- No circular dependencies
- All packages tested
- go.mod kept clean with go mod tidy
- Comments for all exported identifiers

### Testing Approach
- Unit tests for each package
- Integration tests across packages
- Table-driven tests
- Test internal package restrictions
- Quiz Game has comprehensive tests
- All tests pass with go test ./...

## Learning Resources

### Essential Reading
- [How to Write Go Code](https://go.dev/doc/code)
- [Go Modules Reference](https://go.dev/ref/mod)
- [Organizing a Go module](https://go.dev/doc/modules/layout)
- [Go by Example - Packages](https://gobyexample.com/packages)
- [Effective Go - Package names](https://go.dev/doc/effective_go#package-names)

### Specific Topics
- [Go Modules](https://go.dev/blog/using-go-modules)
- [Module versioning](https://go.dev/doc/modules/version-numbers)
- [Internal packages](https://go.dev/doc/go1.4#internalpackages)
- [Package naming conventions](https://go.dev/blog/package-names)

### Practice Problems
- [Go Modules Tutorial](https://go.dev/doc/tutorial/create-module)
- [Exercism Go Track](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/)

## Validation Commands

```bash
# Format all packages
go fmt ./...

# Vet all packages
go vet ./...

# Test all packages
go test ./...

# Test with coverage
go test -cover ./...

# Test specific package
go test ./calc

# Clean up dependencies
go mod tidy

# Verify dependencies
go mod verify

# List all dependencies
go list -m all

# Build all commands
go build ./...

# Install commands
go install ./cmd/...

# Run Quiz Game
go run main.go
```

## Milestone Validation

### Quiz Game Requirements Checklist

**Core Functionality:**
- [ ] Loads questions from CSV file
- [ ] Displays questions with multiple choices
- [ ] Accepts and validates user input
- [ ] Tracks correct/incorrect answers
- [ ] Shows final score and statistics
- [ ] Handles errors gracefully
- [ ] Has time limit option

**Code Organization:**
- [ ] Multiple packages (quiz, score, file, ui)
- [ ] go.mod configured correctly
- [ ] Internal package for UI
- [ ] Proper exports/unexports
- [ ] No circular dependencies

**Phase 1 Concept Coverage:**
- [ ] Structs with methods (Question, Quiz, Score)
- [ ] Interfaces (QuestionLoader, ScoreTracker)
- [ ] Custom error types
- [ ] Multiple return values
- [ ] Control flow (loops, switch)
- [ ] File I/O operations
- [ ] String formatting
- [ ] Test coverage >80%

**Quality:**
- [ ] All code formatted (go fmt)
- [ ] No vet warnings (go vet)
- [ ] All tests pass
- [ ] Documentation for exported identifiers
- [ ] README with usage instructions

---

**Previous Lesson**: [Lesson 07: Error Handling Patterns](lesson-07-error-handling.md)
**Next Lesson**: [Lesson 09: Standard Library CLI](lesson-09-stdlib-cli.md) (Phase 2)

**Estimated Completion Time**: 2-3 hours (core) + 2-4 hours (Quiz Game milestone)
**Difficulty Check**: If this takes >8 hours total, review Go modules documentation and complete simpler multi-package projects first

**🎉 PHASE 1 COMPLETION: Congratulations! You've mastered Go fundamentals and built a complete application!**
