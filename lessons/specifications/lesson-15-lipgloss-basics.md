# Lesson 15: Lip Gloss Basics - Colors & Borders

**Phase**: 3 - Styling with Lip Gloss
**Difficulty**: Beginner
**Estimated Time**: 2-3 hours

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Install and configure** Lip Gloss in Go projects for terminal styling
2. **Create styled text** using method chaining with colors, backgrounds, and formatting
3. **Apply border styles** (rounded, double, thick, custom) to content blocks
4. **Use padding and margins** to control whitespace and layout
5. **Align text** within styled blocks (left, center, right)
6. **Style semantic output** (errors, warnings, success, info) with consistent patterns
7. **Build reusable style definitions** for consistent UI across CLI applications
8. **Test styled output** to ensure visual correctness and degradation

## Prerequisites

- **Required**: Completion of Lessons 01-14 (Go fundamentals + CLI development)
- **Concepts**: String formatting, CLI output, ANSI color codes (helpful but not required)
- **Tools**: Go 1.20+, terminal with color support
- **Setup**: Completed Task Tracker CLI milestone (Lesson 13)
- **Knowledge**: Basic understanding of CLI user experience

## Core Concepts

### 1. Introduction to Lip Gloss

Lip Gloss is a library for styling CLI output with colors, borders, padding, and layout. It's part of the Charm.sh ecosystem and used by popular tools like Glow, Soft Serve, and VHS.

**Why Lip Gloss?**
- 🎨 **Declarative styling**: Define styles once, apply everywhere
- 🔄 **Method chaining**: Fluent API for composing styles
- 🖥️ **Terminal-aware**: Automatic color degradation for limited terminals
- 🧩 **Composable**: Combine styles to build complex layouts
- 📦 **Zero dependencies**: Pure Go, no external tools needed

**Installation**:
```bash
go get github.com/charmbracelet/lipgloss
```

**Basic example**:
```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func main() {
    // Create a style
    style := lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Background(lipgloss.Color("235")).
        Bold(true).
        Padding(1, 2)

    // Apply style to text
    fmt.Println(style.Render("Hello, Lip Gloss!"))
}
```

### 2. Color System

Lip Gloss supports multiple color formats for maximum compatibility:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateColors() {
    // ANSI 256-color palette (0-255)
    style1 := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))

    // Hex colors (true color terminals)
    style2 := lipgloss.NewStyle().Foreground(lipgloss.Color("#FF00FF"))

    // ANSI color names
    style3 := lipgloss.NewStyle().Foreground(lipgloss.Color("magenta"))

    // Adaptive colors (light/dark terminal aware)
    style4 := lipgloss.NewStyle().Foreground(lipgloss.AdaptiveColor{
        Light: "235", // Dark text for light backgrounds
        Dark:  "252", // Light text for dark backgrounds
    })

    fmt.Println(style1.Render("ANSI 256 color"))
    fmt.Println(style2.Render("Hex color"))
    fmt.Println(style3.Render("Named color"))
    fmt.Println(style4.Render("Adaptive color"))
}
```

**Color categories**:
- **Foreground**: Text color
- **Background**: Background color behind text
- **ANSI 256**: Maximum compatibility (0-255)
- **True color**: 24-bit RGB for modern terminals
- **Adaptive**: Different colors for light/dark themes

### 3. Text Styling and Formatting

Basic text formatting options:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateFormatting() {
    // Bold text
    bold := lipgloss.NewStyle().Bold(true)
    fmt.Println(bold.Render("Bold text"))

    // Italic text
    italic := lipgloss.NewStyle().Italic(true)
    fmt.Println(italic.Render("Italic text"))

    // Underline
    underline := lipgloss.NewStyle().Underline(true)
    fmt.Println(underline.Render("Underlined text"))

    // Strikethrough
    strikethrough := lipgloss.NewStyle().Strikethrough(true)
    fmt.Println(strikethrough.Render("Strikethrough text"))

    // Faint/dim
    faint := lipgloss.NewStyle().Faint(true)
    fmt.Println(faint.Render("Faint text"))

    // Blink (rarely supported, avoid in production)
    blink := lipgloss.NewStyle().Blink(true)
    fmt.Println(blink.Render("Blinking text"))

    // Reverse (swap foreground and background)
    reverse := lipgloss.NewStyle().Reverse(true)
    fmt.Println(reverse.Render("Reversed text"))

    // Combine multiple styles
    combined := lipgloss.NewStyle().
        Bold(true).
        Italic(true).
        Foreground(lipgloss.Color("205"))
    fmt.Println(combined.Render("Bold italic colored text"))
}
```

