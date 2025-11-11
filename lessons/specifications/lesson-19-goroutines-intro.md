# Lesson 19: Introduction to Goroutines

**Phase**: 4 - Concurrency Fundamentals
**Estimated Time**: 2-3 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-18 (Go Fundamentals, CLI Development, Styling with Lip Gloss)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Understand concurrency fundamentals** - Differentiate between concurrency and parallelism, understand when and why to use goroutines
2. **Create and launch goroutines** - Use the `go` keyword to execute functions concurrently
3. **Analyze goroutine behavior** - Understand goroutine scheduling, lifecycle, and the Go runtime's role
4. **Compare execution models** - Measure and analyze performance differences between sequential and concurrent execution
5. **Apply goroutine patterns** - Implement basic concurrent patterns like parallel computation and concurrent timers
6. **Debug concurrent programs** - Use runtime tools to inspect goroutine state and identify common pitfalls
7. **Write safe concurrent code** - Understand race conditions and the "don't communicate by sharing memory" principle
8. **Bridge previous knowledge** - Apply CLI styling patterns (Phase 3) to concurrent program output

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (syntax, functions, structs, interfaces, error handling)
- **Phase 2**: CLI development (flag parsing, file I/O, Cobra framework)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout, theming)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-19-goroutines
cd ~/go-learning/lesson-19-goroutines

# Initialize module
go mod init lesson19

# Install dependencies for visualization
go get github.com/charmbracelet/lipgloss@latest
```

### Conceptual Preparation
- Review Lesson 05 (Structs & Methods) - goroutines often work with structured data
- Review Lesson 07 (Error Handling) - concurrent programs require careful error management
- Review Lesson 15 (Lip Gloss Basics) - we'll style concurrent program output

---

## Core Concepts

### 1. What Are Goroutines?

**Definition**: A goroutine is a lightweight thread of execution managed by the Go runtime. Goroutines enable concurrent execution of functions.

**Key Characteristics**:
- **Lightweight**: Start with ~2KB stack (vs 1-2MB for OS threads)
- **Multiplexed**: Thousands of goroutines can run on a few OS threads
- **Managed**: Go runtime handles scheduling and switching
- **Cooperative**: Goroutines yield control at I/O, channel operations, or blocking calls

**Concurrency vs Parallelism**:
```go
// Concurrency: Structure of handling multiple tasks
// - Multiple tasks make progress (not necessarily simultaneously)
// - Can run on a single core
func concurrent() {
    go task1() // Start task 1
    go task2() // Start task 2
    // Both tasks progress, potentially interleaved
}

// Parallelism: Simultaneous execution of tasks
// - Multiple tasks run at the exact same time
// - Requires multiple cores
// - Go achieves parallelism via GOMAXPROCS
```

**When to Use Goroutines**:
```go
// ✅ Good use cases:
// 1. I/O-bound operations (network, disk, API calls)
// 2. Independent computations that can run in parallel
// 3. Background tasks (logging, monitoring, cleanup)
// 4. Server request handling (one goroutine per request)

// ❌ Bad use cases:
// 1. Tiny computations (overhead > benefit)
// 2. Operations requiring strict ordering
// 3. Shared state without synchronization (race conditions)
```

### 2. The `go` Keyword

**Basic Syntax**:
```go
// Sequential execution
func main() {
    doWork()    // Wait for completion
    doMoreWork() // Then execute this
}

// Concurrent execution
func main() {
    go doWork()    // Launch in background
    doMoreWork()   // Execute immediately
}
```

**Goroutine Lifecycle**:
```go
func main() {
    fmt.Println("Main: Starting")

    go func() {
        fmt.Println("Goroutine: Starting")
        time.Sleep(100 * time.Millisecond)
        fmt.Println("Goroutine: Finished") // May not print!
    }()

    fmt.Println("Main: Finishing")
    // Main exits immediately, goroutine may be killed mid-execution
}

// Output (race condition):
// Main: Starting
// Main: Finishing
// (goroutine may not complete)
```

**Proper Synchronization** (preview - covered in Lesson 20):
```go
func main() {
    done := make(chan bool) // Channel for coordination

    go func() {
        fmt.Println("Goroutine: Working...")
        time.Sleep(100 * time.Millisecond)
        done <- true // Signal completion
    }()

    <-done // Wait for signal
    fmt.Println("Main: Goroutine completed")
}
```

### 3. Goroutine Scheduling

**The Go Scheduler (M:N Model)**:
```
┌─────────────────────────────────────┐
│         Go Runtime Scheduler        │
├─────────────────────────────────────┤
│  Goroutines (G): 100,000s possible  │
│         ↓ ↓ ↓ ↓ ↓ ↓ ↓               │
│  Logical Processors (P): GOMAXPROCS │
│         ↓ ↓ ↓ ↓                     │
│  OS Threads (M): Few                │
└─────────────────────────────────────┘
```

**Controlling Parallelism**:
```go
import (
    "fmt"
    "runtime"
)

