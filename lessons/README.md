# GoLang Learning Curriculum

A comprehensive, progressive learning curriculum for mastering Go development, from fundamentals to advanced TUI applications with Charm.sh.

## Overview

This curriculum is designed to take learners from Go novices to proficient CLI/TUI developers over **2-4 weeks of intensive study** (or 8-12 weeks part-time). Each lesson includes detailed specifications that enable multiple AI providers to create competing implementations and tests.

## Learning Philosophy

Based on extensive research from the docs/guides:
- **Evidence-based progression**: Start simple before complexity
- **Incremental challenge**: Each lesson builds on previous knowledge
- **Table-driven testing**: Go's idiomatic testing pattern from day one
- **AI-assisted learning**: Leverage Claude CLI, OpenCode AI, and other tools
- **Competing implementations**: Multiple AI solutions foster learning through comparison

## Curriculum Structure

### Phase 1: Go Fundamentals (Weeks 1-2)
**Objective**: Master Go syntax, data types, control flow, and core concepts

- **Lesson 01**: Hello World & Basic Syntax (1-2 hours)
- **Lesson 02**: Variables, Data Types & Operators (2-3 hours)
- **Lesson 03**: Control Flow: If, Switch, Loops (2-3 hours)
- **Lesson 04**: Functions & Multiple Returns (2-3 hours)
- **Lesson 05**: Structs & Methods (3-4 hours)
- **Lesson 06**: Interfaces & Polymorphism (3-4 hours)
- **Lesson 07**: Error Handling Patterns (3-4 hours)
- **Lesson 08**: Packages & Modules (2-3 hours)

**Total Time**: 20-30 hours | **Quick Wins**: Quiz Game, Number Guessing Game, Calculator

### Phase 2: CLI Development (Weeks 3-4)
**Objective**: Build command-line applications with standard library and Cobra framework

- **Lesson 09**: Standard Library CLI with flag package (2-3 hours)
- **Lesson 10**: File I/O & JSON Persistence (3-4 hours)
- **Lesson 11**: Cobra Framework Fundamentals (3-4 hours)
- **Lesson 12**: Cobra Subcommands & Flags (3-4 hours)
- **Lesson 13**: Building a Task Tracker CLI (4-6 hours)
- **Lesson 14**: API Integration & HTTP Clients (4-6 hours)

**Total Time**: 19-27 hours | **Projects**: Task Tracker, GitHub User Activity, Weather CLI

### Phase 3: Styling with Lip Gloss (Week 5)
**Objective**: Add visual polish to CLI applications before diving into TUIs

- **Lesson 15**: Lip Gloss Basics: Colors & Borders (2-3 hours)
- **Lesson 16**: Layout & Composition (3-4 hours)
- **Lesson 17**: Adaptive Styling & Theming (2-3 hours)
- **Lesson 18**: Enhancing Existing CLIs with Style (3-4 hours)

**Total Time**: 10-14 hours | **Projects**: Styled Task Tracker, Formatted Output Tools

### Phase 4: Concurrency Fundamentals (Weeks 6-7)
**Objective**: Master goroutines, channels, and concurrent programming patterns

- **Lesson 19**: Introduction to Goroutines (2-3 hours)
- **Lesson 20**: Channels: Unbuffered & Buffered (3-4 hours)
- **Lesson 21**: Channel Patterns: Select, Timeouts, Closing (3-4 hours)
- **Lesson 22**: Sync Package: WaitGroups & Mutexes (3-4 hours)
- **Lesson 23**: Worker Pools & Pipeline Patterns (4-5 hours)
- **Lesson 24**: Context for Cancellation & Deadlines (3-4 hours)

**Total Time**: 18-24 hours | **Projects**: Concurrent Web Crawler, Batch File Processor

### Phase 5: Bubble Tea Architecture (Weeks 8-9)
**Objective**: Learn The Elm Architecture and build interactive TUIs

