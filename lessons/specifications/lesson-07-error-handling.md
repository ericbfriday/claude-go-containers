# Lesson 07: Error Handling Patterns

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate

## Learning Objectives

By the end of this lesson, learners will be able to:
- Understand Go's error handling philosophy (errors are values)
- Create custom errors using errors.New() and fmt.Errorf()
- Implement the error interface for custom error types
- Wrap errors with context using %w format verb
- Use errors.Is() for error comparison and errors.As() for type checking
- Design sentinel errors for expected error conditions
- Handle panic/recover for exceptional situations
- Create error hierarchies for complex error reporting
- Apply error handling best practices in real-world scenarios

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Completed Lesson 03: Control Flow - If, Switch, Loops
- Completed Lesson 04: Functions & Multiple Returns
- Completed Lesson 05: Structs & Methods
- Completed Lesson 06: Interfaces & Polymorphism
- Understanding of error handling concepts from other languages

## Core Concepts

### 1. The Error Interface

**Built-in error Interface:**
```go
type error interface {
    Error() string
}

// Simple error creation
err := errors.New("something went wrong")
fmt.Println(err.Error())  // "something went wrong"

// Formatted error
err := fmt.Errorf("user %d not found", userID)
```

**Custom Error Type:**
```go
type MyError struct {
    Code    int
    Message string
}

func (e MyError) Error() string {
    return fmt.Sprintf("error %d: %s", e.Code, e.Message)
}

// Usage
err := MyError{Code: 404, Message: "not found"}
fmt.Println(err)  // "error 404: not found"
```

### 2. Error Handling Pattern

**Idiomatic Error Checking:**
```go
func ReadFile(filename string) ([]byte, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read %s: %w", filename, err)
    }
    return data, nil
}

// Usage
data, err := ReadFile("config.txt")
if err != nil {
    log.Fatal(err)
}
// Use data
```

**Multiple Error Returns:**
```go
func Divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

// Check error before using result
result, err := Divide(10, 0)
if err != nil {
    fmt.Println("Error:", err)
    return
}
fmt.Println("Result:", result)
```

### 3. Error Wrapping

**Wrapping with %w:**
```go
func ProcessFile(filename string) error {
    data, err := ReadFile(filename)
    if err != nil {
        return fmt.Errorf("process file: %w", err)
    }

    if err := ValidateData(data); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }

    return nil
}

// Error chain preserved:
// "process file: failed to read config.txt: open config.txt: no such file"
```

**Error Unwrapping:**
```go
err := ProcessFile("missing.txt")
if err != nil {
    // Get wrapped error
    unwrapped := errors.Unwrap(err)
    fmt.Println("Unwrapped:", unwrapped)
}
```

### 4. Error Comparison

**errors.Is() for Sentinel Errors:**
```go
var (
    ErrNotFound    = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
)

func GetUser(id int) (*User, error) {
    if id < 0 {
        return nil, ErrInvalidInput
    }
    // Check database
    if notFound {
        return nil, ErrNotFound
    }
    return user, nil
}

// Usage with errors.Is()
user, err := GetUser(id)
if err != nil {
    if errors.Is(err, ErrNotFound) {
        fmt.Println("User not found")
    } else if errors.Is(err, ErrInvalidInput) {
        fmt.Println("Invalid user ID")
    } else {
        fmt.Println("Unknown error:", err)
    }
}
```

**errors.As() for Type Checking:**
```go
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func ValidateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return ValidationError{
            Field:   "email",
            Message: "must contain @",
        }
    }
    return nil
}

// Usage with errors.As()
err := ValidateEmail("invalid")
if err != nil {
    var ve ValidationError
    if errors.As(err, &ve) {
        fmt.Printf("Validation error in field %s: %s\n", ve.Field, ve.Message)
    }
}
```

### 5. Custom Error Types

**Rich Error Information:**
```go
type DatabaseError struct {
    Operation string
    Table     string
    Err       error
    Timestamp time.Time
}

func (e DatabaseError) Error() string {
    return fmt.Sprintf("database error in %s on %s at %s: %v",
        e.Operation, e.Table, e.Timestamp.Format(time.RFC3339), e.Err)
}

func (e DatabaseError) Unwrap() error {
    return e.Err
}

// Usage
func InsertUser(user User) error {
    err := db.Insert("users", user)
    if err != nil {
        return DatabaseError{
            Operation: "INSERT",
            Table:     "users",
            Err:       err,
            Timestamp: time.Now(),
        }
    }
    return nil
}
```

