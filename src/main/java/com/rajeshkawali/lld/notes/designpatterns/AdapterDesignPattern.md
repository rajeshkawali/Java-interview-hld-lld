# Adapter Design Pattern

## 1. What is the Adapter Design Pattern?

The **Adapter Design Pattern** is a **Structural Design Pattern**.

It allows two incompatible classes/interfaces to work together by converting the interface of one class into the interface expected by another class.

### Simple definition

> **Adapter Pattern = Convert one interface into another interface that the client expects.**

Think about a **mobile charger adapter**.

Your wall socket may have one type of connection, while your charger needs another. The adapter sits between them and makes them compatible.

```text
Client
  ↓
Adapter
  ↓
Existing/Legacy Class
```

The client doesn't need to know how the existing class works internally.

---

# 2. Real-Life Example

Suppose you have:

```text
Indian Plug
     ↓
   Adapter
     ↓
US Socket
```

The Indian plug and US socket are incompatible.

Instead of changing the Indian plug or the US socket, we introduce an **Adapter**.

The adapter converts one interface into another.

That's exactly what happens in software.

---

# 3. Why do we need Adapter?

Imagine your application expects this interface:

```java
interface PaymentProcessor {
    void pay(double amount);
}
```

Your application uses:

```java
PaymentProcessor processor;

processor.pay(1000);
```

Everything is fine.

But now you want to integrate a third-party payment library.

The third-party library has:

```java
class Razorpay {
    public void makePayment(double amount) {
        System.out.println("Payment using Razorpay: " + amount);
    }
}
```

The problem is:

```text
Your Application expects:

PaymentProcessor
      ↓
    pay()

Third-party library provides:

Razorpay
      ↓
 makePayment()
```

The method names/interfaces don't match.

We don't want to modify the third-party library.

So we create an **Adapter**.

---

# 4. Adapter Example in Java

## Step 1: Target Interface

This is the interface our application expects.

```java
interface PaymentProcessor {

    void pay(double amount);
}
```

---

## Step 2: Existing/Third-Party Class

Suppose this class comes from an external library.

```java
class Razorpay {

    public void makePayment(double amount) {
        System.out.println("Payment using Razorpay: " + amount);
    }
}
```

We cannot change this class.

---

## Step 3: Create Adapter

The adapter implements the interface expected by our application.

```java
class RazorpayAdapter implements PaymentProcessor {

    private Razorpay razorpay;

    public RazorpayAdapter(Razorpay razorpay) {
        this.razorpay = razorpay;
    }

    @Override
    public void pay(double amount) {
        razorpay.makePayment(amount);
    }
}
```

Notice what happened:

```text
Application
     ↓
PaymentProcessor
     ↓
RazorpayAdapter
     ↓
Razorpay
```

The adapter translates:

```text
pay()
  ↓
makePayment()
```

---

# 5. Client Code

Now our application doesn't need to know anything about Razorpay's API.

```java
public class Main {

    public static void main(String[] args) {

        Razorpay razorpay = new Razorpay();

        PaymentProcessor processor =
                new RazorpayAdapter(razorpay);

        processor.pay(1000);
    }
}
```

Output:

```text
Payment using Razorpay: 1000.0
```

---

# 6. What exactly is the Adapter doing?

This is the most important part.

Our application says:

```java
processor.pay(1000);
```

But Razorpay understands:

```java
razorpay.makePayment(1000);
```

The Adapter converts the request.

```text
Client
  |
  | pay(1000)
  ↓
RazorpayAdapter
  |
  | makePayment(1000)
  ↓
Razorpay
```

So:

> **Adapter acts as a translator between two incompatible interfaces.**

---

# 7. Another Simple Example — Media Player

Suppose our application supports:

```java
interface MediaPlayer {

    void play(String filename);
}
```

Our application expects:

```java
play("song.mp3");
```

But an old library provides:

```java
class VLCPlayer {

    public void playVLC(String filename) {
        System.out.println("Playing VLC: " + filename);
    }
}
```

Again, interfaces don't match.

Create an adapter:

```java
class VLCAdapter implements MediaPlayer {

    private VLCPlayer vlcPlayer;

    public VLCAdapter(VLCPlayer vlcPlayer) {
        this.vlcPlayer = vlcPlayer;
    }

    @Override
    public void play(String filename) {
        vlcPlayer.playVLC(filename);
    }
}
```

Now:

```java
MediaPlayer player =
        new VLCAdapter(new VLCPlayer());

player.play("movie.vlc");
```

The client only knows:

```java
MediaPlayer
```

It doesn't care that the actual implementation is VLC.

---

# 8. Adapter Pattern Structure

There are usually four important components.

### 1. Target

The interface expected by the client.

```java
interface PaymentProcessor {
    void pay(double amount);
}
```

### 2. Client

The class that wants to use the Target interface.

```java
class PaymentService {

    private PaymentProcessor processor;

    PaymentService(PaymentProcessor processor) {
        this.processor = processor;
    }

    void processPayment(double amount) {
        processor.pay(amount);
    }
}
```

### 3. Adaptee

The existing class with an incompatible interface.

```java
class Razorpay {

    void makePayment(double amount) {
        // ...
    }
}
```

### 4. Adapter

Connects Target and Adaptee.

```java
class RazorpayAdapter implements PaymentProcessor {

    private Razorpay razorpay;

    RazorpayAdapter(Razorpay razorpay) {
        this.razorpay = razorpay;
    }

    public void pay(double amount) {
        razorpay.makePayment(amount);
    }
}
```

Overall:

```text
                 ┌──────────────────┐
                 │      Client      │
                 └────────┬─────────┘
                          │
                          ↓
                 ┌──────────────────┐
                 │     Target       │
                 │ PaymentProcessor │
                 └────────┬─────────┘
                          │
                          ↓
                 ┌──────────────────┐
                 │     Adapter      │
                 │ RazorpayAdapter  │
                 └────────┬─────────┘
                          │
                          ↓
                 ┌──────────────────┐
                 │     Adaptee      │
                 │    Razorpay      │
                 └──────────────────┘
```

---

# 9. LLD Example — Multiple Payment Providers

This is a very common interview-style use case.

Suppose our application has:

```text
PaymentService
      |
      ↓
PaymentProcessor
      |
      ├── Stripe
      ├── Razorpay
      └── PayPal
```

Our application wants a common interface:

```java
interface PaymentProcessor {

    void pay(double amount);
}
```

But external systems have different APIs.

### Stripe

```java
class Stripe {

    public void charge(double amount) {
        System.out.println("Stripe charged: " + amount);
    }
}
```

### Razorpay

```java
class Razorpay {

    public void makePayment(double amount) {
        System.out.println("Razorpay payment: " + amount);
    }
}
```

### PayPal

```java
class PayPal {

    public void sendPayment(double amount) {
        System.out.println("PayPal payment: " + amount);
    }
}
```

Their APIs are different:

```text
Stripe
  → charge()

Razorpay
  → makePayment()

PayPal
  → sendPayment()
```

Our application doesn't want to deal with these differences.

---

## Create adapters

### Stripe Adapter

```java
class StripeAdapter implements PaymentProcessor {

    private Stripe stripe;

    StripeAdapter(Stripe stripe) {
        this.stripe = stripe;
    }

    @Override
    public void pay(double amount) {
        stripe.charge(amount);
    }
}
```

### Razorpay Adapter

```java
class RazorpayAdapter implements PaymentProcessor {

    private Razorpay razorpay;

    RazorpayAdapter(Razorpay razorpay) {
        this.razorpay = razorpay;
    }

    @Override
    public void pay(double amount) {
        razorpay.makePayment(amount);
    }
}
```

### PayPal Adapter

