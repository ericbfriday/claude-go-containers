# AI Provider Competition Guide

This guide explains how different AI coding assistants can create competing implementations of lesson specifications, enabling learners to compare approaches and learn from multiple perspectives.

## Overview

The GoLang Learning Curriculum uses a **specification-driven approach** where:
1. **Lesson specifications** define requirements, test cases, and success criteria
2. **Multiple AI providers** generate independent implementations
3. **Learners compare** different solutions to understand trade-offs and best practices
4. **Human reviews** select exemplar "reference" implementations

## Supported AI Providers

### 1. Claude Code (via Claude CLI)

**Installation & Setup:**
```bash
# Install Claude CLI
npm install -g @anthropic-ai/claude-code

# Authenticate
claude auth

# Verify setup
claude --version
```

**Implementation Workflow:**
```bash
# Navigate to lessons directory
cd /workspaces/claude-go-containers/lessons

# Read specification
claude "Generate implementation for this Go lesson specification" < specifications/lesson-01-hello-world.md > implementations/claude/lesson-01/main.go

# Or interactive mode
claude
# Then paste specification and request implementation
```

**Claude Strengths:**
- Comprehensive documentation comments
- Strong adherence to Go idioms
- Excellent error handling patterns
- Thoughtful test coverage

**Best Practices:**
- Request explanations of design decisions in README
- Ask for multiple approaches when appropriate
- Prompt for edge case handling explicitly

### 2. OpenCode AI (SST Terminal Agent)

**Installation & Setup:**
```bash
# Already installed in dev container
opencode --version

# Start interactive session
opencode
```

**Implementation Workflow:**
```bash
# Open specification
opencode specifications/lesson-01-hello-world.md

# In OpenCode prompt:
"Implement this Go lesson specification following idiomatic Go practices.
Create implementation in implementations/opencode/lesson-01/.
Include comprehensive tests and a README explaining the approach."

# Or non-interactive
cat specifications/lesson-01-hello-world.md | opencode --prompt "Implement this specification"
```

**OpenCode Strengths:**
- Terminal-native workflow
- LSP integration for Go language server
- Context-aware suggestions
- Fast iteration cycles

**Best Practices:**
- Leverage LSP for automatic imports and formatting
- Use interactive mode for clarifications
- Request refactoring suggestions

### 3. GitHub Copilot (VS Code Extension)

**Implementation Workflow:**
1. Open `specifications/lesson-01-hello-world.md` in VS Code
2. Create new file: `implementations/copilot/lesson-01/main.go`
3. Add comment with specification summary:
```go
// Implement Lesson 01: Hello World & Basic Syntax
// Requirements:
// - BasicGreet() returns "Hello, World!"
// - Greet(name string) handles empty names
// - CustomGreet(name, greeting string) with defaults
// - FormatName(first, last string) handles empty strings
// Tests required: table-driven pattern
```
4. Let Copilot suggest implementations
5. Create `main_test.go` with test structure comment
6. Copilot will suggest test cases

**Copilot Strengths:**
- Real-time inline suggestions
- Context from open files
- Fast completion of repetitive patterns
- Good at generating test boilerplate

**Best Practices:**
- Write detailed comments before implementations
- Review suggestions carefully
- Use Copilot Chat for explanations
- Verify Go idioms (Copilot may suggest non-idiomatic patterns)

### 4. Cursor AI (Cursor Editor)

**Implementation Workflow:**
1. Open lesson specification in Cursor
2. Select specification text
3. Use Cmd/Ctrl+K or Cmd/Ctrl+L to invoke AI
4. Prompt: "Implement this Go lesson specification in implementations/cursor/lesson-01/"
5. Review generated code
6. Use Cursor Chat for refinements

**Cursor Strengths:**
- Codebase-aware suggestions
- Multi-file generation
- Iterative refinement workflow
- Good for larger refactorings

**Best Practices:**
- Use codebase context feature
- Request explanations in-line
- Iterate with follow-up prompts
- Compare against existing implementations

### 5. Reference Implementations (Human-Reviewed)

**Purpose:**
- Serve as exemplar solutions after AI implementations reviewed
- Demonstrate best practices when AI solutions vary in quality
- Provide teaching examples with detailed annotations

**Selection Process:**
1. Review all AI provider implementations
2. Identify best practices from each
3. Create synthesized "reference" implementation
4. Annotate with teaching comments
5. Place in `implementations/reference/lesson-XX/`

