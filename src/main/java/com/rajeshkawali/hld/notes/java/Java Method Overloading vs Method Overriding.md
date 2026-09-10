# Method Overloading vs Method Overriding in Java

Both **method overloading** and **method overriding** are forms of polymorphism in Java, but they work in very different ways.

```text
Polymorphism
     |
     +-------------------------+
     |                         |
Compile-time              Runtime
Polymorphism              Polymorphism
     |                         |
Overloading               Overriding
```

---

# 1. What is Method Overloading?

### Definition

**Method overloading means having multiple methods with the same name but different parameter lists in the same class or related classes.**

The compiler decides which method to call based on the arguments.

Therefore, overloading is called:

> **Compile-time polymorphism**  
> or  
> **Static polymorphism**

---

## Simple Example

```java
class Calculator {

    int add(int a, int b) {
        return a + b;
    }

    int add(int a, int b, int c) {
        return a + b + c;
    }

    double add(double a, double b) {
        return a + b;
    }
}
```

Here we have three methods named:

```text
add()
add()
add()
```

But their parameter lists are different.

```text
add(int, int)
add(int, int, int)
add(double, double)
```

Therefore, they are overloaded methods.

---

## Calling overloaded methods

```java
public class Main {

    public static void main(String[] args) {

        Calculator calculator = new Calculator();

        System.out.println(calculator.add(10, 20));

        System.out.println(calculator.add(10, 20, 30));

        System.out.println(calculator.add(10.5, 20.5));
    }
}
```

Output:

```text
30
60
31.0
```

The compiler determines which `add()` method should be called.

---

# 2. How does Overloading work?

Suppose we write:

```java
calculator.add(10, 20);
```

Java sees:

```text
add(int, int)
add(int, int, int)
add(double, double)
```

The best matching method is:

```java
add(int, int)
```

So Java calls:

```java
int add(int a, int b)
```

This decision is made at **compile time**.

---

# 3. What can change during Overloading?

For a method to be overloaded, the **parameter list must be different**.

You can change:

### Number of parameters

```java
void print(int a) {
}

void print(int a, int b) {
}
```

---

### Type of parameters

```java
void print(int a) {
}

void print(String a) {
}
```

---

### Order of parameters

```java
void print(int a, String b) {
}

void print(String a, int b) {
}
```

These are valid overloaded methods.

---

# 4. Can we overload by changing only return type?

### ❌ No.

This is NOT valid:

```java
class Test {

    int calculate() {
        return 10;
    }

    double calculate() {
        return 20.5;
    }
}
```

The compiler gives an error because the parameter list is exactly the same.

```text
calculate()
calculate()
```

Java cannot distinguish methods only by return type.

### Important Interview Point

> **Return type alone cannot be used for method overloading.**

---

# 5. Can we overload static methods?

### Yes.

Static methods can be overloaded.

```java
class Test {

    static void print(int x) {
        System.out.println("int");
    }

    static void print(String x) {
        System.out.println("String");
    }
}
```

This is valid overloading.

---

# 6. Can we overload methods with different access modifiers?

### Yes.

Access modifiers do not prevent overloading.

```java
class Test {

    public void print(int x) {
    }

    private void print(String x) {
    }
}
```

This is valid because the parameters are different.

---

# 7. What is Method Overriding?

### Definition

**Method overriding occurs when a child class provides its own implementation of a method that is already defined in the parent class.**

The method must represent the same inherited method, subject to Java's overriding rules.

Overriding is mainly associated with:

> **Runtime polymorphism**  
> or  
> **Dynamic polymorphism**

---

# 8. Simple Overriding Example

```java
class Animal {

    void sound() {
        System.out.println("Animal makes a sound");
    }
}

class Dog extends Animal {

    @Override
    void sound() {
        System.out.println("Dog barks");
    }
}
```

Here:

```text
Animal
   |
   ↓
  Dog
```

The parent has:

```java
void sound()
```

The child provides another implementation:

```java
@Override
void sound()
```

Therefore, `Dog` overrides `Animal.sound()`.

---

# 9. Runtime Polymorphism Example

This is one of the **most important interview examples**.

```java
class Animal {

    void sound() {
        System.out.println("Animal sound");
    }
}

class Dog extends Animal {

    @Override
    void sound() {
        System.out.println("Dog barks");
    }
}

class Cat extends Animal {

    @Override
    void sound() {
        System.out.println("Cat meows");
    }
}
```

