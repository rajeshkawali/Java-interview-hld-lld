# CompletableFuture in Java

## 1. What is CompletableFuture?

`CompletableFuture` is a Java class used to perform **asynchronous operations** and then process their results when they are available.

It was introduced in **Java 8**.

It implements:

```java
Future<T>
CompletionStage<T>
```

The main advantage is that we can **start a task asynchronously and build a chain of operations without blocking the current thread**.

### Simple example

```java
CompletableFuture<String> future =
        CompletableFuture.supplyAsync(() -> "Hello");

future.thenApply(result -> result + " Java")
      .thenAccept(System.out::println);
```

Output:

```text
Hello Java
```

The important idea is:

```text
Start task
   ↓
Task completes
   ↓
Process result
   ↓
Process next result
```

---

# 2. Why do we need CompletableFuture?

Before `CompletableFuture`, we commonly used `Thread`, `ExecutorService`, and `Future`.

For example:

```java
ExecutorService executor = Executors.newFixedThreadPool(5);

Future<String> future =
        executor.submit(() -> getCustomer());

String customer = future.get();
```

The problem is:

```java
future.get();
```

is blocking.

The current thread waits until the task finishes.

With `CompletableFuture`:

```java
CompletableFuture
    .supplyAsync(() -> getCustomer())
    .thenApply(customer -> getOrders(customer))
    .thenAccept(orders -> processOrders(orders));
```

We can create an **asynchronous pipeline**.

---

# 3. Main benefits of CompletableFuture

The important benefits are:

### 1. Asynchronous execution

Task can execute in another thread.

### 2. Non-blocking composition

We can say:

```text
When A completes → do B
When B completes → do C
```

without calling `get()` after every operation.

### 3. Combine independent tasks

For example:

```text
Get Customer ──────┐
                   ├──> Build Response
Get Product ───────┘
```

### 4. Chain dependent tasks

```text
Get Customer
     ↓
Get Customer Orders
     ↓
Calculate Total
```

### 5. Exception handling

We can handle failures using:

```java
exceptionally()
handle()
whenComplete()
```

### 6. Timeout support

Modern Java provides:

```java
orTimeout()
completeOnTimeout()
```

---

# 4. Future vs CompletableFuture

| Feature | Future | CompletableFuture |
|---|---|---|
| Async task | Yes | Yes |
| Get result | `get()` | `get()`, `join()` |
| Non-blocking pipeline | Limited | Yes |
| Chain operations | Difficult | Easy |
| Combine tasks | Difficult | Easy |
| Exception handling | Limited | Built-in |
| Timeout support | Limited | Yes |
| Dependent async calls | Difficult | `thenCompose()` |
| Independent calls | Difficult | `thenCombine()` |
| Manual completion | No | Yes |

### Simple interview explanation

> `Future` gives me a handle to an asynchronous result, but `CompletableFuture` allows me to build and combine asynchronous operations.

---

# 5. Creating a CompletableFuture

There are two commonly used methods.

## `supplyAsync()`

Use it when the task **returns a value**.

```java
CompletableFuture<String> future =
        CompletableFuture.supplyAsync(() -> "Hello");
```

The lambda returns:

```java
"Hello"
```

Therefore:

```java
CompletableFuture<String>
```

---

## `runAsync()`

Use it when the task **does not return a value**.

```java
CompletableFuture<Void> future =
        CompletableFuture.runAsync(() -> {
            System.out.println("Processing...");
        });
```

Use:

```text
supplyAsync → result required
runAsync    → no result
```

---

# 6. `completedFuture()`

Creates an already completed future.

```java
CompletableFuture<String> future =
        CompletableFuture.completedFuture("Success");
```

Useful when you already have the result but your method needs to return a `CompletableFuture`.

Example:

```java
CompletableFuture<String> getName(boolean cacheHit) {

    if (cacheHit) {
        return CompletableFuture.completedFuture("John");
    }

    return CompletableFuture.supplyAsync(() -> loadFromDatabase());
}
```

