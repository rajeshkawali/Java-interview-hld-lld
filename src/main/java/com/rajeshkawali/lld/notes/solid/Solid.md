**Bank Account System**, and show **all 5 SOLID principles in the same design**. 

---

# 1. S — Single Responsibility Principle

### What is SRP?

**Interview answer:**

> A class should have one responsibility and one reason to change. It doesn't mean the class can have only one method; it means its methods should belong to the same responsibility.

### Advantages

* Easier to understand
* Easier to test
* Easier to maintain
* Changes have less impact
* Reduces large/complex classes

### Disadvantages / Trade-offs

* Can create too many small classes
* Requires more files and abstractions
* Sometimes splitting too aggressively makes the design harder to understand

---

# 2. O — Open/Closed Principle

### What is OCP?

**Interview answer:**

> A class should be open for extension but closed for modification. We should be able to add new behavior without modifying existing, stable code.

### Advantages

* Easier to add new features
* Existing code is less likely to break
* Reduces regression risk
* Good for extensible systems
* Works well with Strategy and Factory patterns

### Disadvantages / Trade-offs

* Can introduce more interfaces/classes
* May increase complexity
* Over-engineering is possible if extension points are created unnecessarily

---

# 3. L — Liskov Substitution Principle

### What is LSP?

**Interview answer:**

> Objects of a child class should be usable wherever objects of the parent class are expected without changing the correctness of the program.

Simple rule:

```text
Child IS-A valid Parent
```

### Advantages

* Safer inheritance
* Predictable behavior
* Better polymorphism
* Reduces unexpected runtime failures

### Disadvantages / Trade-offs

* Requires careful class hierarchy design
* Sometimes inheritance isn't the right solution
* Can require composition/interfaces instead of simple inheritance

---

# 4. I — Interface Segregation Principle

### What is ISP?

**Interview answer:**

> Clients should not be forced to depend on methods they don't need.

### Advantages

* Smaller interfaces
* Less coupling
* Easier implementation
* Easier testing
* Better flexibility

### Disadvantages / Trade-offs

* More interfaces
* Can increase number of abstractions
* Too much segregation can make the design fragmented

---

# 5. D — Dependency Inversion Principle

### What is DIP?

**Interview answer:**

> High-level modules should not depend directly on low-level concrete implementations. Both should depend on abstractions.

### Advantages

* Loose coupling
* Easy testing
* Easy replacement of implementations
* Better maintainability
* Supports dependency injection

### Disadvantages / Trade-offs

* More interfaces/abstractions
* More configuration
* Can feel complex for simple applications
* Overuse can lead to unnecessary abstraction

---
---


# 🏦 Bank Account — SOLID in One Java Example

