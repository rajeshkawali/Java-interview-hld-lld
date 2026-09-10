# Abstract Class vs Interface in Java

## 1. Short Interview Answer

An **abstract class** is generally used when multiple classes share a strong **"is-a" relationship**, common state, constructors, and some common implementation.

An **interface** is primarily used to define a **contract/capability** that can be implemented by unrelated classes. It helps achieve loose coupling and allows a class to implement multiple contracts.

For an 8+ years experienced developer, the important point is not just *"abstract class vs interface"*, but **why I would choose one over the other from a design perspective**.

---

# 2. Abstract Class

An abstract class is a class that cannot be instantiated directly and can contain both:

- Abstract methods
- Concrete methods
- Instance variables
- Constructors
- Static methods
- Final methods
- Private/protected/public methods
- Initialization blocks

### Example

```java
abstract class Payment {

    protected double amount;

    public Payment(double amount) {
        this.amount = amount;
    }

    // Common behavior
    public void validateAmount() {
        if (amount <= 0) {
            throw new IllegalArgumentException("Invalid amount");
        }
    }

    // Subclass-specific behavior
    public abstract void processPayment();
}
```

Concrete implementations:

```java
class CreditCardPayment extends Payment {

    public CreditCardPayment(double amount) {
        super(amount);
    }

    @Override
    public void processPayment() {
        System.out.println("Processing credit card payment");
    }
}

class UPIPayment extends Payment {

    public UPIPayment(double amount) {
        super(amount);
    }

    @Override
    public void processPayment() {
        System.out.println("Processing UPI payment");
    }
}
```

Usage:

```java
Payment payment = new CreditCardPayment(1000);

payment.validateAmount();
payment.processPayment();
```

### Why abstract class is useful here?

Both payment types:

- Have an `amount`
- Need amount validation
- Have common initialization
- Have payment-specific processing

So the abstract class provides **shared state + shared behavior + extensibility**.

---

# 3. Interface

An interface defines a contract that a class agrees to implement.

```java
interface Refundable {

    void refund();
}
```

Multiple unrelated classes can implement it:

```java
class CreditCardPayment implements Refundable {

    @Override
    public void refund() {
        System.out.println("Refunding credit card payment");
    }
}

class Order implements Refundable {

    @Override
    public void refund() {
        System.out.println("Refunding order");
    }
}
```

Here, `CreditCardPayment` and `Order` don't necessarily have the same inheritance hierarchy.

But both have the **capability to perform a refund**.

That's where an interface is a better abstraction.

---

# 4. The Most Important Design Difference

A useful way to think about it:

```text
Abstract Class
      ↓
"What are you?"
      ↓
Shared identity + state + behavior
```

Example:

```text
Payment
   |
   +-- CreditCardPayment
   +-- UPIPayment
   +-- NetBankingPayment
```

Whereas:

```text
Interface
      ↓
"What can you do?"
      ↓
Capability / Contract
```

Example:

```text
Refundable
   ↑
   |
CreditCardPayment

Refundable
   ↑
   |
Order

Refundable
   ↑
   |
Subscription
```

A class can implement multiple capabilities:

```java
class Payment implements Refundable, Auditable, Retryable {
}
```

This is one of the major advantages of interfaces.

---

# 5. Detailed Comparison

| Feature | Abstract Class | Interface |
|---|---|---|
| Main purpose | Common base abstraction | Contract/capability |
| Relationship | Usually strong "is-a" relationship | Defines "can-do" behavior |
| Instantiation | Cannot instantiate directly | Cannot instantiate directly |
| Constructors | Yes | No constructors |
| Instance variables | Yes | No normal instance variables |
| State | Can maintain object state | Fields are constants |
| Abstract methods | Yes | Yes |
| Concrete methods | Yes | Yes, through `default`, `static`, and `private` methods |
| Static methods | Yes | Yes |
| Final methods | Yes | Interface methods cannot be instance `final` |
| Access modifiers | `private`, `protected`, package-private, `public` | Interface abstract methods are public; default/static/private methods have specific rules |
| Multiple inheritance | A class can extend only one class | A class can implement multiple interfaces |
| Inheritance | `extends` | `implements` |
| Interface inheritance | Can extend one class | Can extend multiple interfaces |
| Constructor initialization | Supported | Not supported |
| Instance state | Supported | Not supported |
| Shared implementation | Strong support | Possible using `default`/`private` methods |
| Coupling | Usually tighter | Usually looser |
| Best for | Shared state and behavior | Contract and loose coupling |
| Typical usage | Template Method pattern, shared base behavior | Strategy, capability, dependency inversion |

---

# 6. Can an Abstract Class Have No Abstract Methods?

Yes.

This is an important interview point.

