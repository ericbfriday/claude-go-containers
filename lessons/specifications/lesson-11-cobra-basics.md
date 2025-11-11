# Lesson 11: Cobra Framework Fundamentals

**Phase**: 2 - Building Command-Line Tools
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-10 (especially Lesson 09: CLI Fundamentals and Lesson 10: Advanced Flag Handling)

## Overview

Learn to build professional command-line applications using the Cobra framework. Master command structure, subcommands, and help generation to create git-style CLIs with proper organization and documentation.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Initialize Cobra projects using cobra-cli and manual setup
2. Create and configure root commands with proper metadata
3. Add subcommands with organized command hierarchies
4. Implement automatic help generation and usage documentation
5. Structure multi-command CLI applications following best practices
6. Integrate Cobra with existing flag-based applications
7. Build professional CLIs with proper command organization
8. Apply Cobra conventions for command naming and structure

## Why Cobra Matters

Cobra is the de facto standard for building CLI applications in Go, powering tools like kubectl, GitHub CLI, Hugo, and Docker CLI. It provides:

- **Automatic Help Generation**: Built-in help and usage text
- **Command Organization**: Hierarchical command structures
- **Flag Management**: Sophisticated flag handling with validation
- **POSIX Compliance**: Standard CLI conventions and patterns
- **Extensibility**: Easy to add new commands and features

Understanding Cobra is essential for building production-ready CLI tools that meet user expectations.

## Core Concepts

### 1. Cobra Architecture

Cobra structures CLI applications around commands, arguments, and flags:

```go
// Basic Cobra application structure
package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// Root command - main entry point
var rootCmd = &cobra.Command{
	Use:   "myapp",
	Short: "A brief description of your application",
	Long: `A longer description that spans multiple lines and likely contains
examples and usage of using your application. For example:

MyApp is a CLI tool that demonstrates Cobra's capabilities
for building professional command-line applications.`,
	Run: func(cmd *cobra.Command, args []string) {
		// Root command logic
		fmt.Println("Welcome to MyApp!")
	},
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
```

**Command Structure Components**:
- **Use**: Command name and argument syntax
- **Short**: Brief one-line description
- **Long**: Detailed multi-line description
- **Run**: Function executed when command runs

### 2. Cobra-CLI Tool for Scaffolding

The cobra-cli tool generates boilerplate code and command structures:

```bash
# Install cobra-cli
go install github.com/spf13/cobra-cli@latest

# Initialize new Cobra application
cobra-cli init myapp

# Add subcommands
cobra-cli add serve
cobra-cli add config
cobra-cli add create
```

**Generated Structure**:
```
myapp/
├── cmd/
│   ├── root.go       # Root command definition
│   ├── serve.go      # Subcommand: serve
│   ├── config.go     # Subcommand: config
│   └── create.go     # Subcommand: create
├── main.go           # Entry point
└── go.mod
```

### 3. Root Command Setup

The root command serves as the application entry point:

```go
// cmd/root.go
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	// Global flags available to all commands
	cfgFile string
	verbose bool
)

var rootCmd = &cobra.Command{
	Use:   "taskctl",
	Short: "A modern task management CLI",
	Long: `TaskCtl is a command-line task manager built with Cobra.

It provides an intuitive interface for managing your daily tasks,
projects, and deadlines with powerful filtering and reporting.`,
	Version: "1.0.0",
	// PersistentPreRun runs before any subcommand
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		if verbose {
			fmt.Println("Verbose mode enabled")
		}
	},
}

// Execute runs the root command
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func init() {
	// Persistent flags available to all commands
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.taskctl.yaml)")
	rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")
}
```

**Root Command Features**:
- Version information with `--version` flag
- Persistent flags shared by all subcommands
- PersistentPreRun hooks for initialization
- Global state management

### 4. Adding Subcommands

Subcommands create hierarchical command structures:

```go
// cmd/add.go
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var addCmd = &cobra.Command{
	Use:   "add [task description]",
	Short: "Add a new task",
	Long: `Add a new task to your task list.