```java
// ============================================================
// BANK ACCOUNT SYSTEM
// Demonstrating all SOLID principles in one example
// ============================================================

public class BankApplication {

    public static void main(String[] args) {

        // ----------------------------------------------------
        // DIP:
        // BankService depends on interfaces, not concrete
        // implementations.
        // ----------------------------------------------------

        AccountRepository repository =
                new MySQLAccountRepository();

        NotificationService notification =
                new EmailNotificationService();

        BankService bankService =
                new BankService(repository, notification);


        // Create account
        BankAccount account =
                new BankAccount(101, "John", 10000);

        // Deposit
        bankService.deposit(account, 5000);

        // Withdraw
        bankService.withdraw(account, 2000);
    }
}


// ============================================================
// BANK ACCOUNT
// ============================================================

// S — Single Responsibility Principle
//
// BankAccount is responsible only for maintaining
// account-related data and account operations.
//
// It does NOT:
// - save to database
// - send email
// - send SMS
// - generate reports
//
// ============================================================

class BankAccount {

    private final int accountNumber;
    private final String holderName;

    // Encapsulation:
    // balance is private and cannot be directly modified.
    private double balance;


    public BankAccount(
            int accountNumber,
            String holderName,
            double balance) {

        this.accountNumber = accountNumber;
        this.holderName = holderName;
        this.balance = balance;
    }


    public void deposit(double amount) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Amount must be greater than zero"
            );
        }

        balance += amount;
    }


    public void withdraw(double amount) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Amount must be greater than zero"
            );
        }

        if (amount > balance) {
            throw new IllegalArgumentException(
                    "Insufficient balance"
            );
        }

        balance -= amount;
    }


    public double getBalance() {
        return balance;
    }


    public int getAccountNumber() {
        return accountNumber;
    }


    public String getHolderName() {
        return holderName;
    }
}


// ============================================================
// ACCOUNT REPOSITORY
// ============================================================

// D — Dependency Inversion Principle
//
// BankService will depend on this interface,
// NOT directly on MySQLAccountRepository.
//
// I — Interface Segregation Principle
//
// This interface contains only the operations required
// for account persistence.
//
// ============================================================

interface AccountRepository {

    void save(BankAccount account);

    BankAccount findById(int accountNumber);
}


// ============================================================
// MYSQL REPOSITORY
// ============================================================

// L — Liskov Substitution Principle
//
// MySQLAccountRepository implements AccountRepository.
//
// Therefore it can be substituted anywhere
// AccountRepository is expected.
//
// ============================================================

class MySQLAccountRepository
        implements AccountRepository {

    @Override
    public void save(BankAccount account) {

        System.out.println(
                "Account " +
                account.getAccountNumber() +
                " saved in MySQL"
        );
    }


    @Override
    public BankAccount findById(int accountNumber) {

        System.out.println(
                "Finding account " + accountNumber
        );

        return null;
    }
}


// ============================================================
// NOTIFICATION SERVICE
// ============================================================

// O — Open/Closed Principle
//
// BankService depends on NotificationService.
//
// We can add:
//
// SmsNotificationService
// PushNotificationService
// WhatsAppNotificationService
//
// without modifying BankService.
//
// ============================================================

interface NotificationService {

    void send(String message);
}


// ============================================================
// EMAIL NOTIFICATION
// ============================================================

// L — Liskov Substitution Principle
//
// EmailNotificationService can be substituted
// wherever NotificationService is expected.
//
// ============================================================

class EmailNotificationService
        implements NotificationService {

    @Override
    public void send(String message) {

        System.out.println(
                "Email notification: " + message
        );
    }
}


// ============================================================
// SMS NOTIFICATION
// ============================================================

// O — Open/Closed Principle
//
// We added a new notification type without modifying
// BankService.
//
// ============================================================

class SmsNotificationService
        implements NotificationService {

    @Override
    public void send(String message) {

        System.out.println(
                "SMS notification: " + message
        );
    }
}


// ============================================================
// BANK SERVICE
// ============================================================

// S — SRP
//
// BankService is responsible for coordinating
// banking operations.
//
// It doesn't know HOW data is stored.
// It doesn't know HOW notification is sent.
//
//
//
// D — DIP
//
// BankService depends on:
//
// AccountRepository      → abstraction
// NotificationService    → abstraction
//
// NOT:
//
// MySQLAccountRepository
// EmailNotificationService
//
//
// Dependencies are injected through constructor.
//
// ============================================================

class BankService {

    private final AccountRepository repository;

    private final NotificationService notification;


    // Constructor Dependency Injection
    public BankService(
            AccountRepository repository,
            NotificationService notification) {

        this.repository = repository;
        this.notification = notification;
    }


    public void deposit(
            BankAccount account,
            double amount) {

        // Account handles its own balance logic.
        account.deposit(amount);

        // Repository handles persistence.
        repository.save(account);

        // Notification handles notification.
        notification.send(
                "₹" + amount +
                " deposited into account " +
                account.getAccountNumber()
        );
    }


    public void withdraw(
            BankAccount account,
            double amount) {

        // Account handles withdrawal rules.
        account.withdraw(amount);

        // Repository handles persistence.
        repository.save(account);

        // Notification handles notification.
        notification.send(
                "₹" + amount +
                " withdrawn from account " +
                account.getAccountNumber()
        );
    }
}
```

# Now understand the 5 principles using ONLY this Bank example

## 1. S — Single Responsibility

**Question:** What is SRP here?

```text
BankAccount
    → Account data + account balance operations

BankService
    → Banking workflow

AccountRepository
    → Database operations

NotificationService
    → Notification
```

### Interview answer

> "Each class has one clear responsibility. `BankAccount` manages account state, `AccountRepository` handles persistence, `NotificationService` handles notifications, and `BankService` coordinates the banking operation."

---

# 2. O — Open/Closed

Suppose the bank initially supports Email:

```java
NotificationService notification =
        new EmailNotificationService();
```

