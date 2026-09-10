# Spring & Spring Boot Interview Questions and Answers
## Part 2 — Spring MVC + REST + JPA/Hibernate + Transactions

> **Level:** Easy → Intermediate → Advanced → Tricky  
> **Goal:** Understand what happens internally, not just memorize annotations.

---

# SECTION 1 — SPRING MVC

## 101. What is Spring MVC?

Spring MVC is Spring's web framework for building web applications and REST APIs.

MVC stands for:

```text
Model
View
Controller
```

A simplified request flow is:

```text
Client
   |
   | HTTP Request
   v
DispatcherServlet
   |
   v
Handler Mapping
   |
   v
Controller
   |
   v
Service
   |
   v
Repository
   |
   v
Database
```

For a REST API, the response is usually serialized as JSON rather than rendered as an HTML view.

---

# 102. What is DispatcherServlet?

`DispatcherServlet` is the central entry point of Spring MVC.

It acts as a front controller.

A simplified flow:

```text
HTTP Request
     |
     v
DispatcherServlet
     |
     +--> Find appropriate controller
     |
     +--> Invoke controller
     |
     +--> Process result
     |
     +--> Convert response
     |
     v
HTTP Response
```

This is one of the most important Spring MVC concepts.

---

# 103. Explain the complete Spring MVC request flow.

Suppose the client sends:

```http
GET /orders/100
```

A simplified flow is:

```text
1. HTTP request arrives
        ↓
2. Servlet container receives request
        ↓
3. DispatcherServlet receives it
        ↓
4. HandlerMapping identifies controller method
        ↓
5. HandlerAdapter invokes controller
        ↓
6. Controller calls service
        ↓
7. Service calls repository
        ↓
8. Database operation
        ↓
9. Controller returns result
        ↓
10. Message conversion serializes object
        ↓
11. HTTP response sent
```

For REST APIs, JSON conversion is commonly handled through HTTP message converters.

---

# 104. What is @RestController?

`@RestController` is effectively:

```java
@Controller
@ResponseBody
```

conceptually combined.

Example:

```java
@RestController
@RequestMapping("/orders")
public class OrderController {

    @GetMapping("/{id}")
    public Order getOrder(@PathVariable Long id) {
        return orderService.getOrder(id);
    }
}
```

The returned object is normally written to the HTTP response body and serialized, commonly as JSON.

---

# 105. @Controller vs @RestController

### @Controller

Normally used for MVC controllers that may return view names.

```java
@Controller
public class OrderController {

    @GetMapping("/orders")
    public String orders() {
        return "orders";
    }
}
```

### @RestController

Used primarily for REST APIs.

```java
@RestController
public class OrderController {

    @GetMapping("/orders")
    public List<Order> orders() {
        return orders;
    }
}
```

The response body is written directly rather than interpreted as a view name.

---

# 106. What is @RequestMapping?

It maps HTTP requests to controller classes or methods.

Example:

```java
@RequestMapping("/orders")
```

At class level:

```java
@RestController
@RequestMapping("/orders")
class OrderController {
}
```

Then:

```java
@GetMapping("/{id}")
```

results in:

```text
GET /orders/{id}
```

---

# 107. @GetMapping vs @PostMapping vs @PutMapping vs @PatchMapping vs @DeleteMapping

They are specialized request-mapping annotations.

```text
GET
    → Retrieve resource

POST
    → Create/process a resource

PUT
    → Replace/update a resource representation

PATCH
    → Partially update a resource

DELETE
    → Delete a resource
```

Example:

```java
@GetMapping("/{id}")
public Order get(@PathVariable Long id) {}

@PostMapping
public Order create(@RequestBody CreateOrderRequest request) {}

@PutMapping("/{id}")
public Order update(
        @PathVariable Long id,
        @RequestBody UpdateOrderRequest request) {}

@PatchMapping("/{id}")
public Order partialUpdate(...) {}

@DeleteMapping("/{id}")
public void delete(@PathVariable Long id) {}
```

---

# 108. What is @PathVariable?

It extracts a value from the URL path.

Request:

```text
GET /orders/100
```

Code:

```java
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {
}
```

Here:

```text
id = 100
```

---

# 109. What is @RequestParam?

It extracts a query parameter.

Request:

```text
GET /orders?status=PAID
```

Code:

```java
@GetMapping("/orders")
public List<Order> getOrders(
        @RequestParam String status) {
}
```

Here:

```text
status = PAID
```

---

# 110. @PathVariable vs @RequestParam

### Path variable

```text
/orders/100
```

Usually identifies a resource.

### Query parameter

```text
/orders?status=PAID
```

Usually represents filtering, sorting, pagination, or optional parameters.

Example:

```text
GET /orders/100
```

means:

> Get order 100.

Whereas:

```text
GET /orders?status=PAID&page=0
```

means:

> Get orders filtered by status, potentially with pagination.

---

# 111. What is @RequestBody?

It maps the HTTP request body to a Java object.

Request:

```json
{
  "productId": 10,
  "quantity": 2
}
```

Controller:

```java
@PostMapping("/orders")
public Order create(
        @RequestBody CreateOrderRequest request) {
}
```

Spring uses HTTP message converters to deserialize the request body.

---

# 112. What is @ResponseBody?

It tells Spring MVC to write the return value directly to the HTTP response body rather than treating it as a view name.

```java
@Controller
class OrderController {

    @ResponseBody
    @GetMapping("/orders")
    public List<Order> orders() {
        return orderService.findAll();
    }
}
```

`@RestController` provides this behavior at the controller level.

---

# 113. What is HTTP message conversion?

Suppose your controller returns:

```java
Order order
```

Spring needs to convert it into an HTTP response representation.

For JSON:

```text
Java Object
    ↓
HTTP Message Converter
    ↓
JSON
    ↓
HTTP Response
```

Similarly, incoming JSON can be converted into Java objects.

---

# 114. What is Jackson?

Jackson is a commonly used Java library for JSON serialization and deserialization.

Example:

```java
Order order
```

can be serialized into:

```json
{
  "id": 100,
  "status": "PAID"
}
```

Spring Boot commonly configures JSON support automatically when the appropriate web stack is present.

---

