# Java Collections Framework — Complete Hierarchy, Java Versions, Use Cases & Interview Q&A

> **Focus:** Internal data structures, hierarchy, performance, Java versions, Java 21 Sequenced Collections, design decisions, production use cases and interview questions.

---

# 1. Collections Framework — Big Picture

The Java Collections Framework is mainly divided into two areas:

```text
                         Java Collections Framework
                                  |
                    +-------------+-------------+
                    |                           |
              Collection                      Map
                    |                           |
        +-----------+-----------+       +-------+-------+
        |           |           |       |       |       |
       List         Set        Queue   Map   SortedMap
        |           |           |       |       |
        |           |           |       |   NavigableMap
        |           |           |       |
        |           |           |   SequencedMap (Java 21)
        |           |           |
        |           |        Deque
        |           |           |
        |           |      SequencedCollection
        |           |
        |      SequencedSet
        |
   SequencedCollection
```

There is one very important point:

```text
Collection
    |
    +-- List
    +-- Set
    +-- Queue
```

`Map` is **NOT** a subtype of `Collection`.

```text
Collection
    |
    +-- List
    +-- Set
    +-- Queue

Map
    |
    +-- SortedMap
```

A `Map` stores **key-value pairs**, while a `Collection` stores individual elements.

---

# 2. Complete Collection Hierarchy

The following is a simplified but interview-friendly hierarchy.

```text
java.lang.Iterable
        |
        v
java.util.Collection
        |
        +------------------+------------------+
        |                  |                  |
       List               Set               Queue
        |                  |                  |
        |                  |                  +----------------+
        |                  |                  |                |
        |                  |                Deque           PriorityQueue
        |                  |                  |
        |                  |            SequencedCollection
        |                  |
        |                  +---- SequencedSet
        |
        +---- SequencedCollection
```

More accurately:

```text
Collection
   |
   +---------------- List
   |                    |
   |                    +-- ArrayList
   |                    +-- LinkedList
   |                    +-- Vector
   |                         |
   |                         +-- Stack
   |
   +---------------- Set
   |                    |
   |                    +-- HashSet
   |                    |     |
   |                    |     +-- LinkedHashSet
   |                    |
   |                    +-- SortedSet
   |                          |
   |                          +-- NavigableSet
   |                                |
   |                                +-- TreeSet
   |
   +---------------- Queue
                        |
                        +-- PriorityQueue
                        |
                        +-- Deque
                              |
                              +-- ArrayDeque
                              +-- LinkedList
```

### Java 21 Sequenced hierarchy

Java 21 introduced the following interfaces:

```text
Collection
    |
    +-- SequencedCollection
    |       |
    |       +-- List
    |       |
    |       +-- Deque
    |       |
    |       +-- SequencedSet
    |
    +-- Set
            |
            +-- SequencedSet
```

`SequencedSet` is itself a specialized `SequencedCollection`.

The important idea is:

```text
SequencedCollection
        |
        +-- first element
        +-- last element
        +-- reverse view
```

This provides a common API for collections where encounter order matters.

---

# 3. Map Hierarchy

`Map` has its own hierarchy.

```text
java.util.Map
      |
      +------------------------------+
      |                              |
  HashMap                        SortedMap
      |                              |
      |                         NavigableMap
      |                              |
      |                           TreeMap
      |
      +-- LinkedHashMap
      |
      +-- Hashtable
      |
      +-- WeakHashMap
      |
      +-- IdentityHashMap
      |
      +-- EnumMap
      |
      +-- ConcurrentMap
              |
              +-- ConcurrentHashMap
```

### Java 21 addition

```text
Map
 |
 +-- SequencedMap
       |
       +-- LinkedHashMap

SortedMap
 |
 +-- SequencedMap

NavigableMap
 |
 +-- TreeMap
```

Conceptually:

```text
                         Map
                          |
              +-----------+-----------+
              |                       |
          SequencedMap             SortedMap
              |                       |
              |                   NavigableMap
              |                       |
        LinkedHashMap              TreeMap
```

Note that these relationships overlap through inheritance:

```text
SortedMap extends SequencedMap
NavigableMap extends SortedMap
```

So `TreeMap`, through `NavigableMap`, is also a `SequencedMap` in Java 21.

---

# 4. Java Versions — Important Collection Data Structures

For interviews, remember the major versions rather than every minor implementation detail.

| Collection / Interface | Introduced |
|---|---:|
| `Vector` | Java 1.0 |
| `Stack` | Java 1.0 |
| `Hashtable` | Java 1.0 |
| Collections Framework | Java 1.2 |
| `ArrayList` | Java 1.2 |
| `LinkedList` | Java 1.2 |
| `HashSet` | Java 1.2 |
| `TreeSet` | Java 1.2 |
| `HashMap` | Java 1.2 |
| `TreeMap` | Java 1.2 |
| `WeakHashMap` | Java 1.2 |
| `LinkedHashSet` | Java 1.4 |
| `LinkedHashMap` | Java 1.4 |
| `IdentityHashMap` | Java 1.4 |
| `PriorityQueue` | Java 5 |
| `ConcurrentHashMap` | Java 5 |
| `CopyOnWriteArrayList` | Java 5 |
| `EnumSet` | Java 5 |
| `EnumMap` | Java 5 |
| `ArrayDeque` | Java 6 |
| `NavigableSet` | Java 6 |
| `NavigableMap` | Java 6 |
| `Deque` | Java 6 |
| `ConcurrentLinkedQueue` | Java 5 |
| `BlockingQueue` | Java 5 |
| `CopyOnWriteArraySet` | Java 5 |
| `SequencedCollection` | Java 21 |
| `SequencedSet` | Java 21 |
| `SequencedMap` | Java 21 |

---

# 5. List Hierarchy

```text
List
 |
 +-- ArrayList
 |
 +-- LinkedList
 |
 +-- Vector
       |
       +-- Stack
```

A `List`:

- Allows duplicates
- Maintains positional/index-based access
- Usually maintains insertion/encounter order
- Allows indexed operations

Example:

```java
List<String> names = new ArrayList<>();

names.add("John");
names.add("Mike");
names.add("John");

System.out.println(names);
```

Output:

```text
[John, Mike, John]
```

Duplicates are allowed.

---

# 6. ArrayList

### Introduced

Java 1.2

### Internal structure

`ArrayList` is backed by a dynamically growing array.

```text
ArrayList
   |
   v
Object[]
   |
   +---- [0] A
   +---- [1] B
   +---- [2] C
   +---- [3] D
```

Example:

```java
List<String> users = new ArrayList<>();

users.add("A");
users.add("B");
users.add("C");

String user = users.get(1);
```

### Complexity

