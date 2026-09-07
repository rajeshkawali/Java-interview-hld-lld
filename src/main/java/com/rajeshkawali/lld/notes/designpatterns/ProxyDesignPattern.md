# Proxy Design Pattern

## 1. Definition

The **Proxy Design Pattern** is a **structural design pattern** where one object acts as a substitute or representative for another object.

The Proxy has the **same interface** as the real object and controls access to it.

### Simple definition

> **Proxy Pattern = Put a substitute object in front of the real object to control access to it.**

The client thinks it is talking to the real object, but actually it talks to the **Proxy**.

```text
Client
   |
   ↓
 Proxy
   |
   ↓
Real Object
```

---

# 2. Real-Life Example

Think about a **security guard** at an office.

You want to enter the office:

```text
You
 ↓
Security Guard
 ↓
Office
```

You don't directly access the office.

The security guard checks:

- Who are you?
- Do you have permission?
- Are you allowed to enter?

If everything is valid, the guard allows you to enter.

Here:

```text
Security Guard = Proxy
Office = Real Object
You = Client
```

The Proxy controls access to the real object.

---

# 3. Why Do We Need Proxy?

Suppose we have:

```java
interface BankService {
    void withdraw(double amount);
}
```

And:

```java
class RealBankService implements BankService {

    @Override
    public void withdraw(double amount) {
        System.out.println("Withdrawing ₹" + amount);
    }
}
```

The client can directly access it:

```java
BankService bankService =
        new RealBankService();

bankService.withdraw(5000);
```

But what if we need to add:

- Authentication
- Authorization
- Logging
- Caching
- Rate limiting
- Validation

We could put everything inside `RealBankService`.

But then the class becomes responsible for too many things.

Instead, we introduce a Proxy.

---

# 4. Basic Structure

```text
                 BankService
                      ↑
             ------------------
             |                |
        BankServiceProxy   RealBankService
             ↑
             |
           Client
```

Both Proxy and Real Object implement the same interface.

That is important.

---

# 5. Simple Java Example

## Step 1 — Common Interface

```java
interface BankService {

    void withdraw(double amount);
}
```

---

## Step 2 — Real Object

```java
class RealBankService implements BankService {

    @Override
    public void withdraw(double amount) {
        System.out.println(
            "Withdrawing ₹" + amount
        );
    }
}
```

This is the actual object that performs the operation.

---

## Step 3 — Proxy

```java
class BankServiceProxy implements BankService {

    private RealBankService realBankService;

    public BankServiceProxy() {
        this.realBankService =
                new RealBankService();
    }

    @Override
    public void withdraw(double amount) {

        if (amount <= 0) {
            System.out.println(
                "Invalid amount"
            );
            return;
        }

        System.out.println(
            "Checking security..."
        );

        realBankService.withdraw(amount);
    }
}
```

The Proxy performs validation/security checks before calling the real object.

---

## Step 4 — Client

```java
public class Main {

    public static void main(String[] args) {

        BankService bankService =
                new BankServiceProxy();

        bankService.withdraw(5000);
    }
}
```

Output:

```text
Checking security...
Withdrawing ₹5000.0
```

The client doesn't directly interact with:

```java
new RealBankService();
```

It interacts with:

```java
new BankServiceProxy();
```

---

# 6. How Proxy Works

The flow is:

```text
Client
   |
   | withdraw(5000)
   ↓
BankServiceProxy
   |
   | Validate / Authenticate / Log
   ↓
RealBankService
   |
   ↓
Actual operation
```

The Proxy can decide:

```text
Should I allow the request?
        |
   -------------
   |           |
   Yes          No
   |            |
   ↓            ↓
Real Object    Reject
```

---

# 7. Proxy for Authentication

A very common LLD example is **access control**.

Suppose:

```java
interface DocumentService {

    void readDocument();
}
```

Real service:

```java
class RealDocumentService
        implements DocumentService {

    @Override
    public void readDocument() {
        System.out.println(
            "Reading confidential document..."
        );
    }
}
```

Proxy:

```java
class DocumentProxy
        implements DocumentService {

    private RealDocumentService realService;
    private boolean authenticated;

    public DocumentProxy(boolean authenticated) {
        this.authenticated = authenticated;
        this.realService =
                new RealDocumentService();
    }

    @Override
    public void readDocument() {

        if (!authenticated) {
            System.out.println(
                "Access Denied"
            );
            return;
        }

        realService.readDocument();
    }
}
```

Client:

```java
DocumentService document =
        new DocumentProxy(false);

document.readDocument();
```

Output:

```text
Access Denied
```

With authentication:

```java
DocumentService document =
        new DocumentProxy(true);

document.readDocument();
```

Output:

```text
Reading confidential document...
```

