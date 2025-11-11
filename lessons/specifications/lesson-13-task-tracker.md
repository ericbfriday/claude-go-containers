# Lesson 13: Building a Task Tracker CLI

**Phase**: 2 - CLI Development
**Estimated Time**: 4-6 hours
**Difficulty**: Intermediate
**Type**: Milestone Project

## Learning Objectives

By the end of this lesson, learners will be able to:
- Build a complete CLI application with multiple subcommands using Cobra
- Implement CRUD operations (Create, Read, Update, Delete) for data management
- Persist data to JSON files with proper file handling
- Parse and validate command-line arguments and flags
- Structure a multi-file Go project with clear separation of concerns
- Handle errors gracefully throughout an application
- Write integration-style tests for CLI applications
- Apply Go best practices in a real-world project

## Prerequisites

- Completed Lessons 1-12 (Go fundamentals and CLI basics)
- Understanding of Cobra framework (Lesson 11-12)
- Knowledge of JSON marshaling/unmarshaling (Lesson 10)
- Experience with file I/O operations
- Familiarity with Go error handling patterns

## Core Concepts

### 1. Project Architecture

A well-structured CLI application separates concerns:

```
task-tracker/
├── cmd/
│   ├── root.go       # Root command and app initialization
│   ├── add.go        # Add subcommand
│   ├── list.go       # List subcommand
│   ├── complete.go   # Complete subcommand
│   └── delete.go     # Delete subcommand
├── internal/
│   ├── task/
│   │   ├── task.go       # Task model and business logic
│   │   └── task_test.go  # Tests for task logic
│   └── storage/
│       ├── storage.go       # File persistence layer
│       └── storage_test.go  # Tests for storage
├── main.go           # Entry point
├── go.mod
└── README.md
```

### 2. Task Model

```go
type Task struct {
    ID          int       `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description,omitempty"`
    Completed   bool      `json:"completed"`
    CreatedAt   time.Time `json:"created_at"`
    CompletedAt *time.Time `json:"completed_at,omitempty"`
}
```

### 3. Cobra Subcommands

Each operation becomes a subcommand:
```bash
task-tracker add "Buy groceries"
task-tracker list
task-tracker list --completed
task-tracker complete 1
task-tracker delete 1
```

### 4. Persistence Strategy

- Store tasks in `~/.task-tracker/tasks.json`
- Load all tasks into memory on command execution
- Modify data structure
- Write back to file (atomic write with temp file + rename)

### 5. Error Handling Pattern

Every layer returns errors up the stack:
- Storage layer: file I/O errors
- Task layer: validation errors, not found errors
- Command layer: catches errors, prints user-friendly messages

## Challenge Description

Build a complete CLI task tracker with the following features:

### Part 1: Task Model (internal/task/task.go)

Implement the task data structure and operations:

```go
// Task represents a single todo item
type Task struct {
    ID          int        `json:"id"`
    Title       string     `json:"title"`
    Description string     `json:"description,omitempty"`
    Completed   bool       `json:"completed"`
    CreatedAt   time.Time  `json:"created_at"`
    CompletedAt *time.Time `json:"completed_at,omitempty"`
}

// TaskList manages a collection of tasks
type TaskList struct {
    Tasks      []Task `json:"tasks"`
    NextID     int    `json:"next_id"`
}

// NewTaskList creates an empty task list
func NewTaskList() *TaskList

// Add adds a new task and returns its ID
func (tl *TaskList) Add(title, description string) int

// Get retrieves a task by ID
func (tl *TaskList) Get(id int) (*Task, error)

// Complete marks a task as completed
func (tl *TaskList) Complete(id int) error

// Delete removes a task
func (tl *TaskList) Delete(id int) error

// ListAll returns all tasks
func (tl *TaskList) ListAll() []Task

// ListCompleted returns only completed tasks
func (tl *TaskList) ListCompleted() []Task