| Operation | Complexity |
|---|---:|
| `get(index)` | O(1) |
| `set(index)` | O(1) |
| `add(element)` | O(1) amortized |
| `add(index, element)` | O(n) |
| `remove(index)` | O(n) |
| `contains()` | O(n) |
| Sorting | O(n log n) |

### Why is add O(1) amortized?

Usually an element is inserted at the end.

But when the internal array becomes full:

```text
Old array
[A][B][C][D]
            ↓
       grow/copy
            ↓
New array
[A][B][C][D][ ][ ][ ]
```

The copying operation is O(n).

But it doesn't happen on every insertion, so append is **amortized O(1)**.

### When should I use ArrayList?

Use it when:

- You need fast random access.
- Reads are frequent.
- Appends are common.
- You don't frequently insert/remove from the middle.

Typical production choice:

```java
List<Order> orders = new ArrayList<>();
```

This should be the default list choice in many applications unless there is a specific reason to choose something else.

---

# 7. LinkedList

### Introduced

Java 1.2

`LinkedList` is a doubly linked list.

```text
null
 |
 v

[A]
 | prev = null
 | next
 v
[B]
 | prev
 | next
 v
[C]
 | prev
 | next = null
```

Each node conceptually contains:

```text
Node
+----------------------+
| previous             |
| element              |
| next                 |
+----------------------+
```

### Complexity

| Operation | Complexity |
|---|---:|
| `get(index)` | O(n) |
| `set(index)` | O(n) |
| Add/remove at ends | O(1) |
| `add(index)` | O(n) to locate node |
| `remove(index)` | O(n) to locate node |
| `contains()` | O(n) |

Important:

A common interview mistake is:

> "LinkedList insertion is always O(1)."

That's incomplete.

If you already have the node/iterator position:

```text
insert = O(1)
```

But if you call:

```java
list.add(500000, value);
```

Java first needs to locate the position.

Therefore:

```text
locating position = O(n)
actual link update = O(1)
```

---

# 8. ArrayList vs LinkedList

| Feature | ArrayList | LinkedList |
|---|---|---|
| Internal structure | Dynamic array | Doubly linked list |
| Random access | Fast | Slow |
| `get(index)` | O(1) | O(n) |
| Add at end | O(1) amortized | O(1) |
| Remove first | O(n) | O(1) |
| Memory overhead | Lower | Higher |
| Cache locality | Better | Worse |
| Typical default | Yes | Rare |
| Queue/Deque support | No | Yes |

### Senior-level decision

In most normal business applications:

```java
List<T> list = new ArrayList<>();
```

is preferable.

Don't choose `LinkedList` simply because:

> "We have many insertions."

Ask **where the insertion happens and whether locating the position is expensive**.

---

# 9. Vector

### Introduced

Java 1.0

`Vector` is a legacy synchronized dynamic array.

```java
Vector<String> vector = new Vector<>();
```

Historically, its methods are synchronized.

### Why don't we normally use Vector?

Because synchronization is built into the legacy implementation and often isn't the right concurrency design for modern applications.

Prefer:

```java
List<String> list = new ArrayList<>();
```

or, if concurrent access is required, choose an appropriate concurrent collection based on the workload.

For example:

```java
List<String> list =
        new CopyOnWriteArrayList<>();
```

if the workload is read-heavy and mutation is rare.

---

# 10. Stack

### Introduced

Java 1.0

`Stack` extends `Vector`.

```text
Vector
   |
 Stack
```

It represents LIFO behavior:

```text
push()
push()
pop()
```

Example:

```java
Stack<Integer> stack = new Stack<>();

stack.push(10);
stack.push(20);
stack.push(30);

System.out.println(stack.pop());
```

Output:

```text
30
```

### Modern recommendation

Prefer:

```java
Deque<Integer> stack = new ArrayDeque<>();

stack.push(10);
stack.push(20);
stack.push(30);

stack.pop();
```

Why?

`Deque` provides a cleaner modern abstraction for stack behavior without relying on the legacy `Stack` class.

---

# 11. Set Hierarchy

```text
Set
 |
 +-- HashSet
 |
 +-- LinkedHashSet
 |
 +-- SortedSet
       |
       +-- NavigableSet
              |
              +-- TreeSet
```

A `Set` generally represents unique elements.

```java
Set<String> set = new HashSet<>();

set.add("A");
set.add("B");
set.add("A");
```

Result:

```text
[A, B]
```

The duplicate `"A"` is not added.

---

# 12. HashSet

### Introduced

Java 1.2

Internally, `HashSet` is backed by a `HashMap`.

Conceptually:

```text
HashSet
   |
   v
HashMap
   |
   +-- element -> PRESENT
```

For example:

```java
Set<String> set = new HashSet<>();
set.add("A");
```

Internally it is conceptually similar to:

```text
HashMap
+----------------+
| "A" -> dummy   |
+----------------+
```

### Complexity

Average:

```text
add()      O(1)
remove()   O(1)
contains() O(1)
```

Worst-case behavior can be different depending on collisions and implementation details.

### When to use?

Use `HashSet` when:

- Uniqueness matters.
- Ordering does not matter.
- Fast lookup is important.

Example:

```java
Set<Long> processedOrderIds = new HashSet<>();
```

---

# 13. LinkedHashSet

### Introduced

Java 1.4

It combines:

```text
HashSet
+
Linked ordering information
```

Example:

```java
Set<String> set = new LinkedHashSet<>();

set.add("B");
set.add("A");
set.add("C");

System.out.println(set);
```

Output:

```text
[B, A, C]
```

It maintains insertion/encounter order.

### When to use?

Use it when:

```text
Need uniqueness
+
Need predictable insertion order
```

Example:

```java
Set<String> uniqueTags = new LinkedHashSet<>();
```

---

# 14. TreeSet

### Introduced

Java 1.2

`TreeSet` is based on a balanced tree structure, specifically a Red-Black tree through `TreeMap`.

```text
TreeSet
   |
   v
TreeMap
   |
   v
Red-Black Tree
```

It maintains sorted order.

```java
Set<Integer> numbers = new TreeSet<>();

numbers.add(30);
numbers.add(10);
numbers.add(20);

System.out.println(numbers);
```

Output:

```text
[10, 20, 30]
```

### Complexity

```text
add()      O(log n)
remove()   O(log n)
contains() O(log n)
```

### When to use?

Use when you need:

- Sorted data
- Range queries
- `floor()`
- `ceiling()`
- `lower()`
- `higher()`
- first/last element

Example:

```java
NavigableSet<Integer> scores = new TreeSet<>();

scores.add(10);
scores.add(20);
scores.add(30);

System.out.println(scores.floor(25));   // 20
System.out.println(scores.ceiling(25)); // 30
```

---

# 15. Queue Hierarchy

```text
Queue
 |
 +-- PriorityQueue
 |
 +-- Deque
       |
       +-- ArrayDeque
       |
       +-- LinkedList
```

