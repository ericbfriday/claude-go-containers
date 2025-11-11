# Lesson 24: Context for Cancellation & Deadlines

**Phase**: 4 - Concurrency Fundamentals (MILESTONE)
**Estimated Time**: 4-6 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-23 (Go Fundamentals, CLI Development, Styling, Concurrency)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Understand context fundamentals** - Explain the context.Context interface and its role in managing cancellation, deadlines, and request-scoped values
2. **Create context hierarchies** - Use WithCancel, WithTimeout, WithDeadline, and WithValue to create context trees
3. **Propagate cancellation** - Design concurrent systems where cancellation signals flow through goroutine hierarchies
4. **Handle timeouts effectively** - Implement timeout patterns for HTTP requests, database queries, and external operations
5. **Apply context best practices** - Follow Go conventions for context usage (first parameter, no storage in structs)
6. **Build production patterns** - Implement graceful shutdown, request tracing, and context-aware services
7. **Debug context issues** - Identify context leaks, missing propagation, and incorrect value usage
8. **Bridge to TUI development** - Apply context patterns with Lip Gloss styling for terminal feedback (Phase 5 preparation)

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (functions, structs, interfaces, error handling)
- **Phase 2**: CLI development (Cobra, file I/O, HTTP clients)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout, theming)
- **Phase 4**: Concurrency (goroutines, channels, select, sync primitives, worker pools)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-24-context
cd ~/go-learning/lesson-24-context

# Initialize module
go mod init lesson24

# Install dependencies
go get github.com/charmbracelet/lipgloss@latest
go get golang.org/x/sync/errgroup@latest
```

### Conceptual Preparation
- Review Lesson 19 (Goroutines) - context controls goroutine lifecycles
- Review Lesson 20-21 (Channels) - context uses channels internally
- Review Lesson 23 (Worker Pools) - context enables graceful worker shutdown
- Review Lesson 14 (HTTP Clients) - context controls request timeouts

---

## Core Concepts

### 1. What is Context?

**Definition**: The `context.Context` interface provides a standardized way to carry deadlines, cancellation signals, and request-scoped values across API boundaries and between goroutines.

**The Context Interface**:
```go
type Context interface {
    // Deadline returns the time when work done on behalf of this context
    // should be canceled. Deadline returns ok==false when no deadline is set.
    Deadline() (deadline time.Time, ok bool)

    // Done returns a channel that's closed when work done on behalf of this
    // context should be canceled.
    Done() <-chan struct{}

    // Err returns nil if Done is not yet closed. If Done is closed, Err
    // returns a non-nil error explaining why.
    Err() error

    // Value returns the value associated with this context for key, or nil
    // if no value is associated with key.
    Value(key interface{}) interface{}
}
```

**Why Context Matters**:
```go
// ❌ Without context: No way to cancel operations
func fetchData(url string) ([]byte, error) {
    resp, err := http.Get(url) // Can't cancel, can't timeout
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}

// ✅ With context: Full control over lifecycle
func fetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err // Includes timeout/cancellation errors
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

**Context Design Principles**:
1. **First parameter**: Context is always the first parameter (conventionally named `ctx`)
2. **Never store in structs**: Pass explicitly through call chains
3. **Immutable**: Creating child contexts doesn't modify parent
4. **Tree structure**: Cancellation flows from parent to all descendants
5. **Safe for concurrent use**: Multiple goroutines can use the same context

### 2. Creating Contexts

**Root Contexts**:
```go
import "context"

// context.Background() - The root of all context trees
// Use as the top-level context for main, initialization, and tests
func main() {
    ctx := context.Background()
    doWork(ctx)
}

// context.TODO() - Placeholder when you're unsure which context to use
// Use during development when refactoring to add context support
func legacyFunction() {
    ctx := context.TODO() // Signals: "I need to figure this out"
    newFunction(ctx)
}
```

**WithCancel - Manual Cancellation**:
```go
func demoWithCancel() {
    // Create cancellable context
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel() // Always call cancel to release resources

    go func() {
        <-ctx.Done()
        fmt.Println("Goroutine cancelled:", ctx.Err())
    }()

    time.Sleep(100 * time.Millisecond)
    cancel() // Trigger cancellation
    time.Sleep(10 * time.Millisecond)
}

// Output:
// Goroutine cancelled: context canceled
```

**WithTimeout - Time-Based Cancellation**:
```go
func demoWithTimeout() {
    // Automatically cancels after duration
    ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
    defer cancel() // Still required for cleanup

    select {
    case <-time.After(500 * time.Millisecond):
        fmt.Println("Work completed")
    case <-ctx.Done():
        fmt.Println("Timeout:", ctx.Err())
    }
}

// Output:
// Timeout: context deadline exceeded
```

**WithDeadline - Absolute Time Cancellation**:
```go
func demoWithDeadline() {
    // Cancel at specific time
    deadline := time.Now().Add(1 * time.Second)
    ctx, cancel := context.WithDeadline(context.Background(), deadline)
    defer cancel()

    if d, ok := ctx.Deadline(); ok {
        fmt.Printf("Deadline: %v (in %v)\n", d, time.Until(d))
    }

    <-ctx.Done()
    fmt.Println("Deadline reached:", ctx.Err())
}
```

**WithValue - Request-Scoped Data**:
```go
type contextKey string

const requestIDKey contextKey = "requestID"

func demoWithValue() {
    ctx := context.WithValue(context.Background(), requestIDKey, "req-12345")

    // Retrieve value
    if reqID, ok := ctx.Value(requestIDKey).(string); ok {
        fmt.Println("Request ID:", reqID)
    }
}

// ⚠️ Warning: Use WithValue sparingly!
// Good: request IDs, auth tokens, trace IDs
// Bad: optional parameters, configuration
```

### 3. Context Propagation Patterns

**Cancellation Propagation**:
```go
func parent(ctx context.Context) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    // Launch children
    go child(ctx, 1)
    go child(ctx, 2)
    go child(ctx, 3)

    // When parent times out, all children are cancelled
    <-ctx.Done()
    fmt.Println("Parent done:", ctx.Err())
}

func child(ctx context.Context, id int) {
    <-ctx.Done()
    fmt.Printf("Child %d cancelled: %v\n", id, ctx.Err())
}

// Output:
// Child 1 cancelled: context deadline exceeded
// Child 2 cancelled: context deadline exceeded
// Child 3 cancelled: context deadline exceeded
// Parent done: context deadline exceeded
```

