# Lesson 20: Channels - Unbuffered & Buffered

**Phase**: 4 - Concurrency Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-19 (Go Fundamentals, CLI Development, Styling with Lip Gloss, Introduction to Goroutines)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Understand channel fundamentals** - Differentiate between buffered and unbuffered channels, understand when and why to use each type
2. **Create and use channels** - Use the `make()` function to create channels with appropriate buffer sizes
3. **Send and receive operations** - Master channel send and receive syntax, understand blocking behavior
4. **Apply channel directions** - Use send-only and receive-only channel types for API safety
5. **Close channels properly** - Understand when to close channels and detect closed channel states
6. **Implement communication patterns** - Build producer-consumer and job queue patterns using channels
7. **Analyze channel performance** - Measure and compare buffered vs unbuffered channel performance characteristics
8. **Bridge goroutine knowledge** - Apply Lesson 19 goroutines with channels for safe concurrent communication

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (syntax, functions, structs, interfaces, error handling)
- **Phase 2**: CLI development (flag parsing, file I/O, Cobra framework)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout, theming)
- **Lesson 19**: Goroutines (concurrent execution, goroutine lifecycle, runtime management)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-20-channels
cd ~/go-learning/lesson-20-channels

# Initialize module
go mod init lesson20

# Install dependencies for visualization
go get github.com/charmbracelet/lipgloss@latest
```

### Conceptual Preparation
- Review Lesson 19 (Goroutines) - channels enable safe goroutine communication
- Review Lesson 05 (Structs & Methods) - channels often pass structured data
- Review Lesson 07 (Error Handling) - channels used for error propagation
- Review Lesson 15 (Lip Gloss Basics) - we'll style channel operation output

---

## Core Concepts

### 1. What Are Channels?

**Definition**: A channel is a typed conduit through which you can send and receive values with the channel operator `<-`. Channels are Go's primary mechanism for communication between goroutines.

**Key Characteristics**:
- **Typed**: Channels carry values of a specific type
- **Synchronization**: Unbuffered channels provide synchronization between goroutines
- **Thread-safe**: Multiple goroutines can safely send/receive on the same channel
- **First-class**: Channels can be passed as function parameters and return values

**Why Channels?**:
```go
// ❌ Without channels: Shared memory (race conditions)
var counter int
go func() { counter++ }()  // Race condition!
go func() { counter++ }()  // Unpredictable result

// ✅ With channels: Message passing (safe)
results := make(chan int, 2)
go func() { results <- 1 }()  // Send via channel
go func() { results <- 1 }()  // Send via channel
total := <-results + <-results  // Receive both: always 2
```

**Go Proverb**: *"Don't communicate by sharing memory; share memory by communicating."*

### 2. Channel Creation with `make()`

**Basic Syntax**:
```go
// Unbuffered channel (capacity 0)
ch := make(chan int)        // Send blocks until receive
messages := make(chan string)

// Buffered channel (capacity > 0)
buffered := make(chan int, 10)     // Can hold 10 ints before blocking
jobs := make(chan string, 100)     // Job queue with 100 capacity

// Read-only and write-only channel types
var readOnly <-chan int = ch       // Receive-only
var writeOnly chan<- int = ch      // Send-only
```

**Channel Type Syntax**:
```go
chan T          // Bidirectional channel of type T
chan<- T        // Send-only channel of type T
<-chan T        // Receive-only channel of type T
```

**Zero Value**:
```go
var ch chan int  // Zero value is nil
// ch <- 42      // Panic: send on nil channel
// <-ch          // Panic: receive on nil channel

// Always initialize with make()
ch = make(chan int)
ch <- 42  // Now safe
```

### 3. Sending and Receiving Operations

**Send Operation**:
```go
ch := make(chan int)

// Send value to channel (blocks until received)
ch <- 42

// Send in goroutine (non-blocking main)
go func() {
    ch <- 100
}()
```

**Receive Operation**:
```go
// Receive value from channel
value := <-ch

// Receive and discard value
<-ch

// Receive with closed channel check
value, ok := <-ch
if !ok {
    fmt.Println("Channel closed")
}
```

**Blocking Behavior**:
```go
func demonstrateBlocking() {
    ch := make(chan int)

    // This would deadlock (no receiver)!
    // ch <- 42  // Fatal error: all goroutines are asleep - deadlock!

    // Solution: Send in goroutine
    go func() {
        ch <- 42
    }()

    value := <-ch  // Receive blocks until send completes
    fmt.Println(value)
}
```

### 4. Unbuffered Channels (Synchronous Communication)

**Behavior**: Sends block until receive is ready, receives block until send is ready.

**Synchronization Example**:
```go
func unbufferedExample() {
    done := make(chan bool)  // Unbuffered

    go func() {
        fmt.Println("Goroutine: Working...")
        time.Sleep(1 * time.Second)
        fmt.Println("Goroutine: Done")
        done <- true  // Send blocks until main receives
    }()

    fmt.Println("Main: Waiting...")
    <-done  // Receive blocks until goroutine sends
    fmt.Println("Main: Goroutine completed")
}