func main() {
    // Get number of logical CPUs
    numCPU := runtime.NumCPU()
    fmt.Printf("Available CPUs: %d\n", numCPU)

    // Get current GOMAXPROCS setting
    current := runtime.GOMAXPROCS(0) // 0 = query only
    fmt.Printf("GOMAXPROCS: %d\n", current)

    // Set GOMAXPROCS (usually not needed - runtime sets optimally)
    runtime.GOMAXPROCS(numCPU) // Use all available CPUs

    // Query goroutine count
    fmt.Printf("Active goroutines: %d\n", runtime.NumGoroutine())
}
```

**Scheduler Behavior**:
```go
func demoScheduling() {
    for i := 0; i < 3; i++ {
        go func(id int) {
            fmt.Printf("Goroutine %d starting\n", id)
            // Yield point: I/O operation
            fmt.Printf("Goroutine %d finishing\n", id)
        }(i)
    }

    runtime.Gosched() // Yield to allow goroutines to run
    time.Sleep(100 * time.Millisecond) // Wait for completion
}

// Output (non-deterministic):
// Goroutine 2 starting
// Goroutine 0 starting
// Goroutine 1 starting
// Goroutine 2 finishing
// ...
```

### 4. Sequential vs Concurrent Execution Comparison

**Sequential Pattern**:
```go
func processSequential(tasks []string) time.Duration {
    start := time.Now()

    for _, task := range tasks {
        processTask(task) // Each task blocks
    }

    return time.Since(start)
}

func processTask(name string) {
    time.Sleep(100 * time.Millisecond) // Simulate work
}

// 5 tasks × 100ms = 500ms total
```

**Concurrent Pattern**:
```go
func processConcurrent(tasks []string) time.Duration {
    start := time.Now()
    done := make(chan bool)

    for _, task := range tasks {
        go func(t string) {
            processTask(t)
            done <- true
        }(task)
    }

    // Wait for all tasks
    for range tasks {
        <-done
    }

    return time.Since(start)
}

// 5 tasks × 100ms = ~100ms total (if 5+ cores available)
```

**Performance Measurement**:
```go
func benchmarkExecution() {
    tasks := []string{"A", "B", "C", "D", "E"}

    seqTime := processSequential(tasks)
    fmt.Printf("Sequential: %v\n", seqTime)

    conTime := processConcurrent(tasks)
    fmt.Printf("Concurrent: %v\n", conTime)

    speedup := float64(seqTime) / float64(conTime)
    fmt.Printf("Speedup: %.2fx\n", speedup)
}
```

### 5. Common Goroutine Patterns

**Pattern 1: Fire and Forget**:
```go
func logAsync(message string) {
    go func() {
        log.Println(message) // Non-blocking logging
    }()
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
    logAsync("Request received") // Don't wait for logging

    // Process request immediately
    fmt.Fprintf(w, "Response")
}
```

**Pattern 2: Parallel Computation**:
```go
func computeParallel(data []int) []int {
    results := make([]int, len(data))
    done := make(chan bool)

    for i, val := range data {
        go func(index, value int) {
            results[index] = expensiveComputation(value)
            done <- true
        }(i, val)
    }

    // Wait for all computations
    for range data {
        <-done
    }

    return results
}
```

**Pattern 3: Timeout with Goroutines**:
```go
func fetchWithTimeout(url string, timeout time.Duration) (string, error) {
    result := make(chan string)
    errChan := make(chan error)

    go func() {
        data, err := http.Get(url)
        if err != nil {
            errChan <- err
            return
        }
        result <- data
    }()

    select {
    case data := <-result:
        return data, nil
    case err := <-errChan:
        return "", err
    case <-time.After(timeout):
        return "", fmt.Errorf("timeout after %v", timeout)
    }
}
```

### 6. Goroutine Debugging and Inspection

**Runtime Inspection**:
```go
import (
    "fmt"
    "runtime"
    "time"
)

func inspectGoroutines() {
    // Initial state
    fmt.Printf("Start: %d goroutines\n", runtime.NumGoroutine())

    // Launch goroutines
    for i := 0; i < 10; i++ {
        go func(id int) {
            time.Sleep(1 * time.Second)
        }(i)
    }

    time.Sleep(100 * time.Millisecond)
    fmt.Printf("Running: %d goroutines\n", runtime.NumGoroutine())

    time.Sleep(2 * time.Second)
    fmt.Printf("Done: %d goroutines\n", runtime.NumGoroutine())
}
```

**Stack Traces**:
```go
func printAllStacks() {
    buf := make([]byte, 1<<16) // 64KB buffer
    stackSize := runtime.Stack(buf, true) // true = all goroutines
    fmt.Printf("=== All Goroutine Stacks ===\n%s\n", buf[:stackSize])
}
```

### 7. Don't Communicate By Sharing Memory

**❌ Wrong: Shared State (Race Condition)**:
```go
var counter int // Shared variable

