# Lesson 06: Interfaces & Polymorphism

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate

## Learning Objectives

By the end of this lesson, learners will be able to:
- Define interfaces to specify behavior contracts
- Understand implicit interface satisfaction (no "implements" keyword)
- Implement polymorphism through interface types
- Use the empty interface (interface{}) for generic types
- Perform type assertions and type switches for dynamic typing
- Leverage common standard library interfaces (Reader, Writer, Stringer, Error)
- Design flexible systems using interface-based architecture
- Apply interface composition for building complex contracts
- Understand interface values and nil interface semantics

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Completed Lesson 03: Control Flow - If, Switch, Loops
- Completed Lesson 04: Functions & Multiple Returns
- Completed Lesson 05: Structs & Methods
- Understanding of polymorphism concepts from other languages

## Core Concepts

### 1. Interface Definition

**Basic Interface:**
```go
// Interface defines a contract of methods
type Writer interface {
    Write(data []byte) (int, error)
}

// Any type with Write method satisfies Writer interface (implicit)
type FileWriter struct {
    filename string
}

func (f FileWriter) Write(data []byte) (int, error) {
    // Implementation
    return len(data), nil
}

// Usage: FileWriter automatically satisfies Writer
var w Writer = FileWriter{filename: "output.txt"}
```

**Multiple Methods:**
```go
type Shape interface {
    Area() float64
    Perimeter() float64
}

type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r Rectangle) Perimeter() float64 {
    return 2 * (r.Width + r.Height)
}

// Rectangle satisfies Shape interface
var s Shape = Rectangle{Width: 5, Height: 3}
```

### 2. Implicit Satisfaction

**No Explicit Declaration:**
```go
// No "implements" keyword needed!
type Duck struct{}

func (d Duck) Quack() {
    fmt.Println("Quack!")
}

func (d Duck) Walk() {
    fmt.Println("Waddle waddle")
}

type Quacker interface {
    Quack()
}

// Duck satisfies Quacker automatically
var q Quacker = Duck{}
q.Quack()
```

### 3. Interface Composition

**Embedding Interfaces:**
```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// ReadWriter combines both interfaces
type ReadWriter interface {
    Reader
    Writer
}

// Or explicitly:
type ReadWriter interface {
    Read(p []byte) (n int, err error)
    Write(p []byte) (n int, err error)
}
```

### 4. Empty Interface

**interface{} - Any Type:**
```go
// Empty interface satisfied by all types
func PrintAnything(value interface{}) {
    fmt.Println(value)
}

PrintAnything(42)
PrintAnything("hello")
PrintAnything([]int{1, 2, 3})

// Slice of any type
func Process(items ...interface{}) {
    for _, item := range items {
        fmt.Printf("%v ", item)
    }
}
```

**any Alias (Go 1.18+):**
```go
// 'any' is an alias for interface{}
func PrintValue(value any) {
    fmt.Println(value)
}
```

### 5. Type Assertions

**Asserting Concrete Type:**
```go
var i interface{} = "hello"

// Type assertion (panics if wrong type)
s := i.(string)
fmt.Println(s)  // "hello"

// Safe type assertion (returns ok boolean)
s, ok := i.(string)
if ok {
    fmt.Println("String:", s)
} else {
    fmt.Println("Not a string")
}

// Wrong type assertion
n, ok := i.(int)
// n = 0 (zero value), ok = false
```

### 6. Type Switch

**Switching on Type:**
```go
func Describe(i interface{}) string {
    switch v := i.(type) {
    case int:
        return fmt.Sprintf("Integer: %d", v)
    case string:
        return fmt.Sprintf("String: %s", v)
    case bool:
        return fmt.Sprintf("Boolean: %t", v)
    case []int:
        return fmt.Sprintf("Int slice: %v", v)
    default:
        return fmt.Sprintf("Unknown type: %T", v)
    }
}

Describe(42)          // "Integer: 42"
Describe("hello")     // "String: hello"
Describe(true)        // "Boolean: true"
Describe(3.14)        // "Unknown type: float64"
```

### 7. Standard Library Interfaces

**fmt.Stringer:**
```go
type Stringer interface {
    String() string
}

type Person struct {
    Name string
    Age  int
}

func (p Person) String() string {
    return fmt.Sprintf("%s (%d years old)", p.Name, p.Age)
}

p := Person{Name: "Alice", Age: 30}
fmt.Println(p)  // Automatically calls String(): "Alice (30 years old)"
```

