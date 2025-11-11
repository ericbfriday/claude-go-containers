# Lesson 12: Cobra Subcommands & Advanced Flags

**Phase**: 2 - Building Command-Line Tools
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-11 (especially Lesson 11: Cobra Framework Fundamentals)

## Overview

Master advanced Cobra features including persistent flags, configuration file binding, argument validators, command hooks, and aliases. Build sophisticated CLI tools with proper state management and user-friendly interfaces.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Distinguish between persistent flags, local flags, and inherited flags
2. Implement required flag validation with custom error messages
3. Integrate Viper for configuration file management and flag binding
4. Use positional argument validators and custom validation logic
5. Implement PreRun, PostRun, and other lifecycle hooks
6. Create command aliases and shortcuts for improved UX
7. Build git-style CLIs with persistent configuration
8. Combine Cobra and Viper for production-ready configuration management

## Why Advanced Features Matter

Professional CLI tools require sophisticated features beyond basic commands:

- **Persistent Configuration**: Save user preferences across sessions
- **Smart Defaults**: Load configuration from files, environment, or flags
- **Validation**: Prevent invalid operations before execution
- **Lifecycle Control**: Initialize and cleanup resources properly
- **User Experience**: Provide shortcuts and intuitive interfaces

Tools like kubectl, helm, and gh CLI demonstrate these patterns in production environments.

## Core Concepts

### 1. Persistent vs Local Flags

Flags have different scopes in Cobra's command hierarchy:

```go
package main

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	// Persistent flags: available to this command and all subcommands
	globalVerbose bool
	globalConfig  string

	// Local flags: only available to specific command
	localFormat string
	localLimit  int
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "myapp",
		Short: "Demonstration of flag scopes",
	}

	// Persistent flags defined on root are available to ALL commands
	rootCmd.PersistentFlags().BoolVarP(&globalVerbose, "verbose", "v", false, "verbose output")
	rootCmd.PersistentFlags().StringVar(&globalConfig, "config", "", "config file path")

	listCmd := &cobra.Command{
		Use:   "list",
		Short: "List items",
		Run: func(cmd *cobra.Command, args []string) {
			// Can access both persistent and local flags
			fmt.Printf("Verbose: %v\n", globalVerbose)
			fmt.Printf("Format: %s\n", localFormat)
		},
	}

	// Local flags only available to listCmd
	listCmd.Flags().StringVarP(&localFormat, "format", "f", "table", "output format")
	listCmd.Flags().IntVarP(&localLimit, "limit", "l", 10, "limit results")

	detailCmd := &cobra.Command{
		Use:   "detail [id]",
		Short: "Show item details",
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			// Can access persistent flags
			fmt.Printf("Verbose: %v\n", globalVerbose)
			// Cannot access listCmd's local flags (format, limit)
		},
	}

	rootCmd.AddCommand(listCmd)
	rootCmd.AddCommand(detailCmd)
	rootCmd.Execute()
}
```

**Flag Scope Rules**:
- **Persistent flags** propagate down the command hierarchy
- **Local flags** are only available to the command they're defined on
- Child commands inherit parent's persistent flags
- Flags can be redefined at lower levels to override behavior

**Best Practices**:
```go
// Use persistent flags for truly global settings
rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")
rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")

// Use local flags for command-specific options
listCmd.Flags().StringP("sort", "s", "name", "sort order")
listCmd.Flags().IntP("limit", "l", 10, "result limit")

// Use parent command persistent flags for related command groups
serverCmd := &cobra.Command{Use: "server"}
serverCmd.PersistentFlags().IntP("port", "p", 8080, "server port")
// All server subcommands (start, stop, status) can access --port
```

### 2. Required Flags and Validation

Cobra provides mechanisms to enforce required flags:

```go
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	username string
	password string
	email    string
	age      int
)

var registerCmd = &cobra.Command{
	Use:   "register",
	Short: "Register a new user",
	RunE: func(cmd *cobra.Command, args []string) error {
		fmt.Printf("Registering user: %s\n", username)
		return nil
	},
}

func init() {
	registerCmd.Flags().StringVarP(&username, "username", "u", "", "username (required)")
	registerCmd.Flags().StringVarP(&password, "password", "p", "", "password (required)")
	registerCmd.Flags().StringVarP(&email, "email", "e", "", "email address (required)")
	registerCmd.Flags().IntVarP(&age, "age", "a", 0, "user age")

	// Mark flags as required
	registerCmd.MarkFlagRequired("username")
	registerCmd.MarkFlagRequired("password")
	registerCmd.MarkFlagRequired("email")

	// Custom flag validation
	registerCmd.PreRunE = func(cmd *cobra.Command, args []string) error {
		// Validate email format
		if !strings.Contains(email, "@") {
			return fmt.Errorf("invalid email format: %s", email)
		}

		// Validate password strength
		if len(password) < 8 {
			return fmt.Errorf("password must be at least 8 characters")
		}

		// Validate age if provided
		if age < 0 || age > 150 {
			return fmt.Errorf("invalid age: %d", age)
		}

		return nil
	}
}
```

