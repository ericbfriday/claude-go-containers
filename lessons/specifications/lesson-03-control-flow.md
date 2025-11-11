# Lesson 03: Control Flow - If, Switch, Loops

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 2-3 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Write conditional statements using if/else with short statement initialization
- Implement multi-branch logic using switch statements
- Use for loops in all their forms (traditional, while-style, infinite, range)
- Apply break and continue statements for loop control
- Understand Go's streamlined control structures compared to other languages
- Implement FizzBuzz and similar algorithmic challenges
- Write table-driven tests for functions with conditional logic

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Understanding of boolean expressions and comparison operators
- Ability to write and test simple Go functions

## Core Concepts

### 1. If Statements

**Basic If/Else:**
```go
if x > 0 {
    fmt.Println("positive")
} else if x < 0 {
    fmt.Println("negative")
} else {
    fmt.Println("zero")
}
```

**If with Short Statement:**
```go
// Initialize variable in if statement (scoped to if/else)
if num := computeValue(); num > 0 {
    fmt.Println("positive:", num)
} else {
    fmt.Println("non-positive:", num)
}
// num is not accessible here
```

### 2. Switch Statements

**Basic Switch:**
```go
switch day {
case "Monday":
    fmt.Println("Start of week")
case "Friday":
    fmt.Println("End of work week")
case "Saturday", "Sunday":
    fmt.Println("Weekend!")
default:
    fmt.Println("Midweek")
}
```

**Switch with Short Statement:**
```go
switch os := runtime.GOOS; os {
case "darwin":
    fmt.Println("macOS")
case "linux":
    fmt.Println("Linux")
default:
    fmt.Println("Other OS")
}
```

**Switch without Condition (replaces if/else chains):**
```go
score := 85
switch {
case score >= 90:
    grade = "A"
case score >= 80:
    grade = "B"
case score >= 70:
    grade = "C"
default:
    grade = "F"
}
```

**Type Switch:**
```go
switch v := value.(type) {
case int:
    fmt.Printf("Integer: %d\n", v)
case string:
    fmt.Printf("String: %s\n", v)
default:
    fmt.Printf("Unknown type\n")
}
```

### 3. For Loops

**Traditional Three-Component For:**
```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}
```

**While-Style For (condition only):**
```go
sum := 1
for sum < 1000 {
    sum += sum
}
```

**Infinite Loop:**
```go
for {
    // Loop forever (use break to exit)
    if condition {
        break
    }
}
```

**Range Loop (over slices, arrays, maps):**
```go
numbers := []int{1, 2, 3, 4, 5}
for index, value := range numbers {
    fmt.Printf("Index: %d, Value: %d\n", index, value)
}

// Ignore index with blank identifier
for _, value := range numbers {
    fmt.Println(value)
}

// Index only
for index := range numbers {
    fmt.Println(index)
}
```

### 4. Loop Control

**Break (exit loop immediately):**
```go
for i := 0; i < 10; i++ {
    if i == 5 {
        break  // Exit loop when i is 5
    }
    fmt.Println(i)
}
```

**Continue (skip to next iteration):**
```go
for i := 0; i < 10; i++ {
    if i%2 == 0 {
        continue  // Skip even numbers
    }
    fmt.Println(i)  // Only prints odd numbers
}
```

**Labeled Break/Continue (for nested loops):**
```go
outer:
for i := 0; i < 3; i++ {
    for j := 0; j < 3; j++ {
        if i*j > 3 {
            break outer  // Break out of both loops
        }
        fmt.Printf("%d*%d=%d ", i, j, i*j)
    }
}
```

### 5. Go Control Flow Idioms

**No while loop:** Go uses `for` with just a condition
**No do-while:** Use infinite `for` with conditional `break`
**No ternary operator:** Use `if/else` for clarity
**No parentheses required:** Around conditions (but braces are mandatory)

## Challenge Description

### Part 1: FizzBuzz Implementations

Implement FizzBuzz in three different ways:

```go
// FizzBuzz returns the FizzBuzz sequence from 1 to n
// Rules: divisible by 3 = "Fizz", by 5 = "Buzz", by both = "FizzBuzz"
func FizzBuzz(n int) []string

// FizzBuzzValue returns the FizzBuzz value for a single number
func FizzBuzzValue(n int) string

// FizzBuzzSwitch implements FizzBuzz using switch statement
func FizzBuzzSwitch(n int) string
```

### Part 2: Number Analysis Functions

```go
// IsPrime returns true if n is a prime number
func IsPrime(n int) bool

// IsEven returns true if n is even
func IsEven(n int) bool

// IsPositive returns true if n is greater than zero
func IsPositive(n int) bool

// GetSign returns "positive", "negative", or "zero"
func GetSign(n int) string

// Abs returns the absolute value of n
func Abs(n int) int
```

### Part 3: Grade Calculator

```go
// GetLetterGrade converts numeric score to letter grade
// A: 90-100, B: 80-89, C: 70-79, D: 60-69, F: 0-59
func GetLetterGrade(score int) string

// IsPassingGrade returns true if score >= 60
func IsPassingGrade(score int) bool

// GetGradePoint returns GPA points for letter grade
// A=4.0, B=3.0, C=2.0, D=1.0, F=0.0
func GetGradePoint(grade string) float64
```

### Part 4: Loop-Based Calculations

```go
// SumRange returns the sum of integers from start to end (inclusive)
func SumRange(start, end int) int

// CountEven returns count of even numbers from 1 to n
func CountEven(n int) int

// FindMax returns the maximum value in a slice
func FindMax(numbers []int) int

// Contains returns true if value exists in slice
func Contains(numbers []int, value int) bool
```

### Part 5: Pattern Printing

```go
// PrintTriangle prints a number triangle with n rows
// Example for n=4:
// 1
// 12
// 123
// 1234
func PrintTriangle(n int) string

// PrintPyramid prints a pyramid pattern
// Example for n=3:
//   *
//  ***
// *****
func PrintPyramid(n int) string
```

## Test Requirements

### FizzBuzz Tests

```go
func TestFizzBuzz(t *testing.T) {
    tests := []struct {
        name     string
        n        int
        expected []string
    }{
        {
            "first 15",
            15,
            []string{"1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8",
                "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"},
        },
        {"single", 1, []string{"1"}},
        {"up to 3", 3, []string{"1", "2", "Fizz"}},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FizzBuzz(tt.n)
            if !reflect.DeepEqual(result, tt.expected) {
                t.Errorf("FizzBuzz(%d) = %v, want %v", tt.n, result, tt.expected)
            }
        })
    }
}

func TestFizzBuzzValue(t *testing.T) {
    tests := []struct {
        name     string
        input    int
        expected string
    }{
        {"divisible by 15", 15, "FizzBuzz"},
        {"divisible by 3", 9, "Fizz"},
        {"divisible by 5", 10, "Buzz"},
        {"neither", 7, "7"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FizzBuzzValue(tt.input)
            if result != tt.expected {
                t.Errorf("FizzBuzzValue(%d) = %s, want %s",
                    tt.input, result, tt.expected)
            }
        })
    }
}
```

### Number Analysis Tests

Test each function with:
- Positive numbers
- Negative numbers
- Zero
- Edge cases (1, -1, large numbers)
- Prime number edge cases (2, 1, negative numbers)

### Grade Calculator Tests

```go
func TestGetLetterGrade(t *testing.T) {
    tests := []struct {
        name     string
        score    int
        expected string
    }{
        {"perfect score", 100, "A"},
        {"minimum A", 90, "A"},
        {"maximum B", 89, "B"},
        {"passing D", 60, "D"},
        {"failing", 59, "F"},
        {"zero", 0, "F"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := GetLetterGrade(tt.score)
            if result != tt.expected {
                t.Errorf("GetLetterGrade(%d) = %s, want %s",
                    tt.score, result, tt.expected)
            }
        })
    }
}
```

### Loop Calculation Tests

Test with:
- Empty slices
- Single-element slices
- Negative numbers
- Range boundaries
- Large ranges

## Input/Output Specifications

### FizzBuzz