# 115. What is DTO?

DTO means **Data Transfer Object**.

A DTO represents data transferred between application boundaries.

Example:

```java
public class CreateOrderRequest {

    private Long productId;
    private int quantity;
}
```

Instead of directly exposing a JPA entity:

```java
@Entity
class Order {
    ...
}
```

the controller can accept/return DTOs.

---

# 116. Why should we avoid exposing JPA entities directly from REST APIs?

Several reasons:

### 1. Coupling

API contract becomes tightly coupled to database model.

### 2. Security

You may accidentally expose fields that should not be public.

### 3. Lazy loading problems

Serialization may trigger lazy associations.

### 4. Infinite recursion

Bidirectional relationships can create serialization cycles.

Example:

```text
Order → Customer → Orders → Customer → ...
```

### 5. API evolution

Database changes shouldn't necessarily change your public API.

Therefore, DTOs are often preferable.

---

# 117. Entity vs DTO

### Entity

Represents persistence state.

```java
@Entity
class Order {
}
```

### DTO

Represents data exchanged between boundaries.

```java
class OrderResponse {
}
```

A common architecture is:

```text
HTTP
 ↓
DTO
 ↓
Service
 ↓
Entity
 ↓
Repository
 ↓
Database
```

and back:

```text
Database
 ↓
Entity
 ↓
Service
 ↓
DTO
 ↓
HTTP
```

---

# SECTION 2 — REST API INTERVIEW QUESTIONS

# 118. What does idempotent mean in REST?

An operation is idempotent if performing it multiple times has the same intended effect as performing it once.

Typically:

```text
GET     → idempotent
PUT     → idempotent
DELETE  → generally idempotent
POST    → generally not idempotent
```

Example:

```http
PUT /users/10
```

with:

```json
{
  "name": "John"
}
```

Sending it multiple times should leave the resource in the same intended state.

---

# 119. Is DELETE always idempotent?

The intended state transition is generally considered idempotent.

Example:

```text
DELETE /orders/100
```

First request:

```text
Order deleted.
```

Second request:

```text
Order is already deleted.
```

The final state remains:

```text
Order does not exist.
```

However, the HTTP response/status behavior may differ between requests.

---

# 120. Is POST always non-idempotent?

POST is generally not defined as idempotent.

Example:

```http
POST /orders
```

Sending it twice may create:

```text
Order 101
Order 102
```

However, APIs can implement idempotency keys to make specific POST operations safely retryable.

This is extremely important in payment/order systems.

---

# 121. What is an idempotency key?

An idempotency key allows a client to safely retry a request without accidentally creating duplicate operations.

Example:

```http
POST /payments
Idempotency-Key: abc-123
```

If the client retries with the same key:

```text
Request 1 → Payment created
Request 2 → Same operation recognized
```

The server can return the previously recorded result rather than processing the payment twice.

---

# 122. 200 vs 201 vs 204

### 200 OK

Request succeeded and response usually contains a representation.

### 201 Created

A resource was successfully created.

Example:

```http
POST /orders
```

### 204 No Content

Request succeeded but there is no response body.

Commonly used for successful deletion/update operations where no representation is returned.

---

# 123. 400 vs 401 vs 403 vs 404

### 400 Bad Request

The request is invalid.

Example:

```json
{
  "quantity": -5
}
```

### 401 Unauthorized

Authentication is missing or invalid.

### 403 Forbidden

The user is authenticated but doesn't have permission.

### 404 Not Found

The requested resource cannot be found.

### Easy way to remember

```text
401 → "Who are you?"
403 → "I know who you are, but you cannot do this."
```

---

# 124. Should validation happen in Controller or Service?

Usually both layers can have different responsibilities.

### Controller

Validate incoming API contract:

```java
@Valid
@RequestBody
CreateOrderRequest request
```

### Service

Enforce business invariants.

For example:

```text
Controller:
quantity must be positive

Service:
customer cannot order more than available credit
```

Don't assume API validation alone guarantees business correctness.

---

# 125. What is @Valid?

`@Valid` triggers Bean Validation on an object.

Example:

```java
public class CreateUserRequest {

    @NotBlank
    private String name;

    @Email
    private String email;

    @Min(18)
    private int age;
}
```

Controller:

```java
@PostMapping
public User create(
        @Valid @RequestBody CreateUserRequest request) {
}
```

Spring validates the request before invoking the controller method body.

---

# 126. @Valid vs @Validated

`@Valid` comes from Jakarta Bean Validation and triggers standard validation.

`@Validated` is a Spring annotation that additionally supports validation groups and is commonly useful for method-level validation.

Example:

```java
@Validated
@Service
class UserService {
}
```

For basic request-body validation, `@Valid` is often enough.

---

# SECTION 3 — SPRING EXCEPTION HANDLING

# 127. What is @ControllerAdvice?

`@ControllerAdvice` allows centralized handling of controller-related concerns.

A common use is global exception handling.

Example:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<?> handleOrderNotFound(
            OrderNotFoundException ex) {

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
}
```

---

# 128. What is @ExceptionHandler?

It defines a method that handles specific exceptions.

Example:

```java
@ExceptionHandler(OrderNotFoundException.class)
public ResponseEntity<?> handle(OrderNotFoundException ex) {
    return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(ex.getMessage());
}
```

This avoids putting repetitive `try/catch` logic inside every controller.

---

# 129. @ControllerAdvice vs @RestControllerAdvice

`@RestControllerAdvice` is effectively a convenient combination of:

```text
@ControllerAdvice
+
@ResponseBody
```

It is particularly convenient for REST APIs because exception-handler results are written directly to the response body.

---

# 130. Should we catch Exception everywhere?

No.

This is generally poor practice:

```java
try {
    ...
} catch (Exception e) {
    return "Something went wrong";
}
```

It can:

- Hide programming errors
- Destroy useful stack traces
- Make debugging difficult
- Produce incorrect HTTP responses
- Mix infrastructure concerns with business logic

Prefer targeted exception handling and centralized translation at appropriate application boundaries.

---

# SECTION 4 — JPA AND HIBERNATE

# 131. What is JPA?

JPA stands for **Jakarta Persistence**.

It is a specification/API for object-relational persistence in Java.

JPA defines concepts such as:

- Entity
- EntityManager
- Persistence Context
- Relationships
- JPQL
- Lifecycle

JPA itself is a specification.

Hibernate is one implementation/provider commonly used with JPA.

---

# 132. JPA vs Hibernate

This is a classic interview question.

### JPA

Specification.

### Hibernate

Implementation/provider of JPA.

Think:

```text
JPA
 ↓
