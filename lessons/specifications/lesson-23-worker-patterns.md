# Lesson 23: Worker Pools & Pipeline Patterns

**Phase**: 4 - Concurrency Fundamentals
**Estimated Time**: 4-5 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-22 (All Concurrency Fundamentals - Goroutines, Channels, Select, Sync Package)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Design worker pool architectures** - Implement fixed-size worker pools to control concurrent resource usage and prevent goroutine explosion
2. **Build multi-stage pipelines** - Create data processing pipelines with fan-out/fan-in patterns for efficient concurrent workflows
3. **Implement rate limiting** - Control throughput using token bucket, leaky bucket, and time-based limiting patterns
4. **Handle backpressure** - Design systems that gracefully handle producer-consumer speed mismatches without dropping data
5. **Coordinate graceful shutdown** - Implement clean termination patterns that allow in-flight work to complete before exit
6. **Propagate errors in pipelines** - Handle and communicate errors across pipeline stages without blocking
7. **Apply production patterns** - Use worker pools and pipelines in real-world scenarios (file processing, API clients, download managers)
8. **Bridge concurrent styling** - Combine Phase 4 concurrency with Phase 3 Lip Gloss for beautiful concurrent output

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (syntax, functions, structs, interfaces, error handling)
- **Phase 2**: CLI development (flag parsing, file I/O)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout)
- **Lesson 19**: Goroutines (creation, lifecycle, scheduling)
- **Lesson 20**: Channels (unbuffered, buffered, closing)
- **Lesson 21**: Channel patterns (select, timeouts, range)
- **Lesson 22**: Sync package (WaitGroup, Mutex, Once)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-23-worker-patterns
cd ~/go-learning/lesson-23-worker-patterns

# Initialize module
go mod init lesson23

# Install dependencies
go get github.com/charmbracelet/lipgloss@latest
go get golang.org/x/time/rate@latest  # For rate limiting
```

### Conceptual Preparation
- Review Lesson 19 (Goroutines) - worker pools manage goroutine lifecycles
- Review Lesson 20 (Channels) - pipelines connect stages via channels
- Review Lesson 21 (Select/Timeouts) - graceful shutdown requires select patterns
- Review Lesson 22 (WaitGroup) - coordination of worker completion

---

## Core Concepts

### 1. Worker Pool Pattern

**Definition**: A worker pool is a fixed-size set of goroutines that process jobs from a shared queue, preventing unbounded goroutine creation while maximizing throughput.

**Key Characteristics**:
- **Fixed concurrency**: Limits number of concurrent operations
- **Job queue**: Channel-based task distribution
- **Worker reuse**: Goroutines process multiple jobs over their lifetime
- **Graceful shutdown**: Workers complete current jobs before exit

**Why Use Worker Pools**:
```go
// ❌ Unbounded goroutine creation (risky)
func processFilesUnbounded(files []string) {
    for _, file := range files {
        go processFile(file)  // Could create millions of goroutines!
    }
}

// ✅ Worker pool (controlled)
func processFilesPooled(files []string, numWorkers int) {
    jobs := make(chan string, len(files))

    // Start fixed number of workers
    var wg sync.WaitGroup
    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go worker(&wg, jobs)
    }

    // Queue jobs
    for _, file := range files {
        jobs <- file
    }
    close(jobs)

    wg.Wait()  // Wait for all workers to finish
}

func worker(wg *sync.WaitGroup, jobs <-chan string) {
    defer wg.Done()
    for file := range jobs {
        processFile(file)
    }
}
```

**Basic Worker Pool Implementation**:
```go
type WorkerPool struct {
    numWorkers int
    jobs       chan Job
    results    chan Result
    wg         sync.WaitGroup
}

type Job struct {
    ID   int
    Data interface{}
}

type Result struct {
    JobID int
    Value interface{}
    Err   error
}

func NewWorkerPool(numWorkers, queueSize int) *WorkerPool {
    return &WorkerPool{
        numWorkers: numWorkers,
        jobs:       make(chan Job, queueSize),
        results:    make(chan Result, queueSize),
    }
}

func (wp *WorkerPool) Start() {
    for i := 0; i < wp.numWorkers; i++ {
        wp.wg.Add(1)
        go wp.worker(i)
    }
}

func (wp *WorkerPool) worker(id int) {
    defer wp.wg.Done()

    for job := range wp.jobs {
        // Process job
        result := process(job)
        wp.results <- result
    }
}

func (wp *WorkerPool) Submit(job Job) {
    wp.jobs <- job
}

func (wp *WorkerPool) Shutdown() {
    close(wp.jobs)     // Signal no more jobs
    wp.wg.Wait()       // Wait for workers to finish
    close(wp.results)  // Close results channel
}
```

### 2. Pipeline Pattern

**Definition**: A pipeline is a series of stages connected by channels, where each stage processes data and passes results to the next stage. Enables concurrent, composable data transformations.

**Pipeline Architecture**:
```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│ Source  │──┬──>│ Stage 1 │──┬──>│ Stage 2 │──┬──>│  Sink   │
└─────────┘  │   └─────────┘  │   └─────────┘  │   └─────────┘
             │                 │                 │
         (channel)         (channel)         (channel)
```

**Basic Pipeline Pattern**:
```go
// Generator stage: produces data
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

// Processor stage: transforms data
func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

// Consumer stage: consumes results
func consume(in <-chan int) {
    for n := range in {
        fmt.Println(n)
    }
}

// Usage: chaining pipeline stages
func main() {
    // Input -> Square -> Output
    numbers := generate(1, 2, 3, 4, 5)
    squares := square(numbers)
    consume(squares)
}
```

**Fan-Out Pattern** (one input, multiple processors):
```go
func fanOut(in <-chan int, numWorkers int) []<-chan int {
    outputs := make([]<-chan int, numWorkers)

    for i := 0; i < numWorkers; i++ {
        outputs[i] = square(in)  // Multiple workers processing same input
    }

    return outputs
}
```

**Fan-In Pattern** (multiple inputs, one output):
```go
func fanIn(channels ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup

    // Start goroutine for each input channel
    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for n := range c {
                out <- n
            }
        }(ch)
    }

    // Close output when all inputs done
    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

// Usage: fan-out then fan-in
func main() {
    in := generate(1, 2, 3, 4, 5)

    // Fan-out: split work across 3 workers
    workers := fanOut(in, 3)

    // Fan-in: merge results
    out := fanIn(workers...)

    consume(out)
}
```

### 3. Rate Limiting Patterns

**Why Rate Limiting**:
- Prevent overwhelming downstream services
- Control resource consumption (network, disk, CPU)
- Comply with API rate limits
- Implement backpressure

**Token Bucket Pattern**:
```go
import (
    "context"
    "golang.org/x/time/rate"
    "time"
)

// Using golang.org/x/time/rate
func rateLimitedWorker(limiter *rate.Limiter, jobs <-chan Job) {
    for job := range jobs {
        // Wait for rate limiter permission
        if err := limiter.Wait(context.Background()); err != nil {
            fmt.Println("Rate limiter error:", err)
            return
        }

        processJob(job)
    }
}

