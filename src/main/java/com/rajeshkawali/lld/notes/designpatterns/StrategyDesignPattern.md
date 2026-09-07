# Strategy Design Pattern

## 1. Definition

The **Strategy Design Pattern** is a **behavioral design pattern** that allows us to define multiple algorithms or behaviors, put each one in a separate class, and make them interchangeable at runtime.

Instead of putting many `if-else` or `switch` conditions inside one class, we create separate strategy classes and choose the required strategy dynamically.

### Simple definition

> **Strategy Pattern = Define different ways of doing something and choose the required way at runtime.**

---

# 2. Real-Life Example

Imagine a **Google Maps** application.

You want to travel from:

**Home → Office**

You can choose different strategies:

- 🚗 Car
- 🚶 Walking
- 🚲 Bicycle
- 🚌 Public Transport

The destination is the same, but the **strategy for reaching it is different**.

Instead of writing:

```java
if (transport == "CAR") {
    // calculate car route
} else if (transport == "WALK") {
    // calculate walking route
} else if (transport == "BIKE") {
    // calculate bicycle route
}
```

we create separate classes:

```text
CarRouteStrategy
WalkingRouteStrategy
BikeRouteStrategy
```

and choose one at runtime.

---

# 3. Problem Without Strategy Pattern

Suppose we have a payment system:

```java
class PaymentService {

    public void pay(String paymentType) {

        if (paymentType.equals("CREDIT_CARD")) {
            System.out.println("Pay using Credit Card");

        } else if (paymentType.equals("UPI")) {
            System.out.println("Pay using UPI");

        } else if (paymentType.equals("PAYPAL")) {
            System.out.println("Pay using PayPal");
        }
    }
}
```

Initially this looks simple.

But imagine we add:

- Credit Card
- Debit Card
- UPI
- PayPal
- Net Banking
- Wallet
- Crypto

Our class keeps growing.

```text
PaymentService
     |
     |-- if Credit Card
     |-- if UPI
     |-- if PayPal
     |-- if Wallet
     |-- if Net Banking
     |-- if Crypto
     |-- ...
```

This creates several problems:

- Large `if-else`/`switch`
- Difficult to maintain
- Difficult to test
- Adding a new payment method requires modifying existing code
- Violates the **Open/Closed Principle**

---

# 4. Solution Using Strategy Pattern

We separate each payment algorithm into its own class.

```text
                 PaymentStrategy
                       |
          -----------------------------
          |             |             |
     CreditCard       UPI          PayPal
      Strategy       Strategy       Strategy
```

The client doesn't need to know how each payment method works.

It simply chooses a strategy.

---

# 5. Structure of Strategy Pattern

There are usually three important parts:

### 1. Strategy

Common interface for all algorithms.

```java
interface PaymentStrategy {
    void pay(double amount);
}
```

### 2. Concrete Strategies

Different implementations of the strategy.

```java
class CreditCardPayment implements PaymentStrategy {
    @Override
    public void pay(double amount) {
        System.out.println("Paid ₹" + amount + " using Credit Card");
    }
}
```

```java
class UPIPayment implements PaymentStrategy {
    @Override
    public void pay(double amount) {
        System.out.println("Paid ₹" + amount + " using UPI");
    }
}
```

```java
class PayPalPayment implements PaymentStrategy {
    @Override
    public void pay(double amount) {
        System.out.println("Paid ₹" + amount + " using PayPal");
    }
}
```

### 3. Context

The Context uses the selected strategy.

```java
class PaymentService {

    private PaymentStrategy paymentStrategy;

    public PaymentService(PaymentStrategy paymentStrategy) {
        this.paymentStrategy = paymentStrategy;
    }

    public void makePayment(double amount) {
        paymentStrategy.pay(amount);
    }
}
```

---

# 6. Complete Example

```java
interface PaymentStrategy {
    void pay(double amount);
}
```

### Credit Card Strategy

```java
class CreditCardPayment implements PaymentStrategy {

    @Override
    public void pay(double amount) {
        System.out.println(
            "Paid ₹" + amount + " using Credit Card"
        );
    }
}
```

### UPI Strategy

```java
class UPIPayment implements PaymentStrategy {

    @Override
    public void pay(double amount) {
        System.out.println(
            "Paid ₹" + amount + " using UPI"
        );
    }
}
```

### PayPal Strategy

```java
class PayPalPayment implements PaymentStrategy {

    @Override
    public void pay(double amount) {
        System.out.println(
            "Paid ₹" + amount + " using PayPal"
        );
    }
}
```

### Context

```java
class PaymentService {

    private PaymentStrategy paymentStrategy;

    public PaymentService(PaymentStrategy paymentStrategy) {
        this.paymentStrategy = paymentStrategy;
    }

    public void makePayment(double amount) {
        paymentStrategy.pay(amount);
    }
}
```