**io.Reader and io.Writer:**
```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Custom reader
type StringReader struct {
    content string
    pos     int
}

func (r *StringReader) Read(p []byte) (int, error) {
    if r.pos >= len(r.content) {
        return 0, io.EOF
    }
    n := copy(p, r.content[r.pos:])
    r.pos += n
    return n, nil
}
```

**error Interface:**
```go
type error interface {
    Error() string
}

// Custom error
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}
```

### 8. Interface Values and Nil

**Interface Value Structure:**
```go
// Interface value contains (type, value) tuple
var w Writer
// w is nil interface (nil type, nil value)

w = (*FileWriter)(nil)
// w is non-nil interface (FileWriter type, nil value)
// Calling methods may panic!

if w == nil {
    fmt.Println("nil")  // False! Type is set
}

// Checking for nil value
if w != nil && reflect.ValueOf(w).IsNil() {
    fmt.Println("Interface with nil value")
}
```

## Challenge Description

### Part 1: Shape System

```go
// Shape interface defines geometric shape behavior
type Shape interface {
    Area() float64
    Perimeter() float64
    Name() string
}

// Rectangle implementation
type Rectangle struct {
    Width  float64
    Height float64
}

func NewRectangle(width, height float64) *Rectangle
func (r Rectangle) Area() float64
func (r Rectangle) Perimeter() float64
func (r Rectangle) Name() string

// Circle implementation
type Circle struct {
    Radius float64
}

func NewCircle(radius float64) *Circle
func (c Circle) Area() float64
func (c Circle) Perimeter() float64
func (c Circle) Name() string

// Triangle implementation
type Triangle struct {
    A, B, C float64  // Side lengths
}

func NewTriangle(a, b, c float64) (*Triangle, error)
func (t Triangle) Area() float64
func (t Triangle) Perimeter() float64
func (t Triangle) Name() string

// Utility functions
func TotalArea(shapes []Shape) float64
func LargestShape(shapes []Shape) Shape
func PrintShapeInfo(s Shape)
```

### Part 2: Reader/Writer Implementations

```go
// StringReader reads from a string
type StringReader struct {
    content string
    pos     int
}

func NewStringReader(content string) *StringReader
func (r *StringReader) Read(p []byte) (n int, err error)

// CountingWriter counts bytes written
type CountingWriter struct {
    writer io.Writer
    count  int64
}

func NewCountingWriter(w io.Writer) *CountingWriter
func (cw *CountingWriter) Write(p []byte) (n int, err error)
func (cw *CountingWriter) BytesWritten() int64

// UppercaseWriter converts to uppercase while writing
type UppercaseWriter struct {
    writer io.Writer
}

func NewUppercaseWriter(w io.Writer) *UppercaseWriter
func (uw *UppercaseWriter) Write(p []byte) (n int, err error)

// BufferedReader adds buffering to any reader
type BufferedReader struct {
    reader io.Reader
    buffer []byte
    pos    int
}

func NewBufferedReader(r io.Reader, bufferSize int) *BufferedReader
func (br *BufferedReader) Read(p []byte) (n int, err error)
```

### Part 3: Custom Error Types

```go
// ValidationError represents input validation failure
type ValidationError struct {
    Field   string
    Value   interface{}
    Message string
}

func NewValidationError(field string, value interface{}, message string) *ValidationError
func (e ValidationError) Error() string

// NotFoundError represents resource not found
type NotFoundError struct {
    Resource string
    ID       string
}

func NewNotFoundError(resource, id string) *NotFoundError
func (e NotFoundError) Error() string

// PermissionError represents access denied
type PermissionError struct {
    User   string
    Action string
}

func NewPermissionError(user, action string) *PermissionError
func (e PermissionError) Error() string

// Helper function to check error types
func IsValidationError(err error) bool
func IsNotFoundError(err error) bool
```

### Part 4: Plugin System

```go
// Plugin interface for extensible system
type Plugin interface {
    Name() string
    Version() string
    Execute(args map[string]interface{}) (interface{}, error)
}

// LoggerPlugin logs messages
type LoggerPlugin struct {
    name    string
    version string
}

func NewLoggerPlugin() *LoggerPlugin
func (p LoggerPlugin) Name() string
func (p LoggerPlugin) Version() string
func (p LoggerPlugin) Execute(args map[string]interface{}) (interface{}, error)

// CalculatorPlugin performs calculations
type CalculatorPlugin struct {
    name    string
    version string
}

func NewCalculatorPlugin() *CalculatorPlugin
func (p CalculatorPlugin) Name() string
func (p CalculatorPlugin) Version() string
func (p CalculatorPlugin) Execute(args map[string]interface{}) (interface{}, error)

// PluginRegistry manages plugins
type PluginRegistry struct {
    plugins map[string]Plugin
}

func NewPluginRegistry() *PluginRegistry
func (r *PluginRegistry) Register(plugin Plugin) error
func (r *PluginRegistry) Get(name string) (Plugin, error)
func (r *PluginRegistry) List() []string
func (r *PluginRegistry) Execute(name string, args map[string]interface{}) (interface{}, error)
```