- **Lesson 25**: Bubble Tea Fundamentals: Model-Update-View (3-4 hours)
- **Lesson 26**: Messages & Event Handling (3-4 hours)
- **Lesson 27**: Commands & Asynchronous I/O (4-5 hours)
- **Lesson 28**: Building a Shopping List Tutorial (4-6 hours)
- **Lesson 29**: Stopwatch & Timer Applications (3-4 hours)
- **Lesson 30**: File Browser with Navigation (4-6 hours)

**Total Time**: 21-29 hours | **Projects**: Shopping List, Stopwatch, File Browser

### Phase 6: Bubbles Components (Weeks 10-11)
**Objective**: Master pre-built components and composition patterns

- **Lesson 31**: TextInput & Form Building (3-4 hours)
- **Lesson 32**: List Component with Selection (3-4 hours)
- **Lesson 33**: Table Component for Data Display (3-4 hours)
- **Lesson 34**: Viewport for Scrollable Content (3-4 hours)
- **Lesson 35**: Spinner, Progress, & Visual Feedback (2-3 hours)
- **Lesson 36**: Component Composition Patterns (4-5 hours)

**Total Time**: 18-24 hours | **Projects**: Interactive Todo TUI, Data Table Browser

### Phase 7: Advanced TUI Development (Weeks 12-13)
**Objective**: Build production-ready terminal applications

- **Lesson 37**: Huh Forms Library (3-4 hours)
- **Lesson 38**: Complex State Management (4-5 hours)
- **Lesson 39**: Keyboard Shortcuts & Help Systems (3-4 hours)
- **Lesson 40**: Testing TUI Applications (4-5 hours)
- **Lesson 41**: Kanban Board Capstone Project (8-12 hours)
- **Lesson 42**: Git TUI Dashboard (8-12 hours)

**Total Time**: 30-42 hours | **Projects**: Kanban Board, Git Dashboard

## Total Curriculum Time
- **Intensive (full-time)**: 136-190 hours over 2-4 weeks
- **Part-time**: Same content over 8-12 weeks at 5-10 hours/week

## Lesson Specification Format

Each lesson in the `specifications/` directory follows this structure:

```markdown
# Lesson XX: Title

## Learning Objectives
- Specific, measurable goals for the lesson

## Prerequisites
- Required knowledge from previous lessons

## Core Concepts
- Key concepts to be taught
- Go idioms and best practices
- Common pitfalls to avoid

## Challenge Description
- Detailed problem statement
- Input/output specifications
- Constraints and requirements

## Test Requirements
- Specific test cases to implement
- Edge cases to handle
- Performance expectations

## Success Criteria
- How to know the implementation is correct
- Code quality expectations
- Documentation requirements

## Extension Challenges (Optional)
- Additional features for advanced learners
- Performance optimizations
- Alternative approaches

## AI Provider Guidelines
- Framework/library constraints
- Idiomatic Go patterns to follow
- Testing approach expectations
```

## AI Provider Competition System

### Workflow
1. **Specification Review**: AI provider reads lesson specification from `specifications/lesson-XX.md`
2. **Implementation**: Creates solution in `implementations/[provider-name]/lesson-XX/`
3. **Testing**: Implements comprehensive tests following Go conventions
4. **Documentation**: Explains approach and design decisions
5. **Comparison**: Learners compare multiple AI implementations

### Directory Structure
```
lessons/
├── README.md (this file)
├── specifications/
│   ├── lesson-01-hello-world.md
│   ├── lesson-02-variables.md
│   └── ...
├── implementations/
│   ├── claude/
│   │   ├── lesson-01/
│   │   │   ├── main.go
│   │   │   ├── main_test.go
│   │   │   └── README.md
│   │   └── ...
│   ├── opencode/
│   │   └── ...
│   ├── copilot/
│   │   └── ...
│   └── reference/
│       └── ... (human-reviewed exemplar solutions)
└── assessments/
    ├── lesson-01-rubric.md
    └── ...
```

### Supported AI Providers
- **Claude Code CLI**: Anthropic's Claude via `claude` command
- **OpenCode AI**: SST's terminal AI agent via `opencode` command
- **GitHub Copilot**: VS Code extension implementations
- **Cursor AI**: Cursor editor implementations
- **Reference**: Human-reviewed exemplar solutions