Rules / APIs / specification

Hibernate
 ↓
Implementation
```

You can write:

```java
@Entity
class Order {
}
```

using JPA annotations while Hibernate performs the actual persistence work underneath.

---

# 133. What is an Entity?

An entity is a Java object mapped to persistent data, typically a database table.

Example:

```java
@Entity
@Table(name = "orders")
public class Order {

    @Id
    private Long id;

    private BigDecimal amount;
}
```

An entity has an identity, typically represented by its primary key.

---

# 134. What is @Id?

`@Id` identifies the primary key of an entity.

Example:

```java
@Id
private Long id;
```

---

# 135. What is @GeneratedValue?

It defines how the primary key value is generated.

Example:

```java
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;
```

The exact behavior depends on the chosen strategy and database.

---

# 136. What is EntityManager?

`EntityManager` is a core JPA interface for interacting with the persistence context.

Operations include:

```java
persist()
find()
merge()
remove()
```

It manages entity state and interaction with persistence.

Spring Data JPA repositories often hide much of the direct EntityManager usage.

---

# 137. What is Persistence Context?

This is one of the **most important JPA interview topics**.

A persistence context is a set of entity instances managed by an EntityManager.

Conceptually:

```text
Persistence Context
       |
       +--> Entity A
       +--> Entity B
       +--> Entity C
```

Hibernate/JPA tracks these managed entities.

This enables:

- Dirty checking
- First-level cache
- Identity guarantee within the persistence context
- Automatic synchronization with database

---

# 138. What is first-level cache?

The persistence context acts as a first-level cache.

Suppose:

```java
Order order1 = entityManager.find(Order.class, 100L);
Order order2 = entityManager.find(Order.class, 100L);
```

Within the same persistence context, JPA can return the same managed entity instance rather than loading the same database row again.

Conceptually:

```text
First find
    ↓
Database
    ↓
Persistence Context

Second find
    ↓
Persistence Context
    ↓
Same managed entity
```

This cache is associated with the persistence context/EntityManager.

---

# 139. Is first-level cache shared between all requests?

No.

A persistence context is not a global application-wide cache.

Typically, in a Spring/JPA transaction:

```text
Request
   ↓
Transaction
   ↓
Persistence Context
```

The persistence context is associated with the relevant transaction/entity manager context.

Do not confuse it with a global second-level cache.

---

# 140. What is dirty checking?

Dirty checking means JPA/Hibernate detects changes made to managed entities and can synchronize those changes with the database.

Example:

```java
@Transactional
public void updateOrder(Long id) {

    Order order = repository.findById(id)
            .orElseThrow();

    order.setStatus("PAID");
}
```

Notice there is no explicit:

```java
repository.save(order);
```

The entity is managed.

At transaction synchronization/flush time, Hibernate can detect the changed state and generate an SQL update.

Conceptually:

```text
Load entity
    ↓
Managed entity
    ↓
Change Java object
    ↓
Dirty checking
    ↓
SQL UPDATE
    ↓
Transaction commit
```

---

# 141. Does save() always execute an INSERT or UPDATE immediately?

**No.**

This is a very common interview trap.

Spring Data JPA's `save()` typically delegates to JPA operations such as `persist` or `merge` depending on entity state/newness.

The actual SQL may occur later during flush/transaction synchronization.

Therefore:

```java
repository.save(entity);
```

does not necessarily mean:

```text
SQL executes immediately
```

---

# 142. What is flush?

Flush synchronizes the persistence context with the database.

Conceptually:

```text
Java managed state
       ↓
Persistence Context
       ↓
flush()
       ↓
SQL statements sent
       ↓
Database
```

Flush is not the same thing as commit.

---

# 143. Flush vs Commit

### Flush

Synchronizes changes to the database.

### Commit

Makes the transaction's changes durable according to the database transaction semantics.

A transaction can flush SQL and still later roll back.

Therefore:

```text
flush ≠ commit
```

This distinction is frequently tested.

---

# 144. What is saveAndFlush()?

`saveAndFlush()` saves the entity and requests a flush of the persistence context.

It still does **not** mean:

> The transaction has committed.

For example:

```java
repository.saveAndFlush(entity);
```

can cause SQL to be sent before the surrounding transaction completes, but a later rollback can still undo the transaction.

---

# 145. What is the N+1 query problem?

Suppose we load:

```text
10 Orders
```

and then access each order's customer.

If the relationship is lazily loaded, the application might execute:

```text
1 query → load orders

10 queries → load customers
```

Total:

```text
11 queries
```

That's the N+1 problem.

Conceptually:

```text
SELECT * FROM orders;

SELECT * FROM customers WHERE id = 1;
SELECT * FROM customers WHERE id = 2;
SELECT * FROM customers WHERE id = 3;
...
```

---

# 146. How do you solve the N+1 problem?

Possible approaches:

### 1. JOIN FETCH

Example:

```java
@Query("""
    select o
    from Order o
    join fetch o.customer
""")
List<Order> findOrdersWithCustomer();
```

### 2. EntityGraph

Use an appropriate fetch plan.

### 3. Batch fetching

Hibernate-specific/configuration approaches can reduce the number of queries.

### 4. DTO projections

Fetch exactly the data needed by the use case.

### Important

Don't simply change everything from:

```text
LAZY → EAGER
```

to "solve" N+1.

That can create other performance problems.

---

# 147. LAZY vs EAGER fetching

### LAZY

Relationship is not necessarily loaded immediately.

It is loaded when accessed, subject to the persistence provider and context.

### EAGER

The relationship is intended to be fetched eagerly.

### Common mistake

> EAGER is faster because everything is loaded once.

Not necessarily.

EAGER fetching can result in:

- Unnecessary data
- Large joins
- Additional queries
- More memory usage
- Performance problems

Fetch strategy should be driven by use cases.

---

# 148. Why is LAZY generally preferred for collections?

Collections can become very large.

Suppose:

```text
Customer
   ↓