---

# 7. `thenApply()`

`thenApply()` is used to **transform the result**.

Think of it as:

```text
T → U
```

Example:

```java
CompletableFuture<String> future =
        CompletableFuture.supplyAsync(() -> "john");

CompletableFuture<String> result =
        future.thenApply(name -> name.toUpperCase());
```

Flow:

```text
"john"
   ↓
toUpperCase()
   ↓
"JOHN"
```

### When to use?

Use `thenApply()` when:

> I have a result and want to transform it.

Example:

```java
future.thenApply(customer -> customer.getName());
```

---

# 8. `thenAccept()`

Use `thenAccept()` when you want to **consume the result** but don't need to return another result.

```java
CompletableFuture
    .supplyAsync(() -> getCustomer())
    .thenAccept(customer -> {
        System.out.println(customer.getName());
    });
```

Return type:

```java
CompletableFuture<Void>
```

Think:

```text
thenApply  → transform
thenAccept → consume
```

---

# 9. `thenRun()`

Use `thenRun()` when you don't need the previous result.

```java
CompletableFuture
    .supplyAsync(() -> getCustomer())
    .thenRun(() -> {
        System.out.println("Customer processing completed");
    });
```

Difference:

```text
thenApply  → needs result + returns result
thenAccept → needs result + returns nothing
thenRun    → doesn't need result + returns nothing
```

---

# 10. `thenApply()` vs `thenApplyAsync()`

This is an important interview question.

### `thenApply()`

```java
future.thenApply(value -> process(value));
```

The continuation may execute in the thread that completes the previous stage.

### `thenApplyAsync()`

```java
future.thenApplyAsync(value -> process(value));
```

The continuation is scheduled asynchronously.

You can also specify an executor:

```java
future.thenApplyAsync(
    value -> process(value),
    executor
);
```

### Important

Don't assume every CompletableFuture operation automatically creates a new thread.

Also:

> Async does not automatically mean "a new thread".

The executor decides where the asynchronous work runs.

---

# 11. Default Executor

If you write:

```java
CompletableFuture.supplyAsync(() -> task());
```

without providing an executor, Java normally uses:

```text
ForkJoinPool.commonPool()
```

Similarly:

```java
thenApplyAsync(...)
thenAcceptAsync(...)
thenRunAsync(...)
```

without an executor normally use the common pool.

### Production recommendation

For blocking I/O operations such as:

```text
Database
REST API
File system
External service
```

consider using a dedicated executor instead of putting blocking work on the common pool.

Example:

```java
ExecutorService ioExecutor =
        Executors.newFixedThreadPool(20);

CompletableFuture.supplyAsync(
        () -> callDatabase(),
        ioExecutor
);
```

---

# 12. `thenCompose()`

This is one of the **most important CompletableFuture methods**.

Use `thenCompose()` when the **second asynchronous operation depends on the first result**.

Suppose:

```java
getCustomer()
```

returns:

```java
CompletableFuture<Customer>
```

Then:

```java
getOrders(customerId)
```

returns:

```java
CompletableFuture<List<Order>>
```

We can write:

```java
CompletableFuture<List<Order>> orders =
    getCustomer()
        .thenCompose(customer ->
            getOrders(customer.getId())
        );
```

Flow:

```text
getCustomer()
      ↓
Customer
      ↓
getOrders(customerId)
      ↓
Orders
```

### Why not `thenApply()`?

If we use:

```java
thenApply(customer -> getOrders(customer.getId()))
```

we get:

```java
CompletableFuture<CompletableFuture<List<Order>>>
```

That is a nested future.

`thenCompose()` **flattens** it.

### Easy way to remember

```text
thenApply   → normal transformation
thenCompose → dependent async operation
```

---

# 13. `thenCombine()`

Use `thenCombine()` when **two CompletableFutures are independent** and we need both results.

Example:

```java
CompletableFuture<Customer> customer =
        getCustomer();

CompletableFuture<Account> account =
        getAccount();

CompletableFuture<CustomerView> result =
        customer.thenCombine(
            account,
            (c, a) -> new CustomerView(c, a)
        );
```

Flow:

```text
Get Customer ──────┐
                   ├──> CustomerView
Get Account ───────┘
```

Both operations can run independently.

### Difference

```text
thenCompose  → B depends on A
thenCombine  → A and B are independent
```

---

# 14. `thenAcceptBoth()`

Similar to `thenCombine()`, but doesn't return a new result.

```java
customer.thenAcceptBoth(
    account,
    (c, a) -> {
        System.out.println(c);
        System.out.println(a);
    }
);
```

Use it when:

> I need both results, but don't need to create another result.

---

# 15. `runAfterBoth()`

Runs an action after both futures complete.

```java
customer.runAfterBoth(
    account,
    () -> System.out.println("Both completed")
);
```

It doesn't need either result.

---

# 16. `allOf()`

Use `allOf()` when you have **multiple independent futures** and want to wait until all are complete.

Example:

```java
CompletableFuture<String> f1 =
        CompletableFuture.supplyAsync(() -> "A");

CompletableFuture<String> f2 =
        CompletableFuture.supplyAsync(() -> "B");

CompletableFuture<String> f3 =
        CompletableFuture.supplyAsync(() -> "C");

CompletableFuture<Void> all =
        CompletableFuture.allOf(f1, f2, f3);
```

Flow:

```text
F1 ────┐
F2 ────┼──> all completed
F3 ────┘
```

### Important interview point

`allOf()` returns:

```java
CompletableFuture<Void>
```

It does **not** directly return:

```java
List<String>
```

If we need the results:

```java
CompletableFuture<List<String>> result =
    CompletableFuture.allOf(f1, f2, f3)
        .thenApply(v -> List.of(
            f1.join(),
            f2.join(),
            f3.join()
        ));
```

---

# 17. `anyOf()`

`anyOf()` completes when **the first future completes**.

```java
CompletableFuture<Object> result =
        CompletableFuture.anyOf(f1, f2, f3);
```

Flow:

```text
F1 ────────┐
F2 ──X─────┼──> First completed result
F3 ────────┘
```

Useful for scenarios such as:

```text
Call Server A
Call Server B
Call Server C

Use whichever responds first.
```

### Important

`anyOf()` returns:

```java
CompletableFuture<Object>
```

because the futures may have different result types.

---

# 18. `applyToEither()`

Similar to `anyOf()`, but type-safe when working with two stages of the same result type.

```java
f1.applyToEither(
    f2,
    value -> process(value)
);
```

Meaning:

> Whichever completes first, process its result.

---

# 19. Exception Handling

CompletableFuture provides several ways to handle errors.

The three most important are:

```text
exceptionally()
handle()
whenComplete()
```

---

# 20. `exceptionally()`

Used to provide a **fallback value when something fails**.

```java
CompletableFuture<String> result =
    CompletableFuture
        .supplyAsync(() -> {
            throw new RuntimeException("DB error");
        })
        .exceptionally(ex -> "Default Value");
```

Result:

```text
Default Value
```

Think:

```text
Success → normal result
Failure → fallback result
```

---

# 21. `handle()`

`handle()` receives both:

```text
result
exception
```

Example:

```java
CompletableFuture<String> result =
    future.handle((value, ex) -> {

        if (ex != null) {
            return "Fallback";
        }

        return value;
    });
```

Use `handle()` when:

> I want to process both success and failure.

---

# 22. `whenComplete()`

Used mainly for **logging, metrics, cleanup, auditing**, etc.

```java
future.whenComplete((result, ex) -> {

    if (ex != null) {
        System.out.println("Failed: " + ex);
    } else {
        System.out.println("Success: " + result);
    }
});
```

It normally doesn't transform the result.

