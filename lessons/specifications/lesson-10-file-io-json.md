# Lesson 10: File I/O & JSON Persistence

**Phase**: 2 - CLI Development
**Difficulty**: Intermediate
**Estimated Time**: 3-4 hours

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Perform file operations** using the `os` package (create, read, write, delete)
2. **Use buffered I/O** with `bufio` for efficient reading and writing
3. **Marshal and unmarshal JSON** with Go's `encoding/json` package
4. **Work with struct tags** for JSON customization (field names, omitempty)
5. **Handle file errors gracefully** with proper resource cleanup using defer
6. **Implement atomic file writes** to prevent data corruption
7. **Build configuration systems** for loading and saving application settings
8. **Work with different file formats** (JSON, CSV, plain text)

## Prerequisites

- **Required**: Completion of Lessons 01-09 (Go fundamentals + flag package)
- **Concepts**: Structs, interfaces, error handling, I/O operations
- **Tools**: Go 1.20+, text editor
- **Setup**: Understanding of file systems and paths

## Core Concepts

### 1. Basic File Operations with os Package

The `os` package provides platform-independent file operations:

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    // Create a new file
    file, err := os.Create("data.txt")
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error creating file: %v\n", err)
        return
    }
    defer file.Close()  // Always close files!

    // Write to file
    _, err = file.WriteString("Hello, File I/O!\n")
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error writing: %v\n", err)
        return
    }

    fmt.Println("File created successfully")
}
```

**Common os functions**:
```go
// Reading
data, err := os.ReadFile("config.txt")          // Read entire file
file, err := os.Open("data.txt")                // Open for reading

// Writing
err := os.WriteFile("out.txt", data, 0644)      // Write entire file
file, err := os.Create("new.txt")               // Create/truncate
file, err := os.OpenFile("log.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)

// Information
info, err := os.Stat("file.txt")                // File info
exists := !os.IsNotExist(err)                   // Check if exists

// Manipulation
err := os.Remove("temp.txt")                    // Delete file
err := os.Rename("old.txt", "new.txt")          // Rename/move
err := os.Mkdir("data", 0755)                   // Create directory
```

### 2. Buffered I/O with bufio

The `bufio` package provides buffered readers and writers for efficiency:

```go
package main

import (
    "bufio"
    "fmt"
    "os"
)

func readLines(filename string) ([]string, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    defer file.Close()

    var lines []string
    scanner := bufio.NewScanner(file)

    // Read line by line
    for scanner.Scan() {
        lines = append(lines, scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        return nil, err
    }

    return lines, nil
}

func writeLines(filename string, lines []string) error {
    file, err := os.Create(filename)
    if err != nil {
        return err
    }
    defer file.Close()

    writer := bufio.NewWriter(file)
    defer writer.Flush()  // Don't forget to flush!

    for _, line := range lines {
        _, err := writer.WriteString(line + "\n")
        if err != nil {
            return err
        }
    }

    return nil
}
```

**Scanner patterns**:
```go
scanner := bufio.NewScanner(file)

// Line by line (default)
scanner.Split(bufio.ScanLines)

// Word by word
scanner.Split(bufio.ScanWords)

// Byte by byte
scanner.Split(bufio.ScanBytes)

// Custom split function
scanner.Split(customSplitFunc)
```

### 3. JSON Encoding and Decoding

Go's `encoding/json` package provides JSON marshaling:

```go
package main

import (
    "encoding/json"
    "fmt"
    "os"
)

type Person struct {
    Name    string   `json:"name"`
    Age     int      `json:"age"`
    Email   string   `json:"email"`
    Hobbies []string `json:"hobbies"`
}

func main() {
    // Create a person
    person := Person{
        Name:    "Alice",
        Age:     30,
        Email:   "alice@example.com",
        Hobbies: []string{"reading", "hiking", "coding"},
    }

    // Marshal to JSON
    data, err := json.Marshal(person)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error marshaling: %v\n", err)
        return
    }
    fmt.Println(string(data))
    // Output: {"name":"Alice","age":30,"email":"alice@example.com","hobbies":["reading","hiking","coding"]}

    // Marshal with indentation (pretty print)
    prettyData, err := json.MarshalIndent(person, "", "  ")
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error marshaling: %v\n", err)
        return
    }
    fmt.Println(string(prettyData))
    /*
    {
      "name": "Alice",
      "age": 30,
      "email": "alice@example.com",
      "hobbies": [
        "reading",
        "hiking",
        "coding"
      ]
    }
    */

    // Unmarshal from JSON
    jsonStr := `{"name":"Bob","age":25,"email":"bob@example.com","hobbies":["gaming"]}`
    var newPerson Person
    err = json.Unmarshal([]byte(jsonStr), &newPerson)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error unmarshaling: %v\n", err)
        return
    }
    fmt.Printf("%+v\n", newPerson)
}
```

### 4. Struct Tags for JSON Customization

Struct tags control JSON field names and behavior:

```go
type User struct {
    // Exported field with custom JSON name
    ID       int    `json:"id"`
    Username string `json:"username"`

    // Omit field if zero value
    Email    string `json:"email,omitempty"`

    // Omit field entirely from JSON
    Password string `json:"-"`

    // Use embedded struct's fields
    Address  `json:"address"`

    // Optional field (pointer)
    Bio      *string `json:"bio,omitempty"`
}

