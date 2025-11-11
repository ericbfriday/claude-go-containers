# Lesson 09: Standard Library CLI with flag Package

**Phase**: 2 - CLI Development
**Difficulty**: Beginner
**Estimated Time**: 2-3 hours

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Parse command-line flags** using Go's built-in `flag` package
2. **Handle different flag types** (string, int, bool, duration) with appropriate defaults
3. **Access raw command-line arguments** using `os.Args` and understand when to use it
4. **Implement basic CLI patterns** with commands, options, and positional arguments
5. **Provide user-friendly help text** with flag descriptions and usage information
6. **Validate CLI input** and provide meaningful error messages
7. **Build practical CLI tools** following Unix philosophy principles

## Prerequisites

- **Required**: Completion of Lessons 01-08 (Phase 1 fundamentals)
- **Concepts**: Functions, error handling, file I/O basics
- **Tools**: Go 1.20+, terminal/command line familiarity
- **Setup**: Completed Quiz Game milestone project

## Core Concepts

### 1. The flag Package

Go's standard library includes the `flag` package for command-line argument parsing. It provides a simple, standardized interface for CLI applications:

```go
package main

import (
    "flag"
    "fmt"
)

func main() {
    // Define flags
    name := flag.String("name", "World", "name to greet")
    count := flag.Int("count", 1, "number of greetings")
    verbose := flag.Bool("verbose", false, "enable verbose output")

    // Parse command line
    flag.Parse()

    // Use flag values (note: these are pointers)
    for i := 0; i < *count; i++ {
        fmt.Printf("Hello, %s!\n", *name)
    }

    if *verbose {
        fmt.Printf("Greeted %s %d times\n", *name, *count)
    }
}
```

**Usage**:
```bash
$ go run main.go -name Alice -count 3 -verbose
Hello, Alice!
Hello, Alice!
Hello, Alice!
Greeted Alice 3 times
```

### 2. Flag Types and Definitions

The `flag` package supports multiple types with two definition styles:

```go
// Pointer style (most common)
var name = flag.String("name", "default", "description")
var count = flag.Int("count", 10, "description")
var enabled = flag.Bool("enabled", false, "description")
var timeout = flag.Duration("timeout", 5*time.Second, "description")

// Variable binding style
var name string
var count int
flag.StringVar(&name, "name", "default", "description")
flag.IntVar(&count, "count", 10, "description")

// Usage after flag.Parse()
fmt.Println(*name)  // Pointer style
fmt.Println(name)   // Variable style
```

**Available flag types**:
- `String`, `Int`, `Int64`, `Uint`, `Uint64`
- `Bool`, `Float64`
- `Duration` (parses "5s", "2m", "1h30m")

### 3. os.Args for Raw Arguments

Sometimes you need access to raw command-line arguments:

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    // os.Args[0] is the program name
    // os.Args[1:] are the arguments

    if len(os.Args) < 2 {
        fmt.Println("Usage: program <command> [args...]")
        os.Exit(1)
    }

    command := os.Args[1]
    args := os.Args[2:]

    fmt.Printf("Command: %s\n", command)
    fmt.Printf("Arguments: %v\n", args)
}
```

**When to use `os.Args`**:
- Implementing subcommands manually (before Cobra in Lesson 11)
- Parsing positional arguments
- Complex argument patterns not supported by `flag`

### 4. Combining Flags and Positional Arguments

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    verbose := flag.Bool("v", false, "verbose output")
    flag.Parse()

    // Non-flag arguments (positional)
    args := flag.Args()

    if len(args) == 0 {
        fmt.Println("Error: no files specified")
        os.Exit(1)
    }

    for _, filename := range args {
        if *verbose {
            fmt.Printf("Processing: %s\n", filename)
        }
        // Process file...
    }
}
```

**Usage**:
```bash
$ go run main.go -v file1.txt file2.txt file3.txt
Processing: file1.txt
Processing: file2.txt
Processing: file3.txt
```

### 5. Custom Help and Usage