func main() {
    // Allow 10 requests per second with burst of 5
    limiter := rate.NewLimiter(rate.Limit(10), 5)

    jobs := make(chan Job, 100)

    // Start rate-limited worker
    go rateLimitedWorker(limiter, jobs)

    // Submit jobs (will be throttled)
    for i := 0; i < 100; i++ {
        jobs <- Job{ID: i}
    }
    close(jobs)
}
```

**Time-Based Rate Limiting**:
```go
func rateLimitWithTicker(jobs <-chan Job, rps int) {
    ticker := time.NewTicker(time.Second / time.Duration(rps))
    defer ticker.Stop()

    for job := range jobs {
        <-ticker.C  // Wait for next tick
        processJob(job)
    }
}
```

**Sliding Window Rate Limiter**:
```go
type RateLimiter struct {
    requests []time.Time
    limit    int
    window   time.Duration
    mu       sync.Mutex
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
    return &RateLimiter{
        requests: make([]time.Time, 0),
        limit:    limit,
        window:   window,
    }
}

func (rl *RateLimiter) Allow() bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    now := time.Now()
    cutoff := now.Add(-rl.window)

    // Remove old requests outside window
    validRequests := make([]time.Time, 0)
    for _, req := range rl.requests {
        if req.After(cutoff) {
            validRequests = append(validRequests, req)
        }
    }
    rl.requests = validRequests

    // Check if under limit
    if len(rl.requests) < rl.limit {
        rl.requests = append(rl.requests, now)
        return true
    }

    return false
}
```

### 4. Backpressure Handling

**Definition**: Backpressure is the mechanism to handle situations where producers generate data faster than consumers can process it.

**Buffered Channels for Buffering**:
```go
// Small buffer: low latency, risk of blocking
jobs := make(chan Job, 10)

// Large buffer: absorbs bursts, higher memory usage
jobs := make(chan Job, 10000)

// Unbuffered: immediate backpressure
jobs := make(chan Job)
```

**Dropping Pattern** (non-blocking send):
```go
func sendNonBlocking(jobs chan<- Job, job Job) bool {
    select {
    case jobs <- job:
        return true  // Sent successfully
    default:
        return false  // Channel full, job dropped
    }
}
```

**Timeout Pattern** (bounded wait):
```go
func sendWithTimeout(jobs chan<- Job, job Job, timeout time.Duration) error {
    select {
    case jobs <- job:
        return nil
    case <-time.After(timeout):
        return fmt.Errorf("timeout sending job")
    }
}
```

**Dynamic Worker Scaling** (advanced):
```go
type ScalablePool struct {
    jobs        chan Job
    minWorkers  int
    maxWorkers  int
    activeWorkers int
    mu          sync.Mutex
}

func (sp *ScalablePool) adjustWorkers() {
    sp.mu.Lock()
    defer sp.mu.Unlock()

    queueDepth := len(sp.jobs)

    // Scale up if queue is backing up
    if queueDepth > 100 && sp.activeWorkers < sp.maxWorkers {
        go sp.worker()
        sp.activeWorkers++
    }

    // Scale down if queue is empty (implementation left as exercise)
}
```

### 5. Graceful Shutdown

**Why Graceful Shutdown**:
- Complete in-flight work before exit
- Prevent data loss or corruption
- Clean up resources (files, connections)
- Provide user feedback

**Context-Based Shutdown**:
```go
import "context"

func worker(ctx context.Context, jobs <-chan Job, results chan<- Result) {
    for {
        select {
        case <-ctx.Done():
            // Shutdown signal received
            fmt.Println("Worker shutting down gracefully")
            return

        case job, ok := <-jobs:
            if !ok {
                // Jobs channel closed
                return
            }

            // Process job with cancellation check
            result := processWithContext(ctx, job)

            // Attempt to send result, respect cancellation
            select {
            case results <- result:
            case <-ctx.Done():
                return
            }
        }
    }
}

func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    jobs := make(chan Job, 100)
    results := make(chan Result, 100)

    // Start workers
    var wg sync.WaitGroup
    for i := 0; i < 5; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            worker(ctx, jobs, results)
        }()
    }

    // Submit jobs...

    // Initiate shutdown
    close(jobs)      // No more jobs
    cancel()         // Cancel context
    wg.Wait()        // Wait for workers
    close(results)   // Close results
}
```

**Two-Phase Shutdown** (drain then cancel):
```go
type Pool struct {
    jobs    chan Job
    results chan Result
    cancel  context.CancelFunc
    wg      sync.WaitGroup
}

func (p *Pool) ShutdownGraceful(timeout time.Duration) error {
    // Phase 1: Stop accepting new jobs
    close(p.jobs)

    // Phase 2: Wait for completion or timeout
    done := make(chan struct{})
    go func() {
        p.wg.Wait()
        close(done)
    }()

    select {
    case <-done:
        // All workers finished
        close(p.results)
        return nil

    case <-time.After(timeout):
        // Timeout: force cancellation
        p.cancel()
        return fmt.Errorf("shutdown timeout, cancelled remaining work")
    }
}
```

### 6. Error Propagation in Pipelines

**Error Channel Pattern**:
```go
type Result struct {
    Value int
    Err   error
}

func stage(in <-chan int) <-chan Result {
    out := make(chan Result)

    go func() {
        defer close(out)

        for n := range in {
            result, err := process(n)
            out <- Result{Value: result, Err: err}
        }
    }()

    return out
}
```

**Error Group Pattern** (using `golang.org/x/sync/errgroup`):
```go
import (
    "golang.org/x/sync/errgroup"
    "context"
)

func pipeline(ctx context.Context, inputs []int) ([]int, error) {
    g, ctx := errgroup.WithContext(ctx)

    // Stage 1: Generate
    gen := make(chan int)
    g.Go(func() error {
        defer close(gen)
        for _, n := range inputs {
            select {
            case gen <- n:
            case <-ctx.Done():
                return ctx.Err()
            }
        }
        return nil
    })

    // Stage 2: Process
    results := make(chan int)
    g.Go(func() error {
        defer close(results)
        for n := range gen {
            result, err := process(n)
            if err != nil {
                return err  // Error stops pipeline
            }

            select {
            case results <- result:
            case <-ctx.Done():
                return ctx.Err()
            }
        }
        return nil
    })

    // Collect results
    var output []int
    g.Go(func() error {
        for result := range results {
            output = append(output, result)
        }
        return nil
    })

    // Wait for all stages, return first error
    if err := g.Wait(); err != nil {
        return nil, err
    }

    return output, nil
}
```

### 7. Real-World Patterns

**Download Manager with Worker Pool**:
```go
type DownloadManager struct {
    pool     *WorkerPool
    limiter  *rate.Limiter
    progress map[string]*Progress
    mu       sync.Mutex
}

type Download struct {
    URL         string
    Destination string
}

func (dm *DownloadManager) Start(downloads []Download) error {
    ctx := context.Background()

    for _, dl := range downloads {
        // Rate limiting
        if err := dm.limiter.Wait(ctx); err != nil {
            return err
        }

        // Submit to worker pool
        dm.pool.Submit(Job{
            ID:   dl.URL,
            Data: dl,
        })
    }

    return nil
}

