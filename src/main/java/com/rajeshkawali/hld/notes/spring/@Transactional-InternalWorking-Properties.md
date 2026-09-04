# `@Transactional` in Spring Boot — Interview Preparation Notes

### Explanation

#### 1. Definition & Purpose

`@Transactional` is a Spring annotation used to define a **transaction boundary declaratively** around a method or class. It tells Spring that the annotated operation should execute within a database transaction, so multiple database operations can succeed or fail as a single unit.

Without `@Transactional`, developers often have to manually begin, commit, and roll back transactions. Spring handles this automatically through **AOP proxies** and a `PlatformTransactionManager`. If the method completes successfully, Spring normally commits the transaction; if an applicable exception occurs, Spring rolls it back.

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder(Order order) {
        orderRepository.save(order);
        paymentService.processPayment(order);
        inventoryService.reduceStock(order);
    }
}
```

If `processPayment()` or another operation causes a rollback-triggering exception, the transaction can be rolled back so the database does not remain in a partially updated state.

---

#### 2. How `@Transactional` Works Internally

Spring generally implements `@Transactional` using **AOP proxies**. When another Spring bean calls a transactional method, the call goes through the proxy rather than directly to the target object. The proxy delegates transaction handling to Spring's transaction infrastructure before and after invoking the actual method.

Conceptually, the flow is:

1. Client calls the proxied service.
2. Proxy intercepts the method call.
3. `TransactionInterceptor` examines the `@Transactional` metadata.
4. It asks the configured `PlatformTransactionManager` to start/join/suspend a transaction according to the propagation rules.
5. Target method executes.
6. On success, the transaction manager commits.
7. On a rollback-triggering exception, it rolls back.

The transaction context is commonly associated with the **current thread** using Spring's transaction synchronization infrastructure. This allows participating resources, such as a JDBC connection, to be associated with the current transaction. Consequently, simply starting another thread does **not** automatically transfer the transaction context to that thread.

---

#### 3. Rollback Rules

By default, Spring rolls back a transaction for **unchecked exceptions** (`RuntimeException`) and `Error`, but not for ordinary checked exceptions.

```java
@Transactional
public void process() throws IOException {
    repository.save(data);

    if (someCondition) {
        throw new IOException("File processing failed");
    }
}
```

The `IOException` above does **not** cause a rollback by default. To explicitly roll back for a checked exception, use `rollbackFor`:

```java
@Transactional(rollbackFor = IOException.class)
public void process() throws IOException {
    repository.save(data);
    throw new IOException("Failure");
}
```

You can also explicitly prevent rollback for an exception using `noRollbackFor`.

> **Interview point:** `@Transactional` does not magically roll back for every exception. Always remember the default rule: **unchecked exceptions and `Error` → rollback; checked exceptions → normally no rollback.**

---

#### 4. Self-Invocation Problem

A common interview question is:

> Why doesn't `@Transactional` always work when one method in the same class calls another transactional method?

Because Spring's transaction interceptor normally operates through the **proxy**.

```java
@Service
public class OrderService {

    public void outerMethod() {
        innerMethod();   // direct call; proxy is bypassed
    }

    @Transactional
    public void innerMethod() {
        // Transaction may NOT be started here
    }
}
```

`outerMethod()` is calling `innerMethod()` directly on `this`, rather than through the Spring proxy. Therefore, the transactional interceptor is bypassed.

A common solution is to move the transactional operation into another Spring bean:

```java
@Service
public class OrderService {

    private final TransactionalOrderService transactionalOrderService;

    public OrderService(TransactionalOrderService transactionalOrderService) {
        this.transactionalOrderService = transactionalOrderService;
    }

    public void outerMethod() {
        transactionalOrderService.innerMethod();
    }
}

@Service
public class TransactionalOrderService {

