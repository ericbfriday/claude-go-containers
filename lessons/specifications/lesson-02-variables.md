# Lesson 02: Variables, Data Types & Operators

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 2-3 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Declare variables using `var`, short declaration (`:=`), and constants
- Understand Go's type system: int, float, string, bool, and their variants
- Perform type conversions safely
- Use arithmetic, comparison, and logical operators
- Understand zero values for different types
- Work with multiple variable declarations
- Follow Go conventions for variable naming and scoping

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Understanding of basic programming concepts
- Ability to write and run simple Go programs

## Core Concepts

### 1. Variable Declaration

**Three Ways to Declare Variables:**

```go
// 1. var with explicit type
var name string = "Alice"
var age int = 30

// 2. var with type inference
var name = "Alice"  // type inferred as string
var age = 30        // type inferred as int

// 3. Short declaration (most common, inside functions only)
name := "Alice"     // type inferred, := only works inside functions
age := 30
```

### 2. Zero Values

Go initializes variables to their zero value if not explicitly initialized:
- `0` for numeric types (int, float64, etc.)
- `false` for boolean
- `""` (empty string) for strings
- `nil` for pointers, slices, maps, channels, interfaces

### 3. Constants

```go
const Pi = 3.14159
const MaxRetries = 3
const Greeting = "Hello"

// Multiple constants
const (
    StatusOK    = 200
    StatusError = 500
)
```

### 4. Basic Types

**Numeric Types:**
- `int`, `int8`, `int16`, `int32`, `int64`
- `uint`, `uint8`, `uint16`, `uint32`, `uint64`
- `float32`, `float64`
- `byte` (alias for uint8)
- `rune` (alias for int32, represents Unicode code point)

**Other Types:**
- `string` - immutable sequence of bytes
- `bool` - true or false

### 5. Type Conversions

Go requires explicit type conversion:
```go
var i int = 42
var f float64 = float64(i)  // Must explicitly convert
var u uint = uint(f)        // No implicit conversion
```

### 6. Operators

**Arithmetic:** `+`, `-`, `*`, `/`, `%`
**Comparison:** `==`, `!=`, `<`, `>`, `<=`, `>=`
**Logical:** `&&`, `||`, `!`
**Bitwise:** `&`, `|`, `^`, `<<`, `>>`

## Challenge Description

### Part 1: Temperature Converter

Create a package that converts temperatures between Fahrenheit, Celsius, and Kelvin:

```go
// FahrenheitToCelsius converts Fahrenheit to Celsius
// Formula: C = (F - 32) * 5/9
func FahrenheitToCelsius(f float64) float64

// CelsiusToFahrenheit converts Celsius to Fahrenheit
// Formula: F = C * 9/5 + 32
func CelsiusToFahrenheit(c float64) float64

// CelsiusToKelvin converts Celsius to Kelvin
// Formula: K = C + 273.15
func CelsiusToKelvin(c float64) float64

// KelvinToCelsius converts Kelvin to Celsius
// Formula: C = K - 273.15
func KelvinToCelsius(k float64) float64
```

### Part 2: Math Operations

Implement a calculator with these functions:

```go
// Add returns the sum of two integers
func Add(a, b int) int

// Subtract returns the difference of two integers
func Subtract(a, b int) int

// Multiply returns the product of two integers
func Multiply(a, b int) int

// Divide returns the quotient and remainder
// Returns quotient, remainder, and error (if divisor is 0)
func Divide(a, b int) (int, int, error)

// Power returns base raised to exponent (using loop, not math.Pow)
func Power(base, exponent int) int
```

### Part 3: String Metrics

Create functions that analyze strings:

```go
// StringLength returns the length of a string
func StringLength(s string) int

// RuneCount returns the number of Unicode characters
// (different from len() for multi-byte characters)
func RuneCount(s string) int

// IsEmpty returns true if string is empty or only whitespace
func IsEmpty(s string) bool

// Concatenate joins multiple strings with a separator
func Concatenate(separator string, parts ...string) string
```

### Part 4: Boolean Logic

Implement logical comparison functions:

```go
// IsEven returns true if number is even
func IsEven(n int) bool

// IsPositive returns true if number is greater than zero
func IsPositive(n int) bool

// InRange returns true if value is between min and max (inclusive)
func InRange(value, min, max int) bool

// IsLeapYear returns true if year is a leap year
// Rules: divisible by 4, except centuries unless divisible by 400
func IsLeapYear(year int) bool
```