func (dm *DownloadManager) worker(id int, jobs <-chan Job) {
    for job := range jobs {
        dl := job.Data.(Download)

        // Track progress
        dm.trackProgress(dl.URL, 0)

        // Perform download
        err := downloadFile(dl.URL, dl.Destination, func(progress int) {
            dm.trackProgress(dl.URL, progress)
        })

        if err != nil {
            dm.trackError(dl.URL, err)
        }
    }
}
```

**File Processor Pipeline**:
```go
func fileProcessorPipeline(files []string, numWorkers int) error {
    // Stage 1: Read files
    fileData := readFiles(files)

    // Stage 2: Fan-out processing
    processors := make([]<-chan ProcessedData, numWorkers)
    for i := 0; i < numWorkers; i++ {
        processors[i] = processData(fileData)
    }

    // Stage 3: Fan-in results
    results := fanIn(processors...)

    // Stage 4: Write results
    return writeResults(results)
}

func readFiles(files []string) <-chan FileData {
    out := make(chan FileData)

    go func() {
        defer close(out)
        for _, file := range files {
            data, err := os.ReadFile(file)
            out <- FileData{Name: file, Content: data, Err: err}
        }
    }()

    return out
}

func processData(in <-chan FileData) <-chan ProcessedData {
    out := make(chan ProcessedData)

    go func() {
        defer close(out)
        for fd := range in {
            if fd.Err != nil {
                out <- ProcessedData{Err: fd.Err}
                continue
            }

            // Transform data
            result := transform(fd.Content)
            out <- ProcessedData{Name: fd.Name, Result: result}
        }
    }()

    return out
}
```

**Rate-Limited API Client**:
```go
type APIClient struct {
    limiter *rate.Limiter
    client  *http.Client
}

func NewAPIClient(requestsPerSecond int) *APIClient {
    return &APIClient{
        limiter: rate.NewLimiter(rate.Limit(requestsPerSecond), 1),
        client:  &http.Client{Timeout: 10 * time.Second},
    }
}

func (ac *APIClient) Get(ctx context.Context, url string) (*Response, error) {
    // Wait for rate limiter
    if err := ac.limiter.Wait(ctx); err != nil {
        return nil, fmt.Errorf("rate limit wait: %w", err)
    }

    // Make request
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := ac.client.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    // Handle rate limit response
    if resp.StatusCode == 429 {
        retryAfter := resp.Header.Get("Retry-After")
        return nil, fmt.Errorf("rate limited, retry after: %s", retryAfter)
    }

    return parseResponse(resp)
}

// Batch processing with worker pool
func (ac *APIClient) BatchGet(ctx context.Context, urls []string, workers int) ([]Response, error) {
    pool := NewWorkerPool(workers, len(urls))
    pool.Start()

    // Submit jobs
    go func() {
        for _, url := range urls {
            pool.Submit(Job{Data: url})
        }
        pool.Shutdown()
    }()

    // Collect results
    var results []Response
    for result := range pool.results {
        if result.Err != nil {
            return nil, result.Err
        }
        results = append(results, result.Value.(Response))
    }

    return results, nil
}
```

### 8. Styling Concurrent Operations (Bridging Phase 3)

**Using Lip Gloss for Pipeline Visualization**:
```go
import (
    "fmt"
    "github.com/charmbracelet/lipgloss"
)

var (
    stageStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("86")).
        Bold(true).
        Padding(0, 1)

    workerStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Prefix("⚙ ")

    progressStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Prefix("▶ ")

    errorStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("196")).
        Bold(true).
        Prefix("✗ ")
)

func visualizePipeline(stages []string) string {
    styledStages := make([]string, len(stages))
    for i, stage := range stages {
        styledStages[i] = stageStyle.Render(stage)
    }

    arrow := lipgloss.NewStyle().
        Foreground(lipgloss.Color("240")).
        Render(" → ")

    return lipgloss.JoinHorizontal(lipgloss.Center,
        lipgloss.JoinHorizontal(lipgloss.Left, styledStages[0], arrow, styledStages[1], arrow, styledStages[2]))
}

func renderWorkerStatus(id int, status string, jobs int) {
    output := lipgloss.JoinVertical(
        lipgloss.Left,
        workerStyle.Render(fmt.Sprintf("Worker %d: %s", id, status)),
        progressStyle.Render(fmt.Sprintf("Processed: %d jobs", jobs)),
    )
    fmt.Println(output)
}

// Dashboard with live updates
func renderDashboard(stats *PoolStats) {
    header := lipgloss.NewStyle().
        Bold(true).
        Foreground(lipgloss.Color("205")).
        Render("Worker Pool Dashboard")

    statsBox := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("62")).
        Padding(1, 2).
        Render(fmt.Sprintf(
            "Active Workers: %d\nQueued Jobs: %d\nCompleted: %d\nErrors: %d",
            stats.ActiveWorkers,
            stats.QueuedJobs,
            stats.Completed,
            stats.Errors,
        ))

    dashboard := lipgloss.JoinVertical(
        lipgloss.Left,
        header,
        "",
        statsBox,
    )

    // Clear screen and render (simple approach)
    fmt.Print("\033[H\033[2J")
    fmt.Println(dashboard)
}
```

### 9. Performance Considerations

**Worker Pool Sizing**:
```go
// CPU-bound: workers = NumCPU
numWorkers := runtime.NumCPU()

// I/O-bound: workers = NumCPU * multiplier (2-10x)
numWorkers := runtime.NumCPU() * 4

// Mixed workload: start with NumCPU, tune based on monitoring
numWorkers := runtime.NumCPU() * 2

// Rate-limited: workers = max concurrent requests allowed
numWorkers := apiRateLimit / requestsPerSecond
```

**Channel Buffer Sizing**:
```go
// No buffering: immediate backpressure
ch := make(chan Job)

// Small buffer: low memory, frequent blocking
ch := make(chan Job, 10)

// Medium buffer: balance memory/throughput
ch := make(chan Job, 100)

// Large buffer: absorb bursts, high memory
ch := make(chan Job, 10000)

// Rule of thumb: buffer = workerCount * avgJobsPerWorker
buffer := numWorkers * 10
ch := make(chan Job, buffer)
```

**Pipeline Optimization**:
- **Minimize allocations**: Reuse objects with `sync.Pool`
- **Batch processing**: Process multiple items per goroutine invocation
- **Avoid deep pipelines**: More stages = more overhead
- **Monitor channel depths**: Identify bottleneck stages

---

## Challenge Description

Build a **Concurrent Download Manager** that demonstrates worker pools, pipelines, rate limiting, and graceful shutdown with styled terminal output.

### Project Overview

Create a CLI application that:
1. Downloads multiple files concurrently using a worker pool
2. Implements rate limiting to respect bandwidth constraints
3. Processes downloads through a multi-stage pipeline (validate → download → checksum)
4. Handles backpressure and errors gracefully
5. Provides real-time progress visualization with Lip Gloss
6. Supports graceful shutdown with in-flight work completion

### Functional Requirements

**Core Features**:
```bash
# Download files with worker pool
go run main.go download --urls urls.txt --workers 5

# Rate-limited downloads
go run main.go download --urls urls.txt --rate-limit 10  # 10 MB/s

# Pipeline mode with checksum verification
go run main.go download --urls urls.txt --pipeline --verify

# Graceful shutdown demo
go run main.go download --urls large-urls.txt --workers 10
# Press Ctrl+C -> waits for in-flight downloads to complete