### 4. Border Styles

Lip Gloss provides built-in border styles and custom border support:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateBorders() {
    content := "Bordered content"

    // Normal (single-line) border
    normal := lipgloss.NewStyle().
        Border(lipgloss.NormalBorder()).
        Padding(1)
    fmt.Println(normal.Render(content))

    // Rounded border
    rounded := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("205")).
        Padding(1)
    fmt.Println(rounded.Render(content))

    // Double border
    double := lipgloss.NewStyle().
        Border(lipgloss.DoubleBorder()).
        Padding(1)
    fmt.Println(double.Render(content))

    // Thick border
    thick := lipgloss.NewStyle().
        Border(lipgloss.ThickBorder()).
        Padding(1)
    fmt.Println(thick.Render(content))

    // Hidden border (spacing without lines)
    hidden := lipgloss.NewStyle().
        Border(lipgloss.HiddenBorder()).
        Padding(1)
    fmt.Println(hidden.Render(content))

    // Partial borders (only top/bottom/left/right)
    topBottom := lipgloss.NewStyle().
        BorderTop(true).
        BorderBottom(true).
        BorderStyle(lipgloss.NormalBorder()).
        Padding(1, 2)
    fmt.Println(topBottom.Render(content))

    // Custom border colors
    coloredBorder := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("205")).
        BorderBackground(lipgloss.Color("235")).
        Padding(1, 2)
    fmt.Println(coloredBorder.Render(content))
}
```

**Border types**:
- `NormalBorder()`: `─│┌┐└┘├┤┬┴┼` (Unicode box drawing)
- `RoundedBorder()`: `─│╭╮╰╯├┤┬┴┼` (Rounded corners)
- `DoubleBorder()`: `═║╔╗╚╝╠╣╦╩╬` (Double lines)
- `ThickBorder()`: `━┃┏┓┗┛┣┫┳┻╋` (Thick lines)
- `HiddenBorder()`: Invisible border for spacing

### 5. Padding and Margins

Control whitespace around content:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateSpacing() {
    content := "Content with spacing"

    // Uniform padding (all sides)
    uniformPadding := lipgloss.NewStyle().
        Padding(2).
        Background(lipgloss.Color("235"))
    fmt.Println(uniformPadding.Render(content))

    // Different padding (vertical, horizontal)
    asymmetricPadding := lipgloss.NewStyle().
        Padding(1, 3). // 1 top/bottom, 3 left/right
        Background(lipgloss.Color("235"))
    fmt.Println(asymmetricPadding.Render(content))

    // Individual padding sides (top, right, bottom, left)
    individualPadding := lipgloss.NewStyle().
        PaddingTop(1).
        PaddingRight(3).
        PaddingBottom(1).
        PaddingLeft(2).
        Background(lipgloss.Color("235"))
    fmt.Println(individualPadding.Render(content))

    // Margins (spacing outside style)
    withMargin := lipgloss.NewStyle().
        Margin(1, 2).
        Background(lipgloss.Color("235")).
        Padding(1)
    fmt.Println(withMargin.Render(content))

    // Combining padding and margins
    combined := lipgloss.NewStyle().
        Padding(1, 2).
        Margin(1).
        Border(lipgloss.RoundedBorder()).
        Background(lipgloss.Color("235"))
    fmt.Println(combined.Render(content))
}
```

**Spacing patterns**:
- `Padding(n)`: n units all sides
- `Padding(v, h)`: v top/bottom, h left/right
- `Padding(t, h, b)`: top, horizontal, bottom
- `Padding(t, r, b, l)`: top, right, bottom, left (clockwise)
- Same patterns work for `Margin()`

### 6. Text Alignment

