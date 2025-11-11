# Lesson 16: Lip Gloss Layout & Composition

**Phase**: 3 - Styling with Lip Gloss
**Difficulty**: Intermediate
**Estimated Time**: 3-4 hours

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Combine styled blocks horizontally** using `lipgloss.JoinHorizontal()` for multi-column layouts
2. **Stack content vertically** using `lipgloss.JoinVertical()` for structured layouts
3. **Position elements absolutely** using `lipgloss.Place()` for precise control
4. **Implement multi-column layouts** with proper alignment and spacing
5. **Build dashboard-style interfaces** with multiple information cards
6. **Create table-like structures** using joined rows and columns
7. **Control dimensions** using Width, Height, MaxWidth, and MaxHeight constraints
8. **Compose complex UIs** by nesting and combining layout primitives

## Prerequisites

- **Required**: Completion of Lesson 15 (Lip Gloss Basics - Colors & Borders)
- **Concepts**: Colors, borders, padding, alignment from Lesson 15
- **Tools**: Go 1.20+, Lip Gloss installed (`go get github.com/charmbracelet/lipgloss`)
- **Knowledge**: Method chaining, style composition patterns
- **Foundation**: Understanding of terminal coordinate system

## Core Concepts

### 1. Horizontal Joining - Side-by-Side Layouts

`JoinHorizontal()` combines multiple strings or styled blocks into a single horizontal row with proper alignment.

**Basic horizontal joining**:
```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateHorizontalJoining() {
    // Create styled blocks
    leftStyle := lipgloss.NewStyle().
        Width(20).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("205")).
        Padding(1).
        Align(lipgloss.Center)

    rightStyle := lipgloss.NewStyle().
        Width(20).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("135")).
        Padding(1).
        Align(lipgloss.Center)

    left := leftStyle.Render("Left Panel")
    right := rightStyle.Render("Right Panel")

    // Join horizontally with top alignment
    combined := lipgloss.JoinHorizontal(lipgloss.Top, left, right)
    fmt.Println(combined)

    // Join with center alignment
    combined = lipgloss.JoinHorizontal(lipgloss.Center, left, right)
    fmt.Println(combined)

    // Join with bottom alignment
    combined = lipgloss.JoinHorizontal(lipgloss.Bottom, left, right)
    fmt.Println(combined)
}
```

**Alignment options**:
- `lipgloss.Top`: Align tops of blocks
- `lipgloss.Center`: Align centers vertically
- `lipgloss.Bottom`: Align bottoms of blocks
- `lipgloss.Left`: Align left edges (for vertical joining)
- `lipgloss.Right`: Align right edges (for vertical joining)

### 2. Vertical Joining - Stacking Layouts

`JoinVertical()` stacks multiple strings or styled blocks vertically with proper alignment.

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateVerticalJoining() {
    headerStyle := lipgloss.NewStyle().
        Width(40).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("205")).
        Padding(1).
        Align(lipgloss.Center).
        Bold(true)

    contentStyle := lipgloss.NewStyle().
        Width(40).
        Border(lipgloss.NormalBorder()).
        BorderForeground(lipgloss.Color("243")).
        Padding(1)

    footerStyle := lipgloss.NewStyle().
        Width(40).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("39")).
        Padding(1).
        Align(lipgloss.Center).
        Faint(true)

    header := headerStyle.Render("Application Header")
    content := contentStyle.Render("This is the main content area.\nIt can contain multiple lines.")
    footer := footerStyle.Render("Footer - Version 1.0.0")

    // Stack vertically with left alignment
    layout := lipgloss.JoinVertical(lipgloss.Left, header, content, footer)
    fmt.Println(layout)

    // Stack with center alignment
    layout = lipgloss.JoinVertical(lipgloss.Center, header, content, footer)
    fmt.Println(layout)

    // Stack with right alignment
    layout = lipgloss.JoinVertical(lipgloss.Right, header, content, footer)
    fmt.Println(layout)
}
```

### 3. Absolute Positioning with Place()

`Place()` positions content within a defined width and height with precise control over horizontal and vertical alignment.

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstratePlacement() {
    // Create a canvas area
    width, height := 60, 15

    // Content to place
    content := lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Bold(true).
        Render("Positioned Content")

    // Top-left corner
    placed := lipgloss.Place(width, height,
        lipgloss.Left, lipgloss.Top,
        content)
    fmt.Println(placed)

    // Center-center
    placed = lipgloss.Place(width, height,
        lipgloss.Center, lipgloss.Center,
        content)
    fmt.Println(placed)

    // Bottom-right corner
    placed = lipgloss.Place(width, height,
        lipgloss.Right, lipgloss.Bottom,
        content)
    fmt.Println(placed)

    // Top-center
    placed = lipgloss.Place(width, height,
        lipgloss.Center, lipgloss.Top,
        content)
    fmt.Println(placed)
}
```

**Place() parameters**:
```go
lipgloss.Place(
    width int,           // Width of container
    height int,          // Height of container
    hPos lipgloss.Position, // Horizontal position (Left, Center, Right)
    vPos lipgloss.Position, // Vertical position (Top, Center, Bottom)
    content string,      // Content to place
    opts ...PlaceOption, // Optional whitespace style
)
```

### 4. Multi-Column Layouts

