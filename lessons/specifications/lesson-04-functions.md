# Lesson 04: Functions & Multiple Returns

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 2-3 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Declare and use functions with multiple parameters and return values
- Understand Go's multiple return value pattern for error handling
- Use named return values for clarity and implicit returns
- Implement variadic functions that accept variable numbers of arguments
- Write closures and understand function scope
- Use defer statements for cleanup and resource management
- Understand panic and recover for exceptional error handling
- Write higher-order functions (functions as arguments and return values)

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Completed Lesson 03: Control Flow - If, Switch, Loops
- Understanding of basic function concepts from other languages

## Core Concepts

### 1. Function Declaration

**Basic Function:**
```go
func add(a int, b int) int {
    return a + b
}

// Shorter form when parameters share type
func add(a, b int) int {
    return a + b
}
```

**Multiple Return Values:**
```go
// Return multiple values (Go's idiomatic pattern)
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}

// Usage
result, err := divide(10, 2)
if err != nil {
    fmt.Println("Error:", err)
    return
}
fmt.Println("Result:", result)
```

**Named Return Values:**
```go
// Named returns are initialized to zero values
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return  // Naked return (returns x and y)
}

// Named returns for documentation clarity
func calculate(a, b int) (sum, product int) {
    sum = a + b
    product = a * b
    return sum, product  // Explicit return preferred
}
```

### 2. Variadic Functions

**Variable Number of Arguments:**
```go
// Variadic parameter must be last
func sum(numbers ...int) int {
    total := 0
    for _, num := range numbers {
        total += num
    }
    return total
}

// Usage
sum(1, 2, 3)           // 6
sum(1, 2, 3, 4, 5)     // 15
sum()                  // 0

// Passing slice to variadic function
numbers := []int{1, 2, 3, 4}
sum(numbers...)        // Unpacking with ...
```

**Mixed Parameters:**
```go
func greet(greeting string, names ...string) string {
    if len(names) == 0 {
        return greeting + ", World!"
    }
    return greeting + ", " + strings.Join(names, " and ") + "!"
}

greet("Hello", "Alice", "Bob")  // "Hello, Alice and Bob!"
```

### 3. Closures

**Functions as Values:**
```go
// Assign function to variable
func main() {
    add := func(a, b int) int {
        return a + b
    }

    result := add(5, 3)  // 8
}

// Closure captures surrounding variables
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

// Usage
c := counter()
fmt.Println(c())  // 1
fmt.Println(c())  // 2
fmt.Println(c())  // 3
```

### 4. Defer Statements

**Defer for Cleanup:**
```go
func readFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close()  // Executed when function returns

    // Work with file...
    return nil
}

// Multiple defers execute in LIFO order (stack)
func example() {
    defer fmt.Println("First")   // Executes third
    defer fmt.Println("Second")  // Executes second
    defer fmt.Println("Third")   // Executes first
}
```

**Defer with Named Returns:**
```go
func incrementAndReturn(value int) (result int) {
    defer func() {
        result++  // Modifies return value
    }()
    result = value
    return  // Returns value + 1
}
```

### 5. Panic and Recover

**Panic for Unrecoverable Errors:**
```go
func mustConnect(url string) *Connection {
    conn, err := connect(url)
    if err != nil {
        panic("cannot connect: " + err.Error())
    }
    return conn
}
```

**Recover from Panic:**
```go
func safeExecute(fn func()) (err error) {
    defer func() {
        if r := recover(); r != nil {
            err = fmt.Errorf("panic recovered: %v", r)
        }
    }()

    fn()
    return nil
}

// Usage
err := safeExecute(func() {
    panic("something went wrong")
})
if err != nil {
    fmt.Println(err)  // "panic recovered: something went wrong"
}
```

### 6. Higher-Order Functions

**Functions as Parameters:**
```go
func apply(numbers []int, fn func(int) int) []int {
    result := make([]int, len(numbers))
    for i, num := range numbers {
        result[i] = fn(num)
    }
    return result
}

// Usage
numbers := []int{1, 2, 3, 4}
doubled := apply(numbers, func(n int) int { return n * 2 })
// [2, 4, 6, 8]
```

**Functions as Return Values:**
```go
func multiplier(factor int) func(int) int {
    return func(value int) int {
        return value * factor
    }
}

// Usage
double := multiplier(2)
triple := multiplier(3)
fmt.Println(double(5))  // 10
fmt.Println(triple(5))  // 15
```

## Challenge Description

### Part 1: Math Functions