func increment() {
    for i := 0; i < 1000; i++ {
        counter++ // Race condition!
    }
}

func main() {
    go increment()
    go increment()
    time.Sleep(1 * time.Second)
    fmt.Println(counter) // Unpredictable result < 2000
}
```

**✅ Right: Communicate via Channels** (preview - Lesson 20):
```go
func incrementSafe(result chan int) {
    count := 0
    for i := 0; i < 1000; i++ {
        count++
    }
    result <- count // Send result via channel
}

func main() {
    result := make(chan int)
    go incrementSafe(result)
    go incrementSafe(result)

    total := <-result + <-result // Receive both results
    fmt.Println(total) // Always 2000
}
```

### 8. Styling Concurrent Output (Bridging Phase 3)

**Using Lip Gloss for Goroutine Visualization**:
```go
import (
    "fmt"
    "sync"
    "time"

    "github.com/charmbracelet/lipgloss"
)

var (
    goroutineStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Bold(true)

    completedStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Prefix("✓ ")
)

func styledGoroutine(id int, wg *sync.WaitGroup) {
    defer wg.Done()

    fmt.Println(goroutineStyle.Render(fmt.Sprintf("Goroutine %d: Starting", id)))
    time.Sleep(time.Duration(id*100) * time.Millisecond)
    fmt.Println(completedStyle.Render(fmt.Sprintf("Goroutine %d: Completed", id)))
}

func main() {
    var wg sync.WaitGroup

    for i := 1; i <= 5; i++ {
        wg.Add(1)
        go styledGoroutine(i, &wg)
    }

    wg.Wait()
    fmt.Println(completedStyle.Render("All goroutines completed"))
}
```

### 9. Performance Considerations

**Goroutine Overhead**:
```go
func measureGoroutineOverhead() {
    // Sequential baseline
    start := time.Now()
    for i := 0; i < 10000; i++ {
        _ = i * 2
    }
    sequential := time.Since(start)

    // Concurrent with goroutines
    start = time.Now()
    done := make(chan bool, 10000)
    for i := 0; i < 10000; i++ {
        go func(n int) {
            _ = n * 2
            done <- true
        }(i)
    }
    for i := 0; i < 10000; i++ {
        <-done
    }
    concurrent := time.Since(start)

    fmt.Printf("Sequential: %v\n", sequential)
    fmt.Printf("Concurrent: %v\n", concurrent)
    fmt.Printf("Overhead: %.2fx slower\n",
        float64(concurrent)/float64(sequential))
}
```

**When Goroutines Hurt Performance**:
- Very short-lived tasks (< 1µs)
- Tasks with high contention on shared resources
- Excessive goroutine creation (millions)

**When Goroutines Help Performance**:
- I/O-bound operations (network, disk)
- Independent computations (embarrassingly parallel)
- Server request handling

---

## Challenge Description

Build a **Concurrent Task Monitor** that demonstrates goroutine fundamentals with styled terminal output.

### Project Overview

Create a CLI application that:
1. Launches multiple goroutines to simulate concurrent tasks
2. Monitors and displays goroutine execution in real-time
3. Measures performance differences between sequential and concurrent execution
4. Uses Lip Gloss to create a visually appealing dashboard
5. Demonstrates safe goroutine patterns

### Functional Requirements

**Core Features**:
```bash
# Run concurrent tasks with monitoring
go run main.go --tasks 10 --duration 100ms

# Compare sequential vs concurrent execution
go run main.go --compare --tasks 20

# Demonstrate different patterns
go run main.go --pattern parallel-compute
go run main.go --pattern fire-forget
go run main.go --pattern timeout
```

**Expected Output**:
```
╔══════════════════════════════════════════╗
║     Concurrent Task Monitor v1.0         ║
╚══════════════════════════════════════════╝

