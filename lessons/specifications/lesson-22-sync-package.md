# Lesson 22: Sync Package - WaitGroups & Mutexes

**Phase**: 4 - Concurrency Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-21 (especially Lessons 19-20: Goroutines and Channels)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Master WaitGroup coordination** - Use sync.WaitGroup to wait for multiple goroutines to complete execution
2. **Understand mutual exclusion** - Protect shared state with sync.Mutex to prevent race conditions
3. **Optimize with RWMutex** - Apply sync.RWMutex for read-heavy workloads to improve concurrent read performance
4. **Implement one-time initialization** - Use sync.Once for thread-safe lazy initialization patterns
5. **Apply object pooling** - Leverage sync.Pool for efficient object reuse and garbage collection reduction
6. **Choose synchronization strategies** - Decide when to use mutexes vs channels based on use case
7. **Build thread-safe data structures** - Create concurrent-safe counters, maps, and caches with proper synchronization
8. **Bridge previous knowledge** - Apply Lip Gloss styling (Phase 3) to concurrent monitoring dashboards

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (structs, interfaces, error handling, packages)
- **Phase 2**: CLI development (flag parsing, file I/O, JSON persistence)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout, theming)
- **Phase 4**: Goroutines (Lesson 19), Channels (Lessons 20-21)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-22-sync-package
cd ~/go-learning/lesson-22-sync-package

# Initialize module
go mod init lesson22

# Install dependencies for visualization
go get github.com/charmbracelet/lipgloss@latest
```

### Conceptual Preparation
- Review Lesson 19 (Goroutines) - understand concurrent execution and race conditions
- Review Lesson 20 (Channels) - compare channel-based vs mutex-based synchronization
- Review Lesson 15 (Lip Gloss Basics) - we'll style concurrent monitoring output

---

## Core Concepts

### 1. Synchronization Primitives Overview

**Definition**: The `sync` package provides synchronization primitives for coordinating goroutines and protecting shared state.

**Core Components**:
```go
import "sync"

// Coordination
sync.WaitGroup    // Wait for collection of goroutines to finish
sync.Once         // Execute something exactly once

// Mutual Exclusion
sync.Mutex        // Mutual exclusion lock
sync.RWMutex      // Reader/writer mutual exclusion lock

// Object Management
sync.Pool         // Set of temporary objects for reuse
sync.Map          // Concurrent-safe map (specialized use cases)
sync.Cond         // Condition variables (advanced, rarely needed)
```

**Mutexes vs Channels Decision Tree**:
```go
// ✅ Use Channels when:
// - Transferring ownership of data
// - Distributing units of work
// - Communicating async results
// - Coordinating multiple goroutines

// ✅ Use Mutexes when:
// - Protecting shared state (counters, caches, config)
// - Critical sections are very short
// - Guarding complex data structures
// - Read-heavy workloads (RWMutex)
```

**Go Proverb**: "Don't communicate by sharing memory; share memory by communicating." Channels are preferred, but mutexes have their place.

### 2. sync.WaitGroup - Goroutine Coordination

**Purpose**: Wait for a collection of goroutines to complete without using channels.

**Basic Pattern**:
```go
var wg sync.WaitGroup

func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done() // Decrement counter when done

    fmt.Printf("Worker %d starting\n", id)
    time.Sleep(time.Second)
    fmt.Printf("Worker %d done\n", id)
}

func main() {
    for i := 1; i <= 5; i++ {
        wg.Add(1) // Increment counter
        go worker(i, &wg)
    }

    wg.Wait() // Block until counter reaches zero
    fmt.Println("All workers completed")
}
```

**WaitGroup Methods**:
```go
var wg sync.WaitGroup

// Add: Increment the WaitGroup counter
wg.Add(1)    // Add 1
wg.Add(5)    // Add 5

// Done: Decrement the WaitGroup counter (equivalent to Add(-1))
wg.Done()

// Wait: Block until counter reaches zero
wg.Wait()
```

**Common Pattern: Bulk Operations**:
```go
func processFiles(files []string) {
    var wg sync.WaitGroup

    for _, file := range files {
        wg.Add(1)
        go func(f string) {
            defer wg.Done()
            processFile(f)
        }(file)
    }

    wg.Wait() // Wait for all files to be processed
}
```

**WaitGroup Best Practices**:
```go
// ✅ Good: Add before launching goroutine
wg.Add(1)
go func() {
    defer wg.Done()
    doWork()
}()

// ❌ Bad: Add inside goroutine (race condition)
go func() {
    wg.Add(1)  // May be called after wg.Wait()
    defer wg.Done()
    doWork()
}()

// ✅ Good: Defer Done to handle panics
go func() {
    defer wg.Done() // Ensures Done is called even if panic
    riskyOperation()
}()

// ❌ Bad: Forgetting Done (deadlock)
go func() {
    doWork() // If this returns early, Done never called
    wg.Done()
}()
```

### 3. sync.Mutex - Mutual Exclusion

**Purpose**: Protect shared state from concurrent access to prevent race conditions.

**Critical Section Pattern**:
```go
var (
    counter int
    mu      sync.Mutex
)

func increment() {
    mu.Lock()         // Acquire lock
    counter++         // Critical section
    mu.Unlock()       // Release lock
}

func safeIncrement() {
    mu.Lock()
    defer mu.Unlock() // Ensure unlock even if panic
    counter++
}
```

**Race Condition Demonstration**:
```go
// ❌ Without Mutex: Race Condition
var counter int

func unsafeIncrement() {
    for i := 0; i < 1000; i++ {
        counter++ // RACE: Multiple goroutines modify counter
    }
}

func main() {
    for i := 0; i < 10; i++ {
        go unsafeIncrement()
    }
    time.Sleep(time.Second)
    fmt.Println(counter) // Unpredictable result < 10000
}

// ✅ With Mutex: Thread-Safe
var (
    counter int
    mu      sync.Mutex
)

func safeIncrement() {
    for i := 0; i < 1000; i++ {
        mu.Lock()
        counter++
        mu.Unlock()
    }
}