// Output (in order):
// Main: Waiting...
// Goroutine: Working...
// Goroutine: Done
// Main: Goroutine completed
```

**Handshake Pattern**:
```go
func handshake() {
    ch := make(chan int)

    go func() {
        fmt.Println("Sender: Waiting for receiver...")
        ch <- 42  // Blocks until receiver ready
        fmt.Println("Sender: Value sent")
    }()

    time.Sleep(500 * time.Millisecond)
    fmt.Println("Receiver: Ready to receive")
    value := <-ch  // Unblocks sender
    fmt.Println("Receiver: Got", value)
}
```

**Guaranteed Execution Order**: Unbuffered channels create happens-before relationships.

### 5. Buffered Channels (Asynchronous Up to Capacity)

**Behavior**: Sends block only when buffer is full, receives block only when buffer is empty.

**Buffer Capacity**:
```go
func bufferedExample() {
    ch := make(chan int, 3)  // Buffer of 3

    // Send 3 values without blocking
    ch <- 1
    ch <- 2
    ch <- 3

    fmt.Println("Three values sent without blocking")

    // Fourth send would block (buffer full)
    // ch <- 4  // Would block until a receive

    // Receive all values
    fmt.Println(<-ch)  // 1
    fmt.Println(<-ch)  // 2
    fmt.Println(<-ch)  // 3
}
```

**Queue Behavior**:
```go
func queueDemo() {
    queue := make(chan string, 2)

    queue <- "first"
    queue <- "second"
    // Buffer full (2/2)

    fmt.Println(<-queue)  // "first" - buffer now 1/2
    queue <- "third"      // Can send again - buffer 2/2

    fmt.Println(<-queue)  // "second"
    fmt.Println(<-queue)  // "third"
}
```

**When to Use Buffered Channels**:
```go
// ✅ Good use cases:
// 1. Job queues with known capacity
jobs := make(chan Job, 100)

// 2. Results collection without blocking
results := make(chan Result, numWorkers)

// 3. Rate limiting
rateLimiter := make(chan struct{}, 10)  // Max 10 concurrent

// 4. Avoiding goroutine blocking
events := make(chan Event, 50)

// ❌ Bad use cases:
// 1. Replacing synchronization (use unbuffered)
// 2. "Fixing" deadlocks (indicates design problem)
// 3. Arbitrary large buffers (memory waste)
```

### 6. Channel Directions (Send-Only, Receive-Only)

**Type Safety with Directions**:
```go
// Function that only sends
func producer(ch chan<- int) {
    for i := 0; i < 5; i++ {
        ch <- i
    }
    close(ch)
}

// Function that only receives
func consumer(ch <-chan int) {
    for val := range ch {
        fmt.Println("Received:", val)
    }
}

func main() {
    ch := make(chan int)  // Bidirectional

    go producer(ch)  // Converts to send-only
    consumer(ch)     // Converts to receive-only
}
```

**Preventing Misuse**:
```go
func sendOnly(ch chan<- int) {
    ch <- 42
    // value := <-ch  // Compile error: receive from send-only
}

func receiveOnly(ch <-chan int) {
    value := <-ch
    // ch <- 42  // Compile error: send to receive-only
}
```

**API Design Pattern**:
```go
// Return receive-only channel for safety
func startWork() <-chan Result {
    results := make(chan Result)
    go func() {
        // Do work
        results <- Result{Data: "done"}
        close(results)
    }()
    return results  // Callers can only receive
}

func main() {
    results := startWork()
    for result := range results {
        fmt.Println(result)
    }
}
```

### 7. Closing Channels

**When to Close**:
```go
// ✅ Close when: Sender is done and no more values will be sent
func producer(ch chan<- int) {
    for i := 0; i < 5; i++ {
        ch <- i
    }
    close(ch)  // Signal completion
}

// ❌ Don't close: If receiver closes (sender will panic)
// ❌ Don't close: Channels you don't own
// ❌ Don't close: If multiple senders (causes panic)
```

**Close Syntax and Detection**:
```go
ch := make(chan int, 2)
ch <- 1
ch <- 2
close(ch)

// Receive with closed check
value, ok := <-ch
fmt.Println(value, ok)  // 1 true

value, ok = <-ch
fmt.Println(value, ok)  // 2 true

value, ok = <-ch
fmt.Println(value, ok)  // 0 false (channel closed, zero value returned)

// Range automatically stops on close
for val := range ch {
    fmt.Println(val)
}
```

**Close Semantics**:
```go
func closeDemo() {
    ch := make(chan int, 2)
    ch <- 1
    ch <- 2
    close(ch)

    // After close:
    // - Receives succeed until buffer empty, then return zero value
    // - Sends panic
    // - Close again panics

    // ch <- 3     // Panic: send on closed channel
    // close(ch)   // Panic: close of closed channel

    // Safe: receive all buffered values
    for val := range ch {
        fmt.Println(val)  // Prints 1, 2, then exits
    }
}
```

**Nil vs Closed Channels**:
```go
var nilCh chan int       // nil channel
closedCh := make(chan int)
close(closedCh)

// nilCh <- 42           // Panic: send on nil channel
// <-nilCh               // Blocks forever

// closedCh <- 42        // Panic: send on closed channel
val := <-closedCh        // Returns zero value immediately
```

### 8. Producer-Consumer Pattern

**Single Producer, Single Consumer**:
```go
func producer(ch chan<- int) {
    defer close(ch)  // Close when done producing

    for i := 0; i < 10; i++ {
        fmt.Printf("Producing: %d\n", i)
        ch <- i
        time.Sleep(100 * time.Millisecond)
    }
}

func consumer(ch <-chan int) {
    for val := range ch {  // Range exits when channel closed
        fmt.Printf("Consuming: %d\n", val)
        time.Sleep(200 * time.Millisecond)
    }
}

func main() {
    ch := make(chan int, 5)  // Buffered to smooth rate difference

    go producer(ch)
    consumer(ch)  // Blocks until producer closes channel
}
```

**Multiple Producers, Single Consumer**:
```go
func multiProducer(id int, ch chan<- int, done chan<- bool) {
    for i := 0; i < 5; i++ {
        val := id*10 + i
        ch <- val
        fmt.Printf("Producer %d: sent %d\n", id, val)
        time.Sleep(100 * time.Millisecond)
    }
    done <- true
}

func main() {
    ch := make(chan int, 10)
    done := make(chan bool)

    // Start 3 producers
    for i := 1; i <= 3; i++ {
        go multiProducer(i, ch, done)
    }

    // Wait for all producers in separate goroutine
    go func() {
        for i := 0; i < 3; i++ {
            <-done
        }
        close(ch)  // Safe to close after all producers done
    }()

    // Consume
    for val := range ch {
        fmt.Printf("Consumed: %d\n", val)
    }
}
```

### 9. Job Queue with Workers Pattern

**Worker Pool Pattern**:
```go
type Job struct {
    ID   int
    Data string
}