**Error with HTTP Status:**
```go
type HTTPError struct {
    StatusCode int
    Message    string
}

func (e HTTPError) Error() string {
    return fmt.Sprintf("HTTP %d: %s", e.StatusCode, e.Message)
}

var (
    ErrNotFound     = HTTPError{StatusCode: 404, Message: "Not Found"}
    ErrUnauthorized = HTTPError{StatusCode: 401, Message: "Unauthorized"}
    ErrBadRequest   = HTTPError{StatusCode: 400, Message: "Bad Request"}
)
```

### 6. Panic and Recover

**Panic for Unrecoverable Errors:**
```go
func mustLoadConfig(filename string) Config {
    config, err := LoadConfig(filename)
    if err != nil {
        panic(fmt.Sprintf("cannot load config: %v", err))
    }
    return config
}

// Use panic only in initialization or truly exceptional cases
```

**Recover from Panic:**
```go
func SafeExecute(fn func()) (err error) {
    defer func() {
        if r := recover(); r != nil {
            err = fmt.Errorf("panic recovered: %v", r)
        }
    }()

    fn()
    return nil
}

// Usage
err := SafeExecute(func() {
    // Code that might panic
    arr := []int{1, 2, 3}
    _ = arr[10]  // Panics: index out of range
})

if err != nil {
    fmt.Println("Caught panic:", err)
}
```

**Graceful Shutdown:**
```go
func StartServer() error {
    defer func() {
        if r := recover(); r != nil {
            log.Printf("Server panic: %v", r)
            // Cleanup resources
            CleanupResources()
        }
    }()

    // Server code
    return nil
}
```

### 7. Error Handling Strategies

**Early Return Pattern:**
```go
func ProcessOrder(order Order) error {
    if err := ValidateOrder(order); err != nil {
        return fmt.Errorf("validation: %w", err)
    }

    if err := CheckInventory(order); err != nil {
        return fmt.Errorf("inventory check: %w", err)
    }

    if err := ProcessPayment(order); err != nil {
        return fmt.Errorf("payment: %w", err)
    }

    if err := ShipOrder(order); err != nil {
        return fmt.Errorf("shipping: %w", err)
    }

    return nil
}
```

**Error Accumulation:**
```go
type MultiError struct {
    Errors []error
}

func (m MultiError) Error() string {
    var msgs []string
    for _, err := range m.Errors {
        msgs = append(msgs, err.Error())
    }
    return strings.Join(msgs, "; ")
}

func ValidateForm(form Form) error {
    var errs []error

    if form.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if form.Email == "" {
        errs = append(errs, errors.New("email is required"))
    }
    if form.Age < 0 {
        errs = append(errs, errors.New("age must be positive"))
    }

    if len(errs) > 0 {
        return MultiError{Errors: errs}
    }
    return nil
}
```

## Challenge Description

### Part 1: Custom Error Types

```go
// ValidationError represents input validation failure
type ValidationError struct {
    Field   string
    Value   interface{}
    Rule    string
    Message string
}

func NewValidationError(field, rule, message string, value interface{}) *ValidationError
func (e ValidationError) Error() string

// NotFoundError represents resource not found
type NotFoundError struct {
    Resource string
    ID       interface{}
}

func NewNotFoundError(resource string, id interface{}) *NotFoundError
func (e NotFoundError) Error() string

// ConflictError represents resource conflict
type ConflictError struct {
    Resource string
    Field    string
    Value    interface{}
}

func NewConflictError(resource, field string, value interface{}) *ConflictError
func (e ConflictError) Error() string

// PermissionError represents access denied
type PermissionError struct {
    User     string
    Resource string
    Action   string
}

func NewPermissionError(user, resource, action string) *PermissionError
func (e PermissionError) Error() string
```

### Part 2: Error Wrapping System

```go
// Validator validates data with detailed errors
type Validator struct {
    errors []error
}

func NewValidator() *Validator

// AddError adds a validation error
func (v *Validator) AddError(field, message string)

// Validate checks if email is valid
func (v *Validator) ValidateEmail(field, email string) bool

// ValidateRequired checks if field is not empty
func (v *Validator) ValidateRequired(field, value string) bool

// ValidateRange checks if number is in range
func (v *Validator) ValidateRange(field string, value, min, max int) bool

// HasErrors returns true if any validation errors
func (v *Validator) HasErrors() bool

// Error returns combined error message
func (v *Validator) Error() error

// Errors returns all validation errors
func (v *Validator) Errors() []error
```

### Part 3: Error Recovery System

