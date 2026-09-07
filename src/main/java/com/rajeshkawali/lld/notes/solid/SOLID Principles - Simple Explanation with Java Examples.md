# SOLID Principles

SOLID has five principles:

```text
S → Single Responsibility Principle
O → Open/Closed Principle
L → Liskov Substitution Principle
I → Interface Segregation Principle
D → Dependency Inversion Principle
```

Let's understand each one with a simple example.

---

# 1. S — Single Responsibility Principle (SRP)

## Definition

> **A class should have only one responsibility and only one reason to change.**

In simple words:

> **One class should do one main job.**

---

## Bad Example

Suppose we have:

```java
class Invoice {

    public void calculateTotal() {
        // Calculate invoice total
    }

    public void printInvoice() {
        // Print invoice
    }

    public void saveToDatabase() {
        // Save invoice to database
    }

    public void sendEmail() {
        // Send invoice email
    }
}
```

This class is doing too many things:

```text
Invoice
  |
  ├── Calculate total
  ├── Print invoice
  ├── Save database
  └── Send email
```

There are multiple reasons for this class to change.

For example:

- Calculation logic changes → modify `Invoice`
- Printing format changes → modify `Invoice`
- Database changes → modify `Invoice`
- Email logic changes → modify `Invoice`

This violates SRP.

---

# Better Example

Separate responsibilities:

```java
class Invoice {
    public void calculateTotal() {
        // Calculate total
    }
}
```

```java
class InvoicePrinter {
    public void print(Invoice invoice) {
        // Print invoice
    }
}
```

```java
class InvoiceRepository {
    public void save(Invoice invoice) {
        // Save invoice
    }
}
```

```java
class InvoiceEmailService {
    public void send(Invoice invoice) {
        // Send email
    }
}
```

Now:

```text
Invoice
   ↓
Only invoice/business data

InvoicePrinter
   ↓
Only printing

InvoiceRepository
   ↓
Only database

InvoiceEmailService
   ↓
Only email
```

Each class has a clear responsibility.

---

## Real-Life Example

Think about a restaurant.

You don't want one employee to:

```text
Take order
Cook food
Handle payment
Clean tables
Deliver food
```

Instead:

```text
Waiter → Takes order
Chef → Cooks
Cashier → Payment
Cleaner → Cleans
Delivery person → Delivers
```

Each has one main responsibility.

That's **Single Responsibility Principle**.

---

## Interview Answer

> **SRP says a class should have one responsibility and one reason to change. We should separate different responsibilities into different classes.**

### Memory Trick

> **S = Single Job**

---

# 2. O — Open/Closed Principle (OCP)

## Definition

> **Software entities should be open for extension but closed for modification.**

In simple words:

> **We should be able to add new functionality without changing existing working code.**

---

## Bad Example

Suppose we have a payment system:

```java
class PaymentService {

    public void pay(String type) {

        if (type.equals("UPI")) {
            // UPI payment

        } else if (type.equals("CARD")) {
            // Card payment

        } else if (type.equals("PAYPAL")) {
            // PayPal payment
        }
    }
}
```

Now tomorrow we add:

```text
Apple Pay
Google Pay
Amazon Pay
```

We have to keep modifying `PaymentService`.

This violates OCP.

---

# Better Example

Create an interface:

```java
interface PaymentMethod {

    void pay(double amount);
}
```

Then:

```java
class UPIPayment implements PaymentMethod {

    public void pay(double amount) {
        System.out.println("Payment using UPI");
    }
}
```

```java
class CardPayment implements PaymentMethod {

    public void pay(double amount) {
        System.out.println("Payment using Card");
    }
}
```

```java
class PayPalPayment implements PaymentMethod {

    public void pay(double amount) {
        System.out.println("Payment using PayPal");
    }
}
```

Now:

```java
class PaymentService {

    public void processPayment(
            PaymentMethod paymentMethod,
            double amount) {

        paymentMethod.pay(amount);
    }
}
```

If we add:

```java
class ApplePayPayment implements PaymentMethod {

    public void pay(double amount) {
        System.out.println("Payment using Apple Pay");
    }
}
```

We don't need to modify `PaymentService`.

We simply add a new class.

That's OCP.

---

## Why?

The existing code is:

```text
PaymentService
```

It is **closed for modification**.

But the system is:

```text
PaymentMethod
   |
   ├── UPI
   ├── Card
   ├── PayPal
   └── ApplePay  ← New
```

