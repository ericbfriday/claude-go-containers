# Architecture Documentation

## System Overview

This project is a containerized Go learning environment with integrated AI development tools, designed to provide an optimal experience for developers learning Go with AI assistance from Claude CLI and Crush AI.

### Design Principles

1. **Learning-First**: All code prioritizes clarity and education over complexity
2. **Best Practices**: Demonstrates idiomatic Go patterns and conventions
3. **AI-Augmented**: Integrates AI tools as first-class development companions
4. **Containerized**: Provides consistent, reproducible development environment
5. **Minimal Dependencies**: Uses standard library where possible

---

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Host Machine                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │            VS Code + Dev Containers              │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ Mounts: ~/.claude
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Dev Container (Debian-based)                │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Runtime Environment                            │   │
│  │  • Go 1.24.9 (latest)                          │   │
│  │  • Node.js (LTS) for Claude CLI                │   │
│  │  • Git, curl, build-essential                  │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │  AI Development Tools                           │   │
│  │  • Claude CLI (@anthropic-ai/claude-code)      │   │
│  │  • Crush AI (Charmbracelet)                    │   │
│  │    - Interactive TUI for coding sessions       │   │
│  │    - LSP integration with gopls                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Go Development Tools                           │   │
│  │  • gopls (Language Server)                     │   │
│  │  • delve (Debugger)                            │   │
│  │  • staticcheck (Linter)                        │   │
│  │  • goimports (Import Formatter)                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Project Structure                              │   │
│  │  /workspace/                                    │   │
│  │  ├── main.go          (Entry point)            │   │
│  │  ├── examples/        (Learning package)       │   │
│  │  ├── go.mod           (Module definition)      │   │
│  │  ├── Makefile         (Build automation)       │   │
│  │  ├── docs/            (Documentation)          │   │
│  │  └── .devcontainer/   (Container config)       │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### 1. Container Layer

**Technology**: Docker + VS Code Dev Containers

**Responsibilities**:
- Provide consistent Go runtime environment
- Isolate development environment from host
- Manage tool installations and configurations
- Mount host authentication (Claude CLI credentials)

**Key Files**:
- `.devcontainer/Dockerfile` - Container image definition
- `.devcontainer/devcontainer.json` - VS Code integration config

**Key Design Decisions**:
- Uses `golang:latest` base image for up-to-date Go features
- Non-root user (`vscode`) for security
- Volume mount for `~/.claude` to persist authentication
- Installs both Claude CLI and Crush AI for comprehensive AI assistance

### 2. Application Layer

**Structure**: Simple monolithic application (currently)

```
main.go              ← Entry point
├── imports: fmt
└── outputs: Environment information

examples/
├── hello.go         ← Learning examples
│   ├── Greet()     ← String manipulation example
│   └── Add()       ← Basic arithmetic example
└── hello_test.go    ← Table-driven tests
    ├── TestGreet()
    └── TestAdd()
```

**Design Patterns**:
- **Table-Driven Testing**: All tests follow this pattern (see examples/hello_test.go)
- **Exported Functions**: PascalCase (Greet, Add)
- **Package Organization**: Separate packages in subdirectories
- **Zero External Dependencies**: Uses only standard library

**Scalability Path**:
```
Current:           Future Growth Path:
main.go       →    cmd/
examples/     →        app1/main.go
                       app2/main.go
                   internal/
                       auth/
                       database/
                       handlers/
                   pkg/
                       utils/
                       models/
```

### 3. AI Tools Layer

**Claude CLI**:
- **Purpose**: Quick one-off questions and code reviews
- **Interface**: Command-line (`claude "question"`)
- **Use Cases**: Syntax help, concept explanation, code review
- **Integration**: npm package, authenticated via `~/.claude`

**Crush AI**:
- **Purpose**: Interactive coding sessions and debugging
- **Interface**: Terminal UI (`crush`)
- **Use Cases**: Architectural discussions, complex debugging, learning sessions
- **Integration**: Standalone binary + npm package
- **Features**: LSP integration with gopls for Go-specific assistance