Align text within styled blocks:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateAlignment() {
    // Left-aligned (default)
    left := lipgloss.NewStyle().
        Width(30).
        Border(lipgloss.RoundedBorder()).
        Align(lipgloss.Left)
    fmt.Println(left.Render("Left aligned"))

    // Center-aligned
    center := lipgloss.NewStyle().
        Width(30).
        Border(lipgloss.RoundedBorder()).
        Align(lipgloss.Center)
    fmt.Println(center.Render("Center aligned"))

    // Right-aligned
    right := lipgloss.NewStyle().
        Width(30).
        Border(lipgloss.RoundedBorder()).
        Align(lipgloss.Right)
    fmt.Println(right.Render("Right aligned"))

    // Vertical alignment
    topAlign := lipgloss.NewStyle().
        Width(30).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        AlignVertical(lipgloss.Top)
    fmt.Println(topAlign.Render("Top"))

    middleAlign := lipgloss.NewStyle().
        Width(30).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        AlignVertical(lipgloss.Center)
    fmt.Println(middleAlign.Render("Middle"))

    bottomAlign := lipgloss.NewStyle().
        Width(30).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        AlignVertical(lipgloss.Bottom)
    fmt.Println(bottomAlign.Render("Bottom"))
}
```

### 7. Reusable Style Definitions

Create consistent styling across your application:

```go
package styles

import "github.com/charmbracelet/lipgloss"

// Color palette
var (
    Primary   = lipgloss.Color("205")
    Secondary = lipgloss.Color("135")
    Success   = lipgloss.Color("42")
    Warning   = lipgloss.Color("214")
    Error     = lipgloss.Color("196")
    Info      = lipgloss.Color("39")
    Muted     = lipgloss.Color("243")
)

// Base styles
var (
    BaseStyle = lipgloss.NewStyle().
        Padding(1, 2)

    HeaderStyle = lipgloss.NewStyle().
        Bold(true).
        Foreground(Primary).
        Padding(0, 1)

    BoxStyle = lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(Primary).
        Padding(1, 2)
)

// Semantic styles
var (
    SuccessStyle = lipgloss.NewStyle().
        Foreground(Success).
        Bold(true).
        Prefix("✓ ")

    ErrorStyle = lipgloss.NewStyle().
        Foreground(Error).
        Bold(true).
        Prefix("✗ ")

    WarningStyle = lipgloss.NewStyle().
        Foreground(Warning).
        Bold(true).
        Prefix("⚠ ")

    InfoStyle = lipgloss.NewStyle().
        Foreground(Info).
        Prefix("ℹ ")
)

// Usage
func FormatSuccess(msg string) string {
    return SuccessStyle.Render(msg)
}

func FormatError(msg string) string {
    return ErrorStyle.Render(msg)
}

func FormatWarning(msg string) string {
    return WarningStyle.Render(msg)
}

func FormatInfo(msg string) string {
    return InfoStyle.Render(msg)
}
```

**Usage in application**:
```go
package main

import (
    "fmt"
    "myapp/styles"
)

func main() {
    fmt.Println(styles.FormatSuccess("Operation completed successfully"))
    fmt.Println(styles.FormatError("Failed to connect to server"))
    fmt.Println(styles.FormatWarning("Configuration file not found, using defaults"))
    fmt.Println(styles.FormatInfo("Processing 1,234 items..."))
}
```

### 8. Method Chaining and Style Composition

Build complex styles through method chaining:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateChaining() {
    // Method chaining for complex styles
    fancyStyle := lipgloss.NewStyle().
        Bold(true).
        Italic(false).
        Foreground(lipgloss.Color("205")).
        Background(lipgloss.Color("235")).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("135")).
        Padding(1, 3).
        Margin(1).
        Width(40).
        Align(lipgloss.Center)

    fmt.Println(fancyStyle.Render("Fully styled content"))

    // Inherit and override styles
    baseStyle := lipgloss.NewStyle().
        Padding(1, 2).
        Border(lipgloss.RoundedBorder())

    successStyle := baseStyle.Copy().
        BorderForeground(lipgloss.Color("42")). // Green
        Foreground(lipgloss.Color("42"))

    errorStyle := baseStyle.Copy().
        BorderForeground(lipgloss.Color("196")). // Red
        Foreground(lipgloss.Color("196"))

    fmt.Println(successStyle.Render("Success message"))
    fmt.Println(errorStyle.Render("Error message"))
}
```

### 9. Width and Height Constraints