    @Transactional
    public void innerMethod() {
        // Transaction is intercepted through the proxy
    }
}
```

---

#### 5. `@Transactional` and `@Async`

Transactions are normally associated with the executing thread. `@Async`, on the other hand, executes work on a different thread.

```java
@Transactional
public void saveOrder() {
    orderRepository.save(order);
    notificationService.sendAsync(); // different thread
}
```

The asynchronous operation should **not be assumed to inherit the caller's transaction**. It can execute after the original transaction has committed or rolled back.

If asynchronous work requires its own transaction, define the transaction on the asynchronous method:

```java
@Async
@Transactional
public void sendNotification() {
    notificationRepository.save(notification);
}
```

This creates a transaction for the asynchronous operation itself; it does not make it part of the caller's original transaction.

---

### Properties

The most important `@Transactional` attributes are:

| Property             | Purpose                                                           |
| -------------------- | ----------------------------------------------------------------- |
| `propagation`        | Determines how the method participates in an existing transaction |
| `isolation`          | Controls visibility/concurrency behavior of database transactions |
| `timeout`            | Maximum transaction duration before timeout                       |
| `readOnly`           | Indicates that the transaction is intended for read-only work     |
| `rollbackFor`        | Exceptions that should trigger rollback                           |
| `noRollbackFor`      | Exceptions that should not trigger rollback                       |
| `transactionManager` | Selects a particular transaction manager                          |
| `label`              | Adds descriptive labels to a transaction                          |

---

#### Propagation

Propagation defines what should happen when a transactional method is called while another transaction already exists.

| Propagation     | Behavior                                                              |
| --------------- | --------------------------------------------------------------------- |
| `REQUIRED`      | Join existing transaction; otherwise create one                       |
| `REQUIRES_NEW`  | Always create a new transaction; suspend existing one                 |
| `SUPPORTS`      | Use existing transaction if one exists; otherwise execute without one |
| `MANDATORY`     | Must have an existing transaction; otherwise fail                     |
| `NOT_SUPPORTED` | Execute without a transaction; suspend existing transaction           |
| `NEVER`         | Must execute without a transaction; fail if one exists                |
| `NESTED`        | Execute within a nested transaction/savepoint when supported          |

**`REQUIRED`** is the default and is suitable for most service-layer operations.

```java
@Transactional(propagation = Propagation.REQUIRED)
public void createOrder() {
    // Join current transaction or create a new one
}
```

**`REQUIRES_NEW`** suspends the existing transaction and starts an independent transaction.

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void saveAuditLog() {
    auditRepository.save(...);
}
```

This is useful when an audit/logging operation must commit independently of the outer business transaction.

---

#### Isolation

Isolation controls how concurrent transactions interact with database data.

| Isolation          | General meaning                                  |
| ------------------ | ------------------------------------------------ |
| `DEFAULT`          | Use database/default transaction isolation       |
| `READ_UNCOMMITTED` | Allows dirty reads                               |
| `READ_COMMITTED`   | Prevents dirty reads                             |
| `REPEATABLE_READ`  | Provides stronger consistency for repeated reads |
| `SERIALIZABLE`     | Strongest standard isolation; lowest concurrency |

Example:

```java
@Transactional(isolation = Isolation.REPEATABLE_READ)
public void processOrder() {
    // Business logic
}
```

Higher isolation generally provides stronger consistency but can increase locking/contention and reduce concurrency. The exact behavior also depends on the database engine.

---

#### Timeout

`timeout` specifies how long a transaction is allowed to run before it is considered timed out.

```java
@Transactional(timeout = 30)
public void processLargeOrder() {
    // Transaction has a 30-second timeout
}
```

Timeouts are particularly useful for preventing unexpectedly long-running transactions from holding database resources indefinitely.

---

#### `readOnly`

```java
@Transactional(readOnly = true)
public List<Order> findOrders() {
    return orderRepository.findAll();
}
```

`readOnly = true` expresses that the transaction is intended for reading rather than modification.

It can allow Spring/JPA/database integrations to optimize certain operations, but it is **not a universal guarantee that writes are impossible**. Its exact effect depends on the transaction manager and persistence technology.

Use it for genuinely read-oriented operations, but don't blindly apply it everywhere because incorrect assumptions about read-only behavior can lead to unexpected behavior or missed optimizations.

