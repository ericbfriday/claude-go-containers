# Lesson 17: Lip Gloss Adaptive Styling & Theming

**Phase**: 3 - Styling with Lip Gloss
**Difficulty**: Intermediate
**Estimated Time**: 2-3 hours

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Detect terminal background** using `lipgloss.HasDarkBackground()` for adaptive styling
2. **Use AdaptiveColor** type to provide different colors for light and dark terminals
3. **Implement graceful degradation** when terminal capabilities are limited
4. **Create theme systems** with reusable color palettes and style definitions
5. **Build configurable themes** that users can switch at runtime
6. **Design accessible color schemes** that work for color-blind users
7. **Handle color profile detection** for 256-color and true-color terminals
8. **Test theming** across different terminal environments

## Prerequisites

- **Required**: Completion of Lessons 15-16 (Lip Gloss Basics and Layout)
- **Concepts**: Colors, borders, layout composition from previous lessons
- **Tools**: Go 1.20+, Lip Gloss installed, multiple terminals for testing
- **Knowledge**: Color theory basics (helpful but not required)
- **Understanding**: Terminal color capabilities and limitations

## Core Concepts

### 1. Terminal Background Detection

Lip Gloss can detect whether the terminal has a light or dark background to automatically adjust colors.

**Basic background detection**:
```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateBackgroundDetection() {
    // Detect terminal background
    hasDark := lipgloss.HasDarkBackground()

    fmt.Printf("Terminal has dark background: %v\n", hasDark)

    // Choose colors based on background
    var textColor, bgColor lipgloss.Color
    if hasDark {
        textColor = lipgloss.Color("252")  // Light text
        bgColor = lipgloss.Color("235")    // Dark background
    } else {
        textColor = lipgloss.Color("235")  // Dark text
        bgColor = lipgloss.Color("252")    // Light background
    }

    style := lipgloss.NewStyle().
        Foreground(textColor).
        Background(bgColor).
        Padding(1, 2)

    fmt.Println(style.Render("Adaptive styling based on terminal background"))
}
```

**How it works**:
- Lip Gloss inspects terminal environment variables and capabilities
- Queries terminal for background color information
- Returns `true` for dark backgrounds, `false` for light backgrounds
- Fallback to reasonable defaults if detection fails

### 2. AdaptiveColor Type - Automatic Color Selection

`AdaptiveColor` automatically chooses appropriate colors based on terminal background without manual detection.

```go
package main

import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateAdaptiveColor() {
    // Define adaptive color that works in both light and dark terminals
    adaptiveText := lipgloss.AdaptiveColor{
        Light: "235",  // Dark text for light backgrounds
        Dark:  "252",  // Light text for dark backgrounds
    }

    adaptiveBg := lipgloss.AdaptiveColor{
        Light: "252",  // Light background for light terminals
        Dark:  "235",  // Dark background for dark terminals
    }

    // Lip Gloss automatically selects the right color
    style := lipgloss.NewStyle().
        Foreground(adaptiveText).
        Background(adaptiveBg).
        Padding(1, 2).
        Bold(true)

    fmt.Println(style.Render("This text adapts to your terminal background!"))

    // Adaptive accent colors
    accentColor := lipgloss.AdaptiveColor{
        Light: "62",   // Darker blue for light backgrounds
        Dark:  "39",   // Brighter blue for dark backgrounds
    }

    accentStyle := lipgloss.NewStyle().
        Foreground(accentColor).
        Bold(true)

    fmt.Println(accentStyle.Render("Accent text that's always visible"))
}
```

**Common adaptive color patterns**:
```go
// Primary text
primaryText := lipgloss.AdaptiveColor{
    Light: "235",  // Near black
    Dark:  "255",  // Near white
}

// Secondary/muted text
mutedText := lipgloss.AdaptiveColor{
    Light: "240",  // Dark gray
    Dark:  "250",  // Light gray
}

// Background colors
cardBackground := lipgloss.AdaptiveColor{
    Light: "255",  // White
    Dark:  "236",  // Near black
}

// Borders
borderColor := lipgloss.AdaptiveColor{
    Light: "240",  // Darker for contrast on light
    Dark:  "240",  // Same works on dark
}
```

### 3. Color Profile Detection and Degradation

Handle terminals with different color capabilities gracefully.

```go
package main

import (
    "fmt"
    "os"
    "github.com/charmbracelet/lipgloss"
)

func demonstrateColorProfile() {
    // Get color profile
    profile := lipgloss.ColorProfile()

    fmt.Printf("Color profile: %s\n", profile)
    fmt.Printf("Supports true color: %v\n", profile == lipgloss.TrueColor)
    fmt.Printf("Supports 256 colors: %v\n", profile == lipgloss.ANSI256)
    fmt.Printf("Basic ANSI only: %v\n", profile == lipgloss.ANSI)
    fmt.Printf("No color: %v\n", profile == lipgloss.Ascii)

    // Define color with degradation strategy
    // True color -> ANSI 256 -> Basic ANSI
    color := lipgloss.Color("#FF6B9D")  // True color hex

    style := lipgloss.NewStyle().
        Foreground(color).
        Bold(true)

    fmt.Println(style.Render("This color degrades gracefully"))

    // Explicit profile handling
    switch profile {
    case lipgloss.TrueColor:
        fmt.Println("Using 24-bit true color")
    case lipgloss.ANSI256:
        fmt.Println("Using 256-color palette")
    case lipgloss.ANSI:
        fmt.Println("Using basic ANSI colors")
    case lipgloss.Ascii:
        fmt.Println("No color support - ASCII only")
    }
}

// Force specific profile for testing
func setColorProfile(profile lipgloss.Profile) {
    os.Setenv("COLORTERM", "truecolor") // For TrueColor
    // or os.Setenv("TERM", "xterm-256color") // For ANSI256
    // or os.Setenv("TERM", "xterm") // For basic ANSI
}
```

**Color degradation hierarchy**:
1. **TrueColor** (24-bit): 16.7 million colors (best)
2. **ANSI256** (8-bit): 256 colors (good)
3. **ANSI** (4-bit): 16 colors (basic)
4. **Ascii**: No color (fallback)