10,000 Orders
```

Loading all orders every time a customer is loaded is wasteful if most use cases only need customer information.

Therefore collections are commonly configured lazily.

---

# 149. What is LazyInitializationException?

It can occur when a lazily loaded association is accessed after the persistence context/session needed to initialize it is no longer available.

Example conceptually:

```text
Load Order
    ↓
Transaction ends
    ↓
Persistence context unavailable
    ↓
Access order.getItems()
    ↓
LazyInitializationException
```

This often indicates that fetching boundaries and application-layer design need attention.

Don't blindly "fix" it by making every relationship EAGER.

---

# 150. What is the Open Session in View pattern?

Open Session in View keeps the persistence context/session available into the web request processing phase, potentially allowing lazy loading during view/response rendering.

It can hide some lazy-loading problems but can also:

- Cause database access during serialization
- Make query behavior less obvious
- Increase database usage
- Blur architectural boundaries

For REST applications, consciously deciding whether to use it is important.

---

# SECTION 5 — ENTITY RELATIONSHIPS

# 151. What is @OneToOne?

Represents a one-to-one relationship.

Example:

```java
@OneToOne
private UserProfile profile;
```

One user has one profile.

---

# 152. What is @OneToMany?

One entity has many related entities.

Example:

```java
@OneToMany(mappedBy = "customer")
private List<Order> orders;
```

One customer can have many orders.

---

# 153. What is @ManyToOne?

Many entities reference one entity.

Example:

```java
@ManyToOne
private Customer customer;
```

Many orders can belong to one customer.

---

# 154. What is @ManyToMany?

Represents a many-to-many relationship.

Example:

```text
Student
  ↕
Course
```

A student can take multiple courses, and a course can have multiple students.

It is commonly represented using a join table.

---

# 155. Which side is usually the owning side of a bidirectional relationship?

The owning side is the side responsible for managing the relationship mapping, typically the side containing the foreign-key relationship.

For example:

```java
@ManyToOne
@JoinColumn(name = "customer_id")
private Customer customer;
```

can be the owning side.

The inverse side might use:

```java
@OneToMany(mappedBy = "customer")
private List<Order> orders;
```

The `mappedBy` side is not the owning side.

---

# 156. What does mappedBy mean?

`mappedBy` indicates that the relationship is mapped by a field/property on the other entity.

Example:

```java
@OneToMany(mappedBy = "customer")
private List<Order> orders;
```

This means:

> The `Order.customer` field owns/maps this relationship.

`mappedBy` prevents both sides from trying to manage the same relationship independently.

---

# 157. What happens if you don't update both sides of a bidirectional relationship in Java?

Suppose:

```java
customer.getOrders().add(order);
```

but:

```java
order.setCustomer(customer);
```

is not done.

Your in-memory object graph may be inconsistent even if the database relationship is eventually persisted correctly depending on which side is owning.

A common practice is to provide helper methods:

```java
public void addOrder(Order order) {
    orders.add(order);
    order.setCustomer(this);
}
```

This keeps both sides synchronized in memory.

---

# SECTION 6 — CASCADE AND ORPHAN REMOVAL

# 158. What is cascade in JPA?

Cascade defines which operations should propagate from one entity to related entities.

Examples:

```text
PERSIST
MERGE
REMOVE
REFRESH
DETACH
ALL
```

Example:

```java
@OneToMany(cascade = CascadeType.ALL)
private List<OrderItem> items;
```

Certain operations on the parent can cascade to children.

---

# 159. Is CascadeType.ALL always a good idea?

**No.**

This is a major interview trap.

Consider:

```text
Customer
   |
   +--> Orders
```

If you use:

```java
cascade = CascadeType.ALL
```

including `REMOVE`, deleting a customer can potentially cascade deletion to orders.

That may be disastrous if orders are business records that must be retained.

Cascade should reflect the actual ownership/lifecycle relationship.

---

# 160. What is orphanRemoval?

`orphanRemoval = true` can cause a child entity to be removed when it is removed from its parent's managed relationship, depending on the mapping and entity lifecycle.

Example:

```java
@OneToMany(
    mappedBy = "order",
    orphanRemoval = true
)
private List<OrderItem> items;
```

If an item is removed from the collection, JPA can delete the orphaned entity when synchronization occurs.

### Important distinction

`cascade REMOVE` and `orphanRemoval` are related but not identical concepts.

---

# 161. Cascade REMOVE vs orphanRemoval

### Cascade REMOVE

Parent removal can propagate removal to children.

```text
Delete parent
    ↓
Delete children
```

### orphanRemoval

Removing a child from the parent's relationship can remove that child.

```text
Remove child from collection
       ↓
Child becomes orphan
       ↓
Delete child
```

Use carefully.

---

# SECTION 7 — TRANSACTIONS DEEP DIVE

# 162. What is a transaction?

A transaction is a logical unit of work that should satisfy transactional guarantees.

Classic ACID properties:

```text
A → Atomicity
C → Consistency
I → Isolation
D → Durability
```

---

# 163. Explain ACID.

### Atomicity

All operations succeed or the transaction is rolled back.

### Consistency

The database moves from one valid state to another valid state according to its constraints/rules.

### Isolation

Concurrent transactions should not improperly interfere with each other.

### Durability

Committed changes survive failures according to the database's durability guarantees.

---

# 164. What is transaction isolation?

Isolation controls how one transaction can observe changes made by concurrent transactions.

Common levels:

```text
READ_UNCOMMITTED
READ_COMMITTED
REPEATABLE_READ
SERIALIZABLE
```

Exact behavior depends on the database.

---

# 165. What are dirty reads?

A dirty read occurs when one transaction reads data written by another transaction that has not yet committed.

Example:

```text
Transaction A:
update balance = 500
(not committed)