**Worker Pool with Context**:
```go
func workerPool(ctx context.Context, jobs <-chan int, results chan<- int) {
    for i := 0; i < 3; i++ {
        go worker(ctx, i, jobs, results)
    }
}

func worker(ctx context.Context, id int, jobs <-chan int, results chan<- int) {
    for {
        select {
        case job, ok := <-jobs:
            if !ok {
                return // Channel closed
            }
            // Simulate work with cancellation check
            select {
            case <-ctx.Done():
                fmt.Printf("Worker %d cancelled\n", id)
                return
            case <-time.After(time.Duration(job) * time.Millisecond):
                results <- job * 2
            }
        case <-ctx.Done():
            fmt.Printf("Worker %d stopped: %v\n", id, ctx.Err())
            return
        }
    }
}
```

**HTTP Server with Context**:
```go
func httpHandler(w http.ResponseWriter, r *http.Request) {
    // Each request has its own context
    ctx := r.Context()

    // Create timeout for this handler
    ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
    defer cancel()

    // Pass context to downstream functions
    result, err := fetchData(ctx, "https://api.example.com/data")
    if err != nil {
        if ctx.Err() == context.DeadlineExceeded {
            http.Error(w, "Request timeout", http.StatusGatewayTimeout)
        } else {
            http.Error(w, err.Error(), http.StatusInternalServerError)
        }
        return
    }

    w.Write(result)
}
```

### 4. Timeout Patterns

**Database Query Timeout**:
```go
func queryWithTimeout(ctx context.Context, db *sql.DB, query string) ([]Row, error) {
    // Create timeout context
    ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
    defer cancel()

    // Execute query with context
    rows, err := db.QueryContext(ctx, query)
    if err != nil {
        if ctx.Err() == context.DeadlineExceeded {
            return nil, fmt.Errorf("query timeout: %w", err)
        }
        return nil, err
    }
    defer rows.Close()

    var results []Row
    for rows.Next() {
        var r Row
        if err := rows.Scan(&r.ID, &r.Name); err != nil {
            return nil, err
        }
        results = append(results, r)
    }

    return results, rows.Err()
}
```

**HTTP Request with Timeout**:
```go
func fetchWithTimeout(ctx context.Context, url string, timeout time.Duration) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()

    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        // Check if timeout caused the error
        if ctx.Err() == context.DeadlineExceeded {
            return nil, fmt.Errorf("request timeout after %v", timeout)
        }
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

**Multi-Stage Pipeline with Timeout**:
```go
func pipeline(ctx context.Context, input <-chan int) (<-chan int, error) {
    // Stage 1: Process
    stage1 := make(chan int)
    go func() {
        defer close(stage1)
        for v := range input {
            select {
            case stage1 <- v * 2:
            case <-ctx.Done():
                return
            }
        }
    }()

    // Stage 2: Filter
    stage2 := make(chan int)
    go func() {
        defer close(stage2)
        for v := range stage1 {
            if v%4 == 0 {
                select {
                case stage2 <- v:
                case <-ctx.Done():
                    return
                }
            }
        }
    }()

    return stage2, nil
}
```

### 5. Error Handling with Context

**Checking Context Errors**:
```go
func processWithContext(ctx context.Context) error {
    // Check if context is already cancelled
    if ctx.Err() != nil {
        return ctx.Err()
    }

    // Perform work
    select {
    case <-time.After(100 * time.Millisecond):
        return nil
    case <-ctx.Done():
        return ctx.Err() // Returns context.Canceled or context.DeadlineExceeded
    }
}

func caller() {
    ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
    defer cancel()

    err := processWithContext(ctx)
    if err != nil {
        switch err {
        case context.Canceled:
            fmt.Println("Operation was cancelled")
        case context.DeadlineExceeded:
            fmt.Println("Operation timed out")
        default:
            fmt.Println("Operation failed:", err)
        }
    }
}
```

**Using errgroup for Error Propagation**:
```go
import "golang.org/x/sync/errgroup"

func parallelFetch(ctx context.Context, urls []string) ([][]byte, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([][]byte, len(urls))

    for i, url := range urls {
        i, url := i, url // Capture loop variables
        g.Go(func() error {
            data, err := fetchWithTimeout(ctx, url, 5*time.Second)
            if err != nil {
                return err // First error cancels all
            }
            results[i] = data
            return nil
        })
    }

    // Wait for all goroutines
    if err := g.Wait(); err != nil {
        return nil, err
    }

    return results, nil
}
```

### 6. Context Best Practices

**✅ DO: Pass Context as First Parameter**:
```go
// Correct
func doWork(ctx context.Context, data string) error {
    return processData(ctx, data)
}

// Wrong
func doWork(data string, ctx context.Context) error { // Bad ordering
    return nil
}
```

**✅ DO: Use defer cancel()**:
```go
func doWork(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel() // Always call to release resources

    return performWork(ctx)
}
```

**❌ DON'T: Store Context in Structs**:
```go
// Wrong
type Server struct {
    ctx context.Context // DON'T DO THIS
}

// Correct
type Server struct {
    // No context field
}

func (s *Server) HandleRequest(ctx context.Context) {
    // Pass context explicitly
}
```

**✅ DO: Accept context.Context, Not Concrete Types**:
```go
// Correct
func doWork(ctx context.Context) error {
    // Works with any context implementation
}

// Wrong
func doWork(ctx *context.cancelCtx) error { // Never use concrete types
    return nil
}
```

**❌ DON'T: Pass nil Context**:
```go
// Wrong
doWork(nil) // Will panic

// Correct
doWork(context.Background()) // Use Background if no parent context
doWork(context.TODO())       // Use TODO during refactoring
```

**✅ DO: Use WithValue Sparingly**:
```go
// Good uses:
// - Request IDs for tracing
// - Authentication tokens
// - User sessions
ctx = context.WithValue(ctx, requestIDKey, "req-12345")

// Bad uses:
// - Function parameters (use actual parameters)
// - Configuration (use dependency injection)
// - Cache (use actual cache)
```

### 7. Graceful Shutdown Pattern

**HTTP Server Graceful Shutdown**:
```go
func main() {
    server := &http.Server{Addr: ":8080"}

    // Handle shutdown signals
    stop := make(chan os.Signal, 1)
    signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

    // Run server in background
    go func() {
        if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("Server error: %v", err)
        }
    }()

    fmt.Println("Server started on :8080")

    // Wait for shutdown signal
    <-stop
    fmt.Println("\nShutting down gracefully...")

    // Create shutdown context with timeout
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    // Attempt graceful shutdown
    if err := server.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    fmt.Println("Server stopped")
}
```

**Worker Pool Graceful Shutdown**:
```go
type WorkerPool struct {
    workers int
    jobs    chan Job
}