## Test Requirements

Implement comprehensive table-driven tests for all functions:

### Temperature Conversion Tests

```go
func TestFahrenheitToCelsius(t *testing.T) {
    tests := []struct {
        name       string
        fahrenheit float64
        expected   float64
        tolerance  float64  // Allow small floating-point differences
    }{
        {"freezing point", 32.0, 0.0, 0.001},
        {"boiling point", 212.0, 100.0, 0.001},
        {"body temperature", 98.6, 37.0, 0.1},
        {"absolute zero", -459.67, -273.15, 0.01},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FahrenheitToCelsius(tt.fahrenheit)
            diff := result - tt.expected
            if diff < 0 {
                diff = -diff
            }
            if diff > tt.tolerance {
                t.Errorf("FahrenheitToCelsius(%f) = %f, want %f",
                    tt.fahrenheit, result, tt.expected)
            }
        })
    }
}
```

### Math Operations Tests

Test each operation with:
- Positive numbers
- Negative numbers
- Zero
- Edge cases (e.g., division by zero)

### String Metrics Tests

Test with:
- Empty strings
- ASCII strings
- Unicode strings (e.g., "Hello 世界")
- Strings with whitespace

### Boolean Logic Tests

Test boundary conditions and typical cases for each function

## Input/Output Specifications

### Temperature Conversions

```go
FahrenheitToCelsius(32.0)   → 0.0
FahrenheitToCelsius(212.0)  → 100.0
CelsiusToFahrenheit(0.0)    → 32.0
CelsiusToKelvin(0.0)        → 273.15
KelvinToCelsius(273.15)     → 0.0
```

### Math Operations

```go
Add(5, 3)           → 8
Subtract(10, 4)     → 6
Multiply(6, 7)      → 42
Divide(10, 3)       → (3, 1, nil)     // quotient=3, remainder=1
Divide(10, 0)       → (0, 0, error)   // error: division by zero
Power(2, 3)         → 8
Power(5, 0)         → 1
```

### String Metrics

```go
StringLength("hello")      → 5
RuneCount("Hello 世界")    → 8   // len() would return 13
IsEmpty("")                → true
IsEmpty("   ")             → true
IsEmpty("hello")           → false
Concatenate("-", "a", "b", "c") → "a-b-c"
```

### Boolean Logic

```go
IsEven(4)           → true
IsEven(7)           → false
IsPositive(5)       → true
IsPositive(-3)      → false
IsPositive(0)       → false
InRange(5, 1, 10)   → true
InRange(11, 1, 10)  → false
IsLeapYear(2000)    → true
IsLeapYear(1900)    → false
IsLeapYear(2024)    → true
```

## Success Criteria

### Functional Requirements
- [ ] All temperature conversions are mathematically correct
- [ ] Floating-point comparisons use tolerance for testing
- [ ] Division by zero returns an error, not panic
- [ ] Power function works with exponent 0 (returns 1)
- [ ] String operations handle Unicode correctly
- [ ] Boolean logic follows specifications exactly

### Code Quality Requirements
- [ ] Use appropriate types (float64 for temps, int for counters)
- [ ] Constants defined for magic numbers (e.g., 273.15 for Kelvin)
- [ ] Variable names are descriptive
- [ ] Type conversions are explicit where needed
- [ ] All exported functions have documentation comments

### Testing Requirements
- [ ] Tests cover positive, negative, and zero cases
- [ ] Floating-point tests use tolerance for comparison
- [ ] Error cases are tested (e.g., Divide by zero)
- [ ] Unicode edge cases are tested for string functions
- [ ] Table-driven tests used throughout

## Common Pitfalls to Avoid

### 1. Implicit Type Conversion
```go
// ❌ Wrong: No implicit conversion
var i int = 42
var f float64 = i  // Compile error!

// ✅ Correct: Explicit conversion required
var i int = 42
var f float64 = float64(i)
```

### 2. Integer Division Truncation
```go
// ❌ Wrong: Integer division truncates
result := 5 / 2  // result = 2, not 2.5

// ✅ Correct: Convert to float for decimal result
result := float64(5) / float64(2)  // result = 2.5
```