---

#### `rollbackFor` and `noRollbackFor`

```java
@Transactional(rollbackFor = BusinessException.class)
public void processPayment() throws BusinessException {
    // Roll back for BusinessException
}
```

You can also specify multiple exceptions:

```java
@Transactional(
    rollbackFor = {
        IOException.class,
        BusinessException.class
    }
)
public void process() throws Exception {
    // ...
}
```

To prevent rollback for a particular exception:

```java
@Transactional(noRollbackFor = NotificationException.class)
public void processOrder() {
    // NotificationException won't normally trigger rollback
}
```

---

#### `transactionManager`

When an application has multiple transaction managers, you can select the appropriate one.

```java
@Transactional(transactionManager = "ordersTransactionManager")
public void createOrder() {
    // Uses the specified transaction manager
}
```

This is useful in applications involving multiple databases or transaction-management resources.

---

#### `label`

Spring also supports transaction labels:

```java
@Transactional(label = "order-processing")
public void processOrder() {
    // ...
}
```

Labels provide descriptive metadata that transaction infrastructure can use. They are primarily useful when custom transaction-management infrastructure or observability needs to distinguish transaction types.

---

### Advantages

**1. Declarative transaction management**

You don't need to manually call `begin()`, `commit()`, or `rollback()` around every database operation.

```java
@Transactional
public void transferMoney() {
    debitAccount();
    creditAccount();
}
```

**2. Consistent rollback handling**

Transaction behavior is centralized and consistently applied by Spring's transaction infrastructure rather than being duplicated throughout business code.

**3. Fine-grained transaction boundaries**

You can control propagation, isolation, timeout, rollback behavior, read-only intent, and transaction-manager selection at the method/class level.

**4. Integration with multiple databases**

Spring's transaction abstraction supports different transaction managers and persistence technologies, allowing transaction-aware application code to remain relatively independent of the underlying transaction implementation.

---

### Disadvantages

**1. Self-invocation limitation**

Calling a transactional method directly from another method in the same object can bypass the proxy, so the transaction interceptor isn't invoked.

**2. Checked exceptions don't roll back by default**

Developers sometimes expect every exception to cause rollback. Checked exceptions require explicit configuration when rollback is desired.

**3. Async operations don't automatically share the transaction**

A transaction associated with one thread isn't automatically propagated to an asynchronous task running on another thread.

**4. Incorrect `readOnly` assumptions**

`readOnly=true` should be treated as a transaction hint/intent rather than a universal write-prevention mechanism. Its effect depends on the persistence stack.

**5. Complex propagation/nested transaction behavior**

Combining `REQUIRED`, `REQUIRES_NEW`, `NESTED`, multiple services, exceptions, and asynchronous execution can make transaction behavior difficult to reason about.

---

### Example

#### Simple `@Transactional` Service

```java
@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;

    public OrderService(
            OrderRepository orderRepository,
            InventoryService inventoryService) {
        this.orderRepository = orderRepository;
        this.inventoryService = inventoryService;
    }

    @Transactional
    public void placeOrder(Order order) {

        orderRepository.save(order);

        inventoryService.reduceStock(
            order.getProductId(),
            order.getQuantity()
        );

        // If a rollback-triggering exception occurs,
        // the transaction can be rolled back.
    }
}
```

Here, saving the order and modifying inventory can participate in the same transaction when the underlying resources and transaction manager support that arrangement.

---

#### `rollbackFor` with a Checked Exception

```java
@Service
public class PaymentService {

    @Transactional(rollbackFor = PaymentProcessingException.class)
    public void processPayment() throws PaymentProcessingException {

        paymentRepository.save(createPayment());

        if (!gatewayAvailable()) {
            throw new PaymentProcessingException(
                "Payment gateway unavailable"
            );
        }
    }
}
```

If `PaymentProcessingException` is a checked exception, explicitly specifying `rollbackFor` tells Spring that this exception should cause rollback.

---

#### `REQUIRES_NEW` Example

