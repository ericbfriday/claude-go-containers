# claude-go-containers

A comprehensive development environment for learning Go (Golang) with AI-powered coding assistants integrated in a Dev Container.

## Overview

This repository provides a complete setup for:
- **Latest Go (Golang) environment** - Using the official latest Go Docker image
- **Comprehensive Learning Curriculum** - 42 progressive lessons from Go fundamentals to advanced TUI development
- **AI Provider Competition System** - Multiple AI assistants create implementations for comparison
- **Claude CLI** - Anthropic's Claude Code CLI for AI-assisted development
- **OpenCode AI** - SST's AI coding agent built for the terminal
- **VS Code Dev Container** - Containerized development environment with all tools pre-installed
- **Optional Crush AI** - Charmbracelet's terminal AI assistant (can be enabled via feature flag)

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed and running
- [Visual Studio Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Anthropic API Key](https://console.anthropic.com/) for Claude CLI

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ericbfriday/claude-go-containers.git
cd claude-go-containers
```

### 2. Set Up Claude CLI

Before opening in the dev container, make sure you have Claude CLI configured on your host machine:

```bash
# Install Claude CLI (if not already installed)
npm install -g @anthropic-ai/claude-code

# Authenticate with your Anthropic API key
claude auth
```

The dev container will mount your `~/.claude` directory to persist authentication.

### 3. Open in Dev Container

1. Open VS Code
2. Open this folder in VS Code
3. When prompted, click "Reopen in Container" (or use Command Palette: `Dev Containers: Reopen in Container`)
4. Wait for the container to build (first time may take a few minutes)

### 4. Verify the Setup

Once the container is running, open a terminal in VS Code and verify:

```bash
# Check Go version
go version

# Check Claude CLI
claude --version

# Check OpenCode AI
opencode --version

# Run the sample program
go run main.go

# Run tests
go test ./...
```

## Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json    # Dev container configuration
│   └── Dockerfile            # Container image with Go + Claude CLI
├── docs/
│   └── guides/
│       ├── go-learning-plan.md      # Comprehensive learning progression
│       ├── go-in-2025-guide.md      # Modern Go ecosystem guide
│       └── OPENCODE_SETUP.md        # AI tools setup
├── lessons/                          # NEW: Learning curriculum
│   ├── README.md                     # Curriculum overview
│   ├── LESSON_MANIFEST.md            # All 42 lessons detailed
│   ├── LESSON_TEMPLATE.md            # Template for new lessons
│   ├── AI_PROVIDER_GUIDE.md          # Multi-AI competition guide
│   ├── specifications/               # Lesson requirements
│   ├── implementations/              # AI-generated solutions
│   │   ├── claude/                   # Claude implementations
│   │   ├── opencode/                 # OpenCode implementations
│   │   ├── copilot/                  # GitHub Copilot implementations
│   │   ├── cursor/                   # Cursor AI implementations
│   │   └── reference/                # Human-reviewed exemplars
│   └── assessments/                  # Grading rubrics
├── examples/
│   ├── hello.go             # Sample Go package
│   └── hello_test.go        # Sample tests
├── main.go                   # Entry point
├── go.mod                    # Go module definition
├── CLAUDE.md                 # Claude Code guidance
└── README.md                 # This file
```

## AI-Powered Development Tools

### Claude CLI

Use Claude CLI for quick AI assistance:

```bash
# Ask Claude a question
claude "How do I implement a linked list in Go?"

# Get help with code
claude "Explain this function" < examples/hello.go

# Generate code
claude "Write a function to reverse a string in Go"
```

### OpenCode AI

Use OpenCode for AI-powered coding assistance:

```bash
# Start interactive coding session
opencode

# Work with specific file
opencode examples/hello.go

# Get help
opencode --help
```

**OpenCode Features:**
- Terminal-native AI coding agent
- LSP integration (works with Go language server)
- Context-aware code understanding
- Multi-model AI support
- Privacy-focused configuration
- Built for developer workflows

### Optional: Crush AI Agent

Crush can be enabled as an optional feature by uncommenting it in `.devcontainer/devcontainer.json`:

```json
"features": {
  "./features/crush": {
    "version": "latest"
  }
}
```

Then rebuild the container to use Crush alongside OpenCode and Claude CLI.

## Learning Go with AI-Powered Curriculum

This repository features a **comprehensive 42-lesson curriculum** designed to take you from Go novice to proficient TUI developer in 2-4 weeks of intensive study (or 8-12 weeks part-time).

### Curriculum Overview

**Phase 1: Go Fundamentals** (Lessons 1-8)
- Master Go syntax, types, control flow, functions
- Learn structs, interfaces, error handling, packages
- **Milestone**: Quiz Game project

**Phase 2: CLI Development** (Lessons 9-14)
- Build command-line tools with standard library and Cobra
- Implement file I/O, JSON persistence, API integration
- **Milestone**: Full-featured Task Tracker CLI

**Phase 3: Styling with Lip Gloss** (Lessons 15-18)
- Add beautiful terminal styling before TUIs
- Colors, borders, layouts, themes
- **Milestone**: Styled CLI applications

**Phase 4: Concurrency** (Lessons 19-24)
- Master goroutines, channels, sync primitives
- Worker pools, pipelines, context
- **Milestone**: Concurrent Web Crawler

**Phase 5: Bubble Tea Architecture** (Lessons 25-30)
- Learn The Elm Architecture (Model-Update-View)
- Commands, messages, async I/O
- **Milestone**: Shopping List TUI

**Phase 6: Bubbles Components** (Lessons 31-36)
- Master pre-built components (textinput, list, table, viewport)
- Component composition patterns
- **Milestone**: Interactive Todo TUI

**Phase 7: Advanced TUI** (Lessons 37-42)
- Huh forms, state management, testing
- **Capstones**: Kanban Board, Git TUI Dashboard

### Getting Started with Lessons

```bash
# 1. Navigate to lessons directory
cd lessons

# 2. Read the curriculum overview
cat README.md

# 3. Review lesson manifest (all 42 lessons)
cat LESSON_MANIFEST.md

# 4. Start with Lesson 01 specification
cat specifications/lesson-01-hello-world.md

# 5. Attempt implementation yourself OR use AI
# AI Implementation Options:

# Option A: Claude CLI
claude "Implement this lesson specification" < specifications/lesson-01-hello-world.md

# Option B: OpenCode AI
opencode specifications/lesson-01-hello-world.md
# Then: "Implement following Go best practices"

# Option C: Compare multiple AI implementations
# See AI_PROVIDER_GUIDE.md for detailed workflow
```

### AI Provider Competition System

Each lesson can be implemented by multiple AI providers:
- **Claude Code** - Comprehensive, well-documented
- **OpenCode AI** - Terminal-native, LSP-integrated
- **GitHub Copilot** - Fast inline suggestions
- **Cursor AI** - Codebase-aware refactoring
- **Reference** - Human-reviewed exemplar solutions

Compare implementations to learn different approaches, trade-offs, and best practices.

### Quick Start Commands

```bash
# Run the Main Program
go run main.go

# Run Tests
go test ./...              # All tests
go test -v ./...           # Verbose
go test -cover ./...       # With coverage

# Format Code
go fmt ./...

# Build the Project
go build -o app
./app
```

## Useful Go Commands

- `go run <file.go>` - Compile and run a Go program
- `go build` - Compile packages and dependencies
- `go test` - Run tests
- `go fmt` - Format Go source code
- `go get <package>` - Add dependencies
- `go mod tidy` - Clean up dependencies
- `go doc <package>` - Show documentation

## Installed Tools

The dev container includes:

### Core Development Tools
- **Go** (latest version)
- **gopls** - Go language server
- **delve** - Go debugger
- **staticcheck** - Go linter
- **goimports** - Import formatter

### AI Coding Assistants
- **Claude CLI** (latest version) - Command-line AI assistance
- **OpenCode AI** (latest version) - SST's terminal AI coding agent
- **Crush** (optional feature) - Charmbracelet's terminal AI assistant
- **Node.js & npm** - For JavaScript/TypeScript AI tooling

## Tips

1. **Use AI Tools for Learning**:
   - Ask Claude quick questions via CLI
   - Use OpenCode for AI-powered coding workflows
   - Both tools can explain Go concepts, review code, and help debug issues

2. **Explore Examples**: Modify the code in the `examples/` directory to experiment

3. **Write Tests**: Practice test-driven development with Go's built-in testing framework

4. **Read Documentation**: Use `go doc` to explore Go's standard library

5. **AI-Assisted Development**:
   - Start `opencode` for AI-powered coding workflows
   - Use `claude` for quick one-off questions
   - Leverage LSP integration in OpenCode for contextual code assistance

## Additional Resources

### Learning Guides
- **[Go Learning Plan](docs/guides/go-learning-plan.md)** - Comprehensive 2-4 week learning progression
- **[Go in 2025 Guide](docs/guides/go-in-2025-guide.md)** - Modern ecosystem, best practices, and pitfalls
- **[OpenCode Setup Guide](docs/guides/OPENCODE_SETUP.md)** - AI tools configuration

### Curriculum Documentation
- **[Lessons README](lessons/README.md)** - Curriculum overview and structure
- **[Lesson Manifest](lessons/LESSON_MANIFEST.md)** - All 42 lessons detailed
- **[AI Provider Guide](lessons/AI_PROVIDER_GUIDE.md)** - Multi-AI competition system

### External Resources
- **[OpenCode Documentation](https://opencode.ai/docs)** - Official OpenCode documentation
- **[Go Documentation](https://golang.org/doc/)** - Official Go language documentation
- **[Tour of Go](https://go.dev/tour/)** - Interactive introduction
- **[Go by Example](https://gobyexample.com/)** - Hands-on examples
- **[Charm.sh](https://charm.sh/)** - TUI framework ecosystem

## Contributing

Feel free to add more examples, improve documentation, or enhance the dev container setup!

## License

This project is open source and available under the MIT License.