### Part 5: Sorting System

```go
// Comparable interface for sortable types
type Comparable interface {
    CompareTo(other Comparable) int  // Returns: -1 (less), 0 (equal), 1 (greater)
}

// Person with sortable implementation
type Person struct {
    Name string
    Age  int
}

func (p Person) CompareTo(other Comparable) int

// Product with sortable implementation
type Product struct {
    Name  string
    Price float64
}

func (p Product) CompareTo(other Comparable) int

// Sort function using Comparable interface
func Sort(items []Comparable)

// FindMin returns smallest Comparable
func FindMin(items []Comparable) Comparable

// FindMax returns largest Comparable
func FindMax(items []Comparable) Comparable
```

### Part 6: Type Inspector

```go
// TypeInfo returns information about a value's type
func TypeInfo(value interface{}) string

// IsNumeric checks if value is numeric type
func IsNumeric(value interface{}) bool

// IsCollection checks if value is slice, array, or map
func IsCollection(value interface{}) bool

// ConvertToString attempts to convert any value to string
func ConvertToString(value interface{}) (string, error)

// DeepEqual compares two interface{} values
func DeepEqual(a, b interface{}) bool

// Clone attempts to deep copy an interface{} value
func Clone(value interface{}) (interface{}, error)
```

## Test Requirements

### Shape Tests

```go
func TestShapeInterface(t *testing.T) {
    shapes := []Shape{
        NewRectangle(4, 3),
        NewCircle(5),
        mustCreateTriangle(t, 3, 4, 5),
    }

    expectedAreas := []float64{12.0, 78.54, 6.0}

    for i, shape := range shapes {
        t.Run(shape.Name(), func(t *testing.T) {
            area := shape.Area()
            if !almostEqual(area, expectedAreas[i]) {
                t.Errorf("%s Area() = %.2f, want %.2f",
                    shape.Name(), area, expectedAreas[i])
            }

            if shape.Perimeter() <= 0 {
                t.Errorf("%s Perimeter() must be positive", shape.Name())
            }
        })
    }
}

func TestTotalArea(t *testing.T) {
    shapes := []Shape{
        NewRectangle(2, 3),  // Area: 6
        NewCircle(1),        // Area: π ≈ 3.14
    }

    total := TotalArea(shapes)
    expected := 9.14  // Approximate

    if !almostEqual(total, expected) {
        t.Errorf("TotalArea() = %.2f, want %.2f", total, expected)
    }
}
```

### Reader/Writer Tests

```go
func TestStringReader(t *testing.T) {
    content := "Hello, World!"
    reader := NewStringReader(content)

    buf := make([]byte, 5)
    n, err := reader.Read(buf)

    if err != nil {
        t.Errorf("unexpected error: %v", err)
    }
    if n != 5 {
        t.Errorf("Read() = %d bytes, want 5", n)
    }
    if string(buf) != "Hello" {
        t.Errorf("Read() = %s, want Hello", string(buf))
    }
}

func TestCountingWriter(t *testing.T) {
    var buf bytes.Buffer
    writer := NewCountingWriter(&buf)

    writer.Write([]byte("Hello"))
    writer.Write([]byte(" World"))

    if writer.BytesWritten() != 11 {
        t.Errorf("BytesWritten() = %d, want 11", writer.BytesWritten())
    }
}
```

### Error Type Tests

Test:
- Error message formatting
- Type assertions on custom errors
- Error type checking functions
- Nil error handling

### Plugin System Tests

```go
func TestPluginRegistry(t *testing.T) {
    registry := NewPluginRegistry()

    logger := NewLoggerPlugin()
    if err := registry.Register(logger); err != nil {
        t.Errorf("Register() error: %v", err)
    }

    plugin, err := registry.Get("Logger")
    if err != nil {
        t.Errorf("Get() error: %v", err)
    }

    if plugin.Name() != "Logger" {
        t.Errorf("plugin.Name() = %s, want Logger", plugin.Name())
    }
}
```