```go
FizzBuzz(5)  → ["1", "2", "Fizz", "4", "Buzz"]
FizzBuzz(15) → ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8",
                "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"]

FizzBuzzValue(3)  → "Fizz"
FizzBuzzValue(5)  → "Buzz"
FizzBuzzValue(15) → "FizzBuzz"
FizzBuzzValue(7)  → "7"
```

### Number Analysis

```go
IsPrime(2)   → true
IsPrime(17)  → true
IsPrime(4)   → false
IsPrime(1)   → false
IsPrime(-5)  → false

GetSign(5)   → "positive"
GetSign(-3)  → "negative"
GetSign(0)   → "zero"
```

### Grade Calculator

```go
GetLetterGrade(95)  → "A"
GetLetterGrade(82)  → "B"
GetLetterGrade(59)  → "F"

GetGradePoint("A")  → 4.0
GetGradePoint("B")  → 3.0
GetGradePoint("F")  → 0.0
```

### Loop Calculations

```go
SumRange(1, 5)        → 15  // 1+2+3+4+5
CountEven(10)         → 5   // 2,4,6,8,10
FindMax([]int{3,7,2}) → 7
Contains([]int{1,2,3}, 2) → true
```

## Success Criteria

### Functional Requirements
- [ ] FizzBuzz correctly handles multiples of 3, 5, and 15
- [ ] Prime number checker handles edge cases (1, 2, negative numbers)
- [ ] Grade calculator covers all grade ranges correctly
- [ ] Loop functions handle empty slices/ranges gracefully
- [ ] All control flow branches are reachable and tested

### Code Quality Requirements
- [ ] Use appropriate control structures (if vs switch)
- [ ] Avoid unnecessary nesting (early returns preferred)
- [ ] Loop variables properly scoped
- [ ] No infinite loops without explicit break
- [ ] Code passes go fmt and go vet

### Testing Requirements
- [ ] Table-driven tests for all functions
- [ ] Edge cases covered (empty, zero, negative, boundaries)
- [ ] All conditional branches tested
- [ ] Test names clearly describe scenarios

## Common Pitfalls to Avoid

### 1. FizzBuzz Order Matters

```go
// ❌ Wrong: Check 15 after 3 and 5 (never reaches 15)
func FizzBuzzValue(n int) string {
    if n%3 == 0 {
        return "Fizz"
    }
    if n%5 == 0 {
        return "Buzz"
    }
    if n%15 == 0 {  // Never reached!
        return "FizzBuzz"
    }
    return fmt.Sprintf("%d", n)
}

// ✅ Correct: Check 15 first
func FizzBuzzValue(n int) string {
    if n%15 == 0 {
        return "FizzBuzz"
    }
    if n%3 == 0 {
        return "Fizz"
    }
    if n%5 == 0 {
        return "Buzz"
    }
    return fmt.Sprintf("%d", n)
}
```

### 2. Infinite Loop Without Break

```go
// ❌ Wrong: Infinite loop with no exit
for {
    process()  // If process() never returns or breaks, loops forever
}

// ✅ Correct: Include exit condition
for {
    if shouldStop() {
        break
    }
    process()
}
```

### 3. Unnecessary Nested Ifs

```go
// ❌ Wrong: Deep nesting
func GetGrade(score int) string {
    if score >= 90 {
        return "A"
    } else {
        if score >= 80 {
            return "B"
        } else {
            if score >= 70 {
                return "C"
            } else {
                return "F"
            }
        }
    }
}

// ✅ Correct: Use else if or switch
func GetGrade(score int) string {
    if score >= 90 {
        return "A"
    } else if score >= 80 {
        return "B"
    } else if score >= 70 {
        return "C"
    }
    return "F"
}

// ✅ Even better: Use switch
func GetGrade(score int) string {
    switch {
    case score >= 90:
        return "A"
    case score >= 80:
        return "B"
    case score >= 70:
        return "C"
    default:
        return "F"
    }
}
```

### 4. Ignoring Range Values

```go
// ❌ Wrong: Unused range values
for i, v := range numbers {  // If v is unused, compiler error
    fmt.Println(i)
}

// ✅ Correct: Use blank identifier
for i, _ := range numbers {
    fmt.Println(i)
}

// ✅ Or omit the value
for i := range numbers {
    fmt.Println(i)
}
```