func main() {
    for i := 0; i < 10; i++ {
        go safeIncrement()
    }
    time.Sleep(time.Second)
    fmt.Println(counter) // Always 10000
}
```

**Thread-Safe Counter Pattern**:
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func NewCounter() *Counter {
    return &Counter{}
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Decrement() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value--
}

func (c *Counter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}

// Usage
func main() {
    counter := NewCounter()
    var wg sync.WaitGroup

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()
    fmt.Printf("Final count: %d\n", counter.Value()) // Always 100
}
```

**Mutex Deadlock Prevention**:
```go
// ❌ Deadlock: Locking same mutex twice
func deadlock() {
    var mu sync.Mutex
    mu.Lock()
    mu.Lock() // DEADLOCK: Already locked by this goroutine
    mu.Unlock()
}

// ❌ Deadlock: Circular dependency
var (
    mu1 sync.Mutex
    mu2 sync.Mutex
)

func goroutine1() {
    mu1.Lock()
    time.Sleep(10 * time.Millisecond)
    mu2.Lock() // Waits for mu2
    mu2.Unlock()
    mu1.Unlock()
}

func goroutine2() {
    mu2.Lock()
    time.Sleep(10 * time.Millisecond)
    mu1.Lock() // Waits for mu1 - DEADLOCK
    mu1.Unlock()
    mu2.Unlock()
}

// ✅ Solution: Always acquire locks in the same order
func safeGoroutine1() {
    mu1.Lock()
    mu2.Lock()
    // Work
    mu2.Unlock()
    mu1.Unlock()
}

func safeGoroutine2() {
    mu1.Lock() // Same order as goroutine1
    mu2.Lock()
    // Work
    mu2.Unlock()
    mu1.Unlock()
}
```

### 4. sync.RWMutex - Reader/Writer Locks

**Purpose**: Optimize read-heavy workloads by allowing multiple concurrent readers while ensuring exclusive writer access.

**RWMutex vs Mutex**:
```go
// Mutex: Exclusive access for all operations
var mu sync.Mutex
mu.Lock()     // Blocks all other goroutines
mu.Unlock()

// RWMutex: Multiple readers OR one writer
var rwmu sync.RWMutex
rwmu.RLock()    // Multiple goroutines can hold read locks
rwmu.RUnlock()
rwmu.Lock()     // Exclusive write lock
rwmu.Unlock()
```

**Thread-Safe Cache with RWMutex**:
```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]string
}

func NewCache() *Cache {
    return &Cache{
        items: make(map[string]string),
    }
}

// Get: Read operation (multiple concurrent readers allowed)
func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()         // Acquire read lock
    defer c.mu.RUnlock()
    value, exists := c.items[key]
    return value, exists
}

// Set: Write operation (exclusive access required)
func (c *Cache) Set(key, value string) {
    c.mu.Lock()          // Acquire write lock
    defer c.mu.Unlock()
    c.items[key] = value
}

// Delete: Write operation
func (c *Cache) Delete(key string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    delete(c.items, key)
}

// Size: Read operation
func (c *Cache) Size() int {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return len(c.items)
}
```

**Performance Comparison**:
```go
func benchmarkMutex() {
    var mu sync.Mutex
    cache := make(map[string]int)

    // Heavy read workload with Mutex
    for i := 0; i < 100; i++ {
        go func() {
            for j := 0; j < 10000; j++ {
                mu.Lock()
                _ = cache["key"]
                mu.Unlock()
            }
        }()
    }
}

func benchmarkRWMutex() {
    var rwmu sync.RWMutex
    cache := make(map[string]int)

    // Heavy read workload with RWMutex (much faster)
    for i := 0; i < 100; i++ {
        go func() {
            for j := 0; j < 10000; j++ {
                rwmu.RLock()
                _ = cache["key"]
                rwmu.RUnlock()
            }
        }()
    }
}

// Result: RWMutex is ~10x faster for read-heavy workloads
```

**When to Use RWMutex**:
```go
// ✅ Good use cases:
// - Read-to-write ratio > 10:1
// - Critical sections with expensive reads
// - Config managers, caches, lookup tables

// ❌ Bad use cases:
// - Balanced read/write workloads
// - Very short critical sections
// - Simple counters (use Mutex)
```

### 5. sync.Once - One-Time Initialization

**Purpose**: Ensure a function is executed exactly once, even with concurrent access.

**Lazy Initialization Pattern**:
```go
var (
    instance *Database
    once     sync.Once
)

func GetDatabase() *Database {
    once.Do(func() {
        fmt.Println("Initializing database...")
        instance = &Database{
            conn: connectToDatabase(),
        }
    })
    return instance
}

func main() {
    var wg sync.WaitGroup

    // Launch 100 goroutines trying to get database
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            db := GetDatabase() // Only initializes once
            fmt.Printf("Got database: %p\n", db)
        }()
    }

    wg.Wait()
    // Output: "Initializing database..." printed exactly once
}
```

**Singleton Pattern with sync.Once**:
```go
type Config struct {
    APIKey    string
    Timeout   time.Duration
    MaxRetries int
}

var (
    config *Config
    once   sync.Once
)

func GetConfig() *Config {
    once.Do(func() {
        config = &Config{
            APIKey:    os.Getenv("API_KEY"),
            Timeout:   30 * time.Second,
            MaxRetries: 3,
        }
        fmt.Println("Config loaded")
    })
    return config
}
```

**vs Mutex Initialization**:
```go
// ❌ Mutex: Locks every access
var (
    config *Config
    mu     sync.Mutex
)

func GetConfigMutex() *Config {
    mu.Lock()
    defer mu.Unlock()
    if config == nil {
        config = loadConfig()
    }
    return config
}

// ✅ sync.Once: Locks only during first call
var (
    config *Config
    once   sync.Once
)

func GetConfigOnce() *Config {
    once.Do(func() {
        config = loadConfig()
    })
    return config // No lock after initialization
}
```

**sync.Once Properties**:
- Executes function exactly once, even with concurrent callers
- Subsequent calls return immediately without executing function
- Thread-safe without explicit locking
- Cannot be reset (once executed, stays executed)

### 6. sync.Pool - Object Reuse