### Type Inspector Tests

Test with:
- Various primitive types (int, string, bool, float)
- Collections (slices, arrays, maps)
- Structs
- Nil values
- Interface values

## Input/Output Specifications

### Shapes

```go
rect := NewRectangle(4, 3)
rect.Area()       → 12.0
rect.Perimeter()  → 14.0
rect.Name()       → "Rectangle"

circle := NewCircle(5)
circle.Area()     → 78.54 (approx)
circle.Perimeter() → 31.42 (approx)

shapes := []Shape{rect, circle}
TotalArea(shapes) → 90.54
```

### Reader/Writer

```go
reader := NewStringReader("Hello")
buf := make([]byte, 3)
reader.Read(buf)  → 3, nil, buf="Hel"
reader.Read(buf)  → 2, nil, buf="lo"
reader.Read(buf)  → 0, io.EOF

var b bytes.Buffer
writer := NewCountingWriter(&b)
writer.Write([]byte("test"))
writer.BytesWritten() → 4
```

### Custom Errors

```go
err := NewValidationError("email", "invalid", "must contain @")
err.Error() → "email: must contain @"

IsValidationError(err) → true
IsNotFoundError(err)   → false
```

### Plugin System

```go
registry := NewPluginRegistry()
registry.Register(NewLoggerPlugin())
registry.List() → ["Logger"]

result, _ := registry.Execute("Logger", map[string]interface{}{
    "message": "test",
})
```

### Type Inspector

```go
TypeInfo(42)           → "int"
TypeInfo("hello")      → "string"
IsNumeric(3.14)        → true
IsNumeric("text")      → false
IsCollection([]int{})  → true
```

## Success Criteria

### Functional Requirements
- [ ] Interfaces define clear behavior contracts
- [ ] Types implicitly satisfy interfaces
- [ ] Polymorphism works through interface types
- [ ] Type assertions and switches handle dynamic types
- [ ] Standard library interfaces properly implemented
- [ ] Custom errors provide useful information
- [ ] Plugin system demonstrates extensibility

### Code Quality Requirements
- [ ] Interfaces are small and focused (1-3 methods)
- [ ] Interface names follow -er convention (Reader, Writer, Stringer)
- [ ] Implementations satisfy interface contracts completely
- [ ] Type assertions use safe two-value form
- [ ] Nil interface checks handle edge cases
- [ ] Comments document interface contracts
- [ ] Code passes go fmt and go vet

### Testing Requirements
- [ ] Interface implementations fully tested
- [ ] Type assertions tested with correct and incorrect types
- [ ] Nil interface handling verified
- [ ] Polymorphic behavior tested with multiple implementations
- [ ] Edge cases covered (empty, nil, boundary values)

## Common Pitfalls to Avoid

### 1. Nil Interface vs Nil Value

```go
// ❌ Wrong: Nil value in non-nil interface
type MyWriter struct{}

func (w *MyWriter) Write(p []byte) (int, error) {
    return len(p), nil
}

func GetWriter() io.Writer {
    var w *MyWriter  // nil pointer
    return w         // Non-nil interface with nil value!
}

w := GetWriter()
if w == nil {
    // This won't execute! w is not nil (has type info)
}

// ✅ Correct: Return nil interface
func GetWriter() io.Writer {
    return nil  // Actually nil interface
}
```

### 2. Interface Pollution (Too Large)

```go
// ❌ Wrong: Interface with too many methods
type DataStore interface {
    Create(data interface{}) error
    Read(id string) (interface{}, error)
    Update(id string, data interface{}) error
    Delete(id string) error
    List() ([]interface{}, error)
    Search(query string) ([]interface{}, error)
    Count() int
    // ... 10 more methods
}

// ✅ Correct: Small, focused interfaces
type Creator interface {
    Create(data interface{}) error
}

type Reader interface {
    Read(id string) (interface{}, error)
}

type Updater interface {
    Update(id string, data interface{}) error
}
```

### 3. Type Assertion Without Check

```go
// ❌ Wrong: Unchecked type assertion (panics on wrong type)
func Process(value interface{}) {
    str := value.(string)  // Panics if not string!
    fmt.Println(str)
}

// ✅ Correct: Check assertion result
func Process(value interface{}) {
    str, ok := value.(string)
    if !ok {
        fmt.Println("Not a string")
        return
    }
    fmt.Println(str)
}

// ✅ Or use type switch
func Process(value interface{}) {
    switch v := value.(type) {
    case string:
        fmt.Println("String:", v)
    default:
        fmt.Println("Unknown type")
    }
}
```

