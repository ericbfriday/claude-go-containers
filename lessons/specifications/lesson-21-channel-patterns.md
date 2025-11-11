# Lesson 21: Channel Patterns - Select, Timeouts, Closing

**Phase**: 4 - Concurrency Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-20 (Go Fundamentals, CLI Development, Styling with Lip Gloss, Goroutines, Channels)

---

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Master the select statement** - Use select to handle multiple channel operations simultaneously
2. **Implement timeout patterns** - Apply time.After and time.Ticker for timeout and periodic operations
3. **Handle channel closure** - Properly close channels and detect closure in receiving goroutines
4. **Use default cases** - Implement non-blocking channel operations with select default
5. **Range over channels** - Iterate through channel values until closure
6. **Work with nil channels** - Understand and apply nil channel behavior in select statements
7. **Build robust concurrent patterns** - Implement rate limiting, broadcasting, and stream merging
8. **Style concurrent applications** - Apply Lip Gloss styling to channel-based program output (bridging Phase 3)

---

## Prerequisites

### Required Knowledge
- **Phase 1**: Go fundamentals (syntax, functions, structs, interfaces, error handling)
- **Phase 2**: CLI development (flag parsing, file I/O, Cobra framework)
- **Phase 3**: Terminal styling (Lip Gloss basics, layout, theming)
- **Lesson 19**: Goroutines (concurrent execution, goroutine lifecycle)
- **Lesson 20**: Channels (unbuffered/buffered channels, send/receive operations)

### Required Setup
```bash
# Verify Go installation
go version  # Should be 1.18+

# Create lesson directory
mkdir -p ~/go-learning/lesson-21-channel-patterns
cd ~/go-learning/lesson-21-channel-patterns

# Initialize module
go mod init lesson21

# Install dependencies for visualization
go get github.com/charmbracelet/lipgloss@latest
```

### Conceptual Preparation
- Review Lesson 19 (Goroutines) - understanding concurrent execution
- Review Lesson 20 (Channels) - channel send/receive mechanics
- Review Lesson 15 (Lip Gloss) - styling for program output
- Understand blocking vs non-blocking operations

---

## Core Concepts

### 1. The Select Statement

**Definition**: The `select` statement lets a goroutine wait on multiple channel operations, proceeding with whichever is ready first.

**Basic Syntax**:
```go
select {
case msg := <-ch1:
    // Handle message from ch1
    fmt.Println("Received:", msg)
case ch2 <- value:
    // Send value to ch2
    fmt.Println("Sent:", value)
case <-time.After(1 * time.Second):
    // Timeout after 1 second
    fmt.Println("Timeout")
default:
    // Non-blocking operation
    fmt.Println("No channel ready")
}
```

**Select Behavior**:
- **Blocks** until one case can proceed
- If **multiple cases ready**, chooses one at **random**
- If **default case present**, never blocks (non-blocking)
- If **no cases ready and no default**, blocks forever

**Example: Multiplexing Channels**:
```go
func multiplex(ch1, ch2 <-chan string) {
    for {
        select {
        case msg1 := <-ch1:
            fmt.Printf("Channel 1: %s\n", msg1)
        case msg2 := <-ch2:
            fmt.Printf("Channel 2: %s\n", msg2)
        }
    }
}

func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)

    go func() {
        for i := 0; i < 3; i++ {
            ch1 <- fmt.Sprintf("A%d", i)
            time.Sleep(100 * time.Millisecond)
        }
    }()

    go func() {
        for i := 0; i < 3; i++ {
            ch2 <- fmt.Sprintf("B%d", i)
            time.Sleep(150 * time.Millisecond)
        }
    }()

    time.Sleep(1 * time.Second)
}
```

### 2. Timeout Patterns with time.After

**time.After Pattern**:
```go
// time.After returns a channel that sends current time after duration
func fetchWithTimeout(url string) (string, error) {
    result := make(chan string, 1)

    go func() {
        // Simulate network fetch
        time.Sleep(2 * time.Second)
        result <- "Data from " + url
    }()

    select {
    case data := <-result:
        return data, nil
    case <-time.After(1 * time.Second):
        return "", fmt.Errorf("timeout fetching %s", url)
    }
}
```

**Multiple Timeout Stages**:
```go
func fetchWithRetry(url string) (string, error) {
    const attempts = 3
    const timeout = 500 * time.Millisecond

    for i := 0; i < attempts; i++ {
        select {
        case result := <-fetch(url):
            return result, nil
        case <-time.After(timeout):
            if i == attempts-1 {
                return "", fmt.Errorf("failed after %d attempts", attempts)
            }
            fmt.Printf("Attempt %d failed, retrying...\n", i+1)
        }
    }
    return "", nil
}
```

**⚠️ Warning: time.After Memory Leak**:
```go
// ❌ Wrong: Creates new timer each iteration, never garbage collected
for {
    select {
    case msg := <-messages:
        process(msg)
    case <-time.After(5 * time.Minute): // Memory leak!
        cleanup()
    }
}

// ✅ Right: Use time.NewTimer with Reset
timer := time.NewTimer(5 * time.Minute)
defer timer.Stop()

for {
    select {
    case msg := <-messages:
        process(msg)
        timer.Reset(5 * time.Minute) // Reuse timer
    case <-timer.C:
        cleanup()
        return
    }
}
```

### 3. Default Cases in Select (Non-Blocking Operations)

**Non-Blocking Send**:
```go
func trySend(ch chan<- string, msg string) bool {
    select {
    case ch <- msg:
        return true // Successfully sent
    default:
        return false // Channel full or no receiver
    }
}
```

**Non-Blocking Receive**:
```go
func tryReceive(ch <-chan string) (string, bool) {
    select {
    case msg := <-ch:
        return msg, true // Successfully received
    default:
        return "", false // No message available
    }
}
```

**Polling Pattern**:
```go
func pollChannels(ch1, ch2 <-chan string) {
    for {
        select {
        case msg := <-ch1:
            fmt.Println("Ch1:", msg)
        case msg := <-ch2:
            fmt.Println("Ch2:", msg)
        default:
            // No messages, do other work
            fmt.Println("Doing other work...")
            time.Sleep(100 * time.Millisecond)
        }
    }
}
```

**Immediate Status Check**:
```go
func checkStatus(quit <-chan bool) bool {
    select {
    case <-quit:
        return true // Quit signal received
    default:
        return false // Still running
    }
}

func worker(quit <-chan bool) {
    for {
        if checkStatus(quit) {
            fmt.Println("Worker shutting down")
            return
        }

        // Do work
        performTask()
    }
}
```

### 4. Range Over Channels

**Basic Range**:
```go
// range loops until channel is closed
func consumer(ch <-chan int) {
    for value := range ch {
        fmt.Printf("Received: %d\n", value)
    }
    fmt.Println("Channel closed, consumer exiting")
}

func main() {
    ch := make(chan int, 5)

    // Producer
    go func() {
        for i := 1; i <= 5; i++ {
            ch <- i
        }
        close(ch) // Must close or range blocks forever
    }()

    consumer(ch)
}
```