The task description can contain spaces and special characters.
Use quotes for complex descriptions.`,
	Args: cobra.MinimumNArgs(1), // Require at least one argument
	Example: `  taskctl add "Complete project documentation"
  taskctl add "Review pull requests" --priority high
  taskctl add "Deploy to production" --tag release`,
	Run: func(cmd *cobra.Command, args []string) {
		// Combine all arguments into task description
		description := cmd.Flags().Args()[0]
		priority, _ := cmd.Flags().GetString("priority")

		fmt.Printf("Adding task: %s\n", description)
		fmt.Printf("Priority: %s\n", priority)

		// Actual task creation logic would go here
	},
}

func init() {
	// Register subcommand with root
	rootCmd.AddCommand(addCmd)

	// Add local flags specific to this command
	addCmd.Flags().StringP("priority", "p", "medium", "task priority (low/medium/high)")
	addCmd.Flags().StringSliceP("tag", "t", []string{}, "task tags (can be specified multiple times)")
}
```

**Subcommand Features**:
- Argument validation with `Args` field
- Example usage in help text
- Command-specific flags (local flags)
- Integration with root command via `AddCommand()`

### 5. Command Organization Patterns

Organize commands logically for complex CLIs:

```go
// Hierarchical command structure: git-style
// app config set key value
// app config get key
// app config list

// cmd/config.go
var configCmd = &cobra.Command{
	Use:   "config",
	Short: "Manage application configuration",
	Long:  "Configure application settings, preferences, and defaults.",
}

var configSetCmd = &cobra.Command{
	Use:   "set [key] [value]",
	Short: "Set a configuration value",
	Args:  cobra.ExactArgs(2),
	Run: func(cmd *cobra.Command, args []string) {
		key, value := args[0], args[1]
		fmt.Printf("Setting %s = %s\n", key, value)
	},
}

var configGetCmd = &cobra.Command{
	Use:   "get [key]",
	Short: "Get a configuration value",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		key := args[0]
		fmt.Printf("Getting value for %s\n", key)
	},
}

var configListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all configuration values",
	Args:  cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Listing all configuration...")
	},
}

func init() {
	// Build command hierarchy
	rootCmd.AddCommand(configCmd)
	configCmd.AddCommand(configSetCmd)
	configCmd.AddCommand(configGetCmd)
	configCmd.AddCommand(configListCmd)
}
```

**Organization Best Practices**:
- Group related commands under parent commands
- Use clear, verb-based command names
- Limit nesting to 2-3 levels deep
- Provide parent commands with helpful descriptions

### 6. Help Generation and Usage Text

Cobra automatically generates comprehensive help:

```go
var listCmd = &cobra.Command{
	Use:   "list [flags]",
	Short: "List all tasks",
	Long: `Display a list of all tasks with filtering options.

Tasks can be filtered by status, priority, tags, and more.
Use flags to customize the output format and content.`,
	Example: `  # List all tasks
  taskctl list

  # List only pending tasks
  taskctl list --status pending

  # List high priority tasks with 'urgent' tag
  taskctl list --priority high --tag urgent

  # List tasks in JSON format
  taskctl list --format json`,
	Run: func(cmd *cobra.Command, args []string) {
		// List logic
	},
}

func init() {
	rootCmd.AddCommand(listCmd)

	// Flags with descriptions
	listCmd.Flags().StringP("status", "s", "all", "filter by status (all/pending/completed)")
	listCmd.Flags().StringP("priority", "p", "all", "filter by priority (all/low/medium/high)")
	listCmd.Flags().StringSliceP("tag", "t", []string{}, "filter by tags")
	listCmd.Flags().StringP("format", "f", "table", "output format (table/json/csv)")
}
```

**Help Output Example**:
```
$ taskctl list --help
Display a list of all tasks with filtering options.

Tasks can be filtered by status, priority, tags, and more.
Use flags to customize the output format and content.

Usage:
  taskctl list [flags]

Examples:
  # List all tasks
  taskctl list

  # List only pending tasks
  taskctl list --status pending

  # List high priority tasks with 'urgent' tag
  taskctl list --priority high --tag urgent

  # List tasks in JSON format
  taskctl list --format json

Flags:
  -f, --format string     output format (table/json/csv) (default "table")
  -h, --help              help for list
  -p, --priority string   filter by priority (all/low/medium/high) (default "all")
  -s, --status string     filter by status (all/pending/completed) (default "all")
  -t, --tag strings       filter by tags

Global Flags:
      --config string   config file (default is $HOME/.taskctl.yaml)
  -v, --verbose         verbose output
```