type Address struct {
    Street  string `json:"street"`
    City    string `json:"city"`
    Country string `json:"country"`
}
```

**Tag options**:
- `json:"fieldname"` - Custom field name in JSON
- `json:",omitempty"` - Omit if zero value (empty string, 0, nil, false, empty slice/map)
- `json:"-"` - Never include in JSON
- `json:",string"` - Marshal numbers as strings

### 5. Reading and Writing JSON Files

Combining file I/O with JSON:

```go
package main

import (
    "encoding/json"
    "fmt"
    "os"
)

type Config struct {
    Host     string `json:"host"`
    Port     int    `json:"port"`
    Debug    bool   `json:"debug"`
    LogLevel string `json:"log_level"`
}

// LoadConfig reads and parses JSON config file
func LoadConfig(filename string) (*Config, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read config: %w", err)
    }

    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return nil, fmt.Errorf("failed to parse config: %w", err)
    }

    return &config, nil
}

// SaveConfig writes config to JSON file
func SaveConfig(filename string, config *Config) error {
    data, err := json.MarshalIndent(config, "", "  ")
    if err != nil {
        return fmt.Errorf("failed to marshal config: %w", err)
    }

    if err := os.WriteFile(filename, data, 0644); err != nil {
        return fmt.Errorf("failed to write config: %w", err)
    }

    return nil
}

func main() {
    config := &Config{
        Host:     "localhost",
        Port:     8080,
        Debug:    true,
        LogLevel: "info",
    }

    // Save config
    if err := SaveConfig("config.json", config); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        return
    }

    // Load config
    loaded, err := LoadConfig("config.json")
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        return
    }

    fmt.Printf("Loaded config: %+v\n", loaded)
}
```

### 6. Atomic File Writes

Prevent data corruption with atomic writes:

```go
package main

import (
    "fmt"
    "os"
    "path/filepath"
)

// AtomicWriteFile writes data atomically by writing to temp file first
func AtomicWriteFile(filename string, data []byte, perm os.FileMode) error {
    // Create temp file in same directory
    dir := filepath.Dir(filename)
    temp, err := os.CreateTemp(dir, "temp-*")
    if err != nil {
        return fmt.Errorf("failed to create temp file: %w", err)
    }
    tempName := temp.Name()

    // Cleanup temp file if we fail
    defer func() {
        temp.Close()
        os.Remove(tempName)
    }()

    // Write data to temp file
    if _, err := temp.Write(data); err != nil {
        return fmt.Errorf("failed to write temp file: %w", err)
    }

    // Sync to disk
    if err := temp.Sync(); err != nil {
        return fmt.Errorf("failed to sync temp file: %w", err)
    }

    // Close temp file
    if err := temp.Close(); err != nil {
        return fmt.Errorf("failed to close temp file: %w", err)
    }

    // Atomic rename (overwrites destination)
    if err := os.Rename(tempName, filename); err != nil {
        return fmt.Errorf("failed to rename temp file: %w", err)
    }

    // Set permissions
    if err := os.Chmod(filename, perm); err != nil {
        return fmt.Errorf("failed to set permissions: %w", err)
    }

    return nil
}
```

**Why atomic writes?**
- Prevents partial writes if program crashes
- Ensures readers always see complete, valid data
- Critical for configuration files and databases

### 7. Working with CSV Files

Reading and writing CSV (comma-separated values):

```go
package main