```java
class PayPalAdapter implements PaymentProcessor {

    private PayPal paypal;

    PayPalAdapter(PayPal paypal) {
        this.paypal = paypal;
    }

    @Override
    public void pay(double amount) {
        paypal.sendPayment(amount);
    }
}
```

Now the client always uses:

```java
PaymentProcessor
```

It doesn't care about the underlying API.

```java
PaymentProcessor processor =
        new RazorpayAdapter(new Razorpay());

processor.pay(5000);
```

We could easily switch:

```java
PaymentProcessor processor =
        new StripeAdapter(new Stripe());
```

or:

```java
PaymentProcessor processor =
        new PayPalAdapter(new PayPal());
```

The client code remains consistent.

---

# 10. Why not simply modify the existing classes?

You might ask:

> Why don't we just change `Razorpay` and rename `makePayment()` to `pay()`?

Because in real applications, the class might be:

- Third-party library
- Legacy code
- Closed-source library
- Shared by many applications
- Already tested and deployed
- Dangerous to modify

So instead of changing the existing class:

```text
❌ Modify existing class
```

we create:

```text
✅ Adapter
```

This follows the **Open/Closed Principle** nicely:

> Existing code remains unchanged while we extend compatibility around it.

---

# 11. Adapter uses Composition

A very important interview point:

**Adapter commonly uses composition.**

For example:

```java
class RazorpayAdapter implements PaymentProcessor {

    private Razorpay razorpay;
}
```

The adapter **contains** a Razorpay object.

```text
RazorpayAdapter
      |
      | contains
      ↓
  Razorpay
```

Then it delegates the call:

```java
public void pay(double amount) {
    razorpay.makePayment(amount);
}
```

So remember:

> **Adapter = Composition + Interface Conversion**

---

# 12. Object Adapter vs Class Adapter

There are two common forms of Adapter.

## Object Adapter

Uses **composition**.

```java
class Adapter implements Target {

    private Adaptee adaptee;

    public void request() {
        adaptee.specificRequest();
    }
}
```

This is the commonly used approach in Java.

```text
Adapter
   |
   ↓
Adaptee
```

---

## Class Adapter

Uses **inheritance**.

Conceptually:

```java
class Adapter extends Adaptee implements Target {
    
    // conversion logic
}
```

Java allows extending one class and implementing an interface, so this is possible.

But **composition is generally more flexible**.

---

# 13. Adapter vs Decorator

These two patterns can look very similar because both can wrap objects.

### Adapter

Changes/ translates the interface.

```text
Old Interface
      ↓
   Adapter
      ↓
Expected Interface
```

Purpose:

> **Make incompatible things work together.**

### Decorator

Keeps the same interface and adds behavior.

```text
Coffee
  ↓
MilkDecorator
  ↓
SugarDecorator
```

Purpose:

> **Add functionality/behavior.**

### Easy difference

| Adapter | Decorator |
|---|---|
| Converts interface | Adds behavior |
| Solves incompatibility | Solves feature extension |
| Makes things work together | Makes an object more capable |
| Interface changes from client's perspective | Same interface remains |

### Memory trick

> **Adapter = Translate**  
> **Decorator = Enhance**

---

# 14. Adapter vs Facade

These are also commonly confused.

### Adapter

Makes **incompatible interfaces compatible**.

```text
Client → Adapter → Existing Class
```

### Facade

Makes a **complex system easier to use**.

```text
Client
  ↓
Facade
  ↓
 ┌────────┬────────┬────────┐
Service A Service B Service C
```

### Memory trick

> **Adapter = Compatibility**  
> **Facade = Simplicity**

---

# 15. Adapter vs Proxy

Both can wrap another object, but their purpose is different.

### Adapter

Changes the interface.

```text
Client
 ↓
Adapter
 ↓
Adaptee
```

### Proxy

Usually keeps the same interface but controls access.