**Purpose**: Pool of temporary objects that can be reused to reduce garbage collection pressure.

**Basic Pool Usage**:
```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        // Create new object when pool is empty
        return new(bytes.Buffer)
    },
}

func processRequest(data string) {
    // Get buffer from pool
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf) // Return to pool when done

    buf.Reset() // Clear previous contents
    buf.WriteString(data)
    buf.WriteString(" processed")

    fmt.Println(buf.String())
}
```

**HTTP Request Pool Example**:
```go
type Request struct {
    ID      int
    Payload []byte
}

var requestPool = sync.Pool{
    New: func() interface{} {
        return &Request{
            Payload: make([]byte, 0, 4096), // Pre-allocate 4KB
        }
    },
}

func handleRequest(id int, data []byte) {
    req := requestPool.Get().(*Request)
    defer requestPool.Put(req)

    req.ID = id
    req.Payload = req.Payload[:0] // Reset slice length, keep capacity
    req.Payload = append(req.Payload, data...)

    // Process request
    fmt.Printf("Handling request %d with %d bytes\n", req.ID, len(req.Payload))
}
```

**Performance Impact**:
```go
// Without Pool: Creates new buffer each time (garbage collection pressure)
func withoutPool() {
    for i := 0; i < 1000000; i++ {
        buf := new(bytes.Buffer) // Allocates memory
        buf.WriteString("data")
        // buf becomes garbage
    }
}

// With Pool: Reuses buffers (reduces allocations)
func withPool() {
    for i := 0; i < 1000000; i++ {
        buf := bufferPool.Get().(*bytes.Buffer)
        buf.Reset()
        buf.WriteString("data")
        bufferPool.Put(buf) // Returns for reuse
    }
}

// Result: Pool version allocates ~100x fewer objects
```

**sync.Pool Characteristics**:
- Objects may be removed from pool at any time (GC can clear pool)
- Not suitable for connection pools or limited resources
- Best for temporary objects with high allocation rate
- Thread-safe without explicit locking

**When to Use sync.Pool**:
```go
// ✅ Good use cases:
// - Temporary buffers (bytes.Buffer, strings.Builder)
// - Frequently allocated small objects
// - HTTP handlers creating many temp objects
// - JSON encoding/decoding buffers

// ❌ Bad use cases:
// - Database connection pools (use dedicated pool)
// - Objects requiring cleanup (file handles, network connections)
// - Objects with important state
// - Small number of objects
```

### 7. Concurrent Map Access Patterns

**Problem: Maps Are Not Thread-Safe**:
```go
// ❌ Race condition
var m = make(map[string]int)

func unsafeWrite() {
    for i := 0; i < 1000; i++ {
        m[fmt.Sprintf("key%d", i)] = i // RACE!
    }
}

func main() {
    go unsafeWrite()
    go unsafeWrite()
    time.Sleep(time.Second)
    // Panic: concurrent map writes
}
```

**Solution 1: Map with Mutex**:
```go
type SafeMap struct {
    mu   sync.RWMutex
    data map[string]int
}

func NewSafeMap() *SafeMap {
    return &SafeMap{
        data: make(map[string]int),
    }
}

func (m *SafeMap) Set(key string, value int) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.data[key] = value
}

func (m *SafeMap) Get(key string) (int, bool) {
    m.mu.RLock()
    defer m.mu.RUnlock()
    value, exists := m.data[key]
    return value, exists
}

func (m *SafeMap) Delete(key string) {
    m.mu.Lock()
    defer m.mu.Unlock()
    delete(m.data, key)
}

func (m *SafeMap) Len() int {
    m.mu.RLock()
    defer m.mu.RUnlock()
    return len(m.data)
}
```

**Solution 2: sync.Map (Specialized)**:
```go
var m sync.Map

// Store: Set key-value pair
m.Store("key", 42)

// Load: Get value
value, ok := m.Load("key")
if ok {
    fmt.Println(value.(int))
}

// LoadOrStore: Atomic get-or-create
actual, loaded := m.LoadOrStore("key", 42)
if loaded {
    fmt.Println("Key existed:", actual)
} else {
    fmt.Println("Key created:", actual)
}

// Delete: Remove key
m.Delete("key")

// Range: Iterate over all entries
m.Range(func(key, value interface{}) bool {
    fmt.Printf("%s: %v\n", key, value)
    return true // Continue iteration
})
```

**sync.Map vs Map with Mutex**:
```go
// Use sync.Map when:
// - Keys are write-once, read-many
// - Disjoint sets of keys (different goroutines work with different keys)
// - Rare contention

// Use Map with Mutex when:
// - Frequent updates to same keys
// - Known key types (type-safe access)
// - Range operations are common
// - General-purpose concurrent map
```

### 8. Connection Pool Implementation

**Pattern: Limited Resource Pool**:
```go
type ConnectionPool struct {
    mu          sync.Mutex
    connections chan *Connection
    maxSize     int
    activeCount int
}

type Connection struct {
    ID     int
    InUse  bool
    Client *http.Client
}

func NewConnectionPool(maxSize int) *ConnectionPool {
    return &ConnectionPool{
        connections: make(chan *Connection, maxSize),
        maxSize:     maxSize,
    }
}

func (p *ConnectionPool) Acquire() (*Connection, error) {
    select {
    case conn := <-p.connections:
        return conn, nil
    default:
        // No connection available, create new if under limit
        p.mu.Lock()
        if p.activeCount < p.maxSize {
            p.activeCount++
            p.mu.Unlock()
            return &Connection{
                ID:     p.activeCount,
                InUse:  true,
                Client: &http.Client{},
            }, nil
        }
        p.mu.Unlock()

        // Wait for available connection
        return <-p.connections, nil
    }
}

func (p *ConnectionPool) Release(conn *Connection) {
    conn.InUse = false
    p.connections <- conn
}

// Usage
func main() {
    pool := NewConnectionPool(5)

    var wg sync.WaitGroup
    for i := 0; i < 20; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()

            conn, _ := pool.Acquire()
            fmt.Printf("Goroutine %d acquired connection %d\n", id, conn.ID)

            time.Sleep(100 * time.Millisecond) // Simulate work

            pool.Release(conn)
            fmt.Printf("Goroutine %d released connection %d\n", id, conn.ID)
        }(i)
    }

    wg.Wait()
}
```