import (
    "encoding/csv"
    "fmt"
    "os"
)

type Record struct {
    Name  string
    Email string
    Age   string
}

func readCSV(filename string) ([]Record, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    defer file.Close()

    reader := csv.NewReader(file)
    records, err := reader.ReadAll()
    if err != nil {
        return nil, err
    }

    var result []Record
    for i, record := range records {
        // Skip header row
        if i == 0 {
            continue
        }

        if len(record) != 3 {
            return nil, fmt.Errorf("invalid record at line %d", i+1)
        }

        result = append(result, Record{
            Name:  record[0],
            Email: record[1],
            Age:   record[2],
        })
    }

    return result, nil
}

func writeCSV(filename string, records []Record) error {
    file, err := os.Create(filename)
    if err != nil {
        return err
    }
    defer file.Close()

    writer := csv.NewWriter(file)
    defer writer.Flush()

    // Write header
    if err := writer.Write([]string{"Name", "Email", "Age"}); err != nil {
        return err
    }

    // Write records
    for _, record := range records {
        row := []string{record.Name, record.Email, record.Age}
        if err := writer.Write(row); err != nil {
            return err
        }
    }

    return writer.Error()
}
```

### 8. Error Handling Best Practices

Proper error handling for file operations:

```go
package main

import (
    "encoding/json"
    "errors"
    "fmt"
    "os"
)

// Custom error types
var (
    ErrFileNotFound = errors.New("file not found")
    ErrInvalidJSON  = errors.New("invalid JSON format")
    ErrPermission   = errors.New("permission denied")
)

func loadData(filename string) (map[string]interface{}, error) {
    // Check if file exists
    if _, err := os.Stat(filename); os.IsNotExist(err) {
        return nil, fmt.Errorf("%w: %s", ErrFileNotFound, filename)
    }

    // Read file
    data, err := os.ReadFile(filename)
    if err != nil {
        if os.IsPermission(err) {
            return nil, fmt.Errorf("%w: %s", ErrPermission, filename)
        }
        return nil, fmt.Errorf("failed to read file: %w", err)
    }

    // Parse JSON
    var result map[string]interface{}
    if err := json.Unmarshal(data, &result); err != nil {
        return nil, fmt.Errorf("%w in %s: %w", ErrInvalidJSON, filename, err)
    }

    return result, nil
}

func main() {
    data, err := loadData("config.json")
    if err != nil {
        switch {
        case errors.Is(err, ErrFileNotFound):
            fmt.Println("Config file not found, using defaults")
            // Use default config
        case errors.Is(err, ErrPermission):
            fmt.Fprintf(os.Stderr, "Permission denied: %v\n", err)
            os.Exit(1)
        case errors.Is(err, ErrInvalidJSON):
            fmt.Fprintf(os.Stderr, "Invalid config format: %v\n", err)
            os.Exit(1)
        default:
            fmt.Fprintf(os.Stderr, "Error loading config: %v\n", err)
            os.Exit(1)
        }
    }

    fmt.Printf("Loaded config: %v\n", data)
}
```

## Challenge Description

Build three file I/O and persistence systems demonstrating different aspects of data management.

### Challenge 1: Configuration Manager

Create a configuration system that loads, validates, and saves application settings.

**Requirements**:
1. Define a `Config` struct with at least 5 different types of settings
2. Implement `LoadConfig(filename string) (*Config, error)`
3. Implement `SaveConfig(filename string, config *Config) error`
4. Use atomic writes to prevent corruption
5. Provide default config if file doesn't exist
6. Validate config values (e.g., port ranges, required fields)
7. Support environment variable overrides
8. Pretty-print JSON with 2-space indentation

**Config struct example**:
```go
type Config struct {
    Server struct {
        Host         string `json:"host"`
        Port         int    `json:"port"`
        ReadTimeout  int    `json:"read_timeout"`
        WriteTimeout int    `json:"write_timeout"`
    } `json:"server"`
    Database struct {
        Path        string `json:"path"`
        MaxConn     int    `json:"max_connections"`
        AutoBackup  bool   `json:"auto_backup"`
    } `json:"database"`
    Logging struct {
        Level  string `json:"level"`
        File   string `json:"file,omitempty"`
    } `json:"logging"`
}
```

**Example usage**:
```bash
$ go run config-manager.go load
Config loaded from config.json

