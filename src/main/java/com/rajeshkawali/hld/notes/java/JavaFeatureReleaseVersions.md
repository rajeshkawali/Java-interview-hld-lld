# Java Features — Version-Wise Study Notes

> A copy-friendly reference to **major Java language, library, JVM, and tooling features** from Java 1.0 through Java 26. This is a curated study guide, **not** a complete inventory of every JEP or API change.
>
> **Release status:** **Direct final** = released without a public preview; **Preview** = available experimentally before finalization; **Incubator** = experimental API in an incubator module. A feature may change or be withdrawn before finalization.

## Contents
```
 Java 1.0–7: Foundations
 Java 8: Functional Java
 Java 9–11: Modules and modern APIs
 Java 12–17: Modern language syntax
 Java 18–21: Concurrency and patterns
 Java 22–26: Recent additions
 Preview-to-final timeline
 Quick interview revision
 Official references]
```

## Java 1.0–7: Foundations

### Java 1.0 (1996)
- **Object-oriented programming** — Classes, objects, inheritance, encapsulation and polymorphism. **Why:** Organize and reuse code. **Example:** `class Student { int id; }`. **Preview:** None. **Final:** 1.0.
- **JVM and bytecode** — Java source compiles to bytecode executed by a compatible JVM. **Why:** Portability. **Preview:** None. **Final:** 1.0.
- **Exceptions** — `try`, `catch`, `finally` for error handling. **Why:** Separate failures from normal flow. **Preview:** None. **Final:** 1.0.
- **Threads** — `Thread` and `Runnable` for concurrent execution. **Why:** Run independent tasks. **Preview:** None. **Final:** 1.0.
- **AWT** — Original desktop GUI toolkit. **Why:** Build graphical applications. **Preview:** None. **Final:** 1.0.

### Java 1.1 (1997)
- **Inner classes** — Classes declared within other classes. **Why:** Group related implementation. **Example:** `class Outer { class Inner {} }`. **Preview:** None. **Final:** 1.1.
- **JDBC** — API for interacting with relational databases. **Why:** Standard SQL access. **Example:** `DriverManager.getConnection(url)`. **Preview:** None. **Final:** 1.1.
- **Reflection** — Inspect types and members at runtime. **Why:** Frameworks and tooling. **Example:** `String.class.getMethods()`. **Preview:** None. **Final:** 1.1.
- **Serialization** — Encode objects for storage or transport. **Why:** Persist/transfer object state. **Preview:** None. **Final:** 1.1.
- **RMI** — Invoke methods on remote Java objects. **Why:** Distributed applications. **Preview:** None. **Final:** 1.1.

### Java 1.2 (1998)
- **Collections Framework** — Common interfaces and implementations (`List`, `Set`, `Map`). **Why:** Standard data structures. **Example:** `List<String> names = new ArrayList<>();` (generic syntax requires Java 5). **Preview:** None. **Final:** 1.2.
- **Swing** — Richer desktop UI components. **Why:** More capable GUIs. **Preview:** None. **Final:** 1.2.
- **Java 2D** — Graphics and text rendering. **Why:** Better drawing capabilities. **Preview:** None. **Final:** 1.2.

### Java 1.3 (2000)
- **HotSpot JVM** — Adaptive compilation and runtime optimization. **Why:** Improve performance. **Preview:** None. **Final:** 1.3.
- **Dynamic proxies** — Create interface proxies at runtime. **Why:** Interception and framework infrastructure. **Example:** `Proxy.newProxyInstance(...)`. **Preview:** None. **Final:** 1.3.

### Java 1.4 (2002)
- **Assertions** — `assert condition;` checks programmer assumptions. **Why:** Debugging. **Preview:** None. **Final:** 1.4.
- **Regular expressions** — `Pattern` and `Matcher`. **Why:** Match and validate text. **Preview:** None. **Final:** 1.4.
- **NIO** — Buffers and channels. **Why:** More scalable I/O. **Preview:** None. **Final:** 1.4.
- **Logging API** — `java.util.logging`. **Why:** Standard application diagnostics. **Preview:** None. **Final:** 1.4.
- **Exception chaining** — Preserve an underlying exception cause. **Why:** Better debugging. **Preview:** None. **Final:** 1.4.