### Easy difference

```text
exceptionally → recover from error
handle        → transform success/failure
whenComplete  → observe/log/cleanup
```

---

# 23. Exception flow

Suppose:

```java
CompletableFuture
    .supplyAsync(() -> callService())
    .thenApply(result -> process(result))
    .thenApply(result -> save(result))
    .exceptionally(ex -> fallback());
```

If:

```text
callService()
```

fails:

```text
callService()
      ↓
   FAILURE
      ↓
process() skipped
      ↓
save() skipped
      ↓
exceptionally()
      ↓
fallback()
```

This is one of the main advantages of CompletableFuture: **failure can flow through the pipeline until it is handled.**

---

# 24. `join()` vs `get()`

Both wait for the result.

### `get()`

```java
String result = future.get();
```

Uses checked exceptions such as:

```text
InterruptedException
ExecutionException
TimeoutException
```

### `join()`

```java
String result = future.join();
```

Does not require checked exception handling.

If the future fails, `join()` typically throws:

```java
CompletionException
```

### Practical preference

Inside CompletableFuture pipelines, avoid repeatedly doing:

```java
future.get();
```

or:

```java
future.join();
```

because that introduces blocking.

Using `join()` at the **final application boundary** can be reasonable when the API itself must return a synchronous result.

---

# 25. `getNow()`

Returns the result immediately if already available.

```java
String result = future.getNow("Default");
```

If the future isn't completed, it returns the supplied default value.

It does not wait for completion.

---

# 26. Timeout handling

Modern Java provides two useful methods.

## `orTimeout()`

If the future doesn't complete within the specified time, it completes exceptionally with a timeout.

```java
future.orTimeout(
    2,
    TimeUnit.SECONDS
);
```

Conceptually:

```text
Task
 ↓
2 seconds
 ↓
Not completed
 ↓
TimeoutException
```

---

## `completeOnTimeout()`

Instead of failing, provide a fallback value.

```java
future.completeOnTimeout(
    "Default",
    2,
    TimeUnit.SECONDS
);
```

Conceptually:

```text
Task
 ↓
2 seconds
 ↓
Not completed
 ↓
"Default"
```

### Difference

```text
orTimeout()
       → failure

completeOnTimeout()
       → fallback value
```

---

# 27. `delayedExecutor()`

Allows execution to be delayed.

```java
Executor executor =
    CompletableFuture.delayedExecutor(
        2,
        TimeUnit.SECONDS
    );
```

Then:

```java
CompletableFuture.runAsync(
    () -> System.out.println("Executed later"),
    executor
);
```

Useful for simple delayed execution.

It is not a replacement for a full scheduling framework.

---

# 28. Manual completion

Normally the task completes itself.

But we can manually complete a future.

```java
CompletableFuture<String> future =
        new CompletableFuture<>();

future.complete("Success");
```

Now:

```java
future.join();
```

returns:

```text
Success
```

---

# 29. `completeExceptionally()`

We can manually complete a future with an error.

```java
CompletableFuture<String> future =
        new CompletableFuture<>();

future.completeExceptionally(
    new RuntimeException("Something failed")
);
```

The future is now completed exceptionally.

---

# 30. `cancel()`

A CompletableFuture can be cancelled:

```java
future.cancel(true);
```

After cancellation, waiting for its result can throw:

```java
CancellationException
```

Important:

> Cancellation of a CompletableFuture does not mean you should assume every underlying operation has been forcibly interrupted.

The actual interruption/cancellation behavior depends on how the underlying task is implemented.

---

# 31. `failedFuture()`

Useful when you want to return an already failed future.

```java
return CompletableFuture.failedFuture(
    new RuntimeException("Service unavailable")
);
```

This is useful in methods that return:

```java
CompletableFuture<T>
```

---

# 32. Important method cheat sheet

