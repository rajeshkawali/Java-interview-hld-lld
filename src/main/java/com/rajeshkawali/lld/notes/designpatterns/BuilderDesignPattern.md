# Builder Design Pattern

## 1. Definition

The **Builder Design Pattern** is a **creational design pattern** used to create complex objects **step by step**.

It is especially useful when an object has:

- Many fields
- Many optional parameters
- Different combinations of parameters
- A need for readable and maintainable object creation

### In simple words

> **Builder Pattern = Create a complex object step by step instead of passing many parameters to a constructor.**

---

# 2. Problem Without Builder Pattern

Suppose we have a `User` class:

```java
class User {

    private String name;
    private String email;
    private int age;
    private String phone;
    private String address;

    public User(String name, String email, int age,
                String phone, String address) {
        this.name = name;
        this.email = email;
        this.age = age;
        this.phone = phone;
        this.address = address;
    }
}
```

Creating an object looks like:

```java
User user = new User(
    "John",
    "john@gmail.com",
    25,
    "9999999999",
    "Mumbai"
);
```

This becomes difficult to understand when there are many parameters.

For example:

```java
new User(
    "John",
    "john@gmail.com",
    25,
    "9999999999",
    "Mumbai",
    "India",
    true,
    false,
    "ADMIN",
    ...
);
```

### Problems

1. Difficult to remember the order of parameters.
2. Difficult to understand what each value represents.
3. Constructor becomes very large.
4. Many parameters may be optional.
5. We may end up creating multiple constructors.

---

# 3. Multiple Constructors Problem

One solution is **constructor overloading**:

```java
User(String name)

User(String name, String email)

User(String name, String email, int age)

User(String name, String email, int age, String phone)

User(String name, String email, int age, String phone, String address)
```

But as the number of fields increases, the number of constructors can become difficult to maintain.

This is where the **Builder Pattern** helps.

---

# 4. Builder Pattern Solution

Instead of:

```java
User user = new User(
    "John",
    "john@gmail.com",
    25,
    "9999999999",
    "Mumbai"
);
```

we can write:

```java
User user = new User.Builder()
        .setName("John")
        .setEmail("john@gmail.com")
        .setAge(25)
        .setPhone("9999999999")
        .setAddress("Mumbai")
        .build();
```

This is much easier to read.

---

# 5. Basic Builder Implementation

```java
class User {

    private String name;
    private String email;
    private int age;
    private String phone;
    private String address;

    private User(Builder builder) {
        this.name = builder.name;
        this.email = builder.email;
        this.age = builder.age;
        this.phone = builder.phone;
        this.address = builder.address;
    }

    public static class Builder {

        private String name;
        private String email;
        private int age;
        private String phone;
        private String address;

        public Builder setName(String name) {
            this.name = name;
            return this;
        }

        public Builder setEmail(String email) {
            this.email = email;
            return this;
        }

        public Builder setAge(int age) {
            this.age = age;
            return this;
        }

        public Builder setPhone(String phone) {
            this.phone = phone;
            return this;
        }

        public Builder setAddress(String address) {
            this.address = address;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }
}
```

Usage:

```java
User user = new User.Builder()
        .setName("John")
        .setEmail("john@gmail.com")
        .setAge(25)
        .setPhone("9999999999")
        .setAddress("Mumbai")
        .build();
```

---

# 6. How Builder Works

The flow is:

```text
Client
  |
  | setName()
  | setEmail()
  | setAge()
  | setPhone()
  |
  v
Builder
  |
  | build()
  v
User Object
```

The important idea is:

```java
Builder
   ↓
collects all values
   ↓
build()
   ↓
creates final object
```

The `Builder` is responsible for **collecting the object's configuration**, while the `User` constructor creates the actual object.

---

# 7. Why `return this`?

Consider:

```java
public Builder setName(String name) {
    this.name = name;
    return this;
}
```

`return this` allows us to use **method chaining**:

```java
new User.Builder()
    .setName("John")
    .setEmail("john@gmail.com")
    .setAge(25)
    .build();
```

Without `return this`, we would have to write:

```java
User.Builder builder = new User.Builder();

builder.setName("John");
builder.setEmail("john@gmail.com");
builder.setAge(25);

User user = builder.build();
```

Both are valid, but method chaining is more readable.

---

# 8. Builder Pattern with Required and Optional Fields

This is one of the most useful applications of Builder Pattern.

Suppose:

```text
User
 ├── name      → required
 ├── email     → required
 ├── age       → optional
 ├── phone     → optional
 └── address   → optional
```

We can validate required fields inside `build()`:

```java
public User build() {

    if (name == null || name.isEmpty()) {
        throw new IllegalArgumentException("Name is required");
    }

    if (email == null || email.isEmpty()) {
        throw new IllegalArgumentException("Email is required");
    }

    return new User(this);
}
```

Now:

```java
User user = new User.Builder()
        .setName("John")
        .setEmail("john@gmail.com")
        .setAge(25)
        .build();
```

is valid.

But:

```java
User user = new User.Builder()
        .setAge(25)
        .build();
```

throws an exception because required fields are missing.

---

# 9. Real-World Example — HTTP Request

Builder Pattern is commonly useful for objects such as HTTP requests.

Imagine:

```text
HttpRequest
 ├── URL
 ├── HTTP Method
 ├── Headers
 ├── Body
 ├── Timeout
 └── Authentication
```

Instead of:

```java
HttpRequest request = new HttpRequest(
    url,
    method,
    headers,
    body,
    timeout,
    authentication
);
```

we can use:

```java
HttpRequest request = new HttpRequest.Builder()
        .url("https://example.com")
        .method("POST")
        .header("Content-Type", "application/json")
        .body("{\"name\":\"John\"}")
        .timeout(5000)
        .build();
```

This makes the configuration much easier to understand.

---

# 10. LLD Example — Pizza

A good LLD interview example is a **Pizza Builder**.

Suppose a pizza can have:

```text
Pizza
 ├── size
 ├── cheese
 ├── mushrooms
 ├── onions
 ├── tomatoes
 └── extra cheese
```

Instead of creating many constructors:

```java
Pizza("Large")

Pizza("Large", true)

Pizza("Large", true, true)

Pizza("Large", true, true, true)

...
```

we use a Builder.

```java
class Pizza {

    private final String size;
    private final boolean cheese;
    private final boolean mushrooms;
    private final boolean onions;
    private final boolean tomatoes;

    private Pizza(Builder builder) {
        this.size = builder.size;
        this.cheese = builder.cheese;
        this.mushrooms = builder.mushrooms;
        this.onions = builder.onions;
        this.tomatoes = builder.tomatoes;
    }

    public static class Builder {

        private final String size;

        private boolean cheese;
        private boolean mushrooms;
        private boolean onions;
        private boolean tomatoes;

        public Builder(String size) {
            this.size = size;
        }

        public Builder addCheese() {
            this.cheese = true;
            return this;
        }

        public Builder addMushrooms() {
            this.mushrooms = true;
            return this;
        }

        public Builder addOnions() {
            this.onions = true;
            return this;
        }

        public Builder addTomatoes() {
            this.tomatoes = true;
            return this;
        }

        public Pizza build() {
            return new Pizza(this);
        }
    }
}
```

Usage:

```java
Pizza pizza = new Pizza.Builder("Large")
        .addCheese()
        .addMushrooms()
        .addOnions()
        .build();
```

The resulting object is:

```text
Pizza
 ├── Size: Large
 ├── Cheese: Yes
 ├── Mushrooms: Yes
 ├── Onions: Yes
 └── Tomatoes: No
```

---

# 11. Builder Pattern and Immutability

Builder Pattern is often used together with **immutable objects**.

For example:

```java
class User {

    private final String name;
    private final String email;
    private final int age;

    private User(Builder builder) {
        this.name = builder.name;
        this.email = builder.email;
        this.age = builder.age;
    }
}
```

Notice that the fields are:

```java
final
```

and there are no setters.

Once the `User` object is created, its values cannot be changed.

The Builder is mutable during construction:

```text
Builder
  ↓
modify configuration
  ↓
build()
  ↓
Immutable User
```

This is a very common and useful combination.