It is **open for extension**.

---

## Connection With Design Patterns

The **Strategy Pattern** that we discussed earlier is a great example of OCP.

```text
PaymentStrategy
       |
       ├── UPI
       ├── Card
       └── PayPal
```

We can add new strategies without changing the Context.

---

## Interview Answer

> **OCP says a class should be open for extension but closed for modification. We should add new behavior through abstraction or new implementations instead of repeatedly modifying existing code.**

### Memory Trick

> **O = Add new, don't keep changing old.**

---

# 3. L — Liskov Substitution Principle (LSP)

This is usually the most confusing SOLID principle.

## Definition

> **Objects of a child class should be replaceable for objects of the parent class without breaking the correctness of the program.**

In simple words:

> **If B is a subtype of A, we should be able to use B wherever A is expected without unexpected behavior.**

---

# Simple Example

Suppose:

```java
class Bird {

    public void fly() {
        System.out.println("Flying");
    }
}
```

Now:

```java
class Sparrow extends Bird {

    @Override
    public void fly() {
        System.out.println("Sparrow flying");
    }
}
```

This is fine.

A `Sparrow` is a `Bird`, and it can fly.

But now:

```java
class Penguin extends Bird {

    @Override
    public void fly() {
        throw new UnsupportedOperationException(
            "Penguins cannot fly"
        );
    }
}
```

We have a problem.

If our code expects:

```java
Bird bird = new Penguin();

bird.fly();
```

the program breaks.

The parent contract says:

```text
Bird → can fly
```

but the child says:

```text
Penguin → cannot fly
```

So `Penguin` should probably not inherit from a `Bird` abstraction that requires `fly()`.

---

# Better Design

Separate the capabilities.

```java
interface Bird {
    void eat();
}
```

Then:

```java
interface FlyingBird extends Bird {
    void fly();
}
```

Sparrow:

```java
class Sparrow implements FlyingBird {

    public void eat() {
        System.out.println("Eating");
    }

    public void fly() {
        System.out.println("Flying");
    }
}
```

Penguin:

```java
class Penguin implements Bird {

    public void eat() {
        System.out.println("Eating");
    }
}
```

Now we don't force Penguin to implement `fly()`.

---

# Another Simple Example

Imagine:

```java
class Rectangle {
    protected int width;
    protected int height;

    public void setWidth(int width) {
        this.width = width;
    }

    public void setHeight(int height) {
        this.height = height;
    }
}
```

And:

```java
class Square extends Rectangle {

    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;
    }

    @Override
    public void setHeight(int height) {
        this.width = height;
        this.height = height;
    }
}
```

Now code expecting a Rectangle may behave unexpectedly:

```java
Rectangle rectangle = new Square();

rectangle.setWidth(10);
rectangle.setHeight(20);
```

A normal Rectangle has:

```text
Width  = 10
Height = 20
```

But the Square changes both dimensions.

This demonstrates why inheritance must preserve the expected behavior of the parent abstraction.

---

## Key Idea

LSP is not simply:

> "Child class should extend parent."

It is:

> **"Child class should behave correctly wherever the parent is expected."**

---

## Interview Answer

> **LSP says that objects of a derived class should be substitutable for objects of the base class without breaking the application's expected behavior. A subclass should honor the contract of its parent rather than weakening or violating it.**

### Memory Trick

> **L = Child should safely replace Parent.**

---

# 4. I — Interface Segregation Principle (ISP)

## Definition

> **Clients should not be forced to depend on methods they do not use.**

In simple words:

> **Don't create one huge interface. Create smaller, specific interfaces.**

---

# Bad Example

Suppose we have:

```java
interface Worker {

    void work();

    void eat();

    void sleep();
}
```

A human worker can do all of these.

```java
class HumanWorker implements Worker {

    public void work() {
        System.out.println("Working");
    }

    public void eat() {
        System.out.println("Eating");
    }

    public void sleep() {
        System.out.println("Sleeping");
    }
}
```

But suppose we have a robot:

```java
class RobotWorker implements Worker {

    public void work() {
        System.out.println("Working");
    }

    public void eat() {
        // Robot doesn't eat
    }

    public void sleep() {
        // Robot doesn't sleep
    }
}
```

This is bad design.

The robot is forced to implement methods it doesn't need.

---

# Better Example

Split the interface:

```java
interface Workable {
    void work();
}
```