### 4. Theme System Architecture

Build a comprehensive theme system with reusable definitions.

```go
package theme

import "github.com/charmbracelet/lipgloss"

// Theme defines a complete color scheme
type Theme struct {
    Name string

    // Base colors
    Foreground lipgloss.AdaptiveColor
    Background lipgloss.AdaptiveColor

    // UI colors
    Primary   lipgloss.AdaptiveColor
    Secondary lipgloss.AdaptiveColor
    Accent    lipgloss.AdaptiveColor

    // Semantic colors
    Success lipgloss.AdaptiveColor
    Warning lipgloss.AdaptiveColor
    Error   lipgloss.AdaptiveColor
    Info    lipgloss.AdaptiveColor

    // Text colors
    TextPrimary   lipgloss.AdaptiveColor
    TextSecondary lipgloss.AdaptiveColor
    TextMuted     lipgloss.AdaptiveColor

    // Border and divider colors
    Border   lipgloss.AdaptiveColor
    Divider  lipgloss.AdaptiveColor

    // Special colors
    Highlight lipgloss.AdaptiveColor
    Selected  lipgloss.AdaptiveColor
}

// Predefined themes

// DefaultTheme - balanced for both light and dark
var DefaultTheme = Theme{
    Name: "Default",
    Foreground: lipgloss.AdaptiveColor{
        Light: "235",
        Dark:  "252",
    },
    Background: lipgloss.AdaptiveColor{
        Light: "255",
        Dark:  "235",
    },
    Primary: lipgloss.AdaptiveColor{
        Light: "62",   // Blue
        Dark:  "39",
    },
    Secondary: lipgloss.AdaptiveColor{
        Light: "135",  // Purple
        Dark:  "141",
    },
    Accent: lipgloss.AdaptiveColor{
        Light: "205",  // Pink
        Dark:  "213",
    },
    Success: lipgloss.AdaptiveColor{
        Light: "28",   // Green
        Dark:  "42",
    },
    Warning: lipgloss.AdaptiveColor{
        Light: "214",  // Orange
        Dark:  "220",
    },
    Error: lipgloss.AdaptiveColor{
        Light: "160",  // Red
        Dark:  "196",
    },
    Info: lipgloss.AdaptiveColor{
        Light: "39",   // Cyan
        Dark:  "51",
    },
    TextPrimary: lipgloss.AdaptiveColor{
        Light: "235",
        Dark:  "252",
    },
    TextSecondary: lipgloss.AdaptiveColor{
        Light: "240",
        Dark:  "247",
    },
    TextMuted: lipgloss.AdaptiveColor{
        Light: "245",
        Dark:  "243",
    },
    Border: lipgloss.AdaptiveColor{
        Light: "240",
        Dark:  "240",
    },
    Divider: lipgloss.AdaptiveColor{
        Light: "250",
        Dark:  "238",
    },
    Highlight: lipgloss.AdaptiveColor{
        Light: "229",  // Yellow background
        Dark:  "58",
    },
    Selected: lipgloss.AdaptiveColor{
        Light: "189",  // Light blue
        Dark:  "61",
    },
}

// DraculaTheme - dark theme inspired by Dracula
var DraculaTheme = Theme{
    Name: "Dracula",
    Foreground: lipgloss.AdaptiveColor{
        Light: "#282A36",
        Dark:  "#F8F8F2",
    },
    Background: lipgloss.AdaptiveColor{
        Light: "#F8F8F2",
        Dark:  "#282A36",
    },
    Primary: lipgloss.AdaptiveColor{
        Light: "#6272A4",
        Dark:  "#BD93F9",
    },
    Secondary: lipgloss.AdaptiveColor{
        Light: "#BD93F9",
        Dark:  "#FF79C6",
    },
    Accent: lipgloss.AdaptiveColor{
        Light: "#FF79C6",
        Dark:  "#FFB86C",
    },
    Success: lipgloss.AdaptiveColor{
        Light: "#50FA7B",
        Dark:  "#50FA7B",
    },
    Warning: lipgloss.AdaptiveColor{
        Light: "#F1FA8C",
        Dark:  "#F1FA8C",
    },
    Error: lipgloss.AdaptiveColor{
        Light: "#FF5555",
        Dark:  "#FF5555",
    },
    Info: lipgloss.AdaptiveColor{
        Light: "#8BE9FD",
        Dark:  "#8BE9FD",
    },
    // ... rest of colors
}

// SolarizedTheme - scientifically designed for readability
var SolarizedTheme = Theme{
    Name: "Solarized",
    // Base colors
    Foreground: lipgloss.AdaptiveColor{
        Light: "#073642",  // base02
        Dark:  "#839496",  // base0
    },
    Background: lipgloss.AdaptiveColor{
        Light: "#FDF6E3",  // base3
        Dark:  "#002B36",  // base03
    },
    Primary: lipgloss.AdaptiveColor{
        Light: "#268BD2",  // blue
        Dark:  "#268BD2",
    },
    // ... rest of Solarized palette
}
```

### 5. Style Factory with Theme Integration

Create reusable style generators that use the current theme.