---

# 12. Advantages

### 1. Readability

Compare:

```java
new User("John", "john@gmail.com", 25, "9999999999", "Mumbai");
```

with:

```java
new User.Builder()
    .setName("John")
    .setEmail("john@gmail.com")
    .setAge(25)
    .setPhone("9999999999")
    .setAddress("Mumbai")
    .build();
```

The second version is much easier to understand.

### 2. Handles optional parameters

We don't need to provide every field.

```java
User user = new User.Builder()
        .setName("John")
        .setEmail("john@gmail.com")
        .build();
```

### 3. Avoids constructor explosion

We don't need many overloaded constructors.

### 4. Supports validation

Validation can be performed inside `build()`.

### 5. Can create immutable objects

The final object can have `final` fields and no setters.

---

# 13. Disadvantages

### 1. More code

We need to create a separate Builder class.

For a very simple object with only 2–3 fields, Builder Pattern may be unnecessary.

### 2. More classes/objects

A Builder object is created before the actual object.

### 3. Slightly more complex

For simple objects, a normal constructor can be easier.

---

# 14. Builder vs Factory

These two patterns are often confused.

### Factory Pattern

Factory focuses on:

> **Which object should I create?**

Example:

```java
Shape shape = ShapeFactory.createShape("CIRCLE");
```

The factory decides which implementation to create.

### Builder Pattern

Builder focuses on:

> **How should I construct this object?**

Example:

```java
User user = new User.Builder()
        .setName("John")
        .setAge(25)
        .setEmail("john@gmail.com")
        .build();
```

### Easy way to remember

```text
Factory → Which object?

Builder → How to build the object?
```

---

# 15. Builder vs Prototype

### Builder

Creates an object **step by step**.

```text
Builder
   ↓
Step 1
   ↓
Step 2
   ↓
Step 3
   ↓
Object
```

### Prototype

Creates a new object by **copying an existing object**.

```text
Existing Object
      ↓
     copy
      ↓
New Object
```

---

# 16. Builder Pattern Structure

The typical structure is:

```text
             Client
                |
                v
             Builder
          /     |      \
      field1  field2  field3
                |
                v
              build()
                |
                v
          Final Object
```

For example:

```text
             Client
                |
                v
          User.Builder
          /     |     \
       name   email   age
                |
                v
             build()
                |
                v
              User
```

---

# 17. When Should You Use Builder Pattern?

Use Builder when:

- An object has **many fields**.
- Many fields are **optional**.
- There are many possible combinations of fields.
- Constructor parameters are becoming difficult to understand.
- You want **readable object creation**.
- You want to create **immutable objects**.
- You need validation before creating the final object.

Don't use it just because it is a design pattern.

For a simple class:

```java
class Student {
    String name;
    int age;
}
```

this may be enough:

```java
Student student = new Student("John", 25);
```

A Builder would add unnecessary complexity.

---

# 18. Interview Answer

If the interviewer asks:

### "What is Builder Design Pattern?"

You can answer:

> **Builder is a creational design pattern used to construct complex objects step by step. It is especially useful when an object has many optional parameters or different configurations. Instead of using a large constructor or many overloaded constructors, we use a Builder to configure the object and finally call `build()` to create the object. It also helps improve readability and can be used to create immutable objects.**

### One-line version

> **Builder Pattern separates the construction of a complex object from its final representation and allows the object to be created step by step.**

---

# 19. LLD Interview Thought Process

When you see a requirement like:

```text
Design a User
```

and the User has:

```text
name
email
age
phone
address
role
permissions
preferences
...
```

Think:

```text
Many fields?
      ↓
Many optional fields?
      ↓
Different combinations?
      ↓
Constructor becoming large?
      ↓
YES
      ↓
Use Builder Pattern
```

Then design:

```text
              User
               ↑
               |
            Builder
               |
      ┌────────┼────────┐
      ↓        ↓        ↓
    name     email     age
      ↓        ↓        ↓
      └────────┼────────┘
               ↓
             build()
               ↓
          User Object
```

**Key idea to remember:**

> **Builder is about constructing one complex object in a clean, flexible, step-by-step way.**