Tomorrow we want SMS.

We simply add:

```java
class SmsNotificationService
        implements NotificationService {

    @Override
    public void send(String message) {
        System.out.println("SMS: " + message);
    }
}
```

And change the configuration:

```java
NotificationService notification =
        new SmsNotificationService();
```

We **don't modify `BankService`**.

### Interview answer

> "The system is open for adding new notification implementations but closed for modifying BankService. This follows OCP."

---

# 3. L — Liskov Substitution

We have:

```java
NotificationService notification;
```

We can use:

```java
notification =
    new EmailNotificationService();
```

or:

```java
notification =
    new SmsNotificationService();
```

Both can replace `NotificationService`.

Same with repository:

```java
AccountRepository repository =
    new MySQLAccountRepository();
```

Any valid implementation of `AccountRepository` should work.

### Interview answer

> "Any implementation of an abstraction should be safely substitutable for that abstraction. For example, EmailNotificationService and SmsNotificationService can both be used wherever NotificationService is expected."

---

# 4. I — Interface Segregation

Instead of creating a huge interface:

```java
// ❌ BAD

interface BankOperations {

    void deposit();

    void withdraw();

    void sendEmail();

    void sendSms();

    void saveToDatabase();

    void generateReport();

    void audit();

}
```

We keep interfaces focused:

```java
interface AccountRepository {

    void save(BankAccount account);

    BankAccount findById(int accountNumber);
}
```

and:

```java
interface NotificationService {

    void send(String message);
}
```

### Interview answer

> "I keep interfaces small and focused so implementations don't have to depend on methods they don't need."

---

# 5. D — Dependency Inversion

This is the most important one to understand.

### ❌ Bad

```java
class BankService {

    private MySQLAccountRepository repository =
            new MySQLAccountRepository();

    private EmailNotificationService notification =
            new EmailNotificationService();
}
```

Now:

```text
BankService
     ↓
MySQL
Email
```

Very tightly coupled.

### ✅ Good

```java
class BankService {

    private final AccountRepository repository;

    private final NotificationService notification;

    BankService(
            AccountRepository repository,
            NotificationService notification) {

        this.repository = repository;
        this.notification = notification;
    }
}
```

Now:

```text
                  BankService
                  /         \
                 ↓           ↓
       AccountRepository   NotificationService
                 ↑           ↑
                 |           |
              MySQL        Email
              Mongo         SMS
```

### Interview answer

> "BankService is a high-level business component. Instead of depending directly on MySQL or Email implementations, it depends on abstractions. The concrete implementations are injected from outside."

---

# ⭐ One interview question covering everything

**Interviewer:**
*"Explain how you applied SOLID principles in your banking system."*

### Copy this answer:

```text
I applied SOLID principles as follows:

SRP:
BankAccount manages account state and balance operations.
AccountRepository handles persistence.
NotificationService handles notifications.
BankService coordinates the banking workflow.

OCP:
I use interfaces for notifications and repositories, so
new implementations like SMS, WhatsApp or MongoDB can be
added without modifying BankService.

LSP:
Implementations such as EmailNotificationService and
SmsNotificationService can be substituted wherever
NotificationService is expected.

ISP:
I keep interfaces small and focused. For example,
NotificationService only contains notification-related
operations and AccountRepository contains persistence-related
operations.

DIP:
BankService does not directly create MySQLRepository or
EmailNotificationService. It depends on AccountRepository
and NotificationService abstractions, and I inject the
dependencies through the constructor.
```

## 🧠 Remember this one diagram

```text
                     BankService
                    /           \
                   ↓             ↓
          AccountRepository   NotificationService
                   ↓             ↓
                MySQL          Email
                Mongo           SMS


BankAccount
    ↓
Owns balance + account rules


SOLID:

S → Separate responsibilities
O → Add implementations without changing BankService
L → Implementations can replace their interfaces
I → Small, focused interfaces
D → BankService depends on interfaces
```

---

```
Memorize this:

S — Single Responsibility
    One class → One responsibility
    One reason to change

O — Open/Closed
    Open for extension
    Closed for modification

L — Liskov Substitution
    Child should be substitutable for parent
    Don't break parent's contract

I — Interface Segregation
    Prefer small, focused interfaces
    Don't force unused methods

D — Dependency Inversion
    Depend on abstractions
    Not concrete implementations
```

---
