# Contributing to claude-go-containers

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Open in the dev container (see README.md)
4. Create a new branch for your changes

## Development Workflow

### Making Changes

1. Make your changes in a feature branch
2. Write or update tests as needed
3. Ensure all tests pass: `make test`
4. Format your code: `make fmt`
5. Run the linter: `make lint` (if staticcheck is available)

### Testing

- Write tests for new functionality
- Ensure existing tests still pass
- Aim for good test coverage
- Use table-driven tests (see `examples/hello_test.go` for examples)

### Code Style

- Follow standard Go conventions
- Use `go fmt` to format code
- Write clear, self-documenting code
- Add comments for exported functions and types
- Keep functions small and focused

## Adding Examples

When adding new examples:

1. Create a new file in the `examples/` directory
2. Include corresponding tests in a `*_test.go` file
3. Document the example in comments
4. Update README.md if the example demonstrates a new concept

## Using Claude CLI

You can use Claude CLI to help with development:

```bash
# Get help writing tests
claude "Write tests for this function" < examples/your_file.go

# Code review
claude "Review this code for best practices" < examples/your_file.go

# Explain concepts
claude "Explain how goroutines work in Go"
```

## Pull Requests

1. Ensure your PR has a clear description
2. Reference any related issues
3. Make sure all tests pass
4. Keep PRs focused on a single feature or fix
5. Update documentation as needed

## Questions?

Feel free to open an issue for questions or discussions!