### Java 5 (2004)
- **Generics** — Parameterized types such as `List<String>`. **Why:** Compile-time type safety. **Preview:** None. **Final:** 5.
- **Enhanced `for`** — `for (String name : names)`. **Why:** Simpler iteration. **Preview:** None. **Final:** 5.
- **Autoboxing/unboxing** — Automatic conversion between `int` and `Integer`. **Why:** Less boilerplate. **Preview:** None. **Final:** 5.
- **Enums** — `enum Day { MON, TUE }`. **Why:** Type-safe named constants. **Preview:** None. **Final:** 5.
- **Annotations** — Metadata such as `@Override`. **Why:** Compiler and framework integration. **Preview:** None. **Final:** 5.
- **Varargs** — `void log(String... messages)`. **Why:** Variable numbers of arguments. **Preview:** None. **Final:** 5.
- **Static imports** — `import static java.lang.Math.PI;`. **Why:** Concise use of static members. **Preview:** None. **Final:** 5.
- **Concurrency utilities** — Executors and concurrent collections. **Why:** Easier concurrent programming. **Preview:** None. **Final:** 5.

```java
List<String> names = new ArrayList<String>();
names.add("Ada");
for (String name : names) System.out.println(name);
```

### Java 6 (2006)
- **Compiler API** — Compile Java programmatically. **Why:** Tools and build integrations. **Example:** `ToolProvider.getSystemJavaCompiler()`. **Preview:** None. **Final:** 6.
- **Scripting API** — Host scripting engines. **Why:** Integrate other languages. **Preview:** None. **Final:** 6.
- **JDBC 4.0** — Automatic driver discovery and enhancements. **Why:** Simpler DB setup. **Preview:** None. **Final:** 6.
- **Console API** — Terminal input and passwords. **Why:** CLI applications. **Preview:** None. **Final:** 6.

### Java 7 (2011)
- **Diamond operator** — `new ArrayList<>()`. **Why:** Avoid repeating generic types. **Preview:** None. **Final:** 7.
- **Strings in `switch`** — Switch on string values. **Why:** Cleaner branching. **Preview:** None. **Final:** 7.
- **Try-with-resources** — Automatically close `AutoCloseable` resources. **Why:** Prevent leaks. **Preview:** None. **Final:** 7.
- **Multi-catch** — `catch (IOException | SQLException e)`. **Why:** Reduce repeated handlers. **Preview:** None. **Final:** 7.
- **Binary literals** — `0b1010`. **Why:** Readable binary values. **Preview:** None. **Final:** 7.
- **Numeric underscores** — `1_000_000`. **Why:** Readable numbers. **Preview:** None. **Final:** 7.
- **NIO.2** — `Path`, `Files`, filesystem APIs. **Why:** Better file operations. **Preview:** None. **Final:** 7.
- **Fork/Join** — Parallel divide-and-conquer framework. **Why:** Efficient parallel work. **Preview:** None. **Final:** 7.

```java
try (java.util.Scanner scanner = new java.util.Scanner(System.in)) {
    System.out.println(scanner.nextLine());
}
```

## Java 8: Functional Java

All the following were finalized directly in **Java 8 (2014)**, without a public preview phase.

- **Lambdas** — Short implementations of functional interfaces. **Why:** Less anonymous-class boilerplate. **Example:** `x -> x * 2`.
- **Functional interfaces** — Interfaces with one abstract method. **Why:** Enable lambdas. **Example:** `Predicate<String>`.
- **Streams** — Declarative pipelines over data. **Why:** Readable filtering/mapping/aggregation. **Example:** `numbers.stream().filter(n -> n > 0)`.
- **Method references** — Reuse existing methods as functions. **Why:** Shorter lambdas. **Example:** `System.out::println`.
- **Default/static interface methods** — Interface-provided implementations/utilities. **Why:** Evolve interfaces compatibly.
- **Optional** — Explicitly represent a possibly absent value. **Why:** Encourage deliberate missing-value handling. **Example:** `Optional.ofNullable(name)`.
- **`java.time`** — Modern immutable date/time types. **Why:** Replace many limitations of older date APIs. **Example:** `LocalDate.now()`.
- **CompletableFuture** — Compose asynchronous operations. **Why:** Better async programming.
- **Base64 API** — Standard encoding/decoding. **Why:** Avoid custom utilities.
- **Repeating and type annotations** — More expressive metadata. **Why:** Frameworks and type checkers.

```java
import java.util.*;
List<Integer> numbers = Arrays.asList(1, 2, 3, 4);
numbers.stream()
       .filter(n -> n % 2 == 0)
       .forEach(System.out::println);
```

## Java 9–11: Modules and modern APIs