### 7. Converting Flag-Based CLI to Cobra

Migrate existing flag-based applications to Cobra:

**Before (flag package)**:
```go
package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	var (
		name    = flag.String("name", "", "user name")
		age     = flag.Int("age", 0, "user age")
		verbose = flag.Bool("verbose", false, "verbose output")
	)

	flag.Parse()

	if *name == "" {
		fmt.Println("Error: name required")
		os.Exit(1)
	}

	fmt.Printf("Name: %s, Age: %d\n", *name, *age)
}
```

**After (Cobra)**:
```go
package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

func main() {
	var (
		name    string
		age     int
		verbose bool
	)

	rootCmd := &cobra.Command{
		Use:   "userinfo",
		Short: "Display user information",
		RunE: func(cmd *cobra.Command, args []string) error {
			if name == "" {
				return fmt.Errorf("name is required")
			}

			fmt.Printf("Name: %s, Age: %d\n", name, age)
			return nil
		},
	}

	rootCmd.Flags().StringVarP(&name, "name", "n", "", "user name (required)")
	rootCmd.Flags().IntVarP(&age, "age", "a", 0, "user age")
	rootCmd.Flags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")

	rootCmd.MarkFlagRequired("name")

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
```

**Migration Benefits**:
- Automatic help generation
- Better error messages
- Extensible command structure
- Consistent user experience

### 8. Command Structure Best Practices

Follow Cobra conventions for maintainable CLIs:

```go
// Good: Clear command organization
// app/
//   cmd/
//     root.go          # Root command + global setup
//     version.go       # Simple commands in separate files
//     server/
//       server.go      # Parent command
//       start.go       # Subcommand: start
//       stop.go        # Subcommand: stop
//       status.go      # Subcommand: status
//     config/
//       config.go      # Parent command
//       get.go         # Subcommand: get
//       set.go         # Subcommand: set
//       list.go        # Subcommand: list

// cmd/root.go - Minimal root setup
package cmd

import (
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "myapp",
	Short: "Application description",
}

func Execute() error {
	return rootCmd.Execute()
}

// cmd/server/server.go - Parent command
package server

import (
	"github.com/spf13/cobra"
)

var ServerCmd = &cobra.Command{
	Use:   "server",
	Short: "Manage application server",
}

func init() {
	// Subcommands added in their own files
	ServerCmd.AddCommand(startCmd)
	ServerCmd.AddCommand(stopCmd)
	ServerCmd.AddCommand(statusCmd)
}

// cmd/server/start.go - Focused subcommand
package server

import (
	"fmt"

	"github.com/spf13/cobra"
)

var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Start the application server",
	RunE: func(cmd *cobra.Command, args []string) error {
		port, _ := cmd.Flags().GetInt("port")
		fmt.Printf("Starting server on port %d\n", port)
		return nil
	},
}

func init() {
	startCmd.Flags().IntP("port", "p", 8080, "server port")
}
```

**Structure Guidelines**:
- One command per file for complex commands
- Group related commands in subdirectories
- Register subcommands in parent's init()
- Export parent commands (ServerCmd) for registration
- Keep root.go minimal and focused

### 9. Argument Validation

Cobra provides built-in argument validators:

```go
// Exact number of arguments
var exactCmd = &cobra.Command{
	Use:  "exact [arg1] [arg2]",
	Args: cobra.ExactArgs(2),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Args: %v\n", args)
	},
}

// Minimum number of arguments
var minCmd = &cobra.Command{
	Use:  "min [args...]",
	Args: cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Args: %v\n", args)
	},
}

// Maximum number of arguments
var maxCmd = &cobra.Command{
	Use:  "max [args...]",
	Args: cobra.MaximumNArgs(3),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Args: %v\n", args)
	},
}

// Range of arguments
var rangeCmd = &cobra.Command{
	Use:  "range [args...]",
	Args: cobra.RangeArgs(1, 3),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Args: %v\n", args)
	},
}

// No arguments allowed
var noArgsCmd = &cobra.Command{
	Use:  "noargs",
	Args: cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("No arguments accepted")
	},
}

// Custom validation
var customCmd = &cobra.Command{
	Use: "custom [file]",
	Args: func(cmd *cobra.Command, args []string) error {
		if len(args) != 1 {
			return fmt.Errorf("requires exactly one file argument")
		}
		if !strings.HasSuffix(args[0], ".json") {
			return fmt.Errorf("file must have .json extension")
		}
		return nil
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Processing file: %s\n", args[0])
	},
}
```