Configuration:
  Tasks:      10
  Duration:   100ms
  Pattern:    parallel-compute

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Task Progress:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 Task 1: Running...
🔄 Task 2: Running...
✓ Task 3: Completed in 95ms
✓ Task 4: Completed in 102ms
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Tasks:         10
Concurrent Time:     105ms
Sequential Time:     1.05s (estimated)
Speedup:            10.00x
Active Goroutines:   1
```

### Implementation Requirements

**Project Structure**:
```
lesson-19-goroutines/
├── main.go                 # CLI entry point and coordination
├── task/
│   ├── task.go             # Task struct and execution logic
│   ├── monitor.go          # Goroutine monitoring
│   └── patterns.go         # Concurrent pattern implementations
├── display/
│   ├── styles.go           # Lip Gloss styles
│   └── dashboard.go        # Terminal dashboard rendering
├── benchmark/
│   └── compare.go          # Sequential vs concurrent comparison
└── main_test.go
```

**Task Types**:
1. **Compute Task**: CPU-bound simulation (Monte Carlo pi estimation)
2. **I/O Task**: Simulated network/disk operation (time.Sleep)
3. **Timeout Task**: Task with built-in timeout
4. **Error Task**: Task that can fail (for error handling practice)

**Monitoring Requirements**:
- Track goroutine creation and completion
- Measure individual task duration
- Calculate total execution time
- Display active goroutine count
- Show completion percentage

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestGoroutineExecution(t *testing.T) {
    tests := []struct {
        name        string
        numTasks    int
        taskDuration time.Duration
        wantCompleted int
        wantMinTime  time.Duration
        wantMaxTime  time.Duration
    }{
        {
            name:         "Single task",
            numTasks:     1,
            taskDuration: 100 * time.Millisecond,
            wantCompleted: 1,
            wantMinTime:   95 * time.Millisecond,
            wantMaxTime:   110 * time.Millisecond,
        },
        {
            name:         "Multiple concurrent tasks",
            numTasks:     10,
            taskDuration: 100 * time.Millisecond,
            wantCompleted: 10,
            wantMinTime:   95 * time.Millisecond,
            wantMaxTime:   150 * time.Millisecond, // Allowing scheduler overhead
        },
        {
            name:         "Many tasks test scheduler",
            numTasks:     100,
            taskDuration: 10 * time.Millisecond,
            wantCompleted: 100,
            wantMinTime:   10 * time.Millisecond,
            wantMaxTime:   200 * time.Millisecond,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            start := time.Now()
            completed := runConcurrentTasks(tt.numTasks, tt.taskDuration)
            elapsed := time.Since(start)

            if completed != tt.wantCompleted {
                t.Errorf("completed = %d, want %d", completed, tt.wantCompleted)
            }

            if elapsed < tt.wantMinTime || elapsed > tt.wantMaxTime {
                t.Errorf("elapsed = %v, want between %v and %v",
                    elapsed, tt.wantMinTime, tt.wantMaxTime)
            }
        })
    }
}
```

### Required Test Coverage

| Test Category | Test Cases | Purpose |
|---------------|------------|---------|
| **Goroutine Creation** | 5+ | Verify goroutines launch correctly |
| **Goroutine Completion** | 5+ | Ensure all goroutines complete |
| **Performance** | 3+ | Validate concurrent speedup |
| **Synchronization** | 4+ | Test coordination mechanisms |
| **Error Handling** | 3+ | Handle goroutine errors gracefully |
| **Pattern Validation** | 6+ | Test each concurrent pattern |
| **Resource Management** | 3+ | Verify no goroutine leaks |

### Specific Test Scenarios

**Goroutine Synchronization**:
```go
func TestGoroutineSynchronization(t *testing.T) {
    done := make(chan bool)
    result := 0

    go func() {
        time.Sleep(50 * time.Millisecond)
        result = 42
        done <- true
    }()

    <-done // Wait for completion

    if result != 42 {
        t.Errorf("result = %d, want 42", result)
    }
}
```

**Goroutine Leak Detection**:
```go
func TestNoGoroutineLeaks(t *testing.T) {
    initial := runtime.NumGoroutine()

    // Launch and complete tasks
    runConcurrentTasks(100, 10*time.Millisecond)

    // Allow cleanup time
    time.Sleep(100 * time.Millisecond)
    runtime.GC()

    final := runtime.NumGoroutine()

    // Should return to baseline (allowing for test runner goroutines)
    if final > initial+2 {
        t.Errorf("goroutine leak detected: initial=%d, final=%d",
            initial, final)
    }
}
```

**Race Condition Detection**:
```go
// Run with: go test -race
func TestNoRaceConditions(t *testing.T) {
    var counter int
    var mu sync.Mutex
    done := make(chan bool)

    for i := 0; i < 100; i++ {
        go func() {
            mu.Lock()
            counter++
            mu.Unlock()
            done <- true
        }()
    }

    for i := 0; i < 100; i++ {
        <-done
    }

    if counter != 100 {
        t.Errorf("counter = %d, want 100", counter)
    }
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Flags**:
```go
var (
    numTasks    = flag.Int("tasks", 10, "Number of concurrent tasks")
    taskDuration = flag.Duration("duration", 100*time.Millisecond, "Task duration")
    pattern     = flag.String("pattern", "parallel", "Concurrent pattern (parallel|fire-forget|timeout)")
    compare     = flag.Bool("compare", false, "Compare sequential vs concurrent")
    verbose     = flag.Bool("verbose", false, "Verbose output with goroutine details")
)
```

### Expected Output Formats

**Standard Execution**:
```
Concurrent Task Monitor v1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  Tasks:      10
  Duration:   100ms
  Pattern:    parallel-compute
  GOMAXPROCS: 8

