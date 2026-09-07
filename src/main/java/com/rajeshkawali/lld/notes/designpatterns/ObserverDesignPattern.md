# Observer Design Pattern

## 1. Definition

The **Observer Design Pattern** is a **behavioral design pattern** in which one object, called the **Subject**, maintains a list of dependent objects, called **Observers**, and automatically notifies them whenever its state changes.

### In simple words

> **Observer Pattern = When one object's state changes, automatically notify all interested objects.**

It creates a **one-to-many relationship**:

```text
One Subject
    |
    | notifies
    |
    ├── Observer 1
    ├── Observer 2
    ├── Observer 3
    └── Observer 4
```

---

# 2. Real-Life Example

Think about a **YouTube channel**.

Suppose you subscribe to a channel.

```text
YouTube Channel
       |
       | new video uploaded
       ↓
   Notification
       |
   ┌───┼────┐
   ↓   ↓    ↓
User1 User2 User3
```

The YouTube channel doesn't need to individually check:

> "Should I notify User1?"

> "Should I notify User2?"

Instead, all subscribers are registered as **Observers**.

Whenever a new video is uploaded:

```text
Channel → notify all subscribers
```

This is the Observer Pattern.

---

# 3. Main Components

There are usually four important components:

### 1. Subject

The object whose state changes.

It maintains a list of observers.

### 2. Observer

The interface that defines how observers receive updates.

### 3. Concrete Subject

The actual implementation of the Subject.

### 4. Concrete Observer

The actual objects that want to receive notifications.

---

# 4. Basic Structure

```text
                    Subject
                       |
              maintains observers
                       |
          ┌────────────┼────────────┐
          ↓            ↓            ↓
      Observer 1   Observer 2   Observer 3
```

When something changes:

```text
Subject
   |
   | notify()
   |
   ├────→ Observer 1
   ├────→ Observer 2
   └────→ Observer 3
```

---

# 5. Java Example — YouTube Channel

Let's design a simple notification system.

## Step 1: Create Observer Interface

```java
interface Observer {

    void update(String videoTitle);
}
```

Every observer must implement the `update()` method.

---

## Step 2: Create Subject Interface

```java
interface Subject {

    void subscribe(Observer observer);

    void unsubscribe(Observer observer);

    void notifyObservers();
}
```

The Subject provides methods to:

- Add an observer
- Remove an observer
- Notify all observers

---

## Step 3: Create Concrete Subject

```java
import java.util.ArrayList;
import java.util.List;

class YouTubeChannel implements Subject {

    private List<Observer> observers = new ArrayList<>();

    private String latestVideo;

    @Override
    public void subscribe(Observer observer) {
        observers.add(observer);
    }

    @Override
    public void unsubscribe(Observer observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyObservers() {

        for (Observer observer : observers) {
            observer.update(latestVideo);
        }
    }

    public void uploadVideo(String videoTitle) {

        this.latestVideo = videoTitle;

        System.out.println(
            "New video uploaded: " + videoTitle
        );

        notifyObservers();
    }
}
```

---

# 6. Create Concrete Observers

Let's create a subscriber.

```java
class User implements Observer {

    private String name;

    public User(String name) {
        this.name = name;
    }

    @Override
    public void update(String videoTitle) {

        System.out.println(
            name + " received notification: " + videoTitle
        );
    }
}
```

Now we can create multiple users:

```java
User user1 = new User("John");
User user2 = new User("Alice");
User user3 = new User("Bob");
```

---

# 7. Connect Observers to Subject

```java
YouTubeChannel channel = new YouTubeChannel();

channel.subscribe(user1);
channel.subscribe(user2);
channel.subscribe(user3);
```

Now the relationship is:

```text
             YouTubeChannel
                    |
          ┌─────────┼─────────┐
          ↓         ↓         ↓
        John      Alice      Bob
       Observer  Observer   Observer
```

---

# 8. Upload a Video

```java
channel.uploadVideo("Observer Pattern Explained");
```

Output:

```text
New video uploaded: Observer Pattern Explained

John received notification: Observer Pattern Explained
Alice received notification: Observer Pattern Explained
Bob received notification: Observer Pattern Explained
```

The important thing is that the channel doesn't need to know the internal implementation of `User`.

It only knows:

```java
observer.update(videoTitle);
```

---

# 9. Unsubscribe

Suppose Alice doesn't want notifications anymore.

```java
channel.unsubscribe(user2);
```