Now:

```java
public class Main {

    public static void main(String[] args) {

        Animal animal;

        animal = new Dog();
        animal.sound();

        animal = new Cat();
        animal.sound();
    }
}
```

Output:

```text
Dog barks
Cat meows
```

Notice:

```java
Animal animal = new Dog();
```

The **reference type** is:

```text
Animal
```

The **actual object** is:

```text
Dog
```

Therefore, at runtime Java executes:

```java
Dog.sound()
```

When the object is a `Cat`:

```java
Cat.sound()
```

is executed.

This is **runtime polymorphism**.

---

# 10. Why is @Override recommended?

Always prefer:

```java
@Override
void sound() {
}
```

instead of simply:

```java
void sound() {
}
```

`@Override` tells the compiler:

> "I intend to override a method from the parent class."

If you accidentally make a mistake in the method signature, the compiler can catch it.

Example:

```java
class Animal {

    void sound() {
    }
}

class Dog extends Animal {

    @Override
    void sounds() {   // Wrong method name
    }
}
```

The compiler reports an error because `sounds()` does not override `sound()`.

Without `@Override`, you might accidentally create a completely new method and not notice.

---

# 11. Rules of Method Overloading

### Rule 1 — Same method name

```java
void add(int a)
void add(String a)
```

Both have the same name.

---

### Rule 2 — Parameters must be different

Different:

- number
- type
- order

Example:

```java
void add(int a, int b)

void add(int a, int b, int c)
```

---

### Rule 3 — Return type alone is not enough

❌ Invalid:

```java
int add(int a) {
    return a;
}

double add(int a) {
    return a;
}
```

---

### Rule 4 — Access modifier can be different

```java
public void test(int x) {
}

private void test(String x) {
}
```

Valid.

---

### Rule 5 — Static methods can be overloaded

```java
static void test(int x) {
}

static void test(String x) {
}
```

Valid.

---

# 12. Rules of Method Overriding

### Rule 1 — Inheritance is required

Overriding normally involves a parent-child relationship.

```java
class Parent {
    void show() {
    }
}

class Child extends Parent {
    @Override
    void show() {
    }
}
```

---

### Rule 2 — Method signature must match

The overriding method must have the same:

```text
method name
+
parameter types
+
parameter order
```

Example:

```java
class Parent {

    void display(int x) {
    }
}

class Child extends Parent {

    @Override
    void display(int x) {
    }
}
```

---

### Rule 3 — Return type must be compatible

The overriding method can have the same return type.

```java
class Parent {

    Number getValue() {
        return 10;
    }
}

class Child extends Parent {

    @Override
    Integer getValue() {
        return 10;
    }
}
```

This is allowed because `Integer` is a subtype of `Number`.

This is called a **covariant return type**.

---

### Rule 4 — Access cannot be more restrictive

Suppose parent has:

```java
class Parent {

    protected void display() {
    }
}
```

Child cannot do:

```java
class Child extends Parent {

    @Override
    private void display() {
    }
}
```

❌ Invalid.

You cannot reduce visibility when overriding.

For example:

```text
public    → can remain public
protected → can become protected/public
package   → can become package/protected/public
```

But you cannot make the method less accessible.

---

# 13. final Methods Cannot Be Overridden

If a parent method is:

```java
class Parent {

    final void display() {
        System.out.println("Parent");
    }
}
```

The child cannot override it:

```java
class Child extends Parent {

    // Compilation error
    void display() {
    }
}
```

Because `final` prevents overriding.

---

# 14. static Methods Are Not Overridden

This is a **very common interview trap**.

Consider:

```java
class Parent {

    static void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {

    static void display() {
        System.out.println("Child");
    }
}
```

This is **not method overriding**.

It is called:

> **Method hiding**

Example:

```java
Parent p = new Child();

p.display();
```

Output:

```text
Parent
```

Because static method selection is based on the **reference type**, not runtime object type.

---

# 15. Instance Methods vs Static Methods

### Instance method

```java
Parent p = new Child();

p.display();
```

If `display()` is overridden:

```text
Runtime object → decides
```

So:

```text
Child.display()
```

may execute.

### Static method

```java
Parent p = new Child();

p.display();
```

