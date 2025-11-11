# Lesson 05: Structs & Methods

**Phase**: 1 - Go Fundamentals
**Estimated Time**: 3-4 hours
**Difficulty**: Beginner

## Learning Objectives

By the end of this lesson, learners will be able to:
- Define custom types using structs to group related data
- Initialize structs using literal syntax, new(), and constructor patterns
- Implement methods with value receivers and pointer receivers
- Understand when to use value vs pointer receivers
- Use struct embedding (composition) for code reuse
- Design constructors following Go conventions (New prefix)
- Work with struct tags for serialization and metadata
- Apply object-oriented design patterns using structs and methods

## Prerequisites

- Completed Lesson 01: Hello World & Basic Syntax
- Completed Lesson 02: Variables, Data Types & Operators
- Completed Lesson 03: Control Flow - If, Switch, Loops
- Completed Lesson 04: Functions & Multiple Returns
- Understanding of basic data structures and OOP concepts

## Core Concepts

### 1. Struct Definition

**Basic Struct:**
```go
type Person struct {
    FirstName string
    LastName  string
    Age       int
}

// Struct with various types
type Employee struct {
    ID        int
    Name      string
    Salary    float64
    IsActive  bool
    HireDate  time.Time
}
```

**Embedded Fields (Anonymous):**
```go
type Address struct {
    Street  string
    City    string
    ZipCode string
}

type Person struct {
    Name    string
    Age     int
    Address  // Embedded struct (anonymous field)
}

// Access embedded fields directly
p := Person{}
p.Street = "123 Main St"  // Direct access to embedded field
```

### 2. Struct Initialization

**Literal Initialization:**
```go
// With field names (preferred, order-independent)
p1 := Person{
    FirstName: "John",
    LastName:  "Doe",
    Age:       30,
}

// Without field names (order-dependent, not recommended)
p2 := Person{"Jane", "Smith", 25}

// Partial initialization (other fields get zero values)
p3 := Person{FirstName: "Bob"}  // LastName="", Age=0
```

**Using new():**
```go
// Returns pointer to struct, all fields zero-valued
p := new(Person)
p.FirstName = "Alice"

// Equivalent to:
p := &Person{}
```

**Constructor Pattern:**
```go
// Constructor function (Go convention: New prefix)
func NewPerson(firstName, lastName string, age int) *Person {
    return &Person{
        FirstName: firstName,
        LastName:  lastName,
        Age:       age,
    }
}

// Constructor with validation
func NewEmployee(id int, name string, salary float64) (*Employee, error) {
    if id <= 0 {
        return nil, fmt.Errorf("invalid employee ID: %d", id)
    }
    if salary < 0 {
        return nil, fmt.Errorf("salary cannot be negative")
    }

    return &Employee{
        ID:       id,
        Name:     name,
        Salary:   salary,
        IsActive: true,
        HireDate: time.Now(),
    }, nil
}
```

### 3. Methods

**Value Receiver:**
```go
// Method with value receiver (receives copy of struct)
func (p Person) FullName() string {
    return p.FirstName + " " + p.LastName
}

// Method doesn't modify original struct
func (p Person) HaveBirthday() {
    p.Age++  // Modifies copy, not original
}
```

**Pointer Receiver:**
```go
// Method with pointer receiver (can modify struct)
func (p *Person) HaveBirthday() {
    p.Age++  // Modifies original struct
}

// Method with pointer receiver for efficiency (large structs)
func (e *Employee) GiveRaise(percent float64) {
    e.Salary += e.Salary * (percent / 100)
}
```

**Method Guidelines:**
- Use pointer receiver to modify the struct
- Use pointer receiver for large structs (avoid copying)
- Use value receiver for small, immutable types
- Be consistent: if one method uses pointer receiver, all should

### 4. Struct Composition

**Embedding for Composition:**
```go
type Engine struct {
    Horsepower int
    Type       string
}

func (e Engine) Start() {
    fmt.Println("Engine started")
}

type Car struct {
    Make   string
    Model  string
    Engine  // Embedded struct
}

// Car "inherits" Engine's methods
car := Car{
    Make:  "Toyota",
    Model: "Camry",
    Engine: Engine{Horsepower: 200, Type: "V6"},
}
car.Start()  // Calls Engine.Start()
car.Horsepower = 250  // Direct access to embedded field
```