```go
// SafeFunction executes a function with panic recovery
func SafeFunction(fn func() error) (err error)

// SafeGoroutine runs a goroutine with panic recovery
func SafeGoroutine(fn func())

// RetryWithBackoff retries operation with exponential backoff
func RetryWithBackoff(operation func() error, maxAttempts int, initialDelay time.Duration) error

// TimeoutOperation executes with timeout
func TimeoutOperation(fn func() error, timeout time.Duration) error

// CircuitBreaker implements circuit breaker pattern
type CircuitBreaker struct {
    maxFailures  int
    resetTimeout time.Duration
    failures     int
    lastFailTime time.Time
    state        string  // "closed", "open", "half-open"
}

func NewCircuitBreaker(maxFailures int, resetTimeout time.Duration) *CircuitBreaker
func (cb *CircuitBreaker) Execute(fn func() error) error
func (cb *CircuitBreaker) State() string
```

### Part 4: File Operations with Error Handling

```go
// ReadFileWithRetry reads file with retry on failure
func ReadFileWithRetry(filename string, maxAttempts int) ([]byte, error)

// WriteFileAtomic writes file atomically with rollback
func WriteFileAtomic(filename string, data []byte) error

// CopyFile copies file with error handling
func CopyFile(src, dst string) error

// FileExists checks if file exists and is accessible
func FileExists(filename string) (bool, error)

// EnsureDirectory creates directory if not exists
func EnsureDirectory(path string) error

// CleanupFiles removes files, collecting errors
func CleanupFiles(filenames []string) error
```

### Part 5: Network Operations with Error Handling

```go
// HTTPClient wraps HTTP client with error handling
type HTTPClient struct {
    client  *http.Client
    baseURL string
}

func NewHTTPClient(baseURL string, timeout time.Duration) *HTTPClient

// Get performs GET request with error handling
func (c *HTTPClient) Get(path string) ([]byte, error)

// Post performs POST request with error handling
func (c *HTTPClient) Post(path string, data interface{}) ([]byte, error)

// IsRetryable checks if error is retryable
func IsRetryable(err error) bool

// IsTimeout checks if error is timeout
func IsTimeout(err error) bool

// ParseHTTPError extracts HTTP error details
func ParseHTTPError(err error) (statusCode int, message string)
```

### Part 6: Error Sentinel and Helpers

```go
// Common sentinel errors
var (
    ErrNotFound        = errors.New("not found")
    ErrAlreadyExists   = errors.New("already exists")
    ErrInvalidInput    = errors.New("invalid input")
    ErrUnauthorized    = errors.New("unauthorized")
    ErrForbidden       = errors.New("forbidden")
    ErrTimeout         = errors.New("operation timeout")
    ErrCanceled        = errors.New("operation canceled")
)

// IsNotFound checks if error is not found
func IsNotFound(err error) bool

// IsValidationError checks if error is validation error
func IsValidationError(err error) bool

// IsPermissionError checks if error is permission error
func IsPermissionError(err error) bool

// ExtractValidationErrors extracts all validation errors
func ExtractValidationErrors(err error) []ValidationError

// WrapError wraps error with context
func WrapError(err error, message string) error

// WrapErrorf wraps error with formatted context
func WrapErrorf(err error, format string, args ...interface{}) error
```

## Test Requirements

### Validation Error Tests

```go
func TestValidationError(t *testing.T) {
    err := NewValidationError("email", "format", "must contain @", "invalid")

    if err.Field != "email" {
        t.Errorf("Field = %s, want email", err.Field)
    }

    errMsg := err.Error()
    if !strings.Contains(errMsg, "email") {
        t.Errorf("Error message should contain field name")
    }
}

func TestValidator(t *testing.T) {
    v := NewValidator()

    v.ValidateEmail("email", "invalid")
    v.ValidateRequired("name", "")
    v.ValidateRange("age", 150, 0, 120)

    if !v.HasErrors() {
        t.Error("Should have validation errors")
    }

    errors := v.Errors()
    if len(errors) != 3 {
        t.Errorf("Expected 3 errors, got %d", len(errors))
    }
}
```

### Error Wrapping Tests

```go
func TestErrorWrapping(t *testing.T) {
    originalErr := errors.New("original error")
    wrappedErr := fmt.Errorf("context: %w", originalErr)

    if !errors.Is(wrappedErr, originalErr) {
        t.Error("errors.Is should find wrapped error")
    }

    unwrapped := errors.Unwrap(wrappedErr)
    if unwrapped != originalErr {
        t.Error("Unwrap should return original error")
    }
}

func TestErrorsAs(t *testing.T) {
    err := NewValidationError("field", "rule", "message", "value")
    wrappedErr := fmt.Errorf("wrapper: %w", err)

    var ve *ValidationError
    if !errors.As(wrappedErr, &ve) {
        t.Error("errors.As should find ValidationError")
    }

    if ve.Field != "field" {
        t.Errorf("Field = %s, want field", ve.Field)
    }
}
```