$ go run config-manager.go init
Default config created: config.json

$ go run config-manager.go validate
✓ Configuration is valid
```

### Challenge 2: Simple Database

Build a simple JSON-based database for storing and querying records.

**Requirements**:
1. Define a generic `Record` struct or use `map[string]interface{}`
2. Implement CRUD operations:
   - `Create(id string, data interface{}) error`
   - `Read(id string) (interface{}, error)`
   - `Update(id string, data interface{}) error`
   - `Delete(id string) error`
   - `List() ([]interface{}, error)`
3. Use atomic writes for all modifications
4. Support filtering/querying by fields
5. Handle concurrent access (basic locking)
6. Implement backup/restore functionality
7. Add index for fast lookups (optional)

**Database structure**:
```json
{
  "users": {
    "user-1": {
      "name": "Alice",
      "email": "alice@example.com",
      "created": "2024-01-15T10:30:00Z"
    },
    "user-2": {
      "name": "Bob",
      "email": "bob@example.com",
      "created": "2024-01-16T14:20:00Z"
    }
  }
}
```

**Example usage**:
```bash
$ go run database.go create --id user-3 --name Charlie --email charlie@example.com
Created record: user-3

$ go run database.go read --id user-3
{
  "name": "Charlie",
  "email": "charlie@example.com",
  "created": "2024-01-20T09:15:00Z"
}

$ go run database.go list
Found 3 records
```

### Challenge 3: Log File Analyzer

Create a tool that parses and analyzes log files with different formats.

**Requirements**:
1. Support multiple log formats (JSON, Apache Common, Custom)
2. Parse log entries into structured data
3. Implement filtering by:
   - Date range
   - Log level (INFO, WARN, ERROR)
   - Search term
4. Generate statistics:
   - Total entries
   - Entries by level
   - Top errors
   - Time distribution
5. Export results to JSON
6. Handle large files efficiently (streaming/chunking)
7. Support compressed files (gzip) - optional

**Log format examples**:
```
# JSON format
{"timestamp":"2024-01-20T10:30:45Z","level":"ERROR","message":"Connection failed","service":"api"}

# Apache Common format
127.0.0.1 - - [20/Jan/2024:10:30:45 +0000] "GET /api/users HTTP/1.1" 200 1234

# Custom format
[2024-01-20 10:30:45] ERROR: Connection failed (api-service)
```

**Example usage**:
```bash
$ go run analyzer.go --file app.log --level ERROR
Found 45 ERROR entries

$ go run analyzer.go --file app.log --from 2024-01-20 --to 2024-01-21 --export stats.json
Analyzed 1523 entries
Statistics exported to stats.json

$ go run analyzer.go --file app.log --stats
Total entries: 1523
INFO:  1200 (78.8%)
WARN:  278  (18.2%)
ERROR: 45   (3.0%)
```

## Test Requirements

Implement comprehensive table-driven tests for all file operations.

### Test Structure Pattern

```go
package main

import (
    "os"
    "path/filepath"
    "testing"
)

func TestConfigLoad(t *testing.T) {
    tests := []struct {
        name       string
        content    string
        wantError  bool
        wantConfig *Config
    }{
        {
            name: "valid config",
            content: `{
                "server": {"host": "localhost", "port": 8080},
                "database": {"path": "./data.db", "max_connections": 10}
            }`,
            wantError: false,
            wantConfig: &Config{
                Server: ServerConfig{
                    Host: "localhost",
                    Port: 8080,
                },
                Database: DatabaseConfig{
                    Path:    "./data.db",
                    MaxConn: 10,
                },
            },
        },
        {
            name:      "invalid JSON",
            content:   `{invalid json`,
            wantError: true,
        },
        {
            name:      "empty file",
            content:   "",
            wantError: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Create temp file
            tmpfile := filepath.Join(t.TempDir(), "config.json")
            if err := os.WriteFile(tmpfile, []byte(tt.content), 0644); err != nil {
                t.Fatal(err)
            }

            // Test load
            config, err := LoadConfig(tmpfile)
            if (err != nil) != tt.wantError {
                t.Errorf("LoadConfig() error = %v, wantError %v", err, tt.wantError)
                return
            }

            if !tt.wantError && !configsEqual(config, tt.wantConfig) {
                t.Errorf("LoadConfig() = %+v, want %+v", config, tt.wantConfig)
            }
        })
    }
}