**Validator Options**:
- `NoArgs`: No arguments allowed
- `ExactArgs(n)`: Exactly n arguments required
- `MinimumNArgs(n)`: At least n arguments required
- `MaximumNArgs(n)`: At most n arguments allowed
- `RangeArgs(min, max)`: Between min and max arguments
- Custom function: Full control over validation

## Practical Examples

### Example 1: Simple CLI with Subcommands

```go
// main.go
package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	verbose bool
	output  string
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "greet",
		Short: "A friendly greeting CLI",
		Long:  "Greet demonstrates basic Cobra commands and flags.",
	}

	helloCmd := &cobra.Command{
		Use:   "hello [name]",
		Short: "Say hello to someone",
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			name := args[0]
			greeting := fmt.Sprintf("Hello, %s!", name)

			if verbose {
				greeting = fmt.Sprintf("Hello, %s! Nice to meet you.", name)
			}

			fmt.Println(greeting)
		},
	}

	goodbyeCmd := &cobra.Command{
		Use:   "goodbye [name]",
		Short: "Say goodbye to someone",
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			name := args[0]
			fmt.Printf("Goodbye, %s!\n", name)
		},
	}

	rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")
	rootCmd.PersistentFlags().StringVarP(&output, "output", "o", "text", "output format")

	rootCmd.AddCommand(helloCmd)
	rootCmd.AddCommand(goodbyeCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
```

**Usage**:
```bash
$ greet hello Alice
Hello, Alice!

$ greet hello Alice --verbose
Hello, Alice! Nice to meet you.

$ greet goodbye Bob
Goodbye, Bob!

$ greet --help
Greet demonstrates basic Cobra commands and flags.

Usage:
  greet [command]

Available Commands:
  goodbye     Say goodbye to someone
  hello       Say hello to someone
  help        Help about any command

Flags:
  -h, --help            help for greet
  -o, --output string   output format (default "text")
  -v, --verbose         verbose output
```

### Example 2: Git-Style Command Hierarchy

```go
// Calculator CLI with nested commands
package main

import (
	"fmt"
	"os"
	"strconv"

	"github.com/spf13/cobra"
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "calc",
		Short: "A simple calculator CLI",
	}

	// Math parent command
	mathCmd := &cobra.Command{
		Use:   "math",
		Short: "Perform mathematical operations",
	}

	// Math subcommands
	addCmd := &cobra.Command{
		Use:   "add [numbers...]",
		Short: "Add numbers together",
		Args:  cobra.MinimumNArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			sum := 0.0
			for _, arg := range args {
				num, err := strconv.ParseFloat(arg, 64)
				if err != nil {
					return fmt.Errorf("invalid number: %s", arg)
				}
				sum += num
			}
			fmt.Printf("Result: %.2f\n", sum)
			return nil
		},
	}

	multiplyCmd := &cobra.Command{
		Use:   "multiply [numbers...]",
		Short: "Multiply numbers together",
		Args:  cobra.MinimumNArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			product := 1.0
			for _, arg := range args {
				num, err := strconv.ParseFloat(arg, 64)
				if err != nil {
					return fmt.Errorf("invalid number: %s", arg)
				}
				product *= num
			}
			fmt.Printf("Result: %.2f\n", product)
			return nil
		},
	}

	// Build hierarchy
	mathCmd.AddCommand(addCmd)
	mathCmd.AddCommand(multiplyCmd)
	rootCmd.AddCommand(mathCmd)

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
```

**Usage**:
```bash
$ calc math add 10 20 30
Result: 60.00

$ calc math multiply 5 4 3
Result: 60.00

$ calc math --help
Perform mathematical operations

Usage:
  calc math [command]

Available Commands:
  add         Add numbers together
  multiply    Multiply numbers together

Flags:
  -h, --help   help for math
```

### Example 3: Version Command with Build Info