**Multiple Embedding:**
```go
type Printer struct {
    Model string
}

func (p Printer) Print() {
    fmt.Println("Printing...")
}

type Scanner struct {
    Model string
}

func (s Scanner) Scan() {
    fmt.Println("Scanning...")
}

type Copier struct {
    Printer
    Scanner
}

// Has both Print() and Scan() methods
copier := Copier{}
copier.Print()
copier.Scan()
```

### 5. Struct Tags

**Tags for Serialization:**
```go
type User struct {
    ID        int    `json:"id"`
    Username  string `json:"username"`
    Email     string `json:"email,omitempty"`
    Password  string `json:"-"`  // Never serialize
    CreatedAt time.Time `json:"created_at"`
}

// JSON marshaling uses tags
user := User{ID: 1, Username: "john", Email: "john@example.com"}
jsonData, _ := json.Marshal(user)
// {"id":1,"username":"john","email":"john@example.com","created_at":"..."}
```

**Custom Tags:**
```go
type Config struct {
    Host string `env:"DB_HOST" default:"localhost"`
    Port int    `env:"DB_PORT" default:"5432"`
}
```

### 6. Exported vs Unexported Fields

**Visibility:**
```go
type Account struct {
    ID       int     // Exported (accessible outside package)
    Balance  float64 // Exported
    password string  // Unexported (package-private)
}

// Getter method for unexported field
func (a *Account) Password() string {
    return a.password
}

// Setter method with validation
func (a *Account) SetPassword(pwd string) error {
    if len(pwd) < 8 {
        return fmt.Errorf("password too short")
    }
    a.password = pwd
    return nil
}
```

## Challenge Description

### Part 1: Person and Contact

```go
// Person represents an individual with basic information
type Person struct {
    FirstName string
    LastName  string
    Age       int
    Email     string
}

// NewPerson creates a new Person with validation
func NewPerson(firstName, lastName string, age int, email string) (*Person, error)

// FullName returns the person's full name
func (p Person) FullName() string

// IsAdult returns true if age >= 18
func (p Person) IsAdult() bool

// UpdateEmail updates the email address
func (p *Person) UpdateEmail(email string) error

// String implements fmt.Stringer interface
func (p Person) String() string
```

### Part 2: Geometric Shapes

```go
// Rectangle represents a rectangle with width and height
type Rectangle struct {
    Width  float64
    Height float64
}

// NewRectangle creates a new Rectangle with validation
func NewRectangle(width, height float64) (*Rectangle, error)

// Area returns the area of the rectangle
func (r Rectangle) Area() float64

// Perimeter returns the perimeter of the rectangle
func (r Rectangle) Perimeter() float64

// IsSquare returns true if width equals height
func (r Rectangle) IsSquare() bool

// Scale multiplies dimensions by factor
func (r *Rectangle) Scale(factor float64)

// Circle represents a circle with radius
type Circle struct {
    Radius float64
}

// NewCircle creates a new Circle with validation
func NewCircle(radius float64) (*Circle, error)

// Area returns the area of the circle (πr²)
func (c Circle) Area() float64

// Circumference returns the circumference (2πr)
func (c Circle) Circumference() float64

// Diameter returns the diameter
func (c Circle) Diameter() float64
```

### Part 3: Bank Account System

```go
// Account represents a bank account
type Account struct {
    AccountNumber string
    HolderName    string
    balance       float64  // Unexported
    transactions  []Transaction
}

// Transaction represents a single transaction
type Transaction struct {
    Type      string    // "deposit" or "withdrawal"
    Amount    float64
    Timestamp time.Time
}

// NewAccount creates a new account with initial balance
func NewAccount(accountNumber, holderName string, initialBalance float64) (*Account, error)

// Balance returns the current balance
func (a *Account) Balance() float64

// Deposit adds money to the account
func (a *Account) Deposit(amount float64) error

// Withdraw removes money from the account
func (a *Account) Withdraw(amount float64) error

// Transfer transfers money to another account
func (a *Account) Transfer(to *Account, amount float64) error

// TransactionHistory returns all transactions
func (a *Account) TransactionHistory() []Transaction

// Statement returns formatted account statement
func (a *Account) Statement() string
```

### Part 4: Address Book

