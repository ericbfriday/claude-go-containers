# Lesson XX: [Title]

**Phase**: [1-7] - [Phase Name]
**Estimated Time**: [X-Y hours]
**Difficulty**: [Beginner|Intermediate|Advanced]

## Learning Objectives

By the end of this lesson, learners will be able to:
- [Objective 1]
- [Objective 2]
- [Objective 3]
- [... 5-8 specific, measurable objectives]

## Prerequisites

- [Required lesson or knowledge]
- [Development environment requirements]
- [Specific tools or packages needed]

## Core Concepts

### 1. [Concept Name]

[Detailed explanation with code examples]

```go
// Example code demonstrating the concept
```

### 2. [Another Concept]

[Explanation with examples]

### [Additional Concepts]

## Challenge Description

### Part 1: [Challenge Component 1]

[Detailed description of what learners need to build]

```go
// Function signatures or expected interfaces
func ExampleFunction(param type) returnType
```

### Part 2: [Challenge Component 2]

[Additional requirements]

### [Additional Parts as Needed]

## Test Requirements

Implement comprehensive table-driven tests that cover:

### [Function/Feature] Tests

```go
func Test[FunctionName](t *testing.T) {
    tests := []struct {
        name     string
        input    [type]
        expected [type]
    }{
        {"test case 1", input1, expected1},
        {"test case 2", input2, expected2},
        // ... more test cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := [FunctionName](tt.input)
            if result != tt.expected {
                t.Errorf("[FunctionName](%v) = %v, want %v",
                    tt.input, result, tt.expected)
            }
        })
    }
}
```

### [Additional Test Suites]

## Input/Output Specifications

Provide concrete examples:

```go
Input:  [example input]
Output: [expected output]

Input:  [edge case input]
Output: [expected output]

// Include edge cases, error cases, and typical usage
```

## Success Criteria

### Functional Requirements
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Edge cases handled]
- [ ] [Error handling correct]

### Code Quality Requirements
- [ ] Code passes `go fmt`
- [ ] Code passes `go vet`
- [ ] All exported functions documented
- [ ] Variables well-named and scoped
- [ ] [Language-specific idioms followed]

### Testing Requirements
- [ ] All tests pass: `go test -v`
- [ ] Table-driven tests where appropriate
- [ ] Edge cases covered
- [ ] Error cases tested
- [ ] [Coverage target if applicable]

### Project Structure
```
lesson-XX/
├── main.go          # Main program (if applicable)
├── [feature].go     # Implementation
├── [feature]_test.go # Tests
└── README.md        # Implementation explanation
```

## Common Pitfalls to Avoid

### 1. [Pitfall Name]
```go
// ❌ Wrong: [why it's wrong]
[bad code example]

// ✅ Correct: [why it's right]
[good code example]
```

### 2. [Another Pitfall]

### [Additional Pitfalls - 4-6 total]

## Extension Challenges (Optional)

For learners who complete core requirements quickly:

### 1. [Challenge Name]
[Description and requirements]

### 2. [Another Challenge]

### [3-5 Extension Challenges]

## AI Provider Guidelines

### Allowed Packages
- Standard library: [list specific packages]
- External (if any): [list and justify]

### Expected Approach
1. [Step 1 of recommended approach]
2. [Step 2]
3. [Step 3]
4. [etc.]

### Code Quality Expectations
- [Specific Go idioms to follow]
- [Performance considerations]
- [Security considerations if applicable]
- [Architectural patterns to use]

### Testing Approach
- [Specific testing patterns expected]
- [Coverage expectations]
- [Performance testing if applicable]

## Learning Resources

### Essential Reading
- [Link 1 with description]
- [Link 2 with description]
- [Official Go documentation links]

### Video Tutorials (if available)
- [Link with description]

### Related Examples
- [Go by Example link]
- [Standard library examples]

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run with coverage
go test -cover -coverprofile=coverage.out
go tool cover -html=coverage.out

# Build (if applicable)
go build -o lessonXX

# Run (if applicable)
./lessonXX
```

---

**Previous Lesson**: [Lesson [XX-1]: [Previous Title]](lesson-[XX-1]-[slug].md)
**Next Lesson**: [Lesson [XX+1]: [Next Title]](lesson-[XX+1]-[slug].md)

**Estimated Completion Time**: [X-Y hours]
**Difficulty Check**: If this takes >[threshold] hours, [recommendation]
