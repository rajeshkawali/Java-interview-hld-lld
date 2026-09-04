**Differences between `String`, `StringBuilder`, and `StringBuffer`** in Java in terms of **mutability, performance, thread-safety, and usage**.

---

## 📦 1. `String` – **Immutable & Non-Thread-Safe**

### 📌 Key Points:

* **Immutable:** Once created, a `String` object **cannot be changed**.
* Stored in the **String Constant Pool**.
* Any operation (like `concat()`) returns a **new object**.

### 💡 Example:

```java
String s = "Java";
s.concat(" World");   // does NOT change s
System.out.println(s); // prints "Java"
```

### ✅ Use when:

* Strings won't change.
* You need safe usage in multithreaded code without extra synchronization.
* You want to leverage **String interning** for memory efficiency.

---

## 🧱 2. `StringBuilder` – **Mutable & Non-Thread-Safe**

### 📌 Key Points:

* **Mutable:** Can modify contents without creating new object.
* **Faster than `String`** for multiple modifications.
* **Not thread-safe** (no synchronized methods).

### 💡 Example:

```java
StringBuilder sb = new StringBuilder("Java");
sb.append(" World");
System.out.println(sb); // prints "Java World"
```

### ✅ Use when:

* You need to modify strings **frequently**.
* Your code runs in a **single-threaded** context.
* You want **better performance** than `String`.

---

## 🔒 3. `StringBuffer` – **Mutable & Thread-Safe**

### 📌 Key Points:

* Like `StringBuilder` but all methods are **synchronized**.
* **Thread-safe**, but slightly **slower** than `StringBuilder`.

### 💡 Example:

```java
StringBuffer sb = new StringBuffer("Java");
sb.append(" World");
System.out.println(sb); // prints "Java World"
```

### ✅ Use when:

* Multiple threads might modify the string.
* You want safe string manipulation in a **multithreaded** environment.

---

## 🔁 Summary Table

| Feature         | `String`                      | `StringBuilder`     | `StringBuffer`              |
| --------------- | ----------------------------- | ------------------- | --------------------------- |
| **Mutability**  | Immutable                     | Mutable             | Mutable                     |
| **Thread-safe** | ❌ No                          | ❌ No                | ✅ Yes (synchronized)        |
| **Performance** | Slowest (for concat loops)    | Fast                | Slower than `StringBuilder` |
| **Use case**    | Constant values, config, keys | Heavy modifications | Thread-safe modifications   |
| **Introduced**  | Java 1.0                      | Java 1.5            | Java 1.0                    |

---

## 🔥 Performance Tip:

```java
// Bad: creates many objects
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i; // new String every time
}

// Good: uses buffer
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
```

---