type Result struct {
    Job   Job
    Value int
}

func worker(id int, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        fmt.Printf("Worker %d: processing job %d\n", id, job.ID)
        time.Sleep(500 * time.Millisecond)  // Simulate work

        // Send result
        results <- Result{
            Job:   job,
            Value: len(job.Data),
        }
    }
}

func jobQueueExample() {
    const numWorkers = 3
    const numJobs = 9

    jobs := make(chan Job, numJobs)
    results := make(chan Result, numJobs)

    // Start workers
    for w := 1; w <= numWorkers; w++ {
        go worker(w, jobs, results)
    }

    // Send jobs
    for j := 1; j <= numJobs; j++ {
        jobs <- Job{ID: j, Data: fmt.Sprintf("task-%d", j)}
    }
    close(jobs)

    // Collect results
    for r := 0; r < numJobs; r++ {
        result := <-results
        fmt.Printf("Result: Job %d = %d\n", result.Job.ID, result.Value)
    }
}
```

**Rate-Limited Worker Pool**:
```go
func rateLimitedWorker(jobs <-chan Job, results chan<- Result, limiter <-chan time.Time) {
    for job := range jobs {
        <-limiter  // Wait for rate limiter
        fmt.Printf("Processing job %d\n", job.ID)
        results <- Result{Job: job, Value: len(job.Data)}
    }
}

func rateLimitedExample() {
    jobs := make(chan Job, 10)
    results := make(chan Result, 10)
    limiter := time.Tick(500 * time.Millisecond)  // Max 2 jobs/second

    go rateLimitedWorker(jobs, results, limiter)

    // Send jobs
    for i := 1; i <= 5; i++ {
        jobs <- Job{ID: i, Data: "data"}
    }
    close(jobs)

    // Collect results
    for i := 0; i < 5; i++ {
        <-results
    }
}
```

### 10. Buffered vs Unbuffered Performance Comparison

**Performance Characteristics**:
```go
func benchmarkUnbuffered(iterations int) time.Duration {
    ch := make(chan int)  // Unbuffered
    start := time.Now()

    go func() {
        for i := 0; i < iterations; i++ {
            ch <- i
        }
    }()

    for i := 0; i < iterations; i++ {
        <-ch
    }

    return time.Since(start)
}

func benchmarkBuffered(iterations int, bufferSize int) time.Duration {
    ch := make(chan int, bufferSize)
    start := time.Now()

    go func() {
        for i := 0; i < iterations; i++ {
            ch <- i
        }
    }()

    for i := 0; i < iterations; i++ {
        <-ch
    }

    return time.Since(start)
}

func comparePerformance() {
    iterations := 10000

    unbuffered := benchmarkUnbuffered(iterations)
    buffered10 := benchmarkBuffered(iterations, 10)
    buffered100 := benchmarkBuffered(iterations, 100)
    buffered1000 := benchmarkBuffered(iterations, 1000)

    fmt.Printf("Unbuffered:      %v\n", unbuffered)
    fmt.Printf("Buffered (10):   %v (%.2fx)\n", buffered10, float64(unbuffered)/float64(buffered10))
    fmt.Printf("Buffered (100):  %v (%.2fx)\n", buffered100, float64(unbuffered)/float64(buffered100))
    fmt.Printf("Buffered (1000): %v (%.2fx)\n", buffered1000, float64(unbuffered)/float64(buffered1000))
}
```

**Memory vs Latency Trade-off**:
```go
// Unbuffered: Low memory, high synchronization cost
ch1 := make(chan int)        // ~96 bytes

// Small buffer: Moderate memory, reduced blocking
ch2 := make(chan int, 10)    // ~96 + 10*8 = 176 bytes

// Large buffer: High memory, minimal blocking
ch3 := make(chan int, 1000)  // ~96 + 1000*8 = 8096 bytes
```

### 11. Styling Channel Operations (Bridging Phase 3)

**Using Lip Gloss for Channel Visualization**:
```go
import (
    "fmt"
    "time"

    "github.com/charmbracelet/lipgloss"
)

var (
    sendStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Bold(true).
        Prefix("→ ")

    receiveStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Bold(true).
        Prefix("← ")

    channelStyle = lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        Padding(1).
        BorderForeground(lipgloss.Color("240"))
)

func visualizeChannelOperations() {
    ch := make(chan int, 3)

    // Producer
    go func() {
        for i := 1; i <= 5; i++ {
            fmt.Println(sendStyle.Render(fmt.Sprintf("Send %d", i)))
            ch <- i
            time.Sleep(500 * time.Millisecond)
        }
        close(ch)
    }()

    // Consumer
    for val := range ch {
        fmt.Println(receiveStyle.Render(fmt.Sprintf("Receive %d", val)))
        time.Sleep(300 * time.Millisecond)
    }

    summary := channelStyle.Render("All messages processed")
    fmt.Println(summary)
}
```

**Channel Dashboard**:
```go
func renderChannelDashboard(sent, received, buffered int, capacity int) string {
    header := lipgloss.NewStyle().
        Bold(true).
        Foreground(lipgloss.Color("99")).
        Render("Channel Statistics")

    stats := fmt.Sprintf(`
Sent:      %d
Received:  %d
Buffered:  %d/%d
Capacity:  %d
`, sent, received, buffered, capacity, capacity)

    return lipgloss.JoinVertical(
        lipgloss.Left,
        header,
        "━━━━━━━━━━━━━━━━━━━━━━",
        stats,
    )
}
```

### 12. Performance and Memory Considerations

**Channel Overhead**:
```go
func measureChannelOverhead() {
    const iterations = 1000000

    // Baseline: Direct function call
    start := time.Now()
    for i := 0; i < iterations; i++ {
        _ = i * 2
    }
    baseline := time.Since(start)

    // Channel communication
    ch := make(chan int)
    start = time.Now()

    go func() {
        for i := 0; i < iterations; i++ {
            ch <- i
        }
        close(ch)
    }()

    for range ch {
        // Consume
    }
    channelTime := time.Since(start)

    fmt.Printf("Baseline:  %v\n", baseline)
    fmt.Printf("Channels:  %v\n", channelTime)
    fmt.Printf("Overhead:  %.2fx\n", float64(channelTime)/float64(baseline))
}
```

**Buffer Size Selection**:
```go
// Consider:
// 1. Expected send/receive rate difference
// 2. Burst traffic patterns
// 3. Memory constraints
// 4. Latency requirements