Queue generally represents:

```text
FIFO

First In
   ↓
First Out
```

Example:

```java
Queue<String> queue = new ArrayDeque<>();

queue.offer("A");
queue.offer("B");
queue.offer("C");

queue.poll();
```

Result:

```text
A removed first
```

---

# 16. Queue Methods — Important Interview Topic

There are paired methods.

| Operation | Throws exception | Returns special value |
|---|---|---|
| Insert | `add()` | `offer()` |
| Remove | `remove()` | `poll()` |
| Examine | `element()` | `peek()` |

Example:

```java
Queue<String> queue = new ArrayDeque<>();

queue.offer("A");

String value = queue.poll();
String next = queue.peek();
```

### Why use `offer/poll/peek`?

They generally provide safer behavior for queue APIs because they return special values instead of throwing exceptions for certain empty/full conditions.

---

# 17. Deque

`Deque` means:

```text
Double Ended Queue
```

You can insert/remove from both ends.

```text
       addFirst()
          ↓
   +-------------+
   | A B C D     |
   +-------------+
          ↑
       addLast()
```

Operations:

```java
Deque<Integer> deque = new ArrayDeque<>();

deque.addFirst(10);
deque.addLast(20);

deque.removeFirst();
deque.removeLast();
```

---

# 18. ArrayDeque

### Introduced

Java 6

It is usually the preferred implementation for stack/queue operations when thread safety is not required.

### Stack usage

```java
Deque<Integer> stack = new ArrayDeque<>();

stack.push(10);
stack.push(20);
stack.push(30);

System.out.println(stack.pop());
```

### Queue usage

```java
Deque<Integer> queue = new ArrayDeque<>();

queue.offer(10);
queue.offer(20);
queue.offer(30);

System.out.println(queue.poll());
```

### Why ArrayDeque?

Compared with legacy `Stack`:

```text
ArrayDeque
   ↓
modern
efficient
supports stack + queue
```

### Important limitation

`ArrayDeque` does not permit `null` elements.

---

# 19. PriorityQueue

### Introduced

Java 5

Unlike a normal FIFO queue, `PriorityQueue` removes according to priority/order.

```java
Queue<Integer> queue = new PriorityQueue<>();

queue.offer(30);
queue.offer(10);
queue.offer(20);

System.out.println(queue.poll());
```

Output:

```text
10
```

By default it is a min-heap.

Conceptually:

```text
        10
       /  \
     30    20
```

### Complexity

```text
offer()   O(log n)
poll()    O(log n)
peek()    O(1)
```

### Important interview point

Iterating a `PriorityQueue` does **not** mean elements are returned in sorted order.

The heap guarantees that the highest-priority element is available at the head.

---

# 20. Java 21 — SequencedCollection

Java 21 introduced:

```text
SequencedCollection
```

The goal was to provide a common API for collections that have a defined encounter order.

Important methods include:

```java
getFirst()
getLast()
addFirst()
addLast()
removeFirst()
removeLast()
reversed()
```

Conceptually:

```text
SequencedCollection
       |
       +-- first
       |
       +-- last
       |
       +-- reverse view
```

This addresses a long-standing API inconsistency where different ordered collections had different ways of accessing their first/last elements.

---

# 21. Example — SequencedCollection

```java
SequencedCollection<String> names =
        new ArrayList<>();

names.add("A");
names.add("B");
names.add("C");

System.out.println(names.getFirst());
System.out.println(names.getLast());
```

Output:

```text
A
C
```

Reverse view:

```java
SequencedCollection<String> reversed =
        names.reversed();
```

Conceptually:

```text
Original:

A → B → C

Reversed view:

C → B → A
```

The important point is that `reversed()` provides a **view**, rather than requiring you to manually create another collection just to reverse the ordering.

---

# 22. SequencedSet — Java 21

Java 21 introduced:

```text
SequencedSet
```

It combines:

```text
Set
+
SequencedCollection
```

Therefore:

```text
SequencedSet
    |
    +-- uniqueness
    |
    +-- defined encounter order
    |
    +-- first/last operations
    |
    +-- reversed view
```

Example:

```java
SequencedSet<String> names =
        new LinkedHashSet<>();

names.add("A");
names.add("B");
names.add("C");

System.out.println(names.getFirst());
System.out.println(names.getLast());
```

### Why is this useful?

Before Java 21, APIs for ordered sets were less uniform.

Java 21 gives a common abstraction for:

```text
first
last
reverse
```

while retaining Set semantics.

---

# 23. SequencedMap — Java 21

Java 21 also introduced:

```text
SequencedMap
```

A `SequencedMap` has a defined encounter order for entries.

It provides operations such as:

```text
firstEntry()
lastEntry()
pollFirstEntry()
pollLastEntry()
putFirst()
putLast()
reversed()
```

Example:

```java
SequencedMap<String, Integer> map =
        new LinkedHashMap<>();

map.put("A", 1);
map.put("B", 2);
map.put("C", 3);

System.out.println(map.firstEntry());
System.out.println(map.lastEntry());
```

Conceptually:

```text
A=1 → B=2 → C=3
```

Reverse view:

```java
SequencedMap<String, Integer> reversed =
        map.reversed();
```

Conceptually:

```text
C=3 → B=2 → A=1
```

---

# 24. Why Were Sequenced Collections Added?

This is a good senior-level interview question.

Before Java 21, ordered collection APIs were somewhat inconsistent.

For example, developers often had to use different methods depending on the implementation:

```text
List
    get(0)
    get(size - 1)

Deque
    getFirst()
    getLast()

NavigableSet
    first()
    last()

LinkedHashMap
    special handling / iteration
```

Java 21 introduced a common abstraction:

```text
SequencedCollection
SequencedSet
SequencedMap
```

This standardizes access to:

```text
first
last
reverse
```

### Interview answer

> "Java 21 introduced the SequencedCollection, SequencedSet and SequencedMap interfaces to provide a common API for collections and maps with a defined encounter order, particularly for accessing the first and last elements and obtaining a reversed view."

---

# 25. Map — HashMap

### Introduced

Java 1.2

`HashMap` stores:

```text
Key → Value
```

Example:

```java
Map<Long, String> employees = new HashMap<>();

employees.put(101L, "John");
employees.put(102L, "Mike");

System.out.println(employees.get(101L));
```

Output:

```text
John
```

### Typical complexity

Average:

```text
put()     O(1)
get()     O(1)
remove()  O(1)
containsKey() O(1)
```

### Internal structure

Modern Java `HashMap` uses:

```text
Hash table
   |
   +-- buckets
          |
          +-- nodes
          |
          +-- tree structure for heavily-collided buckets
```

For interview purposes, explain that modern implementations can convert a heavily collided bucket into a tree structure under appropriate conditions, improving lookup behavior for that bucket.