Now:

```text
             YouTubeChannel
                    |
             ┌──────┴──────┐
             ↓             ↓
           John           Bob
```

If we upload another video:

```java
channel.uploadVideo("Decorator Pattern");
```

Output:

```text
New video uploaded: Decorator Pattern

John received notification: Decorator Pattern
Bob received notification: Decorator Pattern
```

Alice doesn't receive the notification because she unsubscribed.

---

# 10. Complete Example

```java
import java.util.ArrayList;
import java.util.List;

interface Observer {
    void update(String videoTitle);
}

interface Subject {
    void subscribe(Observer observer);

    void unsubscribe(Observer observer);

    void notifyObservers();
}

class YouTubeChannel implements Subject {

    private List<Observer> observers = new ArrayList<>();

    private String latestVideo;

    @Override
    public void subscribe(Observer observer) {
        observers.add(observer);
    }

    @Override
    public void unsubscribe(Observer observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyObservers() {

        for (Observer observer : observers) {
            observer.update(latestVideo);
        }
    }

    public void uploadVideo(String videoTitle) {

        latestVideo = videoTitle;

        System.out.println(
            "New video uploaded: " + videoTitle
        );

        notifyObservers();
    }
}

class User implements Observer {

    private String name;

    public User(String name) {
        this.name = name;
    }

    @Override
    public void update(String videoTitle) {

        System.out.println(
            name + " received notification: "
            + videoTitle
        );
    }
}

public class Main {

    public static void main(String[] args) {

        YouTubeChannel channel =
                new YouTubeChannel();

        User john = new User("John");
        User alice = new User("Alice");
        User bob = new User("Bob");

        channel.subscribe(john);
        channel.subscribe(alice);
        channel.subscribe(bob);

        channel.uploadVideo(
            "Observer Design Pattern"
        );

        System.out.println();

        channel.unsubscribe(alice);

        channel.uploadVideo(
            "Decorator Design Pattern"
        );
    }
}
```

---

# 11. LLD Example — Stock Price Notification

This is a very common LLD-style example.

Suppose we have a stock:

```text
Stock
  |
  | price changes
  ↓
Notify observers
  |
  ├── Mobile App
  ├── Web App
  ├── Email Service
  └── Trading System
```

The Stock is the **Subject**.

The applications/services are **Observers**.

```java
interface StockObserver {

    void update(String stockName, double price);
}
```

Subject:

```java
class Stock {

    private List<StockObserver> observers =
            new ArrayList<>();

    private String stockName;
    private double price;

    public Stock(String stockName) {
        this.stockName = stockName;
    }

    public void addObserver(StockObserver observer) {
        observers.add(observer);
    }

    public void removeObserver(StockObserver observer) {
        observers.remove(observer);
    }

    public void setPrice(double price) {

        this.price = price;

        notifyObservers();
    }

    private void notifyObservers() {

        for (StockObserver observer : observers) {
            observer.update(stockName, price);
        }
    }
}
```

Mobile App:

```java
class MobileApp implements StockObserver {

    @Override
    public void update(
            String stockName,
            double price) {

        System.out.println(
            "Mobile notification: "
            + stockName + " = " + price
        );
    }
}
```

Email Service:

```java
class EmailService implements StockObserver {

    @Override
    public void update(
            String stockName,
            double price) {

        System.out.println(
            "Email sent: "
            + stockName + " = " + price
        );
    }
}
```

Usage:

```java
Stock stock = new Stock("AAPL");

StockObserver mobile = new MobileApp();
StockObserver email = new EmailService();

stock.addObserver(mobile);
stock.addObserver(email);

stock.setPrice(200);
```

Now both observers automatically receive the update.

---

# 12. Why Use Observer Pattern?

Imagine we don't use Observer Pattern.

The Stock class might contain:

```java
mobileApp.update();
emailService.sendEmail();
webApp.update();
tradingSystem.update();
```

Now the Stock class directly depends on every service.

This creates **tight coupling**.

```text
Stock
 ├── MobileApp
 ├── EmailService
 ├── WebApp
 └── TradingSystem
```

If we add another service, we have to modify `Stock`.

With Observer:

```text
                Stock
                  |
             Observer
                  |
      ┌───────────┼───────────┐
      ↓           ↓           ↓
   Mobile       Email        Web
    App         Service       App
```

The Stock only knows about the `Observer` interface.

This creates **loose coupling**.

---