// ✅ Good buffer sizes:
jobs := make(chan Job, runtime.NumCPU()*2)     // 2x workers
events := make(chan Event, 100)                // Expected burst size
results := make(chan Result, numGoroutines)    // One per goroutine

// ❌ Bad buffer sizes:
huge := make(chan int, 1000000)  // Excessive memory
tiny := make(chan int, 1)        // Defeats purpose of buffering
```

**When Channels Hurt Performance**:
- Very high-frequency operations (> 1M ops/sec)
- Shared memory would be simpler with proper locking
- Single-threaded sequential processing sufficient

**When Channels Help Performance**:
- Decoupling producers from consumers
- Load distribution across workers
- Pipeline processing stages
- Event-driven architectures

---

## Challenge Description

Build a **Pipeline Processing System** that demonstrates channel fundamentals with worker pools and styled terminal output.

### Project Overview

Create a CLI application that:
1. Implements a multi-stage processing pipeline using channels
2. Demonstrates buffered and unbuffered channel behavior
3. Uses worker pools for concurrent processing
4. Measures and compares performance characteristics
5. Uses Lip Gloss for real-time visualization of channel operations
6. Handles errors gracefully through error channels

### Functional Requirements

**Core Features**:
```bash
# Run pipeline with default settings
go run main.go

# Specify worker count and buffer size
go run main.go --workers 5 --buffer 10

# Run performance comparison
go run main.go --benchmark --iterations 10000

# Visualize channel operations
go run main.go --visualize --jobs 20
```

**Expected Output**:
```
╔══════════════════════════════════════════╗
║    Pipeline Processing System v1.0       ║
╚══════════════════════════════════════════╝

Configuration:
  Workers:     5
  Buffer Size: 10
  Jobs:        50

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stage 1: Data Generation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Generated job 1
→ Generated job 2
→ Generated job 3
[Progress bar: ████████████████████████] 100%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stage 2: Processing (5 workers)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Worker 1: ← Processing job 1
Worker 2: ← Processing job 2
Worker 3: ← Processing job 3
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stage 3: Results Collection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Job 1 completed: result=42
✓ Job 2 completed: result=37
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Jobs:          50
Total Time:          2.5s
Throughput:          20 jobs/sec
Channel Utilization: 85%
Peak Buffer:         8/10
```

### Implementation Requirements

**Project Structure**:
```
lesson-20-channels/
├── main.go                  # CLI entry point
├── pipeline/
│   ├── pipeline.go          # Pipeline orchestration
│   ├── generator.go         # Job generation stage
│   ├── processor.go         # Processing stage with workers
│   └── collector.go         # Results collection stage
├── channel/
│   ├── monitor.go           # Channel operation monitoring
│   └── benchmark.go         # Performance comparison
├── display/
│   ├── styles.go            # Lip Gloss styles
│   └── visualizer.go        # Real-time visualization
└── main_test.go
```

**Pipeline Stages**:
1. **Generation**: Create jobs and send to processing channel
2. **Processing**: Worker pool consumes jobs, performs work, sends results
3. **Collection**: Aggregate results and compute statistics
4. **Monitoring**: Track channel buffer utilization and throughput

**Channel Types to Demonstrate**:
- Unbuffered channels for synchronization
- Buffered channels for job queues
- Send-only channels for producers
- Receive-only channels for consumers
- Error channels for failure propagation

**Monitoring Requirements**:
- Track send/receive operations
- Measure buffer utilization
- Calculate throughput
- Detect blocking operations
- Display real-time statistics

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestChannelOperations(t *testing.T) {
    tests := []struct {
        name         string
        bufferSize   int
        numJobs      int
        numWorkers   int
        wantDuration time.Duration
        wantAllDone  bool
    }{
        {
            name:         "Unbuffered channel",
            bufferSize:   0,
            numJobs:      10,
            numWorkers:   2,
            wantDuration: 1 * time.Second,
            wantAllDone:  true,
        },
        {
            name:         "Small buffer",
            bufferSize:   5,
            numJobs:      20,
            numWorkers:   3,
            wantDuration: 2 * time.Second,
            wantAllDone:  true,
        },
        {
            name:         "Large buffer",
            bufferSize:   100,
            numJobs:      50,
            numWorkers:   5,
            wantDuration: 3 * time.Second,
            wantAllDone:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            jobs := make(chan Job, tt.bufferSize)
            results := make(chan Result, tt.bufferSize)

            start := time.Now()
            completed := runPipeline(jobs, results, tt.numJobs, tt.numWorkers)
            elapsed := time.Since(start)

            if completed != tt.numJobs {
                t.Errorf("completed = %d, want %d", completed, tt.numJobs)
            }

            if tt.wantAllDone && completed != tt.numJobs {
                t.Errorf("not all jobs completed: %d/%d", completed, tt.numJobs)
            }

            if elapsed > tt.wantDuration*2 {
                t.Errorf("took too long: %v (expected ~%v)", elapsed, tt.wantDuration)
            }
        })
    }
}
```

### Required Test Coverage

| Test Category | Test Cases | Purpose |
|---------------|------------|---------|
| **Channel Creation** | 4+ | Verify buffered/unbuffered channels |
| **Send/Receive** | 6+ | Test blocking behavior and values |
| **Channel Closing** | 5+ | Proper close detection and handling |
| **Producer-Consumer** | 5+ | Single and multiple producer patterns |
| **Worker Pools** | 4+ | Job distribution across workers |
| **Channel Directions** | 3+ | Send-only and receive-only safety |
| **Performance** | 3+ | Buffered vs unbuffered comparison |