```go
// Factorial computes n! (n factorial)
// Returns 1 for n <= 0
func Factorial(n int) int

// Fibonacci returns the nth Fibonacci number
// F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)
func Fibonacci(n int) int

// GCD returns the greatest common divisor of a and b
// Using Euclidean algorithm
func GCD(a, b int) int

// Power computes base^exponent
// Returns 1 for exponent = 0
func Power(base, exponent int) int

// IsPerfectSquare returns true if n is a perfect square
func IsPerfectSquare(n int) bool
```

### Part 2: Multiple Return Values

```go
// MinMax returns the minimum and maximum values from a slice
// Returns error if slice is empty
func MinMax(numbers []int) (min, max int, err error)

// DivMod returns quotient and remainder of a/b
// Returns error if b is zero
func DivMod(a, b int) (quotient, remainder int, err error)

// ParseName splits "First Last" into first and last names
// Returns error if format is invalid
func ParseName(fullName string) (first, last string, err error)

// Stats returns mean, median, and mode of numbers
// Returns error if slice is empty
func Stats(numbers []float64) (mean, median, mode float64, err error)
```

### Part 3: Variadic Functions

```go
// Sum returns the sum of all provided integers
func Sum(numbers ...int) int

// Average returns the average of all provided numbers
// Returns 0 if no numbers provided
func Average(numbers ...float64) float64

// Concat joins strings with a separator
func Concat(separator string, parts ...string) string

// Max returns the maximum value from provided integers
// Panics if no numbers provided
func Max(numbers ...int) int

// AllTrue returns true if all boolean values are true
func AllTrue(values ...bool) bool
```

### Part 4: Higher-Order Functions

```go
// Map applies a function to each element in a slice
func Map(numbers []int, fn func(int) int) []int

// Filter returns elements that satisfy the predicate
func Filter(numbers []int, predicate func(int) bool) []int

// Reduce combines all elements using the provided function
// Initial value is the accumulator starting point
func Reduce(numbers []int, initial int, fn func(acc, val int) int) int

// Compose combines two functions: f(g(x))
func Compose(f, g func(int) int) func(int) int

// Repeat executes a function n times
func Repeat(n int, fn func(int))
```

### Part 5: Defer and Recovery

```go
// SafeDivide performs division with panic recovery
// Returns result and error (if panic occurred)
func SafeDivide(a, b float64) (result float64, err error)

// WithLogging wraps a function with entry/exit logging
// Uses defer to ensure exit log even on panic
func WithLogging(name string, fn func()) func()

// Benchmark measures execution time of a function
// Returns duration and any panic that occurred
func Benchmark(fn func()) (duration time.Duration, err error)

// Transaction simulates a database transaction with rollback
// Uses defer for cleanup, returns commit status
func Transaction(operations []func() error) error
```

### Part 6: Closures

```go
// Counter returns a function that increments and returns count
func Counter(start int) func() int

// Multiplier returns a function that multiplies by factor
func Multiplier(factor int) func(int) int

// Accumulator returns functions to add and get total
func Accumulator() (add func(int), getTotal func() int)

// RateLimiter returns a function that enforces rate limiting
// Allow n calls per second
func RateLimiter(n int) func() bool
```

## Test Requirements

### Math Function Tests

```go
func TestFactorial(t *testing.T) {
    tests := []struct {
        name     string
        input    int
        expected int
    }{
        {"zero", 0, 1},
        {"one", 1, 1},
        {"five", 5, 120},
        {"ten", 10, 3628800},
        {"negative", -5, 1},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Factorial(tt.input)
            if result != tt.expected {
                t.Errorf("Factorial(%d) = %d, want %d",
                    tt.input, result, tt.expected)
            }
        })
    }
}

func TestFibonacci(t *testing.T) {
    tests := []struct {
        name     string
        n        int
        expected int
    }{
        {"F(0)", 0, 0},
        {"F(1)", 1, 1},
        {"F(5)", 5, 5},
        {"F(10)", 10, 55},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Fibonacci(tt.n)
            if result != tt.expected {
                t.Errorf("Fibonacci(%d) = %d, want %d",
                    tt.n, result, tt.expected)
            }
        })
    }
}
```

### Multiple Return Value Tests

```go
func TestMinMax(t *testing.T) {
    tests := []struct {
        name        string
        input       []int
        expectedMin int
        expectedMax int
        expectError bool
    }{
        {"normal", []int{3, 1, 4, 1, 5}, 1, 5, false},
        {"single", []int{42}, 42, 42, false},
        {"negative", []int{-3, -1, -5}, -5, -1, false},
        {"empty", []int{}, 0, 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            min, max, err := MinMax(tt.input)

            if tt.expectError {
                if err == nil {
                    t.Errorf("MinMax(%v) expected error, got nil", tt.input)
                }
                return
            }

            if err != nil {
                t.Errorf("MinMax(%v) unexpected error: %v", tt.input, err)
            }
            if min != tt.expectedMin || max != tt.expectedMax {
                t.Errorf("MinMax(%v) = (%d, %d), want (%d, %d)",
                    tt.input, min, max, tt.expectedMin, tt.expectedMax)
            }
        })
    }
}
```