Build complex multi-column layouts by combining horizontal and vertical joining:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateMultiColumn() {
    // Define column style
    columnStyle := lipgloss.NewStyle().
        Width(25).
        Border(lipgloss.RoundedBorder()).
        Padding(1).
        MarginRight(1)

    // Column 1: System Info
    col1 := columnStyle.Copy().
        BorderForeground(lipgloss.Color("42")).
        Render("System Info\n\nCPU: 45%\nMemory: 2.3GB\nDisk: 125GB free")

    // Column 2: Tasks
    col2 := columnStyle.Copy().
        BorderForeground(lipgloss.Color("214")).
        Render("Tasks\n\n✓ Deploy app\n✓ Run tests\n⏳ Documentation")

    // Column 3: Notifications
    col3 := columnStyle.Copy().
        BorderForeground(lipgloss.Color("196")).
        MarginRight(0). // No margin on last column
        Render("Notifications\n\n✗ Build failed\nℹ 3 new PRs\n⚠ Update deps")

    // Combine columns
    layout := lipgloss.JoinHorizontal(lipgloss.Top, col1, col2, col3)
    fmt.Println(layout)
}
```

### 5. Dashboard-Style Interfaces

Create information-rich dashboards using nested layout structures:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateDashboard() {
    // Header
    headerStyle := lipgloss.NewStyle().
        Width(78).
        Background(lipgloss.Color("62")).
        Foreground(lipgloss.Color("230")).
        Padding(1).
        Bold(true).
        Align(lipgloss.Center)

    header := headerStyle.Render("System Dashboard - Live Status")

    // Metrics row
    metricStyle := lipgloss.NewStyle().
        Width(24).
        Border(lipgloss.RoundedBorder()).
        Padding(1).
        Align(lipgloss.Center)

    metric1 := metricStyle.Copy().
        BorderForeground(lipgloss.Color("42")).
        Render("Uptime\n\n3d 5h 12m")

    metric2 := metricStyle.Copy().
        BorderForeground(lipgloss.Color("214")).
        Render("Requests\n\n1,234,567")

    metric3 := metricStyle.Copy().
        BorderForeground(lipgloss.Color("39")).
        Render("Errors\n\n23 (0.002%)")

    metricsRow := lipgloss.JoinHorizontal(lipgloss.Top,
        metric1, " ", metric2, " ", metric3)

    // Activity panel
    activityStyle := lipgloss.NewStyle().
        Width(78).
        Border(lipgloss.NormalBorder()).
        BorderForeground(lipgloss.Color("243")).
        Padding(1)

    activity := activityStyle.Render(
        "Recent Activity\n\n" +
            "15:42 - Deployment to production successful\n" +
            "15:40 - Database backup completed\n" +
            "15:38 - Cache cleared (12,345 items)",
    )

    // Combine all sections
    dashboard := lipgloss.JoinVertical(lipgloss.Left,
        header,
        "",
        metricsRow,
        "",
        activity,
    )

    fmt.Println(dashboard)
}
```

### 6. Table-Like Structures

Create table layouts using joined rows and aligned columns:

```go
package main

import (
    "fmt"
    "strings"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateTable() {
    // Table cell style
    cellStyle := lipgloss.NewStyle().
        Width(20).
        Padding(0, 1)

    headerStyle := cellStyle.Copy().
        Bold(true).
        Foreground(lipgloss.Color("205")).
        BorderBottom(true).
        BorderStyle(lipgloss.NormalBorder())

    // Header row
    headers := []string{"Name", "Status", "Duration"}
    headerCells := make([]string, len(headers))
    for i, h := range headers {
        headerCells[i] = headerStyle.Render(h)
    }
    headerRow := lipgloss.JoinHorizontal(lipgloss.Top, headerCells...)

    // Data rows
    data := [][]string{
        {"Build", "✓ Success", "2m 34s"},
        {"Test", "✓ Success", "1m 12s"},
        {"Deploy", "⏳ Running", "0m 45s"},
    }

    rows := []string{headerRow}

    for _, rowData := range data {
        cells := make([]string, len(rowData))
        for i, d := range rowData {
            // Color based on status
            style := cellStyle.Copy()
            if strings.Contains(d, "✓") {
                style = style.Foreground(lipgloss.Color("42"))
            } else if strings.Contains(d, "⏳") {
                style = style.Foreground(lipgloss.Color("214"))
            }
            cells[i] = style.Render(d)
        }
        rows = append(rows, lipgloss.JoinHorizontal(lipgloss.Top, cells...))
    }

    // Combine rows
    table := lipgloss.JoinVertical(lipgloss.Left, rows...)

    // Wrap in border
    tableStyle := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("240")).
        Padding(1)

    fmt.Println(tableStyle.Render(table))
}
```

### 7. Width and Height Constraints