Control the dimensions of styled blocks:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateDimensions() {
    longText := "This is a very long text that will be wrapped to fit within the specified width constraint. Lip Gloss handles text wrapping automatically."

    // Fixed width
    fixedWidth := lipgloss.NewStyle().
        Width(40).
        Border(lipgloss.RoundedBorder()).
        Padding(1)
    fmt.Println(fixedWidth.Render(longText))

    // Fixed width and height
    fixedBox := lipgloss.NewStyle().
        Width(40).
        Height(10).
        Border(lipgloss.RoundedBorder()).
        Padding(1).
        Align(lipgloss.Center).
        AlignVertical(lipgloss.Center)
    fmt.Println(fixedBox.Render("Centered in box"))

    // MaxWidth (wrap at max but shrink if content is smaller)
    maxWidth := lipgloss.NewStyle().
        MaxWidth(60).
        Border(lipgloss.RoundedBorder()).
        Padding(1)
    fmt.Println(maxWidth.Render("Short text"))
    fmt.Println(maxWidth.Render(longText))
}
```

## Challenge Description

Build three progressively complex styling systems to enhance CLI output with Lip Gloss.

### Challenge 1: Message Styling System

Create a reusable message formatting system for different message types.

**Requirements**:
1. Define styles for 5 message types:
   - Success (green, checkmark prefix)
   - Error (red, X prefix)
   - Warning (yellow, warning prefix)
   - Info (blue, info prefix)
   - Debug (gray, debug prefix)
2. Implement formatting functions for each type
3. Support optional message titles
4. Add bordered variant for important messages
5. Include timestamp formatting (optional)
6. Test all message types with various text lengths

**Example output**:
```
✓ Success: Operation completed successfully
✗ Error: Failed to connect to database
⚠ Warning: Configuration file not found, using defaults
ℹ Info: Processing 1,234 items...
🔍 Debug: Cache hit for key 'user:123'

╭─────────────────────────────────╮
│ ✓ Success                       │
│ Database backup completed       │
│ 1,234 records backed up         │
╰─────────────────────────────────╯
```

### Challenge 2: CLI Banner Generator

Build a tool that generates styled banners and headers for CLI applications.

**Requirements**:
1. Create ASCII art banner from text input
2. Support multiple border styles (rounded, double, thick)
3. Add subtitle support with different styling
4. Include version number display
5. Support different color schemes
6. Implement centering and width control
7. Add optional tagline or description
8. Generate both large (ASCII art) and small (single line) variants

**Example output**:
```
╭───────────────────────────────────────────╮
│                                           │
│   ████████╗ ██████╗  ██████╗ ██╗        │
│   ╚══██╔══╝██╔═══██╗██╔═══██╗██║        │
│      ██║   ██║   ██║██║   ██║██║        │
│      ██║   ██║   ██║██║   ██║██║        │
│      ██║   ╚██████╔╝╚██████╔╝███████╗   │
│      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝   │
│                                           │
│        A command-line task manager        │
│                 v1.2.3                    │
│                                           │
╰───────────────────────────────────────────╯
```

### Challenge 3: Status Dashboard

Create a dashboard-style output system for displaying structured information.

**Requirements**:
1. Display multiple information cards in bordered boxes
2. Show key-value pairs with aligned columns
3. Include progress indicators (text-based)
4. Support different card styles (success, warning, error, info)
5. Add section headers with dividers
6. Implement color-coded status indicators
7. Handle dynamic content widths
8. Support optional card descriptions/subtitles

**Example output**:
```
╭─ System Status ──────────────────────╮
│ CPU Usage:        45% ████████░░     │
│ Memory:           2.3 GB / 16 GB     │
│ Disk Space:       125 GB available   │
│ Uptime:           3 days, 5 hours    │
╰──────────────────────────────────────╯

╭─ Recent Tasks ───────────────────────╮
│ ✓ Deploy to production               │
│ ✓ Run database migrations            │
│ ⚠ Update dependencies (2 pending)   │
│ ⏳ Run integration tests (in progress)│
╰──────────────────────────────────────╯

╭─ Notifications ──────────────────────╮
│ ✗ Build failed on feature-branch    │
│ ℹ 3 new pull requests awaiting review│
╰──────────────────────────────────────╯
```

## Test Requirements

Implement comprehensive tests for styled output and style behavior.

### Test Structure Pattern

```go
package styles

import (
    "strings"
    "testing"
    "github.com/charmbracelet/lipgloss"
)