### 9. Styling Concurrent Monitoring (Bridging Phase 3)

**Using Lip Gloss for Sync Metrics Dashboard**:
```go
import (
    "fmt"
    "sync"
    "time"

    "github.com/charmbracelet/lipgloss"
)

var (
    titleStyle = lipgloss.NewStyle().
        Bold(true).
        Foreground(lipgloss.Color("205")).
        Padding(0, 1)

    metricStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        PaddingLeft(2)

    boxStyle = lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("62")).
        Padding(1, 2)
)

type ConcurrentMonitor struct {
    mu           sync.RWMutex
    goroutines   int
    tasksStarted int
    tasksCompleted int
}

func (m *ConcurrentMonitor) renderDashboard() string {
    m.mu.RLock()
    defer m.mu.RUnlock()

    title := titleStyle.Render("Concurrent Task Monitor")

    metrics := lipgloss.JoinVertical(
        lipgloss.Left,
        metricStyle.Render(fmt.Sprintf("Active Goroutines: %d", m.goroutines)),
        metricStyle.Render(fmt.Sprintf("Tasks Started:     %d", m.tasksStarted)),
        metricStyle.Render(fmt.Sprintf("Tasks Completed:   %d", m.tasksCompleted)),
        metricStyle.Render(fmt.Sprintf("Tasks Pending:     %d", m.tasksStarted-m.tasksCompleted)),
    )

    dashboard := lipgloss.JoinVertical(
        lipgloss.Left,
        title,
        "",
        metrics,
    )

    return boxStyle.Render(dashboard)
}

func styledWorker(id int, wg *sync.WaitGroup, monitor *ConcurrentMonitor) {
    defer wg.Done()

    monitor.mu.Lock()
    monitor.tasksStarted++
    monitor.mu.Unlock()

    time.Sleep(time.Duration(id*50) * time.Millisecond)

    monitor.mu.Lock()
    monitor.tasksCompleted++
    monitor.mu.Unlock()
}
```

---

## Challenge Description

Build a **Concurrent Data Processor** that demonstrates sync package primitives with real-time monitoring.

### Project Overview

Create a CLI application that:
1. Processes data concurrently using worker pools
2. Protects shared state with mutexes and RWMutex
3. Monitors goroutine activity with WaitGroups
4. Implements thread-safe cache with RWMutex
5. Uses sync.Once for configuration loading
6. Displays real-time metrics with Lip Gloss styling

### Functional Requirements

**Core Features**:
```bash
# Process files with worker pool
go run main.go --workers 10 --files data/*.txt

# Run with cache enabled
go run main.go --cache --cache-size 100

# Monitor concurrency metrics
go run main.go --monitor --interval 100ms

# Compare mutex vs RWMutex performance
go run main.go --benchmark mutex,rwmutex
```

**Expected Output**:
```
╔══════════════════════════════════════════╗
║   Concurrent Data Processor v1.0         ║
╚══════════════════════════════════════════╝

Configuration (loaded once via sync.Once):
  Workers:        10
  Cache Size:     100
  Cache Type:     RWMutex
  Monitor:        Enabled

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing Status:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Workers Active:      10
Tasks Queued:        50
Tasks Completed:     23
Cache Hits:          145
Cache Misses:        12
Cache Hit Rate:      92.4%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Tasks:         50
Processing Time:     2.3s
Throughput:          21.7 tasks/sec
Active Goroutines:   11
```

### Implementation Requirements

**Project Structure**:
```
lesson-22-sync-package/
├── main.go                    # CLI entry point
├── worker/
│   ├── pool.go                # Worker pool with WaitGroup
│   ├── task.go                # Task definition and processing
│   └── coordinator.go         # Task distribution
├── cache/
│   ├── cache.go               # Thread-safe cache with RWMutex
│   ├── stats.go               # Cache statistics
│   └── benchmark.go           # Mutex vs RWMutex comparison
├── config/
│   └── config.go              # sync.Once configuration loader
├── monitor/
│   ├── metrics.go             # Concurrent metrics with Mutex
│   └── display.go             # Lip Gloss dashboard
└── main_test.go
```

**Core Components**:

1. **Worker Pool**: Coordinated with WaitGroup
2. **Thread-Safe Cache**: Using RWMutex for read-heavy operations
3. **Configuration Manager**: Using sync.Once for lazy initialization
4. **Metrics Collector**: Using Mutex for counters
5. **Connection Pool**: Limited resource management

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestThreadSafeCounter(t *testing.T) {
    tests := []struct {
        name         string
        goroutines   int
        increments   int
        wantValue    int
    }{
        {
            name:       "Single goroutine",
            goroutines: 1,
            increments: 1000,
            wantValue:  1000,
        },
        {
            name:       "Multiple goroutines",
            goroutines: 10,
            increments: 1000,
            wantValue:  10000,
        },
        {
            name:       "Heavy contention",
            goroutines: 100,
            increments: 1000,
            wantValue:  100000,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            counter := NewCounter()
            var wg sync.WaitGroup

            for i := 0; i < tt.goroutines; i++ {
                wg.Add(1)
                go func() {
                    defer wg.Done()
                    for j := 0; j < tt.increments; j++ {
                        counter.Increment()
                    }
                }()
            }

            wg.Wait()

            if got := counter.Value(); got != tt.wantValue {
                t.Errorf("counter.Value() = %d, want %d", got, tt.wantValue)
            }
        })
    }
}
```

### Required Test Coverage

| Test Category | Test Cases | Purpose |
|---------------|------------|---------|
| **WaitGroup** | 5+ | Verify goroutine coordination |
| **Mutex** | 5+ | Test race condition prevention |
| **RWMutex** | 4+ | Validate reader/writer patterns |
| **sync.Once** | 3+ | Ensure one-time execution |
| **sync.Pool** | 3+ | Test object reuse |
| **Thread-Safe Structures** | 6+ | Test concurrent data structures |
| **Race Detection** | All tests | Run with `-race` flag |

### Specific Test Scenarios

**WaitGroup Coordination**:
```go
func TestWaitGroupCoordination(t *testing.T) {
    var wg sync.WaitGroup
    completed := 0
    var mu sync.Mutex

    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            time.Sleep(10 * time.Millisecond)
            mu.Lock()
            completed++
            mu.Unlock()
        }()
    }

    wg.Wait()

    if completed != 10 {
        t.Errorf("completed = %d, want 10", completed)
    }
}
```

**Race Condition Detection**:
```go
// Run with: go test -race
func TestNoRaceConditions(t *testing.T) {
    cache := NewThreadSafeCache()
    var wg sync.WaitGroup

    // Concurrent writes
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func(val int) {
            defer wg.Done()
            cache.Set(fmt.Sprintf("key%d", val), val)
        }(i)
    }

    // Concurrent reads
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func(val int) {
            defer wg.Done()
            cache.Get(fmt.Sprintf("key%d", val))
        }(i)
    }

    wg.Wait()
}
```

**sync.Once Behavior**:
```go
func TestSyncOnceExecutesExactlyOnce(t *testing.T) {
    var once sync.Once
    counter := 0

    // Launch 100 goroutines trying to execute
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            once.Do(func() {
                counter++
            })
        }()
    }

    wg.Wait()

    if counter != 1 {
        t.Errorf("counter = %d, want 1", counter)
    }
}
```

**RWMutex Performance**:
```go
func BenchmarkMutexReads(b *testing.B) {
    var mu sync.Mutex
    data := make(map[string]int)
    data["key"] = 42

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            mu.Lock()
            _ = data["key"]
            mu.Unlock()
        }
    })
}