```go
package styles

import (
    "github.com/charmbracelet/lipgloss"
    "myapp/theme"
)

var currentTheme = theme.DefaultTheme

// SetTheme changes the active theme
func SetTheme(t theme.Theme) {
    currentTheme = t
}

// GetTheme returns the current theme
func GetTheme() theme.Theme {
    return currentTheme
}

// Base styles using current theme

func Header() lipgloss.Style {
    return lipgloss.NewStyle().
        Foreground(currentTheme.Primary).
        Bold(true).
        Padding(0, 1)
}

func Paragraph() lipgloss.Style {
    return lipgloss.NewStyle().
        Foreground(currentTheme.TextPrimary).
        Padding(0, 1)
}

func Box() lipgloss.Style {
    return lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(currentTheme.Border).
        Padding(1, 2)
}

// Semantic styles

func Success(msg string) string {
    style := lipgloss.NewStyle().
        Foreground(currentTheme.Success).
        Bold(true).
        Prefix("✓ ")
    return style.Render(msg)
}

func Error(msg string) string {
    style := lipgloss.NewStyle().
        Foreground(currentTheme.Error).
        Bold(true).
        Prefix("✗ ")
    return style.Render(msg)
}

func Warning(msg string) string {
    style := lipgloss.NewStyle().
        Foreground(currentTheme.Warning).
        Bold(true).
        Prefix("⚠ ")
    return style.Render(msg)
}

func Info(msg string) string {
    style := lipgloss.NewStyle().
        Foreground(currentTheme.Info).
        Prefix("ℹ ")
    return style.Render(msg)
}

// Complex components

func Card(title, content string) string {
    headerStyle := lipgloss.NewStyle().
        Foreground(currentTheme.Primary).
        Bold(true).
        BorderBottom(true).
        BorderForeground(currentTheme.Divider).
        Padding(0, 1, 1, 1)

    contentStyle := lipgloss.NewStyle().
        Foreground(currentTheme.TextPrimary).
        Padding(1)

    card := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(currentTheme.Border).
        Width(40)

    return card.Render(
        lipgloss.JoinVertical(lipgloss.Left,
            headerStyle.Render(title),
            contentStyle.Render(content),
        ),
    )
}

func HighlightBox(content string) string {
    return lipgloss.NewStyle().
        Background(currentTheme.Highlight).
        Foreground(currentTheme.TextPrimary).
        Padding(1, 2).
        Render(content)
}

func SelectedItem(content string) string {
    return lipgloss.NewStyle().
        Background(currentTheme.Selected).
        Foreground(currentTheme.TextPrimary).
        Padding(0, 1).
        Render(content)
}
```

### 6. Runtime Theme Switching

Implement dynamic theme switching for user preference.

```go
package main

import (
    "fmt"
    "strings"
    "myapp/styles"
    "myapp/theme"
    "github.com/charmbracelet/lipgloss"
)

var availableThemes = map[string]theme.Theme{
    "default":   theme.DefaultTheme,
    "dracula":   theme.DraculaTheme,
    "solarized": theme.SolarizedTheme,
}

func main() {
    // Show theme selection
    fmt.Println("Available themes:")
    for name := range availableThemes {
        fmt.Printf("  - %s\n", name)
    }

    // Demo each theme
    for name, t := range availableThemes {
        fmt.Printf("\n=== Theme: %s ===\n\n", strings.ToUpper(name))
        demoTheme(t)
    }
}

func demoTheme(t theme.Theme) {
    // Switch to theme
    styles.SetTheme(t)

    // Show styled content
    fmt.Println(styles.Header().Render("Header Text"))
    fmt.Println(styles.Paragraph().Render("This is paragraph text using the current theme."))
    fmt.Println()

    fmt.Println(styles.Success("Operation completed successfully"))
    fmt.Println(styles.Warning("Configuration file not found"))
    fmt.Println(styles.Error("Failed to connect to server"))
    fmt.Println(styles.Info("Processing 1,234 items"))
    fmt.Println()

    fmt.Println(styles.Card("Status", "All systems operational"))
    fmt.Println()

    fmt.Println(styles.HighlightBox("Highlighted content"))
    fmt.Println(styles.SelectedItem("Selected item"))
}

// CLI integration
func loadThemeFromConfig(themeName string) error {
    t, ok := availableThemes[themeName]
    if !ok {
        return fmt.Errorf("unknown theme: %s", themeName)
    }

    styles.SetTheme(t)
    return nil
}

// Cobra command integration
/*
var themeCmd = &cobra.Command{
    Use:   "theme [name]",
    Short: "Set the color theme",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        if err := loadThemeFromConfig(args[0]); err != nil {
            fmt.Fprintf(os.Stderr, "Error: %v\n", err)
            os.Exit(1)
        }
        fmt.Printf("Theme set to: %s\n", args[0])
    },
}
*/
```

### 7. Accessible Color Design

Design themes that work for color-blind users and meet accessibility standards.

```go
package theme

import "github.com/charmbracelet/lipgloss"

// AccessibleTheme - designed for color blindness and high contrast
var AccessibleTheme = Theme{
    Name: "Accessible",

    // High contrast base
    Foreground: lipgloss.AdaptiveColor{
        Light: "16",   // Pure black
        Dark:  "231",  // Pure white
    },
    Background: lipgloss.AdaptiveColor{
        Light: "231",  // Pure white
        Dark:  "16",   // Pure black
    },

    // Semantic colors - distinguishable for color blindness
    // Using shapes and brightness, not just color
    Success: lipgloss.AdaptiveColor{
        Light: "22",   // Dark green - high contrast
        Dark:  "46",   // Bright green
    },
    Warning: lipgloss.AdaptiveColor{
        Light: "166",  // Orange (not red/green)
        Dark:  "214",
    },
    Error: lipgloss.AdaptiveColor{
        Light: "88",   // Dark red - very different from green
        Dark:  "196",
    },
    Info: lipgloss.AdaptiveColor{
        Light: "17",   // Dark blue
        Dark:  "39",   // Bright cyan
    },

    // Always use symbols + color for status
    // ✓ Success (green)
    // ⚠ Warning (orange)
    // ✗ Error (red)
    // ℹ Info (blue)
}

// Design guidelines for accessible themes:
// 1. Minimum contrast ratio 4.5:1 for normal text
// 2. Minimum contrast ratio 3:1 for large text
// 3. Never rely solely on color to convey information
// 4. Always pair color with symbols, text, or patterns
// 5. Test with color blindness simulators
// 6. Provide high contrast mode option
```

**Accessibility checklist**:
```go
// Contrast calculation (simplified)
func contrastRatio(fg, bg lipgloss.Color) float64 {
    // Calculate relative luminance
    // Return contrast ratio (1-21)
    // 4.5:1 minimum for AA compliance
    // 7:1 minimum for AAA compliance
    return 0.0 // Implement proper calculation
}

// Validate theme accessibility
func validateTheme(t Theme) []string {
    issues := []string{}

    // Check contrast ratios
    fgBgContrast := contrastRatio(t.Foreground.Dark, t.Background.Dark)
    if fgBgContrast < 4.5 {
        issues = append(issues, "Insufficient foreground/background contrast")
    }

    // Check semantic color distinctiveness
    // Ensure success/error are distinguishable to color-blind users

    return issues
}
```