| Method | Purpose |
|---|---|
| `supplyAsync()` | Run async task and return result |
| `runAsync()` | Run async task without result |
| `completedFuture()` | Already successful future |
| `failedFuture()` | Already failed future |
| `thenApply()` | Transform result |
| `thenAccept()` | Consume result |
| `thenRun()` | Run action without result |
| `thenCompose()` | Chain dependent async operations |
| `thenCombine()` | Combine two independent futures |
| `thenAcceptBoth()` | Consume two results |
| `runAfterBoth()` | Run after both complete |
| `applyToEither()` | Use first completed result |
| `acceptEither()` | Consume first completed result |
| `allOf()` | Wait for all futures |
| `anyOf()` | Wait for first completed future |
| `exceptionally()` | Recover from failure |
| `handle()` | Handle success/failure |
| `whenComplete()` | Observe completion |
| `orTimeout()` | Fail on timeout |
| `completeOnTimeout()` | Return fallback on timeout |
| `delayedExecutor()` | Delay execution |
| `complete()` | Manually complete |
| `completeExceptionally()` | Manually fail |
| `cancel()` | Cancel future |
| `join()` | Get result without checked exceptions |
| `get()` | Get result with checked exceptions |
| `getNow()` | Get immediately or default |

---

# 33. Real-world example: E-commerce API

Suppose an Order Details API needs:

```text
Customer information
Inventory information
Price information
```

These calls are independent.

Instead of:

```text
Customer API → wait
                 ↓
Inventory API → wait
                 ↓
Price API → wait
```

we can execute them concurrently:

```text
             ┌── Customer API ──┐
Request ─────┼── Inventory API ──┼──> Build response
             └── Price API ─────┘
```

Example:

```java
ExecutorService ioPool =
        Executors.newFixedThreadPool(20);

CompletableFuture<Customer> customer =
    CompletableFuture.supplyAsync(
        () -> customerService.getCustomer(id),
        ioPool
    );

CompletableFuture<Inventory> inventory =
    CompletableFuture.supplyAsync(
        () -> inventoryService.getInventory(id),
        ioPool
    );

CompletableFuture<Price> price =
    CompletableFuture.supplyAsync(
        () -> priceService.getPrice(id),
        ioPool
    );

CompletableFuture<OrderView> result =
    customer
        .thenCombine(inventory,
            (c, i) -> new PartialOrderView(c, i))
        .thenCombine(price,
            (partial, p) -> buildOrderView(partial, p))
        .orTimeout(2, TimeUnit.SECONDS)
        .exceptionally(ex -> fallbackOrderView(id));

OrderView response = result.join();
```

### Why is this useful?

Suppose:

```text
Customer API   = 300 ms
Inventory API  = 500 ms
Price API      = 400 ms
```

Sequential execution is approximately:

```text
300 + 500 + 400 = 1200 ms
```

If the calls are independent and run concurrently, total time can be closer to:

```text
max(300, 500, 400) = 500 ms
```

plus overhead.

This is the main performance benefit of parallelizing **independent I/O operations**.

---

# 34. Another real-world example: dependent API calls

Suppose:

```text
Get User
   ↓
Get User Orders
   ↓
Get Order Details
```

Here each call depends on the previous result.

Use `thenCompose()`:

```java
getUser(userId)
    .thenCompose(user ->
        getOrders(user.getId())
    )
    .thenCompose(orders ->
        getOrderDetails(orders.get(0).getId())
    )
    .thenAccept(details ->
        System.out.println(details)
    );
```

This is a classic `thenCompose()` use case.

---

# 35. CompletableFuture vs ExecutorService

They solve different problems.

### ExecutorService

Main responsibility:

> Manage threads and execute tasks.

```java
ExecutorService executor =
        Executors.newFixedThreadPool(10);

executor.submit(() -> task());
```

### CompletableFuture

Main responsibility:

> Represent an asynchronous result and compose dependent/independent operations.

```java
CompletableFuture
    .supplyAsync(() -> task(), executor)
    .thenApply(result -> process(result))
    .thenAccept(result -> save(result));
```