### Specific Test Scenarios

**Channel Closing Detection**:
```go
func TestChannelClosing(t *testing.T) {
    ch := make(chan int, 2)
    ch <- 1
    ch <- 2
    close(ch)

    // Should receive buffered values first
    val, ok := <-ch
    if val != 1 || !ok {
        t.Errorf("first receive: got (%d, %v), want (1, true)", val, ok)
    }

    val, ok = <-ch
    if val != 2 || !ok {
        t.Errorf("second receive: got (%d, %v), want (2, true)", val, ok)
    }

    // Then indicate closed
    val, ok = <-ch
    if val != 0 || ok {
        t.Errorf("closed receive: got (%d, %v), want (0, false)", val, ok)
    }
}
```

**Producer-Consumer Correctness**:
```go
func TestProducerConsumer(t *testing.T) {
    const numItems = 100
    ch := make(chan int, 10)

    // Producer
    go func() {
        defer close(ch)
        for i := 0; i < numItems; i++ {
            ch <- i
        }
    }()

    // Consumer
    sum := 0
    for val := range ch {
        sum += val
    }

    expectedSum := numItems * (numItems - 1) / 2
    if sum != expectedSum {
        t.Errorf("sum = %d, want %d", sum, expectedSum)
    }
}
```

**Worker Pool Load Distribution**:
```go
func TestWorkerPoolDistribution(t *testing.T) {
    const numWorkers = 5
    const numJobs = 100

    jobs := make(chan int, numJobs)
    results := make(chan int, numJobs)
    workerCounts := make([]int, numWorkers)
    var mu sync.Mutex

    // Start workers
    for w := 0; w < numWorkers; w++ {
        go func(id int) {
            for job := range jobs {
                mu.Lock()
                workerCounts[id]++
                mu.Unlock()
                results <- job * 2
            }
        }(w)
    }

    // Send jobs
    for j := 0; j < numJobs; j++ {
        jobs <- j
    }
    close(jobs)

    // Collect results
    for r := 0; r < numJobs; r++ {
        <-results
    }

    // Verify reasonable distribution (each worker got some jobs)
    for i, count := range workerCounts {
        if count == 0 {
            t.Errorf("worker %d did no work", i)
        }
        t.Logf("Worker %d: %d jobs", i, count)
    }
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Flags**:
```go
var (
    workers     = flag.Int("workers", 3, "Number of worker goroutines")
    bufferSize  = flag.Int("buffer", 10, "Channel buffer size")
    numJobs     = flag.Int("jobs", 50, "Number of jobs to process")
    benchmark   = flag.Bool("benchmark", false, "Run performance benchmark")
    visualize   = flag.Bool("visualize", false, "Real-time visualization")
    iterations  = flag.Int("iterations", 10000, "Benchmark iterations")
)
```

### Expected Output Formats

**Standard Execution**:
```
Pipeline Processing System v1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  Workers:     3
  Buffer Size: 10
  Jobs:        50

Starting pipeline...

Stage 1: Generation    [████████████████████████████████████] 100%
Stage 2: Processing    [████████████████████████████████████] 100%
Stage 3: Collection    [████████████████████████████████████] 100%

Results:
  ✓ All 50 jobs completed successfully
  ⏱  Total time: 2.5s
  🚀 Throughput: 20 jobs/sec
  📊 Peak buffer utilization: 8/10 (80%)
```

**Benchmark Mode**:
```
Channel Performance Benchmark
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Unbuffered Channel:
  Operations: 10,000
  Time:       145ms
  Rate:       68,965 ops/sec

Buffered Channel (10):
  Operations: 10,000
  Time:       52ms
  Rate:       192,307 ops/sec
  Speedup:    2.79x

Buffered Channel (100):
  Operations: 10,000
  Time:       38ms
  Rate:       263,157 ops/sec
  Speedup:    3.82x

Analysis:
  ✓ Buffer size 10 provides best balance
  ℹ  Diminishing returns above size 50
  ℹ  Memory overhead: 96 + (buffer_size * 8) bytes
```

**Visualization Mode**:
```
Real-Time Channel Operations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Jobs Channel:      [████░░░░░░] 4/10 buffered
Results Channel:   [██████░░░░] 6/10 buffered

Recent Operations:
→ Worker 1: Sent result 23
← Worker 2: Received job 24
→ Worker 3: Sent result 25

Statistics:
  Sends:    127
  Receives: 125
  Blocked:  3 operations
  Throughput: 15 ops/sec
```

### Error Handling Output

```go
// Channel error propagation
type ErrorResult struct {
    Job   Job
    Error error
}

func displayErrors(errors <-chan ErrorResult) {
    errorStyle := lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Bold(true)

    for err := range errors {
        msg := fmt.Sprintf("✗ Job %d failed: %v", err.Job.ID, err.Error)
        fmt.Println(errorStyle.Render(msg))
    }
}
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] Pipeline processes all jobs successfully
- [ ] Buffered and unbuffered channels work correctly
- [ ] Worker pool distributes load evenly
- [ ] All channels closed properly (no leaks)
- [ ] Producer-consumer pattern implemented correctly
- [ ] Channel directions enforced (send-only, receive-only)
- [ ] Error propagation through error channels

### Code Quality ✅

- [ ] All code passes `go fmt` (formatting)
- [ ] All code passes `go vet` (correctness)
- [ ] All code passes `staticcheck` (style)
- [ ] No race conditions detected (`go test -race`)
- [ ] Channel operations clearly documented
- [ ] Proper use of defer for closing channels
- [ ] Comments explain synchronization points

### Testing ✅

- [ ] Table-driven tests for channel operations
- [ ] Test coverage >80% (`go test -cover`)
- [ ] Race condition testing passes (`go test -race`)
- [ ] Producer-consumer correctness tests
- [ ] Worker pool distribution tests
- [ ] Channel closing detection tests
- [ ] Performance benchmark tests

### Documentation ✅

