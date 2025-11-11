# Lesson 18: Enhancing Existing CLIs with Style

**Phase**: 3 - Styling with Lip Gloss
**Difficulty**: Intermediate
**Estimated Time**: 3-4 hours
**Type**: Milestone Project

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Retrofit Lip Gloss** into existing CLI applications without breaking functionality
2. **Identify styling opportunities** in plain CLI output for maximum impact
3. **Implement progressive enhancement** by adding styles incrementally
4. **Maintain backwards compatibility** when adding styled output
5. **Optimize performance** by avoiding unnecessary style recalculations
6. **Create before/after examples** demonstrating the value of styling
7. **Apply Phase 3 knowledge** (colors, layout, theming) to real applications
8. **Build professional CLI UIs** that combine all Lip Gloss techniques

## Prerequisites

- **Required**: Completion of Lessons 15-17 (Lip Gloss Basics, Layout, Theming)
- **Required**: Lesson 13 (Task Tracker CLI) - Will be enhanced in this lesson
- **Concepts**: All Phase 3 styling techniques (colors, borders, layout, themes)
- **Tools**: Go 1.20+, Lip Gloss installed, existing CLI projects
- **Knowledge**: CLI architecture, output formatting, user experience
- **Milestone**: This is Phase 3's culminating project

## Core Concepts

### 1. Identifying Styling Opportunities

Analyze existing CLI output to find impactful places for styling.

**Before (plain output)**:
```bash
$ task list

Tasks:
1. Deploy application to production [done]
2. Write API documentation [active]
3. Update dependencies [todo]
4. Run security audit [todo]

Total: 4 tasks
Done: 1, Active: 1, Todo: 2
```

**After (styled output)**:
```bash
$ task list

╭─ Tasks ───────────────────────────────────────────────╮
│ ID  │ Status    │ Task                                │
├─────┼───────────┼─────────────────────────────────────┤
│ 1   │ ✓ Done    │ Deploy application to production    │
│ 2   │ ⏳ Active │ Write API documentation             │
│ 3   │ ○ Todo    │ Update dependencies                 │
│ 4   │ ○ Todo    │ Run security audit                  │
╰─────┴───────────┴─────────────────────────────────────╯

Total: 4 tasks | Done: 1 | Active: 1 | Todo: 2
```

**High-impact styling targets**:
1. **Status indicators**: Replace text with colored symbols (✓, ⚠, ✗, ○)
2. **Tables and lists**: Add borders, headers, alignment
3. **Section headers**: Bold, colored, with dividers
4. **Success/error messages**: Semantic colors with prefixes
5. **Progress information**: Visual bars or percentages
6. **Key-value pairs**: Aligned columns with spacing
7. **Help text**: Hierarchical formatting with colors

### 2. Progressive Enhancement Strategy

Add styling incrementally without breaking existing functionality.

```go
package main

import (
    "fmt"
    "os"
    "github.com/charmbracelet/lipgloss"
)

// Phase 1: Detect if styling should be enabled
func shouldUseStyles() bool {
    // Check if output is a terminal (not piped)
    fileInfo, _ := os.Stdout.Stat()
    isTerminal := (fileInfo.Mode() & os.ModeCharDevice) != 0

    // Check NO_COLOR environment variable
    if os.Getenv("NO_COLOR") != "" {
        return false
    }

    // Check TERM environment variable
    term := os.Getenv("TERM")
    if term == "dumb" || term == "" {
        return false
    }

    return isTerminal
}

// Phase 2: Create styled and plain versions of output functions
func formatTaskStatus(status string, styled bool) string {
    if !styled {
        return status // Plain text: "done", "active", "todo"
    }

    // Styled version with colors and symbols
    switch status {
    case "done":
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
        return style.Render("✓ Done")
    case "active":
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("214"))
        return style.Render("⏳ Active")
    case "todo":
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("243"))
        return style.Render("○ Todo")
    default:
        return status
    }
}

// Phase 3: Wrapper functions that check styling preference
var useStyles = shouldUseStyles()

func FormatStatus(status string) string {
    return formatTaskStatus(status, useStyles)
}

// Phase 4: Allow user to override with flag
func main() {
    // Parse --no-color flag to disable styling
    for _, arg := range os.Args {
        if arg == "--no-color" {
            useStyles = false
        }
        if arg == "--color" {
            useStyles = true
        }
    }

    // Use consistent formatting throughout
    fmt.Println(FormatStatus("done"))
    fmt.Println(FormatStatus("active"))
    fmt.Println(FormatStatus("todo"))
}
```

**Progressive enhancement checklist**:
- [ ] Detect terminal vs pipe output
- [ ] Respect NO_COLOR environment variable
- [ ] Provide --no-color and --color flags
- [ ] Maintain plain text fallback
- [ ] Test with output redirection (`> file.txt`)
- [ ] Ensure scripts/automation still work

### 3. Backwards Compatibility Patterns

Maintain compatibility while adding styles.