**Range with Processing**:
```go
type Job struct {
    ID   int
    Data string
}

func worker(id int, jobs <-chan Job, results chan<- string) {
    for job := range jobs { // Blocks until channel closed
        fmt.Printf("Worker %d processing job %d\n", id, job.ID)
        result := process(job)
        results <- result
    }
    fmt.Printf("Worker %d finished (channel closed)\n", id)
}
```

**Range vs Select**:
```go
// Range: Simple iteration until closed
for msg := range messages {
    process(msg)
}

// Select: Multiple channels or timeout
for {
    select {
    case msg := <-messages:
        process(msg)
    case <-time.After(5 * time.Second):
        fmt.Println("No messages for 5 seconds")
        return
    }
}
```

### 5. Detecting and Handling Closed Channels

**Detecting Closure with Comma-OK Idiom**:
```go
func receiver(ch <-chan string) {
    for {
        msg, ok := <-ch
        if !ok {
            fmt.Println("Channel closed")
            return
        }
        fmt.Printf("Received: %s\n", msg)
    }
}
```

**Closure in Select**:
```go
func handleMultiple(ch1, ch2 <-chan string) {
    ch1Open := true
    ch2Open := true

    for ch1Open || ch2Open {
        select {
        case msg, ok := <-ch1:
            if !ok {
                fmt.Println("Ch1 closed")
                ch1Open = false
                continue
            }
            fmt.Printf("Ch1: %s\n", msg)

        case msg, ok := <-ch2:
            if !ok {
                fmt.Println("Ch2 closed")
                ch2Open = false
                continue
            }
            fmt.Printf("Ch2: %s\n", msg)
        }
    }
    fmt.Println("All channels closed")
}
```

**⚠️ Closure Rules**:
```go
// ✅ Only sender should close
func producer(ch chan<- int) {
    for i := 0; i < 5; i++ {
        ch <- i
    }
    close(ch) // Producer closes after sending all
}

// ❌ Never close from receiver
func consumer(ch <-chan int) {
    for v := range ch {
        fmt.Println(v)
    }
    // close(ch) // Compile error: cannot close receive-only channel
}

// ❌ Never close more than once
ch := make(chan int)
close(ch)
close(ch) // Panic: close of closed channel

// ❌ Never send on closed channel
ch := make(chan int)
close(ch)
ch <- 1 // Panic: send on closed channel

// ✅ Receiving from closed channel returns zero value
ch := make(chan int)
close(ch)
v := <-ch // v = 0, no panic
```

### 6. Nil Channels in Select

**Nil Channel Behavior**:
```go
var ch chan int  // nil channel
ch <- 1          // Blocks forever
v := <-ch        // Blocks forever
close(ch)        // Panic: close of nil channel
```

**Disabling Cases with Nil**:
```go
func mergeChannels(ch1, ch2 <-chan string) <-chan string {
    out := make(chan string)

    go func() {
        defer close(out)

        for ch1 != nil || ch2 != nil {
            select {
            case msg, ok := <-ch1:
                if !ok {
                    ch1 = nil // Disable this case
                    continue
                }
                out <- msg

            case msg, ok := <-ch2:
                if !ok {
                    ch2 = nil // Disable this case
                    continue
                }
                out <- msg
            }
        }
    }()

    return out
}
```

**Dynamic Case Enabling**:
```go
func conditionalSelect(inputCh <-chan int, enableOutput bool) {
    var outputCh chan<- int
    if enableOutput {
        outputCh = make(chan int)
    }
    // If enableOutput is false, outputCh is nil

    for {
        select {
        case v := <-inputCh:
            fmt.Printf("Input: %d\n", v)

        case outputCh <- 42: // Disabled if outputCh is nil
            fmt.Println("Output sent")

        case <-time.After(1 * time.Second):
            return
        }
    }
}
```

### 7. Rate Limiting with time.Ticker

**Basic Rate Limiting**:
```go
func rateLimitedWorker(requests <-chan string) {
    ticker := time.NewTicker(200 * time.Millisecond)
    defer ticker.Stop()

    for req := range requests {
        <-ticker.C // Wait for tick (rate limit)
        fmt.Printf("Processing: %s at %v\n", req, time.Now())
        process(req)
    }
}

func main() {
    requests := make(chan string, 5)

    // Send burst of requests
    go func() {
        for i := 1; i <= 5; i++ {
            requests <- fmt.Sprintf("Request-%d", i)
        }
        close(requests)
    }()

    rateLimitedWorker(requests)
}
// Output: One request processed every 200ms
```

**Bursty Rate Limiting**:
```go
func burstyRateLimiter(requests <-chan string) {
    // Allow bursts of 3, then rate limit
    limiter := make(chan time.Time, 3)

    // Pre-fill burst capacity
    for i := 0; i < 3; i++ {
        limiter <- time.Now()
    }

    // Refill at rate
    go func() {
        ticker := time.NewTicker(200 * time.Millisecond)
        defer ticker.Stop()

        for t := range ticker.C {
            select {
            case limiter <- t:
            default: // Buffer full, drop
            }
        }
    }()

    // Process with rate limiting
    for req := range requests {
        <-limiter // Get token
        fmt.Printf("Processing: %s\n", req)
        process(req)
    }
}
```

**Ticker vs Timer**:
```go
// Ticker: Periodic events
ticker := time.NewTicker(1 * time.Second)
defer ticker.Stop()

for range ticker.C {
    fmt.Println("Tick") // Every second
}

// Timer: Single event
timer := time.NewTimer(5 * time.Second)
defer timer.Stop()

<-timer.C
fmt.Println("Timer fired") // Once after 5 seconds
```

### 8. Merging Multiple Channel Streams

**Simple Fan-In (Merge)**:
```go
func merge(channels ...<-chan string) <-chan string {
    out := make(chan string)
    var wg sync.WaitGroup

    // Start a goroutine for each input channel
    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan string) {
            defer wg.Done()
            for v := range c {
                out <- v
            }
        }(ch)
    }

    // Close output when all inputs drained
    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

func main() {
    ch1 := generate("A", 3)
    ch2 := generate("B", 3)
    ch3 := generate("C", 3)

    merged := merge(ch1, ch2, ch3)

    for msg := range merged {
        fmt.Println(msg)
    }
}
```

**Select-Based Merge**:
```go
func mergeTwo(ch1, ch2 <-chan string) <-chan string {
    out := make(chan string)

    go func() {
        defer close(out)

        for ch1 != nil || ch2 != nil {
            select {
            case msg, ok := <-ch1:
                if !ok {
                    ch1 = nil
                    continue
                }
                out <- msg

            case msg, ok := <-ch2:
                if !ok {
                    ch2 = nil
                    continue
                }
                out <- msg
            }
        }
    }()

    return out
}
```