- [ ] README explains channel patterns used
- [ ] Function comments describe channel behavior
- [ ] Examples demonstrate buffered vs unbuffered
- [ ] Performance characteristics documented
- [ ] Buffer size selection guidelines

### Performance ✅

- [ ] Buffered channels outperform unbuffered for high throughput
- [ ] Worker pool scales with available cores
- [ ] No channel blocking under normal load
- [ ] Memory usage proportional to buffer size
- [ ] Graceful degradation under overload

---

## Common Pitfalls

### ❌ Pitfall 1: Closing Channels from Receiver

**Wrong**:
```go
func consumer(ch chan int) {
    for val := range ch {
        process(val)
    }
    close(ch)  // WRONG: Receiver closing channel
}

func producer(ch chan int) {
    for i := 0; i < 10; i++ {
        ch <- i  // May panic if consumer closes channel
    }
}
```

**Right**:
```go
func producer(ch chan<- int) {
    defer close(ch)  // RIGHT: Sender closes channel
    for i := 0; i < 10; i++ {
        ch <- i
    }
}

func consumer(ch <-chan int) {
    for val := range ch {  // Range exits when producer closes
        process(val)
    }
}
```

**Why**: Only the sender knows when no more values will be sent. Closing from receiver causes send panics.

---

### ❌ Pitfall 2: Sending on Closed Channel

**Wrong**:
```go
ch := make(chan int, 5)
close(ch)
ch <- 42  // Panic: send on closed channel
```

**Right**:
```go
ch := make(chan int, 5)

go func() {
    defer close(ch)
    for i := 0; i < 10; i++ {
        ch <- i  // Safe: channel still open
    }
    // Channel closes after all sends
}()

for val := range ch {
    fmt.Println(val)
}
```

**Why**: Sending on a closed channel always panics. Ensure channel is open before sending.

---

### ❌ Pitfall 3: Deadlock from Unbuffered Channel

**Wrong**:
```go
func main() {
    ch := make(chan int)
    ch <- 42  // Deadlock! No receiver ready
    fmt.Println(<-ch)
}
```

**Right**:
```go
func main() {
    ch := make(chan int)

    go func() {
        ch <- 42  // Send in goroutine
    }()

    fmt.Println(<-ch)  // Receive in main
}

// Or use buffered channel
func mainBuffered() {
    ch := make(chan int, 1)
    ch <- 42  // Doesn't block (buffer has space)
    fmt.Println(<-ch)
}
```

**Why**: Unbuffered channel send blocks until receiver is ready. Must happen in different goroutines or use buffered channel.

---

### ❌ Pitfall 4: Ignoring Closed Channel Detection

**Wrong**:
```go
func process(ch <-chan int) {
    for {
        val := <-ch  // Receives zero value forever after close
        if val == 0 {
            break  // WRONG: Can't distinguish zero from closed
        }
        fmt.Println(val)
    }
}
```

**Right**:
```go
func process(ch <-chan int) {
    for {
        val, ok := <-ch
        if !ok {
            break  // RIGHT: Channel closed
        }
        fmt.Println(val)
    }
}

// Or use range (cleaner)
func processRange(ch <-chan int) {
    for val := range ch {  // Automatically exits on close
        fmt.Println(val)
    }
}
```

**Why**: After close, receive returns zero value and false. Always check the ok value or use range.

---

### ❌ Pitfall 5: Multiple Goroutines Closing Same Channel

**Wrong**:
```go
func worker(ch chan int, done chan bool) {
    process()
    close(ch)  // PANIC if multiple workers close same channel!
    done <- true
}

func main() {
    ch := make(chan int)
    done := make(chan bool)

    for i := 0; i < 5; i++ {
        go worker(ch, done)  // All try to close ch
    }

    for i := 0; i < 5; i++ {
        <-done
    }
}
```

**Right**:
```go
func worker(ch chan int, done chan bool) {
    process()
    done <- true  // Signal completion, don't close
}

func main() {
    ch := make(chan int)
    done := make(chan bool)

    for i := 0; i < 5; i++ {
        go worker(ch, done)
    }

    // Coordinator closes channel
    go func() {
        for i := 0; i < 5; i++ {
            <-done
        }
        close(ch)  // Safe: single closer
    }()
}
```

**Why**: Closing a closed channel panics. Only one goroutine should close a channel.

---

### ❌ Pitfall 6: Wrong Buffer Size

**Wrong**:
```go
// Too small: Defeats purpose
ch := make(chan int, 1)
for i := 0; i < 1000; i++ {
    ch <- i  // Blocks constantly
}

// Too large: Wastes memory
ch := make(chan int, 1000000)
for i := 0; i < 10; i++ {
    ch <- i  // 999,990 slots wasted
}
```

**Right**:
```go
// Based on workload characteristics
numWorkers := runtime.NumCPU()
ch := make(chan int, numWorkers*2)  // 2x workers for smoothing

// Or based on expected burst
maxBurst := 100
ch := make(chan int, maxBurst)

// Or match producer/consumer
numProducers := 5
ch := make(chan int, numProducers)  // One slot per producer
```

**Why**: Buffer size affects memory and performance. Choose based on workload, not arbitrary values.

---

## Extension Challenges

### Extension 1: Pipeline Cancellation with Done Channel ⭐⭐

Implement graceful pipeline cancellation:

```go
type Pipeline struct {
    jobs    chan Job
    results chan Result
    done    chan struct{}
}

func NewPipeline(bufferSize int) *Pipeline {
    return &Pipeline{
        jobs:    make(chan Job, bufferSize),
        results: make(chan Result, bufferSize),
        done:    make(chan struct{}),
    }
}

func (p *Pipeline) worker(id int) {
    for {
        select {
        case job, ok := <-p.jobs:
            if !ok {
                return  // Jobs channel closed
            }
            // Process job
            p.results <- process(job)

        case <-p.done:
            return  // Cancellation signal
        }
    }
}

func (p *Pipeline) Stop() {
    close(p.done)  // Signal all workers to stop
    close(p.jobs)
}

// Usage
func main() {
    pipeline := NewPipeline(10)

    // Start workers
    for i := 0; i < 5; i++ {
        go pipeline.worker(i)
    }

    // Send jobs...

    // Graceful shutdown
    time.AfterFunc(5*time.Second, func() {
        pipeline.Stop()
    })
}
```