// ListIncomplete returns only incomplete tasks
func (tl *TaskList) ListIncomplete() []Task
```

### Part 2: Storage Layer (internal/storage/storage.go)

Implement file persistence:

```go
// Storage handles reading/writing task data
type Storage struct {
    filePath string
}

// NewStorage creates a storage instance
// Creates directory if it doesn't exist
func NewStorage(filePath string) (*Storage, error)

// Load reads tasks from file
// Returns empty TaskList if file doesn't exist
func (s *Storage) Load() (*task.TaskList, error)

// Save writes tasks to file atomically
// Uses temp file + rename to prevent corruption
func (s *Storage) Save(tasks *task.TaskList) error
```

### Part 3: Cobra Commands

Implement subcommands using Cobra:

#### Root Command (cmd/root.go)
```go
// Root command setup
// Handles global flags (if any)
// Shows usage information
```

#### Add Command (cmd/add.go)
```bash
# Usage
task-tracker add "Task title" [description]
task-tracker add "Buy groceries"
task-tracker add "Write report" "Q4 financial report"

# Flags
--description, -d  Task description (optional, can use positional arg instead)
```

#### List Command (cmd/list.go)
```bash
# Usage
task-tracker list              # List all tasks
task-tracker list --completed  # List only completed
task-tracker list --incomplete # List only incomplete

# Flags
--completed, -c    Show only completed tasks
--incomplete, -i   Show only incomplete tasks
--verbose, -v      Show full details (including timestamps)
```

#### Complete Command (cmd/complete.go)
```bash
# Usage
task-tracker complete <id>     # Mark task as complete
task-tracker complete 1
```

#### Delete Command (cmd/delete.go)
```bash
# Usage
task-tracker delete <id>       # Delete a task
task-tracker delete 1

# Flags
--force, -f       Skip confirmation prompt
```

### Part 4: Main Program (main.go)

```go
package main

import "task-tracker/cmd"

func main() {
    cmd.Execute()
}
```

## Test Requirements

### Unit Tests for Task Model

```go
func TestTaskList_Add(t *testing.T) {
    tests := []struct {
        name        string
        title       string
        description string
        wantID      int
    }{
        {"first task", "Task 1", "Desc 1", 1},
        {"second task", "Task 2", "Desc 2", 2},
        {"no description", "Task 3", "", 3},
    }

    tl := task.NewTaskList()
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            id := tl.Add(tt.title, tt.description)
            if id != tt.wantID {
                t.Errorf("Add() = %d, want %d", id, tt.wantID)
            }

            // Verify task was added
            task, err := tl.Get(id)
            if err != nil {
                t.Fatalf("Get() error = %v", err)
            }
            if task.Title != tt.title {
                t.Errorf("Title = %q, want %q", task.Title, tt.title)
            }
        })
    }
}

func TestTaskList_Complete(t *testing.T) {
    tl := task.NewTaskList()
    id := tl.Add("Test task", "")

    // Complete the task
    err := tl.Complete(id)
    if err != nil {
        t.Fatalf("Complete() error = %v", err)
    }

    // Verify it's completed
    task, _ := tl.Get(id)
    if !task.Completed {
        t.Error("Task not marked as completed")
    }
    if task.CompletedAt == nil {
        t.Error("CompletedAt not set")
    }
}

func TestTaskList_Delete(t *testing.T) {
    tl := task.NewTaskList()
    id := tl.Add("Test task", "")

    // Delete the task
    err := tl.Delete(id)
    if err != nil {
        t.Fatalf("Delete() error = %v", err)
    }

    // Verify it's deleted
    _, err = tl.Get(id)
    if err == nil {
        t.Error("Expected error for deleted task")
    }
}