### 9. Broadcasting to Multiple Receivers

**Fan-Out Pattern**:
```go
func fanOut(in <-chan int, outputs ...chan<- int) {
    for v := range in {
        // Send to all output channels
        for _, out := range outputs {
            out <- v
        }
    }

    // Close all outputs when input closes
    for _, out := range outputs {
        close(out)
    }
}

func main() {
    input := make(chan int)
    out1 := make(chan int)
    out2 := make(chan int)
    out3 := make(chan int)

    go fanOut(input, out1, out2, out3)

    // Receivers
    go receiver("R1", out1)
    go receiver("R2", out2)
    go receiver("R3", out3)

    // Send data
    for i := 1; i <= 5; i++ {
        input <- i
    }
    close(input)

    time.Sleep(1 * time.Second)
}

func receiver(name string, ch <-chan int) {
    for v := range ch {
        fmt.Printf("%s received: %d\n", name, v)
    }
}
```

**Pub-Sub Pattern with Select**:
```go
type Message struct {
    Content string
}

type Subscriber struct {
    id   int
    ch   chan Message
    quit chan bool
}

type PubSub struct {
    subscribers map[int]*Subscriber
    mu          sync.RWMutex
    nextID      int
}

func NewPubSub() *PubSub {
    return &PubSub{
        subscribers: make(map[int]*Subscriber),
    }
}

func (ps *PubSub) Subscribe() *Subscriber {
    ps.mu.Lock()
    defer ps.mu.Unlock()

    sub := &Subscriber{
        id:   ps.nextID,
        ch:   make(chan Message, 10),
        quit: make(chan bool),
    }
    ps.subscribers[ps.nextID] = sub
    ps.nextID++

    return sub
}

func (ps *PubSub) Publish(msg Message) {
    ps.mu.RLock()
    defer ps.mu.RUnlock()

    for _, sub := range ps.subscribers {
        select {
        case sub.ch <- msg:
            // Sent successfully
        case <-time.After(100 * time.Millisecond):
            // Timeout, subscriber slow
            fmt.Printf("Subscriber %d timeout\n", sub.id)
        }
    }
}

func (s *Subscriber) Receive() <-chan Message {
    return s.ch
}
```

### 10. Styling Channel Operations (Bridging Phase 3)

**Using Lip Gloss for Channel Visualization**:
```go
import (
    "fmt"
    "time"

    "github.com/charmbracelet/lipgloss"
)

var (
    sentStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("42")).
        Bold(true).
        Prefix("→ ")

    receivedStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("205")).
        Bold(true).
        Prefix("← ")

    timeoutStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("208")).
        Bold(true).
        Prefix("⏱  ")

    closedStyle = lipgloss.NewStyle().
        Foreground(lipgloss.Color("240")).
        Italic(true).
        Prefix("✗ ")
)

func styledChannelDemo() {
    messages := make(chan string, 3)

    // Sender
    go func() {
        for i := 1; i <= 5; i++ {
            msg := fmt.Sprintf("Message %d", i)
            messages <- msg
            fmt.Println(sentStyle.Render(msg))
            time.Sleep(200 * time.Millisecond)
        }
        close(messages)
        fmt.Println(closedStyle.Render("Channel closed"))
    }()

    // Receiver with timeout
    for {
        select {
        case msg, ok := <-messages:
            if !ok {
                return
            }
            fmt.Println(receivedStyle.Render(msg))

        case <-time.After(1 * time.Second):
            fmt.Println(timeoutStyle.Render("Timeout waiting for message"))
            return
        }
    }
}
```

**Dashboard for Channel Monitoring**:
```go
type ChannelStats struct {
    Sent      int
    Received  int
    Timeout   int
    Active    bool
}

func renderDashboard(stats *ChannelStats) {
    titleStyle := lipgloss.NewStyle().
        Bold(true).
        Foreground(lipgloss.Color("86")).
        Background(lipgloss.Color("235")).
        Padding(0, 1)

    statsStyle := lipgloss.NewStyle().
        Border(lipgloss.RoundedBorder()).
        BorderForeground(lipgloss.Color("63")).
        Padding(1, 2)

    title := titleStyle.Render("Channel Monitor")

    statusIcon := "🔴"
    if stats.Active {
        statusIcon = "🟢"
    }

    statsContent := fmt.Sprintf(
        "Status: %s\n"+
            "Messages Sent:     %d\n"+
            "Messages Received: %d\n"+
            "Timeouts:          %d\n",
        statusIcon, stats.Sent, stats.Received, stats.Timeout,
    )

    dashboard := lipgloss.JoinVertical(
        lipgloss.Center,
        title,
        statsStyle.Render(statsContent),
    )

    fmt.Print("\033[H\033[2J") // Clear screen
    fmt.Println(dashboard)
}
```

### 11. Performance Considerations

**Select Performance**:
```go
// Select with many cases has O(n) overhead
// For very high performance, consider:

// ✅ Good: Small number of cases
select {
case msg := <-ch1:
case msg := <-ch2:
case msg := <-ch3:
}

// ⚠️  Caution: Many cases (>10)
select {
case msg := <-channels[0]:
case msg := <-channels[1]:
// ... 100 more cases
}

// ✅ Better: Use reflection or fan-in
merged := merge(channels...)
for msg := range merged {
    process(msg)
}
```

**Buffered Channels for Performance**:
```go
// Unbuffered: Sender blocks until receiver ready
ch := make(chan int)

// Buffered: Sender blocks only when buffer full
ch := make(chan int, 100)

// Use buffered channels to reduce blocking:
// - Known message burst sizes
// - Asynchronous processing
// - Decoupling producer/consumer rates
```

---

## Challenge Description

Build a **Concurrent Event Dispatcher** that demonstrates advanced channel patterns with styled terminal output.

### Project Overview

Create a CLI application that:
1. Multiplexes events from multiple sources using select
2. Implements timeout handling for event processing
3. Provides rate limiting for outbound events
4. Broadcasts events to multiple subscribers
5. Merges multiple event streams
6. Uses Lip Gloss to create a real-time event dashboard
7. Demonstrates robust channel closure handling

### Functional Requirements

**Core Features**:
```bash
# Run event dispatcher with monitoring
go run main.go --sources 3 --subscribers 5

# Run with rate limiting
go run main.go --rate-limit 10/second

# Run with timeout handling
go run main.go --timeout 2s

# Demonstrate different patterns
go run main.go --pattern fan-in
go run main.go --pattern fan-out
go run main.go --pattern pub-sub
```