Customize the help message for better UX:

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    // Custom usage function
    flag.Usage = func() {
        fmt.Fprintf(os.Stderr, "Usage: %s [OPTIONS] <file>...\n\n", os.Args[0])
        fmt.Fprintf(os.Stderr, "A tool for counting words in files.\n\n")
        fmt.Fprintf(os.Stderr, "Options:\n")
        flag.PrintDefaults()
        fmt.Fprintf(os.Stderr, "\nExamples:\n")
        fmt.Fprintf(os.Stderr, "  %s -lines file.txt\n", os.Args[0])
        fmt.Fprintf(os.Stderr, "  %s -words -chars *.txt\n", os.Args[0])
    }

    lines := flag.Bool("lines", false, "count lines")
    words := flag.Bool("words", false, "count words")
    chars := flag.Bool("chars", false, "count characters")

    flag.Parse()

    // If no flags set, default to counting all
    if !*lines && !*words && !*chars {
        *lines, *words, *chars = true, true, true
    }

    // Implementation...
}
```

### 6. Flag Validation and Error Handling

Always validate user input and provide helpful errors:

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    port := flag.Int("port", 8080, "server port")
    host := flag.String("host", "localhost", "server host")

    flag.Parse()

    // Validate port range
    if *port < 1 || *port > 65535 {
        fmt.Fprintf(os.Stderr, "Error: port must be between 1 and 65535, got %d\n", *port)
        os.Exit(1)
    }

    // Validate host is not empty
    if *host == "" {
        fmt.Fprintf(os.Stderr, "Error: host cannot be empty\n")
        os.Exit(1)
    }

    fmt.Printf("Starting server on %s:%d\n", *host, *port)
}
```

### 7. Unix Philosophy CLI Patterns

Good CLI tools follow Unix philosophy:

**Do one thing well**:
```go
// Good: focused tool
// wc - word count
// grep - pattern matching
// sort - sorting lines

// Bad: monolithic tool that tries to do everything
```

**Work with standard I/O**:
```go
package main

import (
    "bufio"
    "flag"
    "fmt"
    "io"
    "os"
)

func main() {
    flag.Parse()

    var reader io.Reader

    // Read from files or stdin
    if flag.NArg() > 0 {
        file, err := os.Open(flag.Arg(0))
        if err != nil {
            fmt.Fprintf(os.Stderr, "Error: %v\n", err)
            os.Exit(1)
        }
        defer file.Close()
        reader = file
    } else {
        reader = os.Stdin
    }

    // Process input
    scanner := bufio.NewScanner(reader)
    lineCount := 0
    for scanner.Scan() {
        lineCount++
    }

    fmt.Println(lineCount)
}
```

**Composable with pipes**:
```bash
$ cat file.txt | grep "error" | wc -l
$ find . -name "*.go" | xargs wc -l
```

## Challenge Description

Build three progressively complex CLI tools using the `flag` package and standard library, following Unix philosophy principles.

### Challenge 1: Word Count Tool (wc clone)

Create a `wc` (word count) clone that counts lines, words, and characters in files.

**Requirements**:
1. Accept flags: `-l` (lines), `-w` (words), `-c` (characters)
2. If no flags specified, count all three
3. Accept multiple files as arguments
4. Read from stdin if no files specified
5. Display totals when processing multiple files
6. Format output like Unix `wc`: `lines words chars filename`

**Example usage**:
```bash
$ go run wc.go -l file.txt
      42 file.txt

$ go run wc.go -w -c file.txt
     256    1543 file.txt

$ cat file.txt | go run wc.go
      42     256    1543
```

### Challenge 2: Grep-like Search Tool

Build a simple text search tool similar to `grep`.

**Requirements**:
1. Accept flags:
   - `-i`: Case-insensitive search
   - `-n`: Show line numbers
   - `-v`: Invert match (show non-matching lines)
   - `-c`: Count matches only
2. Accept pattern as first positional argument
3. Accept files as remaining arguments
4. Read from stdin if no files specified
5. Highlight matched pattern in output (optional: use color)