### 8. Configuration-Driven Theming

Load themes from configuration files for user customization.

```go
package config

import (
    "encoding/json"
    "os"
    "github.com/charmbracelet/lipgloss"
    "myapp/theme"
)

// ThemeConfig represents a theme in JSON
type ThemeConfig struct {
    Name       string                 `json:"name"`
    Colors     map[string]ColorConfig `json:"colors"`
}

type ColorConfig struct {
    Light string `json:"light"`
    Dark  string `json:"dark"`
}

// Load theme from JSON file
func LoadThemeFromFile(path string) (theme.Theme, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return theme.Theme{}, err
    }

    var config ThemeConfig
    if err := json.Unmarshal(data, &config); err != nil {
        return theme.Theme{}, err
    }

    return configToTheme(config), nil
}

func configToTheme(config ThemeConfig) theme.Theme {
    return theme.Theme{
        Name: config.Name,
        Foreground: lipgloss.AdaptiveColor{
            Light: config.Colors["foreground"].Light,
            Dark:  config.Colors["foreground"].Dark,
        },
        Background: lipgloss.AdaptiveColor{
            Light: config.Colors["background"].Light,
            Dark:  config.Colors["background"].Dark,
        },
        Primary: lipgloss.AdaptiveColor{
            Light: config.Colors["primary"].Light,
            Dark:  config.Colors["primary"].Dark,
        },
        // ... map rest of colors
    }
}

// Save theme to JSON file
func SaveThemeToFile(t theme.Theme, path string) error {
    config := themeToConfig(t)

    data, err := json.MarshalIndent(config, "", "  ")
    if err != nil {
        return err
    }

    return os.WriteFile(path, data, 0644)
}

func themeToConfig(t theme.Theme) ThemeConfig {
    return ThemeConfig{
        Name: t.Name,
        Colors: map[string]ColorConfig{
            "foreground": {
                Light: t.Foreground.Light,
                Dark:  t.Foreground.Dark,
            },
            "background": {
                Light: t.Background.Light,
                Dark:  t.Background.Dark,
            },
            // ... map rest of colors
        },
    }
}
```

**Example theme JSON**:
```json
{
  "name": "Custom Theme",
  "colors": {
    "foreground": {
      "light": "235",
      "dark": "252"
    },
    "background": {
      "light": "255",
      "dark": "235"
    },
    "primary": {
      "light": "62",
      "dark": "39"
    },
    "success": {
      "light": "28",
      "dark": "42"
    },
    "warning": {
      "light": "214",
      "dark": "220"
    },
    "error": {
      "light": "160",
      "dark": "196"
    },
    "info": {
      "light": "39",
      "dark": "51"
    }
  }
}
```

### 9. Testing Themes Across Terminals

Strategies for testing themes in different terminal environments.

```go
package main

import (
    "fmt"
    "os"
    "github.com/charmbracelet/lipgloss"
    "myapp/theme"
    "myapp/styles"
)

func testTheme(t theme.Theme) {
    styles.SetTheme(t)

    fmt.Printf("\n=== Testing Theme: %s ===\n", t.Name)
    fmt.Printf("Color Profile: %s\n", lipgloss.ColorProfile())
    fmt.Printf("Dark Background: %v\n", lipgloss.HasDarkBackground())
    fmt.Println()

    // Test all semantic colors
    fmt.Println(styles.Success("Success message"))
    fmt.Println(styles.Warning("Warning message"))
    fmt.Println(styles.Error("Error message"))
    fmt.Println(styles.Info("Info message"))
    fmt.Println()

    // Test text hierarchy
    fmt.Println(styles.Header().Render("Primary Header"))
    fmt.Println(styles.Paragraph().Render("Primary text paragraph"))
    fmt.Println(lipgloss.NewStyle().
        Foreground(t.TextSecondary).
        Render("Secondary text"))
    fmt.Println(lipgloss.NewStyle().
        Foreground(t.TextMuted).
        Render("Muted text"))
    fmt.Println()

    // Test borders and boxes
    fmt.Println(styles.Box().Render("Bordered content"))
    fmt.Println()

    // Test highlights
    fmt.Println(styles.HighlightBox("Highlighted content"))
    fmt.Println(styles.SelectedItem("Selected item"))
}

// Force different terminal modes for testing
func testInMode(mode string) {
    switch mode {
    case "truecolor":
        os.Setenv("COLORTERM", "truecolor")
    case "256":
        os.Unsetenv("COLORTERM")
        os.Setenv("TERM", "xterm-256color")
    case "ansi":
        os.Unsetenv("COLORTERM")
        os.Setenv("TERM", "xterm")
    case "ascii":
        os.Unsetenv("COLORTERM")
        os.Setenv("TERM", "dumb")
    }

    // Re-initialize color profile
    lipgloss.SetColorProfile(lipgloss.ColorProfile())
}

func main() {
    modes := []string{"truecolor", "256", "ansi", "ascii"}

    for _, mode := range modes {
        fmt.Printf("\n\n========== Testing in %s mode ==========\n", mode)
        testInMode(mode)

        for _, t := range []theme.Theme{
            theme.DefaultTheme,
            theme.DraculaTheme,
            theme.AccessibleTheme,
        } {
            testTheme(t)
        }
    }
}
```

## Challenge Description

Build three theme-aware applications demonstrating adaptive styling and runtime theme switching.

### Challenge 1: Theme Showcase Application

Create a CLI tool that displays all available themes with examples of each style element.

**Requirements**:
1. Implement at least 3 complete themes (default, dark, high-contrast)
2. Show all semantic styles (success, warning, error, info)
3. Display text hierarchy (header, body, muted)
4. Show borders and boxes in each theme
5. Include adaptive color examples
6. Support runtime theme switching via flag
7. Display theme metadata (name, color profile compatibility)
8. Show color accessibility information