### Panic Recovery Tests

```go
func TestSafeFunction(t *testing.T) {
    tests := []struct {
        name        string
        fn          func() error
        expectError bool
    }{
        {
            name:        "no panic",
            fn:          func() error { return nil },
            expectError: false,
        },
        {
            name: "with panic",
            fn: func() error {
                panic("test panic")
            },
            expectError: true,
        },
        {
            name: "with error",
            fn: func() error {
                return errors.New("test error")
            },
            expectError: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := SafeFunction(tt.fn)

            if tt.expectError && err == nil {
                t.Error("Expected error, got nil")
            }
            if !tt.expectError && err != nil {
                t.Errorf("Expected no error, got %v", err)
            }
        })
    }
}
```

### Retry Tests

```go
func TestRetryWithBackoff(t *testing.T) {
    attempts := 0
    operation := func() error {
        attempts++
        if attempts < 3 {
            return errors.New("temporary failure")
        }
        return nil
    }

    err := RetryWithBackoff(operation, 5, 10*time.Millisecond)
    if err != nil {
        t.Errorf("Expected success after retries, got %v", err)
    }

    if attempts != 3 {
        t.Errorf("Expected 3 attempts, got %d", attempts)
    }
}
```

### Circuit Breaker Tests

Test:
- Closed state allows operations
- Open state rejects operations
- Half-open state tries operations
- State transitions
- Failure counting
- Reset timeout

## Input/Output Specifications

### Validation Errors

```go
err := NewValidationError("email", "format", "must contain @", "invalid")
err.Error() → "email: must contain @"

v := NewValidator()
v.ValidateEmail("email", "invalid")
v.ValidateRequired("name", "")
v.HasErrors() → true
v.Errors()    → []error{...2 errors...}
```

### Error Wrapping

```go
original := errors.New("file not found")
wrapped := fmt.Errorf("failed to load config: %w", original)
errors.Is(wrapped, original) → true
errors.Unwrap(wrapped)       → original
```

### Error Type Checking

```go
err := NewValidationError("email", "format", "invalid", "test")
IsValidationError(err) → true
IsNotFound(err)        → false

var ve *ValidationError
errors.As(err, &ve)    → true
ve.Field               → "email"
```

### Panic Recovery

```go
SafeFunction(func() error {
    panic("crash")
}) → error("panic recovered: crash")

SafeFunction(func() error {
    return nil
}) → nil
```

### Retry

```go
RetryWithBackoff(operation, 3, 100*time.Millisecond)
// Retries up to 3 times with exponential backoff
```

### Circuit Breaker

```go
cb := NewCircuitBreaker(5, 1*time.Minute)
cb.State()        → "closed"
// After 5 failures:
cb.State()        → "open"
cb.Execute(fn)    → error("circuit breaker open")
```

## Success Criteria

### Functional Requirements
- [ ] Custom errors provide detailed context
- [ ] Error wrapping preserves original errors
- [ ] errors.Is() correctly identifies wrapped errors
- [ ] errors.As() extracts custom error types
- [ ] Panic recovery prevents crashes
- [ ] Retry logic handles transient failures
- [ ] Circuit breaker protects failing services
- [ ] Sentinel errors are comparable

### Code Quality Requirements
- [ ] Errors include sufficient context
- [ ] Error messages are clear and actionable
- [ ] No sensitive data in error messages
- [ ] Panic used only for programming errors
- [ ] Error handling doesn't obscure business logic
- [ ] Comments document error conditions
- [ ] Code passes go fmt and go vet

### Testing Requirements
- [ ] Error creation and formatting tested
- [ ] Error wrapping and unwrapping verified
- [ ] Type assertions tested with errors.As()
- [ ] Sentinel error comparisons tested
- [ ] Panic recovery verified
- [ ] Retry behavior validated
- [ ] Edge cases covered (nil errors, double wrapping)

## Common Pitfalls to Avoid

### 1. Ignoring Errors

```go
// ❌ Wrong: Silently ignoring errors
data, _ := ReadFile("config.txt")  // Error ignored!

// ✅ Correct: Handle errors
data, err := ReadFile("config.txt")
if err != nil {
    log.Printf("Failed to read config: %v", err)
    return err
}
```

### 2. Not Wrapping Errors