The Proxy controls access to the real object.

---

# 8. Proxy for Lazy Loading

Another very common use case is **lazy loading**.

Imagine we have a large image:

```text
image.jpg = 50 MB
```

We don't want to load it immediately.

Instead:

```text
Client
   |
   ↓
ImageProxy
   |
   ↓
RealImage
```

The real image is loaded only when needed.

---

## Example

```java
interface Image {

    void display();
}
```

Real Image:

```java
class RealImage implements Image {

    private String fileName;

    public RealImage(String fileName) {
        this.fileName = fileName;
        loadFromDisk();
    }

    private void loadFromDisk() {
        System.out.println(
            "Loading " + fileName
        );
    }

    @Override
    public void display() {
        System.out.println(
            "Displaying " + fileName
        );
    }
}
```

Proxy:

```java
class ImageProxy implements Image {

    private String fileName;
    private RealImage realImage;

    public ImageProxy(String fileName) {
        this.fileName = fileName;
    }

    @Override
    public void display() {

        if (realImage == null) {
            realImage =
                new RealImage(fileName);
        }

        realImage.display();
    }
}
```

Client:

```java
Image image =
        new ImageProxy("photo.jpg");

System.out.println("Image object created");

image.display();
image.display();
```

Output:

```text
Image object created
Loading photo.jpg
Displaying photo.jpg
Displaying photo.jpg
```

Notice:

```text
new ImageProxy(...)
```

doesn't immediately load the actual image.

The image is loaded only when:

```java
image.display();
```

is called.

This is **lazy initialization**.

---

# 9. Proxy for Caching

Proxy can also be used for caching.

Suppose we have:

```java
interface ProductService {

    Product getProduct(int id);
}
```

The real service gets data from a database:

```text
Client
   ↓
ProductProxy
   ↓
RealProductService
   ↓
Database
```

First request:

```text
getProduct(10)
      ↓
Cache miss
      ↓
Database
      ↓
Store result in cache
```

Second request:

```text
getProduct(10)
      ↓
Cache hit
      ↓
Return cached result
```

This avoids unnecessary database calls.

---

# 10. Proxy for Logging

Proxy can also add logging.

```java
class LoggingPaymentProxy
        implements PaymentService {

    private PaymentService realService;

    public LoggingPaymentProxy(
            PaymentService realService) {

        this.realService = realService;
    }

    @Override
    public void pay(double amount) {

        System.out.println(
            "Payment started: " + amount
        );

        realService.pay(amount);

        System.out.println(
            "Payment completed"
        );
    }
}
```

The real payment class doesn't need to know anything about logging.

The Proxy adds that responsibility.

---

# 11. Main Types of Proxy

There are several common types.

### 1. Virtual Proxy

Used for **lazy loading**.

Example:

```text
Large Image
Large File
Expensive Database Object
```

---

### 2. Protection Proxy

Used for **access control**.

Example:

```text
Admin
User
Guest
```

The Proxy decides who can access the real object.

---

### 3. Remote Proxy

Represents an object located somewhere else, such as another server.

```text
Client
   ↓
Remote Proxy
   ↓
Network
   ↓
Remote Service
```

Examples include remote APIs and distributed systems.

---

### 4. Caching Proxy

Stores previous results.

```text
Client
   ↓
Cache Proxy
   |
   +-- Cache Hit → Return result
   |
   +-- Cache Miss → Real Object
```

---

### 5. Logging Proxy

Adds logging around method calls.

```text
Client
   ↓
Logging Proxy
   ↓
Real Object
```

---

# 12. Proxy vs Decorator

Since you have already learned **Decorator**, this is extremely important.

Both patterns can look very similar because both wrap another object.

### Proxy

> **Controls access to an object.**

Examples:

```text
Authentication
Authorization
Lazy Loading
Caching
Remote Access
```

### Decorator

> **Adds new behavior/functionality to an object.**

Examples:

```text
Coffee
  ↓
MilkDecorator
  ↓
SugarDecorator
```

---

## Simple Difference

```text
Proxy:
Client → Proxy → Real Object
          |
          ↓
     Control Access
```

```text
Decorator:
Client → Decorator → Object
          |
          ↓
      Add Behavior
```

### Memory trick

> **Proxy = "Can I access it?"**

> **Decorator = "What extra behavior can I add?"**

---

# 13. Proxy vs Adapter

Another common interview question.

### Proxy

Keeps the **same interface**.

```text
Client
  ↓
Proxy
  ↓
Real Object
```

The purpose is to control access.

### Adapter

Changes one interface into another compatible interface.

```text
Client
  ↓
Adapter
  ↓
Existing Class
```

The purpose is compatibility.

### Memory trick

> **Proxy = Control access**