Executing tasks...
[████████████████████████████████████] 100%

Results:
  ✓ All 10 tasks completed successfully
  ⏱  Total time: 125ms
  🚀 Speedup: 8.00x
  📊 Goroutines (peak): 11
```

**Comparison Mode**:
```
Performance Comparison
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sequential Execution:
  ⏱  Time: 1.050s

Concurrent Execution:
  ⏱  Time: 0.135s
  🚀 Speedup: 7.78x
  📊 Goroutines: 21

Analysis:
  ✓ Concurrency provided 7.78x speedup
  ℹ  Efficiency: 97% (7.78/8 cores)
  ℹ  Overhead: ~35ms scheduler overhead
```

**Verbose Mode**:
```
Goroutine Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Task 1:
  ID:       #12345
  Status:   ✓ Completed
  Duration: 102ms
  CPU:      15%

Task 2:
  ID:       #12346
  Status:   🔄 Running
  Duration: 65ms
  CPU:      18%
...
```

### Error Handling Output

```go
// Goroutine error example
Error in task 5: timeout after 500ms
  Goroutine ID: #12349
  Started:      14:23:15.123
  Failed:       14:23:15.623
  Stack trace:  [Available with --verbose]

Continuing with remaining tasks...
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] Application launches 10+ goroutines concurrently
- [ ] All goroutines complete successfully
- [ ] Goroutine monitoring tracks creation and completion
- [ ] Performance comparison shows expected speedup
- [ ] No goroutine leaks (verified with runtime.NumGoroutine)
- [ ] Graceful handling of main goroutine exit
- [ ] Correct use of synchronization (channels or WaitGroup)

### Code Quality ✅

- [ ] All code passes `go fmt` (formatting)
- [ ] All code passes `go vet` (correctness)
- [ ] All code passes `staticcheck` (style)
- [ ] No race conditions detected (`go test -race`)
- [ ] Goroutine functions have clear, descriptive names
- [ ] Proper error propagation from goroutines
- [ ] Comments explain concurrent logic and synchronization points

### Testing ✅

- [ ] Table-driven tests for goroutine patterns
- [ ] Test coverage >80% (`go test -cover`)
- [ ] Race condition testing passes (`go test -race`)
- [ ] Goroutine leak tests pass
- [ ] Performance benchmarks included
- [ ] Edge cases tested (0 tasks, 1 task, 1000 tasks)

### Documentation ✅

- [ ] README explains concurrent patterns used
- [ ] Function comments describe goroutine behavior
- [ ] Examples demonstrate basic usage
- [ ] Performance characteristics documented
- [ ] Synchronization mechanisms explained

### Performance ✅

- [ ] Concurrent execution faster than sequential (I/O-bound tasks)
- [ ] Overhead acceptable for given task size
- [ ] Scales efficiently with task count
- [ ] No memory leaks from goroutine accumulation
- [ ] Proper cleanup on program exit

---

## Common Pitfalls

### ❌ Pitfall 1: Main Goroutine Exits Too Early

**Wrong**:
```go
func main() {
    go doWork()
    fmt.Println("Done") // Exits immediately, goroutine killed!
}
```

**Right**:
```go
func main() {
    done := make(chan bool)
    go func() {
        doWork()
        done <- true
    }()
    <-done // Wait for completion
    fmt.Println("Done")
}
```

**Why**: The main goroutine exit kills all other goroutines. Always synchronize before exit.

---

### ❌ Pitfall 2: Goroutine Variable Capture

**Wrong**:
```go
for i := 0; i < 5; i++ {
    go func() {
        fmt.Println(i) // All print 5 (or unpredictable)
    }()
}
```

**Right**:
```go
for i := 0; i < 5; i++ {
    go func(id int) {
        fmt.Println(id) // Each prints its own value
    }(i) // Pass by value
}
```

**Why**: Loop variable `i` is shared. By the time goroutines run, loop has finished and `i == 5`.

---

### ❌ Pitfall 3: Race Conditions on Shared State

**Wrong**:
```go
var counter int

func increment() {
    for i := 0; i < 1000; i++ {
        counter++ // RACE CONDITION!
    }
}

func main() {
    go increment()
    go increment()
    time.Sleep(1 * time.Second)
    fmt.Println(counter) // Unpredictable result
}
```

**Right**:
```go
func increment(result chan int) {
    count := 0
    for i := 0; i < 1000; i++ {
        count++ // Local variable
    }
    result <- count // Send via channel
}

func main() {
    result := make(chan int, 2)
    go increment(result)
    go increment(result)
    total := <-result + <-result
    fmt.Println(total) // Always 2000
}
```

**Why**: Concurrent access to shared variables without synchronization causes race conditions.