func (wp *WorkerPool) Start(ctx context.Context) error {
    for i := 0; i < wp.workers; i++ {
        go wp.worker(ctx, i)
    }

    // Wait for context cancellation
    <-ctx.Done()
    fmt.Println("Stopping worker pool...")

    // Close job channel to signal workers
    close(wp.jobs)

    return ctx.Err()
}

func (wp *WorkerPool) worker(ctx context.Context, id int) {
    fmt.Printf("Worker %d started\n", id)
    defer fmt.Printf("Worker %d stopped\n", id)

    for {
        select {
        case job, ok := <-wp.jobs:
            if !ok {
                return // Jobs channel closed
            }
            job.Process()
        case <-ctx.Done():
            return // Context cancelled
        }
    }
}
```

### 8. Styling Context Operations (Bridging Phase 3)

**Using Lip Gloss with Context Operations**:
```go
import (
    "context"
    "fmt"
    "time"

    "github.com/charmbracelet/lipgloss"
)

var (
    runningStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("86")).
        Bold(true).
        Prefix("🔄 ")

    successStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Bold(true).
        Prefix("✓ ")

    errorStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Bold(true).
        Prefix("✗ ")

    timeoutStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("214")).
        Bold(true).
        Prefix("⏱  ")

    cancelledStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("244")).
        Bold(true).
        Prefix("⊘ ")
)

func styledOperation(ctx context.Context, name string, duration time.Duration) {
    fmt.Println(runningStyle.Render(fmt.Sprintf("%s: Starting...", name)))

    select {
    case <-time.After(duration):
        fmt.Println(successStyle.Render(fmt.Sprintf("%s: Completed in %v", name, duration)))
    case <-ctx.Done():
        switch ctx.Err() {
        case context.Canceled:
            fmt.Println(cancelledStyle.Render(fmt.Sprintf("%s: Cancelled", name)))
        case context.DeadlineExceeded:
            fmt.Println(timeoutStyle.Render(fmt.Sprintf("%s: Timeout", name)))
        default:
            fmt.Println(errorStyle.Render(fmt.Sprintf("%s: Error: %v", name, ctx.Err())))
        }
    }
}
```

**Context Dashboard with Styling**:
```go
func renderContextStatus(ctx context.Context, operation string) {
    status := "Active"
    color := lipgloss.Color("42")

    if ctx.Err() != nil {
        status = ctx.Err().Error()
        color = lipgloss.Color("196")
    }

    if deadline, ok := ctx.Deadline(); ok {
        remaining := time.Until(deadline)
        if remaining > 0 {
            status = fmt.Sprintf("Active (%v remaining)", remaining.Round(time.Millisecond))
        }
    }

    statusStyle := lipgloss.NewStyle().
        Foreground(color).
        Bold(true).
        Border(lipgloss.RoundedBorder()).
        Padding(1, 2)

    fmt.Println(statusStyle.Render(fmt.Sprintf("%s\nStatus: %s", operation, status)))
}
```

### 9. Performance Considerations

**Context Overhead**:
```go
func benchmarkContextOverhead() {
    // Without context
    start := time.Now()
    for i := 0; i < 1000000; i++ {
        doWorkWithoutContext()
    }
    withoutContext := time.Since(start)

    // With context (but not using it)
    ctx := context.Background()
    start = time.Now()
    for i := 0; i < 1000000; i++ {
        doWorkWithContext(ctx)
    }
    withContext := time.Since(start)

    fmt.Printf("Without context: %v\n", withoutContext)
    fmt.Printf("With context: %v\n", withContext)
    fmt.Printf("Overhead: %.2f%%\n",
        (float64(withContext-withoutContext)/float64(withoutContext))*100)
}

// Output (typical):
// Without context: 15ms
// With context: 17ms
// Overhead: 13.33%
```

**When to Check ctx.Done()**:
```go
// ❌ Too frequent (performance impact)
func processItems(ctx context.Context, items []int) {
    for _, item := range items {
        if ctx.Err() != nil { // Checking every iteration
            return
        }
        process(item) // Fast operation
    }
}

// ✅ Appropriate frequency
func processItems(ctx context.Context, items []int) {
    for i, item := range items {
        if i%100 == 0 { // Check every 100 iterations
            if ctx.Err() != nil {
                return
            }
        }
        process(item)
    }
}

// ✅ Use select for blocking operations
func processItems(ctx context.Context, items <-chan int) {
    for {
        select {
        case item, ok := <-items:
            if !ok {
                return
            }
            process(item)
        case <-ctx.Done():
            return
        }
    }
}
```

---

## Challenge Description

Build a **Concurrent Web Crawler** that demonstrates context mastery with cancellation, timeouts, and styled terminal output.

### Project Overview

Create a CLI application that:
1. Crawls multiple URLs concurrently with configurable workers
2. Implements context-based cancellation and timeout
3. Respects rate limiting and politeness delays
4. Provides styled real-time progress updates
5. Handles errors gracefully with context awareness
6. Supports graceful shutdown on interrupt signals
7. Tracks statistics (pages crawled, errors, timeouts)

### Functional Requirements

**Core Features**:
```bash
# Crawl with default settings (5 workers, 30s timeout)
go run main.go crawl https://example.com

# Configure workers and timeout
go run main.go crawl https://example.com --workers 10 --timeout 60s

# Set max depth and rate limit
go run main.go crawl https://example.com --depth 3 --rate-limit 100ms

# Graceful shutdown on Ctrl+C
go run main.go crawl https://example.com
# Press Ctrl+C to trigger graceful shutdown

# Verbose mode with detailed output
go run main.go crawl https://example.com --verbose
```

**Expected Output**:
```
╔══════════════════════════════════════════════════════╗
║          Concurrent Web Crawler v1.0                 ║
╚══════════════════════════════════════════════════════╝

Configuration:
  Starting URL:  https://example.com
  Workers:       5
  Timeout:       30s
  Max Depth:     2
  Rate Limit:    100ms

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Crawling Progress:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 Crawling: https://example.com (depth: 0)
✓ Success:   https://example.com (150ms, 1.2KB, 3 links)
🔄 Crawling: https://example.com/about (depth: 1)
✓ Success:   https://example.com/about (220ms, 2.5KB, 5 links)
⏱  Timeout:   https://slow-site.com/page (30s)
🔄 Crawling: https://example.com/contact (depth: 1)
✗ Error:     https://example.com/404 (404 Not Found)
⊘ Cancelled: https://example.com/pending (user interrupt)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Final Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total URLs:        25
Successful:        20 (80.0%)
Timeouts:          2 (8.0%)
Errors:            2 (8.0%)
Cancelled:         1 (4.0%)
Total Time:        12.5s
Avg Response:      215ms
Data Downloaded:   45.3KB