**Example output**:
```bash
$ ./theme-showcase --theme dracula

╭─────────────────────────────────────────╮
│       Theme: Dracula                    │
│       Color Profile: TrueColor          │
│       Dark Background: true             │
╰─────────────────────────────────────────╯

Semantic Styles
───────────────────────────────────────────
✓ Success: Operation completed successfully
⚠ Warning: Configuration not optimized
✗ Error: Connection refused
ℹ Info: Processing 1,234 items

Text Hierarchy
───────────────────────────────────────────
Primary Header

Primary paragraph text with good contrast
and readability across different terminals.

Secondary descriptive text for less important information.

Muted text for metadata and timestamps.

Layout Components
───────────────────────────────────────────
╭─ Bordered Box ────────────────────────╮
│ Content with themed borders and       │
│ proper contrast for readability.      │
╰───────────────────────────────────────╯

  Highlighted content for emphasis

  Selected item with background

Color Palette
───────────────────────────────────────────
Primary:   #BD93F9 ████
Secondary: #FF79C6 ████
Accent:    #FFB86C ████
Success:   #50FA7B ████
Warning:   #F1FA8C ████
Error:     #FF5555 ████
Info:      #8BE9FD ████
```

### Challenge 2: Adaptive Configuration Editor

Build a theme-aware configuration file editor with syntax highlighting using themes.

**Requirements**:
1. Read and display configuration files (JSON, YAML, TOML)
2. Apply syntax highlighting using current theme
3. Show line numbers with themed colors
4. Highlight current line with selection color
5. Support theme switching during runtime (hot reload)
6. Display file metadata with semantic colors
7. Show validation errors with error theme color
8. Support both light and dark terminal backgrounds

**Example output**:
```
╭─ config.json ─────────────────────────────────────────────────╮
│ File: config.json | Lines: 15 | Modified: 2024-01-15          │
╰───────────────────────────────────────────────────────────────╯

  1  {
  2    "name": "myapp",
  3    "version": "1.0.0",
> 4    "database": {
  5      "host": "localhost",
  6      "port": 5432,
  7      "name": "mydb"
  8    },
  9    "logging": {
 10      "level": "info",
 11      "format": "json"
 12    },
 13    "features": {
 14      "debug": false
 15    }
 16  }

✓ Valid JSON | Theme: Solarized | Press 't' to change theme
```

### Challenge 3: Task Tracker CLI Enhancement (Themed)

Enhance the Task Tracker from Lesson 13 with adaptive theming and user-selectable themes.

**Requirements**:
1. Add theme support to existing Task Tracker
2. Implement at least 3 themes (default, vibrant, minimal)
3. Save user's theme preference to config file
4. Apply theme to all output (list, add, complete, delete)
5. Show task status with themed colors
6. Support `task theme` command to view/change themes
7. Provide theme preview before applying
8. Include accessible high-contrast theme option

**Example output**:
```bash
$ task theme list

Available Themes:
• default     - Balanced adaptive theme
• vibrant     - High-contrast colorful theme
• minimal     - Subtle monochrome theme
• accessible  - High-contrast accessible theme

Current theme: default

$ task theme set vibrant
✓ Theme set to: vibrant

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

$ task theme preview accessible

[Shows preview of all styles in accessible theme]

Apply this theme? (y/n): y
✓ Theme applied and saved to config
```

## Test Requirements

Implement comprehensive tests for theme functionality and adaptive styling.

### Test Structure Pattern

```go
package theme

import (
    "testing"
    "github.com/charmbracelet/lipgloss"
)

func TestAdaptiveColor(t *testing.T) {
    tests := []struct {
        name          string
        adaptiveColor lipgloss.AdaptiveColor
        isDark        bool
        wantColor     string
    }{
        {
            name: "dark background uses dark color",
            adaptiveColor: lipgloss.AdaptiveColor{
                Light: "235",
                Dark:  "252",
            },
            isDark:    true,
            wantColor: "252",
        },
        {
            name: "light background uses light color",
            adaptiveColor: lipgloss.AdaptiveColor{
                Light: "235",
                Dark:  "252",
            },
            isDark:    false,
            wantColor: "235",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Simulate background detection
            // (In real tests, mock HasDarkBackground())

            // Verify correct color selected
            // Note: Direct testing of AdaptiveColor selection
            // requires internal knowledge or integration tests
        })
    }
}

func TestThemeCompleteness(t *testing.T) {
    themes := []Theme{
        DefaultTheme,
        DraculaTheme,
        SolarizedTheme,
        AccessibleTheme,
    }

    for _, theme := range themes {
        t.Run(theme.Name, func(t *testing.T) {
            // Check all required colors are defined
            if theme.Name == "" {
                t.Error("theme name is empty")
            }

            // Verify foreground/background set
            if theme.Foreground.Light == "" || theme.Foreground.Dark == "" {
                t.Error("foreground colors not set")
            }
            if theme.Background.Light == "" || theme.Background.Dark == "" {
                t.Error("background colors not set")
            }

            // Verify semantic colors
            if theme.Success.Light == "" || theme.Success.Dark == "" {
                t.Error("success colors not set")
            }
            if theme.Error.Light == "" || theme.Error.Dark == "" {
                t.Error("error colors not set")
            }
            if theme.Warning.Light == "" || theme.Warning.Dark == "" {
                t.Error("warning colors not set")
            }
            if theme.Info.Light == "" || theme.Info.Dark == "" {
                t.Error("info colors not set")
            }
        })
    }
}

func TestThemeSwitching(t *testing.T) {
    originalTheme := GetTheme()
    defer SetTheme(originalTheme) // Restore after test

    // Switch to Dracula
    SetTheme(DraculaTheme)
    if GetTheme().Name != "Dracula" {
        t.Error("theme not switched to Dracula")
    }

    // Switch to Solarized
    SetTheme(SolarizedTheme)
    if GetTheme().Name != "Solarized" {
        t.Error("theme not switched to Solarized")
    }
}

func TestStylesUseCurrentTheme(t *testing.T) {
    originalTheme := GetTheme()
    defer SetTheme(originalTheme)

    // Set to Dracula theme
    SetTheme(DraculaTheme)

    // Create styled output
    success := Success("Test message")

    // Verify style uses Dracula colors
    // (Requires inspecting rendered output or style properties)
    if success == "" {
        t.Error("success function returned empty string")
    }
}

func TestConfigLoadSave(t *testing.T) {
    // Create temporary config file
    tempFile := t.TempDir() + "/theme.json"

    // Save theme
    err := SaveThemeToFile(DraculaTheme, tempFile)
    if err != nil {
        t.Fatalf("failed to save theme: %v", err)
    }

    // Load theme
    loaded, err := LoadThemeFromFile(tempFile)
    if err != nil {
        t.Fatalf("failed to load theme: %v", err)
    }

    // Verify loaded theme matches original
    if loaded.Name != DraculaTheme.Name {
        t.Errorf("name: got %q, want %q", loaded.Name, DraculaTheme.Name)
    }

    // Verify colors match
    if loaded.Success.Dark != DraculaTheme.Success.Dark {
        t.Errorf("success color mismatch")
    }
}

func TestAccessibleThemeContrast(t *testing.T) {
    // Verify accessible theme meets contrast requirements
    theme := AccessibleTheme

    // Check high contrast between foreground/background
    // (Simplified test - real implementation would calculate contrast ratio)

    if theme.Foreground.Light == theme.Background.Light {
        t.Error("accessible theme: foreground and background too similar")
    }

    if theme.Foreground.Dark == theme.Background.Dark {
        t.Error("accessible theme: foreground and background too similar")
    }
}

func TestColorProfileDetection(t *testing.T) {
    profile := lipgloss.ColorProfile()

    // Verify profile is one of the known types
    validProfiles := []lipgloss.Profile{
        lipgloss.TrueColor,
        lipgloss.ANSI256,
        lipgloss.ANSI,
        lipgloss.Ascii,
    }

    found := false
    for _, vp := range validProfiles {
        if profile == vp {
            found = true
            break
        }
    }

    if !found {
        t.Errorf("unknown color profile: %v", profile)
    }
}
```

