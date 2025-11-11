# Documentation Index

Complete documentation index for the claude-go-containers project.

---

## 📚 Documentation Overview

This project provides comprehensive documentation organized by audience and purpose:

- **Getting Started** → Quick setup and first steps
- **Learning Resources** → Go language and ecosystem guides
- **API Documentation** → Function and package references
- **Architecture** → System design and technical decisions
- **Development** → Daily workflows and best practices
- **Contributing** → How to contribute to the project

---

## 🚀 Quick Start (5 minutes)

**New to this project?** Start here:

1. [README.md](../README.md) - Project overview and setup
2. [QUICKSTART.md](../QUICKSTART.md) - Get running in 5 minutes
3. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Start developing

---

## 📖 Documentation by Role

### For Learners

Start your Go learning journey:

1. **[QUICKSTART.md](../QUICKSTART.md)** - First steps with Go
   - Run your first program
   - Basic Go concepts (variables, functions, loops)
   - Common tasks (create packages, add dependencies)
   - When to use Claude CLI vs Crush AI

2. **[go-in-2025-guide.md](guides/go-in-2025-guide.md)** - Comprehensive ecosystem guide
   - Modern Go development patterns (16K+ words)
   - Common pitfalls and how to avoid them
   - Charm.sh TUI ecosystem (Bubble Tea, Lip Gloss)
   - Frameworks, libraries, and tooling landscape
   - Performance optimization techniques

3. **[API_REFERENCE.md](API_REFERENCE.md)** - Function documentation
   - `examples` package functions (Greet, Add)
   - Usage examples and patterns
   - Testing patterns and best practices

### For Developers

Build features and maintain code:

1. **[CLAUDE.md](../CLAUDE.md)** - AI assistant guidance
   - Development commands (build, test, lint)
   - Architecture overview
   - Go development conventions
   - Common tasks for AI assistance

2. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Complete development guide
   - Development environment setup
   - Daily workflow (write → test → review → commit)
   - Code writing guidelines (naming, documentation, errors)
   - Testing strategy (table-driven tests)
   - AI-assisted development (Claude CLI + Crush)
   - Debugging techniques
   - Performance optimization
   - Troubleshooting

3. **[API_REFERENCE.md](API_REFERENCE.md)** - Function reference
   - Complete API documentation
   - Usage examples
   - Error handling patterns
   - Concurrency patterns

### For Contributors

Contribute to the project:

1. **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Contribution guidelines
   - Development workflow
   - Testing requirements
   - Code style guidelines
   - Adding examples
   - Using AI tools for development

2. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Technical details
   - Code organization
   - Testing patterns
   - Review process

### For Architects

Understand system design:

1. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
   - System overview and design principles
   - Component architecture (container, application, AI tools, build)
   - Data flow and workflows
   - Testing architecture (table-driven pattern)
   - Configuration management
   - Security considerations
   - Scalability and growth path
   - Architecture decision log

2. **[go-in-2025-guide.md](guides/go-in-2025-guide.md)** - Ecosystem patterns
   - Framework selection (Gin, Fiber, Echo, Chi)
   - Database libraries (GORM, sqlc, Ent)
   - Testing practices (testify, Ginkgo)
   - Build tools and CI/CD
   - Observability (Prometheus, OpenTelemetry)

---

## 📋 Documentation by Topic

### Setup and Installation

- [README.md](../README.md) - Prerequisites and initial setup
- [QUICKSTART.md](../QUICKSTART.md) - Quick environment verification
- [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md) - AI tools setup (OpenCode, Claude CLI)

### Go Language Basics