---

### ❌ Pitfall 4: Blocking Without Timeout

**Wrong**:
```go
func main() {
    result := make(chan string)

    go func() {
        // If this fails, we block forever
        if someCondition {
            return // Never sends to channel!
        }
        result <- "data"
    }()

    data := <-result // Deadlock if goroutine doesn't send
    fmt.Println(data)
}
```

**Right**:
```go
func main() {
    result := make(chan string)

    go func() {
        if someCondition {
            result <- "" // Always send something
            return
        }
        result <- "data"
    }()

    select {
    case data := <-result:
        if data != "" {
            fmt.Println(data)
        }
    case <-time.After(1 * time.Second):
        fmt.Println("Timeout")
    }
}
```

**Why**: Always ensure goroutines complete their channel operations or use timeouts.

---

### ❌ Pitfall 5: Forgetting GOMAXPROCS on Single Core

**Wrong**:
```go
func main() {
    // Expects parallelism, but on single-core machine:
    for i := 0; i < 10; i++ {
        go computeIntensive()
    }
    // No speedup - still runs sequentially on single core
}
```

**Right**:
```go
func main() {
    fmt.Printf("Running on %d cores\n", runtime.NumCPU())
    runtime.GOMAXPROCS(runtime.NumCPU()) // Usually set by runtime

    // Set expectations correctly
    if runtime.NumCPU() == 1 {
        fmt.Println("Note: Single core, limited parallelism")
    }

    for i := 0; i < 10; i++ {
        go computeIntensive()
    }
}
```

**Why**: Goroutines provide concurrency, but parallelism requires multiple cores.

---

### ❌ Pitfall 6: Creating Too Many Goroutines

**Wrong**:
```go
func processFiles(files []string) {
    for _, file := range files { // Could be millions
        go processFile(file) // OOM risk!
    }
}
```

**Right**:
```go
func processFiles(files []string) {
    const maxWorkers = 100
    sem := make(chan struct{}, maxWorkers) // Semaphore

    for _, file := range files {
        sem <- struct{}{} // Acquire
        go func(f string) {
            defer func() { <-sem }() // Release
            processFile(f)
        }(file)
    }

    // Drain semaphore to wait for all
    for i := 0; i < maxWorkers; i++ {
        sem <- struct{}{}
    }
}
```

**Why**: Unlimited goroutine creation can exhaust memory. Use worker pools (covered in Lesson 23).

---

## Extension Challenges

### Extension 1: Goroutine Pool Manager ⭐⭐

Implement a reusable goroutine pool:

```go
type Pool struct {
    tasks   chan func()
    workers int
}

func NewPool(workers int) *Pool {
    p := &Pool{
        tasks:   make(chan func(), 100),
        workers: workers,
    }

    // Start worker goroutines
    for i := 0; i < workers; i++ {
        go p.worker()
    }

    return p
}

func (p *Pool) worker() {
    for task := range p.tasks {
        task() // Execute task
    }
}

func (p *Pool) Submit(task func()) {
    p.tasks <- task
}

func (p *Pool) Shutdown() {
    close(p.tasks)
}

// Usage
func main() {
    pool := NewPool(10)
    defer pool.Shutdown()

    for i := 0; i < 100; i++ {
        task := func(id int) func() {
            return func() {
                fmt.Printf("Task %d executing\n", id)
            }
        }(i)
        pool.Submit(task)
    }
}
```

**Learning Goal**: Understand goroutine lifecycle management and resource pooling.

---

### Extension 2: Progress Bar with Goroutine Updates ⭐⭐

Create a real-time progress bar using goroutines:

```go
type ProgressTracker struct {
    total     int
    completed chan int
    done      chan bool
}

func NewProgressTracker(total int) *ProgressTracker {
    pt := &ProgressTracker{
        total:     total,
        completed: make(chan int, total),
        done:      make(chan bool),
    }
    go pt.render()
    return pt
}

func (pt *ProgressTracker) render() {
    count := 0
    for count < pt.total {
        <-pt.completed
        count++

        // Calculate progress
        percent := float64(count) / float64(pt.total) * 100
        bar := strings.Repeat("█", int(percent/2))

        // Clear line and render
        fmt.Printf("\r[%-50s] %.0f%% (%d/%d)",
            bar, percent, count, pt.total)
    }
    fmt.Println() // New line after completion
    pt.done <- true
}

func (pt *ProgressTracker) Complete() {
    pt.completed <- 1
}

func (pt *ProgressTracker) Wait() {
    <-pt.done
}

// Usage
func main() {
    tracker := NewProgressTracker(100)

    for i := 0; i < 100; i++ {
        go func() {
            time.Sleep(50 * time.Millisecond)
            tracker.Complete()
        }()
    }

    tracker.Wait()
}
```

**Learning Goal**: Coordinate goroutines for real-time UI updates.