### Required Test Cases

**For Adaptive Colors**:
1. Dark background selects dark color variant
2. Light background selects light color variant
3. AdaptiveColor works in styles
4. Hex colors supported in AdaptiveColor

**For Themes**:
1. All themes have required colors defined
2. Theme switching updates global state
3. Styles use current theme colors
4. Theme names are unique

**For Configuration**:
1. Themes save to JSON correctly
2. Themes load from JSON correctly
3. Invalid JSON handled gracefully
4. Missing colors use defaults

**For Accessibility**:
1. Accessible theme has high contrast
2. All themes include symbols with colors
3. Color-blind simulation (manual test)

## Input/Output Specifications

### Theme Showcase

**Input**: Theme name via flag
**Output**: Complete theme demonstration

```bash
Input: ./theme-showcase --theme dracula
Output: (Dracula theme samples with all style elements)
```

### Configuration Editor

**Input**: File path and theme name
**Output**: Syntax-highlighted file with theme

```bash
Input: ./config-editor --file config.json --theme solarized
Output: (File content with Solarized syntax highlighting)
```

### Themed Task Tracker

**Input**: Task tracker commands with theme
**Output**: Themed output for all operations

```bash
Input: task list --theme vibrant
Output: (Task list with vibrant theme colors)

Input: task theme set minimal
Output: ✓ Theme set to: minimal
```

## Success Criteria

### Functional Requirements
- [ ] HasDarkBackground() detection works correctly
- [ ] AdaptiveColor selects appropriate colors
- [ ] At least 3 complete themes implemented
- [ ] Theme switching works at runtime
- [ ] Styles update when theme changes
- [ ] Configuration save/load works correctly
- [ ] Accessible theme meets contrast standards
- [ ] Color profile detection works

### Code Quality Requirements
- [ ] Theme definitions in separate package
- [ ] Reusable style factories
- [ ] Clean theme switching API
- [ ] Configuration format documented
- [ ] Accessibility guidelines followed
- [ ] Theme validation implemented
- [ ] Example themes provided

### Testing Requirements
- [ ] Adaptive color tests for both backgrounds
- [ ] Theme completeness verification
- [ ] Theme switching tested
- [ ] Config load/save tested
- [ ] Accessibility standards validated
- [ ] Integration tests in multiple terminals
- [ ] Test coverage >75%

### Visual Requirements
- [ ] Themes look good in both light and dark terminals
- [ ] Contrast is sufficient for readability
- [ ] Semantic colors are distinguishable
- [ ] Accessible theme works for color-blind users
- [ ] No jarring color combinations
- [ ] Professional appearance
- [ ] Consistent across terminal emulators

## Common Pitfalls

### Pitfall 1: Not Testing in Both Light and Dark Terminals

❌ **Wrong**: Only testing in dark terminal
```go
// This might look fine in dark terminal but terrible in light
style := lipgloss.NewStyle().
    Foreground(lipgloss.Color("252")). // Light gray
    Background(lipgloss.Color("255"))  // White - no contrast in light terminal!
```

✅ **Correct**: Use AdaptiveColor for both backgrounds
```go
style := lipgloss.NewStyle().
    Foreground(lipgloss.AdaptiveColor{
        Light: "235",  // Dark gray on white
        Dark:  "252",  // Light gray on black
    }).
    Background(lipgloss.AdaptiveColor{
        Light: "255",  // White
        Dark:  "235",  // Dark gray
    })
```

### Pitfall 2: Relying Only on Color for Information

❌ **Wrong**: Color as only status indicator
```go
func ShowStatus(success bool, msg string) string {
    color := lipgloss.Color("42") // Green
    if !success {
        color = lipgloss.Color("196") // Red
    }

    // No visual distinction for color-blind users!
    return lipgloss.NewStyle().Foreground(color).Render(msg)
}
```

✅ **Correct**: Combine color with symbols
```go
func ShowStatus(success bool, msg string) string {
    var style lipgloss.Style
    var prefix string

    if success {
        style = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
        prefix = "✓ "  // Checkmark
    } else {
        style = lipgloss.NewStyle().Foreground(lipgloss.Color("196"))
        prefix = "✗ "  // X mark
    }

    return style.Render(prefix + msg)
}
```

### Pitfall 3: Hardcoding Theme in Style Definitions

❌ **Wrong**: Theme colors embedded in functions
```go
func Header(text string) string {
    style := lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")). // Hardcoded pink
        Bold(true)
    return style.Render(text)
}

// Can't change theme without modifying code!
```