```go
// Contact represents a contact with embedded address
type Contact struct {
    Person
    Address
    Phone string
}

// Address represents a physical address
type Address struct {
    Street  string
    City    string
    State   string
    ZipCode string
}

// NewContact creates a new contact
func NewContact(firstName, lastName, email, phone string) *Contact

// SetAddress sets the contact's address
func (c *Contact) SetAddress(street, city, state, zipCode string)

// FullAddress returns formatted address string
func (a Address) FullAddress() string

// AddressBook manages multiple contacts
type AddressBook struct {
    contacts []Contact
}

// NewAddressBook creates a new address book
func NewAddressBook() *AddressBook

// AddContact adds a contact to the address book
func (ab *AddressBook) AddContact(contact Contact)

// FindByName searches contacts by name (case-insensitive)
func (ab *AddressBook) FindByName(name string) []Contact

// FindByCity returns all contacts in a city
func (ab *AddressBook) FindByCity(city string) []Contact

// Count returns the number of contacts
func (ab *AddressBook) Count() int
```

### Part 5: Product Inventory

```go
// Product represents a product in inventory
type Product struct {
    ID          int
    Name        string
    Description string
    Price       float64
    Stock       int
}

// NewProduct creates a new product with validation
func NewProduct(id int, name string, price float64, stock int) (*Product, error)

// IsInStock returns true if stock > 0
func (p Product) IsInStock() bool

// UpdateStock adjusts stock level
func (p *Product) UpdateStock(quantity int) error

// DiscountPrice returns price after discount percentage
func (p Product) DiscountPrice(percent float64) float64

// Inventory manages multiple products
type Inventory struct {
    products map[int]Product
}

// NewInventory creates a new inventory
func NewInventory() *Inventory

// AddProduct adds or updates a product
func (i *Inventory) AddProduct(product Product)

// GetProduct retrieves a product by ID
func (i *Inventory) GetProduct(id int) (Product, bool)

// RemoveProduct removes a product by ID
func (i *Inventory) RemoveProduct(id int) bool

// LowStockProducts returns products with stock <= threshold
func (i *Inventory) LowStockProducts(threshold int) []Product

// TotalValue returns total inventory value
func (i *Inventory) TotalValue() float64
```

## Test Requirements

### Person Tests

```go
func TestNewPerson(t *testing.T) {
    tests := []struct {
        name        string
        firstName   string
        lastName    string
        age         int
        email       string
        expectError bool
    }{
        {"valid", "John", "Doe", 30, "john@example.com", false},
        {"negative age", "Jane", "Smith", -5, "jane@example.com", true},
        {"empty name", "", "Doe", 25, "test@example.com", true},
        {"invalid email", "Bob", "Jones", 40, "not-an-email", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            person, err := NewPerson(tt.firstName, tt.lastName, tt.age, tt.email)

            if tt.expectError {
                if err == nil {
                    t.Error("expected error, got nil")
                }
                return
            }

            if err != nil {
                t.Errorf("unexpected error: %v", err)
            }
            if person.FirstName != tt.firstName {
                t.Errorf("FirstName = %s, want %s", person.FirstName, tt.firstName)
            }
        })
    }
}

func TestPersonMethods(t *testing.T) {
    person := &Person{FirstName: "John", LastName: "Doe", Age: 25}

    if fullName := person.FullName(); fullName != "John Doe" {
        t.Errorf("FullName() = %s, want John Doe", fullName)
    }

    if !person.IsAdult() {
        t.Error("IsAdult() = false, want true for age 25")
    }
}
```

### Shape Tests

Test with:
- Valid dimensions
- Zero dimensions
- Negative dimensions
- Boundary values
- Scale operations (positive, negative, zero)
- Area and perimeter calculations

### Bank Account Tests

```go
func TestAccountOperations(t *testing.T) {
    account, _ := NewAccount("ACC001", "John Doe", 1000.0)

    // Test deposit
    if err := account.Deposit(500); err != nil {
        t.Errorf("Deposit failed: %v", err)
    }
    if balance := account.Balance(); balance != 1500 {
        t.Errorf("Balance = %.2f, want 1500.00", balance)
    }

    // Test withdrawal
    if err := account.Withdraw(300); err != nil {
        t.Errorf("Withdraw failed: %v", err)
    }
    if balance := account.Balance(); balance != 1200 {
        t.Errorf("Balance = %.2f, want 1200.00", balance)
    }

    // Test overdraft
    if err := account.Withdraw(2000); err == nil {
        t.Error("expected overdraft error, got nil")
    }
}

func TestTransfer(t *testing.T) {
    from, _ := NewAccount("ACC001", "Alice", 1000)
    to, _ := NewAccount("ACC002", "Bob", 500)

    if err := from.Transfer(to, 300); err != nil {
        t.Errorf("Transfer failed: %v", err)
    }

    if from.Balance() != 700 {
        t.Errorf("From balance = %.2f, want 700.00", from.Balance())
    }
    if to.Balance() != 800 {
        t.Errorf("To balance = %.2f, want 800.00", to.Balance())
    }
}
```