> **Adapter = Change interface**

---

# 14. Proxy vs Facade

You also learned Facade.

### Proxy

Represents **one real object**.

```text
Client
   ↓
Proxy
   ↓
Real Object
```

### Facade

Provides a simple interface to **multiple subsystem classes**.

```text
Client
   ↓
Facade
   ↓
-------------------------
|    |     |     |      |
A    B     C     D      E
```

### Memory trick

> **Proxy = One object + controlled access**

> **Facade = Many objects + simplified interface**

---

# 15. Advantages

### 1. Access Control

Proxy can check permissions before allowing access.

### 2. Lazy Loading

Expensive objects can be created only when needed.

### 3. Caching

Proxy can cache expensive results.

### 4. Logging

Proxy can add logging without modifying the real object.

### 5. Security

Authentication and authorization can be handled by the Proxy.

### 6. Separation of Concerns

The real object focuses on its core business logic while the Proxy handles additional concerns.

---

# 16. Disadvantages

### 1. Extra Complexity

You introduce another class between the client and real object.

```text
Client → Proxy → Real Object
```

### 2. Performance Overhead

Every call goes through the Proxy.

Usually this overhead is small, but remote proxies can have significant network overhead.

### 3. Debugging Can Be More Difficult

There is another layer to trace.

---

# 17. Proxy in Real Java/Spring Applications

Proxy is very common in enterprise Java applications.

For example, frameworks can create proxies to provide:

```text
@Transactional
    ↓
Transaction Proxy

@Cacheable
    ↓
Caching Proxy

@PreAuthorize
    ↓
Security Proxy
```

Conceptually:

```text
Client
   ↓
Framework Proxy
   ↓
Actual Service
```

The Proxy can perform work before and/or after calling the actual service.

---

# 18. LLD Example — E-Commerce Product Service

Imagine an e-commerce application.

```text
Client
   |
   ↓
ProductServiceProxy
   |
   |-- Check authentication
   |-- Check cache
   |-- Logging
   |
   ↓
RealProductService
   |
   ↓
Database
```

A request might work like this:

```text
getProduct(101)
      ↓
Authentication check
      ↓
Cache check
      ↓
Cache Hit?
   /       \
 Yes        No
 |           |
 ↓           ↓
Return    Database
             ↓
          Store Cache
             ↓
          Return
```

This is a practical example of combining multiple proxy responsibilities.

---

# 19. When Should You Use Proxy?

Use Proxy when you need to:

- Control access to an object.
- Add authentication or authorization.
- Delay expensive object creation.
- Cache results.
- Add logging or monitoring.
- Access a remote object.
- Add security checks.
- Hide expensive operations behind a lightweight object.

Common examples:

```text
Authentication
Authorization
Caching
Lazy Loading
Logging
Remote Services
Rate Limiting
Database Access
API Clients
```

---

# 20. Interview-Friendly Answer

If the interviewer asks:

> **What is Proxy Design Pattern?**

You can say:

> **Proxy is a structural design pattern where a proxy object acts as a substitute for a real object and controls access to it. Both the proxy and real object implement the same interface, allowing the client to interact with the proxy without knowing whether it is communicating directly with the real object.**

Then give an example:

> For example, in a document service, a `DocumentProxy` can check whether the user is authenticated before forwarding the request to `RealDocumentService`. Proxy can also be used for caching, logging, lazy loading, and remote access.

---

# 21. Easy Way to Remember

Think about a **security guard**:

```text
You
 ↓
Security Guard
 ↓
Office
```

The guard doesn't perform the actual office work.

The guard **controls access** to the office.

Similarly:

```text
Client
 ↓
Proxy
 ↓
Real Object
```

The Proxy doesn't necessarily perform the main business operation.

It controls or manages access to the real object.

---

# 22. Final Cheat Sheet

| Pattern | Main Purpose | Example |
|---|---|---|
| **Proxy** | Control access to an object | Authentication, caching |
| **Decorator** | Add behavior | Coffee + Milk + Sugar |
| **Adapter** | Convert interface | Legacy API integration |
| **Facade** | Simplify multiple classes | Booking system |
| **Strategy** | Choose algorithm/behavior | UPI/Card/PayPal |
| **Factory** | Create an object | Car/Bike/Truck |
| **Abstract Factory** | Create related object family | Windows UI/Mac UI |
| **Singleton** | One instance | Logger/Config |

### One-line memory trick

> **Proxy = "A middleman that controls access to the real object."**

The three most important things to remember for interviews are:

```text
Proxy
 ↓
Same interface as Real Object
 ↓
Client talks to Proxy
 ↓
Proxy controls/augments access
 ↓
Proxy may call Real Object
```

**Proxy = Control Access + Same Interface + Real Object behind it.**