# Fail-Fast vs Fail-Safe Iterators in Java

> Java interview notes with runnable examples (Java 8+).

## Definitions

**Fail-fast iterator:** Detects unexpected structural modifications during iteration and may throw `ConcurrentModificationException` (CME). Detection is **best effort**, not a thread-safety guarantee.

**Fail-safe iterator:** An **informal interview term**, not an official Java iterator category. Usually refers to iterators that tolerate concurrent modification without throwing CME. Two important implementations behave differently:

- **Snapshot iterator:** `CopyOnWriteArrayList` iterates over the array snapshot captured when the iterator was created.
- **Weakly consistent iterator:** `ConcurrentHashMap` may reflect some changes made during iteration, but does not promise a fixed snapshot.

## 1. Fail-fast example: `ArrayList`

**File:** `FailFastExample.java`

```java
import java.util.ArrayList;
import java.util.List;

public class FailFastExample {
    public static void main(String[] args) {
        List<String> languages = new ArrayList<>();
        languages.add("Java");
        languages.add("Python");
        languages.add("Spring");

        /* Direct structural modification during iteration. */
        for (String language : languages) {
            System.out.println(language);
            if (language.equals("Java")) {
                languages.add("React");
            }
        }
    }
}
```

**Typical output:**

```text
Java
Exception in thread "main" java.util.ConcurrentModificationException
```

`ArrayList` maintains a modification count (`modCount`). Its iterator checks for unexpected structural changes. This example modifies the list in the **same thread**, proving CME is not limited to multithreading.

### Safe removal using `Iterator.remove()`

**File:** `SafeIteratorRemovalExample.java`

```java
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class SafeIteratorRemovalExample {
    public static void main(String[] args) {
        List<String> languages = new ArrayList<>();
        languages.add("Java");
        languages.add("Python");
        languages.add("Spring");

        Iterator<String> iterator = languages.iterator();
        while (iterator.hasNext()) {
            if (iterator.next().equals("Python")) {
                /* Safe structural removal through this iterator. */
                iterator.remove();
            }
        }
        System.out.println(languages);
    }
}
```

**Output:** `[Java, Spring]`

`removeIf()` is another convenient option when removing matching elements without manually iterating.

## 2. Snapshot iteration: `CopyOnWriteArrayList`

**File:** `CopyOnWriteExample.java`

```java
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class CopyOnWriteExample {
    public static void main(String[] args) {
        List<String> languages = new CopyOnWriteArrayList<>();
        languages.add("Java");
        languages.add("Python");
        languages.add("Spring");

        /* Iterator sees a snapshot from the start of iteration. */
        for (String language : languages) {
            System.out.println(language);
            if (language.equals("Java")) {
                languages.add("React");
            }
        }
        System.out.println("Final list: " + languages);
    }
}
```

**Output:**

```text
Java
Python
Spring
Final list: [Java, Python, Spring, React]
```

The iterator does not see `React` because it uses an earlier snapshot. Writes copy the backing array, so this collection works best when **reads greatly outnumber writes**. Its snapshot iterators do not support `remove()`, `set()`, or `add()`.

## 3. Weakly consistent iteration: `ConcurrentHashMap`

**File:** `ConcurrentHashMapIteratorExample.java`

```java
import java.util.concurrent.ConcurrentHashMap;

public class ConcurrentHashMapIteratorExample {
    public static void main(String[] args) {
        ConcurrentHashMap<Integer, String> map =
                new ConcurrentHashMap<>();
        map.put(1, "Java");
        map.put(2, "Python");

        /* Modification is allowed while iterating. */
        for (Integer key : map.keySet()) {
            System.out.println(key + " = " + map.get(key));
            if (key == 1) {
                map.put(3, "Spring");
            }
        }
        System.out.println("Final map: " + map);
    }
}
```

**Possible behavior:** The iterator may or may not visit the newly inserted entry during the same traversal. The final map contains all three entries. Iteration order is not guaranteed.

`ConcurrentHashMap` does **not** copy the entire map to create an iterator. Its iterators are weakly consistent and support concurrent updates.

## Comparison