**Example usage**:
```bash
$ go run grep.go -n "error" logfile.txt
15: ERROR: connection failed
23: ERROR: timeout

$ go run grep.go -i -c "warning" *.log
file1.log: 5
file2.log: 12
```

### Challenge 3: Simple Calculator CLI

Create a calculator that performs operations via flags.

**Requirements**:
1. Accept flags:
   - `-op`: Operation (add, sub, mul, div, pow, sqrt)
   - `-a`: First operand (float64)
   - `-b`: Second operand (float64, not needed for sqrt)
   - `-precision`: Decimal places in output (default 2)
2. Validate inputs (check for required flags, division by zero)
3. Support multiple operations in one invocation
4. Provide helpful error messages

**Example usage**:
```bash
$ go run calc.go -op add -a 5.5 -b 3.2
8.70

$ go run calc.go -op div -a 10 -b 3 -precision 4
3.3333

$ go run calc.go -op sqrt -a 16
4.00
```

## Test Requirements

Implement comprehensive table-driven tests for each tool.

### Test Structure Pattern

```go
package main

import (
    "bytes"
    "strings"
    "testing"
)

func TestWordCount(t *testing.T) {
    tests := []struct {
        name       string
        input      string
        countLines bool
        countWords bool
        countChars bool
        wantLines  int
        wantWords  int
        wantChars  int
    }{
        {
            name:       "empty input",
            input:      "",
            countLines: true,
            countWords: true,
            countChars: true,
            wantLines:  0,
            wantWords:  0,
            wantChars:  0,
        },
        {
            name:       "single line",
            input:      "hello world",
            countLines: true,
            countWords: true,
            countChars: true,
            wantLines:  1,
            wantWords:  2,
            wantChars:  11,
        },
        {
            name:       "multiple lines",
            input:      "hello\nworld\n",
            countLines: true,
            countWords: true,
            countChars: true,
            wantLines:  2,
            wantWords:  2,
            wantChars:  12,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            reader := strings.NewReader(tt.input)
            gotLines, gotWords, gotChars := countFromReader(reader)

            if gotLines != tt.wantLines {
                t.Errorf("lines: got %d, want %d", gotLines, tt.wantLines)
            }
            if gotWords != tt.wantWords {
                t.Errorf("words: got %d, want %d", gotWords, tt.wantWords)
            }
            if gotChars != tt.wantChars {
                t.Errorf("chars: got %d, want %d", gotChars, tt.wantChars)
            }
        })
    }
}
```

### Required Test Cases

**For wc tool**:
1. Empty input (0 lines, 0 words, 0 chars)
2. Single line without newline
3. Multiple lines with various content
4. Unicode characters (emoji, multi-byte)
5. Only whitespace
6. Very long lines (>1000 chars)

**For grep tool**:
1. Pattern found (single match)
2. Pattern found (multiple matches per line)
3. Pattern not found
4. Case-insensitive matching
5. Inverted matching
6. Empty pattern (should match all lines)
7. Empty input

**For calculator**:
1. Each operation (add, sub, mul, div, pow, sqrt)
2. Division by zero error
3. Negative numbers
4. Precision formatting
5. Invalid operation name
6. Missing required operands

## Input/Output Specifications

### Word Count Tool

**Input**: Text files or stdin
**Output**: Formatted counts

```
Format: [lines] [words] [chars] [filename]

Examples:
     42     256    1543 file.txt
     10      45     234 file1.txt
     32     178     856 file2.txt
     42     223    1090 total
```

### Grep Tool

**Input**: Pattern + text files or stdin
**Output**: Matching lines (optionally with line numbers)

```
Format without -n: matched_line
Format with -n: line_number: matched_line
Format with -c: filename: count

Examples:
error in connection
15: ERROR: failed to connect
logfile.txt: 5
```

### Calculator

**Input**: Operation + operands via flags
**Output**: Calculated result with precision

```
Format: result_value

Examples:
8.70
3.3333
4.00
Error: division by zero
```

## Success Criteria