# Dashboard mode with live updates
go run main.go download --urls urls.txt --dashboard
```

**Expected Output**:
```
╔══════════════════════════════════════════════════════╗
║        Concurrent Download Manager v1.0              ║
╚══════════════════════════════════════════════════════╝

Configuration:
  Workers:       5
  Rate Limit:    10 MB/s
  Queue Size:    100
  Mode:          pipeline

Pipeline: Validate → Download → Checksum

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Active Downloads:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ Worker 1: file1.zip    [████████████░░░░░░░░] 65% (6.5 MB/s)
⚙ Worker 2: file2.tar.gz [████████████████░░░░] 80% (8.2 MB/s)
⚙ Worker 3: file3.iso    [███░░░░░░░░░░░░░░░░░] 15% (7.1 MB/s)
⚙ Worker 4: Idle
⚙ Worker 5: Idle

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Queued:        15 files
In Progress:   3 files
Completed:     12 files
Failed:        0 files
Total Speed:   21.8 MB/s
Avg Speed:     7.3 MB/s/worker
```

### Implementation Requirements

**Project Structure**:
```
lesson-23-worker-patterns/
├── main.go                    # CLI entry point
├── pool/
│   ├── worker_pool.go         # Worker pool implementation
│   ├── pool_test.go           # Worker pool tests
│   └── stats.go               # Statistics tracking
├── pipeline/
│   ├── pipeline.go            # Pipeline stages
│   ├── stages.go              # Stage implementations (validate, download, verify)
│   └── pipeline_test.go       # Pipeline tests
├── limiter/
│   ├── rate_limiter.go        # Rate limiting implementations
│   └── limiter_test.go        # Rate limiter tests
├── download/
│   ├── manager.go             # Download manager
│   ├── downloader.go          # Download logic
│   └── progress.go            # Progress tracking
├── display/
│   ├── styles.go              # Lip Gloss styles
│   ├── dashboard.go           # Real-time dashboard
│   └── renderer.go            # Output rendering
└── shutdown/
    ├── graceful.go            # Graceful shutdown coordination
    └── shutdown_test.go       # Shutdown tests