```go
package output

import (
    "fmt"
    "io"
    "os"
    "github.com/charmbracelet/lipgloss"
)

// OutputFormatter handles styled and plain output
type OutputFormatter struct {
    writer  io.Writer
    styled  bool
    theme   Theme
}

// NewOutputFormatter creates formatter with auto-detection
func NewOutputFormatter(w io.Writer) *OutputFormatter {
    // Auto-detect if writer supports styling
    styled := false
    if f, ok := w.(*os.File); ok {
        fileInfo, _ := f.Stat()
        styled = (fileInfo.Mode() & os.ModeCharDevice) != 0
    }

    return &OutputFormatter{
        writer: w,
        styled: styled,
        theme:  DefaultTheme,
    }
}

// SetStyled enables or disables styling
func (of *OutputFormatter) SetStyled(enabled bool) {
    of.styled = enabled
}

// Success prints success message (styled or plain)
func (of *OutputFormatter) Success(msg string) {
    if of.styled {
        style := lipgloss.NewStyle().
            Foreground(of.theme.Success).
            Bold(true).
            Prefix("✓ ")
        fmt.Fprintln(of.writer, style.Render(msg))
    } else {
        fmt.Fprintf(of.writer, "[SUCCESS] %s\n", msg)
    }
}

// Error prints error message (styled or plain)
func (of *OutputFormatter) Error(msg string) {
    if of.styled {
        style := lipgloss.NewStyle().
            Foreground(of.theme.Error).
            Bold(true).
            Prefix("✗ ")
        fmt.Fprintln(of.writer, style.Render(msg))
    } else {
        fmt.Fprintf(of.writer, "[ERROR] %s\n", msg)
    }
}

// Table prints data in table format (styled or plain)
func (of *OutputFormatter) Table(headers []string, rows [][]string) {
    if of.styled {
        of.renderStyledTable(headers, rows)
    } else {
        of.renderPlainTable(headers, rows)
    }
}

func (of *OutputFormatter) renderStyledTable(headers []string, rows [][]string) {
    // Styled table with borders and alignment
    // (Implementation from Lesson 16)
}

func (of *OutputFormatter) renderPlainTable(headers []string, rows [][]string) {
    // Plain text table with simple formatting
    // Header
    for i, h := range headers {
        fmt.Fprintf(of.writer, "%-20s", h)
        if i < len(headers)-1 {
            fmt.Fprint(of.writer, " | ")
        }
    }
    fmt.Fprintln(of.writer)

    // Separator
    for i := range headers {
        fmt.Fprint(of.writer, "--------------------")
        if i < len(headers)-1 {
            fmt.Fprint(of.writer, " | ")
        }
    }
    fmt.Fprintln(of.writer)

    // Rows
    for _, row := range rows {
        for i, cell := range row {
            fmt.Fprintf(of.writer, "%-20s", cell)
            if i < len(row)-1 {
                fmt.Fprint(of.writer, " | ")
            }
        }
        fmt.Fprintln(of.writer)
    }
}
```

**Backwards compatibility strategies**:
1. **Dual output paths**: Styled and plain versions of each function
2. **Auto-detection**: Check if output is terminal
3. **Environment variables**: Respect NO_COLOR, TERM
4. **CLI flags**: --no-color and --color overrides
5. **Graceful degradation**: Plain text fallback always works
6. **Testing**: Verify both styled and plain output

### 4. Performance Considerations

Avoid performance issues when adding styles.

```go
package styles

import (
    "sync"
    "github.com/charmbracelet/lipgloss"
)

// Cache style instances to avoid recreation
var (
    styleCache = make(map[string]lipgloss.Style)
    cacheMutex sync.RWMutex
)

// GetCachedStyle returns or creates cached style
func GetCachedStyle(key string, factory func() lipgloss.Style) lipgloss.Style {
    // Try read lock first
    cacheMutex.RLock()
    if style, ok := styleCache[key]; ok {
        cacheMutex.RUnlock()
        return style
    }
    cacheMutex.RUnlock()

    // Create style with write lock
    cacheMutex.Lock()
    defer cacheMutex.Unlock()

    // Double-check after acquiring write lock
    if style, ok := styleCache[key]; ok {
        return style
    }

    // Create and cache
    style := factory()
    styleCache[key] = style
    return style
}

// Pre-create commonly used styles
var (
    SuccessStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Bold(true).
        Prefix("✓ ")

    ErrorStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Bold(true).
        Prefix("✗ ")

    WarningStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("214")).
        Bold(true).
        Prefix("⚠ ")
)

// Batch rendering for multiple items
func RenderList(items []string, style lipgloss.Style) []string {
    // Pre-allocate result slice
    result := make([]string, len(items))

    // Render all items
    for i, item := range items {
        result[i] = style.Render(item)
    }

    return result
}

// Avoid repeated Width() calls
func RenderAligned(items []string, width int) string {
    // Calculate width once
    // Reuse for all items
    style := lipgloss.NewStyle().Width(width)

    rendered := make([]string, len(items))
    for i, item := range items {
        rendered[i] = style.Render(item)
    }

    return lipgloss.JoinVertical(lipgloss.Left, rendered...)
}
```

**Performance tips**:
1. **Cache styles**: Create once, reuse many times
2. **Pre-create common styles**: Define at package level
3. **Batch operations**: Render multiple items together
4. **Avoid recalculation**: Cache dimensions and measurements
5. **Lazy evaluation**: Only style when output is to terminal
6. **Profile**: Use `go test -bench` to measure performance

### 5. Refactoring Existing Output

Transform plain text output to styled output systematically.

**Before: Plain text list**:
```go
func ListTasks(tasks []Task) {
    fmt.Println("Tasks:")
    for _, task := range tasks {
        fmt.Printf("%d. %s [%s]\n", task.ID, task.Title, task.Status)
    }
    fmt.Printf("\nTotal: %d tasks\n", len(tasks))
}
```

**After: Styled table**:
```go
func ListTasks(tasks []Task, formatter *OutputFormatter) {
    if len(tasks) == 0 {
        formatter.Info("No tasks found")
        return
    }

    // Prepare table data
    headers := []string{"ID", "Status", "Task"}
    rows := make([][]string, len(tasks))

    for i, task := range tasks {
        rows[i] = []string{
            fmt.Sprintf("%d", task.ID),
            formatStatus(task.Status, formatter.styled),
            task.Title,
        }
    }

    // Render table (styled or plain based on formatter)
    formatter.Table(headers, rows)

    // Summary with color-coded counts
    summary := fmt.Sprintf("Total: %d tasks", len(tasks))
    if formatter.styled {
        style := lipgloss.NewStyle().
            Foreground(lipgloss.Color("243")).
            Faint(true).
            Margin(1, 0, 0, 0)
        fmt.Println(style.Render(summary))
    } else {
        fmt.Println("\n" + summary)
    }
}

func formatStatus(status string, styled bool) string {
    if !styled {
        return status
    }

    switch status {
    case "done":
        return SuccessStyle.Render("✓ Done")
    case "active":
        return WarningStyle.Render("⏳ Active")
    case "todo":
        return lipgloss.NewStyle().
            Foreground(lipgloss.Color("243")).
            Render("○ Todo")
    default:
        return status
    }
}
```

**Before: Plain error message**:
```go
func AddTask(title string) error {
    if title == "" {
        fmt.Println("Error: Task title cannot be empty")
        return fmt.Errorf("empty title")
    }
    // ... add task
    fmt.Println("Task added successfully")
    return nil
}
```