### Java 9 (2017)
- **Module System (JPMS)** — `module-info.java` declares dependencies and exports. **Why:** Strong encapsulation and reliable configuration. **Preview:** None. **Final:** 9.
- **JShell** — Interactive Java REPL. **Why:** Test snippets quickly. **Preview:** None. **Final:** 9.
- **Collection factories** — `List.of`, `Set.of`, `Map.of`. **Why:** Easy unmodifiable collections. **Preview:** None. **Final:** 9.
- **Private interface methods** — Shared internal interface code. **Why:** Avoid duplicated default-method logic. **Preview:** None. **Final:** 9.
- **Stream additions** — `takeWhile`, `dropWhile`, `ofNullable`. **Why:** More expressive pipelines. **Preview:** None. **Final:** 9.
- **Optional additions** — `ifPresentOrElse`, `stream`. **Why:** Easier handling. **Preview:** None. **Final:** 9.
- **ProcessHandle** — Inspect/control processes. **Why:** Better OS process APIs. **Preview:** None. **Final:** 9.
- **Flow API** — Reactive Streams interfaces. **Why:** Standard backpressure contracts. **Preview:** None. **Final:** 9.
- **Multi-release JARs** — Version-specific class implementations. **Why:** Support multiple Java runtimes. **Preview:** None. **Final:** 9.

### Java 10 (2018)
- **`var` local inference** — Compiler infers local variable type. **Why:** Reduce redundant declarations. **Example:** `var name = "Java";`. **Preview:** None. **Final:** 10.
- **`copyOf` collections** — Unmodifiable copies. **Why:** Safer collection snapshots. **Preview:** None. **Final:** 10.
- **Unmodifiable collectors** — Collect stream results into unmodifiable collections. **Why:** Express immutability. **Preview:** None. **Final:** 10.
- **Application Class-Data Sharing** — Shared archived class metadata. **Why:** Improve startup/memory usage. **Preview:** None. **Final:** 10.

### Java 11 (2018, LTS)
- **HTTP Client** — Standard modern HTTP client with async and HTTP/2 support. **Why:** Replace cumbersome older patterns. **Incubator:** 9, 10. **Final:** 11.
- **String utilities** — `isBlank`, `lines`, `strip`, `repeat`. **Why:** Common text operations. **Preview:** None. **Final:** 11.
- **Files string helpers** — `Files.readString`, `Files.writeString`. **Why:** Simple text file access. **Preview:** None. **Final:** 11.
- **`Predicate.not`** — Predicate negation helper. **Why:** Readability. **Preview:** None. **Final:** 11.
- **`var` in lambda parameters** — Allows annotations with inferred types. **Why:** Consistency. **Preview:** None. **Final:** 11.
- **Single-file source launch** — `java Hello.java`. **Why:** Run simple source programs without a separate compile command. **Preview:** None. **Final:** 11.
- **Flight Recorder** — Low-overhead runtime diagnostics. **Why:** Production profiling. **Preview:** None. **Final:** 11.

## Java 12–17: Modern language syntax

### Java 12 (2019)
- **Switch expressions** — `switch` produces a value. **Why:** Less repetitive branching. **Preview:** 12, 13. **Final:** 14.
- **`String.indent` / `transform`** — Text transformations. **Why:** Cleaner string manipulation. **Preview:** None. **Final:** 12.
- **`Files.mismatch`** — Find first mismatch between files. **Why:** Easier comparison. **Preview:** None. **Final:** 12.
- **Compact number formatting** — Locale-aware abbreviated numbers. **Why:** Human-friendly display. **Preview:** None. **Final:** 12.

### Java 13 (2019)
- **Text blocks** — Multiline `"""` strings. **Why:** Readable SQL, JSON and HTML literals. **Preview:** 13, 14. **Final:** 15.
- **Switch expressions** — Second preview. **Final:** 14.
- **Dynamic CDS archives** — Dynamic class metadata archiving. **Why:** Faster subsequent startup. **Preview:** None. **Final:** 13.

### Java 14 (2020)
- **Switch expressions** — **Final:** 14 (preview 12–13).
- **Records** — Concise data carrier classes. **Why:** Remove constructor/accessor/equality boilerplate. **Preview:** 14, 15. **Final:** 16.
- **Pattern matching for `instanceof`** — Bind a variable during type testing. **Why:** Avoid explicit casts. **Preview:** 14, 15. **Final:** 16.
- **Helpful NullPointerExceptions** — Better indication of which expression was null. **Why:** Easier debugging. **Final:** 14 (enabled by default in 15).