```text
Client
 ↓
Proxy
 ↓
Real Object
```

For example:

```text
Adapter → "Let me translate this request."

Proxy   → "Let me decide whether/how the request reaches the real object."
```

---

# 16. Advantages

### 1. Reuse existing code

You can use an existing class without modifying it.

### 2. Supports third-party integration

Very useful when integrating external libraries/APIs.

### 3. Reduces coupling

Client depends on the expected interface rather than the external implementation.

### 4. Follows Open/Closed Principle

You can add compatibility without modifying existing classes.

### 5. Easy migration

Useful when gradually replacing legacy systems.

---

# 17. Disadvantages

### 1. More classes

Each incompatible implementation may require an adapter.

```text
StripeAdapter
RazorpayAdapter
PayPalAdapter
```

### 2. Additional layer

There is another level of indirection.

```text
Client → Adapter → Actual Object
```

### 3. Can become complex

If too many adapters and conversions are introduced, understanding the system can become harder.

---

# 18. When should you use Adapter?

Use Adapter when:

- Two interfaces are incompatible.
- You need to integrate a third-party library.
- You need to work with legacy code.
- You cannot modify the existing class.
- You want your application to depend on a common interface.
- You are migrating from an old API to a new API.

Common examples:

```text
Payment Gateway Integration
Third-party APIs
Legacy Systems
Database Drivers
Logging Libraries
Media Players
Cloud Storage Providers
External Notification Services
```

---

# 19. Adapter in a Real LLD

Suppose you're designing an e-commerce application.

Your application expects:

```java
interface NotificationService {

    void send(String userId, String message);
}
```

But external providers have different APIs:

```text
Twilio
  → sendSMS()

SendGrid
  → sendEmail()

Firebase
  → sendPush()
```

Instead of making your entire application understand all these APIs:

```text
OrderService
PaymentService
DeliveryService
   ↓
Twilio
SendGrid
Firebase
```

we introduce adapters:

```text
                    NotificationService
                           ↑
             ┌─────────────┼─────────────┐
             │             │             │
             ↓             ↓             ↓
       TwilioAdapter  SendGridAdapter FirebaseAdapter
             │             │             │
             ↓             ↓             ↓
          Twilio        SendGrid       Firebase
```

Now the rest of the application only knows:

```java
NotificationService
```

This is much cleaner.

---

# 20. Interview Question

### Q: What is Adapter Design Pattern?

A good interview answer:

> **Adapter is a structural design pattern that allows incompatible interfaces to work together. It acts as a bridge between the client and an existing class by converting the existing class's interface into the interface expected by the client. It is commonly used for integrating third-party or legacy systems without modifying their code.**

---

# 21. Most Important Interview Points

If the interviewer asks about Adapter, remember these:

### 1. Category

```text
Structural Design Pattern
```

### 2. Main purpose

```text
Convert incompatible interfaces
```

### 3. Main components

```text
Client
Target
Adapter
Adaptee
```

### 4. Common implementation

```text
Composition
```

### 5. Real-world use

```text
Third-party API integration
Legacy system integration
```

### 6. Main benefit

```text
Existing code doesn't need to be modified.
```

---

# 22. One-Line Comparison of Patterns

For interviews, this is extremely useful:

```text
Adapter    → Make incompatible interfaces compatible

Decorator  → Add behavior to an existing object

Facade     → Hide complexity behind a simple interface

Proxy      → Control access to an object

Strategy   → Choose between different algorithms

Factory    → Decide which object to create

State      → Change behavior based on current state
```

---

# 23. Easy Memory Trick

Think about these words:

```text
Adapter   → Translate
Decorator → Add
Facade    → Simplify
Proxy     → Control
Strategy  → Choose
Factory   → Create
State     → Change
```

### The core idea of Adapter:

> **"I cannot change the existing object, so I'll create an adapter that makes it look like what my application expects."**

That is the entire Adapter Pattern in one sentence.