func TestAtomicWrite(t *testing.T) {
    tmpDir := t.TempDir()
    filename := filepath.Join(tmpDir, "test.txt")

    tests := []struct {
        name    string
        data    []byte
        wantErr bool
    }{
        {"write data", []byte("hello world"), false},
        {"write empty", []byte(""), false},
        {"write large", make([]byte, 1024*1024), false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := AtomicWriteFile(filename, tt.data, 0644)
            if (err != nil) != tt.wantErr {
                t.Errorf("AtomicWriteFile() error = %v, wantErr %v", err, tt.wantErr)
                return
            }

            if !tt.wantErr {
                got, err := os.ReadFile(filename)
                if err != nil {
                    t.Fatal(err)
                }
                if string(got) != string(tt.data) {
                    t.Errorf("File content mismatch")
                }
            }
        })
    }
}
```

### Required Test Cases

**For Config Manager**:
1. Load valid config
2. Load with missing file (use defaults)
3. Load with invalid JSON
4. Save config successfully
5. Atomic write prevents corruption
6. Validation catches invalid values
7. Environment variable overrides

**For Simple Database**:
1. Create new record
2. Read existing record
3. Update record
4. Delete record
5. List all records
6. Concurrent access handling
7. Backup and restore

**For Log Analyzer**:
1. Parse each log format correctly
2. Filter by date range
3. Filter by log level
4. Calculate statistics accurately
5. Handle empty files
6. Handle malformed lines
7. Large file processing

## Input/Output Specifications

### Config Manager

**config.json example**:
```json
{
  "server": {
    "host": "localhost",
    "port": 8080,
    "read_timeout": 30,
    "write_timeout": 30
  },
  "database": {
    "path": "./data.db",
    "max_connections": 10,
    "auto_backup": true
  },
  "logging": {
    "level": "info",
    "file": "app.log"
  }
}
```

### Simple Database

**database.json structure**:
```json
{
  "collection_name": {
    "record_id": {
      "field1": "value1",
      "field2": "value2",
      "created_at": "2024-01-20T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  }
}
```

### Log Analyzer

**stats.json output**:
```json
{
  "total_entries": 1523,
  "by_level": {
    "INFO": 1200,
    "WARN": 278,
    "ERROR": 45
  },
  "date_range": {
    "start": "2024-01-20T00:00:00Z",
    "end": "2024-01-21T23:59:59Z"
  },
  "top_errors": [
    {"message": "Connection timeout", "count": 15},
    {"message": "Database lock", "count": 12},
    {"message": "Invalid request", "count": 8}
  ]
}
```

## Success Criteria

### Functional Requirements
- [ ] All file operations handle errors gracefully
- [ ] JSON marshaling/unmarshaling works correctly
- [ ] Config system loads, validates, and saves settings
- [ ] Database implements full CRUD operations
- [ ] Log analyzer parses multiple formats
- [ ] Atomic writes prevent data corruption
- [ ] Files are always properly closed (use defer)

### Code Quality Requirements
- [ ] All exported functions have documentation
- [ ] Error messages are descriptive and helpful
- [ ] Use `fmt.Errorf` with `%w` for error wrapping
- [ ] Proper use of defer for cleanup
- [ ] No hardcoded file paths (use parameters)
- [ ] Permissions set appropriately (0644 for files, 0755 for dirs)

### Testing Requirements
- [ ] Table-driven tests for all major functions
- [ ] Tests use `t.TempDir()` for temporary files
- [ ] Edge cases covered (empty files, invalid JSON)
- [ ] Error conditions tested explicitly
- [ ] Test cleanup (temp files removed)
- [ ] Test coverage >80%

### File I/O Best Practices
- [ ] Use `defer file.Close()` immediately after opening
- [ ] Check errors from `Close()` when writing
- [ ] Use atomic writes for critical data
- [ ] Validate data before writing
- [ ] Use appropriate file permissions
- [ ] Handle platform differences (path separators)

## Common Pitfalls

### Pitfall 1: Forgetting to Close Files

❌ **Wrong**: File descriptor leak
```go
func readFile(filename string) ([]byte, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    // Missing file.Close()!
    return io.ReadAll(file)
}
```

✅ **Correct**: Always defer Close()
```go
func readFile(filename string) ([]byte, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    defer file.Close()  // Guaranteed to close
    return io.ReadAll(file)
}
```

### Pitfall 2: Not Checking Close() Error When Writing

❌ **Wrong**: Silent data loss
```go
func writeData(filename string, data []byte) error {
    file, err := os.Create(filename)
    if err != nil {
        return err
    }
    defer file.Close()  // Error ignored!

    _, err = file.Write(data)
    return err
}
```

✅ **Correct**: Check Close() error for writes
```go
func writeData(filename string, data []byte) error {
    file, err := os.Create(filename)
    if err != nil {
        return err
    }

    // Write data
    _, err = file.Write(data)
    if err != nil {
        file.Close()
        return err
    }

    // Check close error
    if err := file.Close(); err != nil {
        return err
    }

    return nil
}
```

### Pitfall 3: Not Using Atomic Writes for Critical Data

❌ **Wrong**: Partial writes on crash
```go
func saveConfig(filename string, config *Config) error {
    data, _ := json.MarshalIndent(config, "", "  ")
    return os.WriteFile(filename, data, 0644)
    // If crash during write, file corrupted!
}
```

✅ **Correct**: Atomic write pattern
```go
func saveConfig(filename string, config *Config) error {
    data, err := json.MarshalIndent(config, "", "  ")
    if err != nil {
        return err
    }
    return AtomicWriteFile(filename, data, 0644)
}
```

### Pitfall 4: Forgetting to Flush Buffered Writers

❌ **Wrong**: Data lost in buffer
```go
func writeLines(filename string, lines []string) error {
    file, _ := os.Create(filename)
    defer file.Close()

    writer := bufio.NewWriter(file)
    // Missing writer.Flush()!

    for _, line := range lines {
        writer.WriteString(line + "\n")
    }

    return nil
}
```

✅ **Correct**: Always flush buffered writers
```go
func writeLines(filename string, lines []string) error {
    file, err := os.Create(filename)
    if err != nil {
        return err
    }
    defer file.Close()

    writer := bufio.NewWriter(file)
    defer writer.Flush()  // Ensure all data written

    for _, line := range lines {
        if _, err := writer.WriteString(line + "\n"); err != nil {
            return err
        }
    }

    return nil
}
```

### Pitfall 5: Unmarshaling Without Checking Errors

❌ **Wrong**: Silent parsing failures
```go
func loadConfig(filename string) *Config {
    data, _ := os.ReadFile(filename)
    var config Config
    json.Unmarshal(data, &config)  // Error ignored!
    return &config
}
```

✅ **Correct**: Check all errors
```go
func loadConfig(filename string) (*Config, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read config: %w", err)
    }

    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return nil, fmt.Errorf("failed to parse config: %w", err)
    }

    return &config, nil
}
```

### Pitfall 6: Using Absolute Paths in Tests

❌ **Wrong**: Tests fail on different machines
```go
func TestLoadConfig(t *testing.T) {
    config, err := LoadConfig("/tmp/config.json")
    // Hardcoded path, not portable!
}
```

✅ **Correct**: Use t.TempDir() for tests
```go
func TestLoadConfig(t *testing.T) {
    tmpDir := t.TempDir()  // Automatic cleanup
    configFile := filepath.Join(tmpDir, "config.json")

    // Create test config
    testData := []byte(`{"host":"localhost"}`)
    os.WriteFile(configFile, testData, 0644)

    config, err := LoadConfig(configFile)
    // Test assertions...
}
```

## Extension Challenges

### Extension 1: Add Config File Watching
Reload configuration when file changes:
```go
import "github.com/fsnotify/fsnotify"