**After: Styled messages**:
```go
func AddTask(title string, formatter *OutputFormatter) error {
    if title == "" {
        formatter.Error("Task title cannot be empty")
        return fmt.Errorf("empty title")
    }

    // ... add task

    formatter.Success(fmt.Sprintf("Task added: %q", title))
    return nil
}
```

### 6. Creating Before/After Demos

Build convincing demonstrations of styling improvements.

```go
package demo

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

// DemoComparison shows before/after of styling
func DemoComparison() {
    fmt.Println("========== BEFORE (Plain Text) ==========\n")
    demoPlainOutput()

    fmt.Println("\n\n========== AFTER (Styled with Lip Gloss) ==========\n")
    demoStyledOutput()
}

func demoPlainOutput() {
    fmt.Println("Tasks:")
    fmt.Println("1. Deploy application [done]")
    fmt.Println("2. Write docs [active]")
    fmt.Println("3. Update deps [todo]")
    fmt.Println()
    fmt.Println("Total: 3 tasks")
    fmt.Println("Done: 1, Active: 1, Todo: 1")
}

func demoStyledOutput() {
    // Table style
    tableStyle := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("240")).
        Padding(1)

    // Header style
    headerStyle := lipgloss.NewStyle().
        Bold(true).
        Foreground(lipgloss.Color("205")).
        BorderBottom(true).
        BorderStyle(lipgloss.NormalBorder()).
        Padding(0, 1)

    // Status styles
    doneStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
    activeStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("214"))
    todoStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("243"))

    // Build table
    header := headerStyle.Render("Tasks")

    row1 := fmt.Sprintf("1  %s  Deploy application",
        doneStyle.Render("✓ Done"))
    row2 := fmt.Sprintf("2  %s  Write docs",
        activeStyle.Render("⏳ Active"))
    row3 := fmt.Sprintf("3  %s  Update deps",
        todoStyle.Render("○ Todo"))

    table := lipgloss.JoinVertical(lipgloss.Left,
        header,
        "",
        row1,
        row2,
        row3,
    )

    fmt.Println(tableStyle.Render(table))

    // Summary
    summaryStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("243")).
        Faint(true).
        Margin(1, 0, 0, 0)

    summary := "Total: 3 tasks | Done: 1 | Active: 1 | Todo: 1"
    fmt.Println(summaryStyle.Render(summary))
}

// ScreenshotDemo creates output suitable for screenshots
func ScreenshotDemo() {
    // Create visually impressive output
    // Use maximum styling features
    // Show off colors, borders, layout, icons
}
```

### 7. CLI Help Text Enhancement

Transform plain help text into beautiful, hierarchical documentation.

**Before: Plain help**:
```
Usage: task [command] [options]

Commands:
  list      List all tasks
  add       Add a new task
  complete  Mark a task as complete
  delete    Delete a task

Options:
  --help    Show help
  --version Show version
```

**After: Styled help**:
```go
package help

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func RenderHelp() string {
    // Styles
    titleStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Bold(true).
        Padding(1, 0)

    sectionStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("135")).
        Bold(true).
        Margin(1, 0, 0, 0)

    commandStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        PaddingLeft(2)

    descStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("247")).
        PaddingLeft(4)

    // Build help text
    title := titleStyle.Render("Task Tracker CLI")

    usage := sectionStyle.Render("Usage:")
    usageText := lipgloss.NewStyle().
        PaddingLeft(2).
        Render("task [command] [options]")

    commands := sectionStyle.Render("Commands:")
    cmdList := lipgloss.JoinVertical(lipgloss.Left,
        commandStyle.Render("list"),
        descStyle.Render("List all tasks with status"),
        "",
        commandStyle.Render("add <title>"),
        descStyle.Render("Add a new task with the given title"),
        "",
        commandStyle.Render("complete <id>"),
        descStyle.Render("Mark a task as complete by ID"),
        "",
        commandStyle.Render("delete <id>"),
        descStyle.Render("Delete a task by ID"),
    )

    options := sectionStyle.Render("Options:")
    optList := lipgloss.JoinVertical(lipgloss.Left,
        commandStyle.Render("--help, -h"),
        descStyle.Render("Show this help message"),
        "",
        commandStyle.Render("--version, -v"),
        descStyle.Render("Show version information"),
        "",
        commandStyle.Render("--no-color"),
        descStyle.Render("Disable colored output"),
    )

    examples := sectionStyle.Render("Examples:")
    exampleStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("243")).
        PaddingLeft(2)

    exampleList := lipgloss.JoinVertical(lipgloss.Left,
        exampleStyle.Render("task add \"Deploy to production\""),
        exampleStyle.Render("task list"),
        exampleStyle.Render("task complete 1"),
    )

    // Combine sections
    help := lipgloss.JoinVertical(lipgloss.Left,
        title,
        usage,
        usageText,
        "",
        commands,
        cmdList,
        "",
        options,
        optList,
        "",
        examples,
        exampleList,
    )

    // Border around entire help
    borderStyle := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("240")).
        Padding(1, 2)

    return borderStyle.Render(help)
}
```

### 8. Integration Checklist

Systematic approach to integrating Lip Gloss into existing projects.

```go
// Phase 1: Setup
// □ Install Lip Gloss: go get github.com/charmbracelet/lipgloss
// □ Create styles package for reusable styles
// □ Create theme package for color schemes
// □ Create output package for formatter

// Phase 2: Infrastructure
// □ Implement OutputFormatter with styled/plain modes
// □ Add terminal detection logic
// □ Add NO_COLOR environment variable support
// □ Add --color and --no-color flags
// □ Create theme system (if needed)

// Phase 3: Style Definitions
// □ Define color palette
// □ Create semantic styles (success, error, warning, info)
// □ Create component styles (header, paragraph, box, table)
// □ Pre-create common styles for performance

// Phase 4: Refactoring
// □ Replace fmt.Println with formatter.Print
// □ Replace error messages with formatter.Error
// □ Replace success messages with formatter.Success
// □ Convert lists to styled tables
// □ Add borders to sections
// □ Enhance help text

// Phase 5: Testing
// □ Test styled output in terminal
// □ Test plain output when piped
// □ Test with NO_COLOR=1
// □ Test with --no-color flag
// □ Test in different terminals (iTerm2, Alacritty, etc.)
// □ Test output redirection: ./app > output.txt

// Phase 6: Documentation
// □ Update README with screenshots
// □ Document --color and --no-color flags
// □ Document NO_COLOR environment variable
// □ Show before/after examples
// □ Add theme customization docs (if applicable)

// Phase 7: Polish
// □ Ensure consistent styling throughout
// □ Optimize performance (cache styles)
// □ Add theme support (optional)
// □ Create demo mode for screenshots
// □ Gather user feedback
```