```java
abstract class ReportGenerator {

    public void generate() {
        System.out.println("Generating report");
    }
}
```

There is no abstract method, but the class is still abstract.

Why would we do this?

Sometimes we want to prevent direct instantiation while providing common functionality to subclasses.

For example:

```java
abstract class BaseService {

    protected void log(String message) {
        System.out.println(message);
    }
}
```

The class may intentionally be designed only as a base class.

---

# 7. Can an Interface Have Implementation?

Yes.

This changed significantly with Java 8 and later.

### Default method

```java
interface Payment {

    void process();

    default void validate() {
        System.out.println("Common validation");
    }
}
```

Implementation:

```java
class UPIPayment implements Payment {

    @Override
    public void process() {
        System.out.println("Processing UPI");
    }
}
```

`UPIPayment` automatically gets the default implementation of `validate()`.

---

# 8. Interface Static Method

An interface can also contain static methods.

```java
interface PaymentUtil {

    static boolean isValidAmount(double amount) {
        return amount > 0;
    }
}
```

Call it using the interface:

```java
boolean valid = PaymentUtil.isValidAmount(1000);
```

You don't call it through the implementation:

```java
// Not the intended usage
UPIPayment.isValidAmount(1000);
```

Interface static methods belong to the **interface itself**.

---

# 9. Private Methods in Interface

Since Java 9, interfaces can also contain private methods.

They are useful for sharing implementation between default/static methods.

```java
interface Payment {

    default void validate() {
        logValidation();
    }

    default void validateAndProcess() {
        logValidation();
        System.out.println("Processing");
    }

    private void logValidation() {
        System.out.println("Validation started");
    }
}
```

The private method is not exposed to implementing classes.

---

# 10. Interface Variables

Variables declared inside an interface are implicitly:

```java
public static final
```

Example:

```java
interface Constants {

    int MAX_RETRY = 3;
}
```

This is equivalent to:

```java
public static final int MAX_RETRY = 3;
```

Therefore:

```java
Constants.MAX_RETRY = 5;
```

is not allowed.

### Important senior-level point

I generally avoid using interfaces as a container for large collections of unrelated constants.

Instead, constants can often be better represented using:

- `enum`
- dedicated constant class
- configuration
- domain-specific value objects

depending on the use case.

---

# 11. Multiple Interface Implementation

A class can implement multiple interfaces.

```java
interface Payable {
    void pay();
}

interface Refundable {
    void refund();
}

interface Auditable {
    void audit();
}
```

A class can implement all three:

```java
class PaymentService implements Payable, Refundable, Auditable {

    @Override
    public void pay() {
        System.out.println("Pay");
    }

    @Override
    public void refund() {
        System.out.println("Refund");
    }

    @Override
    public void audit() {
        System.out.println("Audit");
    }
}
```

This is one reason interfaces are very useful for designing systems around **capabilities**.

---

# 12. Multiple Inheritance Problem with Interfaces

Java doesn't allow:

```java
class C extends A, B {
}
```

because multiple class inheritance can create ambiguity around state and implementation.

However, Java allows multiple interfaces.

But default methods can create conflicts.

Example:

```java
interface A {

    default void show() {
        System.out.println("A");
    }
}

interface B {

    default void show() {
        System.out.println("B");
    }
}
```

Now:

```java
class C implements A, B {
}
```

This causes a compilation error because Java doesn't know which `show()` implementation to use.

The class must resolve the conflict:

```java
class C implements A, B {

    @Override
    public void show() {
        A.super.show();
    }
}
```

Or:

```java
class C implements A, B {

    @Override
    public void show() {
        System.out.println("Custom implementation");
    }
}
```

---

# 13. Interface Can Extend Multiple Interfaces

An interface can extend multiple interfaces.

```java
interface Readable {
    void read();
}

interface Writable {
    void write();
}

interface ReadWrite extends Readable, Writable {
}
```

Then:

```java
class FileHandler implements ReadWrite {

    @Override
    public void read() {
        System.out.println("Reading");
    }

    @Override
    public void write() {
        System.out.println("Writing");
    }
}
```

This is another important difference from class inheritance.

---

# 14. Real-World Example: Payment System

Suppose we have:

```text
Payment
   |
   +-- CreditCardPayment
   +-- UPIPayment
   +-- NetBankingPayment
```

An abstract class could provide:

```java
abstract class Payment {

    protected String transactionId;

    public Payment(String transactionId) {
        this.transactionId = transactionId;
    }

    public void validate() {
        System.out.println("Common validation");
    }

    public abstract void process();
}
```

Now suppose only some payments support refunds.

Instead of putting `refund()` in `Payment`, we can define:

```java
interface Refundable {

    void refund();
}
```

Then:

```java
class CreditCardPayment extends Payment implements Refundable {

    public CreditCardPayment(String transactionId) {
        super(transactionId);
    }

    @Override
    public void process() {
        System.out.println("Credit card processing");
    }

    @Override
    public void refund() {
        System.out.println("Credit card refund");
    }
}
```

Another payment may not support refunds:

```java
class CashPayment extends Payment {

    public CashPayment(String transactionId) {
        super(transactionId);
    }

    @Override
    public void process() {
        System.out.println("Cash payment");
    }
}
```

This design is better than putting every possible behavior into the abstract class.

---

# 15. Why Interfaces Are Important in Enterprise Applications

In large applications, interfaces are commonly used to reduce coupling.

For example:

```java
interface PaymentGateway {

    PaymentResponse pay(PaymentRequest request);
}
```

Implementation:

```java
class RazorpayGateway implements PaymentGateway {

    @Override
    public PaymentResponse pay(PaymentRequest request) {
        // Razorpay implementation
        return null;
    }
}
```

Another implementation:

```java
class StripeGateway implements PaymentGateway {

    @Override
    public PaymentResponse pay(PaymentRequest request) {
        // Stripe implementation
        return null;
    }
}
```

The business service depends on the abstraction:

```java
class OrderService {

    private final PaymentGateway paymentGateway;

    public OrderService(PaymentGateway paymentGateway) {
        this.paymentGateway = paymentGateway;
    }

    public void placeOrder(PaymentRequest request) {
        paymentGateway.pay(request);
    }
}
```

Now `OrderService` doesn't need to know whether the implementation is:

```text
Stripe
Razorpay
Mock
Sandbox
Future provider
```

This supports **Dependency Inversion** and makes testing easier.

---

# 16. Abstract Class vs Interface from a Design Perspective

This is the part I would emphasize in an 8+ years interview.

Don't choose an abstract class just because you have common methods.

Ask:

### Question 1: Do the classes have a genuine common identity?

If yes, an abstract class may be appropriate.

```text
Employee
   |
   +-- Developer
   +-- Manager
```

### Question 2: Do they only share a capability?

If yes, interface is usually better.

```text
Serializable
Comparable
Runnable
Auditable
Retryable
Cacheable
```

### Question 3: Do I need shared instance state?

If yes, abstract class becomes more attractive.

```java
abstract class Employee {

    protected String employeeId;
    protected String name;
}
```

### Question 4: Do I need multiple independent capabilities?

Interfaces are better.

```java
class Order
        implements Auditable, Trackable, Refundable {
}
```

### Question 5: Do consumers need loose coupling?

An interface is generally preferable.

---

# 17. Abstract Class + Interface Together

In real applications, these are not mutually exclusive.

They can work together.

Example:

```java
abstract class BasePayment {

    protected double amount;

    public BasePayment(double amount) {
        this.amount = amount;
    }

    public void validate() {
        if (amount <= 0) {
            throw new IllegalArgumentException("Invalid amount");
        }
    }

    public abstract void process();
}
```

Interface:

```java
interface Refundable {

    void refund();
}
```

Implementation:

```java
class CardPayment extends BasePayment implements Refundable {

    public CardPayment(double amount) {
        super(amount);
    }

    @Override
    public void process() {
        System.out.println("Processing card payment");
    }

    @Override
    public void refund() {
        System.out.println("Refunding card payment");
    }
}
```

This gives us:

```text
                 BasePayment
                     |
               CardPayment
                     |
             implements
                     ↓
                Refundable
```

The abstract class handles **shared implementation/state**, while the interface handles a **capability/contract**.

This combination is very common in good object-oriented design.

---

# 18. Common Interview Trap: "Interface Is 100% Abstract"

This statement is outdated.

In older Java versions, interfaces were commonly described as containing only abstract methods.

Modern Java interfaces can contain:

```text
abstract methods
default methods
static methods
private methods
constants
```

Therefore, saying:

> "An interface can contain only abstract methods"

is incorrect for modern Java.

A better answer:

> "An interface primarily defines a contract, but modern Java interfaces can also contain default, static, and private methods to support reusable behavior."

---

# 19. Common Interview Trap: "Use Interface Whenever Possible"

This is also too simplistic.

Interfaces are powerful, but creating an interface for every single class doesn't automatically produce good architecture.

For example:

```java
class UserServiceImpl implements UserService
```

where there is only one implementation and no meaningful abstraction may add unnecessary indirection.

The decision should be based on:

- abstraction boundary
- expected implementations
- dependency inversion
- testing requirements
- domain model
- API design
- maintainability

As a senior developer, I would avoid **interface-for-every-class** blindly.

---

# 20. Common Interview Trap: Abstract Class Cannot Have Static Methods

It can.