Control the dimensions of layouts using various constraint methods:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateDimensions() {
    content := "This is some content that may need to be constrained to specific dimensions."

    // Fixed width and height
    fixedStyle := lipgloss.NewStyle().
        Width(40).
        Height(5).
        Border(lipgloss.RoundedBorder()).
        Padding(1)

    fmt.Println("Fixed dimensions (40x5):")
    fmt.Println(fixedStyle.Render(content))

    // MaxWidth (shrinks if content is smaller)
    maxWidthStyle := lipgloss.NewStyle().
        MaxWidth(60).
        Border(lipgloss.RoundedBorder()).
        Padding(1)

    fmt.Println("\nMaxWidth 60 (shrinks to fit):")
    fmt.Println(maxWidthStyle.Render("Short"))
    fmt.Println(maxWidthStyle.Render(content))

    // MaxHeight (shrinks if content is smaller)
    maxHeightStyle := lipgloss.NewStyle().
        Width(40).
        MaxHeight(10).
        Border(lipgloss.RoundedBorder()).
        Padding(1)

    fmt.Println("\nMaxHeight 10:")
    fmt.Println(maxHeightStyle.Render(content))

    // UnsetWidth and UnsetHeight (remove constraints)
    constrainedStyle := lipgloss.NewStyle().
        Width(50).
        Height(5)

    unconstrainedStyle := constrainedStyle.Copy().
        UnsetWidth().
        UnsetHeight()

    fmt.Println("\nUnconstrained:")
    fmt.Println(unconstrainedStyle.Render(content))
}
```

**Dimension methods**:
- `Width(n)`: Set exact width
- `Height(n)`: Set exact height
- `MaxWidth(n)`: Maximum width (shrinks if content is smaller)
- `MaxHeight(n)`: Maximum height (shrinks if content is smaller)
- `UnsetWidth()`: Remove width constraint
- `UnsetHeight()`: Remove height constraint

### 8. Complex Nested Compositions

Build sophisticated layouts by nesting joins and combining primitives:

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateNestedComposition() {
    // Left sidebar
    sidebarStyle := lipgloss.NewStyle().
        Width(20).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("62")).
        Padding(1)

    sidebar := sidebarStyle.Render(
        "Navigation\n\n" +
            "• Dashboard\n" +
            "• Tasks\n" +
            "• Settings\n" +
            "• Help",
    )

    // Main content area - nested layout
    // Top panel
    topPanelStyle := lipgloss.NewStyle().
        Width(55).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("205")).
        Padding(1)

    topPanel := topPanelStyle.Render("Main Content Area\n\nThis is where primary content appears.")

    // Bottom panel - two columns
    bottomLeftStyle := lipgloss.NewStyle().
        Width(26).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("214")).
        Padding(1)

    bottomRightStyle := lipgloss.NewStyle().
        Width(26).
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("39")).
        Padding(1)

    bottomLeft := bottomLeftStyle.Render("Details\n\nAdditional info here")
    bottomRight := bottomRightStyle.Render("Actions\n\n• Save\n• Cancel")

    bottomPanel := lipgloss.JoinHorizontal(lipgloss.Top, bottomLeft, " ", bottomRight)

    // Combine main area
    mainArea := lipgloss.JoinVertical(lipgloss.Left, topPanel, "", bottomPanel)

    // Final layout: sidebar + main area
    layout := lipgloss.JoinHorizontal(lipgloss.Top, sidebar, "  ", mainArea)

    fmt.Println(layout)
}
```

### 9. Responsive Layout Patterns

Create layouts that adapt to terminal size:

```go
package main

import (
    "fmt"
    "os"
    "github.com/charmbracelet/lipgloss"
    "golang.org/x/term"
)

func demonstrateResponsiveLayout() {
    // Get terminal width
    width, _, err := term.GetSize(int(os.Stdout.Fd()))
    if err != nil {
        width = 80 // fallback
    }

    // Calculate column widths
    margin := 4
    columnCount := 3
    columnWidth := (width - margin*columnCount) / columnCount

    // Create responsive columns
    columnStyle := lipgloss.NewStyle().
        Width(columnWidth).
        Border(lipgloss.RoundedBorder()).
        Padding(1).
        MarginRight(1)

    col1 := columnStyle.Render("Column 1\n\nAdapts to\nterminal width")
    col2 := columnStyle.Render("Column 2\n\nResizes\nautomatically")
    col3 := columnStyle.Copy().
        MarginRight(0).
        Render("Column 3\n\nResponsive\nlayout")

    layout := lipgloss.JoinHorizontal(lipgloss.Top, col1, col2, col3)

    fmt.Printf("Terminal width: %d\n", width)
    fmt.Printf("Column width: %d\n\n", columnWidth)
    fmt.Println(layout)
}
```

## Challenge Description

Build three progressively complex layout systems using Lip Gloss composition primitives.

### Challenge 1: Dashboard Layout Engine

Create a configurable dashboard layout system that renders information cards in a grid.

**Requirements**:
1. Support 2-column and 3-column layouts
2. Create reusable card component with title and content
3. Implement different card styles (success, warning, error, info)
4. Add header and footer sections
5. Support variable-height cards (content-based)
6. Center-align the entire dashboard
7. Add spacing between cards
8. Implement responsive width adjustment

**Example output**:
```
═══════════════════════════════════════════════════════════════
                     System Dashboard v1.0
═══════════════════════════════════════════════════════════════

╭─ CPU Usage ──────────╮  ╭─ Memory ─────────────╮  ╭─ Disk ────────────────╮
│                      │  │                      │  │                       │
│      45%             │  │    2.3 GB / 16 GB    │  │   125 GB available    │
│  ████████░░          │  │    ████████░░        │  │   ████████████░       │
│                      │  │                      │  │                       │
╰──────────────────────╯  ╰──────────────────────╯  ╰───────────────────────╯

╭─ Recent Tasks ───────────────────────────────────────────────────────────╮
│ ✓ Deploy to production               15:42                              │
│ ✓ Run database migrations            15:40                              │
│ ⏳ Update dependencies (in progress)  15:38                              │
╰──────────────────────────────────────────────────────────────────────────╯

╭─ Alerts ─────────────╮  ╭─ Notifications ──────╮  ╭─ Status ──────────────╮
│ ✗ Build failed       │  │ 3 new PRs           │  │ ✓ All systems normal  │
│ ⚠ Low disk space     │  │ 5 issues closed     │  │ Uptime: 3d 5h 12m     │
╰──────────────────────╯  ╰──────────────────────╯  ╰───────────────────────╯

───────────────────────────────────────────────────────────────
               Last updated: 2024-01-15 15:43:22
```

### Challenge 2: Split-Pane File Manager Layout

Build a two-pane file manager layout with navigation, preview, and status bar.

**Requirements**:
1. Create left pane for directory listing (fixed width)
2. Create right pane for file preview (remaining width)
3. Add top navigation breadcrumb bar
4. Add bottom status bar with file info
5. Implement selection highlighting in left pane
6. Show file contents in right pane
7. Support different border styles for active/inactive panes
8. Add keyboard shortcut hints in status bar