In real applications, they are often used **together**.

---

# 36. CompletableFuture vs Thread

Don't think of CompletableFuture as a replacement for `Thread`.

A `Thread` is a lower-level execution mechanism.

```java
new Thread(() -> task()).start();
```

It doesn't naturally provide:

```text
result chaining
combining
exception pipeline
timeouts
fan-out/fan-in
```

CompletableFuture gives us those higher-level capabilities.

---

# 37. CompletableFuture vs Parallel Stream

Parallel streams are useful mainly for **data-parallel operations**.

Example:

```java
orders.parallelStream()
      .filter(...)
      .map(...)
      .toList();
```

CompletableFuture is more suitable for workflows such as:

```text
Call Customer Service
        ↓
Call Order Service
        ↓
Combine results
        ↓
Call Payment Service
        ↓
Handle timeout
        ↓
Return response
```

So:

```text
Parallel Stream → process a collection in parallel

CompletableFuture → compose asynchronous workflows
```

---

# 38. CompletableFuture vs Virtual Threads

Java 21 introduced virtual threads.

For straightforward blocking I/O:

```java
executor.submit(() -> databaseCall());
```

with virtual threads can be much simpler than creating a complex CompletableFuture chain.

But CompletableFuture is still useful when you need to express:

```text
A and B in parallel
       ↓
combine
       ↓
C
       ↓
timeout
       ↓
fallback
```

### Simple rule

```text
Simple blocking workflow → Virtual Threads can be a great choice

Complex async composition → CompletableFuture is very useful
```

They are not mutually exclusive.

---

# 39. Common mistakes

## Mistake 1: Blocking after every operation

Bad:

```java
String a = futureA.join();
String b = futureB.join();
String c = futureC.join();
```

This can remove much of the benefit of asynchronous composition.

Prefer:

```java
futureA.thenCombine(futureB, ...)
       .thenCombine(futureC, ...);
```

---

## Mistake 2: Blocking I/O on common pool

Avoid putting many blocking database/HTTP operations on:

```java
ForkJoinPool.commonPool()
```

Use a suitable dedicated executor when appropriate.

---

## Mistake 3: Confusing `thenApply()` and `thenCompose()`

Remember:

```text
thenApply  → result transformation

thenCompose → another async operation
```

---

## Mistake 4: Confusing `thenCombine()` and `thenCompose()`

```text
thenCompose
A → B
B depends on A

thenCombine
A ──┐
    ├──> C
B ──┘
A and B are independent
```

---

## Mistake 5: Swallowing exceptions

Avoid:

```java
.exceptionally(ex -> null);
```

unless `null` is genuinely a valid business result.

It can hide production problems.

---

## Mistake 6: Creating unlimited async tasks

Just because CompletableFuture makes it easy to create tasks doesn't mean we should create thousands of concurrent database/API calls.

Control concurrency using:

```text
bounded executors
connection pools
rate limits
backpressure
```

---

# 40. Important interview questions

### Q1. What is CompletableFuture?

> `CompletableFuture` is an implementation of `Future` and `CompletionStage` used to build asynchronous, composable workflows. It supports chaining, combining, exception handling, and timeout handling.

### Q2. `thenApply()` vs `thenCompose()`?

> `thenApply()` transforms a result. `thenCompose()` is used when the next operation is itself asynchronous and returns another CompletableFuture.

### Q3. `thenCompose()` vs `thenCombine()`?

> `thenCompose()` is for dependent operations. `thenCombine()` is for independent operations whose results need to be combined.

### Q4. `exceptionally()` vs `handle()`?

> `exceptionally()` is mainly for recovery from failure. `handle()` receives both the result and exception and can transform either outcome.

### Q5. `handle()` vs `whenComplete()`?

> `handle()` can transform the result. `whenComplete()` is mainly for observing completion, logging, metrics, or cleanup.

### Q6. `allOf()` vs `anyOf()`?