Transaction B:
reads balance = 500
```

If A later rolls back, B read data that never became committed.

---

# 166. What is a non-repeatable read?

Transaction A reads a row:

```text
balance = 100
```

Transaction B updates and commits:

```text
balance = 200
```

Transaction A reads again and gets:

```text
balance = 200
```

The same query produced a different committed value within the same transaction.

---

# 167. What is a phantom read?

A transaction executes a query such as:

```sql
SELECT * FROM orders WHERE amount > 1000;
```

Later, another transaction inserts a new matching row and commits.

The first transaction repeats the query and sees an additional row.

That new row is a phantom.

---

# 168. What is optimistic locking?

Optimistic locking assumes conflicts are relatively uncommon.

A common JPA mechanism is:

```java
@Version
private Long version;
```

Conceptually:

```text
Read record
version = 5

Transaction A updates
version 5 → 6

Transaction B tries update using version 5
        ↓
Conflict detected
```

Transaction B can fail instead of silently overwriting A's change.

---

# 169. What is pessimistic locking?

Pessimistic locking assumes conflicts are possible and asks the database to lock rows/resources while the transaction is operating.

Conceptually:

```text
Transaction A
    ↓
Lock row
    ↓
Modify
    ↓
Commit
    ↓
Unlock
```

Other transactions may have to wait or fail depending on the lock and database behavior.

---

# 170. Optimistic vs pessimistic locking

### Optimistic

```text
Assume conflicts are rare
Detect conflict during update
```

Good for many read-heavy systems.

### Pessimistic

```text
Prevent/limit conflicting concurrent access
Use database locking
```

Useful when contention and correctness requirements justify holding locks.

Neither is universally better.

---

# 171. What happens if two users update the same record simultaneously?

Without concurrency control:

```text
User A reads price = 100
User B reads price = 100

A writes 120
B writes 150

Final = 150
```

A's update may be lost.

With optimistic locking:

```text
A version = 1 → update succeeds → version 2

B version = 1 → update fails
```

The application can then:

- Retry
- Inform the user
- Reload the latest state
- Apply conflict resolution

---

# 172. What is lost update?

A lost update occurs when one concurrent update overwrites another update without properly accounting for it.

It is a common concurrency problem.

Solutions may include:

- Optimistic locking
- Pessimistic locking
- Atomic database operations
- Proper transaction design

---

# SECTION 8 — SPRING DATA JPA

# 173. What is Spring Data JPA?

Spring Data JPA simplifies data-access code on top of JPA.

Instead of implementing common CRUD operations manually, you can define:

```java
public interface OrderRepository
        extends JpaRepository<Order, Long> {
}
```

You get operations such as:

```text
save()
findById()
findAll()
delete()
existsById()
```

and many others.

---

# 174. What is query derivation?

Spring Data can derive queries from method names.

Example:

```java
List<Order> findByStatus(String status);
```

or:

```java
List<Order> findByCustomerIdAndStatus(
        Long customerId,
        String status);
```

Spring Data parses the method name and creates the appropriate query.

---

# 175. Is query derivation always a good idea?

No.

For simple queries it is convenient.

But extremely long names become unreadable:

```java
findByCustomerIdAndStatusAndCreatedDateBetweenAndAmountGreaterThanAnd...
```

For complex queries, consider:

- `@Query`
- Specifications
- QueryDSL where used
- Criteria APIs
- Native SQL where justified
- DTO projections

---

# 176. What is @Query?

`@Query` lets you define a query explicitly.

Example:

```java
@Query("""
    select o
    from Order o
    where o.status = :status
""")
List<Order> findOrders(
        @Param("status") String status);
```

This is JPQL unless configured otherwise.

---

# 177. JPQL vs SQL

SQL operates on database tables/columns.

JPQL operates on entities and their properties.

SQL:

```sql
SELECT *
FROM orders
WHERE status = 'PAID';
```

JPQL:

```java
select o
from Order o
where o.status = :status
```

JPQL is object-oriented at the persistence model level.

---

# 178. What is a native query?

A native query is actual database SQL.

Example:

```java
@Query(
    value = "SELECT * FROM orders WHERE status = ?1",
    nativeQuery = true
)
List<Order> findOrders(String status);
```

Native SQL can be useful when:

- Database-specific features are required
- Complex SQL is significantly easier in SQL
- Performance tuning requires database-specific constructs

But excessive use can reduce database portability and abstraction.

---

# 179. What is projection in Spring Data JPA?

Projection allows you to retrieve only the data required rather than the entire entity.

For example:

```java
public interface OrderSummary {
    Long getId();
    BigDecimal getAmount();
}
```

Then a repository can return that projection.

This can reduce:

- Data transfer
- Entity creation
- Memory usage
- Unnecessary fetching

For read-heavy APIs, projections can be very useful.

---

# 180. Why shouldn't every query return an Entity?

Because sometimes you only need:

```text
id
name
status
```

but the entity contains:

```text
100 fields
many relationships
large objects
```

Loading the full entity graph can be wasteful.

For read-only use cases, DTO projections can often be more appropriate.

---

# SECTION 9 — TRANSACTIONAL SCENARIOS

# 181. Where should @Transactional normally be placed?

Usually around a service-layer operation representing a business transaction.

Example:

```java
@Service
public class TransferService {

    @Transactional
    public void transfer(
            Long from,
            Long to,
            BigDecimal amount) {

        debit(from, amount);
        credit(to, amount);
    }
}
```

This gives the business operation a clear transaction boundary.

Putting transactions randomly on every repository/controller method can make transaction behavior harder to reason about.

---

# 182. Should @Transactional be placed on Controller?

Usually, no.

A common architecture is:

```text
Controller
    ↓
Service
    ↓
Repository
```

The service layer generally defines the transaction boundary because it represents the business operation.

There can be legitimate exceptions, but making controllers transactional by default is generally not ideal.

---

# 183. Can a private method be @Transactional?

Consider:

```java
@Transactional
private void process() {
}
```

Don't assume this will work as expected with Spring proxy-based transaction interception.

Spring proxy-based AOP has visibility/proxy limitations, and private method calls cannot be intercepted in the same way as externally invoked public/protected methods through a proxy.

More importantly, transaction boundaries should generally be placed on externally invoked service operations.

---

# 184. What happens when a transactional method calls another transactional method?

It depends on propagation.

Example:

```java
@Transactional
public void methodA() {
    methodB();
}
```

If `methodB()` uses:

```java
@Transactional
```

with default `REQUIRED`, it normally participates in the existing transaction **if the invocation goes through the Spring proxy/infrastructure appropriately**.

If it uses:

```java
Propagation.REQUIRES_NEW
```

the existing transaction is suspended and a new transaction is started.

---

# 185. What is transaction propagation REQUIRED?

It means:

```text
If transaction exists:
    join it