func TestMessageFormatting(t *testing.T) {
    tests := []struct {
        name         string
        msgType      string
        content      string
        wantPrefix   string
        wantContains string
    }{
        {
            name:         "success message",
            msgType:      "success",
            content:      "Operation completed",
            wantPrefix:   "✓",
            wantContains: "Operation completed",
        },
        {
            name:         "error message",
            msgType:      "error",
            content:      "Connection failed",
            wantPrefix:   "✗",
            wantContains: "Connection failed",
        },
        {
            name:         "warning message",
            msgType:      "warning",
            content:      "Config not found",
            wantPrefix:   "⚠",
            wantContains: "Config not found",
        },
        {
            name:         "empty message",
            msgType:      "info",
            content:      "",
            wantPrefix:   "ℹ",
            wantContains: "",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            var result string
            switch tt.msgType {
            case "success":
                result = FormatSuccess(tt.content)
            case "error":
                result = FormatError(tt.content)
            case "warning":
                result = FormatWarning(tt.content)
            case "info":
                result = FormatInfo(tt.content)
            }

            // Strip ANSI codes for testing
            plain := stripANSI(result)

            if !strings.HasPrefix(plain, tt.wantPrefix) {
                t.Errorf("missing prefix: got %q, want prefix %q", plain, tt.wantPrefix)
            }

            if !strings.Contains(plain, tt.wantContains) {
                t.Errorf("missing content: got %q, want to contain %q", plain, tt.wantContains)
            }
        })
    }
}

// Helper to strip ANSI codes for testing
func stripANSI(s string) string {
    // Simple ANSI stripping (use proper library in production)
    // This is for demonstration purposes
    return s // TODO: implement proper ANSI stripping
}

func TestBorderedBox(t *testing.T) {
    tests := []struct {
        name        string
        content     string
        borderType  lipgloss.Border
        width       int
        wantLines   int
    }{
        {
            name:       "single line content",
            content:    "Hello",
            borderType: lipgloss.RoundedBorder(),
            width:      20,
            wantLines:  3, // top border + content + bottom border
        },
        {
            name:       "multi-line content",
            content:    "Line 1\nLine 2\nLine 3",
            borderType: lipgloss.RoundedBorder(),
            width:      20,
            wantLines:  5, // top + 3 lines + bottom
        },
        {
            name:       "empty content",
            content:    "",
            borderType: lipgloss.NormalBorder(),
            width:      15,
            wantLines:  3, // still has borders
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            style := lipgloss.NewStyle().
                Border(tt.borderType).
                Width(tt.width).
                Padding(1)

            result := style.Render(tt.content)
            lines := strings.Split(result, "\n")

            // Account for padding
            expectedLines := tt.wantLines + 2 // padding adds lines

            if len(lines) != expectedLines {
                t.Errorf("line count: got %d, want %d", len(lines), expectedLines)
            }
        })
    }
}

func TestStyleCopy(t *testing.T) {
    base := lipgloss.NewStyle().
        Padding(1, 2).
        Bold(true)

    modified := base.Copy().
        Foreground(lipgloss.Color("205"))

    // Ensure original unchanged
    baseRendered := base.Render("test")
    modifiedRendered := modified.Render("test")

    if baseRendered == modifiedRendered {
        t.Error("Copy() should create independent style")
    }
}
```

### Required Test Cases

**For Message Styling System**:
1. Each message type formats correctly
2. Prefix symbols appear correctly
3. Empty messages handled gracefully
4. Long messages wrap appropriately
5. Bordered variants render with borders
6. Timestamp formatting (if implemented)

**For CLI Banner Generator**:
1. Text converts to ASCII art correctly
2. Different border styles render properly
3. Version number displays in correct format
4. Centering works for various text lengths
5. Small variant generates correctly
6. Empty input handled gracefully

**For Status Dashboard**:
1. Multiple cards render side-by-side (if applicable)
2. Key-value alignment is consistent
3. Progress indicators display correctly
4. Status colors match message types
5. Dynamic width calculation works
6. Empty sections handled gracefully

## Input/Output Specifications

### Message Styling System

**Input**: Message type + content string
**Output**: Styled message with appropriate colors and prefix

```
Input: FormatSuccess("Database connected")
Output: ✓ Database connected (in green)

Input: FormatError("Connection timeout")
Output: ✗ Connection timeout (in red)