---

# 26. How HashMap Works Internally

Suppose:

```java
map.put("John", 100);
```

Conceptually:

```text
"John"
   |
hashCode()
   |
hash spreading
   |
bucket index
   |
   v
+----------------+
| bucket         |
+----------------+
       |
       v
   Entry/Node
   key = John
   value = 100
```

For lookup:

```java
map.get("John");
```

Java:

```text
key
 ↓
hashCode()
 ↓
bucket
 ↓
compare hash
 ↓
equals()
 ↓
value
```

This is why correct implementations of:

```text
equals()
hashCode()
```

are critical when using objects as `HashMap` keys.

---

# 27. HashMap and equals/hashCode Interview Question

Suppose:

```java
class Employee {

    private int id;

    public Employee(int id) {
        this.id = id;
    }
}
```

Then:

```java
Map<Employee, String> map = new HashMap<>();

Employee e1 = new Employee(1);
map.put(e1, "John");

Employee e2 = new Employee(1);

System.out.println(map.get(e2));
```

You may not get `"John"` because `Employee` hasn't defined equality based on `id`.

For a hash-based collection, the contract is:

```text
if a.equals(b) == true
then
a.hashCode() == b.hashCode()
```

This is a critical interview topic.

---

# 28. LinkedHashMap

### Introduced

Java 1.4

`LinkedHashMap` combines:

```text
HashMap
+
predictable encounter order
```

Example:

```java
Map<String, Integer> map =
        new LinkedHashMap<>();

map.put("A", 1);
map.put("B", 2);
map.put("C", 3);
```

Iteration generally follows insertion order.

### Special feature: Access Order

You can construct it with access-order behavior:

```java
Map<String, Integer> cache =
        new LinkedHashMap<>(16, 0.75f, true);
```

The final `true` means:

```text
accessOrder = true
```

This is useful when implementing an LRU-style cache.

---

# 29. TreeMap

### Introduced

Java 1.2

`TreeMap` maintains keys in sorted order.

Internally it is based on a balanced tree.

```text
TreeMap
   |
   v
Red-Black Tree
```

Example:

```java
Map<Integer, String> map = new TreeMap<>();

map.put(30, "C");
map.put(10, "A");
map.put(20, "B");
```

Iteration:

```text
10=A
20=B
30=C
```

### Complexity

```text
put()     O(log n)
get()     O(log n)
remove()  O(log n)
```

### When to use?

Use `TreeMap` when you need:

- Sorted keys
- Range queries
- `floorKey`
- `ceilingKey`
- `lowerKey`
- `higherKey`
- first/last key

---

# 30. TreeMap vs HashMap

| Requirement | HashMap | TreeMap |
|---|---|---|
| Fast average lookup | Yes | No |
| Sorted keys | No | Yes |
| Average get | O(1) | O(log n) |
| Range queries | No | Yes |
| `floorKey()` | No | Yes |
| `ceilingKey()` | No | Yes |
| Ordering required | No | Yes |

### Senior decision

If the requirement says:

> "I need fast key lookup and don't care about ordering."

Use:

```java
HashMap
```

If it says:

> "I need keys sorted or need range navigation."

Use:

```java
TreeMap
```

Don't use `TreeMap` merely because "sorted is better."

Sorting has a cost.

---

# 31. Hashtable

### Introduced

Java 1.0

`Hashtable` is a legacy synchronized map.

```text
Hashtable
    |
legacy
synchronized
doesn't allow null key/value
```

Modern applications generally prefer:

```java
HashMap
```

or:

```java
ConcurrentHashMap
```

depending on concurrency requirements.

---

# 32. ConcurrentHashMap

### Introduced

Java 5

Used for concurrent access to a map.

```java
Map<String, Integer> map =
        new ConcurrentHashMap<>();
```

It provides thread-safe concurrent operations without using one global lock around the entire map for ordinary operations.

Important methods include:

```java
putIfAbsent()
compute()
computeIfAbsent()
computeIfPresent()
merge()
```

Example:

```java
ConcurrentHashMap<String, Integer> counts =
        new ConcurrentHashMap<>();

counts.merge("JAVA", 1, Integer::sum);
```

This is much safer than manually doing:

```java
if (!map.containsKey(key)) {
    map.put(key, 1);
}
```

because that compound operation is not atomic.

---

# 33. ConcurrentHashMap — Important Interview Trap

This is unsafe as a general concurrent pattern:

```java
if (!map.containsKey(key)) {
    map.put(key, value);
}
```

Another thread can modify the map between:

```text
containsKey()
     ↓
put()
```

Instead use atomic map operations:

```java
map.putIfAbsent(key, value);
```

or:

```java
map.computeIfAbsent(key, k -> createValue(k));
```

This demonstrates a stronger understanding of concurrent collections.

---

# 34. WeakHashMap

### Introduced

Java 1.2

`WeakHashMap` uses weak references for keys.

The important idea:

```text
If the key is no longer strongly referenced elsewhere,
the entry can become eligible for removal by GC.
```

Example use case:

```text
metadata associated with objects
temporary object-associated cache
```

It can be useful when you don't want a cache/map itself to keep keys alive indefinitely.

### Important warning

Don't assume:

> "WeakHashMap is a general-purpose cache."

It is not a replacement for a production cache with proper eviction, sizing and operational policies.

---

# 35. IdentityHashMap

### Introduced

Java 1.4

Unlike normal `HashMap`, `IdentityHashMap` uses **reference identity** semantics.

Conceptually:

```text
HashMap
    uses equals()

IdentityHashMap
    uses ==
```

Example:

```java
String a = new String("JAVA");
String b = new String("JAVA");

System.out.println(a.equals(b)); // true
System.out.println(a == b);     // false
```

A normal `HashMap` considers them equal based on `equals()`.

`IdentityHashMap` treats them as different references.

### When useful?

Specialized cases such as:

- object graph processing
- graph traversal
- serialization-like algorithms
- tracking object identity

Do not use it as a normal replacement for `HashMap`.

---

# 36. EnumSet

### Introduced

Java 5

`EnumSet` is specialized for enum values.

Example:

```java
enum Permission {
    READ,
    WRITE,
    DELETE
}

EnumSet<Permission> permissions =
        EnumSet.of(
                Permission.READ,
                Permission.WRITE
        );
```

Why use it?

Because it is optimized specifically for enum values and is usually more efficient than using a general-purpose `HashSet<Permission>`.

---

# 37. EnumMap

### Introduced

Java 5

Specialized map for enum keys.

```java
EnumMap<Permission, String> map =
        new EnumMap<>(Permission.class);
```

Use it when:

```text
Key type = enum
```

It can be more compact and efficient than a general-purpose map.

---

# 38. CopyOnWriteArrayList