If transaction doesn't exist:
    create one
```

It is the default propagation for `@Transactional`.

---

# 186. What is REQUIRES_NEW?

It always creates a new transaction for the method.

If another transaction already exists:

```text
Outer Transaction
       ↓
     suspend
       ↓
New Transaction
       ↓
     commit/rollback
       ↓
Resume Outer Transaction
```

---

# 187. Can an inner REQUIRES_NEW transaction commit while the outer transaction rolls back?

Yes.

Example:

```text
Outer transaction
    |
    +--> update order
    |
    +--> REQUIRES_NEW
           |
           +--> save audit
           |
           +--> COMMIT
    |
    +--> outer rollback
```

The audit transaction can remain committed even though the outer transaction rolls back.

This is sometimes useful for independent audit records, but the implications must be understood.

---

# 188. Why can REQUIRES_NEW cause connection pool problems?

Because the outer transaction may already hold a database connection.

When the inner `REQUIRES_NEW` transaction starts, another database connection may be needed.

If many threads are doing this and the pool is too small:

```text
Thread 1 → connection A → outer tx
          → needs connection B → inner tx

Thread 2 → connection C → outer tx
          → needs connection D → inner tx
```

The pool can become exhausted.

In poorly configured systems, this can contribute to deadlocks/resource starvation.

This is a very good senior-level interview point.

---

# SECTION 10 — REAL-WORLD DEBUGGING QUESTIONS

# 189. API returns 500 when accessing a lazy relationship. What would you investigate?

I would check:

1. Is the association lazy?
2. Is the persistence context still active?
3. Is serialization triggering lazy loading?
4. Is the service fetching the required relationship?
5. Should a DTO/query projection be used?
6. Is the application unintentionally relying on Open Session in View?

I would not immediately change:

```text
LAZY → EAGER
```

without understanding the query requirements.

---

# 190. Your API suddenly executes 1000 SQL queries. What would you investigate?

Likely areas:

```text
N+1 queries
Lazy relationship access
Loops containing repository calls
Missing JOIN FETCH
Incorrect fetch plan
Repeated queries
Poor batching
```

For example:

```java
for (Order order : orders) {
    customerRepository.findById(order.getCustomerId());
}
```

could create a query per order.

A better approach may fetch required data in bulk.

---

# 191. Why is putting repository calls inside a loop dangerous?

Example:

```java
for (Long id : ids) {
    repository.findById(id);
}
```

If there are 10,000 IDs:

```text
10,000 database queries
```

This can produce severe latency and database load.

Prefer appropriate:

```text
findAllById()
batch operations
JOINs
projections
bulk queries
```

where appropriate.

---

# 192. Your database is slow but CPU is low. What could be happening?

Possible causes:

- Database latency
- Missing indexes
- Slow SQL
- Lock contention
- Connection pool waits
- Network latency
- Excessive queries
- N+1
- Database resource saturation
- Long-running transactions

Low application CPU does not mean the application is healthy.

It may be waiting on the database.

---

# 193. What happens if the database connection pool is exhausted?

Threads attempting database access may wait for a connection.

Eventually requests may time out.

Symptoms can include:

```text
High request latency
Connection timeout errors
Thread pool growth
Low CPU
Database appears healthy or overloaded depending on the situation
```

This is why connection-pool metrics are important in production.

---

# 194. What is the relationship between web thread pool and DB connection pool?

Suppose:

```text
Web threads = 200
DB connections = 20
```

Up to many requests can arrive concurrently, but only a limited number can perform database work simultaneously.

If requests hold DB connections for a long time, the remaining requests may wait.

Poor sizing can create:

```text
Web threads
    ↓
waiting for DB connections
    ↓
high latency
    ↓
timeouts
```

Increasing every pool without understanding the bottleneck can make the system worse.

---

# SECTION 11 — VERY TRICKY QUESTIONS

# 195. Does @Transactional guarantee rollback if an exception occurs?

No.

Rollback depends on:

- Exception type
- Transaction configuration
- Propagation
- Whether the exception crosses the transactional boundary
- Whether the transaction has already been committed
- Other transaction-manager/database behavior

By default, Spring's declarative transaction behavior rolls back for unchecked exceptions and errors, not arbitrary checked exceptions.

---

# 196. If I catch the exception inside a @Transactional method, will Spring automatically roll back?

Not necessarily.

Example:

```java
@Transactional
public void process() {

    try {
        riskyOperation();
    } catch (Exception e) {
        log.error("Failed", e);
    }
}
```

If the exception is caught and doesn't cause the transaction to be marked rollback-only, the method can complete normally and the transaction may commit.

This is a very common interview trap.

---

# 197. What if you throw RuntimeException after catching an exception?

Example:

```java
@Transactional
public void process() {

    try {
        riskyOperation();
    } catch (Exception e) {
        throw new RuntimeException(e);
    }
}
```

Now the unchecked exception can trigger the default rollback behavior, assuming it propagates through the transactional boundary and the transaction is otherwise eligible for rollback.

---

# 198. What if you call repository.save() and then an exception happens later?

Example:

```java
@Transactional
public void process() {

    repository.save(order);

    paymentService.pay();

    throw new RuntimeException();
}
```

If everything is part of the same transaction and the exception triggers rollback:

```text
save
 ↓
SQL may be flushed
 ↓
exception
 ↓
rollback
 ↓
database changes undone
```

This demonstrates why:

```text
flush ≠ commit
```

---

# 199. Can a database row be updated before transaction commit?

Yes.

The persistence provider can flush SQL statements before the transaction commits.

But the update is still part of the database transaction and can be rolled back.

Therefore:

```text
SQL sent to DB
        ≠