✅ **Correct**: Use current theme
```go
func Header(text string) string {
    theme := GetTheme()
    style := lipgloss.NewStyle().
        Foreground(theme.Primary). // Uses theme color
        Bold(true)
    return style.Render(text)
}

// Theme can be changed at runtime
```

### Pitfall 4: Not Handling Missing Color Profile

❌ **Wrong**: Assuming true color support
```go
// Will degrade poorly in ANSI-only terminals
style := lipgloss.NewStyle().
    Foreground(lipgloss.Color("#FF6B9D")). // True color
    Background(lipgloss.Color("#1A1B26"))
```

✅ **Correct**: Design for graceful degradation
```go
// Test what it looks like in different profiles
profiles := []lipgloss.Profile{
    lipgloss.TrueColor,
    lipgloss.ANSI256,
    lipgloss.ANSI,
}

for _, profile := range profiles {
    // Verify theme still looks good
    // Consider providing profile-specific palettes
}
```

### Pitfall 5: Not Saving Theme Preference

❌ **Wrong**: Theme resets every run
```go
func main() {
    // User sets theme but it's lost on restart
    SetTheme(DraculaTheme)
    // ... rest of app
}
```

✅ **Correct**: Persist theme choice
```go
func main() {
    // Load saved theme
    configPath := getConfigPath()
    if savedTheme, err := LoadThemeFromFile(configPath); err == nil {
        SetTheme(savedTheme)
    }

    // ... rest of app

    // Save theme on change
    if themeChanged {
        SaveThemeToFile(GetTheme(), configPath)
    }
}
```

### Pitfall 6: Inconsistent Theme Application

❌ **Wrong**: Some output uses theme, some doesn't
```go
func ShowResults() {
    fmt.Println(styles.Header().Render("Results"))  // Themed
    fmt.Println("Status: Success")                  // Not themed!
    fmt.Println(styles.Success("Operation done"))   // Themed
}
```

✅ **Correct**: Apply theme consistently
```go
func ShowResults() {
    fmt.Println(styles.Header().Render("Results"))
    fmt.Println(styles.Paragraph().Render("Status: Success"))
    fmt.Println(styles.Success("Operation done"))
}

// Or create a themed output wrapper
func Print(s string) {
    fmt.Println(styles.Paragraph().Render(s))
}
```

## Extension Challenges

### Extension 1: Color Picker Tool
Build interactive color picker for theme creation:
```go
// Interactive terminal color picker
func ColorPicker() lipgloss.Color {
    // Show 256-color palette
    // Allow selection with arrow keys
    // Preview color in context
    // Return selected color
}

// Theme builder CLI
func BuildTheme() Theme {
    theme := Theme{}
    theme.Foreground.Dark = ColorPicker() // Select each color
    // ... etc
    return theme
}
```

### Extension 2: Theme Interpolation
Create gradient themes between two base themes:
```go
func InterpolateThemes(t1, t2 Theme, ratio float64) Theme {
    // ratio 0.0 = fully t1, 1.0 = fully t2, 0.5 = halfway

    return Theme{
        Foreground: interpolateColor(t1.Foreground, t2.Foreground, ratio),
        Background: interpolateColor(t1.Background, t2.Background, ratio),
        // ... interpolate all colors
    }
}

// Animated theme transitions
func AnimateThemeTransition(from, to Theme, duration time.Duration) {
    steps := 60
    for i := 0; i <= steps; i++ {
        ratio := float64(i) / float64(steps)
        intermediateTheme := InterpolateThemes(from, to, ratio)
        SetTheme(intermediateTheme)
        render() // Render current UI
        time.Sleep(duration / time.Duration(steps))
    }
}
```

### Extension 3: Time-Based Theme Switching
Automatically switch themes based on time of day:
```go
type ThemeSchedule struct {
    DayTheme   Theme
    NightTheme Theme
    DayStart   time.Time  // e.g., 6:00 AM
    NightStart time.Time  // e.g., 6:00 PM
}

func (ts *ThemeSchedule) GetCurrentTheme() Theme {
    now := time.Now()
    hour := now.Hour()

    if hour >= ts.DayStart.Hour() && hour < ts.NightStart.Hour() {
        return ts.DayTheme
    }
    return ts.NightTheme
}

// Auto-update theme
func WatchThemeSchedule(schedule ThemeSchedule) {
    ticker := time.NewTicker(1 * time.Minute)
    for range ticker.C {
        currentTheme := schedule.GetCurrentTheme()
        if currentTheme.Name != GetTheme().Name {
            SetTheme(currentTheme)
        }
    }
}
```

### Extension 4: Theme Import/Export
Support importing themes from popular formats:
```go
// Import from VS Code theme format
func ImportVSCodeTheme(path string) (Theme, error) {
    // Parse VS Code JSON theme
    // Map colors to Lip Gloss theme
    // Handle semantic token colors
}

// Import from iTerm2 color scheme
func ImportITerm2Theme(path string) (Theme, error) {
    // Parse iTerm2 .itermcolors XML
    // Map to Lip Gloss palette
}

// Export to various formats
func ExportTheme(t Theme, format string) ([]byte, error) {
    switch format {
    case "json":
        return json.Marshal(t)
    case "yaml":
        return yaml.Marshal(t)
    case "toml":
        return toml.Marshal(t)
    }
}
```

### Extension 5: Theme Gallery and Sharing
Create theme sharing system:
```go
type ThemeRegistry struct {
    URL string // e.g., "https://themes.example.com"
}

func (tr *ThemeRegistry) List() ([]ThemeInfo, error) {
    // Fetch available themes from registry
}

func (tr *ThemeRegistry) Download(name string) (Theme, error) {
    // Download theme by name
}

func (tr *ThemeRegistry) Upload(theme Theme) error {
    // Share theme with community
}

// CLI integration
/*
$ task themes browse
$ task themes install dracula-pro
$ task themes publish my-theme
*/
```

## AI Provider Guidelines

### Expected Implementation Approach