### Introduced

Java 5

Useful for:

```text
many reads
very few writes
```

When modified, it creates a new underlying array.

Conceptually:

```text
Readers
   |
   v
[A B C]

Writer modifies
   |
   v
new array
[A B C D]
```

Existing readers can continue working against the previous snapshot.

### Good use case

Listener collections:

```java
List<Listener> listeners =
        new CopyOnWriteArrayList<>();
```

where:

```text
read/iterate = very frequent
add/remove listener = rare
```

### Bad use case

High-frequency writes.

If you continuously modify the collection, repeatedly copying arrays can be expensive.

---

# 39. CopyOnWriteArraySet

### Introduced

Java 5

Similar concept to `CopyOnWriteArrayList`, but provides Set semantics.

Use when:

```text
read-heavy
write-light
unique elements
```

---

# 40. Choosing the Correct List

```text
Need List?
    |
    +-- Fast random access?
    |       |
    |      YES
    |       |
    |   ArrayList
    |
    +-- Need queue/deque operations?
    |       |
    |      YES
    |       |
    |   ArrayDeque / LinkedList
    |
    +-- Heavy concurrent reads + rare writes?
            |
           YES
            |
    CopyOnWriteArrayList
```

### Practical default

```java
List<T> list = new ArrayList<>();
```

---

# 41. Choosing the Correct Set

```text
Need unique elements?
        |
       YES
        |
        +-- Ordering irrelevant?
        |       |
        |      YES
        |       |
        |    HashSet
        |
        +-- Insertion/encounter order required?
        |       |
        |      YES
        |       |
        |   LinkedHashSet
        |
        +-- Sorted/range operations required?
                |
               YES
                |
             TreeSet
```

Java 21 perspective:

```text
Need ordered + unique + first/last/reverse API?
        |
       YES
        |
    SequencedSet
```

---

# 42. Choosing the Correct Queue

```text
Need FIFO?
   |
  YES
   |
ArrayDeque

Need LIFO?
   |
  YES
   |
ArrayDeque

Need priority-based removal?
   |
  YES
   |
PriorityQueue

Need thread-safe FIFO?
   |
  YES
   |
ConcurrentLinkedQueue
```

For blocking producer-consumer scenarios:

```text
BlockingQueue
    |
    +-- ArrayBlockingQueue
    +-- LinkedBlockingQueue
    +-- PriorityBlockingQueue
    +-- DelayQueue
```

The exact choice depends on whether you need bounded capacity, ordering, delays, etc.

---

# 43. Choosing the Correct Map

```text
Need key-value lookup?
        |
       YES
        |
        +-- Ordering irrelevant?
        |       |
        |      YES
        |       |
        |    HashMap
        |
        +-- Preserve encounter/insertion order?
        |       |
        |      YES
        |       |
        |   LinkedHashMap
        |
        +-- Sorted keys / range operations?
        |       |
        |      YES
        |       |
        |    TreeMap
        |
        +-- Concurrent access?
        |       |
        |      YES
        |       |
        | ConcurrentHashMap
        |
        +-- Enum keys?
                |
               YES
                |
             EnumMap
```

Java 21:

```text
Need ordered map + first/last/reverse APIs?
        |
       YES
        |
    SequencedMap
```

---

# 44. Complete Decision Table

| Requirement | Recommended |
|---|---|
| General-purpose List | `ArrayList` |
| Fast random access | `ArrayList` |
| Stack | `ArrayDeque` |
| FIFO queue | `ArrayDeque` |
| Double-ended queue | `ArrayDeque` |
| Priority queue | `PriorityQueue` |
| Unique elements, no order | `HashSet` |
| Unique + insertion order | `LinkedHashSet` |
| Unique + sorted | `TreeSet` |
| Key-value, no ordering | `HashMap` |
| Key-value + insertion order | `LinkedHashMap` |
| Key-value + sorted keys | `TreeMap` |
| Concurrent map | `ConcurrentHashMap` |
| Enum keys | `EnumMap` |
| Enum values as Set | `EnumSet` |
| Read-heavy concurrent List | `CopyOnWriteArrayList` |
| Read-heavy concurrent Set | `CopyOnWriteArraySet` |
| Weakly referenced keys | `WeakHashMap` |
| Identity (`==`) semantics | `IdentityHashMap` |
| Legacy synchronized List | `Vector` |
| Legacy stack | `Stack` |
| Legacy synchronized Map | `Hashtable` |

---

# 45. Null Support — Important Interview Table

Null behavior is frequently asked.

| Collection | Null |
|---|---|
| `ArrayList` | Allows null |
| `LinkedList` | Allows null |
| `HashSet` | Allows one null |
| `LinkedHashSet` | Allows one null |
| `TreeSet` | Generally does not support null with natural ordering |
| `ArrayDeque` | Does not allow null |
| `PriorityQueue` | Does not allow null |
| `HashMap` | Allows one null key and multiple null values |
| `LinkedHashMap` | Allows null key/value |
| `TreeMap` | Null key generally not supported with natural ordering |
| `Hashtable` | No null key/value |
| `ConcurrentHashMap` | No null key/value |

The exact behavior should always be checked against the API contract when designing around edge cases.

---

# 46. Ordering Comparison

```text
HashSet
    ↓
No guaranteed encounter order

LinkedHashSet
    ↓
Predictable encounter order

TreeSet
    ↓
Sorted order

ArrayList
    ↓
Insertion/index order

PriorityQueue
    ↓
Priority ordering at head

HashMap
    ↓
No guaranteed encounter order

LinkedHashMap
    ↓
Predictable encounter order

TreeMap
    ↓
Sorted key order
```

---

# 47. Collection vs Collections

Another classic interview question.

### Collection

`Collection` is an interface.

```java
Collection<String> data;
```

It is the root interface for most collection types.

### Collections

`Collections` is a utility class.

```java
Collections.sort(list);
Collections.reverse(list);
Collections.unmodifiableList(list);
```

So:

```text
Collection
    ↓
interface

Collections
    ↓
utility class
```

---

# 48. Collection vs Collectors

Another common confusion.

```text
Collection
    ↓
Data structure abstraction

Collections
    ↓
Utility methods

Collectors
    ↓
Java Stream terminal collection/reduction helpers
```

Example:

```java
List<String> result =
        names.stream()
             .filter(name -> name.startsWith("A"))
             .collect(Collectors.toList());
```

---

# 49. Fail-Fast Iterators

Many standard collection iterators are described as fail-fast.

Example:

```java
List<String> names = new ArrayList<>();

names.add("A");
names.add("B");
names.add("C");

for (String name : names) {

    if (name.equals("B")) {
        names.remove(name);
    }
}
```

This can result in:

```text
ConcurrentModificationException
```

The iterator detects structural modification outside the iterator's expected modification mechanism.