func BenchmarkRWMutexReads(b *testing.B) {
    var rwmu sync.RWMutex
    data := make(map[string]int)
    data["key"] = 42

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            rwmu.RLock()
            _ = data["key"]
            rwmu.RUnlock()
        }
    })
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Flags**:
```go
var (
    workers     = flag.Int("workers", 10, "Number of worker goroutines")
    cacheSize   = flag.Int("cache-size", 100, "Cache size")
    useCache    = flag.Bool("cache", true, "Enable caching")
    cacheType   = flag.String("cache-type", "rwmutex", "Cache type: mutex or rwmutex")
    monitor     = flag.Bool("monitor", true, "Show real-time monitoring")
    interval    = flag.Duration("interval", 100*time.Millisecond, "Monitor update interval")
    benchmark   = flag.String("benchmark", "", "Benchmark: mutex,rwmutex,once,pool")
)
```

### Expected Output Formats

**Standard Execution**:
```
Concurrent Data Processor v1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  Workers:        10
  Cache Type:     RWMutex
  Cache Size:     100
  Monitor:        Enabled

Processing...
[████████████████████████████████████] 100%

Results:
  ✓ Processed 1000 tasks
  ⏱  Total time: 3.2s
  🚀 Throughput: 312.5 tasks/sec
  📊 Cache hit rate: 94.2%
  🔒 No race conditions detected
```

**Real-Time Monitoring**:
```
╔══════════════════════════════════════════╗
║       Concurrent Metrics Dashboard       ║
╚══════════════════════════════════════════╝

Worker Pool:
  Active Workers:      10
  Tasks Queued:        45
  Tasks Completed:     955
  Tasks Failed:        0

Cache Statistics:
  Cache Size:          87 / 100
  Cache Hits:          1,234
  Cache Misses:        156
  Hit Rate:            88.8%

System:
  Active Goroutines:   11
  Memory (Alloc):      2.3 MB
  GC Runs:             3

Last updated: 2024-01-15 14:23:45
```

**Benchmark Mode**:
```
Performance Benchmark
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Mutex Performance:
  Operations:          1,000,000
  Time:                845ms
  Throughput:          1,183,432 ops/sec

RWMutex Performance (90% reads):
  Operations:          1,000,000
  Time:                124ms
  Throughput:          8,064,516 ops/sec
  Speedup:             6.81x

sync.Once Performance:
  Concurrent calls:    10,000
  Initialization time: 1.2ms
  Total time:          2.3ms

sync.Pool Performance:
  Allocations (no pool):   1,000,000
  Allocations (with pool): 12,456
  Reduction:               98.8%
```

### Error Handling Output

```go
// Deadlock detection
Error: Potential deadlock detected
  Goroutine 15: Waiting for mutex at cache.go:45
  Goroutine 23: Waiting for mutex at cache.go:52
  Suggestion: Check lock acquisition order

// Race condition warning
Warning: Race condition detected (run with -race for details)
  Location: counter.go:34
  Fix: Protect counter with sync.Mutex
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] WaitGroup correctly coordinates multiple goroutines
- [ ] Mutex prevents race conditions on shared state
- [ ] RWMutex allows concurrent reads
- [ ] sync.Once ensures one-time initialization
- [ ] sync.Pool reduces allocations
- [ ] Thread-safe cache with correct semantics
- [ ] No race conditions (verified with `-race`)
- [ ] No deadlocks under normal operation

### Code Quality ✅

- [ ] All code passes `go fmt` (formatting)
- [ ] All code passes `go vet` (correctness)
- [ ] All code passes `staticcheck` (style)
- [ ] No race conditions detected (`go test -race`)
- [ ] Proper defer patterns for Unlock
- [ ] Lock acquisition order documented
- [ ] Comments explain synchronization strategy

### Testing ✅

- [ ] Table-driven tests for all sync primitives
- [ ] Test coverage >80% (`go test -cover`)
- [ ] Race condition testing passes (`go test -race`)
- [ ] Deadlock tests (timeout-based)
- [ ] Performance benchmarks included
- [ ] Edge cases tested (0 workers, high contention)

### Documentation ✅

- [ ] README explains synchronization patterns used
- [ ] Function comments describe thread-safety guarantees
- [ ] Lock ordering rules documented
- [ ] When to use mutex vs channel explained
- [ ] Performance characteristics documented

### Performance ✅

- [ ] RWMutex faster than Mutex for read-heavy workloads
- [ ] sync.Pool reduces allocations significantly
- [ ] No goroutine leaks
- [ ] Efficient use of WaitGroup (no busy-waiting)
- [ ] Proper cleanup on shutdown

---

## Common Pitfalls

### ❌ Pitfall 1: Forgetting to Unlock Mutex

**Wrong**:
```go
func dangerousIncrement(counter *int, mu *sync.Mutex) {
    mu.Lock()
    if *counter < 0 {
        return // Mutex still locked!
    }
    *counter++
    mu.Unlock()
}
```

**Right**:
```go
func safeIncrement(counter *int, mu *sync.Mutex) {
    mu.Lock()
    defer mu.Unlock() // Always unlocks, even on early return

    if *counter < 0 {
        return
    }
    *counter++
}
```

**Why**: Early returns or panics can leave mutex locked, causing deadlock. Always use `defer mu.Unlock()`.

---

### ❌ Pitfall 2: Copying Mutex by Value

**Wrong**:
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func brokenCounter() {
    c := Counter{}
    c2 := c // COPIES mutex (breaks synchronization)

    go c.Increment()
    go c2.Increment() // Uses different mutex!
}
```