Pages by Depth:
  Depth 0:  1 page
  Depth 1:  8 pages
  Depth 2:  16 pages

Press Ctrl+C to stop crawler...
```

### Implementation Requirements

**Project Structure**:
```
lesson-24-context/
├── main.go                 # CLI entry point with Cobra
├── crawler/
│   ├── crawler.go          # Core crawler with context
│   ├── worker.go           # Worker pool implementation
│   ├── url_queue.go        # Thread-safe URL queue
│   └── stats.go            # Statistics tracking
├── fetcher/
│   ├── http.go             # HTTP client with timeout
│   └── parser.go           # HTML link extraction
├── display/
│   ├── styles.go           # Lip Gloss styles
│   ├── progress.go         # Real-time progress display
│   └── summary.go          # Final statistics rendering
├── config/
│   └── config.go           # Crawler configuration
└── main_test.go
```

**Crawler Requirements**:
1. **Context Hierarchy**: Root context → crawler context → worker contexts → request contexts
2. **Worker Pool**: Fixed number of workers processing URL queue
3. **Rate Limiting**: Politeness delay between requests to same domain
4. **Timeout Handling**: Per-request timeout with fallback
5. **Cancellation**: Graceful shutdown on SIGINT/SIGTERM
6. **Error Recovery**: Continue crawling despite individual failures
7. **Deduplication**: Track visited URLs to avoid cycles

**Context Usage Patterns**:
```go
// 1. Root context with cancellation
ctx, cancel := context.WithCancel(context.Background())
defer cancel()

// 2. Signal handler for graceful shutdown
go func() {
    <-sigChan
    cancel() // Propagates to all workers
}()

// 3. Worker with context
func worker(ctx context.Context, jobs <-chan URL) {
    for {
        select {
        case url := <-jobs:
            fetchURL(ctx, url)
        case <-ctx.Done():
            return // Shutdown
        }
    }
}

// 4. HTTP request with timeout
func fetchURL(ctx context.Context, url string) {
    ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
    defer cancel()

    req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
    resp, err := http.DefaultClient.Do(req)
    // Handle timeout/cancellation errors
}
```

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestContextCancellation(t *testing.T) {
    tests := []struct {
        name           string
        timeout        time.Duration
        workDuration   time.Duration
        wantErr        error
        wantCompleted  bool
    }{
        {
            name:          "Work completes before timeout",
            timeout:       200 * time.Millisecond,
            workDuration:  100 * time.Millisecond,
            wantErr:       nil,
            wantCompleted: true,
        },
        {
            name:          "Timeout before work completes",
            timeout:       100 * time.Millisecond,
            workDuration:  200 * time.Millisecond,
            wantErr:       context.DeadlineExceeded,
            wantCompleted: false,
        },
        {
            name:          "Manual cancellation",
            timeout:       500 * time.Millisecond,
            workDuration:  200 * time.Millisecond,
            wantErr:       context.Canceled,
            wantCompleted: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            ctx, cancel := context.WithTimeout(context.Background(), tt.timeout)
            defer cancel()

            if tt.wantErr == context.Canceled {
                go func() {
                    time.Sleep(50 * time.Millisecond)
                    cancel()
                }()
            }

            completed := doWork(ctx, tt.workDuration)

            if completed != tt.wantCompleted {
                t.Errorf("completed = %v, want %v", completed, tt.wantCompleted)
            }

            if ctx.Err() != tt.wantErr {
                t.Errorf("ctx.Err() = %v, want %v", ctx.Err(), tt.wantErr)
            }
        })
    }
}
```

### Required Test Coverage

| Test Category | Test Cases | Purpose |
|---------------|------------|---------|
| **Context Creation** | 5+ | Verify WithCancel, WithTimeout, WithDeadline, WithValue |
| **Cancellation Propagation** | 6+ | Test parent→child cancellation flow |
| **Timeout Behavior** | 5+ | Validate deadline enforcement |
| **Error Handling** | 4+ | Test error detection and recovery |
| **HTTP Integration** | 5+ | Test request cancellation |
| **Worker Pool** | 6+ | Test graceful worker shutdown |
| **Value Propagation** | 3+ | Test WithValue retrieval |

### Specific Test Scenarios

**Context Propagation Test**:
```go
func TestContextPropagation(t *testing.T) {
    parent, cancel := context.WithCancel(context.Background())
    child := context.WithValue(parent, "key", "value")

    // Cancel parent
    cancel()

    // Child should be cancelled too
    select {
    case <-child.Done():
        if child.Err() != context.Canceled {
            t.Errorf("Expected Canceled, got %v", child.Err())
        }
    case <-time.After(100 * time.Millisecond):
        t.Error("Child context not cancelled")
    }
}
```

**HTTP Timeout Test**:
```go
func TestHTTPTimeout(t *testing.T) {
    // Create slow server
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        time.Sleep(500 * time.Millisecond)
        w.Write([]byte("OK"))
    }))
    defer server.Close()

    // Request with short timeout
    ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
    defer cancel()

    _, err := fetchWithContext(ctx, server.URL)

    if !errors.Is(err, context.DeadlineExceeded) {
        t.Errorf("Expected DeadlineExceeded, got %v", err)
    }
}
```

**Graceful Shutdown Test**:
```go
func TestGracefulShutdown(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    pool := NewWorkerPool(3)

    // Start workers
    go pool.Start(ctx)

    // Submit jobs
    for i := 0; i < 10; i++ {
        pool.Submit(Job{ID: i})
    }

    time.Sleep(100 * time.Millisecond)

    // Trigger shutdown
    cancel()

    // Wait for completion
    time.Sleep(200 * time.Millisecond)

    // Verify workers stopped
    if pool.ActiveWorkers() != 0 {
        t.Errorf("Expected 0 active workers, got %d", pool.ActiveWorkers())
    }
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Cobra Commands**:
```go
var (
    workers    int
    timeout    time.Duration
    maxDepth   int
    rateLimit  time.Duration
    verbose    bool
)

var crawlCmd = &cobra.Command{
    Use:   "crawl [url]",
    Short: "Crawl a website with concurrent workers",
    Args:  cobra.ExactArgs(1),
    RunE: func(cmd *cobra.Command, args []string) error {
        return runCrawler(cmd.Context(), args[0])
    },
}

