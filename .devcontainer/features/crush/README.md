# Crush AI Feature (Optional)

This is an optional dev container feature that installs Crush AI - Charmbracelet's terminal-based AI assistant.

## What is Crush?

Crush is a powerful terminal-based AI assistant for developers that provides:
- Interactive terminal UI with AI chat
- LSP integration (works with Go language server)
- Multi-session support
- Privacy-first (no code stored externally)
- Support for 75+ AI providers
- Code analysis and debugging assistance

## Enabling Crush

To enable Crush in your dev container:

1. Edit `.devcontainer/devcontainer.json`
2. Uncomment the Crush feature:

```json
{
  "features": {
    "./features/crush": {
      "version": "latest"
    }
  }
}
```

3. Rebuild the container:
   - VS Code Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
   - Select: "Dev Containers: Rebuild Container"

## Usage

Once enabled, use Crush with:

```bash
# Start interactive AI session
crush

# Run with debug logging
crush -d

# Execute a single prompt
crush run "Explain this Go code structure"

# Get help
crush --help
```

## Configuration

Crush looks for configuration in:
- `$HOME/.crush.json`
- `$XDG_CONFIG_HOME/crush/.crush.json`
- `./.crush.json` (local directory)

## Why Optional?

Crush is made optional because:
1. **Not everyone needs it**: The devcontainer already includes OpenCode AI and Claude CLI
2. **Flexibility**: Users can choose their preferred AI assistant
3. **Build time**: Optional features reduce default container build time
4. **Resource usage**: Keeps the default container lean

## When to Use Crush vs OpenCode

- **OpenCode**: Best for AI-powered coding workflows, context-aware assistance
- **Crush**: Best for interactive terminal sessions, exploratory coding

Both tools complement each other and can be used together if desired.

## Links

- [Crush GitHub Repository](https://github.com/charmbracelet/crush)
- [Charmbracelet](https://charm.sh)