```java
abstract class Utility {

    static void print() {
        System.out.println("Hello");
    }
}
```

You can call:

```java
Utility.print();
```

An abstract class can also have:

```java
static
final
private
protected
public
```

methods, subject to normal Java rules.

---

# 21. Abstract Class Constructor

An abstract class can have a constructor.

```java
abstract class Employee {

    protected String name;

    public Employee(String name) {
        this.name = name;
    }
}
```

Even though we cannot do:

```java
new Employee("John");
```

the constructor executes when a concrete subclass is created.

```java
class Developer extends Employee {

    public Developer(String name) {
        super(name);
    }
}
```

Execution:

```text
new Developer("John")
       ↓
Employee constructor
       ↓
Developer constructor
```

This is useful when the base class needs to initialize common state.

---

# 22. When Would I Choose Abstract Class?

I would consider an abstract class when:

1. Classes have a strong common identity.
2. They share instance state.
3. They share constructor logic.
4. They have substantial common implementation.
5. I want to enforce a common inheritance hierarchy.
6. I want protected helper methods/state for subclasses.
7. Template Method pattern is appropriate.

Example:

```java
abstract class DataImporter {

    public final void importData() {
        readData();
        validateData();
        saveData();
    }

    protected abstract void readData();

    protected abstract void validateData();

    protected abstract void saveData();
}
```

This is a classic **Template Method** design.

The algorithm is fixed, while subclasses provide specific steps.

---

# 23. When Would I Choose Interface?

I would prefer an interface when:

1. I need a contract.
2. Multiple unrelated classes can implement the behavior.
3. Multiple capabilities are required.
4. I want loose coupling.
5. I want dependency inversion.
6. I expect multiple implementations.
7. I want consumers to depend on behavior rather than implementation.

Example:

```java
interface NotificationSender {

    void send(String message);
}
```

Implementations:

```java
class EmailNotificationSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("Sending email");
    }
}
```

```java
class SmsNotificationSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("Sending SMS");
    }
}
```

The caller only depends on:

```java
NotificationSender
```

not the concrete implementation.

---

# 24. Java Collections: Real Examples

Java itself uses both approaches.

### Abstract classes

Examples include:

```text
AbstractList
AbstractSet
AbstractMap
AbstractQueue
```

These provide reusable skeletal implementations.

For example, `AbstractList` helps developers create custom `List` implementations without implementing every behavior from scratch.

### Interfaces

Common interfaces include:

```text
List
Set
Map
Queue
Deque
Comparable
Comparator
Runnable
Callable
Serializable
AutoCloseable
```

This demonstrates an important design principle:

```text
Interface
    ↓
Define contract

Abstract class
    ↓
Provide reusable implementation
```

These two concepts often complement each other.

---

# 25. A Strong 8+ Years Interview Answer

If the interviewer asks:

**"What is the difference between abstract class and interface?"**

I would answer:

> "I look at the design intent first. An abstract class is useful when I have a strong common base type where subclasses share state, constructors, and substantial implementation. An interface is more suitable when I want to define a contract or capability and keep implementations loosely coupled.
>
> A class can extend only one abstract or concrete class, but it can implement multiple interfaces, which makes interfaces useful for composing independent capabilities.
>
> Modern Java interfaces can also contain default, static, and private methods, so the distinction is no longer simply 'abstract class has implementation and interface doesn't.'
>
> In enterprise applications, I commonly use interfaces at component boundaries—for example, a `PaymentGateway` interface with multiple provider implementations—and use abstract classes when there is meaningful shared state or a common algorithm, such as a template-method based processing workflow.
>
> I also avoid introducing interfaces mechanically for every class. The choice should be driven by the abstraction, coupling, extensibility, and domain design."

---

# 26. Quick Decision Rule

Use this mental model during an interview:

```text
Need shared STATE?
        |
       YES
        ↓
Consider ABSTRACT CLASS


Need shared CONTRACT / CAPABILITY?
        |
       YES
        ↓
Consider INTERFACE


Need MULTIPLE capabilities?
        |
       YES
        ↓
INTERFACE


Need common constructor/state/implementation?
        |
       YES
        ↓
ABSTRACT CLASS


Need loose coupling between components?
        |
       YES
        ↓
INTERFACE
```

### One-line memory trick

```text
Abstract Class → common identity + state + implementation

Interface → contract + capability + loose coupling
```

### Senior-level takeaway

The strongest answer is **not**:

> "Abstract class supports implementation, interface doesn't."

The stronger answer is:

> **"I choose an abstract class when I need a shared base with state and implementation; I choose an interface when I need a contract or capability that can be implemented by multiple, potentially unrelated classes. In production design, I also consider coupling, extensibility, composition, dependency inversion, and whether the abstraction is actually valuable."**