## Learning Resources

### Primary Guides
- [go-learning-plan.md](../docs/guides/go-learning-plan.md) - Comprehensive learning progression
- [go-in-2025-guide.md](../docs/guides/go-in-2025-guide.md) - Modern Go ecosystem and best practices
- [OPENCODE_SETUP.md](../docs/guides/OPENCODE_SETUP.md) - AI tool configuration

### External Resources
- [Tour of Go](https://go.dev/tour/) - Official interactive introduction
- [Go by Example](https://gobyexample.com/) - Hands-on examples
- [Gophercises](https://gophercises.com/) - 20 CLI exercises by Jon Calhoun
- [Exercism Go Track](https://exercism.org/tracks/go) - 141 exercises with mentoring
- [Charm.sh Documentation](https://charm.sh/) - Official Charm ecosystem docs

## Using This Curriculum

### For Self-Study
1. Start with Phase 1 lesson specifications
2. Attempt implementation before viewing AI solutions
3. Compare your solution with multiple AI implementations
4. Review rubrics to understand code quality expectations
5. Progress to next lesson only after mastering current one

### For AI-Assisted Learning
```bash
# Get Claude's implementation
claude "Implement lesson 01 specification" < specifications/lesson-01-hello-world.md

# Get OpenCode's implementation
opencode specifications/lesson-01-hello-world.md
# Then ask: "Implement this specification following Go best practices"

# Compare implementations
diff implementations/claude/lesson-01/main.go implementations/opencode/lesson-01/main.go
```

### For Educators/Mentors
1. Use specifications as assignment templates
2. Have students implement before showing AI solutions
3. Facilitate discussions comparing different approaches
4. Use rubrics for consistent grading
5. Add custom challenges as needed

## Progress Tracking

### Completion Checklist
- [ ] Phase 1: Go Fundamentals (Lessons 1-8)
- [ ] Phase 2: CLI Development (Lessons 9-14)
- [ ] Phase 3: Styling with Lip Gloss (Lessons 15-18)
- [ ] Phase 4: Concurrency Fundamentals (Lessons 19-24)
- [ ] Phase 5: Bubble Tea Architecture (Lessons 25-30)
- [ ] Phase 6: Bubbles Components (Lessons 31-36)
- [ ] Phase 7: Advanced TUI Development (Lessons 37-42)

### Milestone Projects
- [ ] Quiz Game (Lesson 8 milestone)
- [ ] Task Tracker CLI (Lesson 13)
- [ ] Styled CLI Tool (Lesson 18)
- [ ] Concurrent Web Crawler (Lesson 24)
- [ ] Shopping List TUI (Lesson 28)
- [ ] Interactive Todo TUI (Lesson 36)
- [ ] Kanban Board (Lesson 41)
- [ ] Git TUI Dashboard (Lesson 42)

## Contributing

### Adding New Lessons
1. Create specification in `specifications/lesson-XX-name.md`
2. Follow specification template format
3. Include comprehensive test requirements
4. Define clear success criteria
5. Update this README with lesson details

### Contributing Implementations
1. Create provider directory if needed: `implementations/[provider-name]/`
2. Implement lesson following specification
3. Include comprehensive tests
4. Add README explaining approach
5. Ensure tests pass: `go test ./...`

### Quality Standards
- All code must follow `go fmt` formatting
- Table-driven tests for multiple test cases
- Exported functions must have documentation comments
- Error handling must follow Go conventions
- Tests must achieve >80% code coverage

## License

This curriculum and all lesson specifications are part of the claude-go-containers project, available under the MIT License.

## Acknowledgments

This curriculum is based on research and best practices from:
- The official Go documentation and community
- Charm.sh ecosystem and community
- Gophercises by Jon Calhoun
- Exercism Go Track
- ByteSizeGo learning path
- Frontend Masters courses
- Go community best practices and conventions

---

**Last Updated**: 2025-11-11
**Total Lessons**: 42
**Estimated Completion Time**: 136-190 hours (intensive) or 8-12 weeks (part-time)