Input: FormatWarningBordered("Low disk space", "Only 5GB remaining")
Output:
╭─────────────────────────────╮
│ ⚠ Low disk space           │
│ Only 5GB remaining          │
╰─────────────────────────────╯
```

### CLI Banner Generator

**Input**: Application name, version, tagline
**Output**: Styled banner with borders

```
Input: GenerateBanner("TaskApp", "1.0.0", "Organize your life")
Output:
╭───────────────────────────────╮
│       TASKAPP v1.0.0          │
│   Organize your life          │
╰───────────────────────────────╯
```

### Status Dashboard

**Input**: Map of sections with key-value data
**Output**: Multi-card dashboard layout

```
Input: {
  "System": {"CPU": "45%", "Memory": "2.3 GB"},
  "Tasks": {"Completed": "12", "Pending": "3"}
}
Output: (formatted dashboard as shown in challenge 3)
```

## Success Criteria

### Functional Requirements
- [ ] All three styling systems work correctly
- [ ] Colors display properly in terminal
- [ ] Borders render with proper Unicode characters
- [ ] Text alignment works (left, center, right)
- [ ] Width and height constraints respected
- [ ] Method chaining produces correct results
- [ ] Style copying creates independent styles

### Code Quality Requirements
- [ ] Styles defined in separate package/module
- [ ] Reusable style definitions for consistency
- [ ] No hardcoded ANSI codes (use Lip Gloss API)
- [ ] Functions have clear, descriptive names
- [ ] Color palette defined as constants
- [ ] Documentation for style usage patterns
- [ ] Examples provided for each style function

### Testing Requirements
- [ ] All styling functions have tests
- [ ] Table-driven tests for multiple cases
- [ ] ANSI codes stripped for text assertions
- [ ] Border rendering tested for different types
- [ ] Edge cases covered (empty input, long text)
- [ ] Style independence verified (Copy() tests)
- [ ] Test coverage >75%

### Visual Requirements
- [ ] Output is readable and aesthetically pleasing
- [ ] Consistent spacing and alignment
- [ ] Appropriate use of colors for semantic meaning
- [ ] No visual artifacts or broken borders
- [ ] Works in both light and dark terminals (if using adaptive colors)
- [ ] Unicode characters display correctly

## Common Pitfalls

### Pitfall 1: Hardcoding ANSI Escape Codes

❌ **Wrong**: Manual ANSI codes
```go
func FormatError(msg string) string {
    return "\x1b[31m✗ " + msg + "\x1b[0m"  // Manual red color
}
```

✅ **Correct**: Use Lip Gloss API
```go
func FormatError(msg string) string {
    style := lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Prefix("✗ ")
    return style.Render(msg)
}
```

**Why**: Lip Gloss handles terminal compatibility, color degradation, and proper ANSI code generation.

### Pitfall 2: Not Using Style.Copy() for Variations

❌ **Wrong**: Modifying original style
```go
baseStyle := lipgloss.NewStyle().Padding(1, 2)

// This modifies baseStyle!
successStyle := baseStyle.Foreground(lipgloss.Color("42"))
errorStyle := baseStyle.Foreground(lipgloss.Color("196"))

// Both successStyle and errorStyle point to same modified style
```

✅ **Correct**: Copy before modifying
```go
baseStyle := lipgloss.NewStyle().Padding(1, 2)

successStyle := baseStyle.Copy().Foreground(lipgloss.Color("42"))
errorStyle := baseStyle.Copy().Foreground(lipgloss.Color("196"))

// successStyle and errorStyle are independent
```

### Pitfall 3: Ignoring Terminal Width

❌ **Wrong**: Fixed width without terminal awareness
```go
style := lipgloss.NewStyle().
    Width(120).  // May be wider than terminal!
    Border(lipgloss.RoundedBorder())
```

✅ **Correct**: Respect terminal dimensions
```go
import "golang.org/x/term"

func getTerminalWidth() int {
    width, _, err := term.GetSize(int(os.Stdout.Fd()))
    if err != nil {
        return 80 // fallback
    }
    return width
}

style := lipgloss.NewStyle().
    Width(getTerminalWidth() - 4).  // Leave margin
    Border(lipgloss.RoundedBorder())
```

### Pitfall 4: Not Testing Visual Output

❌ **Wrong**: No tests for styled output
```go
// Just hope it looks right visually
func FormatHeader(text string) string {
    return headerStyle.Render(text)
}
```

✅ **Correct**: Test output structure
```go
func TestFormatHeader(t *testing.T) {
    result := FormatHeader("Test")

    // Strip ANSI and test structure
    plain := stripANSI(result)

    if !strings.Contains(plain, "Test") {
        t.Error("header missing content")
    }

    // Check for borders if applicable
    if !strings.Contains(plain, "─") {
        t.Error("header missing border")
    }
}
```

### Pitfall 5: Overusing Colors and Effects

❌ **Wrong**: Too many colors and effects
```go
style := lipgloss.NewStyle().
    Bold(true).
    Italic(true).
    Underline(true).
    Blink(true).  // Please no!
    Foreground(lipgloss.Color("205")).
    Background(lipgloss.Color("51"))