**Learning Goal**: Graceful shutdown patterns using channels as signals.

---

### Extension 2: Fan-Out, Fan-In Pattern ⭐⭐⭐

Implement fan-out (distribute work) and fan-in (collect results):

```go
func fanOut(input <-chan int, workers int) []<-chan int {
    outputs := make([]<-chan int, workers)

    for i := 0; i < workers; i++ {
        output := make(chan int)
        outputs[i] = output

        go func(out chan<- int) {
            defer close(out)
            for val := range input {
                out <- val * 2  // Process
            }
        }(output)
    }

    return outputs
}

func fanIn(inputs ...<-chan int) <-chan int {
    output := make(chan int)
    var wg sync.WaitGroup

    for _, input := range inputs {
        wg.Add(1)
        go func(ch <-chan int) {
            defer wg.Done()
            for val := range ch {
                output <- val
            }
        }(input)
    }

    go func() {
        wg.Wait()
        close(output)
    }()

    return output
}

// Usage
func main() {
    input := make(chan int)

    // Generate numbers
    go func() {
        defer close(input)
        for i := 0; i < 100; i++ {
            input <- i
        }
    }()

    // Fan-out to 5 workers
    workers := fanOut(input, 5)

    // Fan-in results
    results := fanIn(workers...)

    // Consume
    for result := range results {
        fmt.Println(result)
    }
}
```

**Learning Goal**: Advanced channel patterns for parallel processing.

---

### Extension 3: Channel-Based Semaphore ⭐⭐⭐

Implement a semaphore using buffered channels:

```go
type Semaphore struct {
    slots chan struct{}
}

func NewSemaphore(maxConcurrent int) *Semaphore {
    return &Semaphore{
        slots: make(chan struct{}, maxConcurrent),
    }
}

func (s *Semaphore) Acquire() {
    s.slots <- struct{}{}  // Block if at capacity
}

func (s *Semaphore) Release() {
    <-s.slots  // Free a slot
}

// Usage
func main() {
    sem := NewSemaphore(3)  // Max 3 concurrent operations

    for i := 0; i < 10; i++ {
        go func(id int) {
            sem.Acquire()
            defer sem.Release()

            fmt.Printf("Worker %d: started\n", id)
            time.Sleep(1 * time.Second)
            fmt.Printf("Worker %d: finished\n", id)
        }(i)
    }

    time.Sleep(5 * time.Second)
}
```

**Learning Goal**: Using channels as synchronization primitives beyond communication.

---

### Extension 4: Priority Queue with Channels ⭐⭐⭐⭐

Implement a priority-based job processing system:

```go
type PriorityJob struct {
    ID       int
    Priority int  // Lower number = higher priority
    Data     string
}

type PriorityQueue struct {
    high   chan PriorityJob
    medium chan PriorityJob
    low    chan PriorityJob
}

func NewPriorityQueue(bufferSize int) *PriorityQueue {
    return &PriorityQueue{
        high:   make(chan PriorityJob, bufferSize),
        medium: make(chan PriorityJob, bufferSize),
        low:    make(chan PriorityJob, bufferSize),
    }
}

func (pq *PriorityQueue) Submit(job PriorityJob) {
    switch {
    case job.Priority <= 1:
        pq.high <- job
    case job.Priority <= 5:
        pq.medium <- job
    default:
        pq.low <- job
    }
}

func (pq *PriorityQueue) worker() {
    for {
        select {
        case job := <-pq.high:
            processJob(job)
        default:
            select {
            case job := <-pq.medium:
                processJob(job)
            default:
                select {
                case job := <-pq.low:
                    processJob(job)
                case <-time.After(100 * time.Millisecond):
                    // Idle
                }
            }
        }
    }
}

func processJob(job PriorityJob) {
    fmt.Printf("Processing job %d (priority %d)\n", job.ID, job.Priority)
    time.Sleep(100 * time.Millisecond)
}

// Usage
func main() {
    pq := NewPriorityQueue(10)

    // Start workers
    for i := 0; i < 3; i++ {
        go pq.worker()
    }

    // Submit mixed priority jobs
    pq.Submit(PriorityJob{ID: 1, Priority: 5, Data: "medium"})
    pq.Submit(PriorityJob{ID: 2, Priority: 1, Data: "high"})
    pq.Submit(PriorityJob{ID: 3, Priority: 10, Data: "low"})

    time.Sleep(5 * time.Second)
}
```

**Learning Goal**: Complex channel orchestration with priority handling.

---

### Extension 5: Real-Time Channel Profiler ⭐⭐⭐⭐

Build a profiler that tracks channel operations:

```go
type ChannelStats struct {
    Sends       int64
    Receives    int64
    Blocks      int64
    BufferUsage []int
    mu          sync.Mutex
}

type MonitoredChannel struct {
    ch    chan int
    stats *ChannelStats
}

func NewMonitored(bufferSize int) *MonitoredChannel {
    return &MonitoredChannel{
        ch:    make(chan int, bufferSize),
        stats: &ChannelStats{BufferUsage: make([]int, 0)},
    }
}

func (mc *MonitoredChannel) Send(val int) {
    mc.stats.mu.Lock()
    mc.stats.Sends++
    currentBuffer := len(mc.ch)
    mc.stats.BufferUsage = append(mc.stats.BufferUsage, currentBuffer)
    mc.stats.mu.Unlock()

    mc.ch <- val
}

func (mc *MonitoredChannel) Receive() int {
    mc.stats.mu.Lock()
    mc.stats.Receives++
    mc.stats.mu.Unlock()

    return <-mc.ch
}

func (mc *MonitoredChannel) Report() {
    mc.stats.mu.Lock()
    defer mc.stats.mu.Unlock()

    avgBuffer := 0
    if len(mc.stats.BufferUsage) > 0 {
        sum := 0
        for _, usage := range mc.stats.BufferUsage {
            sum += usage
        }
        avgBuffer = sum / len(mc.stats.BufferUsage)
    }

    fmt.Printf("Channel Statistics:\n")
    fmt.Printf("  Sends:    %d\n", mc.stats.Sends)
    fmt.Printf("  Receives: %d\n", mc.stats.Receives)
    fmt.Printf("  Avg Buffer: %d\n", avgBuffer)
}
```