### 9. Real-World Enhancement Example

Complete example of enhancing the Task Tracker from Lesson 13.

```go
package main

import (
    "flag"
    "fmt"
    "os"

    "github.com/spf13/cobra"
    "tasktracker/internal/output"
    "tasktracker/internal/styles"
    "tasktracker/internal/task"
)

var (
    noColor bool
    theme   string
    formatter *output.OutputFormatter
)

func main() {
    // Global flags
    rootCmd.PersistentFlags().BoolVar(&noColor, "no-color", false, "Disable colored output")
    rootCmd.PersistentFlags().StringVar(&theme, "theme", "default", "Color theme (default, dracula, minimal)")

    // Initialize formatter
    formatter = output.NewOutputFormatter(os.Stdout)

    // Execute
    if err := rootCmd.Execute(); err != nil {
        formatter.Error(err.Error())
        os.Exit(1)
    }
}

var rootCmd = &cobra.Command{
    Use:   "task",
    Short: "Task Tracker CLI with beautiful output",
    PersistentPreRun: func(cmd *cobra.Command, args []string) {
        // Configure formatter
        if noColor {
            formatter.SetStyled(false)
        }

        // Load theme
        if err := styles.LoadTheme(theme); err != nil {
            formatter.Warning(fmt.Sprintf("Unknown theme %q, using default", theme))
        }
    },
}

var listCmd = &cobra.Command{
    Use:   "list",
    Short: "List all tasks",
    Run: func(cmd *cobra.Command, args []string) {
        tasks, err := task.LoadTasks()
        if err != nil {
            formatter.Error(fmt.Sprintf("Failed to load tasks: %v", err))
            return
        }

        if len(tasks) == 0 {
            formatter.Info("No tasks found. Add one with 'task add <title>'")
            return
        }

        // Render styled table
        formatter.TaskTable(tasks)

        // Summary
        done := countByStatus(tasks, "done")
        active := countByStatus(tasks, "active")
        todo := countByStatus(tasks, "todo")

        summary := fmt.Sprintf("Total: %d | Done: %d | Active: %d | Todo: %d",
            len(tasks), done, active, todo)

        formatter.Summary(summary)
    },
}

var addCmd = &cobra.Command{
    Use:   "add [title]",
    Short: "Add a new task",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        title := args[0]

        if title == "" {
            formatter.Error("Task title cannot be empty")
            return
        }

        newTask := task.Task{
            Title:  title,
            Status: "todo",
        }

        if err := task.AddTask(newTask); err != nil {
            formatter.Error(fmt.Sprintf("Failed to add task: %v", err))
            return
        }

        formatter.Success(fmt.Sprintf("Task added: %q", title))
    },
}

var completeCmd = &cobra.Command{
    Use:   "complete [id]",
    Short: "Mark a task as complete",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        id := parseID(args[0])
        if id == 0 {
            formatter.Error("Invalid task ID")
            return
        }

        if err := task.CompleteTask(id); err != nil {
            formatter.Error(fmt.Sprintf("Failed to complete task: %v", err))
            return
        }

        formatter.Success(fmt.Sprintf("Task %d marked as complete", id))
    },
}

func countByStatus(tasks []task.Task, status string) int {
    count := 0
    for _, t := range tasks {
        if t.Status == status {
            count++
        }
    }
    return count
}

func parseID(s string) int {
    var id int
    fmt.Sscanf(s, "%d", &id)
    return id
}

func init() {
    rootCmd.AddCommand(listCmd)
    rootCmd.AddCommand(addCmd)
    rootCmd.AddCommand(completeCmd)
}
```

## Challenge Description

Build three enhanced versions of existing CLI applications, demonstrating comprehensive Lip Gloss integration.

### Challenge 1: Enhanced Task Tracker (from Lesson 13)

Retrofit the Task Tracker CLI with comprehensive styling and theming.

**Requirements**:
1. Add styled table output for `task list`
2. Implement semantic colors for status (done=green, active=yellow, todo=gray)
3. Add borders and sections to output
4. Implement theme support (at least 2 themes)
5. Add --no-color flag for plain output
6. Enhance help text with hierarchical formatting
7. Add summary dashboard with statistics
8. Support output redirection (automatic plain text)
9. Create before/after demo mode
10. Optimize performance (cache styles)

**Example output**:
```bash
$ task list --theme dracula

╭─ Task Tracker ─────────────────────────────────────────────────────────╮
│                                                                         │
│  Active Tasks                                                           │
│                                                                         │
│  ╭─────┬─────────────┬──────────────────────────────────────────────╮  │
│  │ ID  │ Status      │ Task                                         │  │
│  ├─────┼─────────────┼──────────────────────────────────────────────┤  │
│  │ 1   │ ✓ Done      │ Deploy application to production             │  │
│  │ 2   │ ⏳ Active   │ Write API documentation                      │  │
│  │ 3   │ ⏳ Active   │ Run integration tests                        │  │
│  │ 4   │ ○ Todo      │ Update dependencies                          │  │
│  │ 5   │ ○ Todo      │ Security audit                               │  │
│  ╰─────┴─────────────┴──────────────────────────────────────────────╯  │
│                                                                         │
│  ╭─ Statistics ──────────────────────────────────────────────────────╮ │
│  │  Total: 5 tasks                                                   │ │
│  │  ✓ Done: 1 (20%)    ████░░░░░░░░░░░░░░░░                         │ │
│  │  ⏳ Active: 2 (40%)  ████████░░░░░░░░░░░░                         │ │
│  │  ○ Todo: 2 (40%)    ████████░░░░░░░░░░░░                         │ │
│  ╰───────────────────────────────────────────────────────────────────╯ │
│                                                                         │
╰─────────────────────────────────────────────────────────────────────────╯

$ task add "New feature" --theme dracula
✓ Task added: "New feature"

$ task complete 2 --theme dracula
✓ Task 2 marked as complete

$ task list --no-color
Tasks:
ID  Status   Task
1   Done     Deploy application to production
2   Done     Write API documentation
3   Active   Run integration tests
4   Todo     Update dependencies
5   Todo     Security audit
6   Todo     New feature

Total: 6 tasks
Done: 2, Active: 1, Todo: 3
```