**Reference Implementation Criteria:**
- Strictly idiomatic Go
- Comprehensive documentation
- Excellent test coverage
- Clear design rationale
- Performance-conscious when relevant

## Implementation Directory Structure

```
lessons/
├── specifications/
│   └── lesson-01-hello-world.md
├── implementations/
│   ├── claude/
│   │   └── lesson-01/
│   │       ├── main.go
│   │       ├── greet.go
│   │       ├── greet_test.go
│   │       └── README.md
│   ├── opencode/
│   │   └── lesson-01/
│   │       ├── main.go
│   │       ├── greet.go
│   │       ├── greet_test.go
│   │       └── README.md
│   ├── copilot/
│   │   └── lesson-01/
│   │       ├── main.go
│   │       ├── greet.go
│   │       ├── greet_test.go
│   │       └── README.md
│   ├── cursor/
│   │   └── lesson-01/
│   │       ├── main.go
│   │       ├── greet.go
│   │       ├── greet_test.go
│   │       └── README.md
│   └── reference/
│       └── lesson-01/
│           ├── main.go
│           ├── greet.go
│           ├── greet_test.go
│           └── README.md  # Includes teaching annotations
└── assessments/
    └── lesson-01-rubric.md
```

## Required Files for Each Implementation

### 1. Implementation File(s)
- `main.go` (if executable) or feature-specific files
- Follow Go naming conventions
- Include package documentation
- Export appropriate functions

### 2. Test File(s)
- `*_test.go` following Go conventions
- Table-driven tests where appropriate
- Comprehensive edge case coverage
- Benchmark tests for performance-sensitive code

### 3. README.md
Required sections:
```markdown
# Lesson XX Implementation - [Provider Name]

## Approach

[Explain design decisions, architecture choices, trade-offs]

## Implementation Details

[Key algorithms, data structures, patterns used]

## Testing Strategy

[How tests were structured, what edge cases covered, why]

## Running the Code

```bash
# Build
go build

# Run
go run main.go

# Test
go test -v

# Test with coverage
go test -cover
```

## Challenges Encountered

[What was tricky, how was it solved]

## Alternative Approaches Considered

[Other ways this could have been implemented, why this was chosen]
```

## Quality Standards

All implementations must:

### Code Quality
- [ ] Pass `go fmt` (formatted correctly)
- [ ] Pass `go vet` (no common mistakes)
- [ ] Pass `staticcheck` (if available)
- [ ] Follow [Effective Go](https://go.dev/doc/effective_go) guidelines
- [ ] Use idiomatic Go patterns
- [ ] Have clear, descriptive names
- [ ] Include documentation comments for exported items

### Functionality
- [ ] Meet all requirements in specification
- [ ] Handle edge cases defined in spec
- [ ] Return errors appropriately (don't panic unless truly exceptional)
- [ ] Work correctly with sample inputs provided

### Testing
- [ ] All tests pass
- [ ] Table-driven tests used where appropriate
- [ ] Edge cases tested
- [ ] Error conditions tested
- [ ] Achieve >80% code coverage (aim for 90%+)

### Documentation
- [ ] README explains approach
- [ ] Code comments explain "why" not "what"
- [ ] Complex algorithms documented
- [ ] Trade-offs discussed in README

## Validation Checklist

Before submitting an implementation:

```bash
# 1. Format code
cd implementations/[provider]/lesson-XX
go fmt ./...

# 2. Check for common mistakes
go vet ./...

# 3. Run linter (if available)
staticcheck ./...

# 4. Run tests
go test -v

# 5. Check test coverage
go test -cover -coverprofile=coverage.out
go tool cover -html=coverage.out

# 6. Build (if executable)
go build

# 7. Run (if applicable)
./lesson-XX

# 8. Verify against specification
# Review each requirement in specifications/lesson-XX.md
# Ensure all are met
```

## Comparative Analysis Guide

### For Learners

When comparing implementations:

1. **Correctness First**
   - Do all implementations pass tests?
   - Which handles edge cases best?

2. **Code Clarity**
   - Which is easiest to understand?
   - Which has best variable/function names?
   - Which has clearest structure?

3. **Go Idioms**
   - Which follows Go conventions most closely?
   - Which uses standard library effectively?
   - Which demonstrates idiomatic patterns?

4. **Testing Approach**
   - Which has most comprehensive tests?
   - Which test structure is clearest?
   - Which covers edge cases best?

5. **Performance** (when relevant)
   - Which is most efficient?
   - Are performance differences significant?
   - What are the trade-offs?

6. **Maintainability**
   - Which would be easiest to modify?
   - Which has best documentation?
   - Which separates concerns well?

### Comparison Template

Create `implementations/lesson-XX-comparison.md`:

```markdown
# Lesson XX: Implementation Comparison

## Correctness
| Provider | Tests Pass | Edge Cases | Error Handling |
|----------|-----------|------------|----------------|
| Claude   | ✅        | ✅         | ✅             |
| OpenCode | ✅        | ✅         | ⚠️             |
| Copilot  | ✅        | ⚠️         | ✅             |
| Cursor   | ✅        | ✅         | ✅             |

## Code Quality
| Provider | Readability | Go Idioms | Structure | Documentation |
|----------|-------------|-----------|-----------|---------------|
| Claude   | 9/10        | 10/10     | 9/10      | 10/10         |
| OpenCode | 8/10        | 9/10      | 8/10      | 8/10          |
| Copilot  | 7/10        | 7/10      | 7/10      | 6/10          |
| Cursor   | 8/10        | 8/10      | 9/10      | 8/10          |

## Testing
| Provider | Coverage | Test Quality | Edge Cases | Benchmarks |
|----------|----------|--------------|------------|------------|
| Claude   | 95%      | Excellent    | Complete   | Yes        |
| OpenCode | 90%      | Good         | Good       | No         |
| Copilot  | 85%      | Good         | Adequate   | No         |
| Cursor   | 88%      | Good         | Good       | No         |

## Key Differences

### Claude
- Most comprehensive documentation
- Best error handling
- Most complete test coverage
- Follows Effective Go most closely

### OpenCode
- Clean, concise implementations
- Good use of standard library
- Solid core functionality
- Could improve edge case handling

### Copilot
- Fast, practical implementations
- Good for boilerplate
- Sometimes misses Go idioms
- Needs more documentation

### Cursor
- Good balance of quality and speed
- Strong multi-file organization
- Solid overall approach
- Good refactoring suggestions

## Recommendation

For learning purposes, study implementations in this order:
1. **Reference** - exemplar for the lesson
2. **Claude** - comprehensive, well-documented
3. **OpenCode** or **Cursor** - practical, clean approaches
4. **Copilot** - see what quick suggestions provide

For practical development:
- Use **Claude** for complex logic requiring excellent docs
- Use **Copilot** for boilerplate and repetitive code
- Use **OpenCode** for terminal-native workflow
- Use **Cursor** for codebase-wide refactorings
```

## Advanced Usage

### Combining Multiple Providers

1. **Scaffolding with Copilot**
   - Generate initial structure quickly
   - Create test file boilerplate

2. **Implementation with Claude/OpenCode**
   - Fill in complex logic
   - Refine error handling
   - Improve documentation

3. **Refactoring with Cursor**
   - Optimize organization
   - Improve consistency
   - Apply patterns across files

### Iterative Improvement

```bash
# Round 1: Get initial implementation
claude "Implement lesson spec" < spec.md > claude/main.go

# Round 2: Review and request improvements
claude "Review this implementation and suggest improvements focusing on Go idioms" < claude/main.go

# Round 3: Apply refinements
claude "Apply these refinements: [list specific issues]"

# Compare with others
diff claude/main.go opencode/main.go
```

## Troubleshooting

### Common Issues

**AI generates non-idiomatic Go:**
- Explicitly request "idiomatic Go" in prompts
- Reference Effective Go in prompts
- Ask for explanations of patterns used

**Tests are insufficient:**
- Specify "comprehensive table-driven tests"
- List specific edge cases to test
- Request coverage report validation

**Documentation is lacking:**
- Request "production-quality documentation"
- Ask for package, function, and complex logic docs
- Specify Go doc comment conventions

**Code doesn't match specification:**
- Break specification into smaller chunks
- Verify each requirement individually
- Use checklist from specification

## Contributing New Providers

To add support for a new AI provider:

1. Create directory: `implementations/[provider-name]/`
2. Document setup in this guide
3. Provide implementation workflow
4. List strengths and best practices
5. Submit example implementation for lesson 01
6. Update comparison templates

## Questions and Support

- **Specification questions**: Review lesson specification carefully
- **AI provider setup**: See respective provider documentation
- **Go language questions**: Refer to docs/guides/
- **General questions**: Check repository README and CLAUDE.md

---

**Last Updated**: 2025-11-11
**Supported Providers**: 5 (Claude, OpenCode, Copilot, Cursor, Reference)