Transaction committed
```

This distinction is crucial.

---

# 200. Why can a query sometimes trigger a flush before it executes?

Depending on the JPA flush mode and provider behavior, Hibernate may flush pending changes before executing a query to maintain appropriate query consistency.

For example:

```java
order.setStatus("PAID");

repository.findOrdersByStatus("PAID");
```

The persistence provider may need to synchronize pending changes before executing the query.

The exact behavior depends on flush mode/query/provider semantics.

---

# 201. What is the difference between managed, detached, transient and removed entities?

### Transient

A newly created object not associated with a persistence context.

```java
Order order = new Order();
```

### Managed

An entity currently associated with the persistence context.

```text
EntityManager
    ↓
Order
```

### Detached

An entity that was previously managed but is no longer attached to the persistence context.

### Removed

An entity scheduled for deletion.

Conceptually:

```text
Transient
    ↓ persist
Managed
    ↓ detach
Detached

Managed
    ↓ remove
Removed
```

---

# 202. What happens if you modify a detached entity?

Changes to a detached entity are not automatically tracked by the current persistence context.

You may need to reattach/merge it appropriately.

Example:

```java
entityManager.merge(order);
```

But remember:

> `merge()` returns a managed instance.

It does not simply magically turn the original object into a managed object in all cases.

---

# 203. What is the difference between persist() and merge()?

### persist()

Makes a new entity managed and schedules it for persistence.

Conceptually:

```text
new entity
   ↓
persist()
   ↓
managed
```

### merge()

Copies the state of a detached/new entity into a managed instance and returns that managed instance.

Important interview trap:

```java
Order managed = entityManager.merge(detached);
```

The returned object is the managed instance.

Don't assume the original detached object itself becomes managed.

---

# 204. Why should you be careful with merge()?

Because developers sometimes assume:

```java
entityManager.merge(order);
order.setStatus("PAID");
```

means `order` itself is now managed.

That's not necessarily the correct mental model.

Better:

```java
Order managedOrder = entityManager.merge(order);
managedOrder.setStatus("PAID");
```

Now you are explicitly modifying the managed instance.

---

# 205. What is the first-level cache identity guarantee?

Within a persistence context, if the same entity identity is requested multiple times, JPA maintains an identity guarantee for that managed entity.

Conceptually:

```java
Order a = entityManager.find(Order.class, 1L);
Order b = entityManager.find(Order.class, 1L);
```

Typically:

```java
a == b
```

within the same persistence context.

This is different from a global cache shared across the application.

---

# SECTION 12 — ARCHITECTURE QUESTIONS

# 206. Why do we usually use Controller → Service → Repository?

A common separation is:

```text
Controller
    ↓
HTTP/API concerns

Service
    ↓
Business logic + transaction boundary

Repository
    ↓
Persistence/data access
```

This separation provides:

- Clear responsibilities
- Better testing
- Easier maintenance
- Reusable business logic
- Cleaner transaction boundaries

It is not an absolute law, but it is a useful default architecture.

---

# 207. Should business logic be written in the Controller?

Generally, no.

Bad:

```java
@PostMapping
public Order create(...) {

    validate();
    calculatePrice();
    checkInventory();
    applyDiscount();
    save();
    sendEmail();

    return ...;
}
```

Better:

```text
Controller
   ↓
OrderService
   ↓
Inventory
   ↓
Pricing
   ↓
Repository
```

Controllers should primarily handle API concerns.

---

# 208. Should Repository contain business logic?

Generally, no.

Repository should focus on persistence operations.

Bad:

```java
repository.calculateCustomerDiscount();
```

if the discount represents business policy rather than data retrieval/persistence.

Business rules usually belong in an appropriate domain/service layer.

---

# 209. Where should validation/business rules go?

Think in layers.

```text
API validation
    ↓
DTO validation

Business validation
    ↓
Service/domain layer

Database constraints
    ↓
Final integrity protection
```

Example:

```text
@NotNull
@NotBlank
@Size
```

are useful for input validation.

But:

```text
"Customer cannot place an order after account is suspended"
```

is a business rule and should not depend solely on DTO validation.

---

# 210. What is the biggest mistake when designing JPA entities?

Treating entities as simple JSON/data-transfer objects.

Entities have:

- Lifecycle
- Identity
- Relationships
- Persistence context behavior
- Lazy loading
- Dirty checking
- Transactional semantics

They should be designed with persistence and domain behavior in mind.

---

# FINAL PART 2 RAPID-FIRE REVISION

```text
101. What is Spring MVC?
102. What is DispatcherServlet?
103. Explain Spring MVC request flow.
104. What is @RestController?
105. @Controller vs @RestController?
106. What is @RequestMapping?
107. @GetMapping vs @PostMapping?
108. What is @PathVariable?
109. What is @RequestParam?
110. What is @RequestBody?
111. What is @ResponseBody?
112. What is HTTP message conversion?
113. What is Jackson?
114. What is DTO?
115. Why avoid exposing entities directly?
116. What is idempotency?
117. Is DELETE idempotent?
118. Is POST idempotent?
119. What is an idempotency key?
120. 200 vs 201 vs 204?
121. 400 vs 401 vs 403 vs 404?
122. What is @Valid?
123. @Valid vs @Validated?
124. What is @ControllerAdvice?
125. What is @ExceptionHandler?
126. @ControllerAdvice vs @RestControllerAdvice?
127. What is JPA?
128. JPA vs Hibernate?
129. What is an Entity?
130. What is EntityManager?
131. What is Persistence Context?
132. What is first-level cache?
133. What is dirty checking?
134. Does save() immediately execute SQL?
135. What is flush?
136. Flush vs commit?
137. save() vs saveAndFlush()?
138. What is N+1?
139. How do you solve N+1?
140. LAZY vs EAGER?
141. What is LazyInitializationException?
142. What is Open Session in View?
143. @OneToOne?
144. @OneToMany?
145. @ManyToOne?
146. @ManyToMany?
147. What is owning side?
148. What is mappedBy?
149. What is cascade?
150. Is CascadeType.ALL always safe?
151. What is orphanRemoval?
152. Cascade REMOVE vs orphanRemoval?
153. What is a transaction?
154. Explain ACID.
155. What is isolation?
156. Dirty read?
157. Non-repeatable read?
158. Phantom read?
159. Optimistic locking?
160. Pessimistic locking?
161. What is lost update?
162. What is Spring Data JPA?
163. What is query derivation?
164. What is @Query?
165. JPQL vs SQL?
166. Native query?
167. Projection?
168. Why not return Entity for every query?
169. Where should @Transactional be placed?
170. Can @Transactional work on private methods?
171. What is REQUIRED?
172. What is REQUIRES_NEW?
173. Can inner REQUIRES_NEW commit while outer rolls back?
174. Why can REQUIRES_NEW exhaust connection pools?
175. Does @Transactional always rollback?
176. What happens if exception is caught?
177. save() then exception — what happens?
178. Can SQL execute before commit?
179. Why can queries trigger flush?
180. Transient vs managed vs detached vs removed?
181. persist vs merge?
182. What does merge() return?
183. What is first-level cache identity?
184. Why Controller-Service-Repository?
185. Should business logic be in Controller?
186. Should Repository contain business logic?
187. Where should validation happen?
188. Common JPA entity design mistakes?
```

---

# PART 2 — 15 QUESTIONS YOU SHOULD PRACTICE OUT LOUD

If the interviewer asks you to explain something without code, practice these:

```text
1. Explain the complete Spring MVC request lifecycle.