### Challenge 2: Git Status Visualizer

Create a styled git status viewer that enhances standard git output.

**Requirements**:
1. Show current branch with colored indicator
2. Display modified files in colored table
3. Show staged/unstaged/untracked sections separately
4. Add file status icons (M=modified, A=added, D=deleted, ?=untracked)
5. Display commit status (ahead/behind remote)
6. Show stash count if present
7. Add diff statistics (insertions/deletions)
8. Support multiple themes
9. Provide --no-color for scripts
10. Add helpful tips/suggestions

**Example output**:
```bash
$ gitstatus

╭─ Git Status ──────────────────────────────────────────────────────────╮
│                                                                        │
│  On branch: main  ↑2 ↓1  [2 commits ahead, 1 behind]                 │
│  Your branch is ahead of 'origin/main'                                │
│                                                                        │
│  ╭─ Staged Changes (3) ─────────────────────────────────────────────╮ │
│  │  A  internal/styles/styles.go          (+145 -0)                 │ │
│  │  M  cmd/root.go                        (+23 -12)                 │ │
│  │  M  README.md                          (+10 -2)                  │ │
│  ╰───────────────────────────────────────────────────────────────────╯ │
│                                                                        │
│  ╭─ Unstaged Changes (2) ────────────────────────────────────────────╮│
│  │  M  go.mod                             (+1 -0)                   │ │
│  │  M  main.go                            (+5 -3)                   │ │
│  ╰───────────────────────────────────────────────────────────────────╯ │
│                                                                        │
│  ╭─ Untracked Files (1) ─────────────────────────────────────────────╮│
│  │  ?  temp.txt                                                      │ │
│  ╰───────────────────────────────────────────────────────────────────╯ │
│                                                                        │
│  💡 Tip: Use 'git add <file>' to stage changes                        │
│                                                                        │
╰────────────────────────────────────────────────────────────────────────╯

Stash: 1 saved change
```

### Challenge 3: System Monitor Dashboard

Build a styled system monitoring CLI with live-updating dashboard.

**Requirements**:
1. Display CPU usage with progress bar
2. Show memory usage with percentage
3. Display disk space with visual indicator
4. Show top processes in styled table
5. Display network activity (if available)
6. Show system uptime and load average
7. Update dashboard in real-time (refresh every second)
8. Use themed colors for thresholds (green <50%, yellow <80%, red ≥80%)
9. Support multiple themes
10. Provide snapshot mode (single output, no updates)

**Example output**:
```bash
$ sysmon

╭─ System Monitor ──────────────────────────────────────────────────────╮
│  Updated: 2024-01-15 15:43:22                                          │
╰────────────────────────────────────────────────────────────────────────╯

╭─ CPU ──────────────╮  ╭─ Memory ────────────╮  ╭─ Disk ──────────────╮
│                    │  │                     │  │                     │
│  Usage: 45%        │  │  Used: 2.3 GB       │  │  Available:         │
│  ████████░░░░      │  │  Total: 16 GB       │  │    125 GB           │
│                    │  │  ████████░░░░       │  │  ██████████████░░░  │
│  Cores: 8          │  │                     │  │                     │
│  Load: 1.2, 0.9    │  │  Swap: 512 MB       │  │  Usage: 70%         │
│                    │  │                     │  │                     │
╰────────────────────╯  ╰─────────────────────╯  ╰─────────────────────╯

╭─ Top Processes ────────────────────────────────────────────────────────╮
│  PID    │ Name            │ CPU %  │ Memory   │ State                 │
├─────────┼─────────────────┼────────┼──────────┼───────────────────────┤
│  1234   │ chrome          │  23.5% │  1.2 GB  │ Running               │
│  5678   │ node            │  12.3% │  512 MB  │ Running               │
│  9012   │ docker          │   8.1% │  256 MB  │ Sleeping              │
│  3456   │ code            │   5.2% │  890 MB  │ Running               │
╰────────────────────────────────────────────────────────────────────────╯

╭─ Network ──────────────────────────────────────────────────────────────╮
│  ↓ Download: 1.2 MB/s    ↑ Upload: 234 KB/s                           │
╰────────────────────────────────────────────────────────────────────────╯

Uptime: 3 days, 5 hours, 12 minutes          [Press Ctrl+C to exit]
```

## Test Requirements

Implement comprehensive tests for enhancement integration and backwards compatibility.

### Test Structure Pattern