**Expected Output**:
```
╔══════════════════════════════════════════════════╗
║         Concurrent Event Dispatcher v1.0         ║
╚══════════════════════════════════════════════════╝

Configuration:
  Sources:      3
  Subscribers:  5
  Rate Limit:   10 events/sec
  Timeout:      2s
  Pattern:      pub-sub

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Event Flow (Live):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Source 1: Event-A1
→ Source 2: Event-B1
← Subscriber 1: Received Event-A1
← Subscriber 2: Received Event-A1
→ Source 3: Event-C1
⏱  Timeout: No events for 2s
← Subscriber 3: Received Event-B1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Events Generated:     150
Events Dispatched:    150
Events Delivered:     750 (5 subscribers)
Timeouts:             3
Rate (events/sec):    9.8
Active Channels:      8
```

### Implementation Requirements

**Project Structure**:
```
lesson-21-channel-patterns/
├── main.go                 # CLI entry point
├── event/
│   ├── event.go            # Event struct and types
│   ├── source.go           # Event source (producer)
│   └── subscriber.go       # Event subscriber (consumer)
├── dispatcher/
│   ├── dispatcher.go       # Main dispatcher with select
│   ├── fanin.go            # Fan-in pattern implementation
│   ├── fanout.go           # Fan-out pattern implementation
│   └── ratelimit.go        # Rate limiting logic
├── display/
│   ├── styles.go           # Lip Gloss styles
│   └── dashboard.go        # Real-time dashboard
├── patterns/
│   ├── timeout.go          # Timeout patterns
│   ├── merge.go            # Stream merging
│   └── broadcast.go        # Broadcasting patterns
└── main_test.go
```

**Event Types**:
```go
type Event struct {
    ID        string
    Source    string
    Timestamp time.Time
    Data      interface{}
}

type EventSource interface {
    Events() <-chan Event
    Close()
}

type EventSubscriber interface {
    Receive() <-chan Event
    Unsubscribe()
}
```

**Dispatcher Requirements**:
- Use select to multiplex multiple event sources
- Implement timeout for event reception
- Apply rate limiting to outbound events
- Support dynamic subscriber addition/removal
- Handle graceful shutdown with channel closure
- Track and display statistics

---

## Test Requirements

### Table-Driven Test Structure

```go
func TestSelectTimeout(t *testing.T) {
    tests := []struct {
        name           string
        sendDelay      time.Duration
        timeout        time.Duration
        wantReceived   bool
        wantTimeout    bool
    }{
        {
            name:         "Message before timeout",
            sendDelay:    50 * time.Millisecond,
            timeout:      100 * time.Millisecond,
            wantReceived: true,
            wantTimeout:  false,
        },
        {
            name:         "Timeout before message",
            sendDelay:    200 * time.Millisecond,
            timeout:      100 * time.Millisecond,
            wantReceived: false,
            wantTimeout:  true,
        },
        {
            name:         "Message exactly at timeout",
            sendDelay:    100 * time.Millisecond,
            timeout:      100 * time.Millisecond,
            wantReceived: true, // Either is valid, but typically receives
            wantTimeout:  false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            ch := make(chan string, 1)
            received := false
            timedOut := false

            go func() {
                time.Sleep(tt.sendDelay)
                ch <- "message"
            }()

            select {
            case <-ch:
                received = true
            case <-time.After(tt.timeout):
                timedOut = true
            }

            if received != tt.wantReceived {
                t.Errorf("received = %v, want %v", received, tt.wantReceived)
            }
            if timedOut != tt.wantTimeout {
                t.Errorf("timedOut = %v, want %v", timedOut, tt.wantTimeout)
            }
        })
    }
}
```

### Required Test Coverage

| Test Category | Test Cases | Purpose |
|---------------|------------|---------|
| **Select Statement** | 6+ | Test multiple channel operations |
| **Timeout Patterns** | 5+ | Verify timeout behavior |
| **Channel Closure** | 5+ | Test proper closure detection |
| **Default Cases** | 4+ | Non-blocking operations |
| **Range Operations** | 4+ | Iterate until closure |
| **Nil Channels** | 3+ | Case disabling with nil |
| **Rate Limiting** | 4+ | Verify rate control |
| **Fan-In/Fan-Out** | 6+ | Stream merging and broadcasting |

### Specific Test Scenarios

**Channel Closure Detection**:
```go
func TestChannelClosure(t *testing.T) {
    ch := make(chan int, 3)

    // Send and close
    ch <- 1
    ch <- 2
    ch <- 3
    close(ch)

    received := []int{}
    closed := false

    for v := range ch {
        received = append(received, v)
    }
    closed = true

    want := []int{1, 2, 3}
    if !reflect.DeepEqual(received, want) {
        t.Errorf("received = %v, want %v", received, want)
    }

    if !closed {
        t.Error("range should exit when channel closed")
    }
}
```

**Nil Channel Behavior**:
```go
func TestNilChannelInSelect(t *testing.T) {
    ch1 := make(chan int, 1)
    ch2 := make(chan int, 1)

    ch1 <- 1
    ch2 <- 2

    results := []int{}

    // Receive from both, disabling with nil
    for ch1 != nil || ch2 != nil {
        select {
        case v, ok := <-ch1:
            if !ok {
                ch1 = nil
                continue
            }
            results = append(results, v)
            close(ch1)

        case v, ok := <-ch2:
            if !ok {
                ch2 = nil
                continue
            }
            results = append(results, v)
            close(ch2)
        }
    }

    if len(results) != 2 {
        t.Errorf("received %d values, want 2", len(results))
    }
}
```

**Rate Limiting**:
```go
func TestRateLimit(t *testing.T) {
    rate := 10 // 10 items per second
    duration := 1 * time.Second

    limiter := time.NewTicker(duration / time.Duration(rate))
    defer limiter.Stop()

    start := time.Now()
    processed := 0

    for i := 0; i < 10; i++ {
        <-limiter.C
        processed++
    }

    elapsed := time.Since(start)

    expectedMin := 900 * time.Millisecond // ~1 second
    expectedMax := 1100 * time.Millisecond

    if elapsed < expectedMin || elapsed > expectedMax {
        t.Errorf("elapsed = %v, want between %v and %v",
            elapsed, expectedMin, expectedMax)
    }

    if processed != 10 {
        t.Errorf("processed = %d, want 10", processed)
    }
}
```

---

## Input/Output Specifications

### Command-Line Interface

**Flags**:
```go
var (
    numSources     = flag.Int("sources", 3, "Number of event sources")
    numSubscribers = flag.Int("subscribers", 5, "Number of subscribers")
    rateLimit      = flag.String("rate-limit", "10/second", "Rate limit (events/duration)")
    timeout        = flag.Duration("timeout", 2*time.Second, "Event timeout")
    pattern        = flag.String("pattern", "pub-sub", "Pattern (fan-in|fan-out|pub-sub|merge)")
    duration       = flag.Duration("duration", 10*time.Second, "Run duration")
    verbose        = flag.Bool("verbose", false, "Verbose event logging")
)
```

### Expected Output Formats