```go
package main

import (
	"fmt"
	"runtime"

	"github.com/spf13/cobra"
)

var (
	version   = "1.0.0"
	gitCommit = "abc123"
	buildDate = "2024-01-15"
)

func main() {
	rootCmd := &cobra.Command{
		Use:     "myapp",
		Short:   "My application",
		Version: version,
	}

	// Custom version command with detailed info
	versionCmd := &cobra.Command{
		Use:   "version",
		Short: "Print version information",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("Version:    %s\n", version)
			fmt.Printf("Git Commit: %s\n", gitCommit)
			fmt.Printf("Build Date: %s\n", buildDate)
			fmt.Printf("Go Version: %s\n", runtime.Version())
			fmt.Printf("OS/Arch:    %s/%s\n", runtime.GOOS, runtime.GOARCH)
		},
	}

	rootCmd.AddCommand(versionCmd)
	rootCmd.Execute()
}
```

**Usage**:
```bash
$ myapp version
Version:    1.0.0
Git Commit: abc123
Build Date: 2024-01-15
Go Version: go1.21.0
OS/Arch:    linux/amd64

$ myapp --version
myapp version 1.0.0
```

## Practice Challenges

### Challenge 1: Convert CLI to Cobra

**Objective**: Migrate the weather CLI from Lesson 09 to use Cobra.

**Requirements**:
1. Convert the flag-based CLI to Cobra commands
2. Create subcommands for `current`, `forecast`, and `config`
3. Add help text and examples for each command
4. Implement persistent flags for city and units
5. Add version information

**Starter Code**:
```go
// Current implementation uses flag package
// main.go from Lesson 09
```

**Expected CLI Interface**:
```bash
$ weather current --city "San Francisco"
$ weather forecast --city "New York" --days 7
$ weather config set default-city "London"
$ weather config get default-city
$ weather --help
```

**Test Requirements**:
```go
func TestWeatherCommands(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantErr  bool
		contains string
	}{
		{
			name:     "current weather requires city",
			args:     []string{"current"},
			wantErr:  true,
			contains: "city",
		},
		{
			name:     "current weather with city",
			args:     []string{"current", "--city", "Boston"},
			wantErr:  false,
			contains: "Boston",
		},
		{
			name:     "forecast with days flag",
			args:     []string{"forecast", "--city", "Seattle", "--days", "5"},
			wantErr:  false,
			contains: "5 day",
		},
		{
			name:     "config set command",
			args:     []string{"config", "set", "default-city", "Portland"},
			wantErr:  false,
			contains: "Portland",
		},
		{
			name:     "help shows all commands",
			args:     []string{"--help"},
			wantErr:  false,
			contains: "current",
		},
		{
			name:     "version flag",
			args:     []string{"--version"},
			wantErr:  false,
			contains: "version",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test command execution
		})
	}
}
```

### Challenge 2: Build Multi-Command File Manager

**Objective**: Create a file management CLI with hierarchical commands.

**Requirements**:
1. Root command: `fm` (file manager)
2. Parent command: `file` with subcommands:
   - `file list [directory]` - list files
   - `file info [path]` - show file info
   - `file search [pattern]` - search files
3. Parent command: `dir` with subcommands:
   - `dir create [path]` - create directory
   - `dir remove [path]` - remove directory
   - `dir tree [path]` - show directory tree
4. Add persistent flags for verbose and recursive operations
5. Include comprehensive help text and examples

**Example Usage**:
```bash
$ fm file list ~/documents
$ fm file info README.md --verbose
$ fm file search "*.go" --recursive
$ fm dir create ~/projects/newapp
$ fm dir tree ~/projects --depth 2
```