**AI Tool Selection Matrix**:
```
Task Type              │ Tool Choice  │ Reason
──────────────────────┼──────────────┼─────────────────────────
Quick syntax question  │ Claude CLI   │ Fast, non-interactive
Explain concept        │ Claude CLI   │ Simple output, piping
Multi-step debugging   │ Crush        │ Interactive, LSP context
Code review           │ Claude CLI   │ Pipe file, get feedback
Architecture design   │ Crush        │ Back-and-forth discussion
Write tests           │ Either       │ Depends on complexity
```

### 4. Build and Development Layer

**Make-based Build System**:

```
Makefile
├── build          → Compiles to ./app executable
├── run            → Executes main.go
├── test           → Runs all tests with verbose output
├── test-coverage  → Generates coverage reports
├── fmt            → Formats all Go code
├── lint           → Runs staticcheck linter
├── clean          → Removes build artifacts
└── install-tools  → Installs/updates Go tools
```

**Go Module System**:
- Module path: `github.com/ericbfriday/claude-go-containers`
- Go version: 1.24.9 (latest)
- No external dependencies (standard library only)

---

## Data Flow

### Development Workflow

```
Developer
    │
    ├─ VS Code ────────────► Dev Container
    │                           │
    │                           ├─ Go Tools (gopls, delve)
    │                           ├─ Claude CLI (quick help)
    │                           └─ Crush AI (interactive)
    │
    ├─ Write Code ──────────► examples/*.go
    │
    ├─ Write Tests ─────────► examples/*_test.go
    │
    ├─ Run `make test` ─────► go test ./...
    │                           │
    │                           └─ Table-driven tests execute
    │
    ├─ Run `make fmt` ──────► go fmt ./...
    │
    ├─ Run `make lint` ─────► staticcheck ./...
    │
    └─ Run `make build` ────► go build -o app
                                   │
                                   └─ ./app (executable)
```

### AI-Assisted Development Flow

```
Developer Question
    │
    ├─ Simple/Quick? ──YES──► claude "question"
    │                             │
    │                             └─ Answer displayed
    │
    └─ Complex/Interactive? ──YES──► crush
                                      │
                                      ├─ LSP provides context
                                      ├─ Interactive discussion
                                      └─ Multi-step guidance
```

---

## Testing Architecture

### Table-Driven Test Pattern

All tests follow Go's idiomatic table-driven pattern:

```go
func TestFunction(t *testing.T) {
    // 1. Define test cases as struct slice
    tests := []struct {
        name     string      // Descriptive test name
        input    InputType   // Function input
        expected OutputType  // Expected output
    }{
        {"case 1", input1, expected1},
        {"case 2", input2, expected2},
    }

    // 2. Iterate with subtests
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // 3. Execute and verify
            result := Function(tt.input)
            if result != tt.expected {
                t.Errorf("got %v, want %v", result, tt.expected)
            }
        })
    }
}
```

**Benefits**:
- Easy to add new test cases (just append to slice)
- Clear structure and documentation
- Subtests can run individually: `go test -run TestGreet/empty_name`
- Parallel execution possible with `t.Parallel()`

### Test Organization

```
Package Testing Strategy:
examples/
├── hello.go          ← Implementation
└── hello_test.go     ← Same package (can test unexported)

Future Pattern:
pkg/
├── auth/
│   ├── auth.go       ← Implementation
│   ├── auth_test.go  ← Internal tests (same package)
│   └── auth_external_test.go  ← External tests (package auth_test)
```

---

## Configuration Management

### Environment Configuration

**Container Configuration** (`.devcontainer/devcontainer.json`):
- VS Code extensions (Go, Makefile tools)
- Go settings (language server, linting, formatting)
- Volume mounts (Claude authentication)
- Post-create commands (verify installations)