### Variadic Function Tests

Test with:
- No arguments
- Single argument
- Multiple arguments
- Slice unpacking with ...
- Mixed parameters

### Higher-Order Function Tests

```go
func TestMap(t *testing.T) {
    double := func(n int) int { return n * 2 }

    tests := []struct {
        name     string
        input    []int
        fn       func(int) int
        expected []int
    }{
        {"double", []int{1, 2, 3}, double, []int{2, 4, 6}},
        {"empty", []int{}, double, []int{}},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Map(tt.input, tt.fn)
            if !reflect.DeepEqual(result, tt.expected) {
                t.Errorf("Map(%v) = %v, want %v",
                    tt.input, result, tt.expected)
            }
        })
    }
}
```

### Defer and Recovery Tests

Test with:
- Normal execution (no panic)
- Panic scenarios
- Multiple defer statements
- Defer with named returns

### Closure Tests

Test that closures:
- Capture variables correctly
- Maintain separate state for different instances
- Handle concurrent access appropriately

## Input/Output Specifications

### Math Functions

```go
Factorial(5)     → 120
Factorial(0)     → 1
Fibonacci(10)    → 55
GCD(48, 18)      → 6
Power(2, 10)     → 1024
IsPerfectSquare(16) → true
```

### Multiple Returns

```go
MinMax([]int{3,1,4}) → 1, 4, nil
MinMax([]int{})      → 0, 0, error
DivMod(17, 5)        → 3, 2, nil
DivMod(10, 0)        → 0, 0, error
ParseName("John Doe") → "John", "Doe", nil
```

### Variadic Functions

```go
Sum(1, 2, 3, 4, 5)     → 15
Average(2.0, 4.0, 6.0) → 4.0
Concat("-", "a", "b")  → "a-b"
Max(3, 7, 2, 9, 1)     → 9
```

### Higher-Order Functions

```go
Map([]int{1,2,3}, func(n int) int { return n*2 }) → []int{2,4,6}
Filter([]int{1,2,3,4}, func(n int) bool { return n%2==0 }) → []int{2,4}
Reduce([]int{1,2,3,4}, 0, func(a,b int) int { return a+b }) → 10
```

### Closures

```go
c := Counter(10)
c() → 11
c() → 12
c() → 13

mult := Multiplier(3)
mult(5) → 15
mult(7) → 21
```

## Success Criteria

### Functional Requirements
- [ ] All math functions produce correct results
- [ ] Multiple return values properly return errors
- [ ] Variadic functions handle 0, 1, and many arguments
- [ ] Higher-order functions work with various input functions
- [ ] Defer executes in correct order (LIFO)
- [ ] Panic/recover properly handles exceptional cases
- [ ] Closures maintain proper state isolation

### Code Quality Requirements
- [ ] Function names are clear and descriptive
- [ ] Named returns used appropriately for clarity
- [ ] Error returns follow (value, error) convention
- [ ] Defer used for cleanup operations
- [ ] No naked returns in long functions
- [ ] Comments document exported functions
- [ ] Code passes go fmt and go vet

### Testing Requirements
- [ ] Table-driven tests for all functions
- [ ] Edge cases covered (empty, zero, negative)
- [ ] Error conditions tested
- [ ] Panic/recover scenarios verified
- [ ] Closure state isolation tested

## Common Pitfalls to Avoid

### 1. Ignoring Error Returns

```go
// ❌ Wrong: Ignoring error return
result, _ := divide(10, 0)  // Silent error!
fmt.Println(result)

// ✅ Correct: Handle errors
result, err := divide(10, 0)
if err != nil {
    log.Fatal(err)
}
fmt.Println(result)
```

### 2. Naked Returns in Long Functions

```go
// ❌ Wrong: Naked return unclear in long function
func calculate(a, b int) (sum, product int) {
    sum = a + b
    product = a * b
    // ... 50 lines of code ...
    return  // What are we returning?
}

// ✅ Correct: Explicit return
func calculate(a, b int) (sum, product int) {
    sum = a + b
    product = a * b
    return sum, product  // Clear what's returned
}
```

### 3. Defer in Loops

```go
// ❌ Wrong: Defer in loop accumulates
func processFiles(files []string) {
    for _, filename := range files {
        f, _ := os.Open(filename)
        defer f.Close()  // Defers accumulate, files stay open!
    }
}

// ✅ Correct: Extract to function with defer
func processFiles(files []string) {
    for _, filename := range files {
        processFile(filename)
    }
}

func processFile(filename string) {
    f, _ := os.Open(filename)
    defer f.Close()  // Closes after each iteration
    // process file
}
```