**Advanced Validation Patterns**:
```go
// Mutually exclusive flags
var (
	useJSON bool
	useYAML bool
)

cmd.Flags().BoolVar(&useJSON, "json", false, "output as JSON")
cmd.Flags().BoolVar(&useYAML, "yaml", false, "output as YAML")

cmd.PreRunE = func(cmd *cobra.Command, args []string) error {
	if useJSON && useYAML {
		return fmt.Errorf("cannot use both --json and --yaml")
	}
	return nil
}

// Dependent flags
var (
	enableSSL  bool
	certFile   string
	keyFile    string
)

cmd.Flags().BoolVar(&enableSSL, "ssl", false, "enable SSL")
cmd.Flags().StringVar(&certFile, "cert", "", "SSL certificate file")
cmd.Flags().StringVar(&keyFile, "key", "", "SSL key file")

cmd.PreRunE = func(cmd *cobra.Command, args []string) error {
	if enableSSL {
		if certFile == "" || keyFile == "" {
			return fmt.Errorf("--cert and --key required when --ssl is enabled")
		}
	}
	return nil
}

// Enum validation
var outputFormat string

cmd.Flags().StringVarP(&outputFormat, "format", "f", "table", "output format")

cmd.PreRunE = func(cmd *cobra.Command, args []string) error {
	validFormats := []string{"table", "json", "yaml", "csv"}
	for _, valid := range validFormats {
		if outputFormat == valid {
			return nil
		}
	}
	return fmt.Errorf("invalid format: %s (valid: %v)", outputFormat, validFormats)
}
```

### 3. Viper Integration for Configuration

Viper provides comprehensive configuration management:

```go
// cmd/root.go
package cmd

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	cfgFile string
	rootCmd = &cobra.Command{
		Use:   "myapp",
		Short: "Application with Viper configuration",
	}
)

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	// Initialize configuration before command execution
	cobra.OnInitialize(initConfig)

	// Define flags
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.myapp.yaml)")
	rootCmd.PersistentFlags().StringP("author", "a", "", "author name")
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "verbose output")

	// Bind flags to Viper
	viper.BindPFlag("author", rootCmd.PersistentFlags().Lookup("author"))
	viper.BindPFlag("verbose", rootCmd.PersistentFlags().Lookup("verbose"))

	// Set defaults
	viper.SetDefault("author", "Anonymous")
	viper.SetDefault("license", "MIT")
}

func initConfig() {
	if cfgFile != "" {
		// Use config file from flag
		viper.SetConfigFile(cfgFile)
	} else {
		// Search for config in home directory
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		viper.AddConfigPath(home)
		viper.AddConfigPath(".")
		viper.SetConfigType("yaml")
		viper.SetConfigName(".myapp")
	}

	// Read environment variables
	viper.SetEnvPrefix("MYAPP")
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	// Read config file
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}
```

**Configuration Priority** (highest to lowest):
1. Explicit flag values
2. Environment variables
3. Config file values
4. Default values

**Example Configuration File** (`~/.myapp.yaml`):
```yaml
author: "John Doe"
verbose: true
database:
  host: localhost
  port: 5432
  name: myapp_db
server:
  port: 8080
  timeout: 30s
```

**Accessing Configuration Values**:
```go
// In command Run functions
func (cmd *cobra.Command, args []string) error {
	// Get string value
	author := viper.GetString("author")

	// Get bool value
	verbose := viper.GetBool("verbose")

	// Get nested values
	dbHost := viper.GetString("database.host")
	dbPort := viper.GetInt("database.port")

	// Get duration
	timeout := viper.GetDuration("server.timeout")

	// Check if key exists
	if viper.IsSet("database.host") {
		// Use database config
	}

	return nil
}
```

### 4. Positional Arguments with Args Validators

Cobra provides sophisticated argument validation:

```go
package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

// Built-in validators
var examples = []struct {
	name      string
	cmd       *cobra.Command
	validArgs []string
}{
	{
		name: "no arguments",
		cmd: &cobra.Command{
			Use:  "version",
			Args: cobra.NoArgs,
			Run:  func(cmd *cobra.Command, args []string) {},
		},
		validArgs: []string{},
	},
	{
		name: "exact number",
		cmd: &cobra.Command{
			Use:  "copy [source] [dest]",
			Args: cobra.ExactArgs(2),
			Run:  func(cmd *cobra.Command, args []string) {},
		},
		validArgs: []string{"source.txt", "dest.txt"},
	},
	{
		name: "minimum number",
		cmd: &cobra.Command{
			Use:  "concat [files...]",
			Args: cobra.MinimumNArgs(1),
			Run:  func(cmd *cobra.Command, args []string) {},
		},
		validArgs: []string{"file1.txt", "file2.txt"},
	},
	{
		name: "maximum number",
		cmd: &cobra.Command{
			Use:  "select [options...]",
			Args: cobra.MaximumNArgs(3),
			Run:  func(cmd *cobra.Command, args []string) {},
		},
		validArgs: []string{"opt1", "opt2"},
	},
	{
		name: "range",
		cmd: &cobra.Command{
			Use:  "process [files...]",
			Args: cobra.RangeArgs(1, 5),
			Run:  func(cmd *cobra.Command, args []string) {},
		},
		validArgs: []string{"file.txt"},
	},
}

// Custom validators
var copyCmd = &cobra.Command{
	Use:   "copy [source] [dest]",
	Short: "Copy file with validation",
	Args: func(cmd *cobra.Command, args []string) error {
		// Validate argument count
		if len(args) != 2 {
			return fmt.Errorf("requires exactly 2 arguments: source and destination")
		}

		// Validate source file exists
		source := args[0]
		if _, err := os.Stat(source); os.IsNotExist(err) {
			return fmt.Errorf("source file does not exist: %s", source)
		}

		// Validate destination is not a directory
		dest := args[1]
		if info, err := os.Stat(dest); err == nil && info.IsDir() {
			return fmt.Errorf("destination cannot be a directory: %s", dest)
		}

		return nil
	},
	RunE: func(cmd *cobra.Command, args []string) error {
		source, dest := args[0], args[1]
		fmt.Printf("Copying %s to %s\n", source, dest)
		return nil
	},
}

// Combining validators
func validFileExtension(extensions []string) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		if len(args) != 1 {
			return fmt.Errorf("requires exactly one file argument")
		}

		file := args[0]
		ext := filepath.Ext(file)

		for _, validExt := range extensions {
			if ext == validExt {
				return nil
			}
		}

		return fmt.Errorf("invalid file extension: %s (valid: %v)", ext, extensions)
	}
}

var processCmd = &cobra.Command{
	Use:   "process [file]",
	Short: "Process JSON or YAML file",
	Args:  validFileExtension([]string{".json", ".yaml", ".yml"}),
	RunE: func(cmd *cobra.Command, args []string) error {
		file := args[0]
		fmt.Printf("Processing file: %s\n", file)
		return nil
	},
}

// Composing validators
func composeValidators(validators ...cobra.PositionalArgs) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		for _, validator := range validators {
			if err := validator(cmd, args); err != nil {
				return err
			}
		}
		return nil
	}
}

var uploadCmd = &cobra.Command{
	Use:   "upload [file]",
	Short: "Upload file with multiple validations",
	Args: composeValidators(
		cobra.ExactArgs(1),
		validFileExtension([]string{".jpg", ".png", ".gif"}),
		func(cmd *cobra.Command, args []string) error {
			// Check file size
			info, err := os.Stat(args[0])
			if err != nil {
				return err
			}
			if info.Size() > 10*1024*1024 { // 10MB
				return fmt.Errorf("file too large (max 10MB)")
			}
			return nil
		},
	),
	RunE: func(cmd *cobra.Command, args []string) error {
		file := args[0]
		fmt.Printf("Uploading file: %s\n", file)
		return nil
	},
}
```

### 5. PreRun and PostRun Hooks

Cobra provides lifecycle hooks for initialization and cleanup:

```go
package cmd

import (
	"fmt"
	"time"

	"github.com/spf13/cobra"
)

// Hook execution order:
// 1. PersistentPreRun (parent)
// 2. PreRun (current command)
// 3. Run (current command)
// 4. PostRun (current command)
// 5. PersistentPostRun (parent)

var rootCmd = &cobra.Command{
	Use:   "myapp",
	Short: "Demonstration of command hooks",
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("1. Root PersistentPreRun - runs for ALL commands")
		// Initialize global resources (database, logger, etc.)
	},
	PersistentPostRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("5. Root PersistentPostRun - cleanup for ALL commands")
		// Cleanup global resources
	},
}

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Server management commands",
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("2. Server PersistentPreRun - runs for all server subcommands")
		// Initialize server-specific resources
	},
	PersistentPostRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("4. Server PersistentPostRun - cleanup for server commands")
		// Cleanup server-specific resources
	},
}

var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Start the server",
	PreRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("3a. Start PreRun - runs before start command")
		// Command-specific validation or setup
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("3b. Start Run - main command logic")
		// Actual command implementation
	},
	PostRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("3c. Start PostRun - runs after start command")
		// Command-specific cleanup
	},
}

// Practical example: Database connection management
var (
	db *Database
)

var dbCmd = &cobra.Command{
	Use:   "db",
	Short: "Database operations",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		// Initialize database connection for all db subcommands
		var err error
		db, err = ConnectDatabase(viper.GetString("database.url"))
		if err != nil {
			return fmt.Errorf("failed to connect to database: %w", err)
		}
		return nil
	},
	PersistentPostRunE: func(cmd *cobra.Command, args []string) error {
		// Close database connection after command completes
		if db != nil {
			return db.Close()
		}
		return nil
	},
}

// Timing example
var timedCmd = &cobra.Command{
	Use: "process",
	PreRun: func(cmd *cobra.Command, args []string) {
		cmd.Annotations = make(map[string]string)
		cmd.Annotations["startTime"] = time.Now().Format(time.RFC3339)
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Processing...")
		time.Sleep(2 * time.Second)
	},
	PostRun: func(cmd *cobra.Command, args []string) {
		startTime, _ := time.Parse(time.RFC3339, cmd.Annotations["startTime"])
		duration := time.Since(startTime)
		fmt.Printf("Completed in %v\n", duration)
	},
}

// Error handling with RunE variants
var safeCmd = &cobra.Command{
	Use: "safe",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		// Return error to prevent command execution
		if !isAuthorized() {
			return fmt.Errorf("unauthorized: please login first")
		}
		return nil
	},
	RunE: func(cmd *cobra.Command, args []string) error {
		// Errors propagate properly
		if err := doSomething(); err != nil {
			return fmt.Errorf("operation failed: %w", err)
		}
		return nil
	},
	PersistentPostRunE: func(cmd *cobra.Command, args []string) error {
		// Cleanup runs even if Run fails
		return cleanup()
	},
}
```

### 6. Command Aliases

Aliases provide shortcuts and alternative command names:

```go
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// Simple aliases
var listCmd = &cobra.Command{
	Use:     "list",
	Aliases: []string{"ls", "l"},
	Short:   "List items",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Listing items...")
	},
}

// Multiple aliases for different styles
var deleteCmd = &cobra.Command{
	Use:     "delete",
	Aliases: []string{"remove", "rm", "del"},
	Short:   "Delete an item",
	Args:    cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Deleting: %s\n", args[0])
	},
}

// Git-style command shortcuts
var statusCmd = &cobra.Command{
	Use:     "status",
	Aliases: []string{"st", "stat"},
	Short:   "Show status",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Status: OK")
	},
}

var commitCmd = &cobra.Command{
	Use:     "commit",
	Aliases: []string{"ci"},
	Short:   "Commit changes",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Committing changes...")
	},
}

var checkoutCmd = &cobra.Command{
	Use:     "checkout",
	Aliases: []string{"co", "switch"},
	Short:   "Checkout branch",
	Args:    cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Checking out: %s\n", args[0])
	},
}

// All these work identically:
// $ myapp list
// $ myapp ls
// $ myapp l

// $ myapp delete file.txt
// $ myapp remove file.txt
// $ myapp rm file.txt
// $ myapp del file.txt
```

**Alias Best Practices**:
- Provide common abbreviations (list → ls, delete → rm)
- Support both full and short forms
- Match user expectations from similar tools
- Document aliases in help text
- Avoid ambiguous shortcuts that could conflict

### 7. Flag Binding and Config Files

Combine flags, config files, and environment variables:

```go
// cmd/root.go
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
	Use:   "myapp",
	Short: "Application with comprehensive configuration",
}

func init() {
	cobra.OnInitialize(initConfig)

	// Define flags
	rootCmd.PersistentFlags().StringP("host", "H", "localhost", "server host")
	rootCmd.PersistentFlags().IntP("port", "p", 8080, "server port")
	rootCmd.PersistentFlags().String("log-level", "info", "log level")
	rootCmd.PersistentFlags().Bool("debug", false, "enable debug mode")

	// Bind all flags to Viper
	viper.BindPFlag("server.host", rootCmd.PersistentFlags().Lookup("host"))
	viper.BindPFlag("server.port", rootCmd.PersistentFlags().Lookup("port"))
	viper.BindPFlag("logging.level", rootCmd.PersistentFlags().Lookup("log-level"))
	viper.BindPFlag("debug", rootCmd.PersistentFlags().Lookup("debug"))

	// Set defaults
	viper.SetDefault("server.timeout", "30s")
	viper.SetDefault("server.maxConnections", 100)
}

func initConfig() {
	// Config file paths
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("$HOME/.myapp")
	viper.AddConfigPath("/etc/myapp")

	// Environment variable support
	viper.SetEnvPrefix("MYAPP")
	viper.AutomaticEnv()

	// Read config file
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			fmt.Printf("Error reading config: %v\n", err)
		}
	}
}

var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Start the server",
	Run: func(cmd *cobra.Command, args []string) {
		// Access configuration values
		host := viper.GetString("server.host")
		port := viper.GetInt("server.port")
		logLevel := viper.GetString("logging.level")
		debug := viper.GetBool("debug")

		fmt.Printf("Starting server at %s:%d\n", host, port)
		fmt.Printf("Log level: %s, Debug: %v\n", logLevel, debug)
	},
}
```

**Configuration Priority Example**:
```yaml
# config.yaml
server:
  host: production.example.com
  port: 443
  timeout: 60s
logging:
  level: warn
  format: json
```

```bash
# Configuration resolution (highest priority first):

# 1. Explicit flag
$ myapp start --port 9000
# Uses: port=9000

# 2. Environment variable
$ MYAPP_SERVER_PORT=9000 myapp start
# Uses: port=9000

# 3. Config file
$ myapp start
# Uses: port=443 (from config.yaml)

# 4. Default value
$ myapp start
# Uses: port=8080 (if no config file)
```

### 8. Git-Style CLI Pattern

Build CLI tools that follow git's command structure:

```go
// cmd/root.go
package cmd

import (
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
	Use:   "taskctl",
	Short: "A git-style task management CLI",
	Long: `TaskCtl manages tasks using familiar git-like commands.

Commands are organized hierarchically with persistent configuration
and sensible defaults.`,
}

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	cobra.OnInitialize(initConfig)

	// Global flags
	rootCmd.PersistentFlags().StringP("config", "c", "", "config file")
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "verbose output")
	rootCmd.PersistentFlags().String("format", "table", "output format (table/json/yaml)")

	viper.BindPFlag("verbose", rootCmd.PersistentFlags().Lookup("verbose"))
	viper.BindPFlag("format", rootCmd.PersistentFlags().Lookup("format"))
}

func initConfig() {
	viper.SetConfigName(".taskctl")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("$HOME")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()
	viper.SetEnvPrefix("TASKCTL")
	viper.ReadInConfig()
}

// cmd/add.go - Simple command
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var addCmd = &cobra.Command{
	Use:     "add [description]",
	Aliases: []string{"a", "create"},
	Short:   "Add a new task",
	Args:    cobra.MinimumNArgs(1),
	Example: `  taskctl add "Complete documentation"
  taskctl add "Review PR" --priority high
  taskctl a "Quick task"`,
	RunE: func(cmd *cobra.Command, args []string) error {
		description := strings.Join(args, " ")
		priority, _ := cmd.Flags().GetString("priority")

		fmt.Printf("Adding task: %s (priority: %s)\n", description, priority)
		return nil
	},
}

func init() {
	rootCmd.AddCommand(addCmd)
	addCmd.Flags().StringP("priority", "p", "medium", "task priority")
	addCmd.Flags().StringSliceP("tags", "t", []string{}, "task tags")
}

// cmd/config.go - Parent command with subcommands
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var configCmd = &cobra.Command{
	Use:   "config",
	Short: "Manage configuration",
}

var configSetCmd = &cobra.Command{
	Use:   "set [key] [value]",
	Short: "Set configuration value",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		key, value := args[0], args[1]
		viper.Set(key, value)
		if err := viper.WriteConfig(); err != nil {
			return fmt.Errorf("failed to write config: %w", err)
		}
		fmt.Printf("Set %s = %s\n", key, value)
		return nil
	},
}

var configGetCmd = &cobra.Command{
	Use:   "get [key]",
	Short: "Get configuration value",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		key := args[0]
		value := viper.Get(key)
		fmt.Printf("%s = %v\n", key, value)
	},
}

var configListCmd = &cobra.Command{
	Use:     "list",
	Aliases: []string{"ls"},
	Short:   "List all configuration",
	Run: func(cmd *cobra.Command, args []string) {
		settings := viper.AllSettings()
		for key, value := range settings {
			fmt.Printf("%s = %v\n", key, value)
		}
	},
}

func init() {
	rootCmd.AddCommand(configCmd)
	configCmd.AddCommand(configSetCmd)
	configCmd.AddCommand(configGetCmd)
	configCmd.AddCommand(configListCmd)
}
```