2. Explain how @RestController works.

3. Explain JPA Persistence Context.

4. Explain dirty checking with an example.

5. Explain first-level cache.

6. Explain the N+1 query problem and three solutions.

7. Explain LAZY vs EAGER fetching.

8. Explain LazyInitializationException.

9. Explain @Transactional internally.

10. Explain REQUIRED vs REQUIRES_NEW.

11. Explain optimistic vs pessimistic locking.

12. Explain what happens from repository.save()
   until transaction commit.

13. Explain JPA Entity lifecycle.

14. Explain why DTOs are preferable to exposing entities.

15. Explain what happens when two users update
   the same database record concurrently.
```

---

# PART 2 — MOST IMPORTANT TRAPS

Memorize these concepts, not just the wording:

```text
1. JPA is a specification.
   Hibernate is an implementation/provider.

2. save() does NOT necessarily mean immediate SQL execution.

3. flush() does NOT mean commit().

4. A managed entity can be updated without explicitly calling save()
   because dirty checking can detect changes.

5. LAZY is not automatically "better" in every situation.

6. EAGER is not automatically "faster."

7. Changing everything to EAGER is NOT a proper solution
   to N+1 or LazyInitializationException.

8. @Transactional does NOT guarantee rollback for every exception.

9. Catching an exception can prevent the expected rollback behavior.

10. Self-invocation can bypass Spring's proxy-based AOP.

11. REQUIRES_NEW creates an independent transaction.

12. REQUIRES_NEW can increase database connection requirements.

13. @Version provides optimistic locking.

14. mappedBy identifies the inverse side of a relationship.

15. CascadeType.ALL can be dangerous if REMOVE propagates
    farther than intended.

16. orphanRemoval and CascadeType.REMOVE are not the same.

17. DTO and Entity serve different purposes.

18. A singleton Spring bean is NOT automatically thread-safe.

19. First-level cache is associated with the persistence context;
    it is not a global application cache.

20. merge() returns a managed instance; don't assume the original
    detached object becomes managed.
```

---

# SENIOR INTERVIEW MENTAL MODEL

When you encounter a difficult Spring/JPA question, think through these layers:

```text
HTTP
 ↓
Servlet Container
 ↓
DispatcherServlet
 ↓
Controller
 ↓
Spring Proxy
 ↓
Transaction / Security / AOP
 ↓
Service
 ↓
Repository
 ↓
EntityManager
 ↓
Persistence Context
 ↓
Hibernate
 ↓
JDBC
 ↓
Connection Pool
 ↓
Database
```

For performance questions, think:

```text
Request
 ↓
Controller
 ↓
Service
 ↓
Repository
 ↓
How many SQL queries?
 ↓
How long does each query take?
 ↓
How many DB connections?
 ↓
Are there locks?
 ↓
How large is the result?
 ↓
How much memory?
 ↓
How many concurrent requests?
```

For transaction questions, think:

```text
Where does transaction start?
        ↓
Which methods participate?
        ↓
What is propagation?
        ↓
What is isolation?
        ↓
What exception occurred?
        ↓
Will rollback happen?
        ↓
When does flush occur?
        ↓
When does commit occur?
```

For JPA questions, think:

```text
Entity state
    ↓
Persistence Context
    ↓
Managed / Detached
    ↓
Dirty Checking
    ↓
Flush
    ↓
SQL
    ↓
Commit / Rollback
```

These mental models are much more valuable than memorizing 200 isolated Spring annotations.

---

# END OF PART 2

### Part 3 will cover the next major interview layer:

```text
Spring Security
    ↓
Authentication vs Authorization
    ↓
Security Filter Chain
    ↓
JWT
    ↓
OAuth2
    ↓
CORS / CSRF
    ↓
Password hashing
    ↓
Method security

Spring Boot
    ↓
Caching
    ↓
@Cacheable / @CachePut / @CacheEvict
    ↓
Redis
    ↓
Async processing
    ↓
@Async pitfalls
    ↓
Scheduling

Microservices
    ↓
Service-to-service communication
    ↓
RestClient / WebClient
    ↓
Timeouts
    ↓
Retry
    ↓
Circuit breaker
    ↓
Resilience patterns
    ↓
Service discovery
    ↓
API Gateway

Messaging
    ↓
Kafka
    ↓
Consumer groups
    ↓
Partitions
    ↓
Offsets
    ↓
At-least-once delivery
    ↓
Exactly-once concepts

Production
    ↓
Logging
    ↓
Metrics
    ↓
Tracing
    ↓
Actuator
    ↓
Memory issues
    ↓
Thread pools
    ↓
Connection pools
    ↓
Deadlocks
    ↓
Real-world debugging

Senior/Tricky
    ↓
Proxy problems
    ↓
Distributed transactions
    ↓
Race conditions
    ↓
Caching inconsistencies
    ↓
Idempotency
    ↓
Eventual consistency
    ↓
System-design scenarios
```