### Main

```java
public class Main {

    public static void main(String[] args) {

        PaymentStrategy strategy =
                new UPIPayment();

        PaymentService paymentService =
                new PaymentService(strategy);

        paymentService.makePayment(1000);
    }
}
```

### Output

```text
Paid ₹1000.0 using UPI
```

We can easily change the strategy:

```java
PaymentStrategy strategy =
        new CreditCardPayment();

PaymentService paymentService =
        new PaymentService(strategy);

paymentService.makePayment(1000);
```

Output:

```text
Paid ₹1000.0 using Credit Card
```

No changes are required inside `PaymentService`.

---

# 7. Why Is It Called Strategy?

Because each implementation represents a different **strategy for performing the same operation**.

For example:

```text
PaymentStrategy
       |
       +-- CreditCardPayment
       |
       +-- UPIPayment
       |
       +-- PayPalPayment
```

All of them answer the same question:

> "How should I make the payment?"

But each one has a different implementation.

---

# 8. Important Concept: Composition

Strategy Pattern mainly uses **composition**, not inheritance.

The `PaymentService` has a reference to:

```java
PaymentStrategy
```

```java
class PaymentService {

    private PaymentStrategy strategy;
}
```

So we can inject different strategies.

```java
new PaymentService(new UPIPayment());
```

or

```java
new PaymentService(new CreditCardPayment());
```

This gives us flexibility.

---

# 9. Runtime Strategy Change

One of the important benefits is that we can change the strategy at runtime.

For example:

```java
class PaymentService {

    private PaymentStrategy strategy;

    public void setStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void makePayment(double amount) {
        strategy.pay(amount);
    }
}
```

Now:

```java
PaymentService paymentService =
        new PaymentService(new UPIPayment());

paymentService.makePayment(500);

paymentService.setStrategy(
        new CreditCardPayment()
);

paymentService.makePayment(1000);
```

Output:

```text
Paid ₹500.0 using UPI
Paid ₹1000.0 using Credit Card
```

The behavior changed **without modifying `PaymentService`**.

---

# 10. LLD Example — Payment System

A more realistic LLD could look like this:

```text
                    PaymentStrategy
                          |
          ---------------------------------
          |               |               |
    CreditCard        UPIPayment      PayPalPayment
     Payment

                          ↑
                          |
                   PaymentService
                          |
                       Client
```

### PaymentStrategy

```java
interface PaymentStrategy {
    void pay(double amount);
}
```

### Credit Card

```java
class CreditCardPayment implements PaymentStrategy {

    public void pay(double amount) {
        // Validate card
        // Contact bank
        // Process payment
        System.out.println("Credit Card Payment");
    }
}
```

### UPI

```java
class UPIPayment implements PaymentStrategy {

    public void pay(double amount) {
        // Validate UPI
        // Send payment request
        // Verify transaction
        System.out.println("UPI Payment");
    }
}
```

### Payment Service

```java
class PaymentService {

    private PaymentStrategy strategy;

    public PaymentService(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void pay(double amount) {
        strategy.pay(amount);
    }
}
```

The service doesn't care about the actual payment implementation.

It only knows:

```java
strategy.pay(amount);
```

This is **loose coupling**.

---

# 11. Another Common Example — Sorting

Suppose an application supports multiple sorting algorithms:

```text
SortingStrategy
      |
      |-- BubbleSort
      |-- MergeSort
      |-- QuickSort
```

Interface:

```java
interface SortStrategy {
    void sort(int[] arr);
}
```

Implementations:

```java
class QuickSort implements SortStrategy {

    public void sort(int[] arr) {
        System.out.println("Sorting using Quick Sort");
    }
}
```

```java
class MergeSort implements SortStrategy {

    public void sort(int[] arr) {
        System.out.println("Sorting using Merge Sort");
    }
}
```

Context:

```java
class SortService {

    private SortStrategy strategy;

    public SortService(SortStrategy strategy) {
        this.strategy = strategy;
    }

    public void sort(int[] arr) {
        strategy.sort(arr);
    }
}
```

Usage:

```java
SortService service =
        new SortService(new QuickSort());

service.sort(arr);
```

We can replace it with:

```java
SortService service =
        new SortService(new MergeSort());
```

without changing `SortService`.

---

# 12. Strategy Pattern vs If-Else

### Without Strategy

```java
if (type == CREDIT_CARD) {
    ...
} else if (type == UPI) {
    ...
} else if (type == PAYPAL) {
    ...
}
```

### With Strategy

```java
PaymentStrategy strategy =
        new UPIPayment();

strategy.pay(amount);
```