Correct approach:

```java
Iterator<String> iterator =
        names.iterator();

while (iterator.hasNext()) {

    String name = iterator.next();

    if (name.equals("B")) {
        iterator.remove();
    }
}
```

Important:

> Fail-fast is a best-effort bug-detection mechanism, not a concurrency guarantee.

---

# 50. Concurrent Collections

For concurrent applications, don't blindly synchronize a normal collection.

For example:

```java
List<String> list =
        Collections.synchronizedList(
                new ArrayList<>()
        );
```

This can be useful in some situations, but iteration still requires appropriate external synchronization according to the API contract.

For specialized workloads, consider:

```text
ConcurrentHashMap
ConcurrentLinkedQueue
CopyOnWriteArrayList
BlockingQueue
ConcurrentLinkedDeque
```

Choose based on the workload rather than simply asking:

> "Which collection is thread-safe?"

---

# 51. HashMap vs ConcurrentHashMap

| Feature | HashMap | ConcurrentHashMap |
|---|---|---|
| Thread-safe | No | Yes |
| Null key | Yes | No |
| Null value | Yes | No |
| Concurrent operations | Not safe | Designed for concurrency |
| Performance in single-threaded use | Usually simpler/faster | Concurrency overhead/design |
| Atomic methods | Basic map methods | `compute`, `merge`, `putIfAbsent`, etc. |

### Senior-level answer

Don't say:

> "ConcurrentHashMap is always faster."

Instead:

> "ConcurrentHashMap is designed for concurrent access and provides stronger concurrency semantics than HashMap. In a single-threaded use case, HashMap is generally the simpler and more appropriate choice."

---

# 52. HashSet vs TreeSet vs LinkedHashSet

This is one of the most important interview comparisons.

| Feature | HashSet | LinkedHashSet | TreeSet |
|---|---|---|---|
| Duplicate | No | No | No |
| Ordering | No guaranteed order | Encounter/insertion order | Sorted |
| Typical lookup | O(1) average | O(1) average | O(log n) |
| Internal structure | Hash table | Hash table + links | Red-Black tree |
| Range operations | No | No | Yes |
| Memory | Moderate | Higher | Higher |
| Use when | Uniqueness | Uniqueness + order | Uniqueness + sorting |

---

# 53. HashMap vs LinkedHashMap vs TreeMap

| Feature | HashMap | LinkedHashMap | TreeMap |
|---|---|---|---|
| Ordering | No guaranteed order | Encounter order | Sorted keys |
| `get()` average | O(1) | O(1) | O(log n) |
| `put()` average | O(1) | O(1) | O(log n) |
| Range queries | No | No | Yes |
| LRU support | No | Yes, with access order | No |
| Null key | Yes | Yes | Generally no with natural ordering |
| Typical use | General lookup | Ordered map/cache patterns | Sorted/range map |

---

# 54. ArrayList vs ArrayDeque

These solve different problems.

### ArrayList

Use when:

```text
I need a List
I need indexing
I need get(index)
```

Example:

```java
list.get(100);
```

### ArrayDeque

Use when:

```text
I need stack/queue/deque behavior
```

Example:

```java
deque.push(value);
deque.pop();
```

Don't use:

```java
ArrayList
```

as your default queue simply because it can technically add/remove elements.

Choose the abstraction that represents the actual requirement.

---

# 55. Why Program to Interface?

Prefer:

```java
List<Employee> employees =
        new ArrayList<>();
```

instead of:

```java
ArrayList<Employee> employees =
        new ArrayList<>();
```

Why?

The first code depends on the abstraction:

```text
List
```

and the implementation can later change:

```java
List<Employee> employees =
        new LinkedList<>();
```

without changing consumers that only require List behavior.

Similarly:

```java
Map<String, Employee> employees =
        new HashMap<>();
```

This supports:

- loose coupling
- easier refactoring
- dependency inversion
- cleaner APIs
- easier testing

---

# 56. But Don't Program to an Interface Blindly

This is an important 8+ years point.

If the code specifically requires implementation-specific behavior, the abstraction may need to expose it.

For example, if you require:

```java
NavigableMap<Integer, Employee>
```

because you need:

```java
floorKey()
ceilingKey()
subMap()
```

then:

```java
Map<Integer, Employee>
```

is too generic.

Use:

```java
NavigableMap<Integer, Employee>
```

The principle is:

> Depend on the **narrowest abstraction that provides the behavior you actually need**.

---

# 57. A Real Production Example

Suppose we are building an order-processing system.

### Requirement 1

Need orders by ID:

```java
Map<Long, Order> orders =
        new HashMap<>();
```

Reason:

```text
fast lookup
ordering not required
```

### Requirement 2

Need unique customer IDs:

```java
Set<Long> customerIds =
        new HashSet<>();
```

### Requirement 3

Need customers in insertion order:

```java
Set<Long> customerIds =
        new LinkedHashSet<>();
```

### Requirement 4

Need orders sorted by order ID:

```java
NavigableMap<Long, Order> orders =
        new TreeMap<>();
```

### Requirement 5

Need FIFO processing:

```java
Queue<Order> queue =
        new ArrayDeque<>();
```

### Requirement 6

Need priority-based processing:

```java
Queue<Order> queue =
        new PriorityQueue<>(comparator);
```

### Requirement 7

Multiple threads update counts:

```java
ConcurrentHashMap<String, Long> counts =
        new ConcurrentHashMap<>();
```

This is how a senior developer should approach collection selection:

```text
Requirement
    ↓
Ordering?
    ↓
Duplicates?
    ↓
Random access?
    ↓
Priority?
    ↓
Concurrency?
    ↓
Memory?
    ↓
Select implementation
```

---

# 58. Java 21 Sequenced Collection — Practical Selection

Suppose you need:

```text
unique elements
+
preserve encounter order
+
access first/last
+
reverse view
```

Instead of exposing a concrete implementation:

```java
LinkedHashSet<String>
```

you can express the requirement through:

```java
SequencedSet<String>
```

Example:

```java
SequencedSet<String> names =
        new LinkedHashSet<>();

names.add("John");
names.add("Mike");
names.add("Alex");

System.out.println(names.getFirst());
System.out.println(names.getLast());

System.out.println(names.reversed());
```

This is a more expressive API when your application requires sequenced-set semantics.

---

# 59. Important Java 21 Interview Question

### Q: What problem does SequencedCollection solve?

**Answer:**

> "It provides a common abstraction for collections with a defined encounter order. Before Java 21, APIs for first, last and reverse operations varied between collection types. Java 21 introduced SequencedCollection, SequencedSet and SequencedMap to standardize these operations."

---

# 60. Important Collection Interview Questions

## Q1. Is Map a Collection?

**Answer:**

No.