### 4. Modifying Variadic Slice

```go
// ❌ Wrong: Modifying variadic parameter affects caller
func modify(numbers ...int) {
    numbers[0] = 999  // Modifies caller's slice!
}

// ✅ Correct: Copy if you need to modify
func modify(numbers ...int) []int {
    result := make([]int, len(numbers))
    copy(result, numbers)
    result[0] = 999
    return result
}
```

### 5. Closure Variable Capture

```go
// ❌ Wrong: Loop variable captured by reference
funcs := []func(){}
for i := 0; i < 3; i++ {
    funcs = append(funcs, func() {
        fmt.Println(i)  // All closures print 3!
    })
}

// ✅ Correct: Capture loop variable value
funcs := []func(){}
for i := 0; i < 3; i++ {
    i := i  // Create new variable
    funcs = append(funcs, func() {
        fmt.Println(i)  // Prints 0, 1, 2
    })
}
```

### 6. Recovering Outside Defer

```go
// ❌ Wrong: Recover outside defer doesn't work
func example() {
    recover()  // Does nothing!
    panic("crash")
}

// ✅ Correct: Recover inside defer
func example() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered:", r)
        }
    }()
    panic("crash")
}
```

## Extension Challenges (Optional)

### 1. Memoization
Implement a generic memoization wrapper that caches function results:
```go
func Memoize(fn func(int) int) func(int) int
```

### 2. Retry Logic
Create a retry function that attempts an operation multiple times:
```go
func Retry(attempts int, delay time.Duration, fn func() error) error
```

### 3. Pipeline
Build a data processing pipeline with multiple stages:
```go
func Pipeline(input []int, stages ...func(int) int) []int
```

### 4. Lazy Evaluation
Implement lazy sequence generation with closures:
```go
func LazyRange(start, end int) func() (int, bool)
```

### 5. Function Composition Chain
Create a fluent API for composing multiple functions:
```go
type IntFunc func(int) int
func (f IntFunc) Then(g IntFunc) IntFunc
```

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `strings`, `math`, `testing`, `reflect`, `time`
- No external dependencies

### Expected Approach
1. Implement basic math functions first (factorial, fibonacci, GCD)
2. Show multiple return pattern with error handling
3. Demonstrate variadic functions with various parameter counts
4. Implement higher-order functions (Map, Filter, Reduce)
5. Show defer usage for cleanup
6. Demonstrate closure state capture
7. Include panic/recover examples for error handling
8. Write comprehensive table-driven tests

### Code Quality Expectations
- Follow (value, error) return convention
- Use named returns for documentation, explicit for clarity
- Defer for resource cleanup
- Document panic conditions in comments
- Closures capture minimal necessary state
- Higher-order functions have clear, focused purposes
- Comments explain non-obvious behavior

### Testing Approach
- Table-driven tests for all functions
- Test error conditions explicitly
- Verify panic/recover behavior
- Test closure state isolation
- Test variadic functions with 0, 1, many arguments
- Use subtests for organization

## Learning Resources

### Essential Reading
- [A Tour of Go - Functions](https://go.dev/tour/moretypes/24)
- [Go by Example - Functions](https://gobyexample.com/functions)
- [Go by Example - Multiple Return Values](https://gobyexample.com/multiple-return-values)
- [Go by Example - Variadic Functions](https://gobyexample.com/variadic-functions)
- [Go by Example - Closures](https://gobyexample.com/closures)
- [Go by Example - Defer](https://gobyexample.com/defer)
- [Go by Example - Panic and Recover](https://gobyexample.com/panic)
- [Effective Go - Functions](https://go.dev/doc/effective_go#functions)

### Specific Topics
- [Go Spec - Function declarations](https://go.dev/ref/spec#Function_declarations)
- [Go Blog - Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover)
- [Go Blog - Error handling](https://go.dev/blog/error-handling-and-go)

### Practice Problems
- [Exercism Go Track - Functions](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/) for experimentation

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run specific test
go test -v -run TestFactorial

# Test with coverage
go test -cover
go test -coverprofile=coverage.out

# View coverage
go tool cover -html=coverage.out

# Build (if main program included)
go build

# Run
go run main.go
```

---

**Previous Lesson**: [Lesson 03: Control Flow - If, Switch, Loops](lesson-03-control-flow.md)
**Next Lesson**: [Lesson 05: Structs & Methods](lesson-05-structs-methods.md)

**Estimated Completion Time**: 2-3 hours
**Difficulty Check**: If this takes >4 hours, review Go Tour functions section and practice recursive functions first