> `allOf()` completes after all futures complete. `anyOf()` completes when the first future completes.

### Q7. Does CompletableFuture always create a new thread?

> No. Non-async methods may execute in the thread completing the previous stage. Async methods use an executor; without one, they normally use the common ForkJoinPool.

### Q8. Why provide a custom Executor?

> To control concurrency and isolate workloads, especially blocking I/O, instead of putting them on the common pool.

---

# 41. One important concept: Async does not mean automatically faster

This is important for senior interviews.

Suppose:

```java
CompletableFuture.supplyAsync(() -> calculateSomething());
```

Using CompletableFuture doesn't automatically make the calculation faster.

If the task is CPU-heavy and there are already enough CPU tasks running, adding more async tasks can actually hurt performance.

The benefit depends on the workload.

### Good use case

Independent I/O:

```text
Database
REST API
External services
File operations
```

because while one operation is waiting, other work can progress.

### Less useful

Very small synchronous operations:

```java
int x = 10 + 20;
```

There is no reason to make this asynchronous.

---

# 42. Senior-level mental model

Think of CompletableFuture as a **pipeline of stages**.

Example:

```text
             ┌── Customer ──┐
Request ─────┼── Inventory ──┼──> Combine
             └── Price ─────┘
                            ↓
                         Process
                            ↓
                         Timeout
                            ↓
                         Fallback
                            ↓
                         Response
```

Each stage represents an asynchronous computation.

The key design question is:

> **Are these operations independent or dependent?**

If dependent:

```java
thenCompose()
```

If independent:

```java
thenCombine()
allOf()
```

If only transforming:

```java
thenApply()
```

If consuming:

```java
thenAccept()
```

If recovering:

```java
exceptionally()
```

If handling both:

```java
handle()
```

If observing:

```java
whenComplete()
```

---

# 43. Most important methods to remember

For interviews, remember these first:

```text
Creation
---------
supplyAsync()
runAsync()

Transformation
--------------
thenApply()

Dependent async
---------------
thenCompose()

Independent async
-----------------
thenCombine()
allOf()
anyOf()

Consume
-------
thenAccept()
thenRun()

Error
-----
exceptionally()
handle()
whenComplete()

Timeout
-------
orTimeout()
completeOnTimeout()

Result
------
join()
get()
```

---

# 44. Short interview answer

If an interviewer asks:

**"Why do you use CompletableFuture?"**

A strong answer is:

> "I use CompletableFuture when I have asynchronous operations that need to be composed. Unlike Future, it allows me to build non-blocking pipelines, combine independent operations using `thenCombine()` or `allOf()`, chain dependent operations using `thenCompose()`, and handle failures and timeouts using methods such as `exceptionally()`, `handle()`, and `orTimeout()`. In production, I also pay attention to the executor being used, especially for blocking I/O, and usually prefer a dedicated bounded executor instead of relying on the common pool."

---

# 45. Final cheat sheet

```text
Need async task with result?
        ↓
supplyAsync()

Need async task without result?
        ↓
runAsync()

Need to transform result?
        ↓
thenApply()

Need another async call based on result?
        ↓
thenCompose()

Need to combine independent futures?
        ↓
thenCombine()

Need to wait for many?
        ↓
allOf()

Need first completed?
        ↓
anyOf()

Need fallback on error?
        ↓
exceptionally()

Need success + failure handling?
        ↓
handle()

Need logging/metrics/cleanup?
        ↓
whenComplete()

Need timeout failure?
        ↓
orTimeout()

Need timeout fallback?
        ↓
completeOnTimeout()

Need final result?
        ↓
join() / get()
```

## One-line memory trick

```text
Apply   = Transform
Compose = Chain async
Combine = Join independent
Accept  = Consume
Run     = Execute side effect
AllOf   = Wait for all
AnyOf   = First one
Exceptionally = Recover
Handle  = Success + Failure
WhenComplete = Observe
```