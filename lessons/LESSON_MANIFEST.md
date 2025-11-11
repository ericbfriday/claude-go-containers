# Lesson Manifest - Complete Curriculum Outline

This manifest provides the complete structure for all 42 lessons in the GoLang Learning Curriculum. AI providers can use this to generate remaining lesson specifications following the established template and patterns.

## Completed Specifications

✅ = Specification complete and ready for implementation

### Phase 1: Go Fundamentals (COMPLETE - 8/8) ✅
- ✅ **Lesson 01**: Hello World & Basic Syntax (`lesson-01-hello-world.md`)
- ✅ **Lesson 02**: Variables, Data Types & Operators (`lesson-02-variables.md`)
- ✅ **Lesson 03**: Control Flow - If, Switch, Loops (`lesson-03-control-flow.md`)
- ✅ **Lesson 04**: Functions & Multiple Returns (`lesson-04-functions.md`)
- ✅ **Lesson 05**: Structs & Methods (`lesson-05-structs-methods.md`)
- ✅ **Lesson 06**: Interfaces & Polymorphism (`lesson-06-interfaces.md`)
- ✅ **Lesson 07**: Error Handling Patterns (`lesson-07-error-handling.md`)
- ✅ **Lesson 08**: Packages & Modules + Quiz Game Milestone (`lesson-08-packages-modules.md`)

### Phase 2: CLI Development (Partial - 1/6)
- ✅ **Lesson 13**: Building a Task Tracker CLI (`lesson-13-task-tracker.md`) - Milestone Project

### Other
- ✅ **Template**: LESSON_TEMPLATE.md (for creating new specifications)

## Phase 1: Go Fundamentals (Weeks 1-2)

### Lesson 03: Control Flow - If, Switch, Loops
**File**: `lesson-03-control-flow.md`
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- If/else statements and short statement initialization
- Switch statements with cases and fallthrough
- For loops (traditional, while-style, infinite, range)
- Break, continue, and goto statements
- Loop control and iteration patterns

**Challenge Project:**
- Implement FizzBuzz with multiple approaches
- Create number guessing game with input validation
- Build simple menu system using switch
- Implement basic pattern matching functions

**Key Learning**: Understanding Go's streamlined control structures and idiomatic iteration patterns

---

### Lesson 04: Functions & Multiple Returns
**File**: `lesson-04-functions.md`
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- Function declaration and calling
- Multiple return values pattern
- Named return values
- Variadic functions (`...` parameter)
- Function values and closures
- Defer, panic, and recover

**Challenge Project:**
- Implement mathematical functions (factorial, fibonacci, GCD)
- Create string utility functions with variadic parameters
- Build error-returning functions following Go conventions
- Implement higher-order functions (map, filter, reduce equivalents)

**Key Learning**: Go's function signatures, multiple returns for error handling, and first-class functions

---

### Lesson 05: Structs & Methods
**File**: `lesson-05-structs-methods.md`
**Time**: 3-4 hours | **Difficulty**: Beginner

**Core Concepts:**
- Struct definition and initialization
- Anonymous fields and embedded structs
- Methods with value and pointer receivers
- Method sets and receiver choice guidelines
- Struct tags for JSON, XML, etc.
- Constructor patterns

**Challenge Project:**
- Create Person struct with methods for age calculation
- Implement Rectangle/Circle with area/perimeter methods
- Build a simple bank account with deposit/withdraw
- Design a book library system with struct composition

**Key Learning**: Go's approach to object-oriented programming without classes, method receivers, and composition over inheritance

---

### Lesson 06: Interfaces & Polymorphism
**File**: `lesson-06-interfaces.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Interface definition and implicit satisfaction
- Empty interface and type assertions
- Type switches for interface types
- Common standard library interfaces (Reader, Writer, Stringer)
- Interface composition
- Accept interfaces, return concrete types

**Challenge Project:**
- Implement Shape interface with multiple concrete types
- Create custom io.Reader/io.Writer implementations
- Build a simple plugin system using interfaces
- Implement Stringer interface for custom types

**Key Learning**: Go's interfaces enable flexible, testable code and are satisfied implicitly

---

### Lesson 07: Error Handling Patterns
**File**: `lesson-07-error-handling.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Error interface and custom error types
- Error wrapping with fmt.Errorf and %w
- errors.Is() and errors.As() for error checking
- Sentinel errors and when to use them
- Error handling best practices (handle once, add context)
- Panic and recover for exceptional cases