### Functional Requirements
- [ ] All three CLI tools compile and run without errors
- [ ] All flag types parsed correctly (bool, int, string, float64)
- [ ] Flags have appropriate defaults and descriptions
- [ ] Tools read from stdin when no files specified
- [ ] Tools process multiple files correctly
- [ ] Error messages are clear and helpful
- [ ] Help text displays with `-h` or `--help`

### Code Quality Requirements
- [ ] Code follows Go formatting (`gofmt`)
- [ ] Functions are focused and single-purpose
- [ ] Flag definitions are clear with good descriptions
- [ ] Input validation prevents panics
- [ ] Errors use `fmt.Fprintf(os.Stderr, ...)` pattern
- [ ] Exit codes: 0 for success, 1 for errors
- [ ] No global mutable state

### Testing Requirements
- [ ] All tools have `*_test.go` files
- [ ] Table-driven tests for all major functions
- [ ] Edge cases covered (empty input, invalid input)
- [ ] Tests use `strings.NewReader` for input simulation
- [ ] Tests check both output and error conditions
- [ ] Test coverage >80% for core logic

### CLI Best Practices
- [ ] Follow Unix philosophy (do one thing well)
- [ ] Work composably with pipes and redirection
- [ ] Provide meaningful help text
- [ ] Use standard I/O conventions (stdin/stdout/stderr)
- [ ] Exit codes follow conventions
- [ ] Flag names follow conventions (`-v`, `-verbose`)

## Common Pitfalls

### Pitfall 1: Forgetting to Call flag.Parse()

❌ **Wrong**: Flags defined but never parsed
```go
func main() {
    name := flag.String("name", "World", "name")
    // flag.Parse() is missing!
    fmt.Printf("Hello, %s!\n", *name)  // Always prints "Hello, World!"
}
```

✅ **Correct**: Always call flag.Parse()
```go
func main() {
    name := flag.String("name", "World", "name")
    flag.Parse()  // Parse command-line flags
    fmt.Printf("Hello, %s!\n", *name)
}
```

### Pitfall 2: Dereferencing Before flag.Parse()

❌ **Wrong**: Using flag value before parsing
```go
func main() {
    count := flag.Int("count", 1, "count")
    value := *count  // Dereferenced before Parse()!
    flag.Parse()
    fmt.Println(value)  // Always 1 (default)
}
```

✅ **Correct**: Dereference after flag.Parse()
```go
func main() {
    count := flag.Int("count", 1, "count")
    flag.Parse()
    value := *count  // Dereferenced after parsing
    fmt.Println(value)  // Correct value
}
```

### Pitfall 3: Not Checking for Required Arguments

❌ **Wrong**: Assuming arguments exist
```go
func main() {
    flag.Parse()
    filename := flag.Arg(0)  // Panics if no args!
    // process filename...
}
```

✅ **Correct**: Check argument count
```go
func main() {
    flag.Parse()

    if flag.NArg() < 1 {
        fmt.Fprintf(os.Stderr, "Error: filename required\n")
        flag.Usage()
        os.Exit(1)
    }

    filename := flag.Arg(0)
    // process filename...
}
```

### Pitfall 4: Not Providing Helpful Usage Information

❌ **Wrong**: Default cryptic help
```go
func main() {
    flag.Int("port", 8080, "p")  // Unclear description
    flag.Parse()
}
// Output: -port int
//           p (default 8080)
```

✅ **Correct**: Clear descriptions and custom usage
```go
func main() {
    flag.Usage = func() {
        fmt.Fprintf(os.Stderr, "Usage: %s [OPTIONS]\n\n", os.Args[0])
        fmt.Fprintf(os.Stderr, "Options:\n")
        flag.PrintDefaults()
    }

    flag.Int("port", 8080, "server port to listen on (1-65535)")
    flag.Parse()
}
```

### Pitfall 5: Using os.Exit in Library Code

❌ **Wrong**: Calling os.Exit from reusable functions
```go
func processFile(filename string) {
    file, err := os.Open(filename)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)  // Bad in library code!
    }
    // ...
}
```