1. **Theme System First**: Define complete theme structure with all colors
2. **AdaptiveColor Usage**: Use everywhere for automatic light/dark adaptation
3. **Style Factory**: Create reusable style functions that use current theme
4. **Runtime Switching**: Support theme changes without restart
5. **Accessibility**: Always include high-contrast accessible theme
6. **Testing**: Verify in multiple terminal types and backgrounds

### Code Organization

```
lesson-17/
├── theme-showcase/
│   ├── main.go
│   ├── theme/
│   │   ├── theme.go          # Theme definitions
│   │   ├── defaults.go       # Predefined themes
│   │   └── theme_test.go
│   ├── styles/
│   │   ├── styles.go         # Style factories
│   │   └── styles_test.go
│   └── README.md
├── config-editor/
│   ├── main.go
│   ├── editor/
│   │   ├── editor.go         # Editor logic
│   │   ├── syntax.go         # Syntax highlighting
│   │   └── editor_test.go
│   └── README.md
└── themed-task-tracker/
    ├── main.go
    ├── config/
    │   ├── config.go         # Theme persistence
    │   └── config_test.go
    └── README.md
```

### Quality Checklist

- [ ] AdaptiveColor used for all theme colors
- [ ] At least 3 complete themes (default, dark, accessible)
- [ ] Theme switching at runtime works
- [ ] Themes saved/loaded from config
- [ ] Accessible theme meets WCAG AA standards
- [ ] Symbols combined with colors for status
- [ ] Terminal background detection tested
- [ ] Color profile degradation handled
- [ ] Documentation for creating custom themes
- [ ] Tests cover theme switching and persistence

### Testing Approach

Test themes in multiple environments:

```bash
# Test in different terminals
# iTerm2, Terminal.app, Alacritty, Kitty, Windows Terminal

# Test with different TERM values
TERM=xterm-256color ./app
TERM=xterm ./app
TERM=dumb ./app

# Test with different backgrounds
# Set terminal to light background and test
# Set terminal to dark background and test

# Test color profiles
COLORTERM=truecolor ./app
unset COLORTERM && TERM=xterm-256color ./app
unset COLORTERM && TERM=xterm ./app

# Visual testing
go test ./... -v
./theme-showcase --theme default
./theme-showcase --theme dracula
./theme-showcase --theme accessible
```

## Learning Resources

### Official Documentation
- [Lip Gloss Adaptive Colors](https://github.com/charmbracelet/lipgloss#adaptive-colors) - AdaptiveColor documentation
- [Terminal Background Detection](https://github.com/charmbracelet/lipgloss#terminal-background) - HasDarkBackground() usage
- [Color Profiles](https://github.com/charmbracelet/lipgloss#color-profiles) - Terminal capability detection
- [Lip Gloss Examples - Theming](https://github.com/charmbracelet/lipgloss/tree/master/examples/themes) - Theme examples

### Tutorials and Guides
- [Building Adaptive Terminal UIs](https://charm.sh/blog/adaptive-terminals) - Charm blog on adaptive design
- [Terminal Color Design](https://github.com/charmbracelet/lipgloss/wiki/Color-Design) - Color theory for terminals
- [Accessible Terminal Colors](https://charm.sh/blog/accessibility) - Accessibility guidelines
- [Theme System Architecture](https://github.com/charmbracelet/lipgloss/discussions/234) - Community patterns

### Color and Accessibility Resources
- [WCAG Color Contrast](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html) - Accessibility standards
- [Color Blindness Simulator](https://www.color-blindness.com/coblis-color-blindness-simulator/) - Test your themes
- [Terminal Color Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) - Popular terminal themes
- [ANSI 256 Color Palette](https://www.ditig.com/256-colors-cheat-sheet) - Color reference

### Related Tools and Examples
- [Dracula Theme](https://draculatheme.com/contribute) - Popular dark theme
- [Solarized](https://ethanschoonover.com/solarized/) - Scientifically designed palette
- [Nord Theme](https://www.nordtheme.com/) - Arctic-inspired color palette
- [Monokai](https://monokai.pro/) - Professional color scheme

## Validation Commands

```bash
# Install Lip Gloss (if not already installed)
go get github.com/charmbracelet/lipgloss

# Format code
go fmt ./lesson-17/...

# Run all tests
go test ./lesson-17/... -v

# Check test coverage
go test ./lesson-17/... -cover

# Build all challenges
cd lesson-17/theme-showcase && go build
cd lesson-17/config-editor && go build
cd lesson-17/themed-task-tracker && go build

# Test theme showcase with all themes
./theme-showcase/theme-showcase --theme default
./theme-showcase/theme-showcase --theme dracula
./theme-showcase/theme-showcase --theme solarized
./theme-showcase/theme-showcase --theme accessible

# Test in different color profiles
COLORTERM=truecolor ./theme-showcase/theme-showcase --theme dracula
TERM=xterm-256color ./theme-showcase/theme-showcase --theme dracula
TERM=xterm ./theme-showcase/theme-showcase --theme dracula

# Test config editor
./config-editor/config-editor --file config.json --theme solarized

# Test themed task tracker
./themed-task-tracker/task theme list
./themed-task-tracker/task theme set vibrant
./themed-task-tracker/task list

# Test background detection
echo "Terminal background detection:"
./theme-showcase/theme-showcase --detect

# Verify in different terminals
# Open iTerm2, Terminal.app, Alacritty, etc. and test

# Test light terminal background
# 1. Set terminal to light background
# 2. Run: ./theme-showcase/theme-showcase --theme default
# 3. Verify text is dark and readable

# Test dark terminal background
# 1. Set terminal to dark background
# 2. Run: ./theme-showcase/theme-showcase --theme default
# 3. Verify text is light and readable

# Run with race detector
go test ./lesson-17/... -race

# Benchmark theme operations
go test ./lesson-17/... -bench=. -benchmem
```

---

**Next Lesson**: [Lesson 18: Enhancing Existing CLIs with Style](lesson-18-cli-enhancement.md) - Apply styling to real CLI applications

**Previous Lesson**: [Lesson 16: Layout & Composition](lesson-16-lipgloss-layout.md) - Complex layouts with joining

**Phase Overview**: [Phase 3: Styling with Lip Gloss](../README.md#phase-3-styling-with-lip-gloss-week-5) - Terminal styling before TUI complexity