```java
@Service
public class AuditService {

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void saveAudit(String message) {
        auditRepository.save(new AuditLog(message));
    }
}
```

Suppose the outer operation is:

```java
@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final AuditService auditService;

    @Transactional
    public void placeOrder(Order order) {

        orderRepository.save(order);

        auditService.saveAudit("Order created");

        throw new RuntimeException("Something went wrong");
    }
}
```

The outer transaction is rolled back. The `REQUIRES_NEW` audit transaction is independently committed if `saveAudit()` completes successfully.

Conceptually:

```text
Outer Transaction
    |
    +---- Order saved
    |
    +---- suspend Outer Transaction
              |
              +---- New Audit Transaction
              |       |
              |       +---- Audit saved
              |       +---- COMMIT
              |
         resume Outer Transaction
    |
    +---- RuntimeException
    |
    +---- ROLLBACK
```

Therefore, `REQUIRES_NEW` is useful when a piece of work must have an **independent transaction boundary**.

---

### Sequence Diagram

The following UML-style sequence shows the conceptual Spring transaction flow:

```text
Client
  |
  |  call transactionalMethod()
  v
Spring AOP Proxy
  |
  |  intercept method call
  v
TransactionInterceptor
  |
  |  read @Transactional metadata
  |
  |  get/create/join transaction
  v
PlatformTransactionManager
  |
  |  begin / join transaction
  v
Target Service Method
  |
  |  execute business logic
  |
  +----------------------+
  |                      |
  | success              | rollback-triggering exception
  v                      v
TransactionInterceptor  TransactionInterceptor
  |                      |
  | commit               | rollback
  v                      v
PlatformTransactionManager
  |                      |
  +----------+-----------+
             |
             v
          Client
```

A more precise conceptual flow is:

```text
Client
  |
  v
Proxy
  |
  v
TransactionInterceptor
  |
  +--> PlatformTransactionManager
  |        |
  |        +--> Start/Join Transaction
  |
  +--> Target Method
           |
           +--> Repository / Database
           |
           +--> SUCCESS
           |      |
           |      +--> TransactionManager.commit()
           |
           +--> ROLLBACK EXCEPTION
                  |
                  +--> TransactionManager.rollback()
```

---

### Interview Q&A

#### 1. What is `@Transactional` and why is it used?

`@Transactional` is a Spring annotation that defines a transaction boundary around a method or class. It allows Spring to automatically start, join, commit, or roll back transactions instead of requiring explicit transaction-management code.

It is commonly placed on **service-layer methods** because a service method often represents one business operation containing multiple database actions that should succeed or fail together.

---

#### 2. What is the difference between `REQUIRED` and `REQUIRES_NEW`?

`REQUIRED` is the default propagation behavior. It joins an existing transaction if one exists; otherwise, it creates a new transaction.

`REQUIRES_NEW` always creates a separate transaction. If an outer transaction exists, Spring suspends it while the new transaction executes.

```text
REQUIRED:

Outer Transaction
      |
      +---- Inner Method
             |
             +---- same transaction


REQUIRES_NEW:

Outer Transaction
      |
      +---- suspend
             |
             +---- New Inner Transaction
             |
             +---- commit
      |
      +---- resume Outer Transaction
```

---

#### 3. What is the default rollback behavior?

By default, Spring rolls back for `RuntimeException` and `Error`, but not ordinary checked exceptions.

```java
@Transactional
public void process() {

    // RuntimeException -> rollback

    // IOException -> normally no rollback
}
```

For checked exceptions:

```java
@Transactional(rollbackFor = IOException.class)
public void process() throws IOException {
    // IOException -> rollback
}
```

---

#### 4. What are isolation levels?

Isolation determines how concurrent transactions interact with data.

For example:

* `READ_UNCOMMITTED` — permits dirty reads.
* `READ_COMMITTED` — prevents dirty reads.
* `REPEATABLE_READ` — provides stronger repeat-read consistency.
* `SERIALIZABLE` — strongest standard isolation, generally with lower concurrency.