**Example output**:
```
╭────────────────────────────────────────────────────────────────────────────╮
│ 📁 /home/user/projects/myapp/src                                           │
╰────────────────────────────────────────────────────────────────────────────╯

╭─ Files ──────────────╮  ╭─ Preview: main.go ────────────────────────────╮
│                      │  │ package main                                  │
│ 📁 cmd/              │  │                                               │
│ 📁 internal/         │  │ import (                                      │
│ 📁 pkg/              │  │     "fmt"                                     │
│ 📄 main.go        ◄  │  │     "github.com/charmbracelet/lipgloss"       │
│ 📄 go.mod            │  │ )                                             │
│ 📄 go.sum            │  │                                               │
│ 📄 README.md         │  │ func main() {                                 │
│                      │  │     style := lipgloss.NewStyle().             │
│                      │  │         Foreground(lipgloss.Color("205"))     │
│                      │  │     fmt.Println(style.Render("Hello!"))       │
│                      │  │ }                                             │
│                      │  │                                               │
╰──────────────────────╯  ╰───────────────────────────────────────────────╯

╭────────────────────────────────────────────────────────────────────────────╮
│ main.go | 234 lines | Go | Modified: 2024-01-15 15:42    [↑/↓] Navigate │
╰────────────────────────────────────────────────────────────────────────────╯
```

### Challenge 3: Data Table with Summary Cards

Create a data table viewer with summary statistics cards above the table.

**Requirements**:
1. Build 3-4 summary cards with key metrics
2. Create table with headers (Name, Status, Time, Progress)
3. Implement proper column alignment (left, center, right)
4. Add status icons with colored cells
5. Show progress bars in table cells
6. Add table footer with totals
7. Support pagination indicators
8. Implement alternating row backgrounds (subtle)

**Example output**:
```
╭─ Total ──────────╮  ╭─ Success ────────╮  ╭─ Failed ─────────╮  ╭─ Running ────────╮
│                  │  │                  │  │                  │  │                  │
│       24         │  │       18         │  │        2         │  │        4         │
│  All Tasks       │  │  Completed       │  │   Errors         │  │  In Progress     │
│                  │  │                  │  │                  │  │                  │
╰──────────────────╯  ╰──────────────────╯  ╰──────────────────╯  ╰──────────────────╯

╭─────────────────────────────────────────────────────────────────────────────────────╮
│ Task Name               Status         Time       Progress                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ Build application       ✓ Success      2m 34s     ████████████████████ 100%        │
│ Run unit tests          ✓ Success      1m 12s     ████████████████████ 100%        │
│ Integration tests       ⏳ Running      0m 45s     ████████████░░░░░░░░  65%        │
│ Deploy staging          ⏳ Running      1m 23s     ██████░░░░░░░░░░░░░░  30%        │
│ Database migration      ✓ Success      0m 08s     ████████████████████ 100%        │
│ Update documentation    ✗ Failed       0m 15s     ████░░░░░░░░░░░░░░░░  20%        │
│ Security scan           ⏳ Queued       0m 00s     ░░░░░░░░░░░░░░░░░░░░   0%        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ Total: 7 tasks | Success: 3 | Running: 3 | Failed: 1                Page 1 of 3    │
╰─────────────────────────────────────────────────────────────────────────────────────╯
```

## Test Requirements

Implement comprehensive tests for layout composition and rendering.

### Test Structure Pattern