**Learning Goal**: Performance monitoring and profiling for channel-based systems.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear separation: channel creation vs usage vs closing
- Reusable patterns (producer-consumer, worker pool, pipeline)
- Proper channel direction types (send-only, receive-only)
- No channel leaks (all channels eventually closed)

**Channel Patterns**:
- Use defer close(ch) for reliability
- Only sender closes channels
- Check closed state with comma-ok idiom
- Use range for automatic close handling

**Testing Approach**:
- Table-driven tests for different buffer sizes
- Race condition detection (`go test -race`)
- Deadlock detection (tests should complete)
- Performance benchmarks comparing buffered vs unbuffered

**Documentation**:
- Explain channel capacity choices
- Document goroutine communication flow
- Clarify ownership (who closes channel)
- Note synchronization guarantees

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

**Approach 1: Unbuffered for Synchronization**:
```go
func synchronizedWork() {
    done := make(chan bool)  // Unbuffered

    go func() {
        performWork()
        done <- true  // Blocks until main receives
    }()

    <-done  // Wait for completion
}
```

**Approach 2: Buffered for Throughput**:
```go
func highThroughput() {
    jobs := make(chan Job, 100)  // Buffered

    // Producer doesn't block until buffer full
    go func() {
        for i := 0; i < 1000; i++ {
            jobs <- Job{ID: i}
        }
        close(jobs)
    }()

    // Consumer processes at its own pace
    for job := range jobs {
        process(job)
    }
}
```

Both are valid; unbuffered for tight synchronization, buffered for decoupling.

### Performance Expectations

- Buffered channels faster for high-throughput scenarios
- Unbuffered channels provide stronger synchronization guarantees
- Channel overhead acceptable for most use cases (~100ns per operation)
- Worker pools should scale linearly with cores (up to GOMAXPROCS)
- No channel leaks (verify with runtime.NumGoroutine)

---

## Learning Resources

### Official Go Documentation
- [Effective Go: Channels](https://go.dev/doc/effective_go#channels)
- [Go Tour: Channels](https://go.dev/tour/concurrency/2)
- [Go Blog: Share Memory By Communicating](https://go.dev/blog/codelab-share)
- [Go Blog: Go Concurrency Patterns: Pipelines](https://go.dev/blog/pipelines)

### Articles and Tutorials
- [Go by Example: Channels](https://gobyexample.com/channels)
- [Channel Axioms](https://dave.cheney.net/2014/03/19/channel-axioms) by Dave Cheney
- [Understanding Channels](https://go101.org/article/channel.html)
- [Channel Use Cases](https://go101.org/article/channel-use-cases.html)

### Books
- *The Go Programming Language* (Chapter 8: Goroutines and Channels)
- *Concurrency in Go* by Katherine Cox-Buday (Chapters 3-4)
- *Go in Action* (Chapter 6: Concurrency patterns)

### Video Resources
- [GopherCon 2017: Kavya Joshi - Understanding Channels](https://www.youtube.com/watch?v=KBZlN0izeiY)
- [JustForFunc: Understanding nil channels](https://www.youtube.com/watch?v=tf6cR5Cj3cg)

### Related Charm.sh
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Terminal styling for visualizations
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - Uses channels internally (Phase 5)

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
go run main.go

# Specify parameters
go run main.go --workers 5 --buffer 10 --jobs 50

# Run benchmark
go run main.go --benchmark --iterations 10000

# Visualize operations
go run main.go --visualize --jobs 20

# Performance profiling
go test -bench=. -benchmem ./...
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestChannelOperations
=== RUN   TestChannelOperations/Unbuffered_channel
=== RUN   TestChannelOperations/Small_buffer
=== RUN   TestChannelOperations/Large_buffer
--- PASS: TestChannelOperations (3.25s)
    --- PASS: TestChannelOperations/Unbuffered_channel (1.05s)
    --- PASS: TestChannelOperations/Small_buffer (1.08s)
    --- PASS: TestChannelOperations/Large_buffer (1.12s)
=== RUN   TestChannelClosing
--- PASS: TestChannelClosing (0.01s)
=== RUN   TestProducerConsumer
--- PASS: TestProducerConsumer (0.15s)
=== RUN   TestWorkerPoolDistribution
--- PASS: TestWorkerPoolDistribution (0.52s)
    worker_test.go:45: Worker 0: 21 jobs
    worker_test.go:45: Worker 1: 19 jobs
    worker_test.go:45: Worker 2: 20 jobs
    worker_test.go:45: Worker 3: 22 jobs
    worker_test.go:45: Worker 4: 18 jobs
PASS
coverage: 87.5% of statements
ok      lesson20    3.935s
```

### Race Detection Output

```bash
$ go test -race ./...
PASS
ok      lesson20    4.125s
```

*If race detected:*
```bash
==================
WARNING: DATA RACE
Read at 0x00c0001a0080 by goroutine 8:
  lesson20.worker()
      /path/to/file.go:25 +0x88

Previous write at 0x00c0001a0080 by goroutine 7:
  lesson20.worker()
      /path/to/file.go:25 +0xa4
==================
```

---

**Previous Lesson**: [Lesson 19: Introduction to Goroutines](lesson-19-goroutines-intro.md) (Phase 4)
**Next Lesson**: Lesson 21: Channel Patterns - Select, Timeouts, Closing (Phase 4)
**Phase 4 Milestone**: Lesson 24: Concurrent Web Crawler with Context

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