```java
interface Eatable {
    void eat();
}
```

```java
interface Sleepable {
    void sleep();
}
```

Human:

```java
class HumanWorker
        implements Workable, Eatable, Sleepable {

    public void work() {
        System.out.println("Working");
    }

    public void eat() {
        System.out.println("Eating");
    }

    public void sleep() {
        System.out.println("Sleeping");
    }
}
```

Robot:

```java
class RobotWorker implements Workable {

    public void work() {
        System.out.println("Working");
    }
}
```

Now the robot only implements what it needs.

---

# Real-Life Example

Imagine a remote control interface:

```text
RemoteControl
----------------
turnOn()
turnOff()
changeChannel()
increaseVolume()
playMusic()
recordVideo()
```

If a simple TV only supports:

```text
turnOn()
turnOff()
changeChannel()
```

forcing it to implement:

```text
playMusic()
recordVideo()
```

is unnecessary.

Instead, create smaller interfaces.

---

## Interview Answer

> **ISP says that a class should not be forced to implement methods that it does not need. We should prefer small, focused interfaces over large, general-purpose interfaces.**

### Memory Trick

> **I = Small Interfaces**

---

# 5. D — Dependency Inversion Principle (DIP)

This is another very important principle for LLD.

## Definition

> **High-level modules should not depend directly on low-level modules. Both should depend on abstractions.**

Also:

> **Abstractions should not depend on details. Details should depend on abstractions.**

In simple words:

> **Depend on interfaces, not concrete classes.**

---

# Bad Example

Suppose we have:

```java
class MySQLDatabase {

    public void save(String data) {
        System.out.println(
            "Saving to MySQL"
        );
    }
}
```

And:

```java
class UserService {

    private MySQLDatabase database =
        new MySQLDatabase();

    public void saveUser(String user) {
        database.save(user);
    }
}
```

Problem:

`UserService` is tightly coupled to:

```text
MySQLDatabase
```

If tomorrow we want:

```text
PostgreSQL
MongoDB
DynamoDB
```

we have to modify `UserService`.

---

# Better Example

Create an abstraction:

```java
interface Database {

    void save(String data);
}
```

MySQL:

```java
class MySQLDatabase implements Database {

    public void save(String data) {
        System.out.println(
            "Saving to MySQL"
        );
    }
}
```

PostgreSQL:

```java
class PostgreSQLDatabase implements Database {

    public void save(String data) {
        System.out.println(
            "Saving to PostgreSQL"
        );
    }
}
```

Now `UserService` depends on the interface:

```java
class UserService {

    private Database database;

    public UserService(Database database) {
        this.database = database;
    }

    public void saveUser(String user) {
        database.save(user);
    }
}
```

Usage:

```java
Database database =
    new MySQLDatabase();

UserService service =
    new UserService(database);

service.saveUser("John");
```

We can easily change it:

```java
Database database =
    new PostgreSQLDatabase();

UserService service =
    new UserService(database);
```

`UserService` doesn't change.

---

# Why Is This Better?

Before:

```text
UserService
     |
     ↓
MySQLDatabase
```

Very tightly coupled.

After:

```text
             Database
              ↑
              |
       ----------------
       |              |
     MySQL        PostgreSQL
       ↑
       |
 UserService
```

`UserService` depends on the abstraction:

```text
Database
```

not on:

```text
MySQLDatabase
```

---

# Dependency Injection

The previous example also demonstrates **Dependency Injection**.

Instead of doing:

```java
private Database database =
    new MySQLDatabase();
```

we pass the dependency:

```java
public UserService(Database database) {
    this.database = database;
}
```

This is called **constructor injection**.

Dependency Injection is one of the common ways to implement Dependency Inversion.

---

# Interview Answer

> **DIP says that high-level modules should depend on abstractions rather than concrete low-level implementations. Both should depend on abstractions. This reduces coupling and makes the system easier to extend and test.**

### Memory Trick

> **D = Depend on abstraction, not concrete implementation.**

---

# 6. All SOLID Principles Together

Let's look at them as one picture.

```text
S → Single Responsibility
    One class → One main responsibility

O → Open/Closed
    Add new behavior → Don't modify existing code unnecessarily

L → Liskov Substitution
    Child → Can safely replace Parent

I → Interface Segregation
    Small interfaces → Don't force unused methods

D → Dependency Inversion
    Depend on interfaces → Not concrete classes
```