```

**Worker Pool Requirements**:
- Fixed size (configurable via flag)
- Job queue with configurable buffer
- Worker status tracking (idle, busy, completed jobs)
- Graceful shutdown with timeout
- Error propagation to results channel

**Pipeline Requirements**:
1. **Validate Stage**: Check URL format and accessibility
2. **Download Stage**: Fetch file with progress tracking
3. **Checksum Stage**: Verify integrity (optional)
4. Support fan-out (multiple download workers) and fan-in (collect results)

**Rate Limiting Requirements**:
- Bandwidth limiting (bytes per second)
- Request rate limiting (requests per second)
- Configurable via command-line flags
- Dynamic adjustment based on network conditions

**Graceful Shutdown Requirements**:
- Catch SIGINT/SIGTERM signals
- Stop accepting new jobs
- Wait for in-flight jobs with timeout
- Cancel remaining jobs on timeout
- Clean progress reporting during shutdown

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestWorkerPool(t *testing.T) {
    tests := []struct {
        name       string
        numWorkers int
        numJobs    int
        jobDuration time.Duration
        wantMinTime time.Duration
        wantMaxTime time.Duration
    }{
        {
            name:        "Single worker sequential",
            numWorkers:  1,
            numJobs:     10,
            jobDuration: 10 * time.Millisecond,
            wantMinTime: 95 * time.Millisecond,
            wantMaxTime: 120 * time.Millisecond,
        },
        {
            name:        "Multiple workers parallel",
            numWorkers:  5,
            numJobs:     10,
            jobDuration: 10 * time.Millisecond,
            wantMinTime: 15 * time.Millisecond,
            wantMaxTime: 40 * time.Millisecond,
        },
        {
            name:        "More jobs than workers",
            numWorkers:  3,
            numJobs:     30,
            jobDuration: 10 * time.Millisecond,
            wantMinTime: 95 * time.Millisecond,
            wantMaxTime: 120 * time.Millisecond,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            pool := NewWorkerPool(tt.numWorkers, tt.numJobs)
            pool.Start()

            start := time.Now()

            // Submit jobs
            for i := 0; i < tt.numJobs; i++ {
                pool.Submit(Job{
                    ID: i,
                    Data: tt.jobDuration,
                })
            }

            pool.Shutdown()
            elapsed := time.Since(start)

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
| **Worker Pool** | 8+ | Verify pool creation, job distribution, shutdown |
| **Pipeline Stages** | 6+ | Test each stage independently |
| **Fan-Out/Fan-In** | 4+ | Verify concurrent processing and merging |
| **Rate Limiting** | 5+ | Test various rate limits and burst scenarios |
| **Backpressure** | 4+ | Handle producer-consumer speed mismatch |
| **Graceful Shutdown** | 5+ | Test timeout, cancellation, signal handling |
| **Error Propagation** | 6+ | Ensure errors flow through pipeline |
| **Integration** | 4+ | End-to-end pipeline tests |

### Specific Test Scenarios

**Worker Pool Job Distribution**:
```go
func TestWorkerPoolDistribution(t *testing.T) {
    numWorkers := 5
    numJobs := 100

    pool := NewWorkerPool(numWorkers, numJobs)

    // Track which worker processed each job
    workerJobs := make(map[int]int)
    var mu sync.Mutex

    pool.Start()

    for i := 0; i < numJobs; i++ {
        pool.Submit(Job{
            ID: i,
            Data: func(workerID int) {
                mu.Lock()
                workerJobs[workerID]++
                mu.Unlock()
            },
        })
    }

    pool.Shutdown()

    // Verify all jobs processed
    total := 0
    for _, count := range workerJobs {
        total += count
    }

    if total != numJobs {
        t.Errorf("processed %d jobs, want %d", total, numJobs)
    }

    // Verify reasonable distribution (no worker idle)
    for id, count := range workerJobs {
        if count == 0 {
            t.Errorf("worker %d processed 0 jobs", id)
        }
    }
}
```

**Pipeline Error Handling**:
```go
func TestPipelineErrorPropagation(t *testing.T) {
    // Stage that returns errors for even numbers
    errorStage := func(in <-chan int) <-chan Result {
        out := make(chan Result)
        go func() {
            defer close(out)
            for n := range in {
                if n%2 == 0 {
                    out <- Result{Err: fmt.Errorf("error processing %d", n)}
                } else {
                    out <- Result{Value: n * 2}
                }
            }
        }()
        return out
    }

    // Input
    input := make(chan int, 10)
    for i := 1; i <= 10; i++ {
        input <- i
    }
    close(input)

    // Run pipeline
    results := errorStage(input)

    // Count errors and successes
    errors := 0
    successes := 0

    for result := range results {
        if result.Err != nil {
            errors++
        } else {
            successes++
        }
    }

    if errors != 5 || successes != 5 {
        t.Errorf("errors=%d, successes=%d, want 5 each", errors, successes)
    }
}
```

**Rate Limiter Accuracy**:
```go
func TestRateLimiterAccuracy(t *testing.T) {
    requestsPerSecond := 10
    duration := 1 * time.Second

    limiter := rate.NewLimiter(rate.Limit(requestsPerSecond), 1)
    ctx := context.Background()

    start := time.Now()
    requests := 0

    for time.Since(start) < duration {
        if err := limiter.Wait(ctx); err != nil {
            t.Fatal(err)
        }
        requests++
    }

    // Allow ±10% tolerance
    if requests < 9 || requests > 11 {
        t.Errorf("processed %d requests in 1s, want ~10", requests)
    }
}
```

**Graceful Shutdown Timeout**:
```go
func TestGracefulShutdownTimeout(t *testing.T) {
    pool := NewWorkerPool(5, 100)
    pool.Start()

    // Submit long-running jobs
    for i := 0; i < 10; i++ {
        pool.Submit(Job{
            ID: i,
            Data: 5 * time.Second,  // Longer than shutdown timeout
        })
    }

    // Shutdown with 1 second timeout
    start := time.Now()
    err := pool.ShutdownWithTimeout(1 * time.Second)
    elapsed := time.Since(start)

    // Should timeout, not wait 5 seconds
    if elapsed > 1500*time.Millisecond {
        t.Errorf("shutdown took %v, want ~1s", elapsed)
    }

    if err == nil {
        t.Error("expected timeout error, got nil")
    }
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Flags**:
```go
var (
    urlsFile    = flag.String("urls", "", "File containing URLs to download (one per line)")
    workers     = flag.Int("workers", 5, "Number of concurrent workers")
    rateLimit   = flag.Float64("rate-limit", 0, "Rate limit in MB/s (0 = unlimited)")
    queueSize   = flag.Int("queue", 100, "Job queue buffer size")
    pipeline    = flag.Bool("pipeline", false, "Enable pipeline mode")
    verify      = flag.Bool("verify", false, "Verify checksums after download")
    dashboard   = flag.Bool("dashboard", false, "Show live dashboard")
    timeout     = flag.Duration("timeout", 30*time.Second, "Per-file download timeout")
    gracePeriod = flag.Duration("grace-period", 10*time.Second, "Graceful shutdown timeout")
)
```

### Expected Output Formats

**Standard Mode**:
```
Concurrent Download Manager v1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  Workers:        5
  Rate Limit:     10 MB/s
  Queue Size:     100
  Verify:         enabled

Starting workers...

✓ file1.zip      8.5 MB    2.3s    [✓ checksum verified]
✓ file2.tar.gz   12.1 MB   3.1s    [✓ checksum verified]
✓ file3.iso      650 MB    85.2s   [✓ checksum verified]
✗ file4.bin      Error: connection timeout
✓ file5.pdf      2.1 MB    0.8s    [✓ checksum verified]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Files:      25
Successful:       24
Failed:           1
Total Size:       1.2 GB
Total Time:       2m 15s
Avg Speed:        9.1 MB/s
```

**Dashboard Mode** (live updates):
```
╔══════════════════════════════════════════════════════╗
║        Download Manager Dashboard                    ║
╚══════════════════════════════════════════════════════╝

Pipeline: Validate → Download → Checksum

Workers: 5/5 active          Queue: 12 pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ Worker 1 │ file1.zip    │ [████████████░░░░░░░░] 65%
⚙ Worker 2 │ file2.tar.gz │ [████████████████░░░░] 80%
⚙ Worker 3 │ file3.iso    │ [███░░░░░░░░░░░░░░░░░] 15%
⚙ Worker 4 │ file4.bin    │ [██████████████████░░] 90%
⚙ Worker 5 │ file5.pdf    │ [████████████████████] 100%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Statistics                    Performance
━━━━━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━━━━━━━━━━
Completed:  18 files          Current:   21.8 MB/s
Failed:      0 files          Average:    7.3 MB/s
Downloaded: 850 MB            Peak:      28.5 MB/s
Remaining:  12 files          Efficiency: 87%

Press 'q' to quit, Ctrl+C for graceful shutdown
```

**Graceful Shutdown Output**:
```
^C
Shutdown signal received. Initiating graceful shutdown...

⏳ Waiting for 3 in-flight downloads to complete...
   file1.zip    [████████████████░░░░] 85% - continuing...
   file2.tar.gz [██████████░░░░░░░░░░] 52% - continuing...
   file3.iso    [███░░░░░░░░░░░░░░░░░] 18% - continuing...

✓ file2.tar.gz completed
✓ file1.zip completed

⏰ Shutdown timeout (10s) reached
✗ file3.iso cancelled (18% complete)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Shutdown Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Completed:       20 files
In-flight done:   2 files
Cancelled:        1 file
Queued dropped:  12 files

Total downloaded: 1.1 GB
Time:            2m 45s
```

### Error Handling Output

```go
// Rate limit error
⚠ Rate limit reached. Throttling requests to 10 MB/s...

// Download error
✗ Error downloading file3.iso
  URL:    https://example.com/file3.iso
  Error:  connection timeout after 30s
  Retry:  attempt 2/3

// Pipeline error
✗ Pipeline stage failed: checksum verification
  File:     file5.pdf
  Expected: abc123def456
  Got:      xyz789uvw012
  Action:   re-downloading
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] Worker pool with configurable size launches and manages workers
- [ ] Jobs distributed evenly across workers
- [ ] Pipeline stages (validate, download, checksum) function correctly
- [ ] Rate limiting respects configured limits (bandwidth and request rate)
- [ ] Backpressure handled without dropping jobs or deadlocking
- [ ] Graceful shutdown completes in-flight work or times out appropriately
- [ ] Errors propagate through pipeline and reported to user
- [ ] Progress tracking shows real-time updates for all workers

### Code Quality ✅

- [ ] All code passes `go fmt` (formatting)
- [ ] All code passes `go vet` (correctness)
- [ ] All code passes `staticcheck` (style)
- [ ] No race conditions detected (`go test -race`)
- [ ] Channels properly closed to prevent goroutine leaks
- [ ] Context used for cancellation where appropriate
- [ ] Clear separation of concerns (pool, pipeline, limiter, display)

### Testing ✅

- [ ] Table-driven tests for worker pool sizing
- [ ] Test coverage >80% (`go test -cover`)
- [ ] Race condition testing passes (`go test -race`)
- [ ] Pipeline stages tested independently
- [ ] Rate limiter accuracy tested
- [ ] Graceful shutdown tested with various scenarios
- [ ] Error propagation verified through pipeline
- [ ] Integration tests for end-to-end workflows

### Documentation ✅

- [ ] README explains worker pool and pipeline patterns
- [ ] Function comments describe concurrency behavior
- [ ] Examples demonstrate usage
- [ ] Architecture diagram included
- [ ] Graceful shutdown behavior documented
- [ ] Performance tuning guidelines provided

### Performance ✅

- [ ] Worker pool provides speedup proportional to worker count
- [ ] Rate limiting accuracy within ±10%
- [ ] Minimal overhead for pipeline stages
- [ ] Graceful shutdown completes within timeout
- [ ] No memory leaks from unclosed channels or goroutines

---

## Common Pitfalls

### ❌ Pitfall 1: Unbounded Worker Creation

**Wrong**:
```go
func processFiles(files []string) {
    for _, file := range files {
        go processFile(file)  // Creates thousands of goroutines!
    }
}
```

**Right**:
```go
func processFiles(files []string, numWorkers int) {
    jobs := make(chan string, len(files))
    var wg sync.WaitGroup

    // Fixed number of workers
    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go worker(&wg, jobs)
    }

    // Queue jobs
    for _, file := range files {
        jobs <- file
    }
    close(jobs)

    wg.Wait()
}
```

**Why**: Unbounded goroutine creation can exhaust memory and overwhelm system resources. Worker pools provide controlled concurrency.

---

### ❌ Pitfall 2: Forgetting to Close Channels

**Wrong**:
```go
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        for _, n := range nums {
            out <- n
        }
        // Forgot to close(out)!
    }()
    return out
}