```go
package layout

import (
    "strings"
    "testing"
    "github.com/charmbracelet/lipgloss"
)

func TestHorizontalJoining(t *testing.T) {
    tests := []struct {
        name          string
        blocks        []string
        alignment     lipgloss.Position
        wantMinWidth  int
        wantMinHeight int
    }{
        {
            name: "two equal blocks top aligned",
            blocks: []string{
                lipgloss.NewStyle().Width(10).Height(3).Render("A"),
                lipgloss.NewStyle().Width(10).Height(3).Render("B"),
            },
            alignment:     lipgloss.Top,
            wantMinWidth:  20,
            wantMinHeight: 3,
        },
        {
            name: "different height blocks center aligned",
            blocks: []string{
                lipgloss.NewStyle().Width(10).Height(5).Render("Tall"),
                lipgloss.NewStyle().Width(10).Height(3).Render("Short"),
            },
            alignment:     lipgloss.Center,
            wantMinWidth:  20,
            wantMinHeight: 5,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := lipgloss.JoinHorizontal(tt.alignment, tt.blocks...)
            lines := strings.Split(result, "\n")

            if len(lines) < tt.wantMinHeight {
                t.Errorf("height: got %d lines, want at least %d", len(lines), tt.wantMinHeight)
            }

            // Check first line width (strip ANSI)
            firstLine := stripANSI(lines[0])
            if len(firstLine) < tt.wantMinWidth {
                t.Errorf("width: got %d, want at least %d", len(firstLine), tt.wantMinWidth)
            }
        })
    }
}

func TestVerticalJoining(t *testing.T) {
    tests := []struct {
        name         string
        blocks       []string
        alignment    lipgloss.Position
        wantMinLines int
    }{
        {
            name: "three blocks stacked",
            blocks: []string{
                lipgloss.NewStyle().Height(2).Render("Top"),
                lipgloss.NewStyle().Height(2).Render("Middle"),
                lipgloss.NewStyle().Height(2).Render("Bottom"),
            },
            alignment:    lipgloss.Left,
            wantMinLines: 6,
        },
        {
            name: "empty block handling",
            blocks: []string{
                lipgloss.NewStyle().Render("Content"),
                "",
                lipgloss.NewStyle().Render("More"),
            },
            alignment:    lipgloss.Center,
            wantMinLines: 2,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := lipgloss.JoinVertical(tt.alignment, tt.blocks...)
            lines := strings.Split(result, "\n")

            if len(lines) < tt.wantMinLines {
                t.Errorf("lines: got %d, want at least %d", len(lines), tt.wantMinLines)
            }
        })
    }
}

func TestPlacement(t *testing.T) {
    tests := []struct {
        name      string
        width     int
        height    int
        hPos      lipgloss.Position
        vPos      lipgloss.Position
        content   string
        wantLines int
        wantWidth int
    }{
        {
            name:      "center placement",
            width:     20,
            height:    5,
            hPos:      lipgloss.Center,
            vPos:      lipgloss.Center,
            content:   "X",
            wantLines: 5,
            wantWidth: 20,
        },
        {
            name:      "top left placement",
            width:     15,
            height:    3,
            hPos:      lipgloss.Left,
            vPos:      lipgloss.Top,
            content:   "TL",
            wantLines: 3,
            wantWidth: 15,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := lipgloss.Place(tt.width, tt.height, tt.hPos, tt.vPos, tt.content)
            lines := strings.Split(result, "\n")

            if len(lines) != tt.wantLines {
                t.Errorf("height: got %d lines, want %d", len(lines), tt.wantLines)
            }

            if len(lines) > 0 {
                firstLineWidth := len(stripANSI(lines[0]))
                if firstLineWidth != tt.wantWidth {
                    t.Errorf("width: got %d, want %d", firstLineWidth, tt.wantWidth)
                }
            }

            if !strings.Contains(result, tt.content) {
                t.Errorf("content missing: want %q in output", tt.content)
            }
        })
    }
}

func TestDashboardLayout(t *testing.T) {
    tests := []struct {
        name         string
        cards        []Card
        columns      int
        wantSections int
    }{
        {
            name: "three cards in three columns",
            cards: []Card{
                {Title: "Card 1", Content: "Content 1"},
                {Title: "Card 2", Content: "Content 2"},
                {Title: "Card 3", Content: "Content 3"},
            },
            columns:      3,
            wantSections: 3,
        },
        {
            name: "four cards in two columns",
            cards: []Card{
                {Title: "A", Content: "A content"},
                {Title: "B", Content: "B content"},
                {Title: "C", Content: "C content"},
                {Title: "D", Content: "D content"},
            },
            columns:      2,
            wantSections: 4,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            dashboard := RenderDashboard(tt.cards, tt.columns)
            plain := stripANSI(dashboard)

            // Check all card titles present
            for _, card := range tt.cards {
                if !strings.Contains(plain, card.Title) {
                    t.Errorf("missing card title: %q", card.Title)
                }
            }

            // Check border presence
            if !strings.Contains(plain, "─") {
                t.Error("borders missing from dashboard")
            }
        })
    }
}

func TestTableLayout(t *testing.T) {
    headers := []string{"Name", "Status", "Time"}
    rows := [][]string{
        {"Task 1", "Success", "2m 34s"},
        {"Task 2", "Running", "1m 12s"},
    }

    table := RenderTable(headers, rows)
    plain := stripANSI(table)

    // Check headers present
    for _, h := range headers {
        if !strings.Contains(plain, h) {
            t.Errorf("missing header: %q", h)
        }
    }

    // Check data present
    for _, row := range rows {
        for _, cell := range row {
            if !strings.Contains(plain, cell) {
                t.Errorf("missing cell data: %q", cell)
            }
        }
    }

    // Check structure
    lines := strings.Split(plain, "\n")
    if len(lines) < len(rows)+1 { // At least headers + data
        t.Errorf("insufficient rows: got %d, want at least %d", len(lines), len(rows)+1)
    }
}

// Helper to strip ANSI codes for testing
func stripANSI(s string) string {
    // Simple ANSI stripping for tests
    // In production, use: github.com/acarl005/stripansi
    result := ""
    inEscape := false
    for _, r := range s {
        if r == '\x1b' {
            inEscape = true
            continue
        }
        if inEscape {
            if r == 'm' {
                inEscape = false
            }
            continue
        }
        result += string(r)
    }
    return result
}

type Card struct {
    Title   string
    Content string
}

// Stub functions for testing (implement in actual code)
func RenderDashboard(cards []Card, columns int) string {
    return "" // Implementation in challenge
}

func RenderTable(headers []string, rows [][]string) string {
    return "" // Implementation in challenge
}
```

### Required Test Cases

**For Dashboard Layout**:
1. Multiple cards arrange in correct columns
2. Cards align properly horizontally
3. Header and footer sections render
4. Variable-height cards don't break layout
5. Spacing between cards is consistent
6. Empty dashboard handled gracefully

**For Split-Pane Layout**:
1. Left and right panes render side-by-side
2. Pane width calculation correct
3. Active/inactive pane styling differs
4. Status bar spans full width
5. Navigation breadcrumb appears correctly
6. Empty panes don't break layout

**For Data Table**:
1. Headers render with proper styling
2. All data rows display correctly
3. Column alignment works (left/center/right)
4. Progress bars render in cells
5. Footer totals calculate correctly
6. Empty table shows appropriate message

## Input/Output Specifications

### Dashboard Layout Engine

**Input**: List of cards with metadata
**Output**: Multi-column dashboard layout

```go
Input: []Card{
    {Title: "CPU", Content: "45%", Style: "success"},
    {Title: "Memory", Content: "2.3 GB", Style: "warning"},
    {Title: "Disk", Content: "125 GB", Style: "info"},
}
Columns: 3

Output: (3-column dashboard with styled cards)
```

### Split-Pane File Manager

**Input**: Directory path, selected file, file content
**Output**: Two-pane layout with preview

```go
Input:
    LeftPane: ["cmd/", "internal/", "main.go", "go.mod"]
    RightPane: "package main\n\nimport (...)"
    Selected: "main.go"

Output: (split-pane layout with selection highlighting)
```

### Data Table with Summary