### 4. Implementing Unnecessary Interfaces

```go
// ❌ Wrong: Implementing interface methods not needed
type Config struct {
    settings map[string]string
}

// Don't implement if not using interface polymorphism
func (c Config) Read(p []byte) (int, error) {
    // Forced io.Reader implementation we don't need
    return 0, nil
}

// ✅ Correct: Only implement what you need
type Config struct {
    settings map[string]string
}

func (c Config) Get(key string) string {
    return c.settings[key]
}
```

### 5. Empty Interface Overuse

```go
// ❌ Wrong: Using interface{} everywhere
func Process(data interface{}) interface{} {
    // Loses type safety
    return data
}

// ✅ Correct: Use specific types or generics (Go 1.18+)
func Process(data string) string {
    return strings.ToUpper(data)
}

// Or with generics:
func Process[T any](data T) T {
    return data
}
```

### 6. Forgetting to Export Interface Methods

```go
// ❌ Wrong: Unexported interface methods
type Shape interface {
    area() float64  // Unexported - can't be implemented outside package!
}

// ✅ Correct: Export interface methods
type Shape interface {
    Area() float64  // Exported - can be implemented anywhere
}
```

## Extension Challenges (Optional)

### 1. HTTP Handler System
Implement custom http.Handler interface with middleware chaining.

### 2. Serialization Framework
Create Serializer interface with JSON, XML, and binary implementations.

### 3. Database Abstraction
Build a database interface with multiple backend implementations (mock, in-memory, SQL).

### 4. Event System
Design Event and EventHandler interfaces for publish/subscribe pattern.

### 5. Caching Layer
Implement Cache interface with various strategies (LRU, TTL, size-limited).

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `io`, `bytes`, `strings`, `testing`, `reflect`, `math`
- No external dependencies

### Expected Approach
1. Define small, focused interfaces (1-3 methods)
2. Implement multiple concrete types satisfying each interface
3. Demonstrate polymorphism through interface types
4. Show type assertions and type switches
5. Implement standard library interfaces (Stringer, error, Reader, Writer)
6. Create custom error types
7. Build plugin or extensibility system
8. Write comprehensive tests for interface implementations

### Code Quality Expectations
- Interfaces named with -er suffix (Reader, Writer, Calculator)
- Small interfaces (1-3 methods preferred)
- Complete interface implementation (all methods)
- Safe type assertions (two-value form)
- Proper nil interface handling
- Comments document interface contracts
- Demonstrate polymorphic behavior

### Testing Approach
- Test interface implementations through interface type
- Verify polymorphic behavior with multiple implementations
- Test type assertions with various types
- Verify error interface implementations
- Test nil interface scenarios
- Use table-driven tests for implementations

## Learning Resources

### Essential Reading
- [A Tour of Go - Interfaces](https://go.dev/tour/methods/9)
- [Go by Example - Interfaces](https://gobyexample.com/interfaces)
- [Effective Go - Interfaces](https://go.dev/doc/effective_go#interfaces)
- [Go Blog - Laws of Reflection](https://go.dev/blog/laws-of-reflection)

### Specific Topics
- [Go Spec - Interface types](https://go.dev/ref/spec#Interface_types)
- [Go Spec - Method sets](https://go.dev/ref/spec#Method_sets)
- [How to use interfaces in Go](https://jordanorelli.com/post/32665860244/how-to-use-interfaces-in-go)
- [Accept interfaces, return structs](https://bryanftan.medium.com/accept-interfaces-return-structs-in-go-d4cab29a301b)

### Practice Problems
- [Exercism Go Track - Interfaces](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/) for experimentation

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run specific test
go test -v -run TestShape

# Test with coverage
go test -cover
go test -coverprofile=coverage.out

# View coverage
go tool cover -html=coverage.out

# Check interface satisfaction (compile-time)
var _ io.Reader = (*StringReader)(nil)

# Build
go build

# Run
go run main.go
```

---

**Previous Lesson**: [Lesson 05: Structs & Methods](lesson-05-structs-methods.md)
**Next Lesson**: [Lesson 07: Error Handling Patterns](lesson-07-error-handling.md)

**Estimated Completion Time**: 3-4 hours
**Difficulty Check**: If this takes >5 hours, review Go Tour interfaces section and practice with simpler interface implementations first