**Challenge Project:**
- Create custom error types with context
- Implement error wrapping chain
- Build validator with detailed error reporting
- Create graceful error handling for file operations

**Key Learning**: Go's explicit error handling philosophy and error wrapping for context preservation

---

### Lesson 08: Packages & Modules
**File**: `lesson-08-packages-modules.md`
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- Package organization and naming
- Exported vs unexported identifiers
- Internal packages and visibility
- go.mod and go.sum files
- Dependency management with go get
- Module versioning and semantic import versioning

**Challenge Project:**
- Create multi-package calculator project
- Build reusable string utility package
- Implement internal package for shared logic
- Create module with external dependencies

**Milestone**: Quiz Game (combining lessons 1-8)
- Build complete quiz game from Gophercises Exercise #1
- CSV parsing, time management, score tracking
- Demonstrates fundamental Go proficiency

**Key Learning**: Go's package system, module management, and code organization best practices

---

## Phase 2: CLI Development (Weeks 3-4) ✅ COMPLETE

### Lesson 09: Standard Library CLI with flag package
**File**: `lesson-09-stdlib-cli.md` ✅ (Completed)
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- flag package for command-line parsing
- Defining string, int, bool flags
- flag.Parse() and accessing flag values
- Custom flag types
- os.Args for raw arguments
- Basic CLI patterns (commands, options, arguments)

**Challenge Project:**
- Build word count tool (wc clone)
- Create file grep utility
- Implement calculator with flags
- Build log parser CLI

**Key Learning**: Standard library CLI capabilities before frameworks

---

### Lesson 10: File I/O & JSON Persistence
**File**: `lesson-10-file-io-json.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- os package for file operations
- ioutil/os functions for reading/writing
- bufio for buffered I/O
- JSON encoding/decoding with encoding/json
- Struct tags for JSON customization
- Handling file errors gracefully

**Challenge Project:**
- Implement CSV reader/writer
- Create config file loader (JSON/TOML)
- Build log file analyzer
- Implement data persistence layer

**Key Learning**: File I/O best practices and JSON marshaling patterns

---

### Lesson 11: Cobra Framework Fundamentals
**File**: `lesson-11-cobra-basics.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Cobra project initialization
- Root command setup
- Adding subcommands
- Command structure and organization
- Help generation and usage text
- cobra-cli for scaffolding

**Challenge Project:**
- Convert flag-based CLI to Cobra
- Build multi-command CLI tool
- Implement help and usage documentation
- Create nested command structure

**Key Learning**: Industry-standard CLI framework used by kubectl, docker, github CLI

---

### Lesson 12: Cobra Subcommands & Flags
**File**: `lesson-12-cobra-subcommands.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Persistent flags vs local flags
- Required flags and validation
- Flag binding and config files
- Positional arguments with Args validators
- PreRun and PostRun hooks
- Command aliases

**Challenge Project:**
- Build git-style CLI with subcommands
- Implement persistent configuration
- Add validation for required flags
- Create command shortcuts/aliases

**Key Learning**: Advanced Cobra patterns for professional CLI applications

---

### Lesson 13: Building a Task Tracker CLI
**File**: `lesson-13-task-tracker.md` ✅ (Completed)
**Time**: 4-6 hours | **Difficulty**: Intermediate | **Type**: Milestone Project

**Core Concepts:**
- Complete CRUD operations
- JSON file persistence
- Cobra subcommands (add, list, complete, delete)
- Project structure (cmd/, internal/)
- Atomic file writes
- Error handling throughout

**Challenge Project:**
- Full-featured task tracker CLI
- Data persistence with JSON
- Filtering and searching
- Multiple command implementation

**Milestone**: First complete CLI application demonstrating Phase 2 mastery

**Key Learning**: End-to-end CLI application development with best practices

---

### Lesson 14: API Integration & HTTP Clients
**File**: `lesson-14-api-integration.md` ✅ (Completed)
**Time**: 4-6 hours | **Difficulty**: Intermediate

**Core Concepts:**
- net/http client usage
- Making GET/POST requests
- Handling JSON responses
- Error handling for network operations
- Rate limiting and retries
- Authentication (API keys, tokens)

**Challenge Project:**
- GitHub User Activity CLI
- Weather CLI tool with API integration
- Currency converter using external API
- News aggregator CLI

**Milestone**: API-powered CLI demonstrating HTTP client skills

**Key Learning**: Integrating external APIs into CLI applications

---

## Phase 3: Styling with Lip Gloss (Week 5) ✅ COMPLETE

### Lesson 15: Lip Gloss Basics - Colors & Borders
**File**: `lesson-15-lipgloss-basics.md` ✅ (Completed)
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- Lip Gloss installation and setup
- Style creation and method chaining
- Color and background colors
- Border styles (rounded, double, thick, etc.)
- Padding and margins
- Text alignment

**Challenge Project:**
- Add colors to existing CLI output
- Create bordered boxes for content
- Style error/success/warning messages differently
- Build fancy ASCII art header

**Key Learning**: Terminal styling basics without full TUI complexity

---

### Lesson 16: Layout & Composition
**File**: `lesson-16-lipgloss-layout.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- JoinHorizontal and JoinVertical
- Width and height constraints
- Place function for positioning
- Multi-column layouts
- Complex compositions
- Table-like structures