The second approach is cleaner when there are **many interchangeable behaviors**.

---

# 13. Advantages

### 1. Removes large if-else/switch blocks

Different behaviors are moved into separate classes.

### 2. Follows Open/Closed Principle

We can add:

```java
class ApplePayPayment implements PaymentStrategy
```

without modifying `PaymentService`.

### 3. Easy to test

Each strategy can be tested independently.

### 4. Runtime flexibility

We can change the strategy dynamically.

### 5. Loose coupling

The Context depends on the interface rather than concrete implementations.

### 6. Single Responsibility

Each strategy is responsible for one specific algorithm/behavior.

---

# 14. Disadvantages

### 1. More classes

Instead of one class, we may have:

```text
PaymentStrategy
CreditCardPayment
UPIPayment
PayPalPayment
WalletPayment
...
```

### 2. Client needs to know the strategies

The client generally needs to decide which strategy to use.

### 3. Can be unnecessary for simple logic

If there are only two very simple conditions, creating multiple strategy classes may add unnecessary complexity.

---

# 15. Strategy vs State Pattern

These two patterns are often confused.

| Strategy | State |
|---|---|
| Chooses an algorithm/behavior | Represents current state |
| Usually selected by client/configuration | Usually changes because of internal state |
| Focuses on interchangeable behavior | Focuses on behavior changing with state |
| Example: Payment method | Example: Order status |

### Strategy

```text
Payment
  |
  +-- UPI
  +-- Card
  +-- PayPal
```

### State

```text
Order
  |
  +-- Created
  +-- Paid
  +-- Shipped
  +-- Delivered
```

**Memory trick:**

> Strategy = "Which way should I do it?"

> State = "What state am I currently in?"

---

# 16. Strategy vs Factory

They are also commonly used together.

### Factory

Factory answers:

> **Which object should I create?**

Example:

```java
PaymentStrategy strategy =
    PaymentFactory.getPaymentMethod("UPI");
```

### Strategy

Strategy answers:

> **How should I perform the operation?**

Example:

```java
strategy.pay(1000);
```

So:

```text
Factory
   ↓
Creates Strategy
   ↓
Strategy performs behavior
```

They can work together.

---

# 17. Strategy vs Template Method

### Strategy

Uses **composition**.

```text
Context
   |
   has-a
   ↓
Strategy
```

Different algorithms are represented by different objects.

### Template Method

Uses **inheritance**.

```text
Base Class
    |
    +-- Child Class
    +-- Child Class
```

The parent defines the overall algorithm and subclasses customize certain steps.

---

# 18. When Should We Use Strategy Pattern?

Use Strategy when:

- You have multiple ways of performing the same task.
- You have many `if-else` or `switch` statements.
- Algorithms can change independently.
- You want to choose behavior at runtime.
- You want to follow Open/Closed Principle.
- Different algorithms need to be tested independently.

### Common examples

```text
Payment methods
   ↓
UPI / Card / PayPal

Payment calculation
   ↓
Cash / Card / Wallet

Routing
   ↓
Car / Walking / Bike

Sorting
   ↓
QuickSort / MergeSort

Discount calculation
   ↓
Regular / Premium / Festival

Compression
   ↓
ZIP / GZIP / RAR

Notification
   ↓
Email / SMS / Push
```

---

# 19. Interview-Friendly Answer

If an interviewer asks:

> "What is Strategy Design Pattern?"

You can answer:

> **Strategy is a behavioral design pattern that defines a family of interchangeable algorithms or behaviors, encapsulates each one in a separate class, and allows the client to choose or change the behavior at runtime. It helps avoid large if-else or switch statements and follows the Open/Closed Principle.**

### Example:

> For a payment system, instead of putting UPI, Credit Card, and PayPal logic inside one `PaymentService`, we create separate `PaymentStrategy` implementations such as `UPIPayment`, `CreditCardPayment`, and `PayPalPayment`. `PaymentService` uses the selected strategy through the common interface.

---

# 20. Easy Way to Remember

Remember these 3 words:

> **Strategy = Separate + Encapsulate + Switch**

### Separate

Put different algorithms in different classes.

### Encapsulate

Hide the implementation behind a common interface.

### Switch

Choose/change the required strategy at runtime.

```text
                  Strategy
                     |
        -----------------------------
        |             |             |
       UPI           CARD         PAYPAL
        |             |             |
        -----------------------------
                     ↑
                     |
                  Context
```

### One-line memory trick

> **Strategy Pattern = "Same job, different ways of doing it."**

For example:

**Pay → UPI / Card / PayPal**

**Travel → Car / Bus / Walk**

**Sort → QuickSort / MergeSort / BubbleSort**

**Discount → Regular / Premium / Festival**

That's the core idea of the Strategy Design Pattern.