### Address Book Tests

Test:
- Adding contacts
- Searching by name (exact and partial)
- Searching by city
- Empty address book
- Duplicate contacts
- Case-insensitive search

### Inventory Tests

Test:
- Adding/removing products
- Stock updates
- Low stock filtering
- Total value calculation
- Product retrieval by ID

## Input/Output Specifications

### Person

```go
p, _ := NewPerson("John", "Doe", 30, "john@example.com")
p.FullName()    → "John Doe"
p.IsAdult()     → true

p.UpdateEmail("newemail@example.com") → nil
p.Email         → "newemail@example.com"
```

### Shapes

```go
r, _ := NewRectangle(4, 3)
r.Area()        → 12.0
r.Perimeter()   → 14.0
r.IsSquare()    → false
r.Scale(2)
r.Width         → 8.0

c, _ := NewCircle(5)
c.Area()        → 78.54 (approx)
c.Circumference() → 31.42 (approx)
```

### Bank Account

```go
acc, _ := NewAccount("ACC001", "John", 1000)
acc.Balance()   → 1000.0
acc.Deposit(500) → nil
acc.Balance()   → 1500.0
acc.Withdraw(300) → nil
acc.Balance()   → 1200.0
acc.Withdraw(2000) → error
```

### Address Book

```go
ab := NewAddressBook()
contact := NewContact("John", "Doe", "john@example.com", "555-1234")
ab.AddContact(*contact)
ab.Count()      → 1
ab.FindByName("John") → []Contact{contact}
```

### Inventory

```go
inv := NewInventory()
p, _ := NewProduct(1, "Widget", 19.99, 100)
inv.AddProduct(*p)
inv.GetProduct(1) → Product{...}, true
inv.TotalValue() → 1999.0
inv.LowStockProducts(10) → []
```

## Success Criteria

### Functional Requirements
- [ ] Structs properly encapsulate related data
- [ ] Constructors validate input and return errors
- [ ] Methods correctly modify (pointer) or read (value) struct state
- [ ] Embedded structs provide composition
- [ ] Unexported fields properly protected
- [ ] All operations maintain data consistency

### Code Quality Requirements
- [ ] Consistent use of pointer vs value receivers
- [ ] Constructors follow New* naming convention
- [ ] Exported names capitalized, unexported lowercase
- [ ] Struct fields logically grouped
- [ ] Methods have clear, focused responsibilities
- [ ] Comments document exported types and methods
- [ ] Code passes go fmt and go vet

### Testing Requirements
- [ ] Table-driven tests for constructors
- [ ] Method behavior verified with various inputs
- [ ] Edge cases tested (zero values, boundaries)
- [ ] Error conditions validated
- [ ] Pointer receiver modifications verified
- [ ] Composition behavior tested

## Common Pitfalls to Avoid

### 1. Value vs Pointer Receiver Confusion

```go
// ❌ Wrong: Value receiver can't modify struct
func (p Person) UpdateAge(age int) {
    p.Age = age  // Modifies copy, not original!
}

// ✅ Correct: Pointer receiver modifies original
func (p *Person) UpdateAge(age int) {
    p.Age = age  // Modifies original
}
```

### 2. Inconsistent Receiver Types

```go
// ❌ Wrong: Mixing value and pointer receivers
func (p Person) GetName() string { return p.Name }
func (p *Person) SetName(name string) { p.Name = name }
func (p Person) GetAge() int { return p.Age }  // Inconsistent!

// ✅ Correct: Consistent pointer receivers
func (p *Person) GetName() string { return p.Name }
func (p *Person) SetName(name string) { p.Name = name }
func (p *Person) GetAge() int { return p.Age }
```

### 3. Not Returning Errors from Constructors

```go
// ❌ Wrong: Panics on invalid input
func NewAccount(balance float64) *Account {
    if balance < 0 {
        panic("negative balance")  // Don't panic!
    }
    return &Account{balance: balance}
}

// ✅ Correct: Return error for invalid input
func NewAccount(balance float64) (*Account, error) {
    if balance < 0 {
        return nil, fmt.Errorf("balance cannot be negative")
    }
    return &Account{balance: balance}, nil
}
```

### 4. Exposing Internal State