| Feature | Fail-fast (`ArrayList`, `HashMap`) | Snapshot (`CopyOnWriteArrayList`) | Weakly consistent (`ConcurrentHashMap`) |
|---|---|---|---|
| Concurrent structural changes | May throw CME | Allowed | Allowed |
| View during iteration | Detects unexpected changes | Fixed snapshot | May reflect some changes |
| Iterator `remove()` | Often supported | Unsupported | Supported for entry/key/value views where applicable |
| Extra write cost | Usually low | Copies array on writes | Concurrency coordination overhead |
| Best suited for | Single-threaded or externally synchronized access | Read-heavy lists, infrequent updates | Concurrent map access |

## Important interview points

1. **Fail-fast is best effort:** Do not rely on CME to detect races or enforce correctness.
2. **CME can occur with one thread:** Modifying an `ArrayList` directly inside its enhanced `for` loop is enough.
3. **Structural vs non-structural changes:** Adding/removing elements is structural; replacing an existing list element using `set()` generally is not.
4. **Use iterator operations correctly:** `Iterator.remove()` is safe for supported fail-fast iterators; direct collection removal while iterating is generally unsafe.
5. **`CopyOnWriteArrayList` uses snapshots:** Existing iterators do not see later modifications; each write has copying overhead.
6. **`ConcurrentHashMap` uses weak consistency:** Its iterator is not a fixed snapshot and does not throw CME during concurrent updates.
7. **`Collections.synchronizedList(...)` is not automatically safe to iterate:** Manually synchronize on the wrapper while iterating, or use an appropriate concurrent collection.
8. **`HashMap` is not thread-safe:** A fail-fast iterator does not make the collection thread-safe.
9. **`ConcurrentHashMap` does not permit null keys or values.**
10. **Choose based on workload:** Use `CopyOnWriteArrayList` for mostly reads, `ConcurrentHashMap` for concurrent key-value operations, and ordinary collections when external synchronization or single-threaded use is sufficient.

## Common interview questions and answers

**Q1. What is the difference between fail-fast and fail-safe?**  
Fail-fast iterators may throw CME on unexpected structural modifications. “Fail-safe” informally describes iterators that tolerate modifications, often via snapshots or weak consistency.

**Q2. Is fail-safe an official Java API term?**  
No. Prefer the precise terms **snapshot iterator** and **weakly consistent iterator**.

**Q3. Can `ConcurrentModificationException` occur without multiple threads?**  
Yes. A single thread modifying an `ArrayList` directly during enhanced-for iteration can trigger it.

**Q4. Why doesn't `ConcurrentHashMap` throw CME during iteration?**  
Its iterators are designed to tolerate concurrent changes and are weakly consistent.

**Q5. Does `ConcurrentHashMap` iterate over a cloned map?**  
No. It traverses the concurrent structure without making a full snapshot.

**Q6. Does `CopyOnWriteArrayList` show newly added elements in an existing iterator?**  
No. The iterator uses the snapshot captured when it was created.

**Q7. How do you safely remove items from an `ArrayList` while iterating?**  
Use the iterator's `remove()` method or `List.removeIf(...)`.

**Q8. Which is faster: `ArrayList` or `CopyOnWriteArrayList`?**  
It depends on workload. `CopyOnWriteArrayList` is attractive for many reads and few writes; frequent writes are expensive because they copy the array.

**Q9. Are fail-fast iterators thread-safe?**  
No. Fail-fast detection does not replace synchronization.

**Q10. What happens when another thread changes a `ConcurrentHashMap` during iteration?**  
The iterator may observe some changes and miss others; it does not promise a point-in-time snapshot.

## Quick revision

```java
/*
 * FAIL-FAST:
 * - Detects unexpected structural changes (best effort).
 * - May throw ConcurrentModificationException.
 * - Examples: ArrayList, HashMap, HashSet.
 *
 * SNAPSHOT ITERATOR:
 * - Iterates over a fixed snapshot.
 * - Example: CopyOnWriteArrayList.
 *
 * WEAKLY CONSISTENT ITERATOR:
 * - Tolerates concurrent changes.
 * - May reflect some modifications.
 * - Example: ConcurrentHashMap.
 *
 * IMPORTANT:
 * "Fail-safe" is an informal term, not an official API category.
 */
```