**Project Configuration** (`.claude.json`):
- Project metadata for Claude Code
- Language and framework detection
- File inclusion/exclusion patterns
- Context instructions for AI assistance

**Go Module Configuration** (`go.mod`):
- Module path declaration
- Go version requirement
- Dependency management (currently none)

---

## Security Considerations

### Container Security
- **Non-root user**: All operations run as `vscode` user
- **Minimal surface**: Only necessary tools installed
- **Host isolation**: Container provides security boundary

### Authentication
- **Claude CLI**: Credentials mounted read-only from host `~/.claude`
- **No embedded secrets**: Environment-based configuration
- **Git ignore**: `.gitignore` prevents credential commits

### Code Security (Future Growth)
- **Input validation**: Always validate user input
- **SQL injection prevention**: Use parameterized queries/sqlc
- **Dependency scanning**: `go list -m -u all` for updates
- **Vulnerability checking**: Use `govulncheck` in CI/CD

---

## Scalability and Growth

### Current Limitations
- **Single binary**: All code in one executable
- **No database**: No persistence layer
- **No HTTP server**: CLI-only application
- **No external dependencies**: Limited to stdlib

### Growth Path

**Phase 1** (Current): Learning basics
- Simple examples and tests
- Standard library only
- CLI application

**Phase 2**: HTTP Application
```go
// Add web server
cmd/server/main.go
internal/handlers/
internal/middleware/
```

**Phase 3**: Data Persistence
```go
// Add database layer
internal/database/
    ├── queries/      (sqlc SQL files)
    ├── models/       (Generated code)
    └── migrations/   (Database schema)
```

**Phase 4**: Microservices
```go
// Multiple services
cmd/
    ├── api-service/
    ├── worker-service/
    └── admin-service/
```

### Recommended Patterns for Growth

When adding complexity:
1. **Start simple**: Don't add structure until needed
2. **Use `internal/`**: Keep implementation details private
3. **Prefer fewer packages**: Combine related functionality
4. **Follow stdlib**: Study standard library organization
5. **Document decisions**: Update this architecture doc

---

## Monitoring and Observability (Future)

When application grows, add:

**Structured Logging**:
```go
import "log/slog"  // Go 1.21+ standard library

logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
logger.Info("request processed",
    "path", r.URL.Path,
    "duration_ms", duration.Milliseconds(),
)
```

**Metrics** (Prometheus pattern):
```go
import "github.com/prometheus/client_golang/prometheus"

// Expose /metrics endpoint
http.Handle("/metrics", promhttp.Handler())
```

**Tracing** (OpenTelemetry):
```go
import "go.opentelemetry.io/otel"

// Add tracing spans for request tracking
```

---

## References

### Internal Documentation
- [CLAUDE.md](../CLAUDE.md) - AI assistant guidance
- [API_REFERENCE.md](API_REFERENCE.md) - Function documentation
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Development workflows
- [README.md](../README.md) - Project overview
- [QUICKSTART.md](../QUICKSTART.md) - Getting started guide

### External Resources
- [Go in 2025 Guide](guides/go-in-2025-guide.md) - Comprehensive Go ecosystem overview
- [Effective Go](https://go.dev/doc/effective_go) - Official Go practices
- [Go Standard Project Layout](https://github.com/golang-standards/project-layout)
- [Charm.sh Documentation](https://charm.sh) - TUI development (future)

### Architecture Decisions Log

**Decision 1**: Use table-driven tests exclusively
- **Rationale**: Go community standard, easy to extend, clear structure
- **Date**: Project inception
- **Status**: Active

**Decision 2**: No external dependencies initially
- **Rationale**: Focus on standard library learning
- **Date**: Project inception
- **Status**: Active, will evolve as needed

**Decision 3**: AI tools as first-class citizens
- **Rationale**: Learning-focused project benefits from AI assistance
- **Date**: Project inception
- **Status**: Active

**Decision 4**: Dev Container environment
- **Rationale**: Consistent cross-platform development experience
- **Date**: Project inception
- **Status**: Active