// Consumer blocks forever waiting for close
for n := range generate(1, 2, 3) {
    fmt.Println(n)
}
```

**Right**:
```go
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)  // Always close when done
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}
```

**Why**: Unclosed channels cause goroutines to block forever waiting for data, leading to goroutine leaks.

---

### ❌ Pitfall 3: Ignoring Shutdown Signals

**Wrong**:
```go
func worker(jobs <-chan Job) {
    for job := range jobs {
        process(job)  // No way to interrupt!
    }
}

func main() {
    jobs := make(chan Job)
    go worker(jobs)

    // User presses Ctrl+C, but no handler!
    // Worker keeps running
}
```

**Right**:
```go
func worker(ctx context.Context, jobs <-chan Job) {
    for {
        select {
        case <-ctx.Done():
            return  // Graceful exit

        case job, ok := <-jobs:
            if !ok {
                return
            }
            process(job)
        }
    }
}

func main() {
    ctx, cancel := context.WithCancel(context.Background())

    // Handle SIGINT/SIGTERM
    sigChan := make(chan os.Signal, 1)
    signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

    go func() {
        <-sigChan
        fmt.Println("\nShutdown signal received...")
        cancel()
    }()

    jobs := make(chan Job)
    go worker(ctx, jobs)
}
```

**Why**: Users expect Ctrl+C to gracefully stop programs, not forcefully kill them mid-operation.

---

### ❌ Pitfall 4: Rate Limiter Deadlock

**Wrong**:
```go
func rateLimitedWorker(limiter *rate.Limiter, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        limiter.Wait(context.Background())  // Blocks forever if context cancelled
        result := process(job)
        results <- result
    }
}
```

**Right**:
```go
func rateLimitedWorker(ctx context.Context, limiter *rate.Limiter, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        // Respect cancellation
        if err := limiter.Wait(ctx); err != nil {
            return
        }

        result := process(job)

        // Respect cancellation when sending
        select {
        case results <- result:
        case <-ctx.Done():
            return
        }
    }
}
```

**Why**: Rate limiter waits can block indefinitely. Always pass a cancellable context.

---

### ❌ Pitfall 5: Pipeline Stage Blocking

**Wrong**:
```go
func slowStage(in <-chan int) <-chan int {
    out := make(chan int)  // Unbuffered!
    go func() {
        defer close(out)
        for n := range in {
            result := verySlowProcess(n)  // Takes 10 seconds
            out <- result  // Blocks until consumer reads
        }
    }()
    return out
}
```

**Right**:
```go
func slowStage(in <-chan int) <-chan int {
    out := make(chan int, 10)  // Buffered for throughput
    go func() {
        defer close(out)
        for n := range in {
            result := verySlowProcess(n)
            out <- result  // Non-blocking if buffer available
        }
    }()
    return out
}

// Or: use fan-out to parallelize slow stage
func slowStageFanOut(in <-chan int, workers int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup

    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for n := range in {
                result := verySlowProcess(n)
                out <- result
            }
        }()
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

**Why**: Slow pipeline stages become bottlenecks. Buffer channels or use fan-out for parallelism.

---

### ❌ Pitfall 6: Shared State in Workers

**Wrong**:
```go
var totalProcessed int  // Shared, unprotected!

func worker(jobs <-chan Job) {
    for job := range jobs {
        process(job)
        totalProcessed++  // RACE CONDITION!
    }
}

func main() {
    jobs := make(chan Job, 100)
    for i := 0; i < 10; i++ {
        go worker(jobs)  // Multiple workers accessing shared state
    }
}
```

**Right**:
```go
// Option 1: Pass via channel (preferred)
func worker(jobs <-chan Job, stats chan<- int) {
    count := 0
    for job := range jobs {
        process(job)
        count++
    }
    stats <- count  // Send local count
}

func main() {
    jobs := make(chan Job, 100)
    stats := make(chan int, 10)

    for i := 0; i < 10; i++ {
        go worker(jobs, stats)
    }

    // Collect stats
    close(jobs)
    total := 0
    for i := 0; i < 10; i++ {
        total += <-stats
    }
}

// Option 2: Use mutex
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (sc *SafeCounter) Increment() {
    sc.mu.Lock()
    sc.count++
    sc.mu.Unlock()
}
```

**Why**: Shared state across goroutines requires synchronization. Prefer channels over shared memory.

---

## Extension Challenges

### Extension 1: Priority Job Queue ⭐⭐⭐

Implement a worker pool with priority-based job processing:

```go
type PriorityJob struct {
    Job
    Priority int  // Higher = more important
}

type PriorityQueue struct {
    jobs []PriorityJob
    mu   sync.Mutex
    cond *sync.Cond
}

func NewPriorityQueue() *PriorityQueue {
    pq := &PriorityQueue{
        jobs: make([]PriorityJob, 0),
    }
    pq.cond = sync.NewCond(&pq.mu)
    return pq
}

func (pq *PriorityQueue) Enqueue(job PriorityJob) {
    pq.mu.Lock()
    defer pq.mu.Unlock()

    // Insert sorted by priority
    inserted := false
    for i, existingJob := range pq.jobs {
        if job.Priority > existingJob.Priority {
            pq.jobs = append(pq.jobs[:i], append([]PriorityJob{job}, pq.jobs[i:]...)...)
            inserted = true
            break
        }
    }

    if !inserted {
        pq.jobs = append(pq.jobs, job)
    }

    pq.cond.Signal()  // Wake up a waiting worker
}

func (pq *PriorityQueue) Dequeue() (PriorityJob, bool) {
    pq.mu.Lock()
    defer pq.mu.Unlock()

    for len(pq.jobs) == 0 {
        pq.cond.Wait()  // Wait for jobs
    }

    if len(pq.jobs) == 0 {
        return PriorityJob{}, false
    }

    job := pq.jobs[0]
    pq.jobs = pq.jobs[1:]
    return job, true
}

// Usage with worker pool
func priorityWorker(pq *PriorityQueue) {
    for {
        job, ok := pq.Dequeue()
        if !ok {
            return
        }

        fmt.Printf("Processing priority %d job\n", job.Priority)
        process(job.Job)
    }
}
```

**Learning Goal**: Implement custom synchronization patterns beyond basic channels.

---

### Extension 2: Dynamic Worker Scaling ⭐⭐⭐⭐

Create a worker pool that scales up/down based on load:

```go
type AutoScalingPool struct {
    jobs          chan Job
    minWorkers    int
    maxWorkers    int
    activeWorkers int
    mu            sync.Mutex
    scaler        *time.Ticker
}

func NewAutoScalingPool(min, max int) *AutoScalingPool {
    pool := &AutoScalingPool{
        jobs:       make(chan Job, 1000),
        minWorkers: min,
        maxWorkers: max,
        scaler:     time.NewTicker(5 * time.Second),
    }

    // Start minimum workers
    for i := 0; i < min; i++ {
        pool.startWorker()
    }

    // Start auto-scaling monitor
    go pool.monitor()

    return pool
}

func (asp *AutoScalingPool) monitor() {
    for range asp.scaler.C {
        asp.adjustScale()
    }
}

func (asp *AutoScalingPool) adjustScale() {
    asp.mu.Lock()
    defer asp.mu.Unlock()

    queueDepth := len(asp.jobs)

    // Scale up if queue backing up
    if queueDepth > 100 && asp.activeWorkers < asp.maxWorkers {
        asp.startWorker()
        asp.activeWorkers++
        fmt.Printf("Scaled up to %d workers (queue: %d)\n", asp.activeWorkers, queueDepth)
    }

    // Scale down if queue empty
    if queueDepth == 0 && asp.activeWorkers > asp.minWorkers {
        // Signal worker to stop (implementation detail)
        asp.activeWorkers--
        fmt.Printf("Scaled down to %d workers\n", asp.activeWorkers)
    }
}

func (asp *AutoScalingPool) startWorker() {
    go func() {
        for job := range asp.jobs {
            process(job)
        }
    }()
}
```

**Learning Goal**: Implement adaptive concurrency based on runtime metrics.

---

### Extension 3: Retry Pipeline Stage ⭐⭐⭐

Add retry logic with exponential backoff to pipeline:

```go
type RetryableStage struct {
    maxRetries int
    backoff    time.Duration
}

func (rs *RetryableStage) Process(in <-chan Job) <-chan Result {
    out := make(chan Result)

    go func() {
        defer close(out)

        for job := range in {
            result := rs.processWithRetry(job)
            out <- result
        }
    }()

    return out
}

func (rs *RetryableStage) processWithRetry(job Job) Result {
    var lastErr error

    for attempt := 0; attempt < rs.maxRetries; attempt++ {
        result, err := process(job)
        if err == nil {
            return Result{Value: result}
        }

        lastErr = err

        // Exponential backoff
        wait := rs.backoff * time.Duration(1<<uint(attempt))
        fmt.Printf("Attempt %d failed, retrying in %v: %v\n", attempt+1, wait, err)
        time.Sleep(wait)
    }

    return Result{
        Err: fmt.Errorf("failed after %d retries: %w", rs.maxRetries, lastErr),
    }
}

// Usage in pipeline
func buildResilientPipeline(jobs <-chan Job) <-chan Result {
    // Stage 1: Validate (no retry)
    validated := validateStage(jobs)

    // Stage 2: Download (with retry)
    retryStage := &RetryableStage{
        maxRetries: 3,
        backoff:    1 * time.Second,
    }
    downloaded := retryStage.Process(validated)

    // Stage 3: Process (no retry)
    return processStage(downloaded)
}
```

**Learning Goal**: Build resilient pipelines that handle transient failures.

---

### Extension 4: Circuit Breaker Pattern ⭐⭐⭐⭐

Implement circuit breaker to prevent cascading failures:

```go
type CircuitBreaker struct {
    maxFailures  int
    resetTimeout time.Duration

    failures    int
    lastFailure time.Time
    state       string  // "closed", "open", "half-open"
    mu          sync.Mutex
}

func NewCircuitBreaker(maxFailures int, resetTimeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures:  maxFailures,
        resetTimeout: resetTimeout,
        state:        "closed",
    }
}

func (cb *CircuitBreaker) Call(fn func() error) error {
    cb.mu.Lock()

    // Check if circuit should reset
    if cb.state == "open" && time.Since(cb.lastFailure) > cb.resetTimeout {
        cb.state = "half-open"
        cb.failures = 0
    }

    // Reject if circuit open
    if cb.state == "open" {
        cb.mu.Unlock()
        return fmt.Errorf("circuit breaker open")
    }

    cb.mu.Unlock()

    // Execute function
    err := fn()

    cb.mu.Lock()
    defer cb.mu.Unlock()

    if err != nil {
        cb.failures++
        cb.lastFailure = time.Now()

        if cb.failures >= cb.maxFailures {
            cb.state = "open"
            fmt.Println("Circuit breaker opened")
        }

        return err
    }

    // Success: reset if half-open
    if cb.state == "half-open" {
        cb.state = "closed"
        cb.failures = 0
        fmt.Println("Circuit breaker closed")
    }

    return nil
}

// Usage in worker
func workerWithCircuitBreaker(cb *CircuitBreaker, jobs <-chan Job) {
    for job := range jobs {
        err := cb.Call(func() error {
            return processJob(job)
        })

        if err != nil {
            fmt.Printf("Job failed: %v\n", err)
        }
    }
}
```

**Learning Goal**: Implement fault-tolerance patterns for production systems.

---

### Extension 5: Pipeline Visualization & Metrics ⭐⭐⭐⭐

Create real-time visualization of pipeline performance:

```go
type PipelineMetrics struct {
    stages map[string]*StageMetrics
    mu     sync.RWMutex
}

type StageMetrics struct {
    Name          string
    Processed     int
    Errors        int
    AvgDuration   time.Duration
    QueueDepth    int
    Throughput    float64  // items/second
    LastUpdate    time.Time
}

func (pm *PipelineMetrics) RecordStage(name string, duration time.Duration, err error) {
    pm.mu.Lock()
    defer pm.mu.Unlock()

    if _, exists := pm.stages[name]; !exists {
        pm.stages[name] = &StageMetrics{Name: name}
    }

    sm := pm.stages[name]
    sm.Processed++
    if err != nil {
        sm.Errors++
    }

    // Update average duration
    sm.AvgDuration = (sm.AvgDuration*time.Duration(sm.Processed-1) + duration) / time.Duration(sm.Processed)

    // Calculate throughput
    elapsed := time.Since(sm.LastUpdate)
    if elapsed > time.Second {
        sm.Throughput = float64(sm.Processed) / elapsed.Seconds()
        sm.LastUpdate = time.Now()
    }
}

func (pm *PipelineMetrics) Render() string {
    pm.mu.RLock()
    defer pm.mu.RUnlock()

    var output strings.Builder

    output.WriteString(lipgloss.NewStyle().Bold(true).Render("Pipeline Performance"))
    output.WriteString("\n\n")

    for _, sm := range pm.stages {
        stageBox := lipgloss.NewStyle().
            Border(lipgloss.RoundedBorder()).
            BorderForeground(lipgloss.Color("62")).
            Padding(1, 2).
            Render(fmt.Sprintf(
                "%s\nProcessed: %d\nErrors: %d\nAvg Duration: %v\nThroughput: %.2f/s",
                sm.Name, sm.Processed, sm.Errors, sm.AvgDuration, sm.Throughput,
            ))

        output.WriteString(stageBox)
        output.WriteString("\n")
    }

    return output.String()
}

// Usage: instrument pipeline stages
func instrumentedStage(name string, metrics *PipelineMetrics, in <-chan Job) <-chan Result {
    out := make(chan Result)

    go func() {
        defer close(out)

        for job := range in {
            start := time.Now()
            result, err := process(job)
            duration := time.Since(start)

            metrics.RecordStage(name, duration, err)

            out <- Result{Value: result, Err: err}
        }
    }()

    return out
}
```