func watchConfig(filename string, onChange func(*Config)) error {
    watcher, err := fsnotify.NewWatcher()
    if err != nil {
        return err
    }
    defer watcher.Close()

    if err := watcher.Add(filename); err != nil {
        return err
    }

    for {
        select {
        case event := <-watcher.Events:
            if event.Op&fsnotify.Write == fsnotify.Write {
                config, _ := LoadConfig(filename)
                onChange(config)
            }
        case err := <-watcher.Errors:
            return err
        }
    }
}
```

### Extension 2: Implement Database Transactions
Add transaction support with rollback:
```go
type Transaction struct {
    db       *Database
    changes  map[string]interface{}
    original map[string]interface{}
}

func (db *Database) Begin() *Transaction {
    return &Transaction{
        db:       db,
        changes:  make(map[string]interface{}),
        original: db.clone(),
    }
}

func (tx *Transaction) Commit() error {
    // Apply all changes atomically
    return tx.db.applyChanges(tx.changes)
}

func (tx *Transaction) Rollback() {
    // Restore original state
    tx.db.restore(tx.original)
}
```

### Extension 3: Add Compression Support
Automatically compress/decompress large files:
```go
import (
    "compress/gzip"
    "io"
)

func writeCompressed(filename string, data []byte) error {
    file, err := os.Create(filename + ".gz")
    if err != nil {
        return err
    }
    defer file.Close()

    gzipWriter := gzip.NewWriter(file)
    defer gzipWriter.Close()

    _, err = gzipWriter.Write(data)
    return err
}