```go
package output

import (
    "bytes"
    "strings"
    "testing"
)

func TestStyledOutput(t *testing.T) {
    tests := []struct {
        name        string
        styled      bool
        message     string
        wantContain string
    }{
        {
            name:        "styled success message",
            styled:      true,
            message:     "Operation complete",
            wantContain: "Operation complete",
        },
        {
            name:        "plain success message",
            styled:      false,
            message:     "Operation complete",
            wantContain: "[SUCCESS]",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            buf := &bytes.Buffer{}
            formatter := &OutputFormatter{
                writer: buf,
                styled: tt.styled,
            }

            formatter.Success(tt.message)

            output := buf.String()
            if !strings.Contains(output, tt.wantContain) {
                t.Errorf("output doesn't contain %q: %s", tt.wantContain, output)
            }
        })
    }
}

func TestPlainOutputNoPipes(t *testing.T) {
    // Ensure plain output works for pipes and scripts
    buf := &bytes.Buffer{}
    formatter := &OutputFormatter{
        writer: buf,
        styled: false,
    }

    formatter.Success("Test")
    formatter.Error("Test")
    formatter.Warning("Test")
    formatter.Info("Test")

    output := buf.String()

    // Verify no ANSI codes in plain output
    if strings.Contains(output, "\x1b[") {
        t.Error("plain output contains ANSI codes")
    }

    // Verify all messages present
    if !strings.Contains(output, "[SUCCESS]") {
        t.Error("missing success message")
    }
    if !strings.Contains(output, "[ERROR]") {
        t.Error("missing error message")
    }
}

func TestTableOutput(t *testing.T) {
    headers := []string{"ID", "Status", "Task"}
    rows := [][]string{
        {"1", "done", "Task 1"},
        {"2", "active", "Task 2"},
    }

    tests := []struct {
        name   string
        styled bool
    }{
        {"styled table", true},
        {"plain table", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            buf := &bytes.Buffer{}
            formatter := &OutputFormatter{
                writer: buf,
                styled: tt.styled,
            }

            formatter.Table(headers, rows)

            output := buf.String()

            // Verify headers present
            for _, h := range headers {
                if !strings.Contains(output, h) {
                    t.Errorf("missing header: %q", h)
                }
            }

            // Verify data present
            for _, row := range rows {
                for _, cell := range row {
                    if !strings.Contains(output, cell) {
                        t.Errorf("missing cell: %q", cell)
                    }
                }
            }
        })
    }
}

func TestBackwardsCompatibility(t *testing.T) {
    // Test that scripts relying on plain text still work
    tests := []struct {
        name    string
        command string
        want    string
    }{
        {
            name:    "list tasks plain",
            command: "task list --no-color",
            want:    "Tasks:",
        },
        {
            name:    "add task plain",
            command: "task add 'Test' --no-color",
            want:    "[SUCCESS]",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Execute command
            // Verify output format matches expectations
            // Ensure parsing logic still works
        })
    }
}

func TestPerformance(t *testing.T) {
    // Benchmark style application
    formatter := &OutputFormatter{
        writer: bytes.NewBuffer(nil),
        styled: true,
    }

    b := testing.Benchmark(func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            formatter.Success("Test message")
        }
    })

    // Ensure reasonable performance
    opsPerSec := float64(b.N) / b.T.Seconds()
    if opsPerSec < 100000 {
        t.Errorf("performance too slow: %.0f ops/sec", opsPerSec)
    }
}

func TestThemeSwitching(t *testing.T) {
    formatter := &OutputFormatter{
        writer: bytes.NewBuffer(nil),
        styled: true,
    }

    // Switch themes
    formatter.SetTheme(DraculaTheme)
    // Verify theme applied

    formatter.SetTheme(SolarizedTheme)
    // Verify theme switched
}
```

### Required Test Cases

**For Output Formatting**:
1. Styled output contains expected content
2. Plain output contains expected content
3. Plain output has no ANSI codes
4. Table rendering works for both modes
5. Semantic messages formatted correctly

**For Backwards Compatibility**:
1. --no-color flag disables styling
2. NO_COLOR environment variable respected
3. Piped output is automatically plain
4. Scripts parsing output still work
5. Output redirection produces plain text

**For Performance**:
1. Style caching reduces overhead
2. Batch operations faster than individual
3. No memory leaks in long-running apps
4. Performance acceptable (>100k ops/sec)

**For Integration**:
1. All commands work with styling
2. All commands work without styling
3. Theme switching doesn't break output
4. Help text renders correctly

## Input/Output Specifications

### Enhanced Task Tracker

**Input**: Task commands with styling flags
**Output**: Styled or plain based on flags and detection

```bash
Input: task list --theme dracula
Output: (Styled table with Dracula theme)

Input: task list --no-color
Output: (Plain text table)

Input: task list > tasks.txt
Output: (Automatically plain text in file)
```

### Git Status Visualizer

**Input**: Git repository in current directory
**Output**: Styled git status visualization

```bash
Input: gitstatus
Output: (Styled dashboard with git information)

Input: gitstatus --no-color
Output: (Plain text git status)
```

### System Monitor

**Input**: No arguments (monitor system)
**Output**: Real-time updating dashboard or snapshot

```bash
Input: sysmon
Output: (Live-updating dashboard, updates every second)

Input: sysmon --snapshot
Output: (Single output, no updates)

Input: sysmon --no-color
Output: (Plain text system stats)
```

## Success Criteria

### Functional Requirements
- [ ] All enhanced CLIs work with styling enabled
- [ ] All enhanced CLIs work with styling disabled
- [ ] --no-color flag works correctly
- [ ] NO_COLOR environment variable respected
- [ ] Output redirection produces plain text automatically
- [ ] Themes can be switched at runtime
- [ ] Help text is beautifully formatted
- [ ] Performance is acceptable (no noticeable lag)

### Code Quality Requirements
- [ ] Dual output paths (styled and plain)
- [ ] OutputFormatter abstraction used throughout
- [ ] Styles cached for performance
- [ ] Theme system implemented (if using themes)
- [ ] Clean separation of concerns
- [ ] No hardcoded ANSI codes
- [ ] Reusable style definitions

### Testing Requirements
- [ ] Styled output tested
- [ ] Plain output tested
- [ ] Backwards compatibility verified
- [ ] Performance benchmarked
- [ ] Integration tests for all commands
- [ ] Theme switching tested
- [ ] Test coverage >75%

### Visual Requirements
- [ ] Output is significantly improved over plain text
- [ ] Consistent styling throughout application
- [ ] Appropriate use of colors and formatting
- [ ] Professional appearance
- [ ] Works in multiple terminals
- [ ] Accessible (symbols + colors)
- [ ] Before/after comparison is compelling

## Common Pitfalls

### Pitfall 1: Breaking Scripts That Parse Output

❌ **Wrong**: Changing output format breaks automation
```go
// Before
fmt.Printf("%d tasks found\n", len(tasks))

// After (breaks parsing)
style := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
fmt.Println(style.Render(fmt.Sprintf("Found %d tasks", len(tasks))))

// Script that breaks:
// count=$(task list | grep "tasks found" | awk '{print $1}')
```

