# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Go learning environment with integrated AI development tools, designed for developers learning Go with assistance from Claude CLI and Crush AI. The project is containerized using VS Code Dev Containers with Go latest, Claude CLI, and Crush AI pre-installed.

## Development Commands

### Building and Running
```bash
# Build the application
make build          # Creates ./app executable
go build -o app .   # Alternative without make

# Run the application
make run            # Runs main.go
go run main.go      # Alternative

# Run built executable
./app
```

### Testing
```bash
# Run all tests
make test           # Runs with verbose output
go test ./...       # Standard test run
go test -v ./...    # Verbose output

# Test coverage
make test-coverage  # Creates coverage.out and coverage.html
go test -cover ./...           # Simple coverage percentage
go test -coverprofile=coverage.out ./...  # Detailed coverage

# Run specific package tests
go test -v ./examples

# Run specific test function
go test -v -run TestGreet ./examples
```

### Code Quality
```bash
# Format code (always run before committing)
make fmt            # Formats all Go files
go fmt ./...        # Alternative

# Run linter (requires staticcheck)
make lint
staticcheck ./...

# Install/update Go tools
make install-tools  # Installs gopls, delve, staticcheck, goimports
```

### Cleanup
```bash
make clean          # Removes app, coverage.out, coverage.html
```

## Architecture and Code Organization

### Project Structure
- **main.go**: Entry point - simple hello world demonstrating the environment
- **examples/**: Learning package with sample functions and table-driven tests
  - `hello.go`: Example functions (Greet, Add) following Go conventions
  - `hello_test.go`: Table-driven test examples following Go testing patterns
- **Makefile**: Development task automation
- **.devcontainer/**: Dev container configuration with Go, Claude CLI, and Crush AI
- **docs/**: Additional documentation (Go guides, learning resources)

### Go Module Configuration
- Module path: `github.com/ericbfriday/claude-go-containers`
- Go version: 1.24.9 (latest)
- Currently no external dependencies - uses only standard library

### Code Patterns
- **Testing**: Uses table-driven tests pattern (see examples/hello_test.go)
- **Package structure**: Separate packages in subdirectories (e.g., examples/)
- **Naming**: Exported functions use PascalCase, unexported use camelCase
- **Error handling**: Follow Go conventions (not demonstrated yet in simple examples)

## AI Development Tools Integration

### Claude CLI vs Crush AI
- **Claude CLI**: Quick one-off questions, code reviews, generating snippets
  - Example: `claude "Explain goroutines in Go"`
- **Crush AI**: Interactive sessions, debugging, architectural discussions
  - Example: `crush` for interactive terminal UI
  - LSP integration with Go language server

### Environment Configuration
- Claude CLI authentication mounted from host: `~/.claude` → `/home/vscode/.claude`
- Both tools are pre-installed and verified in postCreateCommand
- See docs/guides/OPENCODE_SETUP.md for detailed usage instructions

## Go Development Conventions

### When Adding New Code
1. Create packages in subdirectories (not in root)
2. Add corresponding `*_test.go` files
3. Use table-driven tests for multiple test cases
4. Export only necessary functions (PascalCase for exported)
5. Run `make fmt` before committing
6. Ensure `make test` passes

### Test-Driven Development Workflow
1. Write tests first in `*_test.go` files
2. Use table-driven test structure (see examples/hello_test.go)
3. Run `go test -v ./...` to verify
4. Implement functionality to make tests pass
5. Run `make test-coverage` to check coverage

### Adding Dependencies
```bash
go get github.com/package/name  # Add dependency
go mod tidy                     # Clean up go.mod and go.sum
```

## Important Notes

- **Go Version**: Uses latest Go (currently 1.24.9) - features from all Go versions available
- **Container Environment**: All development happens inside VS Code Dev Container
- **Authentication**: Claude CLI auth persisted via volume mount from host
- **Testing Pattern**: Strongly prefer table-driven tests (see examples)
- **Formatting**: Always run `go fmt ./...` or `make fmt` before committing
- **Learning Focus**: This is a learning environment - prioritize clarity and education over complexity

## Common Tasks for AI Assistance

### Code Generation
- Create new packages following `examples/` pattern
- Write table-driven tests for new functions
- Add Go best practices (error handling, documentation)

### Code Review Focus
- Go idioms and conventions
- Table-driven test patterns
- Proper error handling
- Exported vs unexported naming
- Documentation comments for exported items

### Debugging
- Use `go test -v` for verbose test output
- Check `go build` errors for compilation issues
- Use delve debugger (pre-installed): `dlv debug`