```java
int day = 2;
String label = switch (day) {
    case 1 -> "Monday";
    case 2 -> "Tuesday";
    default -> "Other";
};
```

### Java 15 (2020)
- **Text blocks** — **Final:** 15 (preview 13–14).
- **Sealed classes** — Limit permitted subclasses. **Why:** Model controlled hierarchies. **Preview:** 15, 16. **Final:** 17.
- **Hidden classes** — Runtime-defined implementation classes. **Why:** Framework and language runtime support. **Preview:** None. **Final:** 15.

```java
String json = """
    { "language": "Java", "version": 15 }
    """;
```

### Java 16 (2021)
- **Records** — **Final:** 16 (preview 14–15). **Example:** `record Person(String name, int age) {}`.
- **`instanceof` patterns** — **Final:** 16 (preview 14–15). **Example:** `if (obj instanceof String s) System.out.println(s.length());`.
- **`Stream.toList()`** — Convenient unmodifiable result list. **Why:** Less collector boilerplate. **Preview:** None. **Final:** 16.
- **Unix-domain socket channels** — Local IPC. **Why:** Efficient local communication. **Preview:** None. **Final:** 16.
- **Vector API** — SIMD-oriented computations. **Why:** Express data-parallel operations. **Incubator:** First in 16; still incubating in 26.

### Java 17 (2021, LTS)
- **Sealed classes** — **Final:** 17 (preview 15–16).
- **Enhanced pseudorandom number generators** — More algorithms and interfaces. **Why:** Flexible random generation. **Preview:** None. **Final:** 17.
- **Pattern matching for `switch`** — Type-based case labels. **Why:** Safer, expressive dispatch. **Preview:** 17–20. **Final:** 21.
- **Strong JDK encapsulation** — Restrict unsupported internal APIs. **Why:** Security and maintainability. **Final:** 17 (following earlier stages).

```java
sealed interface Shape permits Circle, Square {}
final class Circle implements Shape {}
final class Square implements Shape {}
```

## Java 18–21: Concurrency and patterns

### Java 18 (2022)
- **UTF-8 by default** — Consistent default charset across environments. **Why:** Portability. **Preview:** None. **Final:** 18.
- **Simple Web Server** — Minimal development HTTP server. **Why:** Quick local file serving. **Preview:** None. **Final:** 18.
- **Internet-address resolution SPI** — Pluggable name resolution. **Why:** Custom resolution strategies. **Preview:** None. **Final:** 18.
- **Javadoc code snippets** — `@snippet` documentation. **Why:** Better sample-code documentation. **Preview:** None. **Final:** 18.
- **Finalization deprecated for removal** — Move away from unreliable cleanup. **Why:** Safer resource management. **Status:** Deprecation in 18.

### Java 19 (2022)
- **Virtual threads** — Lightweight threads for scalable blocking I/O. **Why:** Support many concurrent tasks. **Preview:** 19, 20. **Final:** 21.
- **Record patterns** — Deconstruct records in patterns. **Why:** Easy component extraction. **Preview:** 19, 20. **Final:** 21.
- **Structured concurrency** — Treat related concurrent subtasks as a unit. **Why:** Clear cancellation and lifecycle management. **Incubator:** 19, 20. **Preview:** 21–26. **Final:** Not yet as of 26.
- **Foreign Function & Memory API** — Native calls and off-heap memory. **Why:** Safer alternative to many JNI/Unsafe use cases. **Incubator:** 16–18. **Preview:** 19–21. **Final:** 22.

### Java 20 (2023)
- **Scoped values** — Safely share immutable context within an execution scope. **Why:** Alternative to some thread-local uses. **Incubator:** 20. **Preview:** 21–24. **Final:** 25.
- **Virtual threads** — Second preview; **Final:** 21.
- **Record patterns** — Second preview; **Final:** 21.
- **Switch patterns** — Fourth preview; **Final:** 21.

### Java 21 (2023, LTS)
- **Virtual threads** — **Final:** 21 (preview 19–20).
- **Record patterns** — **Final:** 21 (preview 19–20).
- **Pattern matching for `switch`** — **Final:** 21 (preview 17–20).
- **Sequenced collections** — `getFirst`, `getLast`, `reversed`. **Why:** Uniform order-aware APIs. **Preview:** None. **Final:** 21.
- **String templates** — Interpolated template expressions. **Preview:** 21, 22. **Final:** Not finalized; withdrawn after 22.
- **Unnamed classes / instance main methods** — Simplify introductory programs. **Preview:** 21–24 (names evolved). **Final:** 25 as compact source files and instance main methods.
- **Unnamed patterns and variables** — `_` for unused bindings. **Preview:** 21. **Final:** 22.
- **Generational ZGC** — Generational low-latency GC. **Why:** Better allocation/reclamation behavior. **Final:** 21.