```go
// ❌ Wrong: Returning mutable reference
type Team struct {
    members []string
}

func (t *Team) Members() []string {
    return t.members  // Caller can modify internal slice!
}

// ✅ Correct: Return copy
func (t *Team) Members() []string {
    result := make([]string, len(t.members))
    copy(result, t.members)
    return result
}
```

### 5. Forgetting to Initialize Embedded Structs

```go
// ❌ Wrong: Embedded struct not initialized
type Car struct {
    Make string
    Engine  // nil embedded struct!
}
car := Car{Make: "Toyota"}
car.Start()  // Panic! Engine is zero value

// ✅ Correct: Initialize embedded struct
car := Car{
    Make: "Toyota",
    Engine: Engine{Horsepower: 200},
}
```

### 6. Comparing Structs with Incomparable Fields

```go
// ❌ Wrong: Struct with slice can't be compared
type Person struct {
    Name    string
    Friends []string  // Slices are not comparable
}

p1 := Person{}
p2 := Person{}
if p1 == p2 {}  // Compile error!

// ✅ Correct: Implement custom comparison
func (p Person) Equals(other Person) bool {
    if p.Name != other.Name {
        return false
    }
    // Compare slices manually or use reflect.DeepEqual
    return reflect.DeepEqual(p.Friends, other.Friends)
}
```

## Extension Challenges (Optional)

### 1. Library Management System
Create Book, Author, and Library structs with borrowing/returning functionality.

### 2. Employee Management
Build an Employee struct with embedded Person, calculate salaries with bonuses, and manage departments.

### 3. Shopping Cart
Implement Cart, CartItem, and Product structs with add/remove/calculate total functionality.

### 4. Polymorphic Shapes
Create a Shape interface and implement it with Rectangle, Circle, Triangle structs.

### 5. JSON Serialization
Add JSON tags to structs and implement custom marshaling/unmarshaling methods.

## AI Provider Guidelines

### Allowed Packages
- Standard library: `fmt`, `strings`, `testing`, `reflect`, `time`, `encoding/json`
- No external dependencies

### Expected Approach
1. Define basic structs with appropriate field types
2. Implement constructor functions with validation
3. Add methods demonstrating value vs pointer receivers
4. Show struct embedding for composition
5. Implement systems with multiple interacting structs (bank accounts, inventory)
6. Use unexported fields with getter/setter methods
7. Write comprehensive table-driven tests

### Code Quality Expectations
- Constructors validate input and return errors
- Consistent receiver types (all pointer or all value)
- Exported/unexported naming properly applied
- Comments document all exported types and methods
- Methods have single, clear responsibilities
- Struct fields logically ordered
- Use composition over inheritance patterns

### Testing Approach
- Test constructor validation
- Verify method side effects
- Test pointer vs value receiver behavior
- Check embedded struct functionality
- Validate unexported field protection
- Test struct interactions (transfers, inventory operations)

## Learning Resources

### Essential Reading
- [A Tour of Go - Structs](https://go.dev/tour/moretypes/2)
- [Go by Example - Structs](https://gobyexample.com/structs)
- [Go by Example - Methods](https://gobyexample.com/methods)
- [Go by Example - Struct Embedding](https://gobyexample.com/struct-embedding)
- [Effective Go - Data](https://go.dev/doc/effective_go#data)

### Specific Topics
- [Go Spec - Struct types](https://go.dev/ref/spec#Struct_types)
- [Go Spec - Method declarations](https://go.dev/ref/spec#Method_declarations)
- [Go Blog - Organizing Go code](https://go.dev/blog/organizing-go-code)
- [Pointer vs Value Receivers](https://go.dev/doc/faq#methods_on_values_or_pointers)

### Practice Problems
- [Exercism Go Track - Structs and Methods](https://exercism.org/tracks/go)
- [Go Playground](https://go.dev/play/) for experimentation

## Validation Commands

```bash
# Format and check
go fmt ./...
go vet ./...

# Run tests
go test -v

# Run specific test
go test -v -run TestPerson

# Test with coverage
go test -cover
go test -coverprofile=coverage.out

# View coverage
go tool cover -html=coverage.out

# Build
go build

# Run
go run main.go
```

---

**Previous Lesson**: [Lesson 04: Functions & Multiple Returns](lesson-04-functions.md)
**Next Lesson**: [Lesson 06: Interfaces & Polymorphism](lesson-06-interfaces.md)

**Estimated Completion Time**: 3-4 hours
**Difficulty Check**: If this takes >5 hours, review Go Tour structs/methods sections and practice with simpler examples first