The appropriate isolation level depends on the application's consistency requirements and the database's implementation.

---

#### 5. Why does self-invocation cause problems with `@Transactional`?

Because Spring's transaction interceptor is normally applied through a proxy.

```java
public void methodA() {
    methodB(); // direct call
}

@Transactional
public void methodB() {
}
```

The call is effectively made on the current object rather than through its Spring proxy, so the transactional interceptor may not execute.

The usual solution is to put the transactional method in another Spring-managed bean and invoke that bean.

---

#### 6. How does `@Transactional` work internally?

Spring creates an AOP proxy around the bean. When a caller invokes the transactional method through that proxy, `TransactionInterceptor` processes the transaction metadata.

It then delegates transaction operations to a `PlatformTransactionManager`, which starts or joins a transaction according to propagation rules. After the target method finishes, Spring commits or rolls back according to the outcome and configured rollback rules.

```text
Caller
   ↓
AOP Proxy
   ↓
TransactionInterceptor
   ↓
PlatformTransactionManager
   ↓
Target Method
   ↓
Commit / Rollback
```

---

#### 7. When should you use `readOnly = true`?

Use it for operations that are genuinely intended to **read data without modifying it**:

```java
@Transactional(readOnly = true)
public List<Product> getProducts() {
    return productRepository.findAll();
}
```

It communicates intent and may allow optimizations depending on the transaction manager, database, and persistence framework. However, don't assume that `readOnly=true` universally prevents writes or automatically makes every query faster.

---

#### 8. What is the difference between declarative and programmatic transaction management?

**Declarative transaction management** uses annotations/configuration:

```java
@Transactional
public void transfer() {
    debit();
    credit();
}
```

Spring manages the transaction boundary automatically.

**Programmatic transaction management** explicitly controls transaction operations:

```java
transactionTemplate.execute(status -> {
    debit();
    credit();
    return null;
});
```

Declarative management is generally preferred for normal service-layer business transactions because it keeps transaction infrastructure out of business logic. Programmatic management is useful when transaction boundaries need unusually fine-grained or dynamic control.

---

### Quick Interview Cheat Sheet

| Question                                    | Short Answer                                            |
| ------------------------------------------- | ------------------------------------------------------- |
| What is `@Transactional`?                   | Declarative transaction management in Spring            |
| Default propagation?                        | `REQUIRED`                                              |
| Default rollback?                           | `RuntimeException` and `Error`                          |
| Checked exception rollback?                 | Use `rollbackFor`                                       |
| New independent transaction?                | `REQUIRES_NEW`                                          |
| Same transaction if available?              | `REQUIRED`                                              |
| Strongest standard isolation?               | `SERIALIZABLE`                                          |
| Read-only transaction?                      | `@Transactional(readOnly = true)`                       |
| Why self-invocation fails?                  | Internal call bypasses Spring proxy                     |
| Who intercepts transactions?                | `TransactionInterceptor`                                |
| Who manages transactions?                   | `PlatformTransactionManager`                            |
| Where is transaction context associated?    | Typically with the current thread                       |
| Does `@Async` inherit caller's transaction? | No, don't assume transaction propagation across threads |
| Declarative vs programmatic?                | Annotation/configuration vs explicit transaction API    |

### Key Takeaways

1. **`@Transactional` defines a transaction boundary; it does not itself implement the transaction.**
2. **Spring AOP proxies and `TransactionInterceptor` apply the transactional behavior.**
3. **`PlatformTransactionManager` performs the underlying transaction operations.**
4. **`REQUIRED` is the default propagation.**
5. **`REQUIRES_NEW` suspends the current transaction and starts an independent one.**
6. **Runtime exceptions normally trigger rollback; checked exceptions normally do not.**
7. **Self-invocation can bypass transactional interception.**
8. **Transaction context should not be assumed to cross `@Async` thread boundaries.**
9. **Isolation controls concurrency/consistency trade-offs.**
10. **Use `readOnly=true` as an indication of read-only intent, not as a universal write prohibition.**