func init() {
    crawlCmd.Flags().IntVarP(&workers, "workers", "w", 5, "Number of concurrent workers")
    crawlCmd.Flags().DurationVarP(&timeout, "timeout", "t", 30*time.Second, "Timeout per request")
    crawlCmd.Flags().IntVarP(&maxDepth, "depth", "d", 2, "Maximum crawl depth")
    crawlCmd.Flags().DurationVarP(&rateLimit, "rate-limit", "r", 100*time.Millisecond, "Delay between requests")
    crawlCmd.Flags().BoolVarP(&verbose, "verbose", "v", false, "Verbose output")
}
```

### Expected Output Formats

**Progress Output (Verbose Mode)**:
```
Context Status:
┌─────────────────────────────────────────┐
│ Operation: Crawler                      │
│ Status: Active (28.5s remaining)        │
│ Workers: 5/5 active                     │
│ Queue: 12 pending                       │
└─────────────────────────────────────────┘

Worker Details:
  Worker 1: 🔄 Fetching https://example.com/page1
  Worker 2: ✓ Completed https://example.com/page2 (180ms)
  Worker 3: 🔄 Fetching https://example.com/page3
  Worker 4: ⏱  Waiting (rate limit)
  Worker 5: 🔄 Fetching https://example.com/page4
```

**Cancellation Output**:
```
^C
⚠️  Interrupt signal received

Initiating graceful shutdown...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Shutdown Progress:
  ⊘ Cancelling all workers...
  ⊘ Worker 1 stopped
  ⊘ Worker 2 stopped
  ⊘ Worker 3 stopped
  ⊘ Worker 4 stopped
  ⊘ Worker 5 stopped
  ✓ All workers stopped

Partial Results:
  URLs Crawled:  15/25 (60%)
  Time Elapsed:  8.2s
  Data:          23.5KB

Shutdown complete.
```

**Error Handling Output**:
```go
// Timeout error
⏱  Timeout: https://slow-site.com/page
   Duration: 30.0s (exceeded timeout)
   Error: context deadline exceeded

// Cancellation error
⊘ Cancelled: https://example.com/pending
   Reason: Graceful shutdown initiated
   Error: context canceled

// HTTP error
✗ Error: https://example.com/404
   Status: 404 Not Found
   Error: HTTP 404
```

### Context Statistics Dashboard

```go
func renderContextStats(stats *CrawlerStats) string {
    summary := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        Padding(1, 2).
        Render(fmt.Sprintf(
            "Total: %d | Success: %d | Timeout: %d | Cancelled: %d",
            stats.Total, stats.Success, stats.Timeout, stats.Cancelled,
        ))

    timing := lipgloss.NewStyle().
        Foreground(lipgloss.Color("86")).
        Render(fmt.Sprintf(
            "Avg Response: %v | Total Time: %v",
            stats.AvgDuration, stats.TotalTime,
        ))

    return lipgloss.JoinVertical(lipgloss.Left, summary, timing)
}
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] Crawler processes multiple URLs concurrently
- [ ] Context timeout enforced per request
- [ ] Graceful shutdown on SIGINT/SIGTERM
- [ ] Parent cancellation propagates to all workers
- [ ] Rate limiting respects politeness delays
- [ ] Statistics tracked accurately
- [ ] Duplicate URLs avoided
- [ ] Styled output using Lip Gloss

### Code Quality ✅

- [ ] All code passes `go fmt`
- [ ] All code passes `go vet`
- [ ] All code passes `staticcheck`
- [ ] Context passed as first parameter (never in structs)
- [ ] `defer cancel()` called for all created contexts
- [ ] No context leaks (verified with tests)
- [ ] Error handling distinguishes timeout vs cancellation

### Testing ✅

- [ ] Table-driven tests for context operations
- [ ] Test coverage >80%
- [ ] Context propagation tested
- [ ] Timeout behavior validated
- [ ] Graceful shutdown tested
- [ ] HTTP integration tested (with httptest)
- [ ] Worker pool shutdown verified

### Documentation ✅

- [ ] README explains context usage patterns
- [ ] Function comments describe context behavior
- [ ] Examples demonstrate cancellation and timeout
- [ ] Architecture diagram shows context hierarchy
- [ ] Performance characteristics documented

### Performance ✅

- [ ] No context leaks (resource cleanup verified)
- [ ] Graceful shutdown completes within timeout
- [ ] Rate limiting enforced accurately
- [ ] Worker pool scales efficiently
- [ ] Memory usage stable during long crawls

---

## Common Pitfalls

### ❌ Pitfall 1: Not Calling defer cancel()

**Wrong**:
```go
func fetchData() error {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    // Missing defer cancel() - resource leak!

    return doWork(ctx)
}
```

**Right**:
```go
func fetchData() error {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel() // Always call cancel to release resources

    return doWork(ctx)
}
```

**Why**: Even if timeout expires, `cancel()` must be called to release goroutine resources. Missing `defer cancel()` causes goroutine leaks.

---

### ❌ Pitfall 2: Storing Context in Struct

**Wrong**:
```go
type Server struct {
    ctx context.Context // DON'T STORE CONTEXT
}

func (s *Server) HandleRequest() {
    // Using stored context across requests - WRONG
    data := s.fetchData(s.ctx)
}
```

**Right**:
```go
type Server struct {
    // No context field
}

func (s *Server) HandleRequest(ctx context.Context) {
    // Pass context explicitly
    data := s.fetchData(ctx)
}

func (s *Server) fetchData(ctx context.Context) []byte {
    // Use passed context
    return fetch(ctx)
}
```

**Why**: Context is request-scoped. Storing in structs violates lifetime semantics and prevents proper cancellation.

---

### ❌ Pitfall 3: Ignoring Context Errors

**Wrong**:
```go
func fetchData(ctx context.Context) error {
    select {
    case <-time.After(5 * time.Second):
        return nil
    case <-ctx.Done():
        return nil // Ignoring why context was cancelled!
    }
}
```

**Right**:
```go
func fetchData(ctx context.Context) error {
    select {
    case <-time.After(5 * time.Second):
        return nil
    case <-ctx.Done():
        return ctx.Err() // Return context.Canceled or context.DeadlineExceeded
    }
}

// Caller can distinguish errors:
func caller() {
    err := fetchData(ctx)
    if err == context.DeadlineExceeded {
        log.Println("Operation timed out")
    } else if err == context.Canceled {
        log.Println("Operation was cancelled")
    }
}
```

**Why**: Callers need to know WHY the context was cancelled (timeout vs manual cancellation) for proper error handling.

---

### ❌ Pitfall 4: Creating Context Without Parent