`Map` is a separate hierarchy because it stores key-value mappings rather than individual elements.

```text
Collection
    |
    +-- List
    +-- Set
    +-- Queue

Map
    |
    +-- HashMap
    +-- TreeMap
    +-- LinkedHashMap
```

---

## Q2. Why does HashSet use HashMap internally?

Because a Set needs to maintain unique elements.

A HashMap already provides:

```text
hashing
bucket management
key uniqueness
lookup
```

HashSet can use the element as the key and a dummy value as the map value.

---

## Q3. Why is HashMap lookup usually O(1)?

Because hashing maps a key to a bucket.

Conceptually:

```text
key
 ↓
hashCode()
 ↓
bucket
 ↓
entry
 ↓
equals()
 ↓
value
```

Under normal distribution, lookup is approximately constant time.

---

## Q4. Why can HashMap performance degrade?

Potential reasons include:

- poor hash distribution
- many collisions
- expensive `hashCode()`
- expensive `equals()`
- excessive resizing
- mutable keys

Modern implementations mitigate heavy collisions using tree structures in suitable buckets, but good key design is still important.

---

# 61. Q5. What happens if a HashMap key is mutable?

This is dangerous.

Example:

```java
class Employee {

    int id;

    Employee(int id) {
        this.id = id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Employee other)) {
            return false;
        }

        return id == other.id;
    }
}
```

Now:

```java
Employee e = new Employee(1);

Map<Employee, String> map = new HashMap<>();

map.put(e, "John");

e.id = 2;
```

The object's hash-related identity has changed after insertion.

A subsequent lookup can fail because the object may now be searched in a different bucket.

### Senior recommendation

Use immutable objects as map keys whenever practical.

---

# 62. Q6. Why does TreeSet say two objects are duplicates even though equals() returns false?

Because TreeSet uses ordering to determine uniqueness.

If:

```java
compareTo() == 0
```

or:

```java
Comparator.compare() == 0
```

TreeSet treats the elements as equivalent for its sorted-set purposes.

This can produce:

```text
equals() == false
compareTo() == 0
```

and the second object may not be added.

This is an important distinction between:

```text
HashSet
    equality/hashCode semantics

TreeSet
    ordering/comparison semantics
```

---

# 63. Q7. Why should compareTo not be implemented using subtraction?

Avoid:

```java
return this.id - other.id;
```

Because integer overflow can produce incorrect comparison results.

Prefer:

```java
return Integer.compare(this.id, other.id);
```

For long:

```java
return Long.compare(this.id, other.id);
```

This is a good senior-level coding practice.

---

# 64. Q8. ArrayList vs CopyOnWriteArrayList?

Use `ArrayList` when:

```text
normal single-threaded/non-concurrent use
```

Use `CopyOnWriteArrayList` when:

```text
many concurrent reads
very few writes
```

Example:

```text
Application listeners
configuration observers
event subscribers
```

Avoid it for write-heavy workloads because every mutation can copy the backing array.

---

# 65. Q9. Why is ArrayDeque preferred over Stack?

`Stack` is a legacy class that extends `Vector`.

For stack semantics, modern Java code generally prefers:

```java
Deque<T> stack = new ArrayDeque<>();
```

because `Deque` is a more general and modern abstraction.

---

# 66. Q10. HashMap vs ConcurrentHashMap?

Use `HashMap` when:

```text
No concurrent mutation/access requirement
```

Use `ConcurrentHashMap` when:

```text
Multiple threads access/update the map concurrently
```

Don't synchronize a map blindly. First understand the concurrency requirements.

---

# 67. Q11. Why doesn't ConcurrentHashMap allow null?

Because in concurrent APIs, `null` can make the meaning of lookup results ambiguous.

For example:

```java
map.get(key)
```

could mean:

```text
key doesn't exist
OR
key exists and value is null
```

ConcurrentHashMap avoids this ambiguity by disallowing null keys and values.

---

# 68. Q12. What is the difference between fail-fast and weakly consistent iteration?

A fail-fast iterator attempts to detect structural modification and may throw:

```text
ConcurrentModificationException
```

Concurrent collections such as `ConcurrentHashMap` provide weakly consistent iteration semantics rather than the same fail-fast behavior.

The iterator can proceed while the collection is concurrently modified, with behavior defined by the concurrent collection's contract.

---

# 69. Q13. What is the difference between Comparable and Comparator?

```text
Comparable
    ↓
natural ordering
    ↓
inside the class
    ↓
compareTo()

Comparator
    ↓
custom ordering
    ↓
outside the class
    ↓
compare()
```

Example:

```java
employees.sort(
    Comparator.comparing(Employee::getSalary)
);
```

This is particularly useful when the same object needs multiple sorting strategies.

---

# 70. Q14. Why would you use LinkedHashMap instead of HashMap?

When you need predictable encounter order.

For example:

```text
API response ordering
deterministic iteration
insertion-order processing
LRU-style implementation
```

For an access-order LRU-style structure:

```java
new LinkedHashMap<>(
    16,
    0.75f,
    true
);
```

The `true` enables access-order behavior.

---

# 71. Q15. When would you use TreeMap instead of HashMap?

When the application requires:

```text
sorted keys
range queries
nearest-key operations
floor/ceiling navigation
```

Example:

```java
map.floorKey(timestamp);
```

A HashMap doesn't provide this naturally.

---

# 72. Q16. When would you use WeakHashMap?

When the lifetime of an entry should be tied to the lifetime of its key through weak referencing.

Typical specialized use cases:

```text
metadata
object-associated auxiliary data
certain temporary caches
```

But for production caching, evaluate a dedicated cache solution when you need explicit policies such as:

```text
maximum size
TTL
refresh
metrics
eviction
```

---

# 73. Q17. What collection would you use for LRU cache?

A classic simple implementation is:

```java
Map<String, String> cache =
    new LinkedHashMap<>(16, 0.75f, true);
```

Then override:

```java
removeEldestEntry()
```

Example:

```java
class LruCache<K, V> extends LinkedHashMap<K, V> {

    private final int capacity;

    public LruCache(int capacity) {
        super(capacity, 0.75f, true);
        this.capacity = capacity;
    }

    @Override
    protected boolean removeEldestEntry(
            Map.Entry<K, V> eldest) {

        return size() > capacity;
    }
}
```

This is a classic interview implementation.

For production systems, however, consider whether a dedicated caching solution is more appropriate because production caches often require richer eviction, expiration, metrics and concurrency behavior.

---

# 74. Q18. Which collection would you choose for 1 million elements?

There is no universal answer.

A senior developer should ask:

```text
What operations?

Random access?
Lookup?
Ordering?
Sorting?
Duplicates?
Memory constraints?
Concurrent access?
Insertion/removal location?
Priority?
```

For example:

```text
Random access → ArrayList

Unique + fast lookup → HashSet

Key lookup → HashMap

Sorted keys → TreeMap

FIFO → ArrayDeque

Priority → PriorityQueue

Concurrent key lookup → ConcurrentHashMap
```

The number of elements alone does not determine the correct collection.

---

# 75. Q19. What is the difference between size and capacity in ArrayList?

Conceptually:

```text
size
    ↓
number of actual elements

capacity
    ↓
space currently available in backing array
```

Example:

```text
capacity = 10
size = 3
```

means:

```text
[ A ][ B ][ C ][ ][ ][ ][ ][ ][ ][ ]
  <---- size ---->
  <--------- capacity --------->
```

When capacity is insufficient, the backing array grows.

---

# 76. Q20. Why is ArrayList generally faster than LinkedList for iteration?

A major reason is memory locality.

`ArrayList` stores elements in an array-like contiguous structure:

```text
[A][B][C][D][E]
```

`LinkedList` stores separate nodes connected through references:

```text
[A] -> [B] -> [C] -> [D]
```

The linked structure can have worse CPU cache locality and additional object/reference overhead.

Therefore:

> The theoretical complexity alone does not determine real-world performance.

This is an important 8+ years interview point.

---

# 77. Collection Selection — Senior Mental Model

When an interviewer asks:

> "Which collection would you use?"

Don't immediately answer with a class.

Walk through this:

```text
                 What is the requirement?
                          |
            +-------------+-------------+
            |                           |
        Individual                   Key/Value
         elements                    mapping
            |                           |
       Collection                       Map
            |                           |
    +-------+-------+             +-----+------+
    |       |       |             |            |
   List    Set    Queue          Hash         Sorted
    |       |       |             |            |
 ArrayList |   ArrayDeque      HashMap      TreeMap
           |                   |
     +-----+-----+         LinkedHashMap
     |           |
  HashSet   LinkedHashSet
                |
             ordered
               
Sorted Set:
    TreeSet

Concurrent:
    ConcurrentHashMap
    ConcurrentLinkedQueue
    CopyOnWriteArrayList

Priority:
    PriorityQueue

Java 21 ordered abstraction:
    SequencedCollection
    SequencedSet
    SequencedMap
```

---

# 78. Most Important Collections to Memorize

For an 8+ years interview, prioritize these:

```text
List
 ├── ArrayList
 ├── LinkedList
 └── Vector / Stack (legacy)

Set
 ├── HashSet
 ├── LinkedHashSet
 └── TreeSet

Queue
 ├── PriorityQueue
 └── Deque
      └── ArrayDeque

Map
 ├── HashMap
 ├── LinkedHashMap
 ├── TreeMap
 ├── ConcurrentHashMap
 ├── WeakHashMap
 ├── IdentityHashMap
 └── EnumMap

Specialized
 ├── EnumSet
 ├── CopyOnWriteArrayList
 ├── CopyOnWriteArraySet
 └── BlockingQueue implementations

Java 21
 ├── SequencedCollection
 ├── SequencedSet
 └── SequencedMap
```

---

# 79. Final Interview Cheat Sheet

```text
ArrayList
→ Fast index access
→ Default List choice

LinkedList
→ Deque/List
→ Usually not preferred for general List use

HashSet
→ Unique + fast lookup
→ No ordering requirement

LinkedHashSet
→ Unique + encounter order

TreeSet
→ Unique + sorted + range/navigation operations

ArrayDeque
→ Stack + Queue + Deque
→ Preferred over Stack for modern code

PriorityQueue
→ Priority-based removal

HashMap
→ General key-value lookup

LinkedHashMap
→ Key-value + predictable encounter order
→ Can support LRU-style access ordering

TreeMap
→ Sorted keys + range/navigation

ConcurrentHashMap
→ Concurrent map access/update

EnumSet
→ Set of enum values

EnumMap
→ Map with enum keys

CopyOnWriteArrayList
→ Many reads + very few writes

WeakHashMap
→ Weak-key association

IdentityHashMap
→ Reference identity (`==`) semantics

SequencedCollection (Java 21)
→ Common ordered collection API

SequencedSet (Java 21)
→ Ordered + unique collection

SequencedMap (Java 21)
→ Ordered map + first/last/reverse operations
```

---

# 80. Best 8+ Years Interview Closing Answer

If the interviewer asks:

**"How do you decide which Java collection to use?"**

A strong answer is:

> "I don't choose a collection only based on familiarity. I first look at the access pattern and functional requirements: whether duplicates are allowed, whether encounter or sorted order is required, whether random access is important, whether I need priority or deque semantics, and whether the collection is accessed concurrently.
>
> For example, I normally start with ArrayList for a general-purpose List, HashSet for uniqueness without ordering, LinkedHashSet when encounter order matters, and TreeSet when I need sorted and navigable data. For maps, HashMap is my default for general lookup, LinkedHashMap when predictable encounter order is required, TreeMap for sorted or range-based operations, and ConcurrentHashMap when concurrent access is required.
>
> I also consider memory overhead, iteration performance, mutation frequency and the actual workload. For example, although LinkedList has O(1) node insertion once the position is known, ArrayList can perform better in many real applications because of contiguous storage and cache locality.
>
> With Java 21, I also consider the SequencedCollection, SequencedSet and SequencedMap abstractions when the API requires a defined encounter order and operations such as first, last and reversed views.
>
> So my decision is driven by the required semantics first, then complexity, memory characteristics, concurrency and maintainability."

---

# 81. One-Page Hierarchy to Memorize

```text
                         Iterable
                            |
                       Collection
                            |
          +-----------------+------------------+
          |                 |                  |
         List              Set               Queue
          |                 |                  |
    +-----+-----+      +----+----+        +----+----+
    |     |     |      |         |        |         |
ArrayList LinkedList Vector    HashSet  PriorityQueue Deque
                    |             |                   |
                  Stack      LinkedHashSet        ArrayDeque
                                  |
                             SortedSet
                                  |
                            NavigableSet
                                  |
                              TreeSet


                            Map
                             |
          +------------------+------------------+
          |                  |                  |
       HashMap         LinkedHashMap        SortedMap
                                               |
                                          NavigableMap
                                               |
                                            TreeMap

Other important Maps:
    ConcurrentHashMap
    WeakHashMap
    IdentityHashMap
    EnumMap


Java 21:
    SequencedCollection
         |
         +-- List
         +-- Deque
         +-- SequencedSet

    SequencedSet
         |
         +-- LinkedHashSet
         +-- SortedSet

    SequencedMap
         |
         +-- LinkedHashMap
         +-- SortedMap
```

> **Core interview rule:** Don't memorize only "which collection is faster." Memorize **what semantic requirement each collection provides**, then choose based on access pattern, ordering, uniqueness, concurrency, memory and operational behavior.