### 3. Floating-Point Comparison
```go
// ❌ Wrong: Direct equality check on floats
if 0.1 + 0.2 == 0.3 { ... }  // May be false due to precision

// ✅ Correct: Use tolerance
tolerance := 0.0001
if math.Abs((0.1 + 0.2) - 0.3) < tolerance { ... }
```

### 4. Short Declaration Outside Functions
```go
// ❌ Wrong: := cannot be used at package level
package main
name := "Alice"  // Compile error!

// ✅ Correct: Use var at package level
package main
var name = "Alice"
```

### 5. Unused Variables
```go
// ❌ Wrong: Declared but unused variable
func example() {
    unused := 42  // Compile error: unused variable
}

// ✅ Correct: Either use it or remove it
func example() {
    value := 42
    fmt.Println(value)  // Used
}
```

### 6. String Length vs Rune Count
```go
// ❌ Wrong: len() counts bytes, not characters
s := "Hello 世界"
length := len(s)  // Returns 13 (bytes), not 8 (characters)

// ✅ Correct: Use utf8.RuneCountInString()
import "unicode/utf8"
length := utf8.RuneCountInString(s)  // Returns 8
```

## Extension Challenges (Optional)

### 1. Unit Converter Package
Create converters for:
- Distance (miles ↔ kilometers)
- Weight (pounds ↔ kilograms)
- Volume (gallons ↔ liters)

### 2. Advanced Math Operations
Implement:
- `Factorial(n int) int` - calculate n!
- `IsPrime(n int) bool` - check if number is prime
- `GCD(a, b int) int` - greatest common divisor
- `Fibonacci(n int) int` - nth Fibonacci number

### 3. String Transformations
Implement:
- `Reverse(s string) string` - reverse string preserving Unicode
- `IsPalindrome(s string) bool` - check if palindrome
- `WordCount(s string) int` - count words
- `ToTitleCase(s string) string` - capitalize first letter of each word

### 4. Bitwise Operations
Implement:
- `IsPowerOfTwo(n int) bool` - check using bitwise ops
- `SetBit(n int, pos uint) int` - set bit at position
- `ClearBit(n int, pos uint) int` - clear bit at position
- `ToggleBit(n int, pos uint) int` - toggle bit at position

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `strings`, `testing`, `math`, `unicode/utf8`, `errors`
- No external dependencies

### Expected Approach
1. Group related functions in separate files (e.g., `temperature.go`, `math.go`)
2. Define constants for magic numbers (e.g., `const KelvinOffset = 273.15`)
3. Use explicit type conversions
4. Return errors for invalid operations (don't panic)
5. Handle Unicode strings properly with `unicode/utf8` package
6. Use floating-point tolerance in tests

### Code Quality Expectations
- Use descriptive constant names for magic numbers
- Keep functions pure (no side effects)
- Use appropriate numeric types (float64 for decimals, int for counting)
- Document formulas in comments
- Format code with `go fmt`

### Testing Approach
- Test positive, negative, and zero cases
- Test boundary conditions
- Use tolerance for floating-point comparisons
- Test error cases explicitly
- Include edge cases (Unicode, large numbers, etc.)

## Learning Resources

### Essential Reading
- [A Tour of Go - Basics](https://go.dev/tour/basics/8) (Variables)
- [Go by Example - Variables](https://gobyexample.com/variables)
- [Go by Example - Constants](https://gobyexample.com/constants)
- [Effective Go - Constants](https://go.dev/doc/effective_go#constants)

### Type System
- [Go Spec - Types](https://go.dev/ref/spec#Types)
- [Understanding Type Conversions](https://go.dev/doc/faq#conversions)

### Floating-Point Arithmetic
- [What Every Programmer Should Know About Floating-Point](https://floating-point-gui.de/)
- [Go - Comparing Floats](https://yourbasic.org/golang/compare-floats/)

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run all tests
go test -v

# Run tests with coverage
go test -cover -coverprofile=coverage.out
go tool cover -html=coverage.out

# Run specific test
go test -v -run TestFahrenheitToCelsius

# Build and run
go build -o lesson02
./lesson02
```

---

**Previous Lesson**: [Lesson 01: Hello World & Basic Syntax](lesson-01-hello-world.md)
**Next Lesson**: [Lesson 03: Control Flow - If, Switch, Loops](lesson-03-control-flow.md)

**Estimated Completion Time**: 2-3 hours
**Difficulty Check**: If this takes >4 hours, review Tour of Go sections on variables and types