**Wrong**:
```go
func worker() {
    // Creating orphan context - won't respect parent cancellation
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    doWork(ctx)
}

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    go worker() // Worker ignores main's timeout!
}
```

**Right**:
```go
func worker(ctx context.Context) {
    // Create child context from parent
    ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
    defer cancel()

    doWork(ctx)
}

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    go worker(ctx) // Worker respects main's timeout
}
```

**Why**: Child contexts inherit parent cancellation. Using `context.Background()` in worker breaks cancellation chain.

---

### ❌ Pitfall 5: Misusing WithValue

**Wrong**:
```go
// Using WithValue for function parameters
func processUser(ctx context.Context) {
    ctx = context.WithValue(ctx, "email", "user@example.com")
    ctx = context.WithValue(ctx, "age", 30)
    ctx = context.WithValue(ctx, "admin", true)

    sendEmail(ctx) // Using context as parameter bag - WRONG
}

func sendEmail(ctx context.Context) {
    email := ctx.Value("email").(string) // Type assertion required, not type-safe
    // ...
}
```

**Right**:
```go
// Use actual function parameters
func processUser(ctx context.Context, email string, age int, admin bool) {
    sendEmail(ctx, email)
}

func sendEmail(ctx context.Context, email string) {
    // Type-safe, clear signature
}

// WithValue for cross-cutting concerns ONLY
func middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Good: Request ID for tracing across call stack
        requestID := generateID()
        ctx := context.WithValue(r.Context(), requestIDKey, requestID)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

**Why**: `WithValue` is for request-scoped metadata (trace IDs, auth tokens), NOT for passing function arguments. Use it sparingly.

---

### ❌ Pitfall 6: Not Checking Context Before Expensive Operations

**Wrong**:
```go
func processItems(ctx context.Context, items []Item) {
    for _, item := range items {
        // Expensive operation without cancellation check
        result := expensiveComputation(item) // Could take minutes
        save(result)
    }
}
```

**Right**:
```go
func processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        // Check context before expensive operation
        if ctx.Err() != nil {
            return ctx.Err()
        }

        result := expensiveComputation(item)

        if ctx.Err() != nil {
            return ctx.Err() // Check again after operation
        }

        save(result)
    }
    return nil
}