**Test Requirements**:
```go
func TestFileManagerCommands(t *testing.T) {
	tests := []struct {
		name        string
		args        []string
		setupFunc   func() error
		cleanupFunc func() error
		wantErr     bool
		validate    func(*testing.T, string)
	}{
		{
			name: "list files in directory",
			args: []string{"file", "list", "testdata"},
			setupFunc: func() error {
				return os.MkdirAll("testdata", 0755)
			},
			cleanupFunc: func() error {
				return os.RemoveAll("testdata")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "testdata") {
					t.Error("output should contain directory name")
				}
			},
		},
		{
			name:    "file info requires path",
			args:    []string{"file", "info"},
			wantErr: true,
		},
		{
			name: "dir create makes directory",
			args: []string{"dir", "create", "testdata/newdir"},
			cleanupFunc: func() error {
				return os.RemoveAll("testdata")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if _, err := os.Stat("testdata/newdir"); os.IsNotExist(err) {
					t.Error("directory should be created")
				}
			},
		},
		{
			name: "dir tree shows structure",
			args: []string{"dir", "tree", "testdata"},
			setupFunc: func() error {
				os.MkdirAll("testdata/a/b", 0755)
				return os.MkdirAll("testdata/c", 0755)
			},
			cleanupFunc: func() error {
				return os.RemoveAll("testdata")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "├──") && !strings.Contains(output, "└──") {
					t.Error("output should contain tree characters")
				}
			},
		},
		{
			name:    "search requires pattern",
			args:    []string{"file", "search"},
			wantErr: true,
		},
		{
			name: "help shows all parent commands",
			args: []string{"--help"},
			validate: func(t *testing.T, output string) {
				requiredCommands := []string{"file", "dir"}
				for _, cmd := range requiredCommands {
					if !strings.Contains(output, cmd) {
						t.Errorf("help should contain '%s' command", cmd)
					}
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.setupFunc != nil {
				if err := tt.setupFunc(); err != nil {
					t.Fatalf("setup failed: %v", err)
				}
			}

			if tt.cleanupFunc != nil {
				defer tt.cleanupFunc()
			}

			// Execute command and validate
		})
	}
}
```

### Challenge 3: Document Management System

**Objective**: Build a document management CLI with comprehensive help and validation.

**Requirements**:
1. Commands for creating, listing, editing, and deleting documents
2. Argument validation for document IDs and paths
3. Custom validators for file extensions (only .md, .txt)
4. Comprehensive help text with examples for each command
5. Version command with build information
6. Support for tags and metadata

**Command Structure**:
```
docman
├── create [name]
│   --template string
│   --tags strings
├── list
│   --tags strings
│   --format string (table/json)
├── edit [id]
│   --editor string
├── delete [id]
│   --force bool
├── show [id]
│   --format string
└── version
```

**Example Usage**:
```bash
$ docman create "Project Notes" --template project --tags work,planning
$ docman list --tags work
$ docman show doc-123 --format json
$ docman edit doc-123 --editor vim
$ docman delete doc-123 --force
```

**Test Requirements**:
```go
func TestDocumentCommands(t *testing.T) {
	tests := []struct {
		name         string
		args         []string
		wantErr      bool
		errorMessage string
		validate     func(*testing.T, string)
	}{
		{
			name:    "create requires document name",
			args:    []string{"create"},
			wantErr: true,
			errorMessage: "requires exactly 1 arg",
		},
		{
			name:    "create with valid name",
			args:    []string{"create", "Test Document"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "Test Document") {
					t.Error("should create document with given name")
				}
			},
		},
		{
			name:    "list with tag filter",
			args:    []string{"list", "--tags", "work,urgent"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "work") || !strings.Contains(output, "urgent") {
					t.Error("should filter by tags")
				}
			},
		},
		{
			name:    "show requires document id",
			args:    []string{"show"},
			wantErr: true,
			errorMessage: "requires exactly 1 arg",
		},
		{
			name:    "delete without force prompts confirmation",
			args:    []string{"delete", "doc-123"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "confirm") {
					t.Error("should prompt for confirmation")
				}
			},
		},
		{
			name:    "version shows build info",
			args:    []string{"version"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				required := []string{"Version", "Build Date", "Go Version"}
				for _, s := range required {
					if !strings.Contains(output, s) {
						t.Errorf("version output should contain '%s'", s)
					}
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Execute command and validate results
		})
	}
}
```

## Common Pitfalls

### 1. Not Registering Subcommands

**❌ Wrong**:
```go
// Subcommand never registered
var addCmd = &cobra.Command{
	Use: "add",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Adding...")
	},
}

func init() {
	// Missing: rootCmd.AddCommand(addCmd)
}

// Command is invisible to users
```

**✅ Correct**:
```go
var addCmd = &cobra.Command{
	Use: "add",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Adding...")
	},
}

func init() {
	rootCmd.AddCommand(addCmd) // Register subcommand
}
```

### 2. Poor Command Naming

**❌ Wrong**:
```go
// Unclear, inconsistent command names
var cmd1 = &cobra.Command{Use: "do_something"}
var cmd2 = &cobra.Command{Use: "performAction"}
var cmd3 = &cobra.Command{Use: "Thing"}

// Mixed conventions, unclear purpose
```