// Result: Unreadable rainbow chaos
```

✅ **Correct**: Restrained, semantic styling
```go
// Use colors purposefully
errorStyle := lipgloss.NewStyle().
    Foreground(lipgloss.Color("196")).
    Bold(true).
    Prefix("✗ ")

// Clean, readable output
```

**Design principle**: Less is more. Use color to convey meaning, not decorate.

### Pitfall 6: Not Considering Accessibility

❌ **Wrong**: Color as only indicator
```go
// Only color indicates status
func ShowStatus(success bool, msg string) string {
    if success {
        return lipgloss.NewStyle().Foreground(lipgloss.Color("42")).Render(msg)
    }
    return lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Render(msg)
}
```

✅ **Correct**: Combine color with symbols
```go
func ShowStatus(success bool, msg string) string {
    if success {
        return lipgloss.NewStyle().
            Foreground(lipgloss.Color("42")).
            Prefix("✓ ").  // Visual indicator
            Render(msg)
    }
    return lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Prefix("✗ ").  // Visual indicator
        Render(msg)
}
```

**Why**: Color-blind users and monochrome terminals need non-color indicators.

## Extension Challenges

### Extension 1: Theme System with Color Schemes
Implement switchable themes (light/dark/high-contrast):
```go
type Theme struct {
    Primary    lipgloss.Color
    Secondary  lipgloss.Color
    Success    lipgloss.Color
    Error      lipgloss.Color
    Warning    lipgloss.Color
    Background lipgloss.Color
}

func LoadTheme(name string) Theme {
    switch name {
    case "dark":
        return DarkTheme
    case "light":
        return LightTheme
    default:
        return DefaultTheme
    }
}
```

### Extension 2: Animated Progress Indicators
Create text-based progress bars and spinners:
```go
func RenderProgressBar(percent int, width int) string {
    filled := int(float64(width) * float64(percent) / 100)
    bar := strings.Repeat("█", filled) + strings.Repeat("░", width-filled)

    style := lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Render(bar)

    return fmt.Sprintf("[%s] %d%%", style, percent)
}
```

### Extension 3: Gradient Text Effects
Implement color gradients across text:
```go
func RenderGradient(text string, startColor, endColor lipgloss.Color) string {
    // Interpolate colors across text length
    runes := []rune(text)
    result := ""

    for i, r := range runes {
        progress := float64(i) / float64(len(runes))
        color := interpolateColor(startColor, endColor, progress)

        style := lipgloss.NewStyle().Foreground(color)
        result += style.Render(string(r))
    }

    return result
}
```

### Extension 4: Table Rendering
Build a table renderer with styled headers and cells:
```go
type Table struct {
    Headers []string
    Rows    [][]string
    Style   lipgloss.Style
}

func (t *Table) Render() string {
    // Calculate column widths
    // Render header row with bold style
    // Render data rows with alternating backgrounds
    // Add borders and padding
}
```

### Extension 5: Markdown-like Syntax
Parse simple markdown and render with styles:
```go
func RenderMarkdown(md string) string {
    // Parse markdown:
    // **bold** → bold style
    // *italic* → italic style
    // `code` → monospace with background
    // # Heading → larger, bold, colored
    // > quote → bordered with left accent

    return parsed
}
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Package structure**: Create `styles` package for reusable definitions
2. **Color palette**: Define consistent colors as package constants
3. **Style factory**: Functions returning configured styles
4. **Testing**: Strip ANSI codes for text assertions
5. **Examples**: Provide usage examples for each style

### Code Organization

```
lesson-15/
├── message-styler/
│   ├── main.go           # CLI demo
│   ├── styles/
│   │   ├── styles.go     # Style definitions
│   │   └── styles_test.go
│   └── README.md
├── banner-generator/
│   ├── main.go
│   ├── banner/
│   │   ├── banner.go
│   │   └── banner_test.go
│   └── README.md
└── status-dashboard/
    ├── main.go
    ├── dashboard/
    │   ├── dashboard.go
    │   └── dashboard_test.go
    └── README.md
```