```java
Thread.startVirtualThread(() -> System.out.println("Hello from virtual thread"));

record Point(int x, int y) {}
Object point = new Point(10, 20);
if (point instanceof Point(int x, int y)) {
    System.out.println(x + y);
}
```

## Java 22–26: Recent additions

### Java 22 (2024)
- **Foreign Function & Memory API** — **Final:** 22 (incubator 16–18; preview 19–21).
- **Unnamed variables/patterns** — `_` signals a deliberately unused binding. **Preview:** 21. **Final:** 22.
- **Multi-file source launch** — Launch small programs spanning source files. **Why:** Easier small projects. **Preview:** None. **Final:** 22.
- **Stream Gatherers** — Custom intermediate stream operations. **Why:** Extensible stream processing. **Preview:** 22, 23. **Final:** 24.
- **Class-File API** — Parse and generate class files. **Why:** Standard bytecode tooling. **Preview:** 22–24. **Final:** 25.
- **Statements before `super(...)`** — Constructor flexibility. **Why:** Validate arguments before superclass construction. **Preview:** 22–24. **Final:** 25 as flexible constructor bodies.

### Java 23 (2024)
- **Markdown documentation comments** — Markdown in Javadoc. **Why:** Easier documentation authoring. **Preview:** None. **Final:** 23.
- **Module import declarations** — `import module java.base;`. **Why:** Simplify imports. **Preview:** 23, 24. **Final:** 25.
- **Primitive types in patterns, `instanceof`, and `switch`** — Expand pattern support to primitive types. **Why:** More uniform pattern matching. **Preview:** 23–26. **Final:** Not yet as of 26.
- **Generational ZGC only** — Remove non-generational ZGC mode. **Why:** Simplify collector maintenance. **Final:** 23.

### Java 24 (2025)
- **Stream Gatherers** — **Final:** 24 (preview 22–23).
- **AOT class loading and linking** — Preprocess loading/linking. **Why:** Faster startup. **Preview:** None. **Final:** 24.
- **Post-quantum crypto APIs** — ML-KEM and ML-DSA. **Why:** Quantum-resistant cryptographic standards. **Preview:** None. **Final:** 24.
- **Virtual-thread synchronization improvements** — Reduce carrier-thread pinning in synchronized blocks. **Why:** Better virtual-thread scalability. **Preview:** None. **Final:** 24.
- **Security Manager permanently disabled** — Retire legacy security mechanism. **Final:** 24.
- **Compact object headers** — Smaller object headers. **Experimental:** 24. **Final:** 25.

```java
import java.util.stream.*;
var windows = Stream.of(1, 2, 3, 4, 5)
    .gather(Gatherers.windowFixed(2))
    .toList();
System.out.println(windows);
```

### Java 25 (2025, LTS)
- **Compact source files and instance main methods** — Write simple programs without a class declaration. **Why:** Easier learning and scripts. **Preview:** 21–24. **Final:** 25.
- **Module import declarations** — Import exported packages from a module. **Why:** Fewer import lines. **Preview:** 23–24. **Final:** 25.
- **Flexible constructor bodies** — Validate before `super(...)`/`this(...)` within language restrictions. **Why:** Safer construction. **Preview:** 22–24. **Final:** 25.
- **Scoped values** — Scoped immutable context propagation. **Why:** Safer alternatives to some thread locals. **Incubator:** 20. **Preview:** 21–24. **Final:** 25.
- **Class-File API** — Class file manipulation. **Why:** Standard tooling support. **Preview:** 22–24. **Final:** 25.
- **Compact object headers** — Reduce object memory overhead. **Why:** Memory efficiency. **Experimental:** 24. **Final:** 25.
- **Stable Values** — Deferred immutable value initialization. **Why:** Safe laziness. **Preview:** 25; evolved into Lazy Constants in 26. **Final:** Not yet.
- **Key Derivation Function API** — Standard key derivation interface. **Why:** Cryptographic interoperability. **Preview:** None. **Final:** 25.

```java
// Java 25: simple source file
void main() {
    System.out.println("Hello Java");
}
```

```java
// Java 25: constructor validation before super()
class Parent { Parent(int age) {} }
class Child extends Parent {
    Child(int age) {
        if (age < 0) throw new IllegalArgumentException();
        super(age);
    }
}
```