**Right**:
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func correctCounter() {
    c := &Counter{} // Use pointer

    go c.Increment()
    go c.Increment() // Same mutex
}
```

**Why**: Mutexes must not be copied. Always pass structs containing mutexes by pointer.

---

### ❌ Pitfall 3: WaitGroup Add Inside Goroutine

**Wrong**:
```go
func brokenWaitGroup() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        go func() {
            wg.Add(1) // RACE: May be called after wg.Wait()
            defer wg.Done()
            doWork()
        }()
    }

    wg.Wait() // May return before all goroutines start
}
```

**Right**:
```go
func correctWaitGroup() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        wg.Add(1) // Add before launching goroutine
        go func() {
            defer wg.Done()
            doWork()
        }()
    }

    wg.Wait()
}
```

**Why**: `wg.Add()` must be called before the goroutine starts to avoid race conditions.

---

### ❌ Pitfall 4: Deadlock from Lock Ordering

**Wrong**:
```go
var (
    mu1 sync.Mutex
    mu2 sync.Mutex
)

func goroutine1() {
    mu1.Lock()
    time.Sleep(10 * time.Millisecond)
    mu2.Lock() // Waits for mu2
    // ...
    mu2.Unlock()
    mu1.Unlock()
}

func goroutine2() {
    mu2.Lock()
    time.Sleep(10 * time.Millisecond)
    mu1.Lock() // Waits for mu1 - DEADLOCK!
    // ...
    mu1.Unlock()
    mu2.Unlock()
}
```

**Right**:
```go
func goroutine1() {
    mu1.Lock()
    mu2.Lock() // Always acquire in same order
    // ...
    mu2.Unlock()
    mu1.Unlock()
}

func goroutine2() {
    mu1.Lock() // Same order as goroutine1
    mu2.Lock()
    // ...
    mu2.Unlock()
    mu1.Unlock()
}
```

**Why**: Always acquire multiple locks in the same order to prevent circular dependencies.

---

### ❌ Pitfall 5: Using sync.Map for Everything

**Wrong**:
```go
// Using sync.Map for general-purpose concurrent map
var cache sync.Map

func set(key string, value int) {
    cache.Store(key, value) // Type-unsafe
}

func get(key string) int {
    val, _ := cache.Load(key)
    return val.(int) // Requires type assertion
}
```

**Right**:
```go
// Using map with RWMutex for general-purpose concurrent map
type Cache struct {
    mu   sync.RWMutex
    data map[string]int // Type-safe
}

func (c *Cache) Set(key string, value int) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = value
}

func (c *Cache) Get(key string) (int, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    val, ok := c.data[key]
    return val, ok
}
```

**Why**: `sync.Map` is optimized for specific use cases (write-once, disjoint keys). For general use, map with RWMutex is clearer and type-safe.

---

### ❌ Pitfall 6: Holding Lock During Expensive Operation

**Wrong**:
```go
func slowCache(key string) string {
    mu.Lock()
    defer mu.Unlock()

    if val, ok := cache[key]; ok {
        return val
    }

    // Expensive operation while holding lock (blocks all readers/writers)
    val := expensiveAPICall(key) // Takes 100ms
    cache[key] = val
    return val
}
```

**Right**:
```go
func fastCache(key string) string {
    mu.RLock()
    val, ok := cache[key]
    mu.RUnlock()

    if ok {
        return val
    }

    // Expensive operation without lock
    val = expensiveAPICall(key)

    mu.Lock()
    cache[key] = val // Only lock briefly for write
    mu.Unlock()

    return val
}
```

**Why**: Minimize time spent holding locks. Release lock before expensive operations to allow concurrent access.

---

## Extension Challenges

### Extension 1: Adaptive RWMutex Selection ⭐⭐

Automatically choose between Mutex and RWMutex based on read/write ratio:

```go
type AdaptiveCache struct {
    mu         sync.RWMutex
    data       map[string]string
    readCount  uint64
    writeCount uint64
    useMutex   bool
}

func (c *AdaptiveCache) updateStrategy() {
    reads := atomic.LoadUint64(&c.readCount)
    writes := atomic.LoadUint64(&c.writeCount)

    // Switch to RWMutex if read-heavy (>80% reads)
    ratio := float64(reads) / float64(reads+writes)
    c.useMutex = ratio < 0.8
}

func (c *AdaptiveCache) Get(key string) (string, bool) {
    atomic.AddUint64(&c.readCount, 1)

    if c.useMutex {
        c.mu.Lock()
        defer c.mu.Unlock()
    } else {
        c.mu.RLock()
        defer c.mu.RUnlock()
    }

    val, ok := c.data[key]
    return val, ok
}

func (c *AdaptiveCache) Set(key, value string) {
    atomic.AddUint64(&c.writeCount, 1)

    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = value

    // Periodically update strategy
    if (atomic.LoadUint64(&c.writeCount) % 100) == 0 {
        c.updateStrategy()
    }
}
```

**Learning Goal**: Dynamic optimization based on runtime behavior.

---

### Extension 2: Distributed Rate Limiter with Mutex ⭐⭐

Implement a thread-safe token bucket rate limiter:

```go
type RateLimiter struct {
    mu         sync.Mutex
    tokens     int
    maxTokens  int
    refillRate time.Duration
    lastRefill time.Time
}