```go
// ❌ Wrong: Losing context
func Process() error {
    err := doSomething()
    if err != nil {
        return err  // No context about what failed
    }
    return nil
}

// ✅ Correct: Add context
func Process() error {
    err := doSomething()
    if err != nil {
        return fmt.Errorf("process failed: %w", err)
    }
    return nil
}
```

### 3. Using %v Instead of %w

```go
// ❌ Wrong: %v doesn't preserve error for errors.Is/As
return fmt.Errorf("failed: %v", err)

// ✅ Correct: %w preserves error
return fmt.Errorf("failed: %w", err)
```

### 4. Comparing Errors with ==

```go
// ❌ Wrong: Direct comparison fails with wrapped errors
if err == ErrNotFound {
    // Won't work if error is wrapped
}

// ✅ Correct: Use errors.Is()
if errors.Is(err, ErrNotFound) {
    // Works with wrapped errors
}
```

### 5. Panicking for Expected Errors

```go
// ❌ Wrong: Panic for expected condition
func Divide(a, b float64) float64 {
    if b == 0 {
        panic("division by zero")  // Expected condition!
    }
    return a / b
}

// ✅ Correct: Return error
func Divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}
```

### 6. Not Using Sentinel Errors

```go
// ❌ Wrong: Creating new errors each time
func Find(id int) (*Item, error) {
    return nil, errors.New("not found")  // New error every time
}

// Comparison fails:
err1 := Find(1)
err2 := Find(2)
err1 == err2  // false!

// ✅ Correct: Use sentinel error
var ErrNotFound = errors.New("not found")

func Find(id int) (*Item, error) {
    return nil, ErrNotFound
}

// Comparison works:
err := Find(1)
errors.Is(err, ErrNotFound)  // true
```

## Extension Challenges (Optional)

### 1. Error Aggregation
Implement an error aggregator that collects multiple errors and provides detailed reporting.

### 2. Structured Logging
Create error types that integrate with structured logging (JSON fields, context).

### 3. Error Metrics
Build error tracking system with metrics (counts, types, rates).

### 4. Error Recovery Middleware
Implement HTTP middleware that handles panics and converts to appropriate responses.

### 5. Deadline Propagation
Create context-aware error handling with deadline propagation.

## AI Provider Guidelines

### Allowed Packages
- Standard library: `errors`, `fmt`, `strings`, `testing`, `time`, `net/http`, `os`, `io`
- No external dependencies

### Expected Approach
1. Create custom error types implementing error interface
2. Demonstrate error wrapping with %w
3. Show errors.Is() and errors.As() usage
4. Implement sentinel errors
5. Create validation system with error accumulation
6. Show panic/recover patterns
7. Implement retry and circuit breaker
8. Write comprehensive error handling tests

### Code Quality Expectations
- Custom errors provide detailed context
- Error messages are clear and actionable
- Proper use of %w for wrapping
- Sentinel errors for common conditions
- Panic only for programming errors
- Error handling separated from business logic
- Comments explain error conditions

### Testing Approach
- Test error creation and formatting
- Verify error wrapping/unwrapping
- Test errors.Is() and errors.As()
- Validate panic recovery
- Test retry and timeout logic
- Verify circuit breaker state transitions
- Use table-driven tests

## Learning Resources

### Essential Reading
- [Go Blog - Error handling and Go](https://go.dev/blog/error-handling-and-go)
- [Go Blog - Working with Errors in Go 1.13](https://go.dev/blog/go1.13-errors)
- [Go by Example - Errors](https://gobyexample.com/errors)
- [Go by Example - Panic](https://gobyexample.com/panic)
- [Effective Go - Errors](https://go.dev/doc/effective_go#errors)

### Specific Topics
- [errors package documentation](https://pkg.go.dev/errors)
- [fmt.Errorf documentation](https://pkg.go.dev/fmt#Errorf)
- [Error wrapping in Go 1.13](https://go.dev/doc/go1.13#error_wrapping)

### Practice Problems
- [Exercism Go Track - Error Handling](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/) for experimentation

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run specific test
go test -v -run TestValidation

# Test with coverage
go test -cover
go test -coverprofile=coverage.out

# View coverage
go tool cover -html=coverage.out

# Build
go build

# Run
go run main.go
```

---

**Previous Lesson**: [Lesson 06: Interfaces & Polymorphism](lesson-06-interfaces.md)
**Next Lesson**: [Lesson 08: Packages & Modules](lesson-08-packages-modules.md)

**Estimated Completion Time**: 3-4 hours
**Difficulty Check**: If this takes >5 hours, review Go Blog error handling articles and practice with simpler error scenarios first