---

# 7. Easy Real-Life Analogy

Imagine you're building a **food delivery application**.

### S — Single Responsibility

Don't make one class do everything.

```text
OrderService
PaymentService
NotificationService
DeliveryService
```

Each has a specific responsibility.

---

### O — Open/Closed

Suppose we support:

```text
UPI
Card
PayPal
```

Later we add:

```text
Apple Pay
```

We should add a new implementation rather than keep modifying the existing payment logic.

---

### L — Liskov Substitution

If:

```text
PaymentMethod
```

has a contract, every implementation should honor that contract.

```text
UPI
Card
PayPal
```

should be usable wherever `PaymentMethod` is expected.

---

### I — Interface Segregation

Don't create one huge interface:

```text
Payment
------------------
pay()
refund()
generateInvoice()
sendEmail()
deliverFood()
```

Instead, use focused interfaces:

```text
Payment
Refundable
InvoiceGenerator
EmailSender
DeliveryService
```

---

### D — Dependency Inversion

Don't make:

```text
OrderService → MySQLDatabase
```

Instead:

```text
OrderService → Database Interface
                         ↑
                  MySQL / MongoDB
```

---

# 8. SOLID and Design Patterns

SOLID principles are not design patterns.

They are **design principles** that help us create better software.

Many design patterns help us apply these principles.

For example:

### Strategy

Helps with:

```text
OCP
DIP
```

```text
PaymentStrategy
      ↑
  ------------
  |    |     |
 UPI  Card  PayPal
```

---

### Factory

Helps separate:

```text
Object creation
```

from:

```text
Object usage
```

and can help with coupling and OCP.

---

### State

Helps avoid:

```text
large if-else based on state
```

and separates state-specific responsibilities.

---

### Decorator

Allows adding behavior without modifying the original class.

This strongly relates to:

```text
OCP
```

---

# 9. SOLID vs Design Patterns

This is a common interview question.

### SOLID

SOLID gives us **principles/guidelines**.

```text
How should we design our classes?
```

### Design Patterns

Design patterns give us **reusable solutions** to common design problems.

```text
How can we solve this particular design problem?
```

For example:

```text
SOLID
  ↓
Guidelines

Strategy
Factory
Observer
Decorator
State
Proxy
  ↓
Reusable design solutions
```

---

# 10. Most Important Interview Examples

Remember these examples:

| Principle | Easy Example |
|---|---|
| **S — SRP** | Invoice should not calculate + print + save + email |
| **O — OCP** | Add new payment type without modifying PaymentService |
| **L — LSP** | Child should safely replace parent |
| **I — ISP** | Robot shouldn't implement `eat()` and `sleep()` |
| **D — DIP** | UserService should depend on `Database`, not MySQL |

---

# 11. One-Line Interview Answers

### S — Single Responsibility Principle

> **A class should have one responsibility and one reason to change.**

### O — Open/Closed Principle

> **Classes should be open for extension but closed for modification.**

### L — Liskov Substitution Principle

> **A child class should be usable wherever its parent class is expected without breaking the application.**

### I — Interface Segregation Principle

> **Clients should not be forced to depend on methods they don't use.**

### D — Dependency Inversion Principle

> **High-level modules should depend on abstractions rather than concrete implementations.**

---

# 12. Easy Memory Trick

Remember SOLID as five questions:

```text
S → Does this class have ONE clear job?

O → Can I add functionality without changing existing code?

L → Can the child safely replace the parent?

I → Am I forcing a class to implement things it doesn't need?

D → Am I depending on an interface or a concrete class?
```

If you can answer these five questions while designing an LLD system, your design will usually become much cleaner.

---

# 13. Final Cheat Sheet

```text
                 SOLID
                   |
       ---------------------------
       |    |    |    |          |
       S    O    L    I          D
       |    |    |    |          |
      One  Extend Child Small   Depend
      Job  don't  can   interfaces on
           modify replace       abstraction
           old    parent
```

### The simplest way to remember SOLID:

> **S → One job**

> **O → Extend, don't modify**

> **L → Child can replace parent**

> **I → Keep interfaces small**

> **D → Depend on abstraction**

And one important point for LLD interviews:

> **SOLID principles are guidelines, not strict rules.** Don't introduce interfaces, classes, or patterns just to say that your code is "SOLID." Use them when they make the design more maintainable, flexible, testable, and easier to change.