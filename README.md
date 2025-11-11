# claude-go-containers

A comprehensive development environment for learning Go (Golang) with AI-powered coding assistants integrated in a Dev Container.

## Overview

This repository provides a complete setup for:
- **Latest Go (Golang) environment** - Using the official latest Go Docker image
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

The dev container will mount your `~/.anthropic` directory to persist authentication.

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
├── examples/
│   ├── hello.go             # Sample Go package
│   └── hello_test.go        # Sample tests
├── main.go                   # Entry point
├── go.mod                    # Go module definition
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

## Learning Go

This repository includes sample code to help you learn Go:

### Run the Main Program

```bash
go run main.go
```

### Run Tests

```bash
# Run all tests
go test ./...

# Run tests with verbose output
go test -v ./...

# Run tests with coverage
go test -cover ./...
```

### Format Code

```bash
# Format all Go files
go fmt ./...

# Or use gofmt directly
gofmt -w .
```

### Build the Project

```bash
# Build the executable
go build -o app

# Run the built executable
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

- **[OpenCode Setup Guide](docs/guides/OPENCODE_SETUP.md)** - Detailed guide for using OpenCode AI
- **[OpenCode Documentation](https://opencode.ai/docs)** - Official OpenCode documentation
- **[Go Documentation](https://golang.org/doc/)** - Official Go language documentation

## Contributing

Feel free to add more examples, improve documentation, or enhance the dev container setup!

## License

This project is open source and available under the MIT License.