# Java Primitive Data Types

Java has **8 primitive data types**:

| Data Type | Size | Range / Values | Example |
|---|---:|---|---|
| `byte` | 8 bits (1 byte) | -128 to 127 | `byte age = 25;` |
| `short` | 16 bits (2 bytes) | -32,768 to 32,767 | `short salary = 30000;` |
| `int` | 32 bits (4 bytes) | -2³¹ to 2³¹ - 1 | `int count = 100000;` |
| `long` | 64 bits (8 bytes) | -2⁶³ to 2⁶³ - 1 | `long population = 8000000000L;` |
| `float` | 32 bits (4 bytes) | Approximately ±3.4 × 10³⁸ | `float price = 99.99f;` |
| `double` | 64 bits (8 bytes) | Approximately ±1.7 × 10³⁰⁸ | `double salary = 99999.99;` |
| `char` | 16 bits (2 bytes) | `0` to `65,535` (UTF-16 code unit) | `char grade = 'A';` |
| `boolean` | JVM-dependent | `true` or `false` | `boolean active = true;` |

---

# 1. byte

- Size: **8 bits = 1 byte**
- Range: **-128 to 127**
- Default value: `0`

Example:

```java
byte age = 25;
byte temperature = -10;
```

Useful when you need small integer values or byte-oriented data.

---

# 2. short

- Size: **16 bits = 2 bytes**
- Range: **-32,768 to 32,767**
- Default value: `0`

Example:

```java
short salary = 30000;
short year = 2026;
```

`short` is less commonly used in normal application code.

---

# 3. int

- Size: **32 bits = 4 bytes**
- Range: **-2³¹ to 2³¹ - 1**
- Range approximately:
  **-2,147,483,648 to 2,147,483,647**
- Default value: `0`

Example:

```java
int age = 30;
int employeeCount = 1000;
```

`int` is the **default integer type** in Java.

Example:

```java
int number = 100;
```

You normally do not need to write:

```java
int number = 100i;
```

Java does not use an `i` suffix for normal integer literals.

---

# 4. long

- Size: **64 bits = 8 bytes**
- Range: **-2⁶³ to 2⁶³ - 1**
- Range approximately:
  **-9,223,372,036,854,775,808 to 9,223,372,036,854,775,807**
- Default value: `0L`

Example:

```java
long population = 8000000000L;
long accountNumber = 1234567890123L;
```

Use `L` for a long literal when necessary.

Example:

```java
long value = 100L;
```

Without `L`:

```java
long value = 100;
```

is still valid because `100` is an `int` literal that can be widened to `long`.

But:

```java
long value = 8000000000;
```

does **not** compile because the literal is too large for an `int`.

Correct:

```java
long value = 8000000000L;
```

---

# 5. float

- Size: **32 bits = 4 bytes**
- Approximate range: **±3.4 × 10³⁸**
- Precision: approximately **6–7 decimal digits**
- Default value: `0.0f`

Example:

```java
float price = 99.99f;
float temperature = 36.5f;
```

Important:

Java treats decimal literals such as:

```java
99.99
```

as `double` by default.

Therefore:

```java
float price = 99.99;
```

causes a compilation error.

Correct:

```java
float price = 99.99f;
```

---

# 6. double

- Size: **64 bits = 8 bytes**
- Approximate range: **±1.7 × 10³⁰⁸**
- Precision: approximately **15–16 decimal digits**
- Default value: `0.0d`

Example:

```java
double price = 99.99;
double salary = 125000.50;
```

`double` is the **default floating-point type** in Java.

You can optionally use `d`:

```java
double value = 99.99d;
```

---

# 7. char

- Size: **16 bits = 2 bytes**
- Range: **0 to 65,535**
- Represents a UTF-16 code unit
- Default value: `'\u0000'`

Example:

```java
char grade = 'A';
char gender = 'M';
char symbol = '$';
```

Use **single quotes** for a `char`:

```java
char letter = 'A';
```

Use **double quotes** for a String:

```java
String letter = "A";
```

Important:

```java
char c = 'A';
```

is valid.

But:

```java
char c = "A";
```

is invalid because `"A"` is a `String`.

---

# 8. boolean

- Values: **`true` or `false`**
- Default value: `false`
- Java does not define a language-level numeric size for `boolean`; its in-memory representation is JVM/implementation dependent.

Example:

```java
boolean isActive = true;
boolean isLoggedIn = false;
```

Example:

```java
boolean isEligible = age >= 18;
```

---

# Quick Interview Table

```text
byte     -> 8 bits   -> 1 byte    -> -128 to 127
short    -> 16 bits  -> 2 bytes   -> -32,768 to 32,767
int      -> 32 bits  -> 4 bytes   -> -2³¹ to 2³¹ - 1
long     -> 64 bits  -> 8 bytes   -> -2⁶³ to 2⁶³ - 1

float    -> 32 bits  -> 4 bytes   -> ~6-7 decimal digits
double   -> 64 bits  -> 8 bytes   -> ~15-16 decimal digits

char     -> 16 bits  -> 2 bytes   -> 0 to 65,535
boolean  -> true/false             -> JVM-dependent representation
```

# Default Values of Primitive Types

```java
byte    -> 0
short   -> 0
int     -> 0
long    -> 0L

float   -> 0.0f
double  -> 0.0d

char    -> '\u0000'
boolean -> false
```

These default values apply to **instance variables, static variables, and array elements**.

Local variables do **not** receive automatic default values.

Example:

```java
public void test() {

    int number;

    System.out.println(number); // Compilation error
}
```

You must initialize it first:

```java
public void test() {

    int number = 0;

    System.out.println(number);
}
```

# Important Interview Points

### 1. How many primitive types are there?

**8**

```text
byte
short
int
long
float
double
char
boolean
```

### 2. Which is the default integer type?

```text
int
```

### 3. Which is the default decimal type?

```text
double
```

### 4. Which primitive is used for a single character?

```text
char
```

### 5. How many bytes is an int?

```text
4 bytes
```

### 6. How many bytes is a long?

```text
8 bytes
```

### 7. How many bytes is a double?

```text
8 bytes
```

### 8. How many bytes is a float?

```text
4 bytes
```

### 9. How many bytes is a char?

```text
2 bytes
```

### 10. How many bytes is a byte?

```text
1 byte
```

### 11. Why does float need `f`?

Because decimal literals are `double` by default.

```java
float value = 10.5f;
```

### 12. Why does long sometimes need `L`?

Integer literals are `int` by default.

For values outside the `int` range:

```java
long value = 10000000000L;
```

the `L` tells Java that the literal is a `long`.

# Primitive vs Wrapper Types

Each primitive has a corresponding wrapper class:

```text
byte     -> Byte
short    -> Short
int      -> Integer
long     -> Long
float    -> Float
double   -> Double
char     -> Character
boolean  -> Boolean
```

Example:

```java
int primitive = 10;

Integer wrapper = 10;
```

Primitive:

```java
int age = 30;
```

Wrapper:

```java
Integer age = 30;
```

Wrappers are objects and can therefore be used in places that require objects, such as:

```java
List<Integer> numbers =
    new ArrayList<>();
```

You cannot write:

```java
List<int> numbers; // Invalid
```

because Java generics work with reference types, not primitive types.

# Easy Memory Trick

Remember the numeric types in this order:

```text
byte → short → int → long
 1      2       4      8 bytes
```

For floating-point:

```text
float → double
  4        8 bytes
```

And:

```text
char → 2 bytes
boolean → true / false
```

# One-Line Interview Answer

> "Java has eight primitive types: byte, short, int, long, float, double, char, and boolean. The integer types range from byte to long, with sizes of 1, 2, 4, and 8 bytes respectively; float and double are 4 and 8 bytes; char is 2 bytes and represents a UTF-16 code unit; boolean has true or false values and its JVM representation is implementation-dependent."