**Standard Execution**:
```
Concurrent Event Dispatcher v1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  Sources:      3
  Subscribers:  5
  Rate Limit:   10 events/sec
  Timeout:      2s
  Pattern:      pub-sub
  Duration:     10s

Starting dispatcher...

Event Flow:
  → Source-1: Event-1 (type: INFO)
  → Source-2: Event-2 (type: DATA)
  ← Sub-1: Received Event-1
  ← Sub-2: Received Event-1
  ← Sub-3: Received Event-1
  → Source-3: Event-3 (type: ALERT)
  ⏱  Timeout: 2s elapsed
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Final Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Events Generated:     103
Events Dispatched:    103
Events Delivered:     515 (5 subscribers)
Timeouts:             2
Average Rate:         10.3 events/sec
Peak Concurrent:      8 goroutines
```

**Verbose Mode**:
```
Event Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Event: Event-42
  ID:        evt-042
  Source:    Source-2
  Timestamp: 2024-01-15 14:23:45.123
  Type:      DATA
  Size:      1024 bytes

  Select Cases Ready: 3
    - Source-1 channel
    - Source-2 channel (chosen)
    - Timeout channel

  Subscribers Notified: 5/5
    ✓ Subscriber-1 (5ms)
    ✓ Subscriber-2 (3ms)
    ✓ Subscriber-3 (7ms)
    ✓ Subscriber-4 (4ms)
    ✓ Subscriber-5 (6ms)
```

### Error Handling Output

```go
// Timeout error
Error: Event timeout
  Source:     Source-2
  Last Event: 2.5s ago
  Timeout:    2s
  Action:     Continuing with other sources

// Channel closed
Info: Channel closed
  Source:     Source-1
  Events:     150 total
  Action:     Removing from select cases

// Subscriber slow
Warning: Subscriber slow
  Subscriber: Sub-3
  Queue Size: 95/100
  Action:     Applying backpressure
```

---

## Success Criteria

### Functional Requirements ✅

- [ ] Select statement multiplexes 3+ channel sources
- [ ] Timeout pattern correctly handles delayed events
- [ ] Default case provides non-blocking operations
- [ ] Range properly iterates until channel closure
- [ ] Closed channels detected with comma-ok idiom
- [ ] Nil channels used to disable select cases
- [ ] Rate limiting maintains specified rate (±10%)
- [ ] Fan-in pattern merges multiple streams
- [ ] Fan-out pattern broadcasts to multiple receivers

### Code Quality ✅

- [ ] All code passes `go fmt` (formatting)
- [ ] All code passes `go vet` (correctness)
- [ ] All code passes `staticcheck` (style)
- [ ] No race conditions detected (`go test -race`)
- [ ] Proper channel closure (only sender closes)
- [ ] No goroutine leaks after shutdown
- [ ] Select cases handle all channel states

### Testing ✅

- [ ] Table-driven tests for select patterns
- [ ] Test coverage >80% (`go test -cover`)
- [ ] Timeout behavior tested with time control
- [ ] Channel closure tested in all scenarios
- [ ] Rate limiting verified with timing tests
- [ ] Fan-in/fan-out patterns validated

### Documentation ✅

- [ ] README explains channel patterns used
- [ ] Select statement logic documented
- [ ] Timeout strategies explained
- [ ] Closure protocol documented
- [ ] Rate limiting algorithm described

### Performance ✅

- [ ] Rate limiting accurate within 10%
- [ ] Select overhead minimal (<1ms per operation)
- [ ] No channel buffer exhaustion
- [ ] Graceful degradation under load
- [ ] Proper cleanup on shutdown

---

## Common Pitfalls

### ❌ Pitfall 1: Select with All Channels Nil

**Wrong**:
```go
func broken() {
    var ch1, ch2 chan int // Both nil

    select {
    case <-ch1: // Never ready
    case <-ch2: // Never ready
    }
    // Deadlock! No cases ever ready
}
```

**Right**:
```go
func correct() {
    ch1 := make(chan int)
    var ch2 chan int // Nil, but we have timeout

    go func() {
        time.Sleep(100 * time.Millisecond)
        ch1 <- 42
    }()

    select {
    case v := <-ch1:
        fmt.Println("Received:", v)
    case <-ch2: // Never ready (nil)
    case <-time.After(1 * time.Second):
        fmt.Println("Timeout")
    }
}
```

**Why**: Select with all nil channels and no default blocks forever (deadlock).

---

### ❌ Pitfall 2: Leaking Goroutines with time.After

**Wrong**:
```go
func leak() {
    for {
        select {
        case msg := <-messages:
            process(msg)
        case <-time.After(5 * time.Minute): // New timer every iteration!
            cleanup()
        }
    }
}
// Memory leak: timers accumulate in memory
```

**Right**:
```go
func noLeak() {
    timer := time.NewTimer(5 * time.Minute)
    defer timer.Stop()

    for {
        select {
        case msg := <-messages:
            process(msg)
            if !timer.Stop() {
                <-timer.C
            }
            timer.Reset(5 * time.Minute) // Reuse timer

        case <-timer.C:
            cleanup()
            return
        }
    }
}
```

**Why**: `time.After` creates a new timer each call. In loops, this causes memory leaks.

---

### ❌ Pitfall 3: Sending on Closed Channel

**Wrong**:
```go
func dangerous() {
    ch := make(chan int)
    close(ch)
    ch <- 42 // Panic: send on closed channel
}
```

**Right**:
```go
func safe() {
    ch := make(chan int)
    done := make(chan bool)

    go func() {
        defer close(ch) // Close after sending done
        for i := 0; i < 5; i++ {
            select {
            case ch <- i:
                // Sent successfully
            case <-done:
                return // Exit before close
            }
        }
    }()

    // Receiver signals completion
    time.Sleep(100 * time.Millisecond)
    close(done)
}
```

**Why**: Sending on closed channel panics. Only close from sender, and ensure sends complete first.

---

### ❌ Pitfall 4: Closing Channel from Wrong Goroutine

**Wrong**:
```go
func wrongClose() {
    ch := make(chan int)

    // Multiple senders
    go func() {
        ch <- 1
        close(ch) // ❌ Wrong: sender 1 closes
    }()

    go func() {
        ch <- 2 // May panic if ch already closed
    }()
}
```

**Right**:
```go
func rightClose() {
    ch := make(chan int)
    done := make(chan bool)
    var wg sync.WaitGroup

    // Multiple senders
    for i := 0; i < 2; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            select {
            case ch <- id:
            case <-done:
            }
        }(i)
    }

    // Coordinator closes
    go func() {
        wg.Wait()  // Wait for all senders
        close(ch)  // ✅ Right: coordinator closes
    }()
}
```

**Why**: Only one goroutine should close a channel. Usually a coordinator or the last sender.

---

### ❌ Pitfall 5: Forgetting to Handle Channel Closure in Select