**Input**: Table data and summary metrics
**Output**: Cards + table layout

```go
Input:
    Summary: {Total: 24, Success: 18, Failed: 2, Running: 4}
    Table: [
        ["Build", "Success", "2m 34s", 100],
        ["Test", "Running", "1m 12s", 65],
    ]

Output: (summary cards above data table)
```

## Success Criteria

### Functional Requirements
- [ ] Horizontal joining works with all alignment options
- [ ] Vertical joining stacks blocks correctly
- [ ] Place() positions content accurately
- [ ] Multi-column layouts render properly
- [ ] Dashboard cards align in grid
- [ ] Split-pane divides space correctly
- [ ] Tables display with proper column alignment
- [ ] Nested compositions work without artifacts

### Code Quality Requirements
- [ ] Layout functions are reusable and composable
- [ ] Dimension calculations handle edge cases
- [ ] Alignment logic is correct for all positions
- [ ] No hardcoded dimensions (use parameters)
- [ ] Responsive to terminal size changes
- [ ] Clean separation of layout and content
- [ ] Well-documented layout patterns

### Testing Requirements
- [ ] Join operations tested for all alignments
- [ ] Placement tested for all 9 positions (3x3 grid)
- [ ] Multi-column layouts tested with various widths
- [ ] Table rendering tested with different data
- [ ] Edge cases covered (empty content, mismatched sizes)
- [ ] Dimension calculations verified
- [ ] Test coverage >75%

### Visual Requirements
- [ ] Layouts are visually balanced
- [ ] Spacing is consistent throughout
- [ ] Alignment is precise (no off-by-one errors)
- [ ] Borders connect properly in complex layouts
- [ ] No visual artifacts or broken characters
- [ ] Works in terminals of various sizes
- [ ] Graceful degradation for small terminals

## Common Pitfalls

### Pitfall 1: Not Accounting for Border Width in Calculations

❌ **Wrong**: Ignoring border width
```go
func createColumns(termWidth int) string {
    // Each column gets 1/3 width, but borders add extra width!
    colWidth := termWidth / 3

    style := lipgloss.NewStyle().
        Width(colWidth).
        Border(lipgloss.RoundedBorder())

    col1 := style.Render("Column 1")
    col2 := style.Render("Column 2")
    col3 := style.Render("Column 3")

    // Total width exceeds terminal width due to borders!
    return lipgloss.JoinHorizontal(lipgloss.Top, col1, col2, col3)
}
```

✅ **Correct**: Account for borders and spacing
```go
func createColumns(termWidth int) string {
    // Account for borders (2 per column) and spacing
    borderWidth := 2
    spacing := 2
    totalBorderWidth := (borderWidth * 3) + (spacing * 2)
    availableWidth := termWidth - totalBorderWidth
    colWidth := availableWidth / 3

    style := lipgloss.NewStyle().
        Width(colWidth).
        Border(lipgloss.RoundedBorder())

    col1 := style.Render("Column 1")
    col2 := style.Render("Column 2")
    col3 := style.Render("Column 3")

    // Use strings for spacing
    return lipgloss.JoinHorizontal(lipgloss.Top, col1, "  ", col2, "  ", col3)
}
```

### Pitfall 2: Mismatched Heights in Horizontal Layouts

❌ **Wrong**: Not setting consistent heights
```go
// Different heights cause misalignment
left := lipgloss.NewStyle().
    Width(20).
    Height(5).
    Render("Short content")

right := lipgloss.NewStyle().
    Width(20).
    Height(10).
    Render("Tall content")

// Looks awkward when joined
layout := lipgloss.JoinHorizontal(lipgloss.Top, left, right)
```

✅ **Correct**: Use consistent heights or proper alignment
```go
// Option 1: Set consistent height
height := 10
left := lipgloss.NewStyle().
    Width(20).
    Height(height).
    AlignVertical(lipgloss.Top).
    Render("Short content")

right := lipgloss.NewStyle().
    Width(20).
    Height(height).
    AlignVertical(lipgloss.Top).
    Render("Tall content")

layout := lipgloss.JoinHorizontal(lipgloss.Top, left, right)

// Option 2: Use Center alignment for different heights
layout := lipgloss.JoinHorizontal(lipgloss.Center, left, right)
```

### Pitfall 3: Forgetting to Strip ANSI in Width Calculations

❌ **Wrong**: Using styled string length directly
```go
styled := lipgloss.NewStyle().
    Foreground(lipgloss.Color("205")).
    Render("Hello")

// WRONG: len() includes ANSI codes!
width := len(styled) // Much larger than 5!

style := lipgloss.NewStyle().Width(width)
```

✅ **Correct**: Use lipgloss.Width() helper
```go
styled := lipgloss.NewStyle().
    Foreground(lipgloss.Color("205")).
    Render("Hello")

// Correct: lipgloss.Width() strips ANSI codes
width := lipgloss.Width(styled) // Returns 5

style := lipgloss.NewStyle().Width(width + 4) // Add padding
```

**Why**: ANSI escape sequences add hidden characters. Use `lipgloss.Width()` and `lipgloss.Height()` for accurate measurements.

### Pitfall 4: Not Handling Empty Strings in Joins

❌ **Wrong**: Passing empty strings causes spacing issues
```go
blocks := []string{
    renderCard("Card 1"),
    "", // Empty string adds unwanted space
    renderCard("Card 2"),
}

layout := lipgloss.JoinVertical(lipgloss.Left, blocks...)
// Creates extra blank line
```

✅ **Correct**: Filter empty strings or use explicit spacing
```go
// Option 1: Filter empty strings
blocks := []string{
    renderCard("Card 1"),
    renderCard("Card 2"),
}

layout := lipgloss.JoinVertical(lipgloss.Left, blocks...)

// Option 2: Use explicit newline for spacing
layout := lipgloss.JoinVertical(lipgloss.Left,
    renderCard("Card 1"),
    "\n", // Explicit spacing
    renderCard("Card 2"),
)
```