If `display()` is static:

```text
Reference type → decides
```

So:

```text
Parent.display()
```

executes.

---

# 16. private Methods Cannot Be Overridden

A `private` method belongs only to the class where it is declared and is not inherited in the normal overriding sense.

Example:

```java
class Parent {

    private void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {

    void display() {
        System.out.println("Child");
    }
}
```

This is **not overriding**.

The child method is a separate method.

---

# 17. Constructors Cannot Be Overridden

Constructors are not inherited, so they cannot be overridden.

However, constructors **can be overloaded**.

Example:

```java
class Employee {

    Employee() {
    }

    Employee(String name) {
    }

    Employee(String name, int age) {
    }
}
```

These are overloaded constructors.

---

# 18. Can Constructors Be Overloaded?

### Yes.

```java
class Employee {

    Employee() {
        System.out.println("Default constructor");
    }

    Employee(String name) {
        System.out.println("Name: " + name);
    }

    Employee(String name, int age) {
        System.out.println(name + " " + age);
    }
}
```

This is **constructor overloading**, not overriding.

---

# 19. Can a Method Be Both Overloaded and Overridden?

Yes.

Consider:

```java
class Parent {

    void display() {
        System.out.println("Parent display");
    }

    void display(int x) {
        System.out.println("Parent display int");
    }
}

class Child extends Parent {

    @Override
    void display() {
        System.out.println("Child display");
    }

    void display(String message) {
        System.out.println("Child display String");
    }
}
```

Here:

```text
display()
```

is overridden.

And:

```text
display(String)
```

is an overloaded method.

So both concepts can exist in the same class hierarchy.

---

# 20. Complete Comparison

| Feature | Overloading | Overriding |
|---|---|---|
| Meaning | Same method name, different parameters | Child provides new implementation of inherited method |
| Polymorphism | Compile-time | Runtime |
| Inheritance required? | No | Yes, normally |
| Method name | Same | Same |
| Parameters | Must be different | Must match |
| Return type | Can be different, but cannot distinguish methods by return type alone | Same or covariant |
| Access modifier | Can be different | Cannot reduce visibility |
| `static` | Can be overloaded | Not overridden; static methods are hidden |
| `final` | Can overload a final method | Final method cannot be overridden |
| `private` | Can overload | Private methods are not overridden |
| Constructor | Can be overloaded | Cannot be overridden |
| Decision time | Compile time | Runtime for overridden instance methods |
| Main purpose | Provide different ways to call a method | Provide specialized behavior in child classes |
| `@Override` | Not used | Recommended |
| Inheritance relationship | Not required | Required for normal overriding |

---

# 21. The Most Important Difference

Remember this:

```text
OVERLOADING
     ↓
Same method name
     +
Different parameters
     ↓
Compiler decides
```

Whereas:

```text
OVERRIDING
     ↓
Parent-child relationship
     +
Same method signature
     ↓
Runtime decides
```

---

# 22. Easy Real-World Example

Imagine a payment system.

### Overloading

A payment service may support:

```java
pay(double amount)

pay(double amount, String currency)

pay(double amount, String currency, String description)
```

Same operation:

```text
pay()
```

but different inputs.

This is **overloading**.

---

### Overriding

Different payment methods may implement payment differently:

```java
class Payment {

    void processPayment() {
        System.out.println("Processing payment");
    }
}

class CreditCardPayment extends Payment {

    @Override
    void processPayment() {
        System.out.println("Processing credit card payment");
    }
}

class UpiPayment extends Payment {

    @Override
    void processPayment() {
        System.out.println("Processing UPI payment");
    }
}
```

Now:

```java
Payment payment = new CreditCardPayment();
payment.processPayment();
```

Output:

```text
Processing credit card payment
```

And:

```java
payment = new UpiPayment();
payment.processPayment();
```

Output:

```text
Processing UPI payment
```

This is **overriding/runtime polymorphism**.

---

# 23. Interview Tricky Question

### What happens here?

```java
class Parent {

    void show(int x) {
        System.out.println("Parent int");
    }
}

class Child extends Parent {

    @Override
    void show(int x) {
        System.out.println("Child int");
    }

    void show(String x) {
        System.out.println("Child String");
    }
}
```

Now:

```java
Child child = new Child();

child.show(10);
child.show("Hello");
```

Output:

```text
Child int
Child String
```

Why?

```text
show(int)
    ↓
Overridden method

show(String)
    ↓
Overloaded method
```

So the class contains both **overriding and overloading**.

---

# 24. Tricky Question — Which Method Is Called?

```java
class Parent {

    void show(Object obj) {
        System.out.println("Parent Object");
    }
}

class Child extends Parent {

    @Override
    void show(Object obj) {
        System.out.println("Child Object");
    }

    void show(String str) {
        System.out.println("Child String");
    }
}
```

Now:

```java
Parent p = new Child();

p.show("Hello");
```

Output:

```text
Child Object
```

Why?

First, **overloading resolution happens at compile time** based on the reference type.

Reference type:

```java
Parent
```

Parent has:

```java
show(Object)
```

So the compiler chooses:

```java
show(Object)
```

Then, because `show(Object)` is an overridden instance method, runtime dispatch selects:

```java
Child.show(Object)
```

This gives:

```text
Child Object
```

### Important concept

```text
Overloading decision → Compile time
Overriding decision  → Runtime
```

---

# 25. Another Important Example

```java
class Parent {

    void show(Object obj) {
        System.out.println("Parent Object");
    }
}

class Child extends Parent {

    @Override
    void show(Object obj) {
        System.out.println("Child Object");
    }

    void show(String str) {
        System.out.println("Child String");
    }
}
```

Compare:

```java
Child c = new Child();

c.show("Hello");
```

Output:

```text
Child String
```

But:

```java
Parent p = new Child();

p.show("Hello");
```

Output:

```text
Child Object
```

### Why are they different?

Because the compiler sees different available methods.

For:

```java
Child c
```

available methods include:

```text
show(Object)
show(String)
```

`String` is the better match.

For:

```java
Parent p
```

the compiler only sees:

```text
show(Object)
```

Then runtime overriding selects `Child.show(Object)`.

---

# 26. Overloading vs Overriding — Memory Trick

Use this:

```text
OVERLOADING
"Same name, different input"

OVERriding
"Child changes parent's behavior"
```

Or remember:

```text
Overloading  → Different Parameters
Overriding   → Same Signature
```

---

# 27. One-Line Interview Answers

### What is method overloading?

> Method overloading means defining multiple methods with the same name but different parameter lists. It is compile-time polymorphism.

### What is method overriding?

> Method overriding occurs when a child class provides its own implementation of an inherited instance method with the same signature. It enables runtime polymorphism.

### Difference?

> Overloading uses different parameters and is resolved at compile time, whereas overriding uses the same method signature in a parent-child relationship and is resolved at runtime for instance methods.

---

# 28. Interview Answer — Detailed Version

If the interviewer asks:

**"Explain overloading and overriding with the difference."**

You can say:

> **Method overloading means having multiple methods with the same name but different parameter lists. It does not require inheritance and is resolved at compile time, so it is called compile-time polymorphism.**
>
> **Method overriding happens when a child class provides its own implementation of an inherited instance method with the same signature. It requires a parent-child relationship and enables runtime polymorphism, where the implementation is selected based on the actual object at runtime.**
>
> **For example, `add(int, int)` and `add(double, double)` are overloaded methods, while a `Dog` class providing its own implementation of `Animal.sound()` is method overriding.**

---

# 29. Final Cheat Sheet

```text
                    OVERLOADING              OVERRIDING
                    ----------               ----------
Same method name?       YES                      YES

Parameters?          DIFFERENT                 SAME

Inheritance?           NO                       YES

Polymorphism?       Compile-time              Runtime

Decision?            Compiler                 Runtime

Return type alone
can differentiate?      NO                       NO

Access modifier?    Can differ              Cannot reduce visibility

static?              Can overload          Cannot override
                                           (method hiding)

final method?        Can overload              Cannot override

private method?      Can overload              Cannot override

Constructor?         Can overload              Cannot override

@ Override?             NO                      YES
                                            (recommended)

Main purpose:
Different ways to       Different implementation
call same operation     in child class
```

# ⭐ Remember These 5 Points for Interviews

```text
1. Overloading = same name + different parameters.

2. Overriding = child class + same method signature.

3. Overloading = compile-time polymorphism.

4. Overriding = runtime polymorphism.

5. static, private, and final methods are NOT overridden
   in the normal instance-method sense.
```