**Wrong**:
```go
func badLoop(ch <-chan int) {
    for {
        select {
        case v := <-ch: // Doesn't check if closed
            fmt.Println(v)
        }
    }
}
// Infinite loop of zero values after channel closes
```

**Right**:
```go
func goodLoop(ch <-chan int) {
    for {
        select {
        case v, ok := <-ch:
            if !ok {
                fmt.Println("Channel closed")
                return
            }
            fmt.Println(v)
        }
    }
}
```

**Why**: Reading from closed channel returns zero value. Check with comma-ok to detect closure.

---

### ❌ Pitfall 6: Select Default Making Everything Non-Blocking

**Wrong**:
```go
func cpuSpin() {
    for {
        select {
        case msg := <-messages:
            process(msg)
        default:
            // Busy loop! CPU at 100%
        }
    }
}
```

**Right**:
```go
func efficient() {
    for {
        select {
        case msg := <-messages:
            process(msg)
        case <-time.After(100 * time.Millisecond):
            // Do periodic work
            checkStatus()
        }
    }
}
```

**Why**: Default case makes select never block, creating CPU-consuming busy loop.

---

## Extension Challenges

### Extension 1: Priority Channel Selection ⭐⭐

Implement priority-based channel selection where high-priority channels are checked first:

```go
type PriorityDispatcher struct {
    high   <-chan Event
    medium <-chan Event
    low    <-chan Event
}

func (pd *PriorityDispatcher) Dispatch() Event {
    // Always check high priority first
    select {
    case event := <-pd.high:
        return event
    default:
        // High not ready, check medium
        select {
        case event := <-pd.medium:
            return event
        default:
            // Medium not ready, check low or block
            select {
            case event := <-pd.high: // Re-check high
                return event
            case event := <-pd.medium: // Re-check medium
                return event
            case event := <-pd.low:
                return event
            }
        }
    }
}

// Usage
func main() {
    high := make(chan Event, 10)
    medium := make(chan Event, 10)
    low := make(chan Event, 10)

    dispatcher := &PriorityDispatcher{high, medium, low}

    go generateEvents(high, "HIGH", 100*time.Millisecond)
    go generateEvents(medium, "MEDIUM", 200*time.Millisecond)
    go generateEvents(low, "LOW", 300*time.Millisecond)

    for i := 0; i < 20; i++ {
        event := dispatcher.Dispatch()
        fmt.Printf("Priority: %s, Event: %s\n", event.Priority, event.Data)
    }
}
```

**Learning Goal**: Understand nested select statements and priority handling.

---

### Extension 2: Adaptive Timeout Pattern ⭐⭐⭐

Create a system that adjusts timeout durations based on success/failure history:

```go
type AdaptiveTimeout struct {
    baseTimeout    time.Duration
    currentTimeout time.Duration
    successCount   int
    failureCount   int
    mu             sync.Mutex
}

func NewAdaptiveTimeout(base time.Duration) *AdaptiveTimeout {
    return &AdaptiveTimeout{
        baseTimeout:    base,
        currentTimeout: base,
    }
}

func (at *AdaptiveTimeout) Execute(fn func() error) error {
    at.mu.Lock()
    timeout := at.currentTimeout
    at.mu.Unlock()

    done := make(chan error, 1)
    go func() {
        done <- fn()
    }()

    select {
    case err := <-done:
        at.recordSuccess()
        return err

    case <-time.After(timeout):
        at.recordFailure()
        return fmt.Errorf("timeout after %v", timeout)
    }
}

func (at *AdaptiveTimeout) recordSuccess() {
    at.mu.Lock()
    defer at.mu.Unlock()

    at.successCount++
    at.failureCount = 0

    // Reduce timeout after consecutive successes
    if at.successCount >= 5 {
        at.currentTimeout = time.Duration(float64(at.currentTimeout) * 0.9)
        if at.currentTimeout < at.baseTimeout/2 {
            at.currentTimeout = at.baseTimeout / 2
        }
        at.successCount = 0
    }
}

func (at *AdaptiveTimeout) recordFailure() {
    at.mu.Lock()
    defer at.mu.Unlock()

    at.failureCount++
    at.successCount = 0

    // Increase timeout after failures
    if at.failureCount >= 3 {
        at.currentTimeout = time.Duration(float64(at.currentTimeout) * 1.5)
        if at.currentTimeout > at.baseTimeout*4 {
            at.currentTimeout = at.baseTimeout * 4
        }
        at.failureCount = 0
    }
}

func (at *AdaptiveTimeout) CurrentTimeout() time.Duration {
    at.mu.Lock()
    defer at.mu.Unlock()
    return at.currentTimeout
}
```

**Learning Goal**: Dynamic timeout adjustment based on runtime behavior.

---

### Extension 3: Circuit Breaker with Select ⭐⭐⭐

Implement a circuit breaker pattern using channels and select:

```go
type CircuitState int

const (
    StateClosed CircuitState = iota
    StateOpen
    StateHalfOpen
)

type CircuitBreaker struct {
    maxFailures  int
    resetTimeout time.Duration

    state        CircuitState
    failures     int
    lastFailTime time.Time
    mu           sync.RWMutex
}

func NewCircuitBreaker(maxFailures int, resetTimeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures:  maxFailures,
        resetTimeout: resetTimeout,
        state:        StateClosed,
    }
}

func (cb *CircuitBreaker) Execute(fn func() error) error {
    cb.mu.RLock()
    state := cb.state
    lastFail := cb.lastFailTime
    cb.mu.RUnlock()

    // Check if we should transition from Open to HalfOpen
    if state == StateOpen && time.Since(lastFail) > cb.resetTimeout {
        cb.mu.Lock()
        cb.state = StateHalfOpen
        state = StateHalfOpen
        cb.mu.Unlock()
    }

    if state == StateOpen {
        return fmt.Errorf("circuit breaker open")
    }

    // Execute with timeout
    done := make(chan error, 1)
    go func() {
        done <- fn()
    }()

    select {
    case err := <-done:
        if err != nil {
            cb.recordFailure()
            return err
        }
        cb.recordSuccess()
        return nil

    case <-time.After(2 * time.Second):
        cb.recordFailure()
        return fmt.Errorf("timeout")
    }
}

func (cb *CircuitBreaker) recordFailure() {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    cb.failures++
    cb.lastFailTime = time.Now()

    if cb.failures >= cb.maxFailures {
        cb.state = StateOpen
        fmt.Println("Circuit breaker opened")
    }
}

func (cb *CircuitBreaker) recordSuccess() {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    cb.failures = 0
    if cb.state == StateHalfOpen {
        cb.state = StateClosed
        fmt.Println("Circuit breaker closed")
    }
}

// Usage
func main() {
    cb := NewCircuitBreaker(3, 5*time.Second)

    for i := 0; i < 10; i++ {
        err := cb.Execute(func() error {
            // Simulate flaky operation
            if rand.Float64() < 0.5 {
                return fmt.Errorf("operation failed")
            }
            return nil
        })

        if err != nil {
            fmt.Printf("Attempt %d: %v\n", i+1, err)
        } else {
            fmt.Printf("Attempt %d: Success\n", i+1)
        }

        time.Sleep(1 * time.Second)
    }
}
```