func TestTaskList_ListFiltering(t *testing.T) {
    tl := task.NewTaskList()
    id1 := tl.Add("Task 1", "")
    id2 := tl.Add("Task 2", "")
    tl.Complete(id1)

    allTasks := tl.ListAll()
    completedTasks := tl.ListCompleted()
    incompleteTasks := tl.ListIncomplete()

    if len(allTasks) != 2 {
        t.Errorf("ListAll() = %d tasks, want 2", len(allTasks))
    }
    if len(completedTasks) != 1 {
        t.Errorf("ListCompleted() = %d tasks, want 1", len(completedTasks))
    }
    if len(incompleteTasks) != 1 {
        t.Errorf("ListIncomplete() = %d tasks, want 1", len(incompleteTasks))
    }
}
```

### Unit Tests for Storage

```go
func TestStorage_LoadSave(t *testing.T) {
    // Create temp file
    tmpFile := filepath.Join(t.TempDir(), "tasks.json")
    storage, err := storage.NewStorage(tmpFile)
    if err != nil {
        t.Fatalf("NewStorage() error = %v", err)
    }

    // Create and save task list
    tl := task.NewTaskList()
    tl.Add("Test task", "Description")

    err = storage.Save(tl)
    if err != nil {
        t.Fatalf("Save() error = %v", err)
    }

    // Load and verify
    loaded, err := storage.Load()
    if err != nil {
        t.Fatalf("Load() error = %v", err)
    }

    if len(loaded.Tasks) != 1 {
        t.Errorf("Loaded %d tasks, want 1", len(loaded.Tasks))
    }
    if loaded.Tasks[0].Title != "Test task" {
        t.Errorf("Title = %q, want %q", loaded.Tasks[0].Title, "Test task")
    }
}

func TestStorage_LoadEmptyFile(t *testing.T) {
    tmpFile := filepath.Join(t.TempDir(), "nonexistent.json")
    storage, _ := storage.NewStorage(tmpFile)

    tl, err := storage.Load()
    if err != nil {
        t.Fatalf("Load() error = %v", err)
    }

    if len(tl.Tasks) != 0 {
        t.Errorf("Expected empty task list, got %d tasks", len(tl.Tasks))
    }
}
```

### Integration Tests

Test commands by invoking them programmatically or with subprocess:

```go
func TestAddCommand(t *testing.T) {
    // Set up temporary storage
    tmpDir := t.TempDir()
    os.Setenv("TASK_TRACKER_HOME", tmpDir)

    // Execute add command
    cmd := cmd.NewAddCommand()
    cmd.SetArgs([]string{"Test task", "Test description"})
    err := cmd.Execute()

    if err != nil {
        t.Fatalf("Add command failed: %v", err)
    }

    // Verify task was saved
    storage, _ := storage.NewStorage(filepath.Join(tmpDir, "tasks.json"))
    tasks, _ := storage.Load()

    if len(tasks.Tasks) != 1 {
        t.Errorf("Expected 1 task, got %d", len(tasks.Tasks))
    }
}
```

## Success Criteria

### Functional Requirements
- [ ] Can add tasks with title and optional description
- [ ] Can list all tasks with formatted output
- [ ] Can filter tasks by completed/incomplete status
- [ ] Can mark tasks as completed with timestamp
- [ ] Can delete tasks with optional confirmation
- [ ] Tasks persist across program runs
- [ ] Task IDs are unique and incrementing
- [ ] All errors are handled gracefully with user-friendly messages

### Code Quality Requirements
- [ ] Project follows standard Go structure (cmd/, internal/)
- [ ] All packages have documentation comments
- [ ] Exported functions have clear documentation
- [ ] Code passes `go fmt`, `go vet`, `staticcheck`
- [ ] Error handling follows Go conventions (return errors, don't panic)
- [ ] File operations use atomic writes (temp file + rename)
- [ ] Constants used for magic strings and numbers

### Testing Requirements
- [ ] Unit tests for task model (>90% coverage)
- [ ] Unit tests for storage layer (>85% coverage)
- [ ] Integration tests for main commands
- [ ] Edge cases tested (empty lists, invalid IDs, file errors)
- [ ] Tests use temp directories (no side effects)

### User Experience
- [ ] Clear help text for all commands
- [ ] Consistent output formatting
- [ ] Progress/success messages for operations
- [ ] Error messages are actionable
- [ ] Handles missing/corrupted data files gracefully

## Input/Output Specifications

### Adding Tasks

```bash
$ task-tracker add "Buy groceries"
✓ Task added with ID 1