func readCompressed(filename string) ([]byte, error) {
    file, err := os.Open(filename + ".gz")
    if err != nil {
        return nil, err
    }
    defer file.Close()

    gzipReader, err := gzip.NewReader(file)
    if err != nil {
        return nil, err
    }
    defer gzipReader.Close()

    return io.ReadAll(gzipReader)
}
```

### Extension 4: Add Schema Validation
Validate JSON against a schema:
```go
import "github.com/xeipuuv/gojsonschema"

func validateConfig(config *Config) error {
    schemaLoader := gojsonschema.NewStringLoader(`{
        "type": "object",
        "required": ["server", "database"],
        "properties": {
            "server": {
                "type": "object",
                "required": ["host", "port"]
            }
        }
    }`)

    configLoader := gojsonschema.NewGoLoader(config)

    result, err := gojsonschema.Validate(schemaLoader, configLoader)
    if err != nil {
        return err
    }

    if !result.Valid() {
        return fmt.Errorf("invalid config: %v", result.Errors())
    }

    return nil
}
```

### Extension 5: Implement File Rotation
Rotate log files by size or time:
```go
type RotatingWriter struct {
    filename    string
    maxSize     int64
    maxFiles    int
    currentSize int64
    file        *os.File
}

func (w *RotatingWriter) Write(p []byte) (n int, err error) {
    if w.currentSize+int64(len(p)) > w.maxSize {
        if err := w.rotate(); err != nil {
            return 0, err
        }
    }

    n, err = w.file.Write(p)
    w.currentSize += int64(n)
    return n, err
}

func (w *RotatingWriter) rotate() error {
    w.file.Close()

    // Rename old files: log.2 -> log.3, log.1 -> log.2
    for i := w.maxFiles - 1; i > 0; i-- {
        oldName := fmt.Sprintf("%s.%d", w.filename, i)
        newName := fmt.Sprintf("%s.%d", w.filename, i+1)
        os.Rename(oldName, newName)
    }

    // Rename current: log -> log.1
    os.Rename(w.filename, w.filename+".1")

    // Create new file
    file, err := os.Create(w.filename)
    if err != nil {
        return err
    }

    w.file = file
    w.currentSize = 0
    return nil
}
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Separation of concerns**: Split file I/O logic from business logic
2. **Testability**: Design functions to accept io.Reader/io.Writer when possible
3. **Error handling**: Always check and wrap errors with context
4. **Resource cleanup**: Use defer for all cleanup operations
5. **Atomic operations**: Use temp files for critical writes

### Code Organization