---

### Extension 3: Monte Carlo Pi Estimation (Parallel Compute) ⭐⭐⭐

Compute π using parallel Monte Carlo simulation:

```go
func estimatePiParallel(samples int, workers int) float64 {
    samplesPerWorker := samples / workers
    results := make(chan int, workers)

    for i := 0; i < workers; i++ {
        go func() {
            inside := 0
            for j := 0; j < samplesPerWorker; j++ {
                x := rand.Float64()
                y := rand.Float64()
                if x*x + y*y <= 1.0 {
                    inside++
                }
            }
            results <- inside
        }()
    }

    totalInside := 0
    for i := 0; i < workers; i++ {
        totalInside += <-results
    }

    return 4.0 * float64(totalInside) / float64(samples)
}

func main() {
    samples := 10_000_000

    // Sequential
    start := time.Now()
    pi := estimatePiSequential(samples)
    seqTime := time.Since(start)
    fmt.Printf("Sequential: π ≈ %.6f in %v\n", pi, seqTime)

    // Parallel
    start = time.Now()
    pi = estimatePiParallel(samples, runtime.NumCPU())
    parTime := time.Since(start)
    fmt.Printf("Parallel:   π ≈ %.6f in %v\n", pi, parTime)
    fmt.Printf("Speedup:    %.2fx\n", float64(seqTime)/float64(parTime))
}
```

**Learning Goal**: Apply goroutines to CPU-bound embarrassingly parallel problems.

---

### Extension 4: Goroutine Profiling Dashboard ⭐⭐⭐

Create a live dashboard showing goroutine statistics:

```go
type GoroutineStats struct {
    Total      int
    Running    int
    Waiting    int
    MaxSeen    int
    CreatedTotal int
}

func monitorGoroutines(interval time.Duration, done chan bool) {
    ticker := time.Ticker(interval)
    defer ticker.Stop()

    stats := &GoroutineStats{}

    for {
        select {
        case <-ticker.C:
            current := runtime.NumGoroutine()
            stats.Total = current

            if current > stats.MaxSeen {
                stats.MaxSeen = current
            }

            printDashboard(stats)

        case <-done:
            return
        }
    }
}

func printDashboard(stats *GoroutineStats) {
    dashboard := lipgloss.JoinVertical(
        lipgloss.Left,
        "╔══════════════════════════════════════╗",
        "║      Goroutine Monitor              ║",
        "╚══════════════════════════════════════╝",
        fmt.Sprintf("Current:  %d", stats.Total),
        fmt.Sprintf("Peak:     %d", stats.MaxSeen),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    )

    // Clear screen and render
    fmt.Print("\033[H\033[2J") // ANSI clear
    fmt.Println(dashboard)
}
```

**Learning Goal**: Real-time monitoring and visualization of goroutine behavior.

---

### Extension 5: Goroutine Timeout Manager ⭐⭐⭐⭐

Implement a manager that can timeout and cancel goroutines:

```go
type TimeoutManager struct {
    timeout time.Duration
}

func NewTimeoutManager(timeout time.Duration) *TimeoutManager {
    return &TimeoutManager{timeout: timeout}
}

func (tm *TimeoutManager) Run(task func() error) error {
    errChan := make(chan error, 1)

    go func() {
        errChan <- task()
    }()

    select {
    case err := <-errChan:
        return err
    case <-time.After(tm.timeout):
        return fmt.Errorf("timeout after %v", tm.timeout)
    }
}

// With cancellation (preview of context.Context in Lesson 24)
func (tm *TimeoutManager) RunWithCancel(task func(cancel <-chan bool) error) error {
    errChan := make(chan error, 1)
    cancel := make(chan bool)

    go func() {
        errChan <- task(cancel)
    }()

    select {
    case err := <-errChan:
        return err
    case <-time.After(tm.timeout):
        close(cancel) // Signal cancellation
        return fmt.Errorf("timeout after %v", tm.timeout)
    }
}

// Usage
func main() {
    tm := NewTimeoutManager(500 * time.Millisecond)

    err := tm.RunWithCancel(func(cancel <-chan bool) error {
        for i := 0; i < 10; i++ {
            select {
            case <-cancel:
                return fmt.Errorf("cancelled at iteration %d", i)
            default:
                time.Sleep(100 * time.Millisecond)
                fmt.Printf("Iteration %d\n", i)
            }
        }
        return nil
    })

    fmt.Println("Result:", err)
}
```

**Learning Goal**: Advanced goroutine control and cancellation patterns.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear separation: goroutine launching vs coordination vs monitoring
- Reusable patterns (pool, timeout, progress tracking)
- Proper synchronization (channels or sync.WaitGroup)
- No race conditions (verify with `-race` flag)

**Goroutine Patterns**:
- Use channels for communication (preview Lesson 20)
- Pass loop variables by value to goroutines
- Always ensure goroutines complete before main exits
- Handle errors from goroutines via error channels