**Learning Goal**: Resilience patterns with channel-based state management.

---

### Extension 4: Multiplexed Timeout Manager ⭐⭐⭐⭐

Create a manager that handles different timeouts for different operations simultaneously:

```go
type TimeoutManager struct {
    operations map[string]*Operation
    mu         sync.RWMutex
}

type Operation struct {
    ID       string
    Timeout  time.Duration
    Start    time.Time
    Done     chan struct{}
    Timer    *time.Timer
    Callback func(timedOut bool)
}

func NewTimeoutManager() *TimeoutManager {
    return &TimeoutManager{
        operations: make(map[string]*Operation),
    }
}

func (tm *TimeoutManager) Start(id string, timeout time.Duration, callback func(bool)) {
    op := &Operation{
        ID:       id,
        Timeout:  timeout,
        Start:    time.Now(),
        Done:     make(chan struct{}),
        Callback: callback,
    }

    op.Timer = time.AfterFunc(timeout, func() {
        tm.mu.Lock()
        defer tm.mu.Unlock()

        if _, exists := tm.operations[id]; exists {
            callback(true) // Timed out
            delete(tm.operations, id)
        }
    })

    tm.mu.Lock()
    tm.operations[id] = op
    tm.mu.Unlock()
}

func (tm *TimeoutManager) Complete(id string) bool {
    tm.mu.Lock()
    defer tm.mu.Unlock()

    op, exists := tm.operations[id]
    if !exists {
        return false // Already timed out or completed
    }

    op.Timer.Stop()
    close(op.Done)
    op.Callback(false) // Completed successfully
    delete(tm.operations, id)
    return true
}

func (tm *TimeoutManager) MonitorAll() {
    ticker := time.NewTicker(1 * time.Second)
    defer ticker.Stop()

    for range ticker.C {
        tm.mu.RLock()
        fmt.Printf("Active operations: %d\n", len(tm.operations))
        for id, op := range tm.operations {
            elapsed := time.Since(op.Start)
            remaining := op.Timeout - elapsed
            fmt.Printf("  %s: %v remaining\n", id, remaining)
        }
        tm.mu.RUnlock()
    }
}

// Usage with select
func main() {
    manager := NewTimeoutManager()

    go manager.MonitorAll()

    results := make(chan string, 3)

    // Start multiple operations with different timeouts
    manager.Start("op1", 1*time.Second, func(timedOut bool) {
        if timedOut {
            results <- "op1: timeout"
        } else {
            results <- "op1: success"
        }
    })

    manager.Start("op2", 2*time.Second, func(timedOut bool) {
        if timedOut {
            results <- "op2: timeout"
        } else {
            results <- "op2: success"
        }
    })

    manager.Start("op3", 3*time.Second, func(timedOut bool) {
        if timedOut {
            results <- "op3: timeout"
        } else {
            results <- "op3: success"
        }
    })

    // Simulate varying completion times
    go func() {
        time.Sleep(500 * time.Millisecond)
        manager.Complete("op1") // Completes before timeout
    }()

    go func() {
        time.Sleep(2500 * time.Millisecond)
        manager.Complete("op2") // Completes after timeout (no effect)
    }()

    // op3 completes normally
    go func() {
        time.Sleep(2 * time.Second)
        manager.Complete("op3")
    }()

    // Collect results
    for i := 0; i < 3; i++ {
        result := <-results
        fmt.Println(result)
    }
}
```

**Learning Goal**: Complex timeout orchestration across multiple concurrent operations.

---

### Extension 5: Dynamic Channel Pool with Select ⭐⭐⭐⭐

Implement a dynamic pool of channels that grows and shrinks based on load:

```go
type ChannelPool struct {
    channels []chan interface{}
    size     int
    minSize  int
    maxSize  int
    mu       sync.RWMutex

    metrics  PoolMetrics
}

type PoolMetrics struct {
    totalSends    int64
    totalReceives int64
    expansions    int64
    contractions  int64
    mu            sync.Mutex
}

func NewChannelPool(minSize, maxSize int) *ChannelPool {
    pool := &ChannelPool{
        channels: make([]chan interface{}, minSize),
        size:     minSize,
        minSize:  minSize,
        maxSize:  maxSize,
    }

    for i := 0; i < minSize; i++ {
        pool.channels[i] = make(chan interface{}, 10)
    }

    return pool
}

func (cp *ChannelPool) Send(value interface{}) error {
    cp.mu.RLock()
    channels := make([]chan interface{}, len(cp.channels))
    copy(channels, cp.channels)
    cp.mu.RUnlock()

    // Try all channels with select
    cases := make([]reflect.SelectCase, len(channels)+1)
    for i, ch := range channels {
        cases[i] = reflect.SelectCase{
            Dir:  reflect.SelectSend,
            Chan: reflect.ValueOf(ch),
            Send: reflect.ValueOf(value),
        }
    }

    // Add default case
    cases[len(channels)] = reflect.SelectCase{
        Dir: reflect.SelectDefault,
    }

    chosen, _, _ := reflect.Select(cases)

    if chosen == len(channels) {
        // All channels full, try to expand
        if cp.expand() {
            return cp.Send(value) // Retry
        }
        return fmt.Errorf("all channels full")
    }

    cp.metrics.mu.Lock()
    cp.metrics.totalSends++
    cp.metrics.mu.Unlock()

    return nil
}

func (cp *ChannelPool) Receive() (interface{}, error) {
    cp.mu.RLock()
    channels := make([]chan interface{}, len(cp.channels))
    copy(channels, cp.channels)
    cp.mu.RUnlock()

    cases := make([]reflect.SelectCase, len(channels))
    for i, ch := range channels {
        cases[i] = reflect.SelectCase{
            Dir:  reflect.SelectRecv,
            Chan: reflect.ValueOf(ch),
        }
    }

    chosen, value, ok := reflect.Select(cases)
    if !ok {
        return nil, fmt.Errorf("channel %d closed", chosen)
    }

    cp.metrics.mu.Lock()
    cp.metrics.totalReceives++
    cp.metrics.mu.Unlock()

    return value.Interface(), nil
}

func (cp *ChannelPool) expand() bool {
    cp.mu.Lock()
    defer cp.mu.Unlock()

    if cp.size >= cp.maxSize {
        return false
    }

    newChan := make(chan interface{}, 10)
    cp.channels = append(cp.channels, newChan)
    cp.size++

    cp.metrics.mu.Lock()
    cp.metrics.expansions++
    cp.metrics.mu.Unlock()

    fmt.Printf("Pool expanded to %d channels\n", cp.size)
    return true
}

func (cp *ChannelPool) contract() {
    cp.mu.Lock()
    defer cp.mu.Unlock()

    if cp.size <= cp.minSize {
        return
    }

    // Remove last channel if empty
    lastChan := cp.channels[len(cp.channels)-1]
    select {
    case <-lastChan:
        // Channel has data, can't remove
        return
    default:
        // Channel empty, safe to remove
        close(lastChan)
        cp.channels = cp.channels[:len(cp.channels)-1]
        cp.size--

        cp.metrics.mu.Lock()
        cp.metrics.contractions++
        cp.metrics.mu.Unlock()

        fmt.Printf("Pool contracted to %d channels\n", cp.size)
    }
}

func (cp *ChannelPool) AutoScale() {
    ticker := time.NewTicker(5 * time.Second)
    defer ticker.Stop()

    for range ticker.C {
        cp.metrics.mu.Lock()
        sends := cp.metrics.totalSends
        receives := cp.metrics.totalReceives
        cp.metrics.mu.Unlock()

        utilization := float64(sends-receives) / float64(cp.size)

        if utilization > 8.0 { // High pressure
            cp.expand()
        } else if utilization < 2.0 { // Low utilization
            cp.contract()
        }
    }
}
```