func NewRateLimiter(maxTokens int, refillRate time.Duration) *RateLimiter {
    return &RateLimiter{
        tokens:     maxTokens,
        maxTokens:  maxTokens,
        refillRate: refillRate,
        lastRefill: time.Now(),
    }
}

func (rl *RateLimiter) refill() {
    now := time.Now()
    elapsed := now.Sub(rl.lastRefill)
    tokensToAdd := int(elapsed / rl.refillRate)

    if tokensToAdd > 0 {
        rl.tokens = min(rl.tokens+tokensToAdd, rl.maxTokens)
        rl.lastRefill = now
    }
}

func (rl *RateLimiter) Allow() bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    rl.refill()

    if rl.tokens > 0 {
        rl.tokens--
        return true
    }
    return false
}

// Usage
func main() {
    limiter := NewRateLimiter(10, 100*time.Millisecond)

    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()

            if limiter.Allow() {
                fmt.Printf("Request %d: allowed\n", id)
            } else {
                fmt.Printf("Request %d: rate limited\n", id)
            }
        }(i)
    }

    wg.Wait()
}
```

**Learning Goal**: Practical application of mutex for rate limiting.

---

### Extension 3: LRU Cache with RWMutex ⭐⭐⭐

Build a thread-safe LRU (Least Recently Used) cache:

```go
type LRUCache struct {
    mu       sync.RWMutex
    capacity int
    cache    map[string]*list.Element
    lruList  *list.List
}

type entry struct {
    key   string
    value interface{}
}

func NewLRUCache(capacity int) *LRUCache {
    return &LRUCache{
        capacity: capacity,
        cache:    make(map[string]*list.Element),
        lruList:  list.New(),
    }
}

func (c *LRUCache) Get(key string) (interface{}, bool) {
    c.mu.Lock()
    defer c.mu.Unlock()

    if elem, ok := c.cache[key]; ok {
        c.lruList.MoveToFront(elem)
        return elem.Value.(*entry).value, true
    }
    return nil, false
}

func (c *LRUCache) Put(key string, value interface{}) {
    c.mu.Lock()
    defer c.mu.Unlock()

    if elem, ok := c.cache[key]; ok {
        c.lruList.MoveToFront(elem)
        elem.Value.(*entry).value = value
        return
    }

    if c.lruList.Len() >= c.capacity {
        // Evict LRU
        oldest := c.lruList.Back()
        if oldest != nil {
            c.lruList.Remove(oldest)
            delete(c.cache, oldest.Value.(*entry).key)
        }
    }

    elem := c.lruList.PushFront(&entry{key, value})
    c.cache[key] = elem
}

// Usage with benchmarking
func benchmarkLRU() {
    cache := NewLRUCache(100)
    var wg sync.WaitGroup

    // Concurrent reads and writes
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()

            // 90% reads, 10% writes
            if id%10 == 0 {
                cache.Put(fmt.Sprintf("key%d", id), id)
            } else {
                cache.Get(fmt.Sprintf("key%d", id%100))
            }
        }(i)
    }

    wg.Wait()
}
```

**Learning Goal**: Complex data structure with thread-safety and eviction policy.

---

### Extension 4: Metrics Aggregator with sync.Pool ⭐⭐⭐

Build a high-performance metrics collection system:

```go
type MetricBatch struct {
    Metrics []Metric
}

var metricPool = sync.Pool{
    New: func() interface{} {
        return &MetricBatch{
            Metrics: make([]Metric, 0, 100),
        }
    },
}

type Metric struct {
    Name      string
    Value     float64
    Timestamp time.Time
}

type MetricsAggregator struct {
    mu      sync.Mutex
    batches []*MetricBatch
}

func (ma *MetricsAggregator) RecordMetric(name string, value float64) {
    batch := metricPool.Get().(*MetricBatch)
    batch.Metrics = append(batch.Metrics, Metric{
        Name:      name,
        Value:     value,
        Timestamp: time.Now(),
    })

    if len(batch.Metrics) >= 100 {
        ma.flush(batch)
    }
}

func (ma *MetricsAggregator) flush(batch *MetricBatch) {
    ma.mu.Lock()
    defer ma.mu.Unlock()

    // Process metrics
    for _, metric := range batch.Metrics {
        processMetric(metric)
    }

    // Return batch to pool
    batch.Metrics = batch.Metrics[:0] // Reset slice
    metricPool.Put(batch)
}

// Benchmark allocation reduction
func BenchmarkMetricsWithPool(b *testing.B) {
    agg := &MetricsAggregator{}

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            agg.RecordMetric("cpu", 42.5)
        }
    })
}

func BenchmarkMetricsWithoutPool(b *testing.B) {
    agg := &MetricsAggregator{}

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            // Create new batch every time (no pooling)
            batch := &MetricBatch{
                Metrics: make([]Metric, 0, 100),
            }
            batch.Metrics = append(batch.Metrics, Metric{
                Name:  "cpu",
                Value: 42.5,
            })
        }
    })
}
```

**Learning Goal**: Using sync.Pool for high-throughput systems to reduce GC pressure.

---

### Extension 5: Deadlock Detector ⭐⭐⭐⭐

Implement a deadlock detection system using timeout-based monitoring:

```go
type MonitoredMutex struct {
    mu      sync.Mutex
    name    string
    holder  string
    timeout time.Duration
}

func NewMonitoredMutex(name string, timeout time.Duration) *MonitoredMutex {
    return &MonitoredMutex{
        name:    name,
        timeout: timeout,
    }
}

func (m *MonitoredMutex) Lock(caller string) error {
    lockChan := make(chan struct{})

    go func() {
        m.mu.Lock()
        m.holder = caller
        close(lockChan)
    }()

    select {
    case <-lockChan:
        return nil
    case <-time.After(m.timeout):
        return fmt.Errorf("deadlock suspected: %s waiting for lock %s held by %s",
            caller, m.name, m.holder)
    }
}

