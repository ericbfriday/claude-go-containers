# OpenCode AI Coding Agent Setup

This devcontainer includes support for **OpenCode** by SST - The AI coding agent built for the terminal.

## What's Included

### OpenCode - AI Coding Agent by SST
- **Package**: `opencode-ai` (npm)
- **Version**: Latest (installed globally)
- **Website**: https://opencode.ai
- **Description**: A powerful AI coding agent for developers that provides intelligent code assistance, analysis, and generation directly in your terminal

### Original OpenCode Project Note
- The original OpenCode project (opencode.ai) is now developed by SST
- **Recommendation**: This is the actively maintained OpenCode from SST

## Usage

### Starting OpenCode

```bash
# Interactive mode
opencode

# Run with specific file
opencode myfile.go

# Get help
opencode --help

# Check version
opencode --version
```

### Features Available in the Devcontainer

- **Terminal-native**: Fast, responsive interface built for the command line
- **LSP Integration**: Automatically works with Go LSP (gopls) for intelligent code understanding
- **Context-aware**: Understands your project structure and dependencies
- **Multi-model support**: Works with various AI providers
- **Privacy-focused**: Configurable to work with local or cloud models

### Integration with Existing Tools

The devcontainer includes:
- **Go tools**: gopls, delve, staticcheck, goimports
- **Claude CLI**: For Anthropic Claude integration
- **OpenCode**: For AI-powered coding assistance
- **Node.js**: For npm-based tools and dependencies

## Configuration

OpenCode can be configured through:
- Command-line arguments
- Environment variables
- Configuration files (see OpenCode documentation)

For detailed configuration options, visit: https://opencode.ai/docs

## Getting Started

1. Start the devcontainer
2. Open a terminal
3. Run `opencode` to start the AI coding assistant
4. Configure your preferred AI provider when prompted (if needed)

## Optional: Crush AI (Charmbracelet)

If you prefer Crush AI (the Charmbracelet terminal assistant), you can enable it as an optional feature:

1. Edit `.devcontainer/devcontainer.json`
2. Uncomment the Crush feature:
   ```json
   "features": {
     "./features/crush": {
       "version": "latest"
     }
   }
   ```
3. Rebuild the container

### Using Crush (if enabled)

```bash
# Interactive mode
crush

# Run with debug logging
crush -d

# Run a single prompt
crush run "Explain this code"

# Get help
crush --help
```

## AI Tool Comparison

| Feature | OpenCode (SST) | Crush (Charmbracelet) | Claude CLI |
|---------|----------------|------------------------|------------|
| **Installation** | Default | Optional | Default |
| **Primary Use** | AI coding agent | Terminal AI assistant | Quick AI queries |
| **Interface** | Terminal | TUI (Terminal UI) | Command-line |
| **LSP Integration** | Yes | Yes | No |
| **Best For** | Coding workflows | Interactive sessions | Quick questions |

## Links

- [OpenCode Documentation](https://opencode.ai/docs)
- [OpenCode GitHub](https://github.com/sst/opencode)
- [SST Official Site](https://sst.dev)
- [Crush GitHub (Optional)](https://github.com/charmbracelet/crush)