**Challenge Project:**
- Create dashboard-style output
- Build multi-column data display
- Implement pretty-printed tables
- Design split-pane interface

**Key Learning**: Composing complex layouts from styled blocks

---

### Lesson 17: Adaptive Styling & Theming
**File**: `lesson-17-lipgloss-theming.md` ✅ (Completed)
**Time**: 2-3 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Adaptive colors for light/dark terminals
- Terminal capability detection
- Color degradation strategies
- Theme systems and color palettes
- Style reuse patterns
- Configuration-driven styling

**Challenge Project:**
- Implement light/dark theme support
- Create configurable color schemes
- Build theme switcher
- Design accessible color palettes

**Key Learning**: Graceful degradation and theme-aware terminal UIs

---

### Lesson 18: Enhancing Existing CLIs with Style
**File**: `lesson-18-cli-enhancement.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate | **Type**: Milestone Project

**Core Concepts:**
- Retrofitting Lip Gloss into existing projects
- Progress indicators and status messages
- Table formatting for data display
- Error message styling
- Loading states and spinners (preview for Bubbles)

**Challenge Project:**
- Enhance Task Tracker CLI from Lesson 13
- Add styled output to API integration project
- Create beautiful help pages
- Implement colored diff output

**Milestone**: Styled CLI demonstrating Lip Gloss proficiency

**Key Learning**: Transforming plain CLI into beautiful terminal UI

---

## Phase 4: Concurrency Fundamentals (Weeks 6-7) ✅ COMPLETE

### Lesson 19: Introduction to Goroutines
**File**: `lesson-19-goroutines-intro.md` ✅ (Completed)
**Time**: 2-3 hours | **Difficulty**: Intermediate

**Core Concepts:**
- What are goroutines
- The `go` keyword
- Goroutine scheduling and runtime
- Comparing sequential vs concurrent execution
- Goroutine lifecycle
- Don't communicate by sharing memory

**Challenge Project:**
- Concurrent counter example
- Parallel computation (Monte Carlo pi estimation)
- Multiple timers running concurrently
- Demonstrating goroutine overhead

**Key Learning**: Understanding concurrency basics and goroutine creation

---

### Lesson 20: Channels - Unbuffered & Buffered
**File**: `lesson-20-channels.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Channel creation with make()
- Sending and receiving operations
- Unbuffered channels (synchronous)
- Buffered channels (asynchronous up to capacity)
- Channel directions (send-only, receive-only)
- Closing channels

**Challenge Project:**
- Producer-consumer pattern
- Job queue with workers
- Buffered vs unbuffered performance comparison
- Message passing between goroutines

**Key Learning**: Channels as the primary communication mechanism between goroutines

---

### Lesson 21: Channel Patterns - Select, Timeouts, Closing
**File**: `lesson-21-channel-patterns.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Select statement for multiple channels
- Timeout patterns with time.After
- Default cases in select
- Range over channels
- Detecting closed channels
- nil channels in select

**Challenge Project:**
- Timeout handling for network operations
- Merging multiple channel streams
- Rate limiting with tickers
- Broadcasting to multiple receivers

**Key Learning**: Advanced channel patterns for robust concurrent programs

---

### Lesson 22: Sync Package - WaitGroups & Mutexes
**File**: `lesson-22-sync-package.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- sync.WaitGroup for goroutine coordination
- sync.Mutex for protecting shared state
- sync.RWMutex for read-heavy workloads
- sync.Once for one-time initialization
- sync.Pool for object reuse
- When to use mutexes vs channels