### Java 26 (2026)
- **HTTP/3 support in HTTP Client** — HTTP/3 protocol support in the standard client. **Why:** Modern network transport. **Preview:** None. **Final:** 26.
- **Primitive patterns** — Fourth preview. **Why:** Uniform type patterns. **First preview:** 23. **Final:** Not yet.
- **Structured concurrency** — Sixth preview. **Why:** Group concurrent task lifetimes. **First incubator:** 19; **first preview:** 21. **Final:** Not yet.
- **Lazy Constants** — Second preview of the API previously called Stable Values. **Why:** Controlled lazy initialization. **First preview:** 25. **Final:** Not yet.
- **PEM encodings of cryptographic objects** — Standard encode/decode APIs. **Why:** Crypto data interoperability. **Preview:** 25, 26. **Final:** Not yet.
- **Vector API** — Eleventh incubator. **Why:** SIMD programming. **First incubator:** 16. **Final:** Not yet.
- **AOT object caching with any GC** — Broader AOT caching support. **Why:** Startup improvements. **Final:** 26.
- **G1 throughput improvements** — GC synchronization optimizations. **Why:** Better throughput. **Final:** 26.
- **Prepare to Make Final Mean Final** — Tighten handling of writes to final fields. **Why:** Stronger immutability guarantees. **Status:** Preparatory changes in 26, not an across-the-board ban on all reflective writes yet.
- **Applet API removed** — Remove obsolete browser applet interfaces. **Why:** Retire unsupported technology. **Final removal:** 26.

## Preview-to-final timeline

| Feature | First preview/incubator | Final release / current status |
|---|---|---|
| HTTP Client | Incubator 9 | 11 |
| Switch expressions | Preview 12 | 14 |
| Text blocks | Preview 13 | 15 |
| Records | Preview 14 | 16 |
| `instanceof` pattern matching | Preview 14 | 16 |
| Sealed classes | Preview 15 | 17 |
| Pattern matching for `switch` | Preview 17 | 21 |
| Virtual threads | Preview 19 | 21 |
| Record patterns | Preview 19 | 21 |
| Foreign Function & Memory API | Incubator 16 | 22 |
| Unnamed patterns and variables | Preview 21 | 22 |
| Stream Gatherers | Preview 22 | 24 |
| Scoped values | Incubator 20 | 25 |
| Class-File API | Preview 22 | 25 |
| Flexible constructor bodies | Preview 22 | 25 |
| Module import declarations | Preview 23 | 25 |
| Compact source files / instance main | Preview 21 | 25 |
| Compact object headers | Experimental 24 | 25 |
| Structured concurrency | Incubator 19 | Still preview in 26 |
| Primitive patterns | Preview 23 | Still preview in 26 |
| Lazy Constants / Stable Values | Preview 25 | Still preview in 26 |
| PEM encoding API | Preview 25 | Still preview in 26 |
| Vector API | Incubator 16 | Still incubating in 26 |
| String templates | Preview 21 | Withdrawn after 22 |

## Quick interview revision

- **Java 5:** Generics, annotations, enums, enhanced for.
- **Java 7:** Try-with-resources, diamond operator, multi-catch.
- **Java 8:** Lambdas, streams, Optional, `java.time`.
- **Java 9:** Modules, JShell, `List.of`.
- **Java 10:** `var`.
- **Java 11 (LTS):** HTTP Client, String methods, source-file launch.
- **Java 14:** Switch expressions.
- **Java 15:** Text blocks.
- **Java 16:** Records, `instanceof` patterns.
- **Java 17 (LTS):** Sealed classes.
- **Java 21 (LTS):** Virtual threads, record patterns, switch patterns, sequenced collections.
- **Java 22:** FFM API, unnamed variables.
- **Java 24:** Stream Gatherers.
- **Java 25 (LTS):** Scoped values, module imports, flexible constructors, compact source files, Class-File API.
- **Java 26:** HTTP/3 support and continued previews.

## Official references

- [OpenJDK JEP index](https://openjdk.org/jeps/0)
- [OpenJDK JDK project releases](https://openjdk.org/projects/jdk/)
- [Oracle Java documentation](https://docs.oracle.com/en/java/)

---

**Study tip:** For each feature, remember (1) what it does, (2) why it exists, (3) a tiny code example, and (4) its first preview and final version. Examples across this document target different Java releases; compile each with a JDK version that supports its syntax and APIs.