**Testing Approach**:
- Table-driven tests for different goroutine counts
- Race condition detection (`go test -race`)
- Goroutine leak detection (runtime.NumGoroutine checks)
- Performance benchmarks comparing sequential vs concurrent

**Documentation**:
- Explain synchronization mechanisms used
- Document goroutine lifecycle
- Clarify when goroutines start and complete
- Note any assumptions about GOMAXPROCS

### Code Quality Standards

```bash
# All implementations must pass:
go fmt ./...
go vet ./...
staticcheck ./...
go test -race ./...
go test -cover ./... # Target >80%
```

### Common Implementation Approaches

**Approach 1: Channel-Based Coordination**:
```go
func runTasks(n int) {
    done := make(chan bool, n)

    for i := 0; i < n; i++ {
        go func(id int) {
            performTask(id)
            done <- true
        }(i)
    }

    for i := 0; i < n; i++ {
        <-done
    }
}
```

**Approach 2: WaitGroup Coordination** (preview):
```go
func runTasks(n int) {
    var wg sync.WaitGroup

    for i := 0; i < n; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            performTask(id)
        }(i)
    }

    wg.Wait()
}
```

Both are valid; Approach 1 is more explicit for beginners, Approach 2 is more idiomatic.

### Performance Expectations

- Concurrent execution should be faster than sequential for I/O-bound tasks
- Speedup proportional to available cores (up to GOMAXPROCS)
- Minimal overhead for goroutine creation (~2KB per goroutine)
- No memory leaks or goroutine leaks

---

## Learning Resources

### Official Go Documentation
- [Effective Go: Goroutines](https://go.dev/doc/effective_go#goroutines)
- [Go Tour: Goroutines](https://go.dev/tour/concurrency/1)
- [Go Blog: Go Concurrency Patterns](https://go.dev/blog/pipelines)
- [Package runtime](https://pkg.go.dev/runtime)

### Articles and Tutorials
- [Concurrency is not Parallelism](https://go.dev/blog/waza-talk) by Rob Pike
- [Visualizing Concurrency in Go](https://divan.dev/posts/go_concurrency_visualize/)
- [Common Goroutine Mistakes](https://go101.org/article/concurrent-common-mistakes.html)

### Books
- *The Go Programming Language* (Chapter 8: Goroutines and Channels)
- *Concurrency in Go* by Katherine Cox-Buday
- *Go in Action* (Chapter 6: Concurrency)

### Video Resources
- [Rob Pike: Concurrency is not Parallelism](https://www.youtube.com/watch?v=oV9rvDllKEg)
- [GopherCon 2018: Kavya Joshi - The Scheduler Saga](https://www.youtube.com/watch?v=YHRO5WQGh0k)

### Related Charm.sh
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Terminal styling (Phase 3 review)
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - Coming in Phase 5

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

# Run application
go run main.go --tasks 10 --duration 100ms

# Compare sequential vs concurrent
go run main.go --compare --tasks 20

# Verbose goroutine monitoring
go run main.go --verbose --tasks 5

# Performance profiling
go test -bench=. -benchmem ./...
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestGoroutineExecution
=== RUN   TestGoroutineExecution/Single_task
=== RUN   TestGoroutineExecution/Multiple_concurrent_tasks
=== RUN   TestGoroutineExecution/Many_tasks_test_scheduler
--- PASS: TestGoroutineExecution (0.45s)
    --- PASS: TestGoroutineExecution/Single_task (0.11s)
    --- PASS: TestGoroutineExecution/Multiple_concurrent_tasks (0.12s)
    --- PASS: TestGoroutineExecution/Many_tasks_test_scheduler (0.22s)
=== RUN   TestNoRaceConditions
--- PASS: TestNoRaceConditions (0.01s)
=== RUN   TestNoGoroutineLeaks
--- PASS: TestNoGoroutineLeaks (0.15s)
PASS
coverage: 85.3% of statements
ok      lesson19    0.625s
```

### Race Detection Output

```bash
$ go test -race ./...
PASS
ok      lesson19    0.847s
```

*If race detected:*
```bash
==================
WARNING: DATA RACE
Read at 0x00c0000140a0 by goroutine 8:
  lesson19.increment()
      /path/to/file.go:15 +0x44

Previous write at 0x00c0000140a0 by goroutine 7:
  lesson19.increment()
      /path/to/file.go:15 +0x5a
==================
```

---

**Previous Lesson**: [Lesson 18: Enhancing Existing CLIs with Style](lesson-18-cli-enhancement.md) (Phase 3)
**Next Lesson**: Lesson 20: Channels - Unbuffered & Buffered (Phase 4)
**Phase 4 Milestone**: Lesson 24: Concurrent Web Crawler with Context

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