**✅ Correct**:
```go
// Clear, verb-based, consistent naming
var createCmd = &cobra.Command{Use: "create"}
var listCmd = &cobra.Command{Use: "list"}
var deleteCmd = &cobra.Command{Use: "delete"}

// Follows standard CLI conventions
```

### 3. Missing Help Text

**❌ Wrong**:
```go
var deployCmd = &cobra.Command{
	Use: "deploy",
	// No Short or Long description
	Run: func(cmd *cobra.Command, args []string) {
		// Deploy logic
	},
}

// Users have no idea what this does
```

**✅ Correct**:
```go
var deployCmd = &cobra.Command{
	Use:   "deploy [environment]",
	Short: "Deploy application to specified environment",
	Long: `Deploy builds and deploys the application to the specified environment.

Supported environments: dev, staging, production
Requires proper authentication and permissions.`,
	Example: `  myapp deploy staging
  myapp deploy production --version v1.2.3`,
	Run: func(cmd *cobra.Command, args []string) {
		// Deploy logic
	},
}
```

### 4. Ignoring Argument Validation

**❌ Wrong**:
```go
var deleteCmd = &cobra.Command{
	Use: "delete [id]",
	// No Args validation
	Run: func(cmd *cobra.Command, args []string) {
		id := args[0] // Panic if no args provided!
		fmt.Printf("Deleting %s\n", id)
	},
}
```

**✅ Correct**:
```go
var deleteCmd = &cobra.Command{
	Use:  "delete [id]",
	Args: cobra.ExactArgs(1), // Validate argument count
	RunE: func(cmd *cobra.Command, args []string) error {
		id := args[0] // Safe: validated by Args
		if id == "" {
			return fmt.Errorf("id cannot be empty")
		}
		fmt.Printf("Deleting %s\n", id)
		return nil
	},
}
```

### 5. Using Run Instead of RunE

**❌ Wrong**:
```go
var processCmd = &cobra.Command{
	Use: "process",
	Run: func(cmd *cobra.Command, args []string) {
		if err := doSomething(); err != nil {
			fmt.Println(err) // Error printed but not propagated
			// Exit status still 0!
		}
	},
}
```

**✅ Correct**:
```go
var processCmd = &cobra.Command{
	Use: "process",
	RunE: func(cmd *cobra.Command, args []string) error {
		if err := doSomething(); err != nil {
			return fmt.Errorf("process failed: %w", err)
		}
		return nil
	},
}

// Cobra handles error display and exit code
```

### 6. Overly Deep Command Hierarchies

**❌ Wrong**:
```go
// Too many nesting levels
// myapp config database connection pool size set 10
rootCmd.AddCommand(configCmd)
configCmd.AddCommand(databaseCmd)
databaseCmd.AddCommand(connectionCmd)
connectionCmd.AddCommand(poolCmd)
poolCmd.AddCommand(sizeCmd)
sizeCmd.AddCommand(setCmd)

// Confusing and hard to remember
```

**✅ Correct**:
```go
// Flatter, more intuitive structure
// myapp config set db.pool.size 10
rootCmd.AddCommand(configCmd)
configCmd.AddCommand(setCmd)

// Or: myapp db config --pool-size 10
rootCmd.AddCommand(dbCmd)
dbCmd.AddCommand(configCmd)

// Maximum 2-3 levels deep
```

## Testing Your Cobra Applications