- [QUICKSTART.md](../QUICKSTART.md) - Variables, functions, loops, slices
- [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Modern Go patterns and best practices
- [API_REFERENCE.md](API_REFERENCE.md) - Example implementations

### Development Workflow

- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Complete workflow guide
- [CLAUDE.md](../CLAUDE.md) - Quick command reference
- [Makefile](../Makefile) - Build automation commands

### Testing

- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-strategy) - Testing guide
- [API_REFERENCE.md](API_REFERENCE.md#testing-patterns) - Test patterns
- [examples/hello_test.go](../examples/hello_test.go) - Table-driven test examples
- [ARCHITECTURE.md](ARCHITECTURE.md#testing-architecture) - Testing philosophy

### AI-Powered Development

- [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md) - Detailed AI tools guide
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#ai-assisted-development) - AI workflow
- [QUICKSTART.md](../QUICKSTART.md#ai-powered-learning-tools) - Quick AI guide
- [README.md](../README.md#ai-powered-development-tools) - Tool overview

### Architecture and Design

- [ARCHITECTURE.md](ARCHITECTURE.md) - Complete architecture documentation
- [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Ecosystem patterns
- [CLAUDE.md](../CLAUDE.md#architecture-and-code-organization) - Code organization

### Performance

- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#performance-optimization) - Profiling and benchmarking
- [go-in-2025-guide.md](go-in-2025-guide.md#performance-optimization-in-go) - Optimization techniques

### Security

- [ARCHITECTURE.md](ARCHITECTURE.md#security-considerations) - Security design
- [go-in-2025-guide.md](go-in-2025-guide.md#security-practices) - Security patterns
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#troubleshooting) - Common security issues

### Ecosystem and Tools

- [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Complete ecosystem overview
  - Web frameworks (Gin, Fiber, Echo, Chi, Beego)
  - Databases (GORM, sqlc, Ent, Bun)
  - Testing (testify, Ginkgo, GoConvey)
  - Build tools (golangci-lint, staticcheck)
  - Observability (Prometheus, OpenTelemetry, Loki)
  - Charm.sh ecosystem (Bubble Tea, Lip Gloss, Bubbles, Gum)

---

## 🗂️ Complete File Reference

### Root Documentation

| File | Purpose | Audience |
|------|---------|----------|
| [README.md](../README.md) | Project overview and setup | Everyone |
| [QUICKSTART.md](../QUICKSTART.md) | Quick start guide | Learners |
| [CLAUDE.md](../CLAUDE.md) | AI assistant guidance | Developers |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guidelines | Contributors |
| [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md) | AI tools setup | Developers |
| [DOCUMENTATION_UPDATES.md](meta/DOCUMENTATION_UPDATES.md) | Documentation changelog | Maintainers |

### docs/ Directory

| File | Purpose | Audience |
|------|---------|----------|
| [INDEX.md](INDEX.md) | This file - navigation hub | Everyone |
| [API_REFERENCE.md](API_REFERENCE.md) | Function documentation | Developers |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture | Architects, Developers |
| [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | Development workflows | Developers |
| [go-in-2025-guide.md](guides/go-in-2025-guide.md) | Go ecosystem guide | All Developers |

### Code Files

| File/Directory | Purpose | Reference |
|----------------|---------|-----------|
| [main.go](../main.go) | Application entry point | [API_REFERENCE.md](API_REFERENCE.md#package-main) |
| [examples/](../examples/) | Learning code package | [API_REFERENCE.md](API_REFERENCE.md#package-examples) |
| [examples/hello.go](../examples/hello.go) | Example functions | [API_REFERENCE.md](API_REFERENCE.md#functions) |
| [examples/hello_test.go](../examples/hello_test.go) | Table-driven tests | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-strategy) |

### Configuration Files

| File | Purpose | Reference |
|------|---------|-----------|
| [go.mod](../go.mod) | Go module definition | [ARCHITECTURE.md](ARCHITECTURE.md#go-module-system) |
| [Makefile](../Makefile) | Build automation | [CLAUDE.md](../CLAUDE.md#development-commands) |
| [.claude.json](../.claude.json) | Claude Code config | [ARCHITECTURE.md](ARCHITECTURE.md#configuration-management) |
| [.devcontainer/](../.devcontainer/) | Container setup | [ARCHITECTURE.md](ARCHITECTURE.md#container-layer) |

---

## 🔍 Find Documentation by Task

### "I want to..."

**...get started quickly**
→ [QUICKSTART.md](../QUICKSTART.md)

**...understand the project structure**
→ [ARCHITECTURE.md](ARCHITECTURE.md#system-architecture)

**...write my first Go function**
→ [QUICKSTART.md](../QUICKSTART.md#basic-go-concepts)
→ [examples/hello.go](../examples/hello.go)

**...write tests**
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-strategy)
→ [examples/hello_test.go](../examples/hello_test.go)

**...use Claude CLI or Crush AI**
→ [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md)
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#ai-assisted-development)

**...learn Go best practices**
→ [go-in-2025-guide.md](guides/go-in-2025-guide.md)
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#code-writing-guidelines)

**...debug my code**
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#debugging-techniques)

**...optimize performance**
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#performance-optimization)
→ [go-in-2025-guide.md](go-in-2025-guide.md#performance-optimization)

**...contribute to the project**
→ [CONTRIBUTING.md](../CONTRIBUTING.md)

**...understand design decisions**
→ [ARCHITECTURE.md](ARCHITECTURE.md#architecture-decisions-log)

**...add a new package**
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#file-organization)

**...handle errors properly**
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#error-handling-patterns)
→ [API_REFERENCE.md](API_REFERENCE.md#error-handling-patterns)

**...deploy or build**
→ [CLAUDE.md](../CLAUDE.md#development-commands)
→ [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#daily-development-workflow)

**...understand concurrency**
→ [go-in-2025-guide.md](go-in-2025-guide.md#concurrency-patterns)
→ [API_REFERENCE.md](API_REFERENCE.md#concurrency-patterns)

**...choose a web framework**
→ [go-in-2025-guide.md](go-in-2025-guide.md#web-framework-selection)

**...build a TUI application**
→ [go-in-2025-guide.md](go-in-2025-guide.md#charmsh-ecosystem)

---

## 📊 Documentation Statistics

- **Total Documentation Files**: 11
- **Total Documentation Size**: ~45,000+ words
- **Coverage Areas**: Setup, Learning, Development, Architecture, Ecosystem
- **Code Examples**: 100+ across all documentation
- **External References**: 50+ to official Go resources

---

## 🔗 Cross-Reference Map

### Concepts and Their Locations

**Table-Driven Tests**:
- Example: [examples/hello_test.go](../examples/hello_test.go)
- Guide: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#table-driven-tests-required-pattern)
- Pattern: [API_REFERENCE.md](API_REFERENCE.md#table-driven-test-example-structure)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#testing-architecture)

**AI Tools (Claude CLI + Crush)**:
- Setup: [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md)
- Usage: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#ai-assisted-development)
- Quick Reference: [QUICKSTART.md](../QUICKSTART.md#ai-powered-learning-tools)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#ai-tools-layer)

**Error Handling**:
- Patterns: [API_REFERENCE.md](API_REFERENCE.md#error-handling-patterns)
- Guidelines: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#error-handling-patterns)
- Best Practices: [go-in-2025-guide.md](go-in-2025-guide.md#error-handling)

**Go Module System**:
- File: [go.mod](../go.mod)
- Guide: [ARCHITECTURE.md](ARCHITECTURE.md#go-module-configuration)
- Usage: [CLAUDE.md](../CLAUDE.md#go-development-conventions)

**Dev Container**:
- Setup: [README.md](../README.md#getting-started)
- Config: [.devcontainer/](../.devcontainer/)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#container-layer)

---

## 📚 External Resources

### Official Go Documentation
- [Go Official Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Tour](https://go.dev/tour/)
- [Go by Example](https://gobyexample.com/)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)

### Tools Documentation
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [Crush AI (Charmbracelet)](https://github.com/charmbracelet/crush)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

### Learning Resources
- [Go FAQ](https://go.dev/doc/faq)
- [Go Playground](https://go.dev/play/)
- [Go Blog](https://go.dev/blog/)

---

## 🎯 Recommended Reading Paths

### Path 1: Complete Beginner

1. [README.md](../README.md) - Understand the project
2. [QUICKSTART.md](../QUICKSTART.md) - Run first program
3. [OPENCODE_SETUP.md](guides/OPENCODE_SETUP.md) - Learn AI tools
4. [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Learn Go ecosystem
5. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Daily workflows

### Path 2: Experienced Developer (New to Go)

1. [CLAUDE.md](../CLAUDE.md) - Quick command reference
2. [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Modern Go patterns
3. [ARCHITECTURE.md](ARCHITECTURE.md) - System design
4. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Workflows
5. [API_REFERENCE.md](API_REFERENCE.md) - Code patterns

### Path 3: Go Developer (New to Project)

1. [CLAUDE.md](../CLAUDE.md) - AI assistant setup
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Project architecture
3. [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution process
4. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Project workflows

### Path 4: Quick Reference User

1. [CLAUDE.md](../CLAUDE.md) - Command cheat sheet
2. [API_REFERENCE.md](API_REFERENCE.md) - Function reference
3. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#quick-reference-commands) - Command reference

---

## 🔄 Documentation Maintenance

### Keeping Documentation Updated

When making changes:

1. **Code Changes** → Update [API_REFERENCE.md](API_REFERENCE.md)
2. **Architecture Changes** → Update [ARCHITECTURE.md](ARCHITECTURE.md)
3. **Workflow Changes** → Update [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
4. **New Features** → Update [README.md](../README.md)
5. **New Examples** → Update [QUICKSTART.md](../QUICKSTART.md)

### Documentation Quality Standards

- ✅ Clear, concise language
- ✅ Code examples for all concepts
- ✅ Cross-references to related sections
- ✅ Table of contents for long documents
- ✅ Consistent formatting and structure
- ✅ Regular updates with code changes

---

## 💬 Getting Help

**Can't find what you need?**

1. **Search this index** for relevant topics
2. **Use AI tools**:
   ```bash
   claude "How do I [task]?"
   crush  # Interactive help session
   ```
3. **Check [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#troubleshooting)** for common issues
4. **Review [go-in-2025-guide.md](guides/go-in-2025-guide.md)** for ecosystem guidance

---

## 📝 Document Version Information

**Last Updated**: 2025-11-11
**Documentation Version**: 1.0
**Project Version**: Based on main branch
**Go Version**: 1.24.9

---

**Need to add new documentation?** See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