**Learning Goal**: Advanced dynamic channel management with reflection-based select.

---

## AI Provider Guidelines

### Implementation Expectations

**Code Structure**:
- Clear separation: event generation vs dispatching vs subscribing
- Proper use of select for channel multiplexing
- Timeout handling without memory leaks (use time.NewTimer)
- Correct channel closure protocol (sender closes, check with comma-ok)

**Channel Patterns**:
- Use select for multiple channel operations
- Apply default case only when non-blocking is intentional
- Use nil channels to disable select cases dynamically
- Always check channel closure with comma-ok in select
- Close channels from sender, not receiver

**Testing Approach**:
- Table-driven tests for different timeout scenarios
- Test channel closure detection and handling
- Verify rate limiting accuracy
- Test nil channel behavior in select
- Validate fan-in and fan-out patterns

**Documentation**:
- Explain select case selection logic
- Document timeout strategies and trade-offs
- Clarify channel closure protocol
- Note when goroutines exit (channel closure)

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

**Approach 1: Select with Timeout**:
```go
select {
case result := <-ch:
    return result, nil
case <-time.After(timeout):
    return nil, fmt.Errorf("timeout")
}
```

**Approach 2: Reusable Timer**:
```go
timer := time.NewTimer(timeout)
defer timer.Stop()

select {
case result := <-ch:
    return result, nil
case <-timer.C:
    return nil, fmt.Errorf("timeout")
}
```

Approach 2 is preferred for loops or repeated operations (avoids memory leaks).

### Performance Expectations

- Select overhead should be minimal (<1ms)
- Rate limiting accurate within ±10%
- No goroutine leaks after shutdown
- Proper cleanup of timers and channels
- Efficient fan-in/fan-out (avoid unnecessary buffering)

---

## Learning Resources

### Official Go Documentation
- [Effective Go: Channels](https://go.dev/doc/effective_go#channels)
- [Go Tour: Select](https://go.dev/tour/concurrency/5)
- [Go Blog: Go Concurrency Patterns: Timing out, moving on](https://go.dev/blog/go-concurrency-patterns-timing-out-and)
- [Package time](https://pkg.go.dev/time)

### Articles and Tutorials
- [Go Concurrency Patterns: Pipelines and cancellation](https://go.dev/blog/pipelines)
- [Advanced Go Concurrency Patterns](https://go.dev/blog/io2013-talk-concurrency)
- [Channel Axioms](https://dave.cheney.net/2014/03/19/channel-axioms) by Dave Cheney
- [Visualizing Concurrency in Go](https://divan.dev/posts/go_concurrency_visualize/)

### Books
- *The Go Programming Language* (Chapter 8: Goroutines and Channels)
- *Concurrency in Go* by Katherine Cox-Buday (Chapters 3-4)
- *Go in Action* (Chapter 6: Concurrency patterns)

### Video Resources
- [GopherCon 2017: Kavya Joshi - Understanding Channels](https://www.youtube.com/watch?v=KBZlN0izeiY)
- [justforfunc: The Context Package](https://www.youtube.com/watch?v=LSzR0VEraWw)

### Related Charm.sh
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Terminal styling (Phase 3 bridge)
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
go run main.go --sources 3 --subscribers 5

# Test different patterns
go run main.go --pattern fan-in
go run main.go --pattern fan-out
go run main.go --pattern pub-sub

# Test rate limiting
go run main.go --rate-limit 10/second --duration 30s

# Test timeout handling
go run main.go --timeout 500ms --verbose

# Performance profiling
go test -bench=. -benchmem ./...
```

### Expected Test Output

```bash
$ go test -v ./...
=== RUN   TestSelectTimeout
=== RUN   TestSelectTimeout/Message_before_timeout
=== RUN   TestSelectTimeout/Timeout_before_message
=== RUN   TestSelectTimeout/Message_exactly_at_timeout
--- PASS: TestSelectTimeout (0.45s)
    --- PASS: TestSelectTimeout/Message_before_timeout (0.06s)
    --- PASS: TestSelectTimeout/Timeout_before_message (0.11s)
    --- PASS: TestSelectTimeout/Message_exactly_at_timeout (0.11s)
=== RUN   TestChannelClosure
--- PASS: TestChannelClosure (0.01s)
=== RUN   TestNilChannelInSelect
--- PASS: TestNilChannelInSelect (0.01s)
=== RUN   TestRateLimit
--- PASS: TestRateLimit (1.02s)
=== RUN   TestFanIn
--- PASS: TestFanIn (0.15s)
=== RUN   TestFanOut
--- PASS: TestFanOut (0.12s)
PASS
coverage: 83.7% of statements
ok      lesson21    1.875s
```

### Race Detection Output

```bash
$ go test -race ./...
PASS
ok      lesson21    2.143s
```

*If race detected:*
```bash
==================
WARNING: DATA RACE
Write at 0x00c0001a0080 by goroutine 8:
  lesson21.(*Dispatcher).broadcast()
      /path/to/file.go:45 +0x88

Previous read at 0x00c0001a0080 by goroutine 7:
  lesson21.(*Dispatcher).getSubscribers()
      /path/to/file.go:52 +0x44
==================
```

---

**Previous Lesson**: Lesson 20: Channels - Unbuffered & Buffered (Phase 4)
**Next Lesson**: Lesson 22: Sync Package - WaitGroups & Mutexes (Phase 4)
**Phase 4 Milestone**: Lesson 24: Context for Cancellation & Deadlines

---

**Navigation**:
- [Back to Curriculum Overview](../README.md)
- [View All Lessons](../LESSON_MANIFEST.md)
- [Phase 4 Overview](../README.md#phase-4-concurrency-fundamentals-weeks-6-7)