**Usage Examples**:
```bash
# Add tasks
$ taskctl add "Complete documentation" --priority high
$ taskctl a "Quick task"  # Using alias

# Configure defaults
$ taskctl config set default.priority high
$ taskctl config get default.priority
$ taskctl config list

# List tasks with formatting
$ taskctl list --format json
$ taskctl ls  # Using alias

# Use persistent flags
$ taskctl --verbose list
$ taskctl -v ls  # Short form
```

## Practical Examples

### Example 1: Database Management CLI

```go
package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func main() {
	var cfgFile string

	rootCmd := &cobra.Command{
		Use:   "dbctl",
		Short: "Database management tool",
	}

	cobra.OnInitialize(func() {
		if cfgFile != "" {
			viper.SetConfigFile(cfgFile)
		} else {
			viper.SetConfigName(".dbctl")
			viper.AddConfigPath("$HOME")
		}
		viper.AutomaticEnv()
		viper.ReadInConfig()
	})

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")
	rootCmd.PersistentFlags().String("host", "localhost", "database host")
	rootCmd.PersistentFlags().Int("port", 5432, "database port")
	rootCmd.PersistentFlags().String("user", "postgres", "database user")

	viper.BindPFlag("db.host", rootCmd.PersistentFlags().Lookup("host"))
	viper.BindPFlag("db.port", rootCmd.PersistentFlags().Lookup("port"))
	viper.BindPFlag("db.user", rootCmd.PersistentFlags().Lookup("user"))

	// Connect command
	connectCmd := &cobra.Command{
		Use:   "connect [database]",
		Short: "Connect to database",
		Args:  cobra.ExactArgs(1),
		PreRunE: func(cmd *cobra.Command, args []string) error {
			// Validate required configuration
			if viper.GetString("db.host") == "" {
				return fmt.Errorf("database host required")
			}
			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			database := args[0]
			host := viper.GetString("db.host")
			port := viper.GetInt("db.port")
			user := viper.GetString("db.user")

			fmt.Printf("Connecting to %s@%s:%d/%s\n", user, host, port, database)
			return nil
		},
	}

	// Migrate command with subcommands
	migrateCmd := &cobra.Command{
		Use:   "migrate",
		Short: "Database migration operations",
	}

	migrateUpCmd := &cobra.Command{
		Use:   "up",
		Short: "Apply migrations",
		RunE: func(cmd *cobra.Command, args []string) error {
			steps, _ := cmd.Flags().GetInt("steps")
			fmt.Printf("Applying %d migration(s)\n", steps)
			return nil
		},
	}
	migrateUpCmd.Flags().IntP("steps", "n", 0, "number of migrations to apply (0 = all)")

	migrateDownCmd := &cobra.Command{
		Use:   "down",
		Short: "Rollback migrations",
		PreRunE: func(cmd *cobra.Command, args []string) error {
			force, _ := cmd.Flags().GetBool("force")
			if !force {
				return fmt.Errorf("rollback requires --force flag")
			}
			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			steps, _ := cmd.Flags().GetInt("steps")
			fmt.Printf("Rolling back %d migration(s)\n", steps)
			return nil
		},
	}
	migrateDownCmd.Flags().IntP("steps", "n", 1, "number of migrations to rollback")
	migrateDownCmd.Flags().Bool("force", false, "force rollback without confirmation")
	migrateDownCmd.MarkFlagRequired("force")

	migrateCmd.AddCommand(migrateUpCmd)
	migrateCmd.AddCommand(migrateDownCmd)

	rootCmd.AddCommand(connectCmd)
	rootCmd.AddCommand(migrateCmd)

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
```

### Example 2: API Client CLI