✅ **Correct**: Maintain plain text option and detect pipes
```go
func PrintTaskCount(count int, formatter *OutputFormatter) {
    if formatter.styled {
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
        fmt.Println(style.Render(fmt.Sprintf("Found %d tasks", count)))
    } else {
        // Keep original format for scripts
        fmt.Printf("%d tasks found\n", count)
    }
}

// Auto-disable styling when piped
func isPiped() bool {
    fileInfo, _ := os.Stdout.Stat()
    return (fileInfo.Mode() & os.ModeCharDevice) == 0
}
```

### Pitfall 2: Not Respecting NO_COLOR

❌ **Wrong**: Ignoring NO_COLOR standard
```go
// Always uses colors, even when NO_COLOR is set
func main() {
    style := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
    fmt.Println(style.Render("Hello"))
}
```

✅ **Correct**: Check NO_COLOR environment variable
```go
func shouldUseColors() bool {
    // Respect NO_COLOR: https://no-color.org/
    if os.Getenv("NO_COLOR") != "" {
        return false
    }

    // Check if output is terminal
    fileInfo, _ := os.Stdout.Stat()
    isTerminal := (fileInfo.Mode() & os.ModeCharDevice) != 0

    return isTerminal
}

func main() {
    useColors := shouldUseColors()

    if useColors {
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
        fmt.Println(style.Render("Hello"))
    } else {
        fmt.Println("Hello")
    }
}
```

### Pitfall 3: Performance Degradation from Style Recreation

❌ **Wrong**: Recreating styles on every render
```go
func RenderTasks(tasks []Task) {
    for _, task := range tasks {
        // Creating new style for EVERY task!
        style := lipgloss.NewStyle().
            Foreground(lipgloss.Color("42")).
            Bold(true)

        fmt.Println(style.Render(task.Title))
    }
}
// With 1000 tasks, creates 1000 style instances
```

✅ **Correct**: Create styles once and reuse
```go
// Package-level style created once
var taskStyle = lipgloss.NewStyle().
    Foreground(lipgloss.Color("42")).
    Bold(true)

func RenderTasks(tasks []Task) {
    for _, task := range tasks {
        // Reuse same style instance
        fmt.Println(taskStyle.Render(task.Title))
    }
}
// With 1000 tasks, reuses single style instance
```

### Pitfall 4: Inconsistent Styling Throughout App

❌ **Wrong**: Different parts use different styles
```go
// In file1.go
func ShowSuccess1(msg string) {
    style := lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
    fmt.Println(style.Render(msg))
}

// In file2.go
func ShowSuccess2(msg string) {
    style := lipgloss.NewStyle().Foreground(lipgloss.Color("46")) // Different green!
    fmt.Println(style.Render(msg))
}
```

✅ **Correct**: Centralized style definitions
```go
// styles/styles.go
package styles

var Success = lipgloss.NewStyle().
    Foreground(lipgloss.Color("42")).
    Prefix("✓ ")

// Used consistently everywhere
func ShowSuccess(msg string) {
    fmt.Println(styles.Success.Render(msg))
}
```

### Pitfall 5: Not Testing Plain Output Mode

❌ **Wrong**: Only testing styled output
```go
func TestTaskList(t *testing.T) {
    // Only tests styled output
    formatter := &OutputFormatter{styled: true}
    // ... test styled output
}
// Plain output untested, might break scripts!
```

✅ **Correct**: Test both styled and plain output
```go
func TestTaskList(t *testing.T) {
    tests := []struct {
        name   string
        styled bool
    }{
        {"styled output", true},
        {"plain output", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            formatter := &OutputFormatter{styled: tt.styled}
            // Test output format
            // Verify expected content present
            // Ensure no ANSI codes in plain mode
        })
    }
}
```

### Pitfall 6: Overusing Styling

❌ **Wrong**: Too many colors and borders everywhere
```go
// Every single line is styled differently
fmt.Println(style1.Render("Line 1"))
fmt.Println(style2.Render("Line 2"))
fmt.Println(style3.Render("Line 3"))
// Result: Visual chaos, hard to read
```

✅ **Correct**: Restrained, purposeful styling
```go
// Use styling for emphasis and structure
fmt.Println(headerStyle.Render("Tasks"))
fmt.Println() // Plain spacing
fmt.Println(task1) // Plain text
fmt.Println(task2)
fmt.Println(successStyle.Render("✓ Complete"))
// Result: Clear hierarchy and emphasis
```

## Extension Challenges

### Extension 1: Animated Transitions
Add smooth animations when switching themes or updating data:
```go
func AnimateThemeChange(from, to Theme, duration time.Duration) {
    // Gradually transition colors over duration
    // Update display smoothly
}

func AnimateProgressBar(from, to int, duration time.Duration) {
    // Smoothly fill progress bar from -> to percentage
}
```

### Extension 2: Custom Style DSL
Create domain-specific language for defining styles:
```go
// styles.yaml
styles:
  success:
    foreground: "42"
    prefix: "✓ "
    bold: true

  error:
    foreground: "196"
    prefix: "✗ "
    bold: true

  table:
    border: rounded
    border_color: "240"
    padding: 1

// Load and use
styles := LoadStylesFromYAML("styles.yaml")
fmt.Println(styles.Success.Render("Done"))
```

### Extension 3: Terminal Recording Integration
Generate terminal recordings automatically for documentation:
```go
// Integration with VHS (https://github.com/charmbracelet/vhs)
func GenerateDemoRecording() {
    recorder := NewRecorder("demo.tape")

    recorder.Type("task list")
    recorder.Sleep(1 * time.Second)
    recorder.Enter()
    recorder.Sleep(2 * time.Second)

    recorder.Type("task add 'New feature'")
    recorder.Enter()
    recorder.Sleep(1 * time.Second)

    recorder.Generate("demo.gif")
}
```

### Extension 4: Interactive Theme Editor
Build TUI for creating and editing themes interactively:
```go
// Interactive theme editor using Bubble Tea
type ThemeEditor struct {
    theme       Theme
    selectedColor string
    colorPicker ColorPicker
}

func (te *ThemeEditor) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    // Handle keyboard input
    // Update theme colors
    // Preview changes live
}

func (te *ThemeEditor) View() string {
    // Show color palette
    // Show theme preview
    // Show controls
}
```