### Pitfall 5: Not Using MaxWidth for Flexible Layouts

❌ **Wrong**: Fixed widths that don't adapt
```go
// Always 80 characters wide
style := lipgloss.NewStyle().
    Width(80).
    Border(lipgloss.RoundedBorder())
```

✅ **Correct**: Use MaxWidth for flexibility
```go
// Shrinks if content is smaller, grows to max
style := lipgloss.NewStyle().
    MaxWidth(80).
    Border(lipgloss.RoundedBorder())

// Or calculate based on terminal
import "golang.org/x/term"

width, _, _ := term.GetSize(int(os.Stdout.Fd()))
style := lipgloss.NewStyle().
    MaxWidth(width - 4). // Leave margin
    Border(lipgloss.RoundedBorder())
```

### Pitfall 6: Incorrect Alignment Expectations

❌ **Wrong**: Expecting Left/Right to work with JoinHorizontal
```go
// Left/Right are for vertical alignment, not horizontal!
layout := lipgloss.JoinHorizontal(lipgloss.Left, block1, block2)
// Doesn't align blocks to left side as expected
```

✅ **Correct**: Use correct alignment constants
```go
// For horizontal joining, use Top/Center/Bottom
layout := lipgloss.JoinHorizontal(lipgloss.Top, block1, block2)

// For vertical joining, use Left/Center/Right
layout := lipgloss.JoinVertical(lipgloss.Center, block1, block2)
```

**Alignment guide**:
- `JoinHorizontal`: Use `Top`, `Center`, or `Bottom`
- `JoinVertical`: Use `Left`, `Center`, or `Right`

## Extension Challenges

### Extension 1: Grid Layout System
Implement a grid system with rows and columns:
```go
type Grid struct {
    Rows    int
    Columns int
    Cells   [][]string
    Gap     int
}

func (g *Grid) Render() string {
    // Calculate cell dimensions
    // Render grid with gaps
    // Support spanning cells (rowspan/colspan)
}

// Usage
grid := Grid{
    Rows:    3,
    Columns: 3,
    Gap:     1,
}
grid.SetCell(0, 0, "Header")
grid.SetCell(0, 1, "Header")
grid.SetCell(0, 2, "Header")
grid.SetCell(1, 0, "Content")
// ...
fmt.Println(grid.Render())
```

### Extension 2: Flex Layout Engine
Create flexbox-style layout system:
```go
type FlexContainer struct {
    Direction  FlexDirection // Row or Column
    Justify    FlexJustify   // Start, Center, End, SpaceBetween
    Align      FlexAlign     // Start, Center, End, Stretch
    Gap        int
    Children   []FlexItem
}

type FlexItem struct {
    Content string
    Grow    int // Flex grow factor
    Shrink  int // Flex shrink factor
    Basis   int // Base size
}

func (fc *FlexContainer) Render() string {
    // Calculate flex sizes
    // Distribute space based on grow/shrink
    // Apply alignment
}
```

### Extension 3: Responsive Breakpoints
Implement responsive layouts with breakpoint system:
```go
type ResponsiveLayout struct {
    Breakpoints map[int]Layout // Width -> Layout
}

func (rl *ResponsiveLayout) Render() string {
    width := getTerminalWidth()

    // Find appropriate layout for current width
    layout := rl.selectLayout(width)

    return layout.Render()
}

// Usage
responsive := ResponsiveLayout{
    Breakpoints: map[int]Layout{
        40:  SingleColumnLayout(),
        80:  TwoColumnLayout(),
        120: ThreeColumnLayout(),
    },
}
```

### Extension 4: Tabbed Interface
Create tabbed content viewer:
```go
type TabbedView struct {
    Tabs       []Tab
    ActiveTab  int
    TabStyle   lipgloss.Style
    PanelStyle lipgloss.Style
}

type Tab struct {
    Label   string
    Content string
}

func (tv *TabbedView) Render() string {
    // Render tab headers with active highlighting
    tabRow := renderTabHeaders(tv.Tabs, tv.ActiveTab)

    // Render active tab content
    content := tv.PanelStyle.Render(tv.Tabs[tv.ActiveTab].Content)

    return lipgloss.JoinVertical(lipgloss.Left, tabRow, content)
}
```

### Extension 5: Modal Dialog System
Implement overlay modals with backdrop:
```go
func RenderModal(width, height int, title, content string) string {
    // Create semi-transparent backdrop (dimmed background)
    backdrop := lipgloss.Place(width, height,
        lipgloss.Center, lipgloss.Center,
        renderModalBox(title, content))

    return backdrop
}

func renderModalBox(title, content string) string {
    // Modal with shadow effect
    modalStyle := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("62")).
        Padding(1, 2).
        Width(50)

    header := lipgloss.NewStyle().Bold(true).Render(title)
    body := modalStyle.Render(
        lipgloss.JoinVertical(lipgloss.Left, header, "", content))

    return body
}
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Layout Primitives**: Master Join and Place functions first
2. **Composition Patterns**: Build complex layouts from simple blocks
3. **Dimension Management**: Careful width/height calculations
4. **Responsive Design**: Adapt to terminal size
5. **Testing**: Verify layout structure, not just visual appearance

### Code Organization

```
lesson-16/
├── dashboard/
│   ├── main.go              # Dashboard demo
│   ├── layout/
│   │   ├── layout.go        # Layout engine
│   │   ├── card.go          # Card component
│   │   └── layout_test.go
│   └── README.md
├── file-manager/
│   ├── main.go              # Split-pane demo
│   ├── panes/
│   │   ├── panes.go         # Pane management
│   │   └── panes_test.go
│   └── README.md
└── data-table/
    ├── main.go              # Table viewer demo
    ├── table/
    │   ├── table.go         # Table rendering
    │   └── table_test.go
    └── README.md