```go
package main

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "apicli",
		Short: "API client with authentication",
	}

	cobra.OnInitialize(func() {
		viper.SetConfigName(".apicli")
		viper.AddConfigPath("$HOME")
		viper.AutomaticEnv()
		viper.SetEnvPrefix("API")
		viper.ReadInConfig()
	})

	rootCmd.PersistentFlags().String("token", "", "API token")
	rootCmd.PersistentFlags().String("base-url", "https://api.example.com", "base URL")
	viper.BindPFlag("auth.token", rootCmd.PersistentFlags().Lookup("token"))
	viper.BindPFlag("api.baseURL", rootCmd.PersistentFlags().Lookup("base-url"))

	// Authentication check in PreRun
	rootCmd.PersistentPreRunE = func(cmd *cobra.Command, args []string) error {
		// Skip auth check for login command
		if cmd.Name() == "login" {
			return nil
		}

		token := viper.GetString("auth.token")
		if token == "" {
			return fmt.Errorf("authentication required: run 'apicli login' first")
		}
		return nil
	}

	loginCmd := &cobra.Command{
		Use:   "login",
		Short: "Authenticate with API",
		RunE: func(cmd *cobra.Command, args []string) error {
			username, _ := cmd.Flags().GetString("username")
			password, _ := cmd.Flags().GetString("password")

			// Simulate authentication
			token := "generated-token-12345"

			viper.Set("auth.token", token)
			if err := viper.WriteConfig(); err != nil {
				viper.SafeWriteConfig()
			}

			fmt.Println("Login successful")
			return nil
		},
	}
	loginCmd.Flags().StringP("username", "u", "", "username")
	loginCmd.Flags().StringP("password", "p", "", "password")
	loginCmd.MarkFlagRequired("username")
	loginCmd.MarkFlagRequired("password")

	getCmd := &cobra.Command{
		Use:   "get [resource] [id]",
		Short: "Get resource by ID",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			resource, id := args[0], args[1]
			baseURL := viper.GetString("api.baseURL")
			token := viper.GetString("auth.token")

			fmt.Printf("GET %s/%s/%s\n", baseURL, resource, id)
			fmt.Printf("Authorization: Bearer %s\n", token)
			return nil
		},
	}

	rootCmd.AddCommand(loginCmd)
	rootCmd.AddCommand(getCmd)
	rootCmd.Execute()
}
```

## Practice Challenges

### Challenge 1: Git-Style Version Control CLI

**Objective**: Build a CLI with git-like commands and persistent configuration.

**Requirements**:
1. Commands: `init`, `add`, `commit`, `status`, `config`
2. Persistent flags: `--verbose`, `--config`
3. Config subcommands: `config set`, `config get`, `config list`
4. Required flags: commit requires `--message`
5. Aliases: `st` for status, `ci` for commit
6. Use Viper for configuration persistence