### Quality Checklist

- [ ] Lip Gloss installed via `go get`
- [ ] No hardcoded ANSI escape sequences
- [ ] Style definitions in separate package
- [ ] Color constants defined clearly
- [ ] Method chaining used idiomatically
- [ ] Style.Copy() used for variations
- [ ] Tests strip ANSI codes for assertions
- [ ] Visual examples in README
- [ ] Documentation for style usage
- [ ] Accessible design (symbols + colors)

### Testing Approach

Focus on testing style structure, not rendered appearance:

```go
// Test content presence (strip ANSI)
func TestMessageContent(t *testing.T) {
    msg := FormatSuccess("test message")
    plain := stripANSI(msg)
    if !strings.Contains(plain, "test message") {
        t.Error("message content missing")
    }
}

// Test prefix presence
func TestMessagePrefix(t *testing.T) {
    msg := FormatError("error")
    plain := stripANSI(msg)
    if !strings.HasPrefix(plain, "✗") {
        t.Error("error prefix missing")
    }
}

// Test border presence
func TestBorderedOutput(t *testing.T) {
    msg := RenderBox("content")
    plain := stripANSI(msg)
    if !strings.Contains(plain, "─") {
        t.Error("border missing")
    }
}
```

## Learning Resources

### Official Documentation
- [Lip Gloss GitHub](https://github.com/charmbracelet/lipgloss) - Official repository and docs
- [Lip Gloss Examples](https://github.com/charmbracelet/lipgloss/tree/master/examples) - Official code examples
- [Charm.sh](https://charm.sh) - Charm ecosystem overview
- [ANSI Color Codes](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors) - Understanding terminal colors

### Tutorials and Guides
- [Building Beautiful CLIs with Lip Gloss](https://dev.to/charmbracelet/building-beautiful-clis-with-lip-gloss-1d0) - Charm blog
- [Terminal UI Development](https://charm.sh/blog/) - Charm technical blog
- [Styling CLI Output](https://github.com/charmbracelet/lipgloss/wiki) - Wiki and guides

### Related Tools and Examples
- [Glow](https://github.com/charmbracelet/glow) - Markdown renderer using Lip Gloss
- [Soft Serve](https://github.com/charmbracelet/soft-serve) - Git server with styled output
- [VHS](https://github.com/charmbracelet/vhs) - Terminal recorder with styling
- [Bubble Tea Examples](https://github.com/charmbracelet/bubbletea/tree/master/examples) - TUI examples using Lip Gloss

### Color Resources
- [ANSI 256 Color Chart](https://www.ditig.com/256-colors-cheat-sheet) - Full color palette
- [Terminal Color Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) - Popular themes
- [Accessible Color Palettes](https://www.accessibility-developer-guide.com/knowledge/colors-and-contrast/) - A11y guidelines

## Validation Commands

```bash
# Install Lip Gloss
go get github.com/charmbracelet/lipgloss

# Format code
go fmt ./lesson-15/...

# Run all tests
go test ./lesson-15/... -v

# Check test coverage
go test ./lesson-15/... -cover

# Build all challenges
cd lesson-15/message-styler && go build
cd lesson-15/banner-generator && go build
cd lesson-15/status-dashboard && go build

# Test message styler
./message-styler/message-styler --success "Operation completed"
./message-styler/message-styler --error "Connection failed"
./message-styler/message-styler --warning "Config not found"

# Test banner generator
./banner-generator/banner-generator --name "MyApp" --version "1.0.0"
./banner-generator/banner-generator --name "TaskTracker" --border rounded

# Test status dashboard
./status-dashboard/status-dashboard --demo
./status-dashboard/status-dashboard --live

# Verify in different terminals
# Test with: iTerm2, Terminal.app, Alacritty, Kitty, Windows Terminal
```

---

**Next Lesson**: [Lesson 16: Layout & Composition](lesson-16-lipgloss-layout.md) - Complex layouts with JoinHorizontal/JoinVertical

**Previous Lesson**: [Lesson 14: API Integration & HTTP Clients](lesson-14-api-integration.md) - HTTP clients and external APIs

**Phase Overview**: [Phase 3: Styling with Lip Gloss](../README.md#phase-3-styling-with-lip-gloss-week-5) - Terminal styling before TUI complexity