```

### Quality Checklist

- [ ] All joins (horizontal/vertical) demonstrated
- [ ] Place() used for absolute positioning
- [ ] Width/Height calculations account for borders
- [ ] Responsive layouts adapt to terminal size
- [ ] lipgloss.Width() and lipgloss.Height() used for measurements
- [ ] Alignment constants used correctly (Top/Center/Bottom for horizontal)
- [ ] Nested compositions work without visual artifacts
- [ ] Empty strings handled properly in joins
- [ ] Tests verify structure, not just appearance
- [ ] Code is reusable and composable

### Testing Approach

Focus on layout structure and composition correctness:

```go
// Test dimension calculations
func TestColumnWidths(t *testing.T) {
    totalWidth := 80
    columns := 3
    borderWidth := 2 * columns
    spacing := (columns - 1) * 2
    expectedColWidth := (totalWidth - borderWidth - spacing) / columns

    result := createColumns(totalWidth, columns)
    // Verify each column has correct width
}

// Test alignment behavior
func TestJoinAlignment(t *testing.T) {
    tall := lipgloss.NewStyle().Height(10).Render("Tall")
    short := lipgloss.NewStyle().Height(5).Render("Short")

    // Test top alignment
    topAligned := lipgloss.JoinHorizontal(lipgloss.Top, tall, short)
    lines := strings.Split(topAligned, "\n")
    // Verify short block starts at top

    // Test center alignment
    centerAligned := lipgloss.JoinHorizontal(lipgloss.Center, tall, short)
    // Verify short block centered vertically
}

// Test nested composition
func TestNestedLayout(t *testing.T) {
    // Create nested structure
    // Verify all components present
    // Check no visual artifacts
}
```

## Learning Resources

### Official Documentation
- [Lip Gloss Layout Functions](https://github.com/charmbracelet/lipgloss#layout) - Join and Place documentation
- [Lip Gloss Examples - Layout](https://github.com/charmbracelet/lipgloss/tree/master/examples/layout) - Official layout examples
- [Lip Gloss Width/Height Helpers](https://pkg.go.dev/github.com/charmbracelet/lipgloss#Width) - Measurement functions
- [Position Constants](https://pkg.go.dev/github.com/charmbracelet/lipgloss#Position) - Alignment options

### Tutorials and Guides
- [Building Complex Layouts](https://github.com/charmbracelet/lipgloss/discussions/123) - Community layout patterns
- [Dashboard Examples](https://github.com/charmbracelet/lipgloss/tree/master/examples/dashboard) - Dashboard layouts
- [Grid Systems in Terminal](https://charm.sh/blog/grid-layouts) - Grid layout techniques
- [Responsive Terminal UIs](https://charm.sh/blog/responsive-tuis) - Adapting to terminal size

### Related Tools and Examples
- [Bubble Tea Layouts](https://github.com/charmbracelet/bubbletea/tree/master/examples/layout) - TUI layout patterns
- [Soft Serve UI](https://github.com/charmbracelet/soft-serve) - Complex layout examples
- [Glow Layout](https://github.com/charmbracelet/glow/tree/master/ui) - Document viewer layouts
- [VHS Examples](https://github.com/charmbracelet/vhs/tree/main/examples) - Recording terminal layouts

### Layout Resources
- [Terminal Grid Systems](https://github.com/topics/terminal-layout) - Layout libraries and examples
- [CSS Flexbox Guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/) - Flexbox concepts (applicable to TUI)
- [Terminal Dimensions in Go](https://pkg.go.dev/golang.org/x/term#GetSize) - Getting terminal size
- [Unicode Box Drawing](https://en.wikipedia.org/wiki/Box-drawing_character) - Box drawing characters

## Validation Commands

```bash
# Install Lip Gloss (if not already installed)
go get github.com/charmbracelet/lipgloss

# Install terminal size library
go get golang.org/x/term

# Format code
go fmt ./lesson-16/...

# Run all tests
go test ./lesson-16/... -v

# Check test coverage
go test ./lesson-16/... -cover

# Test coverage report
go test ./lesson-16/... -coverprofile=coverage.out
go tool cover -html=coverage.out

# Build all challenges
cd lesson-16/dashboard && go build
cd lesson-16/file-manager && go build
cd lesson-16/data-table && go build

# Test dashboard with different configurations
./dashboard/dashboard --columns 2
./dashboard/dashboard --columns 3
./dashboard/dashboard --responsive

# Test file manager
./file-manager/file-manager --path /path/to/directory
./file-manager/file-manager --demo

# Test data table
./data-table/data-table --file data.csv
./data-table/data-table --demo

# Test in different terminal sizes
# Resize terminal and rerun to verify responsive behavior
./dashboard/dashboard

# Test alignment variations
./dashboard/dashboard --align top
./dashboard/dashboard --align center
./dashboard/dashboard --align bottom

# Run with race detector (for concurrent rendering if implemented)
go test ./lesson-16/... -race

# Benchmark layout performance
go test ./lesson-16/... -bench=. -benchmem
```

---

**Next Lesson**: [Lesson 17: Adaptive Styling & Theming](lesson-17-lipgloss-theming.md) - Light/dark themes and terminal adaptation

**Previous Lesson**: [Lesson 15: Lip Gloss Basics - Colors & Borders](lesson-15-lipgloss-basics.md) - Style fundamentals and method chaining

**Phase Overview**: [Phase 3: Styling with Lip Gloss](../README.md#phase-3-styling-with-lip-gloss-week-5) - Terminal styling before TUI complexity