$ task-tracker add "Write report" "Q4 financial report"
✓ Task added with ID 2
```

### Listing Tasks

```bash
$ task-tracker list
ID  Status  Title               Description
1   [ ]     Buy groceries
2   [ ]     Write report        Q4 financial report

$ task-tracker list --completed
No completed tasks.

$ task-tracker list --verbose
ID: 1
Title: Buy groceries
Description:
Status: Incomplete
Created: 2025-11-11 10:30:00
---
ID: 2
Title: Write report
Description: Q4 financial report
Status: Incomplete
Created: 2025-11-11 10:32:00
```

### Completing Tasks

```bash
$ task-tracker complete 1
✓ Task 1 marked as complete

$ task-tracker list
ID  Status  Title               Description
1   [✓]     Buy groceries
2   [ ]     Write report        Q4 financial report
```

### Deleting Tasks

```bash
$ task-tracker delete 1
Delete task "Buy groceries"? (y/N): y
✓ Task 1 deleted

$ task-tracker delete 2 --force
✓ Task 2 deleted
```

## Common Pitfalls to Avoid

### 1. Not Using Atomic Writes

```go
// ❌ Wrong: Direct write can corrupt data if interrupted
func (s *Storage) Save(tasks *TaskList) error {
    return os.WriteFile(s.filePath, data, 0644)
}

// ✅ Correct: Atomic write with temp file
func (s *Storage) Save(tasks *TaskList) error {
    tmpFile := s.filePath + ".tmp"
    if err := os.WriteFile(tmpFile, data, 0644); err != nil {
        return err
    }
    return os.Rename(tmpFile, s.filePath)
}
```

### 2. Not Handling File Not Exists

```go
// ❌ Wrong: Crashes if file doesn't exist
func (s *Storage) Load() (*TaskList, error) {
    data, err := os.ReadFile(s.filePath)
    if err != nil {
        return nil, err  // Error on first run!
    }
    // ...
}

// ✅ Correct: Return empty list if file doesn't exist
func (s *Storage) Load() (*TaskList, error) {
    data, err := os.ReadFile(s.filePath)
    if os.IsNotExist(err) {
        return NewTaskList(), nil
    }
    if err != nil {
        return nil, err
    }
    // ...
}
```

### 3. Mutable Task Pointers in List

```go
// ❌ Wrong: Returning pointer allows external mutation
func (tl *TaskList) Get(id int) *Task {
    for i := range tl.Tasks {
        if tl.Tasks[i].ID == id {
            return &tl.Tasks[i]  // Dangerous!
        }
    }
    return nil
}

// ✅ Correct: Return copy or use separate methods
func (tl *TaskList) Get(id int) (Task, error) {
    for _, task := range tl.Tasks {
        if task.ID == id {
            return task, nil  // Returns copy
        }
    }
    return Task{}, fmt.Errorf("task %d not found", id)
}
```

### 4. Not Validating Input

```go
// ❌ Wrong: No validation
func (tl *TaskList) Add(title, description string) int {
    // Accepts empty title!
}

// ✅ Correct: Validate input
func (tl *TaskList) Add(title, description string) (int, error) {
    title = strings.TrimSpace(title)
    if title == "" {
        return 0, errors.New("title cannot be empty")
    }
    // ...
}
```

### 5. Hardcoded File Paths

```go
// ❌ Wrong: Hardcoded path
const taskFile = "/tmp/tasks.json"