### Extension 5: Screenshot Mode with Padding
Create output optimized for documentation screenshots:
```go
func ScreenshotMode(content string, width int) string {
    // Add padding and borders
    // Use maximum visual polish
    // Include window-like chrome

    titleBar := lipgloss.NewStyle().
        Background(lipgloss.Color("235")).
        Foreground(lipgloss.Color("252")).
        Padding(0, 2).
        Width(width).
        Render("● ● ●  task-tracker")

    contentArea := lipgloss.NewStyle().
        Border(lipgloss.NormalBorder()).
        BorderForeground(lipgloss.Color("240")).
        Width(width).
        Padding(2).
        Render(content)

    screenshot := lipgloss.JoinVertical(lipgloss.Left,
        titleBar,
        contentArea,
    )

    // Add drop shadow effect
    return addShadow(screenshot)
}
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Analysis**: Study existing CLI to identify styling opportunities
2. **Infrastructure**: Build OutputFormatter with dual output modes
3. **Style Library**: Create reusable style definitions
4. **Refactoring**: Systematically replace output with styled versions
5. **Testing**: Verify both styled and plain output work correctly
6. **Documentation**: Create before/after comparisons

### Code Organization

```
enhanced-app/
├── cmd/
│   └── root.go              # CLI commands with formatter
├── internal/
│   ├── output/
│   │   ├── formatter.go     # OutputFormatter
│   │   └── formatter_test.go
│   ├── styles/
│   │   ├── styles.go        # Style definitions
│   │   └── theme.go         # Theme system
│   ├── task/
│   │   └── task.go          # Business logic (unchanged)
├── demo/
│   ├── before.go            # Plain output demo
│   └── after.go             # Styled output demo
├── README.md                # With screenshots
└── go.mod
```

### Quality Checklist

- [ ] Both styled and plain output work
- [ ] --no-color flag implemented
- [ ] NO_COLOR environment variable respected
- [ ] Auto-detect terminal vs pipe
- [ ] Styles cached for performance
- [ ] Theme system (if using themes)
- [ ] Help text enhanced
- [ ] All commands styled consistently
- [ ] Backwards compatibility maintained
- [ ] Tests for both output modes

### Testing Approach

Comprehensive testing strategy:

```bash
# Unit tests
go test ./... -v

# Integration tests - styled output
./app list
./app add "Task"

# Integration tests - plain output
./app list --no-color
NO_COLOR=1 ./app list

# Piped output
./app list | cat
./app list > output.txt

# Performance benchmark
go test -bench=. -benchmem

# Cross-terminal testing
# iTerm2, Terminal.app, Alacritty, Kitty, Windows Terminal
```

## Learning Resources

### Official Documentation
- [Lip Gloss Best Practices](https://github.com/charmbracelet/lipgloss#best-practices) - Usage guidelines
- [NO_COLOR Standard](https://no-color.org/) - Environment variable specification
- [Terminal Detection](https://pkg.go.dev/golang.org/x/term) - Detecting terminal capabilities
- [Cobra Documentation](https://github.com/spf13/cobra) - CLI framework integration

### Tutorials and Guides
- [Refactoring CLI Apps](https://charm.sh/blog/refactoring-cli-apps) - Adding Lip Gloss to existing CLIs
- [CLI UX Best Practices](https://clig.dev/) - Command-line interface guidelines
- [Terminal Output Design](https://github.com/charmbracelet/lipgloss/wiki/Terminal-Output) - Design principles
- [Performance Optimization](https://charm.sh/blog/performance) - Optimizing styled output

### Related Tools and Examples
- [Glow Source](https://github.com/charmbracelet/glow) - Real-world Lip Gloss usage
- [Soft Serve Source](https://github.com/charmbracelet/soft-serve) - Complex CLI enhancement
- [gh-dash Source](https://github.com/dlvhdr/gh-dash) - GitHub dashboard with styling
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI example

### CLI Design Resources
- [Command Line Interface Guidelines](https://clig.dev/) - CLI design best practices
- [12 Factor CLI Apps](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46) - CLI architecture
- [POSIX Utility Conventions](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html) - Standards
- [Unix Philosophy](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html) - Design principles

## Validation Commands

```bash
# Build enhanced applications
cd lesson-18/enhanced-task-tracker && go build
cd lesson-18/git-status-viz && go build
cd lesson-18/system-monitor && go build

# Test styled output
./enhanced-task-tracker/task list
./git-status-viz/gitstatus
./system-monitor/sysmon --snapshot

# Test plain output
./enhanced-task-tracker/task list --no-color
./git-status-viz/gitstatus --no-color
./system-monitor/sysmon --no-color --snapshot

# Test NO_COLOR environment variable
NO_COLOR=1 ./enhanced-task-tracker/task list
NO_COLOR=1 ./git-status-viz/gitstatus

# Test piped output
./enhanced-task-tracker/task list | cat
./enhanced-task-tracker/task list > output.txt
cat output.txt  # Verify plain text

# Test themes
./enhanced-task-tracker/task list --theme dracula
./enhanced-task-tracker/task list --theme solarized
./enhanced-task-tracker/task list --theme minimal

# Test before/after demo
./enhanced-task-tracker/task demo

# Run all tests
go test ./lesson-18/... -v

# Check test coverage
go test ./lesson-18/... -cover

# Performance benchmark
go test ./lesson-18/... -bench=. -benchmem

# Test in different terminals
# iTerm2
./enhanced-task-tracker/task list

# Terminal.app
./enhanced-task-tracker/task list

# Alacritty
./enhanced-task-tracker/task list

# Test with output redirection
./enhanced-task-tracker/task list > tasks.txt
./enhanced-task-tracker/task list 2>&1 | tee output.log

# Run with race detector
go test ./lesson-18/... -race

# Format code
go fmt ./lesson-18/...

# Vet code
go vet ./lesson-18/...
```

---

**Next Lesson**: [Lesson 19: Introduction to Goroutines](../specifications/lesson-19-goroutines-intro.md) - Begin Phase 4: Concurrency

**Previous Lesson**: [Lesson 17: Adaptive Styling & Theming](lesson-17-lipgloss-theming.md) - Terminal-aware color adaptation

**Phase Overview**: [Phase 3: Styling with Lip Gloss](../README.md#phase-3-styling-with-lip-gloss-week-5) - Phase 3 Milestone Complete!