func (m *MonitoredMutex) Unlock() {
    m.holder = ""
    m.mu.Unlock()
}

// Deadlock detection example
func detectDeadlock() {
    mu1 := NewMonitoredMutex("mutex1", 100*time.Millisecond)
    mu2 := NewMonitoredMutex("mutex2", 100*time.Millisecond)

    go func() {
        mu1.Lock("goroutine1")
        time.Sleep(50 * time.Millisecond)
        if err := mu2.Lock("goroutine1"); err != nil {
            fmt.Println("Deadlock detected:", err)
        }
        mu2.Unlock()
        mu1.Unlock()
    }()

    go func() {
        mu2.Lock("goroutine2")
        time.Sleep(50 * time.Millisecond)
        if err := mu1.Lock("goroutine2"); err != nil {
            fmt.Println("Deadlock detected:", err)
        }
        mu1.Unlock()
        mu2.Unlock()
    }()

    time.Sleep(200 * time.Millisecond)
}
```

**Learning Goal**: Advanced mutex instrumentation and deadlock prevention strategies.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear separation: synchronization primitives vs business logic
- Type-safe wrappers around sync primitives
- Proper use of defer for Unlock
- No mutex copying (always use pointers)

**Synchronization Patterns**:
- Always use `defer mu.Unlock()` after `mu.Lock()`
- WaitGroup.Add before launching goroutines
- Document lock ordering for multiple mutexes
- Use RWMutex for read-heavy workloads

**Testing Approach**:
- Table-driven tests for different concurrency levels
- Race condition detection (`go test -race`)
- Deadlock tests with timeouts
- Performance benchmarks comparing strategies

**Documentation**:
- Explain thread-safety guarantees
- Document lock ordering requirements
- Clarify when to use mutex vs channel
- Note any performance characteristics

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

**Approach 1: Struct with Embedded Mutex**:
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}
```

**Approach 2: Separate Mutex Variable**:
```go
var (
    counter int
    mu      sync.Mutex
)

func Increment() {
    mu.Lock()
    defer mu.Unlock()
    counter++
}
```

Both are valid; Approach 1 is preferred for better encapsulation.

### Performance Expectations

- Thread-safe operations should be fast (< 1µs for mutex lock/unlock)
- RWMutex should show significant speedup for read-heavy workloads (>5x)
- sync.Pool should reduce allocations by >90%
- No goroutine leaks or deadlocks
- Proper cleanup on shutdown

---

## Learning Resources

### Official Go Documentation
- [Package sync](https://pkg.go.dev/sync)
- [sync.WaitGroup](https://pkg.go.dev/sync#WaitGroup)
- [sync.Mutex](https://pkg.go.dev/sync#Mutex)
- [sync.RWMutex](https://pkg.go.dev/sync#RWMutex)
- [sync.Once](https://pkg.go.dev/sync#Once)
- [sync.Pool](https://pkg.go.dev/sync#Pool)

### Articles and Tutorials
- [Go Blog: Share Memory By Communicating](https://go.dev/blog/codelab-share)
- [Mutex or Channel](https://github.com/golang/go/wiki/MutexOrChannel)
- [Common Mistakes with sync](https://go101.org/article/concurrent-synchronization-more.html)
- [Understanding sync.Pool](https://www.akshaydeo.com/blog/2017/12/23/How-did-I-improve-latency-by-700-percent-using-syncPool/)

### Books
- *The Go Programming Language* (Chapter 9: Concurrency with Shared Variables)
- *Concurrency in Go* by Katherine Cox-Buday (Chapter 3: Go's Concurrency Building Blocks)
- *Go in Action* (Chapter 6: Concurrency)

### Video Resources
- [GopherCon 2017: Kavya Joshi - Understanding Channels](https://www.youtube.com/watch?v=KBZlN0izeiY)
- [dotGo 2015: Francesc Campoy - Go Proverbs](https://www.youtube.com/watch?v=PAAkCSZUG1c)

### Related Charm.sh
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Terminal styling for monitoring output

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

# Race condition detection (CRITICAL)
go test -race ./...

# Coverage report
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Benchmarks
go test -bench=. -benchmem ./...

# Run application
go run main.go --workers 10 --cache-size 100

# Monitor mode
go run main.go --monitor --interval 100ms

# Benchmark mode
go run main.go --benchmark mutex,rwmutex,pool
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestThreadSafeCounter
=== RUN   TestThreadSafeCounter/Single_goroutine
=== RUN   TestThreadSafeCounter/Multiple_goroutines
=== RUN   TestThreadSafeCounter/Heavy_contention
--- PASS: TestThreadSafeCounter (1.02s)
    --- PASS: TestThreadSafeCounter/Single_goroutine (0.01s)
    --- PASS: TestThreadSafeCounter/Multiple_goroutines (0.10s)
    --- PASS: TestThreadSafeCounter/Heavy_contention (0.91s)
=== RUN   TestRWMutexCache
--- PASS: TestRWMutexCache (0.15s)
=== RUN   TestSyncOnce
--- PASS: TestSyncOnce (0.02s)
=== RUN   TestSyncPool
--- PASS: TestSyncPool (0.05s)
PASS
coverage: 87.5% of statements
ok      lesson22    1.245s
```

### Race Detection Output

```bash
$ go test -race ./...
PASS
ok      lesson22    2.134s
```

*If race detected:*
```bash
==================
WARNING: DATA RACE
Read at 0x00c0000140a0 by goroutine 8:
  lesson22.(*Counter).Value()
      /path/to/counter.go:25 +0x44

Previous write at 0x00c0000140a0 by goroutine 7:
  lesson22.(*Counter).Increment()
      /path/to/counter.go:15 +0x5a
==================
```

---

**Previous Lesson**: Lesson 21: Channel Patterns - Select, Timeouts, Closing (Phase 4)
**Next Lesson**: Lesson 23: Worker Pools & Pipeline Patterns (Phase 4)
**Phase 4 Milestone**: Lesson 24: Concurrent Web Crawler with Context

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