// ✅ Correct: Use user's home directory or configurable path
func getDefaultDataPath() string {
    home, _ := os.UserHomeDir()
    return filepath.Join(home, ".task-tracker", "tasks.json")
}
```

## Extension Challenges (Optional)

### 1. Due Dates
Add due date functionality:
- `--due` flag for add command
- List overdue tasks
- Sort by due date

### 2. Categories/Tags
Add categorization:
- `--category` flag for add
- List tasks by category
- Multiple categories per task

### 3. Priority Levels
Implement priority:
- High, Medium, Low priorities
- Sort by priority
- Highlight high-priority tasks

### 4. Search Functionality
Add search:
- Search by title/description
- Filter by multiple criteria
- Regex pattern matching

### 5. Edit Command
Allow task editing:
- Edit title/description
- Change due date
- Update priority

### 6. Statistics
Show task statistics:
- Total/completed/incomplete counts
- Completion rate
- Average completion time

## AI Provider Guidelines

### Allowed Packages

**Standard Library:**
- `encoding/json` - JSON marshaling
- `fmt` - Formatting and printing
- `os` - File operations
- `path/filepath` - Path manipulation
- `strings` - String utilities
- `time` - Time handling
- `errors` - Error creation

**External:**
- `github.com/spf13/cobra` - CLI framework (required)

### Expected Approach

1. **Project Structure**: Follow cmd/internal layout
2. **Separation of Concerns**: Task model, storage layer, CLI commands separate
3. **Error Handling**: Return errors, handle at command layer
4. **File Operations**: Atomic writes, handle missing files
5. **Testing**: Unit tests for each package, integration tests for commands
6. **User Experience**: Clear messages, formatted output, help text

### Code Quality Expectations

- Use Cobra's built-in features (flags, help, usage)
- Implement graceful error messages
- Use table-driven tests extensively
- Document all exported types and functions
- Keep functions focused and small (<20 lines ideal)
- Use constants for strings, file names, error messages

### Testing Approach

- Test task model thoroughly in isolation
- Test storage with temporary files
- Integration tests should clean up after themselves
- Use `t.TempDir()` for test files
- Mock nothing - use real files in temp directories
- Test error cases explicitly

## Learning Resources

### Cobra Framework
- [Cobra README](https://github.com/spf13/cobra)
- [Cobra User Guide](https://github.com/spf13/cobra/blob/master/user_guide.md)
- [Building CLI Applications in Go](https://spf13.com/presentation/building-an-awesome-cli-app-in-go-oscon/)

### Project Structure
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- [Go Modules by Example](https://github.com/go-modules-by-example/index)

### File Operations
- [Go by Example: Reading Files](https://gobyexample.com/reading-files)
- [Go by Example: Writing Files](https://gobyexample.com/writing-files)
- [Atomic File Writes](https://stackoverflow.com/questions/2333872/how-to-make-file-writes-atomic)

### JSON in Go
- [Go by Example: JSON](https://gobyexample.com/json)
- [JSON and Go](https://go.dev/blog/json)

## Validation Commands

```bash
# Format and check all packages
go fmt ./...
go vet ./...
staticcheck ./...

# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Build
go build -o task-tracker

# Test commands
./task-tracker add "Test task"
./task-tracker list
./task-tracker complete 1
./task-tracker delete 1

# Test help
./task-tracker --help
./task-tracker add --help
```

---

**Previous Lesson**: [Lesson 12: Cobra Subcommands & Flags](lesson-12-cobra-subcommands.md)
**Next Lesson**: [Lesson 14: API Integration & HTTP Clients](lesson-14-api-integration.md)

**Estimated Completion Time**: 4-6 hours
**Difficulty Check**: This is a milestone project. If taking >8 hours, break into smaller steps and complete the core functionality first (add, list, complete, delete), then add polish.

**Milestone**: Completing this lesson demonstrates CLI development proficiency. You should feel confident building command-line tools with Go and Cobra after this project.