### 5. Modifying Slice During Range

```go
// ❌ Wrong: Modifying slice while ranging (unexpected behavior)
numbers := []int{1, 2, 3}
for _, v := range numbers {
    if v == 2 {
        numbers = append(numbers, 4)  // Modifying during iteration
    }
}

// ✅ Correct: Use traditional for loop
for i := 0; i < len(numbers); i++ {
    if numbers[i] == 2 {
        numbers = append(numbers, 4)
        break  // Or adjust loop logic
    }
}
```

### 6. Forgetting Break in Switch

Go switches don't fall through by default (unlike C/Java), but if you want fallthrough, you must be explicit:

```go
// In Go, cases don't fall through automatically
switch day {
case "Monday":
    fmt.Println("Start")
    // No fallthrough - this is good!
case "Tuesday":
    fmt.Println("Second day")
}

// Explicit fallthrough if needed (rare)
switch day {
case "Saturday":
    fmt.Println("Weekend!")
    fallthrough
case "Sunday":
    fmt.Println("Sleep in")
}
```

## Extension Challenges (Optional)

### 1. Collatz Conjecture
Implement the Collatz sequence:
- Start with any positive integer n
- If n is even, divide by 2
- If n is odd, multiply by 3 and add 1
- Repeat until reaching 1
- Return the number of steps

### 2. Number Guessing Game
Build an interactive game:
- Generate random number 1-100
- User guesses
- Respond with "higher", "lower", or "correct"
- Count number of attempts

### 3. Prime Number Sieve
Implement Sieve of Eratosthenes:
- Find all primes up to n
- Use nested loops efficiently
- Return slice of prime numbers

### 4. Pattern Variations
Create more complex patterns:
- Diamond pattern
- Hollow square
- Number spiral
- Pascal's triangle (first n rows)

### 5. Menu System
Build a simple CLI menu:
- Display options in loop
- Accept user input
- Execute corresponding action
- Continue until user quits

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `strings`, `testing`, `reflect` (for DeepEqual in tests)
- No external dependencies

### Expected Approach
1. Implement FizzBuzz first (classic exercise)
2. Use switch statements where appropriate (grade calculator)
3. Demonstrate range loops vs traditional for loops
4. Show proper loop control (break, continue)
5. Implement early returns to reduce nesting
6. Write comprehensive table-driven tests

### Code Quality Expectations
- Use switch for multi-branch logic when appropriate
- Avoid deep nesting (max 2-3 levels)
- Use early returns to simplify logic
- Loop variables properly scoped
- No infinite loops without explicit exit strategy
- Comments explain "why" for non-obvious logic

### Testing Approach
- Table-driven tests for all functions
- Test boundary conditions (0, 1, negative, max values)
- Test all conditional branches
- Verify loop termination conditions
- Use descriptive test names

## Learning Resources

### Essential Reading
- [A Tour of Go - Flow Control](https://go.dev/tour/flowcontrol/1)
- [Go by Example - If/Else](https://gobyexample.com/if-else)
- [Go by Example - Switch](https://gobyexample.com/switch)
- [Go by Example - For Loops](https://gobyexample.com/for)
- [Effective Go - Control Structures](https://go.dev/doc/effective_go#control-structures)

### Specific Topics
- [Go Spec - For statements](https://go.dev/ref/spec#For_statements)
- [Go Spec - Switch statements](https://go.dev/ref/spec#Switch_statements)
- [Why Go doesn't have while loops](https://go.dev/doc/faq#Does_Go_have_a_ternary_form)

### Practice Problems
- [Exercism Go Track - Control Flow](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/) for experimentation

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run specific test
go test -v -run TestFizzBuzz

# Test with coverage
go test -cover

# Build (if main program included)
go build

# Run
go run main.go
```

---

**Previous Lesson**: [Lesson 02: Variables, Data Types & Operators](lesson-02-variables.md)
**Next Lesson**: [Lesson 04: Functions & Multiple Returns](lesson-04-functions.md)

**Estimated Completion Time**: 2-3 hours
**Difficulty Check**: If this takes >4 hours, review Go Tour flow control sections and practice FizzBuzz first