```
lesson-10/
├── config-manager/
│   ├── main.go          # CLI interface
│   ├── config.go        # Config struct and methods
│   ├── config_test.go   # Table-driven tests
│   └── atomic.go        # Atomic write utilities
├── database/
│   ├── main.go
│   ├── db.go            # Database operations
│   ├── db_test.go
│   └── lock.go          # Concurrency control
└── log-analyzer/
    ├── main.go
    ├── parser.go        # Log parsing logic
    ├── parser_test.go
    ├── stats.go         # Statistics calculation
    └── stats_test.go
```

### Quality Checklist

- [ ] All functions that open files use defer Close()
- [ ] Atomic writes used for critical data
- [ ] JSON struct tags properly defined
- [ ] Error wrapping with %w
- [ ] Tests use t.TempDir() for temporary files
- [ ] No hardcoded paths
- [ ] Proper file permissions (0644/0755)
- [ ] Buffer flushing before file close
- [ ] Documentation for all exported types/functions

### Testing Approach

Focus on testing with temporary files and in-memory buffers:

```go
func TestJSONMarshal(t *testing.T) {
    // Use in-memory for speed
    config := &Config{Host: "localhost", Port: 8080}

    data, err := json.Marshal(config)
    if err != nil {
        t.Fatal(err)
    }

    var decoded Config
    if err := json.Unmarshal(data, &decoded); err != nil {
        t.Fatal(err)
    }

    if decoded.Host != "localhost" || decoded.Port != 8080 {
        t.Errorf("roundtrip failed: %+v", decoded)
    }
}

func TestFileOperations(t *testing.T) {
    // Use temp directory
    tmpDir := t.TempDir()
    filename := filepath.Join(tmpDir, "test.json")

    // Test write
    config := &Config{Host: "localhost"}
    if err := SaveConfig(filename, config); err != nil {
        t.Fatal(err)
    }

    // Test read
    loaded, err := LoadConfig(filename)
    if err != nil {
        t.Fatal(err)
    }

    if loaded.Host != "localhost" {
        t.Errorf("expected localhost, got %s", loaded.Host)
    }
}
```

## Learning Resources

### Official Documentation
- [os package](https://pkg.go.dev/os) - File operations and system interface
- [bufio package](https://pkg.go.dev/bufio) - Buffered I/O
- [encoding/json](https://pkg.go.dev/encoding/json) - JSON encoding/decoding
- [io package](https://pkg.go.dev/io) - I/O primitives and interfaces
- [path/filepath](https://pkg.go.dev/path/filepath) - Platform-independent path manipulation

### Tutorials and Guides
- [Working with Files in Go](https://gobyexample.com/reading-files) - Go by Example
- [JSON and Go](https://go.dev/blog/json) - Official Go blog
- [Effective Go: Data](https://go.dev/doc/effective_go#data) - Data handling patterns

### Related Exercises
- [Gophercises #7: CLI Task Manager](https://gophercises.com/) - JSON persistence
- [Exercism: Error Handling](https://exercism.org/tracks/go/exercises/error-handling) - File error patterns

## Validation Commands

```bash
# Format code
go fmt ./lesson-10/...

# Run all tests
go test ./lesson-10/... -v

# Test with race detector
go test ./lesson-10/... -race

# Check coverage
go test ./lesson-10/... -cover -coverprofile=coverage.out
go tool cover -html=coverage.out

# Build all tools
cd lesson-10/config-manager && go build
cd lesson-10/database && go build
cd lesson-10/log-analyzer && go build

# Test config manager
./config-manager/config-manager init
./config-manager/config-manager load
./config-manager/config-manager validate

# Test database
./database/database create --id test-1 --name "Test User"
./database/database read --id test-1
./database/database list

# Test log analyzer
./log-analyzer/log-analyzer --file sample.log --stats
./log-analyzer/log-analyzer --file sample.log --level ERROR
```

---

**Next Lesson**: [Lesson 11: Cobra Framework Fundamentals](lesson-11-cobra-basics.md) - Industry-standard CLI framework

**Previous Lesson**: [Lesson 09: Standard Library CLI](lesson-09-stdlib-cli.md) - flag package and basic CLI patterns

**Phase Overview**: [Phase 2: CLI Development](../README.md#phase-2-cli-development-weeks-3-4) - Building command-line applications