// Even better: Use select for interruptible operations
func processItems(ctx context.Context, items <-chan Item) error {
    for {
        select {
        case item, ok := <-items:
            if !ok {
                return nil
            }
            result := expensiveComputation(item)
            save(result)
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

**Why**: Long-running operations should check `ctx.Done()` periodically to enable timely cancellation.

---

## Extension Challenges

### Extension 1: Context-Aware Cache ⭐⭐

Implement a cache that respects context cancellation:

```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]*CacheItem
}

type CacheItem struct {
    Value      interface{}
    Expiration time.Time
}

func (c *Cache) Get(ctx context.Context, key string) (interface{}, error) {
    // Check if context is already cancelled
    if ctx.Err() != nil {
        return nil, ctx.Err()
    }

    c.mu.RLock()
    defer c.mu.RUnlock()

    item, exists := c.items[key]
    if !exists {
        return nil, ErrNotFound
    }

    if time.Now().After(item.Expiration) {
        return nil, ErrExpired
    }

    return item.Value, nil
}

func (c *Cache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    if ctx.Err() != nil {
        return ctx.Err()
    }

    c.mu.Lock()
    defer c.mu.Unlock()

    c.items[key] = &CacheItem{
        Value:      value,
        Expiration: time.Now().Add(ttl),
    }

    return nil
}

// Background cleanup respects context
func (c *Cache) StartCleanup(ctx context.Context, interval time.Duration) {
    ticker := time.NewTicker(interval)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            c.cleanup()
        case <-ctx.Done():
            return
        }
    }
}

func (c *Cache) cleanup() {
    c.mu.Lock()
    defer c.mu.Unlock()

    now := time.Now()
    for key, item := range c.items {
        if now.After(item.Expiration) {
            delete(c.items, key)
        }
    }
}

// Usage
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    cache := &Cache{items: make(map[string]*CacheItem)}
    go cache.StartCleanup(ctx, 1*time.Minute)

    // Cache operations respect context
    cache.Set(ctx, "key", "value", 5*time.Minute)
    value, err := cache.Get(ctx, "key")

    // Shutdown stops cleanup
    cancel()
}
```

**Learning Goal**: Build context-aware data structures with lifecycle management.

---

### Extension 2: Request Tracing with Context ⭐⭐⭐

Implement distributed tracing using context values:

```go
type TraceID string

const traceKey = "trace-id"

func NewTraceContext(parent context.Context) context.Context {
    traceID := generateTraceID()
    return context.WithValue(parent, traceKey, traceID)
}

func GetTraceID(ctx context.Context) TraceID {
    if id, ok := ctx.Value(traceKey).(TraceID); ok {
        return id
    }
    return ""
}

// Logging with trace context
func logWithTrace(ctx context.Context, message string) {
    traceID := GetTraceID(ctx)
    log.Printf("[%s] %s", traceID, message)
}

// HTTP middleware for tracing
func TracingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Extract or create trace ID
        traceID := r.Header.Get("X-Trace-ID")
        if traceID == "" {
            traceID = string(generateTraceID())
        }

        // Add to context
        ctx := context.WithValue(r.Context(), traceKey, TraceID(traceID))

        // Add to response headers
        w.Header().Set("X-Trace-ID", traceID)

        logWithTrace(ctx, "Request started")
        next.ServeHTTP(w, r.WithContext(ctx))
        logWithTrace(ctx, "Request completed")
    })
}

// Service that propagates trace
func fetchUserData(ctx context.Context, userID string) (*User, error) {
    logWithTrace(ctx, fmt.Sprintf("Fetching user %s", userID))

    // Create HTTP request with trace context
    req, err := http.NewRequestWithContext(ctx, "GET", "/api/users/"+userID, nil)
    if err != nil {
        return nil, err
    }

    // Propagate trace ID in headers
    if traceID := GetTraceID(ctx); traceID != "" {
        req.Header.Set("X-Trace-ID", string(traceID))
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        logWithTrace(ctx, "User fetch failed")
        return nil, err
    }
    defer resp.Body.Close()

    logWithTrace(ctx, "User fetch succeeded")
    var user User
    json.NewDecoder(resp.Body).Decode(&user)
    return &user, nil
}
```

**Learning Goal**: Implement observability patterns with context propagation.

---

### Extension 3: Circuit Breaker with Context ⭐⭐⭐

Build a circuit breaker that respects context cancellation:

```go
type CircuitBreaker struct {
    maxFailures int
    resetTime   time.Duration

    mu        sync.Mutex
    failures  int
    lastFail  time.Time
    state     State
}

type State int

const (
    StateClosed State = iota
    StateOpen
    StateHalfOpen
)

func (cb *CircuitBreaker) Execute(ctx context.Context, fn func(context.Context) error) error {
    // Check context before attempting
    if ctx.Err() != nil {
        return ctx.Err()
    }

    if err := cb.beforeRequest(); err != nil {
        return err
    }

    // Execute with timeout derived from context
    errChan := make(chan error, 1)
    go func() {
        errChan <- fn(ctx)
    }()

    select {
    case err := <-errChan:
        cb.afterRequest(err)
        return err
    case <-ctx.Done():
        cb.afterRequest(ctx.Err())
        return ctx.Err()
    }
}

func (cb *CircuitBreaker) beforeRequest() error {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    switch cb.state {
    case StateOpen:
        if time.Since(cb.lastFail) > cb.resetTime {
            cb.state = StateHalfOpen
            return nil
        }
        return ErrCircuitOpen
    default:
        return nil
    }
}

func (cb *CircuitBreaker) afterRequest(err error) {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    if err != nil {
        cb.failures++
        cb.lastFail = time.Now()

        if cb.failures >= cb.maxFailures {
            cb.state = StateOpen
        }
    } else {
        cb.failures = 0
        cb.state = StateClosed
    }
}

// Usage
func main() {
    cb := &CircuitBreaker{
        maxFailures: 3,
        resetTime:   30 * time.Second,
    }

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    err := cb.Execute(ctx, func(ctx context.Context) error {
        return externalAPICall(ctx)
    })

    if err == ErrCircuitOpen {
        log.Println("Circuit breaker is open")
    }
}
```

**Learning Goal**: Build resilience patterns with context integration.

---

### Extension 4: Context-Aware Rate Limiter ⭐⭐⭐⭐

Implement token bucket rate limiter with context support:

```go
type RateLimiter struct {
    rate     int
    capacity int
    tokens   int
    mu       sync.Mutex
    lastRefill time.Time
}

func NewRateLimiter(rate, capacity int) *RateLimiter {
    return &RateLimiter{
        rate:       rate,
        capacity:   capacity,
        tokens:     capacity,
        lastRefill: time.Now(),
    }
}

func (rl *RateLimiter) Wait(ctx context.Context) error {
    for {
        if ctx.Err() != nil {
            return ctx.Err()
        }

        if rl.tryAcquire() {
            return nil
        }

        // Calculate wait time
        waitDuration := rl.calculateWaitTime()

        // Wait with context awareness
        select {
        case <-time.After(waitDuration):
            // Continue to next iteration
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}

func (rl *RateLimiter) tryAcquire() bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    rl.refill()

    if rl.tokens > 0 {
        rl.tokens--
        return true
    }

    return false
}

func (rl *RateLimiter) refill() {
    now := time.Now()
    elapsed := now.Sub(rl.lastRefill)

    tokensToAdd := int(elapsed.Seconds() * float64(rl.rate))
    if tokensToAdd > 0 {
        rl.tokens = min(rl.tokens+tokensToAdd, rl.capacity)
        rl.lastRefill = now
    }
}

func (rl *RateLimiter) calculateWaitTime() time.Duration {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    if rl.tokens > 0 {
        return 0
    }

    return time.Second / time.Duration(rl.rate)
}

// Usage in crawler
func (c *Crawler) fetchWithRateLimit(ctx context.Context, url string) error {
    // Wait for rate limiter
    if err := c.rateLimiter.Wait(ctx); err != nil {
        return err // Context cancelled during wait
    }

    // Proceed with fetch
    return c.fetch(ctx, url)
}
```

**Learning Goal**: Build advanced concurrency primitives with context awareness.

---

### Extension 5: Context Propagation Visualization ⭐⭐⭐⭐

Create a visual debugger for context hierarchies:

```go
type ContextTracer struct {
    mu     sync.Mutex
    tree   map[context.Context]*ContextNode
    root   *ContextNode
}

type ContextNode struct {
    ID       int
    Type     string // "Background", "Cancel", "Timeout", "Deadline"
    Parent   *ContextNode
    Children []*ContextNode
    Created  time.Time
    Cancelled time.Time
    Deadline time.Time
}

func NewContextTracer() *ContextTracer {
    return &ContextTracer{
        tree: make(map[context.Context]*ContextNode),
    }
}

func (t *ContextTracer) Track(ctx context.Context, typ string) context.Context {
    t.mu.Lock()
    defer t.mu.Unlock()

    node := &ContextNode{
        ID:      len(t.tree),
        Type:    typ,
        Created: time.Now(),
    }

    // Find parent
    if parent, ok := t.tree[ctx]; ok {
        node.Parent = parent
        parent.Children = append(parent.Children, node)
    } else {
        t.root = node
    }

    t.tree[ctx] = node

    // Track deadline
    if deadline, ok := ctx.Deadline(); ok {
        node.Deadline = deadline
    }

    return ctx
}

func (t *ContextTracer) Visualize() string {
    t.mu.Lock()
    defer t.mu.Unlock()

    var builder strings.Builder
    t.visualizeNode(&builder, t.root, "", true)
    return builder.String()
}

func (t *ContextTracer) visualizeNode(builder *strings.Builder, node *ContextNode, prefix string, isLast bool) {
    if node == nil {
        return
    }

    // Draw branch
    if node.Parent != nil {
        if isLast {
            builder.WriteString(prefix + "└── ")
        } else {
            builder.WriteString(prefix + "├── ")
        }
    }

    // Draw node
    status := "active"
    if !node.Cancelled.IsZero() {
        status = "cancelled"
    } else if !node.Deadline.IsZero() && time.Now().After(node.Deadline) {
        status = "deadline exceeded"
    }

    builder.WriteString(fmt.Sprintf("[%d] %s (%s)\n", node.ID, node.Type, status))

    // Draw children
    for i, child := range node.Children {
        newPrefix := prefix
        if node.Parent != nil {
            if isLast {
                newPrefix += "    "
            } else {
                newPrefix += "│   "
            }
        }
        t.visualizeNode(builder, child, newPrefix, i == len(node.Children)-1)
    }
}

// Usage
func main() {
    tracer := NewContextTracer()

    ctx := tracer.Track(context.Background(), "Background")
    ctx1, cancel1 := context.WithCancel(ctx)
    ctx1 = tracer.Track(ctx1, "Cancel")

    ctx2, cancel2 := context.WithTimeout(ctx1, 5*time.Second)
    ctx2 = tracer.Track(ctx2, "Timeout")

    ctx3, cancel3 := context.WithTimeout(ctx1, 10*time.Second)
    ctx3 = tracer.Track(ctx3, "Timeout")

    time.Sleep(1 * time.Second)
    cancel2()

    fmt.Println(tracer.Visualize())

    cancel1()
    cancel3()
}

// Output:
// [0] Background (active)
// └── [1] Cancel (active)
//     ├── [2] Timeout (cancelled)
//     └── [3] Timeout (active)
```

**Learning Goal**: Deep understanding of context lifecycle and propagation mechanisms.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear context hierarchy (root → crawler → workers → requests)
- Proper error handling for timeout vs cancellation
- Graceful shutdown pattern with signal handling
- Resource cleanup with `defer cancel()`

**Context Patterns**:
- Always pass context as first parameter
- Never store context in structs
- Check `ctx.Err()` after blocking operations
- Use `select` for cancellable waits
- Distinguish `context.Canceled` vs `context.DeadlineExceeded`

**Testing Approach**:
- Table-driven tests for timeout scenarios
- Mock HTTP servers with `httptest`
- Test cancellation propagation
- Verify no goroutine leaks after shutdown
- Test graceful vs forced shutdown

**Documentation**:
- Explain context lifecycle and hierarchy
- Document timeout values and reasoning
- Clarify cancellation semantics
- Provide examples of proper context usage

### Code Quality Standards

```bash
# All implementations must pass:
go fmt ./...
go vet ./...
staticcheck ./...
go test ./...
go test -race ./...
go test -cover ./... # Target >80%
```

### Common Implementation Approaches

**Approach 1: errgroup for Error Propagation**:
```go
import "golang.org/x/sync/errgroup"

func crawl(ctx context.Context, urls []string) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, url := range urls {
        url := url
        g.Go(func() error {
            return fetchURL(ctx, url)
        })
    }

    return g.Wait() // Returns first error, cancels all
}
```

**Approach 2: Worker Pool with Context**:
```go
func workerPool(ctx context.Context, jobs <-chan Job) {
    var wg sync.WaitGroup

    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            worker(ctx, jobs)
        }()
    }

    wg.Wait()
}

func worker(ctx context.Context, jobs <-chan Job) {
    for {
        select {
        case job, ok := <-jobs:
            if !ok {
                return
            }
            processJob(ctx, job)
        case <-ctx.Done():
            return
        }
    }
}
```

Both approaches are valid; errgroup is more idiomatic for parallel operations, worker pools for controlled concurrency.

### Performance Expectations

- Context overhead <5% in typical use cases
- Graceful shutdown completes within 10 seconds
- No goroutine leaks (verified with `runtime.NumGoroutine()`)
- Rate limiting accurate within 10ms
- Timeout precision within 50ms

---

## Learning Resources

### Official Go Documentation
- [Go Blog: Context](https://go.dev/blog/context)
- [Go Blog: Pipelines and Cancellation](https://go.dev/blog/pipelines)
- [Package context](https://pkg.go.dev/context)
- [Go Wiki: Timeouts](https://github.com/golang/go/wiki/Timeouts)

### Articles and Tutorials
- [Understanding Context](https://www.digitalocean.com/community/tutorials/how-to-use-contexts-in-go)
- [Context Best Practices](https://go.dev/blog/context-and-structs)
- [Cancellation, Context, and Propagation](https://rakyll.org/leakingctx/)

### Books
- *The Go Programming Language* (Chapter 8: Goroutines and Channels - Context section)
- *Concurrency in Go* by Katherine Cox-Buday (Chapter 4: Cancellation)
- *Learning Go* by Jon Bodner (Chapter 12: The Context)

### Video Resources
- [GopherCon 2019: Sam Whittington - Understanding Allocations: the Stack and the Heap](https://www.youtube.com/watch?v=ZMZpH4yT7M0)
- [Just for Func: Context Propagation](https://www.youtube.com/watch?v=LSzR0VEraWw)

### Related Libraries
- [golang.org/x/sync/errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup)
- [github.com/charmbracelet/lipgloss](https://github.com/charmbracelet/lipgloss)

---

## Validation Commands

### Run All Validations

```bash
# Format check
go fmt ./...

# Lint check
go vet ./...
staticcheck ./...

# Test execution
go test -v ./...

# Race condition detection
go test -race ./...

# Coverage report
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run crawler
go run main.go crawl https://example.com

# Test graceful shutdown (press Ctrl+C)
go run main.go crawl https://example.com

# Test timeout
go run main.go crawl https://httpbin.org/delay/10 --timeout 5s

# Test with multiple workers
go run main.go crawl https://example.com --workers 10 --verbose

# Performance profiling
go test -bench=. -benchmem ./...
go test -cpuprofile=cpu.prof -memprofile=mem.prof
go tool pprof cpu.prof
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestContextCancellation
=== RUN   TestContextCancellation/Work_completes_before_timeout
=== RUN   TestContextCancellation/Timeout_before_work_completes
=== RUN   TestContextCancellation/Manual_cancellation
--- PASS: TestContextCancellation (0.65s)
    --- PASS: TestContextCancellation/Work_completes_before_timeout (0.11s)
    --- PASS: TestContextCancellation/Timeout_before_work_completes (0.11s)
    --- PASS: TestContextCancellation/Manual_cancellation (0.21s)
=== RUN   TestContextPropagation
--- PASS: TestContextPropagation (0.05s)
=== RUN   TestHTTPTimeout
--- PASS: TestHTTPTimeout (0.15s)
=== RUN   TestGracefulShutdown
--- PASS: TestGracefulShutdown (0.35s)
=== RUN   TestWorkerPool
--- PASS: TestWorkerPool (0.25s)
PASS
coverage: 87.5% of statements
ok      lesson24    1.456s
```

### Goroutine Leak Detection

```bash
$ go test -v -run TestNoGoroutineLeaks
=== RUN   TestNoGoroutineLeaks
    goroutines before: 4
    goroutines after: 4
--- PASS: TestNoGoroutineLeaks (0.25s)
PASS
```

---

**Previous Lesson**: [Lesson 23: Worker Pools & Pipeline Patterns](lesson-23-worker-patterns.md) (Phase 4)
**Next Lesson**: Lesson 25: Bubble Tea Fundamentals - Model-Update-View (Phase 5)
**Phase 4 Complete**: This milestone marks completion of Concurrency Fundamentals

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
- [Phase 5 Preview](../README.md#phase-5-bubble-tea-architecture-weeks-8-9)