**Challenge Project:**
- Thread-safe counter with mutex
- Concurrent map access patterns
- Connection pool implementation
- Cache with RWMutex

**Key Learning**: Synchronization primitives for shared state protection

---

### Lesson 23: Worker Pools & Pipeline Patterns
**File**: `lesson-23-worker-patterns.md` ✅ (Completed)
**Time**: 4-5 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Fixed-size worker pools
- Job distribution patterns
- Pipeline stages with channels
- Fan-out, fan-in patterns
- Bounded parallelism
- Graceful shutdown of workers

**Challenge Project:**
- Image processing pipeline
- Log file processor with workers
- Web scraper with rate limiting
- Batch job processor

**Key Learning**: Production-ready concurrency patterns for real-world applications

---

### Lesson 24: Context for Cancellation & Deadlines
**File**: `lesson-24-context-cancellation.md` ✅ (Completed)
**Time**: 3-4 hours | **Difficulty**: Intermediate | **Type**: Milestone Project

**Core Concepts:**
- context.Background() and context.TODO()
- WithCancel, WithDeadline, WithTimeout, WithValue
- Propagating cancellation through call stacks
- Context in HTTP handlers
- Best practices for context usage
- errgroup package for error propagation

**Challenge Project:**
- Concurrent Web Crawler with cancellation
- Timeout-aware HTTP client
- Graceful shutdown for services
- Request-scoped context in CLI

**Milestone**: Concurrent web crawler demonstrating Phase 4 mastery

**Key Learning**: Context for managing lifecycle of concurrent operations

---

## Phase 5: Bubble Tea Architecture (Weeks 8-9)

### Lesson 25: Bubble Tea Fundamentals - Model-Update-View
**File**: `lesson-25-bubbletea-basics.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- The Elm Architecture pattern
- Model (application state)
- Init() for initialization
- Update(msg) for state transitions
- View() for rendering
- Messages and message handling
- Program lifecycle

**Challenge Project:**
- Simple counter application
- Stopwatch with start/stop
- Choice selector (up/down navigation)
- Text display with scrolling

**Key Learning**: Understanding reactive TUI architecture fundamentally different from imperative programming

---

### Lesson 26: Messages & Event Handling
**File**: `lesson-26-bubbletea-messages.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Built-in message types (KeyMsg, MouseMsg, WindowSizeMsg)
- Custom message types
- Message routing patterns
- Keyboard input handling
- Mouse input handling
- Window resize handling

**Challenge Project:**
- Keyboard-driven menu
- Mouse-clickable interface
- Responsive layout on resize
- Custom event types for business logic

**Key Learning**: Event-driven programming in TUI context

---

### Lesson 27: Commands & Asynchronous I/O
**File**: `lesson-27-bubbletea-commands.md`
**Time**: 4-5 hours | **Difficulty**: Advanced

**Core Concepts:**
- What are Commands
- Cmd type and functions
- tea.Tick for periodic updates
- Wrapping I/O operations in Commands
- tea.Batch for multiple commands
- tea.Sequence for sequential commands
- Never use goroutines directly (use Commands instead)

**Challenge Project:**
- HTTP request with loading state
- File watcher TUI
- Periodic refresh (clock, system stats)
- Async data loading indicator

**Key Learning**: Bubble Tea's approach to asynchronous operations through Commands

---

### Lesson 28: Building a Shopping List Tutorial
**File**: `lesson-28-shopping-list.md`
**Time**: 4-6 hours | **Difficulty**: Intermediate | **Type**: Milestone Project

**Core Concepts:**
- Complete Bubble Tea application
- Text input handling
- List management
- State machine patterns
- Adding/removing items
- Persistence integration

**Challenge Project:**
- Interactive shopping list from official tutorial
- Add item, mark done, delete
- Save to file
- Navigate with keyboard

**Milestone**: First complete Bubble Tea application demonstrating architecture understanding

**Key Learning**: Building a complete, functional TUI application from scratch

---

