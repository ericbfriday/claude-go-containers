# Getting Started with the GoLang Learning Curriculum

Welcome to the comprehensive GoLang learning curriculum! This guide will help you begin your journey from Go novice to proficient TUI developer.

## Quick Start

### 1. Understand the Curriculum Structure

```bash
# Read the curriculum overview
cat lessons/README.md

# Review all 42 lessons
cat lessons/LESSON_MANIFEST.md

# Understand the AI competition system
cat lessons/AI_PROVIDER_GUIDE.md
```

### 2. Start with Lesson 01

```bash
# Read the first lesson specification
cat lessons/specifications/lesson-01-hello-world.md
```

### 3. Choose Your Learning Path

You have three options:

#### Option A: Self-Study (Recommended for Learning)
```bash
# 1. Read the specification thoroughly
# 2. Attempt implementation yourself
# 3. Create your solution in a practice directory
# 4. Compare with AI implementations afterward
```

#### Option B: AI-Assisted Implementation
```bash
# Using Claude CLI
cd lessons
claude "Implement this lesson specification following Go best practices" < specifications/lesson-01-hello-world.md

# Using OpenCode AI
opencode specifications/lesson-01-hello-world.md
# Then prompt: "Implement this specification"
```

#### Option C: Multi-AI Comparison (Best for Learning Patterns)
```bash
# Generate implementations from multiple AI providers
# Compare approaches, code quality, and testing strategies
# See AI_PROVIDER_GUIDE.md for detailed workflow
```

## Learning Path Recommendations

### For Complete Beginners

**Week 1-2: Foundation**
1. Start with Phase 1 lessons (1-8)
2. Complete each lesson's core requirements
3. Attempt extension challenges for deeper understanding
4. Build the Quiz Game milestone project (Lesson 8)

**Week 3-4: CLI Development**
1. Progress through Phase 2 lessons (9-14)
2. Focus on Cobra framework (lessons 11-12)
3. Complete Task Tracker milestone (Lesson 13)
4. Integrate with APIs (Lesson 14)

**Week 5: Visual Enhancement**
1. Learn Lip Gloss styling (lessons 15-18)
2. Enhance your previous CLI projects
3. Build styled CLI milestone (Lesson 18)

**Week 6-7: Concurrency**
1. Master concurrent programming (lessons 19-24)
2. Build concurrent web crawler milestone (Lesson 24)

**Week 8-13: TUI Mastery**
1. Learn Bubble Tea architecture (lessons 25-30)
2. Master Bubbles components (lessons 31-36)
3. Build advanced TUIs (lessons 37-42)
4. Complete capstone projects (lessons 41-42)

### For Experienced Programmers

**Accelerated Path (2 weeks intensive):**
- Days 1-3: Lessons 1-8 (Go fundamentals)
- Days 4-5: Lessons 9-14 (CLI development)
- Days 6-7: Lessons 19-24 (Concurrency)
- Days 8-10: Lessons 25-36 (Bubble Tea & Bubbles)
- Days 11-14: Lessons 37-42 (Advanced TUI)

### For Part-Time Learners

**8-12 Week Plan (5-10 hours/week):**
- Weeks 1-2: Phase 1 (Fundamentals)
- Weeks 3-4: Phase 2 (CLI)
- Week 5: Phase 3 (Styling)
- Weeks 6-7: Phase 4 (Concurrency)
- Weeks 8-9: Phase 5 (Bubble Tea)
- Weeks 10-11: Phase 6 (Bubbles)
- Week 12: Phase 7 (Advanced)

## Using AI Providers Effectively

### Best Practices

1. **Read specifications first** - Understand requirements before implementation
2. **Attempt yourself when possible** - Build muscle memory
3. **Compare multiple implementations** - Learn different approaches
4. **Study the differences** - Understand trade-offs
5. **Reference implementations** - Use as learning tools, not just answers

### AI Provider Strengths

**Claude Code**
- Use for: Complex logic, comprehensive documentation
- Best for: Learning idiomatic Go patterns
- Strong in: Error handling, test coverage

**OpenCode AI**
- Use for: Terminal-native workflow, quick iterations
- Best for: Interactive development sessions
- Strong in: LSP integration, practical code

**GitHub Copilot**
- Use for: Boilerplate, repetitive patterns
- Best for: Fast scaffolding
- Strong in: Inline suggestions

**Cursor AI**
- Use for: Codebase-aware refactoring
- Best for: Multi-file operations
- Strong in: Architectural improvements

## Validation Workflow

For every lesson implementation:

```bash
# 1. Navigate to implementation directory
cd lessons/implementations/[provider]/lesson-XX

# 2. Format code
go fmt ./...

# 3. Check for issues
go vet ./...

# 4. Run linter (if available)
staticcheck ./...

# 5. Run tests
go test -v

# 6. Check coverage
go test -cover -coverprofile=coverage.out
go tool cover -html=coverage.out

# 7. Build (if executable)
go build

# 8. Run (if applicable)
./lesson-XX
```

## Progress Tracking

### Completion Checklist

Create your own progress tracker:

```markdown
# My Go Learning Progress

## Phase 1: Fundamentals
- [ ] Lesson 01: Hello World
- [ ] Lesson 02: Variables & Types
- [ ] Lesson 03: Control Flow
- [ ] Lesson 04: Functions
- [ ] Lesson 05: Structs & Methods
- [ ] Lesson 06: Interfaces
- [ ] Lesson 07: Error Handling
- [ ] Lesson 08: Packages & Modules
- [ ] Milestone: Quiz Game

[Continue for all phases...]

## Skills Acquired
- [ ] Go fundamentals
- [ ] CLI development
- [ ] Cobra framework
- [ ] Concurrency patterns
- [ ] Bubble Tea architecture
- [ ] TUI development

## Projects Completed
- [ ] Quiz Game
- [ ] Task Tracker CLI
- [ ] Styled CLI
- [ ] Web Crawler
- [ ] Shopping List TUI
- [ ] Todo TUI
- [ ] Kanban Board
- [ ] Git Dashboard
```

### Milestone Achievements

Celebrate completing these major milestones:
1. **Quiz Game** (Lesson 8) - Go fundamentals mastery
2. **Task Tracker** (Lesson 13) - CLI proficiency
3. **Styled CLI** (Lesson 18) - Visual design skills
4. **Web Crawler** (Lesson 24) - Concurrency mastery
5. **Shopping List** (Lesson 28) - Bubble Tea basics
6. **Todo TUI** (Lesson 36) - Component composition
7. **Kanban Board** (Lesson 41) - Production-quality TUI
8. **Git Dashboard** (Lesson 42) - Enterprise-grade application

## Getting Help

### Documentation Resources

1. **Lesson Specifications** (`lessons/specifications/`)
   - Detailed requirements and test cases
   - Common pitfalls to avoid
   - Extension challenges

2. **Learning Guides** (`docs/guides/`)
   - Go learning plan
   - Go in 2025 ecosystem guide
   - AI tools setup

3. **CLAUDE.md**
   - Claude Code specific guidance
   - Implementation workflows
   - Best practices

### External Resources

- [Tour of Go](https://go.dev/tour/) - Interactive basics
- [Go by Example](https://gobyexample.com/) - Practical examples
- [Effective Go](https://go.dev/doc/effective_go) - Idiomatic patterns
- [Go Documentation](https://go.dev/doc/) - Official docs
- [Charm.sh](https://charm.sh/) - TUI ecosystem

### Community Support

- **Go Community**: [Gophers Slack](https://invite.slack.golangbridge.org/)
- **Charm Community**: [Charm Discord](https://charm.sh/discord)
- **Reddit**: [r/golang](https://reddit.com/r/golang)

## Tips for Success

### Learning Best Practices

1. **Build, Don't Just Read**
   - Type code yourself
   - Experiment with variations
   - Break things and fix them

2. **Test Everything**
   - Write tests before implementation (TDD)
   - Use table-driven test pattern
   - Aim for >80% coverage

3. **Review and Refactor**
   - Compare your code with AI implementations
   - Identify improvements
   - Refactor to Go idioms

4. **Document Your Journey**
   - Keep notes on learnings
   - Document challenges and solutions
   - Build a personal knowledge base

5. **Practice Regularly**
   - Daily practice > weekend marathons
   - Even 30 minutes daily helps
   - Consistency builds muscle memory

### Common Pitfalls to Avoid

1. **Don't skip fundamentals** - Phases 1-2 are critical foundation
2. **Don't just copy AI code** - Understand every line
3. **Don't skip tests** - Testing is part of learning
4. **Don't rush milestones** - Ensure mastery before advancing
5. **Don't ignore errors** - Go's error handling is fundamental

### When You Get Stuck

1. **Read the specification again** - Often clarifies confusion
2. **Check common pitfalls section** - May address your issue
3. **Review AI implementations** - See different approaches
4. **Consult learning guides** - Deep dive into concepts
5. **Take a break** - Fresh perspective often helps

## Next Steps

Ready to begin? Here's your action plan:

```bash
# 1. Read Lesson 01 specification
cat lessons/specifications/lesson-01-hello-world.md

# 2. Create your workspace
mkdir -p ~/go-learning/lesson-01
cd ~/go-learning/lesson-01

# 3. Initialize Go module
go mod init lesson-01

# 4. Start implementing!
# Create: main.go, greet.go, greet_test.go

# 5. Test as you go
go test -v

# 6. Compare with AI implementations when done
diff ~/go-learning/lesson-01/greet.go /workspaces/claude-go-containers/lessons/implementations/claude/lesson-01/greet.go
```

## Graduation Goals

By completing this curriculum, you will:

✅ Master Go fundamentals and idiomatic patterns
✅ Build professional CLI applications with Cobra
✅ Implement concurrent programs safely and effectively
✅ Create beautiful terminal UIs with Bubble Tea
✅ Compose complex applications from Bubbles components
✅ Deploy production-ready Go applications
✅ Understand modern Go ecosystem (2025 best practices)
✅ Compare and evaluate different implementation approaches

---

**Ready to start?** Open `lessons/specifications/lesson-01-hello-world.md` and begin your journey!

**Questions?** Review `lessons/README.md` and `lessons/AI_PROVIDER_GUIDE.md` for comprehensive information.

**Happy Learning!** 🎓🚀