✅ **Correct**: Return errors, let main() handle exits
```go
func processFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return fmt.Errorf("failed to open %s: %w", filename, err)
    }
    defer file.Close()
    // ...
    return nil
}

func main() {
    // ...
    if err := processFile(filename); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }
}
```

### Pitfall 6: Not Handling Stdin/File Input Uniformly

❌ **Wrong**: Separate logic for stdin vs files
```go
func main() {
    flag.Parse()

    if flag.NArg() > 0 {
        // Read from files
        for i := 0; i < flag.NArg(); i++ {
            // ... file reading logic
        }
    } else {
        // Different stdin logic
        // ... stdin reading logic
    }
}
```

✅ **Correct**: Use io.Reader interface for both
```go
func processReader(r io.Reader, name string) error {
    scanner := bufio.NewScanner(r)
    for scanner.Scan() {
        // ... processing logic
    }
    return scanner.Err()
}

func main() {
    flag.Parse()

    if flag.NArg() > 0 {
        for i := 0; i < flag.NArg(); i++ {
            file, err := os.Open(flag.Arg(i))
            if err != nil {
                return err
            }
            defer file.Close()
            processReader(file, flag.Arg(i))
        }
    } else {
        processReader(os.Stdin, "<stdin>")
    }
}
```

## Extension Challenges

### Extension 1: Add Color Output to Grep
Highlight matched patterns in red using ANSI color codes:
```go
const (
    ColorReset  = "\033[0m"
    ColorRed    = "\033[31m"
)

func highlightMatch(line, pattern string) string {
    return strings.ReplaceAll(line, pattern, ColorRed+pattern+ColorReset)
}
```

### Extension 2: Implement FlagSet for Subcommands
Create a tool with multiple subcommands, each with its own flags:
```go
func main() {
    if len(os.Args) < 2 {
        fmt.Println("expected 'add' or 'list' subcommands")
        os.Exit(1)
    }

    switch os.Args[1] {
    case "add":
        addCmd := flag.NewFlagSet("add", flag.ExitOnError)
        addName := addCmd.String("name", "", "task name")
        addCmd.Parse(os.Args[2:])
        // Handle add...
    case "list":
        listCmd := flag.NewFlagSet("list", flag.ExitOnError)
        listAll := listCmd.Bool("all", false, "show all")
        listCmd.Parse(os.Args[2:])
        // Handle list...
    default:
        fmt.Println("expected 'add' or 'list' subcommands")
        os.Exit(1)
    }
}
```

### Extension 3: Add Progress Bar for Large Files
Show progress when processing large files:
```go
func processWithProgress(filename string) error {
    stat, _ := os.Stat(filename)
    total := stat.Size()

    file, _ := os.Open(filename)
    defer file.Close()

    reader := &progressReader{
        reader: file,
        total:  total,
        onProgress: func(current, total int64) {
            pct := float64(current) / float64(total) * 100
            fmt.Fprintf(os.Stderr, "\rProgress: %.1f%%", pct)
        },
    }

    // Process reader...
}
```

### Extension 4: Support Configuration Files
Load default flag values from a config file:
```go
type Config struct {
    Verbose bool   `json:"verbose"`
    Output  string `json:"output"`
    MaxSize int    `json:"max_size"`
}

func loadConfig(filename string) (*Config, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, err
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, err
    }

    return &cfg, nil
}

func main() {
    // Try to load config
    cfg, _ := loadConfig(".apprc")

    // Define flags with config defaults
    verbose := flag.Bool("verbose", cfg.Verbose, "verbose output")
    // ...
}
```

### Extension 5: Add Shell Completion Support
Generate completion scripts for bash/zsh:
```go
func generateCompletion(shell string) {
    switch shell {
    case "bash":
        fmt.Println(`_myapp_completions() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "-verbose -output -help" -- $cur))
}
complete -F _myapp_completions myapp`)
    case "zsh":
        fmt.Println(`#compdef myapp