# 13. Push vs Pull Model

There are two common ways to send updates.

## Push Model

The Subject sends the updated data directly.

```java
observer.update(price);
```

The Observer receives the data.

```text
Subject
   |
   | price
   ↓
Observer
```

## Pull Model

The Subject tells the Observer that something changed.

```java
observer.update();
```

Then the Observer asks the Subject for the latest data.

```text
Subject
   |
   | something changed
   ↓
Observer
   |
   | getLatestPrice()
   ↓
Subject
```

Both approaches can be used depending on the design.

---

# 14. Advantages

### 1. Loose coupling

The Subject doesn't need to know the concrete implementation of its observers.

### 2. Easy to add new observers

We can add a new observer without changing the Subject.

```text
Stock
  ↓
NewObserver
```

Just implement the interface.

### 3. Automatic notification

Observers automatically receive updates when the Subject changes.

### 4. Follows Open/Closed Principle

We can add new observer types without modifying existing Subject logic.

---

# 15. Disadvantages

### 1. Too many notifications

If there are hundreds or thousands of observers, one update can trigger many operations.

### 2. Ordering can be difficult

If multiple observers are notified, the order in which they receive updates may matter.

### 3. Memory leak risk

If observers are not properly unsubscribed, the Subject may continue holding references to them.

### 4. Debugging can become harder

A single state change can trigger a chain of notifications.

---

# 16. Observer vs Pub/Sub

These concepts are similar but not exactly the same.

### Observer Pattern

The Subject usually maintains the list of observers directly.

```text
Subject
  |
  ├── Observer
  ├── Observer
  └── Observer
```

### Pub/Sub

A **message broker/event bus** usually sits between publishers and subscribers.

```text
Publisher
    |
    ↓
Message Broker
    |
    ├── Subscriber
    ├── Subscriber
    └── Subscriber
```

Easy way to remember:

> **Observer = Subject directly manages observers.**

> **Pub/Sub = Broker manages communication.**

---

# 17. Observer vs Mediator

These can also be confused.

### Observer

Focuses on:

> **One-to-many notification**

```text
Subject
  ↓
Many Observers
```

### Mediator

Focuses on:

> **Managing communication between multiple objects**

```text
Object A ─┐
Object B ─┼──→ Mediator
Object C ─┘
```

Easy way:

> **Observer = Notify**

> **Mediator = Coordinate**

---

# 18. When Should You Use Observer?

Use Observer Pattern when:

- One object's state changes.
- Multiple objects need to know about that change.
- You don't want the Subject tightly coupled to those objects.
- Observers can be added/removed dynamically.
- You are building notification/event-based systems.

Common examples:

```text
Stock price updates
YouTube subscribers
Weather updates
GUI event listeners
Chat notifications
Order status updates
Inventory changes
News subscriptions
```

---

# 19. Interview Answer

If the interviewer asks:

### "What is Observer Design Pattern?"

You can say:

> **Observer is a behavioral design pattern that establishes a one-to-many relationship between objects. A Subject maintains a list of Observers and automatically notifies them whenever its state changes. It helps achieve loose coupling because the Subject depends on an Observer interface rather than concrete implementations.**

### One-line version

> **Observer Pattern = When the Subject changes, automatically notify all registered Observers.**

---

# 20. Easy Way to Remember

Think:

```text
YouTube Channel = Subject

Subscribers = Observers

New Video = State Change

Notification = Update
```

So:

```text
              YouTube Channel
                  SUBJECT
                     |
              uploadVideo()
                     |
                  notify()
                     |
        ┌────────────┼────────────┐
        ↓            ↓            ↓
      John         Alice         Bob
    OBSERVER      OBSERVER      OBSERVER
```

### Final memory trick

> **Subject → "Something changed!"**

> **Observers → "Thanks, I'll update myself."**

That's the core idea of the **Observer Design Pattern**.



---

### Interview One-Liner

> **“I use Observer Pattern when one object's state change needs to automatically notify multiple dependent objects, while keeping the subject loosely coupled from those observers.”**

### Common Real-World Examples

* 🔔 Notification system — Email/SMS/Push
* 📈 Stock price updates — multiple users receive price changes
* 🛒 E-commerce — order status → customer, warehouse, delivery
* 📱 Event/listener systems
* 💳 Bank account — balance change → notification services
* 🎬 YouTube — new video → notify subscribers

**Memory trick:**
**Observer = “Subscribe → Change → Notify all.”**