**Test Requirements**:
```go
func TestGitCLI(t *testing.T) {
	tests := []struct {
		name       string
		args       []string
		setupFunc  func() error
		wantErr    bool
		errContains string
		validate   func(*testing.T, string)
	}{
		{
			name:    "init creates repository",
			args:    []string{"init"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "Initialized") {
					t.Error("should confirm initialization")
				}
			},
		},
		{
			name:        "commit requires message",
			args:        []string{"commit"},
			wantErr:     true,
			errContains: "message",
		},
		{
			name:    "commit with message",
			args:    []string{"commit", "--message", "Initial commit"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "Initial commit") {
					t.Error("should include commit message")
				}
			},
		},
		{
			name:    "status alias works",
			args:    []string{"st"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "status") {
					t.Error("alias should execute status command")
				}
			},
		},
		{
			name:    "config set and get",
			args:    []string{"config", "set", "user.name", "John Doe"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				// Verify value was set
				output2, _ := executeCommand(rootCmd, "config", "get", "user.name")
				if !strings.Contains(output2, "John Doe") {
					t.Error("config should persist value")
				}
			},
		},
		{
			name:    "verbose flag affects all commands",
			args:    []string{"--verbose", "status"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "verbose") {
					t.Error("should show verbose output")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

### Challenge 2: Server Management CLI

**Objective**: Create a CLI for managing application servers with lifecycle hooks.

**Requirements**:
1. Parent command: `server` with subcommands: `start`, `stop`, `restart`, `status`
2. PersistentPreRun: Check server installation
3. PreRun for start: Validate port availability
4. PostRun for stop: Cleanup temporary files
5. Flags: `--port`, `--config`, `--daemon`
6. Required flag validation
7. Custom argument validators

**Test Requirements**:
```go
func TestServerCLI(t *testing.T) {
	tests := []struct {
		name         string
		args         []string
		preRun       func() error
		postRun      func() error
		wantErr      bool
		validate     func(*testing.T, string, error)
	}{
		{
			name: "start validates port range",
			args: []string{"server", "start", "--port", "99999"},
			wantErr: true,
			validate: func(t *testing.T, output string, err error) {
				if !strings.Contains(err.Error(), "port") {
					t.Error("should validate port range")
				}
			},
		},
		{
			name: "start requires config file",
			args: []string{"server", "start"},
			wantErr: true,
			validate: func(t *testing.T, output string, err error) {
				if !strings.Contains(err.Error(), "config") {
					t.Error("should require config file")
				}
			},
		},
		{
			name: "start with valid configuration",
			args: []string{"server", "start", "--port", "8080", "--config", "test.yaml"},
			preRun: func() error {
				return os.WriteFile("test.yaml", []byte("server: config"), 0644)
			},
			postRun: func() error {
				return os.Remove("test.yaml")
			},
			wantErr: false,
			validate: func(t *testing.T, output string, err error) {
				if !strings.Contains(output, "8080") {
					t.Error("should start on specified port")
				}
			},
		},
		{
			name: "stop cleans up resources",
			args: []string{"server", "stop"},
			preRun: func() error {
				return os.WriteFile("server.pid", []byte("12345"), 0644)
			},
			wantErr: false,
			validate: func(t *testing.T, output string, err error) {
				if _, err := os.Stat("server.pid"); !os.IsNotExist(err) {
					t.Error("should cleanup PID file")
				}
			},
		},
		{
			name: "restart combines stop and start",
			args: []string{"server", "restart", "--port", "8080", "--config", "test.yaml"},
			preRun: func() error {
				return os.WriteFile("test.yaml", []byte("server: config"), 0644)
			},
			postRun: func() error {
				return os.Remove("test.yaml")
			},
			wantErr: false,
			validate: func(t *testing.T, output string, err error) {
				if !strings.Contains(output, "Stopping") || !strings.Contains(output, "Starting") {
					t.Error("restart should stop then start")
				}
			},
		},
		{
			name: "status shows server state",
			args: []string{"server", "status"},
			wantErr: false,
			validate: func(t *testing.T, output string, err error) {
				if !strings.Contains(output, "Status:") {
					t.Error("should display status information")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

### Challenge 3: Project Generator CLI

**Objective**: Build a CLI that generates project scaffolding with comprehensive validation.

**Requirements**:
1. Commands: `new [project-name]`, `template list`, `template add`
2. Argument validation: project name must be valid directory name
3. Required flags: `--template`, `--author`
4. Optional flags with defaults: `--license`, `--git-init`
5. Interactive mode: prompt for missing required flags
6. PreRun: Validate template exists
7. PostRun: Display next steps

**Example Usage**:
```bash
$ projgen new myapp --template golang --author "John Doe" --license MIT
$ projgen template list
$ projgen template add custom-template ./template-dir
```

**Test Requirements**:
```go
func TestProjectGenerator(t *testing.T) {
	tests := []struct {
		name         string
		args         []string
		setupFunc    func() error
		cleanupFunc  func() error
		wantErr      bool
		errorMessage string
		validate     func(*testing.T, string)
	}{
		{
			name:         "new requires project name",
			args:         []string{"new"},
			wantErr:      true,
			errorMessage: "requires exactly 1 arg",
		},
		{
			name:    "new with invalid project name",
			args:    []string{"new", "invalid project name!"},
			wantErr: true,
			errorMessage: "invalid project name",
		},
		{
			name:         "new requires template flag",
			args:         []string{"new", "myapp"},
			wantErr:      true,
			errorMessage: "template",
		},
		{
			name: "new creates project structure",
			args: []string{"new", "myapp", "--template", "golang", "--author", "John Doe"},
			cleanupFunc: func() error {
				return os.RemoveAll("myapp")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if _, err := os.Stat("myapp"); os.IsNotExist(err) {
					t.Error("should create project directory")
				}
				if !strings.Contains(output, "Successfully created") {
					t.Error("should confirm creation")
				}
			},
		},
		{
			name: "new with git-init flag",
			args: []string{"new", "myapp", "--template", "golang", "--author", "John", "--git-init"},
			cleanupFunc: func() error {
				return os.RemoveAll("myapp")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if _, err := os.Stat("myapp/.git"); os.IsNotExist(err) {
					t.Error("should initialize git repository")
				}
			},
		},
		{
			name:    "template list shows available templates",
			args:    []string{"template", "list"},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				templates := []string{"golang", "python", "nodejs"}
				for _, tmpl := range templates {
					if !strings.Contains(output, tmpl) {
						t.Errorf("should list %s template", tmpl)
					}
				}
			},
		},
		{
			name: "template add with custom template",
			args: []string{"template", "add", "custom", "./testdata/template"},
			setupFunc: func() error {
				return os.MkdirAll("./testdata/template", 0755)
			},
			cleanupFunc: func() error {
				return os.RemoveAll("./testdata")
			},
			wantErr: false,
			validate: func(t *testing.T, output string) {
				if !strings.Contains(output, "custom") {
					t.Error("should add custom template")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

## Common Pitfalls

### 1. Not Using RunE for Error Handling

**❌ Wrong**:
```go
var cmd = &cobra.Command{
	Use: "process",
	Run: func(cmd *cobra.Command, args []string) {
		if err := doSomething(); err != nil {
			fmt.Println("Error:", err)
			// Exit code is still 0!
		}
	},
}
```

**✅ Correct**:
```go
var cmd = &cobra.Command{
	Use: "process",
	RunE: func(cmd *cobra.Command, args []string) error {
		if err := doSomething(); err != nil {
			return fmt.Errorf("processing failed: %w", err)
		}
		return nil
	},
}
```

### 2. Incorrect Flag Binding Order

**❌ Wrong**:
```go
func init() {
	// Binding before flag is defined
	viper.BindPFlag("port", rootCmd.PersistentFlags().Lookup("port"))

	rootCmd.PersistentFlags().IntP("port", "p", 8080, "server port")
	// Binding returns nil if flag doesn't exist yet!
}
```

**✅ Correct**:
```go
func init() {
	// Define flag first
	rootCmd.PersistentFlags().IntP("port", "p", 8080, "server port")

	// Then bind to Viper
	viper.BindPFlag("port", rootCmd.PersistentFlags().Lookup("port"))
}
```

### 3. Forgetting Hook Execution Order

**❌ Wrong**:
```go
var rootCmd = &cobra.Command{
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		fmt.Println("Root pre-run")
	},
}

var subCmd = &cobra.Command{
	PreRun: func(cmd *cobra.Command, args []string) {
		// This runs AFTER parent's PersistentPreRun
		// but might expect global setup from Root's PreRun
		fmt.Println("Sub pre-run")
	},
}
```

**✅ Correct**:
```go
var rootCmd = &cobra.Command{
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		// Global setup runs first for ALL commands
		initGlobalResources()
	},
}

var subCmd = &cobra.Command{
	PreRun: func(cmd *cobra.Command, args []string) {
		// Command-specific setup runs after global
		initCommandResources()
	},
}
```

### 4. Not Checking Viper Config Read Errors

**❌ Wrong**:
```go
func initConfig() {
	viper.SetConfigFile(cfgFile)
	viper.ReadInConfig() // Ignoring errors
	// Silently fails if config has syntax errors
}
```

**✅ Correct**:
```go
func initConfig() {
	viper.SetConfigFile(cfgFile)

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// Config file not found; using defaults
		} else {
			// Config file found but has errors
			fmt.Fprintf(os.Stderr, "Error reading config: %v\n", err)
			os.Exit(1)
		}
	}
}
```

### 5. Overusing Persistent Flags

**❌ Wrong**:
```go
// Making everything persistent unnecessarily
rootCmd.PersistentFlags().StringP("output", "o", "table", "output format")
rootCmd.PersistentFlags().IntP("limit", "l", 10, "result limit")
rootCmd.PersistentFlags().StringP("sort", "s", "name", "sort order")

// Not all commands need these flags!
```

**✅ Correct**:
```go
// Only truly global flags as persistent
rootCmd.PersistentFlags().BoolP("verbose", "v", false, "verbose output")
rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")

// Command-specific flags as local
listCmd.Flags().StringP("output", "o", "table", "output format")
listCmd.Flags().IntP("limit", "l", 10, "result limit")
listCmd.Flags().StringP("sort", "s", "name", "sort order")
```

### 6. Missing Required Flag Documentation

**❌ Wrong**:
```go
cmd.Flags().StringP("file", "f", "", "input file")
cmd.MarkFlagRequired("file")

// Help text doesn't indicate it's required
```

**✅ Correct**:
```go
cmd.Flags().StringP("file", "f", "", "input file (required)")
cmd.MarkFlagRequired("file")

// Or in Long description:
cmd.Long = `Process the specified input file.

The --file flag is required and must point to a valid JSON or YAML file.`
```

## Extension Challenges

### 1. Shell Completion

Add shell completion support:
- Generate completion scripts for bash, zsh, fish
- Support flag completion
- Support dynamic value completion (e.g., available files)
- Add completion for custom types

### 2. Configuration Migration

Implement config version migration:
- Detect old config format versions
- Automatically migrate to new format
- Backup old config before migration
- Provide rollback capability

### 3. Plugin System with Configuration

Build a plugin system:
- Load plugins from configuration
- Pass configuration to plugins
- Allow plugins to register commands
- Validate plugin compatibility

### 4. Interactive Configuration Wizard

Create interactive setup:
- Prompt for all required configuration
- Validate input in real-time
- Show current values for editing
- Generate configuration file from answers

### 5. Remote Configuration

Add remote config support:
- Fetch configuration from remote URL
- Cache remote config locally
- Support config updates via API
- Implement config synchronization

## Learning Resources

### Official Documentation
- [Cobra Documentation](https://cobra.dev/)
- [Viper Documentation](https://github.com/spf13/viper)
- [Flag Package Documentation](https://pkg.go.dev/github.com/spf13/pflag)

### Code Examples
- [kubectl Commands](https://github.com/kubernetes/kubectl/tree/master/pkg/cmd) - Complex command structure
- [Hugo Commands](https://github.com/gohugoio/hugo/tree/master/commands) - Cobra + Viper integration
- [GitHub CLI](https://github.com/cli/cli/tree/trunk/pkg/cmd) - Modern CLI patterns

### Tutorials and Articles
- "Advanced Cobra Patterns" - Command lifecycle
- "Cobra and Viper Integration" - Configuration management
- "Testing Cobra Applications" - Testing strategies

### Related Tools
- [Survey](https://github.com/AlecAivazis/survey) - Interactive prompts
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - TUI framework
- [Lipgloss](https://github.com/charmbracelet/lipgloss) - Terminal styling

## Summary

You've mastered advanced Cobra features for professional CLI development:

**Key Achievements**:
- ✅ Implement persistent vs local flag scopes
- ✅ Add required flag validation with custom logic
- ✅ Integrate Viper for configuration management
- ✅ Use positional argument validators
- ✅ Apply command lifecycle hooks (PreRun, PostRun)
- ✅ Create command aliases and shortcuts
- ✅ Build git-style CLIs with persistent configuration
- ✅ Combine flags, config files, and environment variables

**Advanced Cobra enables**:
- Professional configuration management
- Sophisticated validation logic
- Proper resource lifecycle control
- Superior user experience with shortcuts and persistence

**Next Steps**:
- Lesson 13 applies these concepts in the Task Tracker milestone project
- Lesson 14 covers API integration for CLI tools

## Navigation

**Previous**: [Lesson 11: Cobra Framework Fundamentals](lesson-11-cobra-basics.md)
**Next**: [Lesson 13: Milestone - Task Tracker CLI](lesson-13-task-tracker.md)
**Phase Overview**: [Phase 2: Building Command-Line Tools](../README.md#phase-2)