### Lesson 29: Stopwatch & Timer Applications
**File**: `lesson-29-stopwatch-timer.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Time-based updates with tea.Tick
- Start/stop/reset functionality
- Duration formatting
- Multiple timers/stopwatches
- Lap time tracking

**Challenge Project:**
- Stopwatch with lap times
- Countdown timer with alerts
- Pomodoro timer
- Multiple concurrent timers

**Key Learning**: Time-based TUI updates and state management

---

### Lesson 30: File Browser with Navigation
**File**: `lesson-30-file-browser.md`
**Time**: 4-6 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Directory traversal
- Tree-like navigation
- Cursor positioning
- Viewport scrolling (preview for Bubbles)
- File information display
- Keyboard navigation patterns

**Challenge Project:**
- Navigate filesystem with arrow keys
- Display file sizes and dates
- Preview file contents
- Navigate into/out of directories

**Key Learning**: Building interactive exploratory interfaces

---

## Phase 6: Bubbles Components (Weeks 10-11)

### Lesson 31: TextInput & Form Building
**File**: `lesson-31-bubbles-textinput.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- textinput.Model creation and configuration
- Character limit and validation
- Placeholder text
- Password mode
- Focus management
- Multiple inputs in forms

**Challenge Project:**
- Login form (username/password)
- Multi-field data entry
- Validation with error display
- Tab navigation between fields

**Key Learning**: Building forms with Bubbles components

---

### Lesson 32: List Component with Selection
**File**: `lesson-32-bubbles-list.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- list.Model setup
- Item interface implementation
- Filtering and fuzzy search
- Pagination
- Custom item rendering
- Selection handling

**Challenge Project:**
- Task list viewer
- Filterable file list
- Searchable command palette
- Todo list with status icons

**Key Learning**: Using List for navigable, searchable data display

---

### Lesson 33: Table Component for Data Display
**File**: `lesson-33-bubbles-table.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- table.Model configuration
- Column definitions
- Row data
- Styling columns
- Sorting
- Row selection

**Challenge Project:**
- Process list viewer
- CSV data displayer
- Git log viewer
- System resource monitor

**Key Learning**: Displaying tabular data effectively in terminal

---

### Lesson 34: Viewport for Scrollable Content
**File**: `lesson-34-bubbles-viewport.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- viewport.Model for scrolling
- Content larger than screen
- Scroll position management
- Mouse wheel support
- Percentage-based positioning
- Viewport in layouts

**Challenge Project:**
- Log file viewer
- Markdown renderer (with Glamour)
- Documentation browser
- Multi-pane viewer

**Key Learning**: Handling content that exceeds screen size

---

### Lesson 35: Spinner, Progress, & Visual Feedback
**File**: `lesson-35-bubbles-feedback.md`
**Time**: 2-3 hours | **Difficulty**: Beginner

**Core Concepts:**
- spinner.Model for loading indicators
- progress.Model for progress bars
- Built-in spinner styles
- Gradient progress bars
- Indeterminate vs determinate progress

**Challenge Project:**
- File download with progress
- Multi-step process with spinner
- Batch operation progress
- Loading screen for async operations

**Key Learning**: Providing visual feedback for long-running operations

---

### Lesson 36: Component Composition Patterns
**File**: `lesson-36-component-composition.md`
**Time**: 4-5 hours | **Difficulty**: Advanced | **Type**: Milestone Project

**Core Concepts:**
- Embedding Bubbles components in Model
- Delegating Update to components
- Composing View from components
- Message routing to correct component
- Focus management across components
- State coordination

**Challenge Project:**
- Interactive Todo TUI (combining textinput, list, viewport)
- Multi-pane file manager
- Dashboard with multiple components
- Form with table preview

**Milestone**: Complex TUI demonstrating component composition mastery

**Key Learning**: Building sophisticated TUIs from well-tested components

---

## Phase 7: Advanced TUI Development (Weeks 12-13)

### Lesson 37: Huh Forms Library
**File**: `lesson-37-huh-forms.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Huh form creation
- Field types (input, select, confirm, text)
- Form groups and pages
- Validation rules
- Conditional fields
- Standalone vs Bubble Tea integration

**Challenge Project:**
- Configuration wizard
- Survey/questionnaire
- Order form
- Setup assistant

**Key Learning**: High-level form building for data collection workflows

---

### Lesson 38: Complex State Management
**File**: `lesson-38-state-management.md`
**Time**: 4-5 hours | **Difficulty**: Advanced