```go
// cmd/root_test.go
package cmd

import (
	"bytes"
	"strings"
	"testing"

	"github.com/spf13/cobra"
)

func executeCommand(root *cobra.Command, args ...string) (string, error) {
	buf := new(bytes.Buffer)
	root.SetOut(buf)
	root.SetErr(buf)
	root.SetArgs(args)

	err := root.Execute()
	return buf.String(), err
}

func TestRootCommand(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantErr  bool
		contains string
	}{
		{
			name:     "no args shows help",
			args:     []string{},
			wantErr:  false,
			contains: "Usage:",
		},
		{
			name:     "help flag",
			args:     []string{"--help"},
			wantErr:  false,
			contains: "Available Commands:",
		},
		{
			name:     "version flag",
			args:     []string{"--version"},
			wantErr:  false,
			contains: "version",
		},
		{
			name:     "unknown command",
			args:     []string{"nonexistent"},
			wantErr:  true,
			contains: "unknown command",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			output, err := executeCommand(rootCmd, tt.args...)

			if (err != nil) != tt.wantErr {
				t.Errorf("wantErr %v, got %v", tt.wantErr, err)
			}

			if !strings.Contains(output, tt.contains) {
				t.Errorf("expected output to contain %q, got %q", tt.contains, output)
			}
		})
	}
}

func TestSubcommands(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantErr  bool
		validate func(*testing.T, string)
	}{
		{
			name:    "add command with args",
			args:    []string{"add", "task description"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "task description") {
					t.Error("should include task description in output")
				}
			},
		},
		{
			name:    "add command without args",
			args:    []string{"add"},
			wantErr: true,
		},
		{
			name:    "list command",
			args:    []string{"list"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if output == "" {
					t.Error("list should produce output")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			output, err := executeCommand(rootCmd, tt.args...)

			if (err != nil) != tt.wantErr {
				t.Errorf("wantErr %v, got %v", tt.wantErr, err)
			}

			if tt.validate != nil {
				tt.validate(t, output)
			}
		})
	}
}
```

## Extension Challenges

### 1. Interactive Mode

Add an interactive shell mode to your Cobra CLI:
- Accept commands in a REPL loop
- Maintain command history
- Support tab completion
- Allow exiting with `exit` or `quit` commands

### 2. Configuration File Support

Integrate Viper for configuration management:
- Load config from file (JSON, YAML, TOML)
- Support environment variable overrides
- Provide `config` subcommands for managing settings
- Merge flags with config values

### 3. Colored Output

Add color to your CLI output:
- Use github.com/fatih/color package
- Color error messages red
- Highlight important information
- Add a `--no-color` flag to disable

### 4. Progress Indicators

Add progress bars for long-running operations:
- Show spinner for indeterminate progress
- Display progress bar for determinate operations
- Update status messages during execution
- Provide `--quiet` flag to suppress progress

### 5. Plugin System

Design a plugin system for extensibility:
- Load plugins from specific directory
- Validate plugin signatures
- Register plugin commands dynamically
- Provide plugin discovery via `plugins list` command

## Learning Resources

### Official Documentation
- [Cobra GitHub Repository](https://github.com/spf13/cobra)
- [Cobra User Guide](https://cobra.dev/)
- [Cobra Generator Documentation](https://github.com/spf13/cobra-cli)

### Code Examples
- [kubectl Source Code](https://github.com/kubernetes/kubectl) - Complex Cobra implementation
- [GitHub CLI Source](https://github.com/cli/cli) - Modern CLI patterns
- [Hugo Source Code](https://github.com/gohugoio/hugo) - Documentation generator using Cobra

### Tutorials and Articles
- "Building CLI Applications with Cobra" - Tutorial series
- "Cobra Best Practices" - Community guidelines
- "Testing Cobra Commands" - Unit testing strategies

### Related Libraries
- [Viper](https://github.com/spf13/viper) - Configuration management (pairs with Cobra)
- [Survey](https://github.com/AlecAivazis/survey) - Interactive prompts
- [Color](https://github.com/fatih/color) - Terminal colors

## Summary

You've learned to build professional CLI applications with Cobra:

**Key Achievements**:
- ✅ Initialize Cobra projects with proper structure
- ✅ Create root commands with comprehensive metadata
- ✅ Build hierarchical command structures with subcommands
- ✅ Implement automatic help generation
- ✅ Validate arguments with built-in and custom validators
- ✅ Migrate flag-based CLIs to Cobra architecture
- ✅ Organize commands following best practices
- ✅ Test Cobra commands systematically

**Cobra provides**:
- Professional CLI framework used by major projects
- Automatic help generation and POSIX compliance
- Flexible command hierarchies and flag management
- Extensible architecture for complex tools

**Next Steps**:
- Lesson 12 covers advanced Cobra features (persistent flags, config files, hooks)
- Lesson 13 applies Cobra to build the Task Tracker milestone project

## Navigation

**Previous**: [Lesson 10: Advanced Flag Handling](lesson-10-advanced-flags.md)
**Next**: [Lesson 12: Cobra Subcommands & Flags](lesson-12-cobra-subcommands.md)
**Phase Overview**: [Phase 2: Building Command-Line Tools](../README.md#phase-2)