**Learning Goal**: Monitor and visualize complex concurrent systems in real-time.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear separation: worker pool, pipeline stages, rate limiter, display logic
- Reusable components (worker pool can be used in multiple contexts)
- Proper channel management (always close channels when done)
- Context-aware cancellation throughout

**Worker Pool Patterns**:
- Fixed-size pool with configurable workers
- Job queue using buffered channels
- Worker coordination with WaitGroup or Context
- Graceful shutdown that waits for completion or times out

**Pipeline Patterns**:
- Each stage is an independent function returning a channel
- Clear input/output channel types
- Fan-out for parallelism, fan-in for merging
- Error handling at each stage

**Testing Approach**:
- Table-driven tests for various pool sizes and job counts
- Race condition detection (`go test -race`)
- Channel leak detection
- Rate limiter accuracy tests
- Graceful shutdown tests with timeouts

**Documentation**:
- Explain concurrency patterns used
- Document channel ownership and closing responsibility
- Clarify graceful shutdown behavior
- Provide architecture diagrams

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

**Approach 1: Channel-Based Worker Pool**:
```go
type WorkerPool struct {
    jobs    chan Job
    results chan Result
    wg      sync.WaitGroup
}

func (wp *WorkerPool) Start(numWorkers int) {
    for i := 0; i < numWorkers; i++ {
        wp.wg.Add(1)
        go wp.worker()
    }
}

func (wp *WorkerPool) worker() {
    defer wp.wg.Done()
    for job := range wp.jobs {
        result := process(job)
        wp.results <- result
    }
}

func (wp *WorkerPool) Shutdown() {
    close(wp.jobs)
    wp.wg.Wait()
    close(wp.results)
}
```

**Approach 2: Context-Based Worker Pool**:
```go
type WorkerPool struct {
    jobs    chan Job
    results chan Result
    ctx     context.Context
    cancel  context.CancelFunc
    wg      sync.WaitGroup
}

func (wp *WorkerPool) Start(numWorkers int) {
    wp.ctx, wp.cancel = context.WithCancel(context.Background())

    for i := 0; i < numWorkers; i++ {
        wp.wg.Add(1)
        go wp.worker()
    }
}

func (wp *WorkerPool) worker() {
    defer wp.wg.Done()

    for {
        select {
        case <-wp.ctx.Done():
            return

        case job, ok := <-wp.jobs:
            if !ok {
                return
            }
            result := process(job)

            select {
            case wp.results <- result:
            case <-wp.ctx.Done():
                return
            }
        }
    }
}

func (wp *WorkerPool) Shutdown() {
    close(wp.jobs)
    wp.cancel()
    wp.wg.Wait()
    close(wp.results)
}
```

Both approaches are valid. Approach 2 provides better cancellation control, Approach 1 is simpler for basic use cases.

### Performance Expectations

- Worker pool should provide speedup proportional to worker count (for I/O-bound work)
- Rate limiting should be accurate within ±10%
- Pipeline overhead should be minimal (< 5% compared to sequential)
- Graceful shutdown should complete within configured timeout
- No goroutine or channel leaks

---

## Learning Resources

### Official Go Documentation
- [Go Concurrency Patterns: Pipelines](https://go.dev/blog/pipelines)
- [Advanced Go Concurrency Patterns](https://go.dev/blog/io2013-talk-concurrency)
- [Go Concurrency Patterns: Context](https://go.dev/blog/context)
- [Package sync](https://pkg.go.dev/sync)
- [Package context](https://pkg.go.dev/context)

### Rate Limiting
- [golang.org/x/time/rate](https://pkg.go.dev/golang.org/x/time/rate)
- [Rate Limiting Algorithms](https://en.wikipedia.org/wiki/Rate_limiting#Algorithms)

### Error Handling
- [golang.org/x/sync/errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup)
- [Error handling and Go](https://go.dev/blog/error-handling-and-go)

### Books
- *Concurrency in Go* by Katherine Cox-Buday (Chapters 4-5: Concurrency Patterns)
- *The Go Programming Language* (Chapter 8.4-8.5: Channels, Concurrency)
- *Go in Practice* (Chapter 6: Concurrent Patterns)

### Video Resources
- [GopherCon 2017: Kavya Joshi - Understanding Channels](https://www.youtube.com/watch?v=KBZlN0izeiY)
- [Advanced Concurrency Patterns](https://www.youtube.com/watch?v=QDDwwePbDtw)

### Real-World Examples
- [Kubernetes Worker Pool](https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/util/workqueue/)
- [Docker Builder Pipeline](https://github.com/moby/moby/tree/master/builder)

### Related Charm.sh
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Terminal styling for output
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - TUI framework (Phase 5)

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

# Race condition detection (critical for concurrent code)
go test -race ./...

# Coverage report
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run application
go run main.go download --urls test-urls.txt --workers 5

# Dashboard mode
go run main.go download --urls test-urls.txt --dashboard

# Rate-limited mode
go run main.go download --urls test-urls.txt --rate-limit 1.0

# Graceful shutdown test (press Ctrl+C during execution)
go run main.go download --urls large-files.txt --workers 10

# Pipeline mode with verification
go run main.go download --urls test-urls.txt --pipeline --verify

# Performance benchmarks
go test -bench=. -benchmem ./pool/
go test -bench=. -benchmem ./pipeline/
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestWorkerPool
=== RUN   TestWorkerPool/Single_worker_sequential
=== RUN   TestWorkerPool/Multiple_workers_parallel
=== RUN   TestWorkerPool/More_jobs_than_workers
--- PASS: TestWorkerPool (0.35s)
    --- PASS: TestWorkerPool/Single_worker_sequential (0.12s)
    --- PASS: TestWorkerPool/Multiple_workers_parallel (0.08s)
    --- PASS: TestWorkerPool/More_jobs_than_workers (0.15s)
=== RUN   TestPipelineStages
=== RUN   TestPipelineStages/Validate_stage
=== RUN   TestPipelineStages/Download_stage
=== RUN   TestPipelineStages/Checksum_stage
--- PASS: TestPipelineStages (0.22s)
=== RUN   TestRateLimiter
--- PASS: TestRateLimiter (1.05s)
=== RUN   TestGracefulShutdown
--- PASS: TestGracefulShutdown (1.52s)
=== RUN   TestErrorPropagation
--- PASS: TestErrorPropagation (0.15s)
PASS
coverage: 84.7% of statements
ok      lesson23/pool       2.291s
ok      lesson23/pipeline   1.875s
ok      lesson23/limiter    1.128s
```

### Race Detection Output

```bash
$ go test -race ./...
PASS
ok      lesson23/pool       3.421s
ok      lesson23/pipeline   2.876s
```

*If race detected:*
```bash
==================
WARNING: DATA RACE
Write at 0x00c000014080 by goroutine 8:
  lesson23/pool.(*WorkerPool).worker()
      /path/to/pool.go:45 +0x88

Previous read at 0x00c000014080 by goroutine 7:
  lesson23/pool.(*WorkerPool).Stats()
      /path/to/pool.go:72 +0x44
==================
```

---

**Previous Lesson**: [Lesson 22: Sync Package - WaitGroups & Mutexes](lesson-22-sync-package.md) (Phase 4)
**Next Lesson**: Lesson 24: Context for Cancellation & Deadlines (Phase 4 Milestone)
**Phase 4 Milestone**: Lesson 24: Concurrent Web Crawler with Context

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