**Core Concepts:**
- State machines for UI states
- Global vs local state
- State transitions and guards
- Reducer patterns
- Undo/redo implementation
- State persistence

**Challenge Project:**
- Multi-screen application
- Modal dialogs and overlays
- Wizard-style interfaces
- Editor with undo/redo

**Key Learning**: Managing complexity in large TUI applications

---

### Lesson 39: Keyboard Shortcuts & Help Systems
**File**: `lesson-39-keyboard-help.md`
**Time**: 3-4 hours | **Difficulty**: Intermediate

**Core Concepts:**
- Key binding organization
- help.Model from Bubbles
- Context-sensitive help
- Vim-style key bindings
- Customizable shortcuts
- Discovery mechanisms

**Challenge Project:**
- Comprehensive help system
- Keyboard shortcut overlay
- Vim-style modal editing
- Context help for each screen

**Key Learning**: Making TUIs discoverable and efficient

---

### Lesson 40: Testing TUI Applications
**File**: `lesson-40-testing-tuis.md`
**Time**: 4-5 hours | **Difficulty**: Advanced

**Core Concepts:**
- Unit testing Models
- Testing Update functions
- Testing View output
- tea.testutils package
- Mocking Commands
- Integration testing strategies

**Challenge Project:**
- Test suite for shopping list
- Model update tests
- Command behavior tests
- View rendering tests

**Key Learning**: Ensuring TUI quality through comprehensive testing

---

### Lesson 41: Kanban Board Capstone Project
**File**: `lesson-41-kanban-board.md`
**Time**: 8-12 hours | **Difficulty**: Advanced | **Type**: Capstone Project

**Core Concepts:**
- Multi-column layout
- Drag-drop simulation
- Card management
- Persistence
- Complex state
- Professional UI polish

**Challenge Project:**
- Full Kanban board TUI
- Todo / In Progress / Done columns
- Move cards between columns
- Add/edit/delete cards
- Save/load boards
- Tags and filters

**Milestone**: Production-quality TUI demonstrating mastery of Bubble Tea, Bubbles, and Lip Gloss

**Key Learning**: Building professional-grade terminal applications

---

### Lesson 42: Git TUI Dashboard
**File**: `lesson-42-git-dashboard.md`
**Time**: 8-12 hours | **Difficulty**: Advanced | **Type**: Capstone Project

**Core Concepts:**
- GitHub API integration
- Table components for PRs/issues
- Detail views with viewport
- Auto-refresh with tea.Tick
- OAuth authentication
- Spinner for loading states

**Challenge Project:**
- Git TUI inspired by gh-dash
- List PRs and issues
- View details
- Filter and search
- Real-time updates
- Open in browser

**Final Milestone**: Enterprise-grade TUI demonstrating full stack of learned skills

**Key Learning**: Building complex, API-powered TUI applications ready for production use

---

## Generation Guidelines for AI Providers

When generating specifications for remaining lessons:

### Follow the Template

Use `LESSON_TEMPLATE.md` as the structure foundation.

### Study Completed Examples

Reference these completed specifications:
- `lesson-01-hello-world.md` - Beginner fundamentals pattern
- `lesson-02-variables.md` - Core concepts with math operations
- `lesson-13-task-tracker.md` - Milestone project pattern

### Key Elements to Include

1. **Clear Learning Objectives** (5-8 specific, measurable goals)
2. **Detailed Core Concepts** (with code examples for each)
3. **Concrete Challenge Projects** (specific requirements, not vague)
4. **Comprehensive Test Requirements** (table-driven tests, edge cases)
5. **Input/Output Specifications** (concrete examples)
6. **Common Pitfalls** (4-6 with wrong/right code examples)
7. **Extension Challenges** (3-5 optional advanced features)
8. **Validation Commands** (exact commands to run)

### Maintain Consistency

- Time estimates realistic based on complexity
- Difficulty progression (Beginner → Intermediate → Advanced)
- Go idioms and best practices emphasized throughout
- Testing culture reinforced in every lesson
- Clear connections to learning plan guides

### Link to Resources

- Official Go documentation
- Go by Example
- Effective Go
- Relevant blog posts or tutorials
- Standard library examples

---

**Total Lessons**: 42
**Completed Specifications**: 3 + Template
**Remaining Specifications**: 39

**Next Steps**: AI providers can generate specifications for lessons 03-12, 14-42 following this manifest and the established patterns.