_myapp() {
    _arguments \
        '-verbose[Enable verbose output]' \
        '-output[Output file]:file:_files' \
        '-help[Show help]'
}`)
    }
}
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Project structure**: Each tool should be a separate package or file
2. **Core logic separation**: Separate I/O from business logic for testability
3. **Error handling**: Return errors, handle in main()
4. **Testing strategy**: Focus on testing core logic functions, not main()

### Code Organization

```
lesson-09/
├── wc/
│   ├── main.go          # CLI interface with flags
│   ├── counter.go       # Core counting logic
│   └── counter_test.go  # Table-driven tests
├── grep/
│   ├── main.go
│   ├── searcher.go
│   └── searcher_test.go
└── calc/
    ├── main.go
    ├── operations.go
    └── operations_test.go
```

### Quality Checklist

- [ ] Each tool is in its own directory
- [ ] Core logic separated from CLI parsing
- [ ] All functions have doc comments
- [ ] Table-driven tests for all core functions
- [ ] Edge cases handled (empty input, errors)
- [ ] Help text is clear and complete
- [ ] Code follows `gofmt` style
- [ ] No global mutable state
- [ ] Errors written to stderr, output to stdout
- [ ] Exit codes used correctly (0=success, 1=error)

### Testing Approach

Focus on testing pure functions that don't depend on flags or os.Args:

```go
// Good: Testable function
func countWords(r io.Reader) (int, error) {
    scanner := bufio.NewScanner(r)
    scanner.Split(bufio.ScanWords)
    count := 0
    for scanner.Scan() {
        count++
    }
    return count, scanner.Err()
}

// Test it
func TestCountWords(t *testing.T) {
    input := strings.NewReader("hello world foo bar")
    got, err := countWords(input)
    if err != nil {
        t.Fatal(err)
    }
    if got != 4 {
        t.Errorf("got %d, want 4", got)
    }
}
```

## Learning Resources

### Official Documentation
- [flag package](https://pkg.go.dev/flag) - Official flag package documentation
- [os package](https://pkg.go.dev/os) - os.Args and file operations
- [bufio package](https://pkg.go.dev/bufio) - Buffered I/O operations
- [io package](https://pkg.go.dev/io) - io.Reader and io.Writer interfaces

### Tutorials and Guides
- [Command Line Applications in Go](https://golang.org/doc/articles/wiki/) - Official Go wiki tutorial
- [Building CLI Applications](https://dev.to/ilyakaznacheev/a-guide-to-building-cli-applications-in-go-5d4b) - Comprehensive guide
- [The Unix Philosophy](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html) - Design principles

### Related Exercises
- [Gophercises #9: Deck of Cards](https://gophercises.com/) - CLI tool building
- [Exercism: Gigasecond](https://exercism.org/tracks/go/exercises/gigasecond) - Date calculations CLI
- [Go by Example: Command-Line Flags](https://gobyexample.com/command-line-flags) - Quick reference

## Validation Commands

```bash
# Format code
go fmt ./lesson-09/...

# Run all tests
go test ./lesson-09/... -v

# Check test coverage
go test ./lesson-09/... -cover

# Build all tools
cd lesson-09/wc && go build
cd lesson-09/grep && go build
cd lesson-09/calc && go build

# Test wc tool
echo "hello world" | ./wc/wc
./wc/wc -l -w README.md

# Test grep tool
./grep/grep -n "error" testfile.txt
echo "test\nERROR\nfoo" | ./grep/grep -i "error"

# Test calc tool
./calc/calc -op add -a 5 -b 3
./calc/calc -op sqrt -a 16
```

---

**Next Lesson**: [Lesson 10: File I/O & JSON Persistence](lesson-10-file-io-json.md) - Learn file operations and JSON marshaling for data persistence

**Previous Lesson**: [Lesson 08: Packages & Modules](lesson-08-packages-modules.md) - Go package system and module management

**Phase Overview**: [Phase 2: CLI Development](../README.md#phase-2-cli-development-weeks-3-4) - Building command-line applications
