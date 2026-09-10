# Spring & Spring Boot Interview Questions and Answers
## Part 3 — Security + Caching + Async + Microservices + Kafka + Production + Senior Tricky Questions

> **Level:** Intermediate → Advanced → Senior  
> **Focus:** Internal working, production scenarios, debugging, and tricky interview questions.

---

# SECTION 1 — SPRING SECURITY

## 211. What is Spring Security?

Spring Security is a framework for securing Spring applications.

It mainly handles:

```text
Authentication
Authorization
Password security
Session management
CSRF protection
Security filters
OAuth2
JWT-based security
Method-level security
```

The simplest distinction is:

```text
Authentication
    ↓
Who are you?

Authorization
    ↓
What are you allowed to do?
```

---

# 212. Authentication vs Authorization

### Authentication

Verifies identity.

Example:

```text
Username: john
Password: ******
```

The system verifies that John is actually John.

### Authorization

Determines permissions.

Example:

```text
JOHN → USER
ADMIN → ADMIN
```

Then:

```text
USER
   → can view orders

ADMIN
   → can view orders
   → can delete orders
   → can manage users
```

---

# 213. Explain Spring Security request flow.

A simplified flow:

```text
HTTP Request
     ↓
Servlet Container
     ↓
Spring Security Filter Chain
     ↓
Authentication
     ↓
Authorization
     ↓
Controller
     ↓
Service
```

The important point is:

> Security processing happens before the request reaches your controller.

---

# 214. What is SecurityFilterChain?

It defines the security filters and rules applied to incoming HTTP requests.

Modern Spring Security configuration commonly looks like:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http)
        throws Exception {

    http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/public/**").permitAll()
            .requestMatchers("/admin/**").hasRole("ADMIN")
            .anyRequest().authenticated()
        );

    return http.build();
}
```

The exact configuration depends on the authentication mechanism and application requirements.

---

# 215. What is a security filter?

A security filter intercepts an HTTP request and performs security-related processing.

Examples include processing:

```text
Authentication
Authorization
CSRF
Session
Bearer tokens
Exception handling
```

A request may pass through multiple security filters before reaching the controller.

---

# 216. What is SecurityContext?

`SecurityContext` contains security information associated with the current execution/request context.

It can contain the authenticated principal.

Conceptually:

```text
HTTP Request
     ↓
Authentication
     ↓
SecurityContext
     ↓
Current authenticated user
```

Code may retrieve authentication information through:

```java
SecurityContextHolder
```

---

# 217. What is Authentication?

`Authentication` represents the authentication information.

It can contain:

```text
Principal
Credentials
Authorities
Authenticated status
```

For example:

```text
Principal → john
Authorities → ROLE_USER
```

---

# 218. What are GrantedAuthority and roles?

A `GrantedAuthority` represents an authority/permission.

For example:

```text
ROLE_USER
ROLE_ADMIN
ORDER_READ
ORDER_WRITE
```

A role is commonly represented as an authority with the `ROLE_` convention.

Example:

```java
.hasRole("ADMIN")
```

commonly corresponds to:

```text
ROLE_ADMIN
```

---

# 219. hasRole() vs hasAuthority()

Example:

```java
.hasRole("ADMIN")
```

typically checks:

```text
ROLE_ADMIN
```

Whereas:

```java
.hasAuthority("ORDER_READ")
```

checks exactly:

```text
ORDER_READ
```

A useful distinction:

```text
Role
    → broader grouping

Authority
    → specific permission
```

---

# 220. What is JWT?

JWT means **JSON Web Token**.

A JWT commonly contains:

```text
Header
Payload
Signature
```

Conceptually:

```text
xxxxx.yyyyy.zzzzz
```

The three sections represent:

```text
Header.Payload.Signature
```

---

# 221. Is JWT encrypted?

**Not necessarily.**

This is an important interview trap.

A typical signed JWT is encoded, not encrypted.

Therefore, you should not put sensitive secrets into the JWT payload simply because it looks unreadable.

The signature provides integrity/authenticity verification, not confidentiality.

---

# 222. What is the purpose of the JWT signature?

The signature helps the receiver verify that the token was created/signed by a trusted party and that its signed contents were not modified.

Conceptually:

```text
JWT
 ↓
Verify signature
 ↓
Valid?
 ├── Yes → Continue
 └── No  → Reject
```

---

# 223. What are access tokens and refresh tokens?

### Access token

Used to access protected resources.

Usually:

```text
short-lived
```

### Refresh token

Used to obtain a new access token.

Usually:

```text
longer-lived
```

Conceptually:

```text
Login
  ↓
Access Token + Refresh Token
  ↓
Access Token expires
  ↓
Refresh Token
  ↓
New Access Token
```

Exact implementation depends on the authentication architecture.

---

# 224. Where should JWT be stored?

There is no universal answer; storage depends on the application architecture and threat model.

For browser applications, blindly putting tokens into `localStorage` can expose them to JavaScript-accessible XSS theft.

A common browser security approach is to use appropriately configured secure, `HttpOnly` cookies, while also handling CSRF appropriately.

The important interview answer is:

> Token storage is a security design decision; don't simply say "localStorage is best."

---

# 225. What is CSRF?

CSRF means **Cross-Site Request Forgery**.

It occurs when a malicious site tricks a user's browser into sending an authenticated request to another site where the browser automatically includes credentials such as cookies.

Example concept:

```text
User logged into bank
       ↓
Malicious website
       ↓
Tricks browser into sending request
       ↓
Bank receives authenticated request
```

---

# 226. When is CSRF particularly relevant?

CSRF is especially relevant when authentication credentials are automatically attached by the browser, such as session cookies.

If an application uses bearer tokens supplied explicitly in an authorization header, the CSRF threat model is different.

Don't answer:

> "JWT means CSRF doesn't exist."

The correct answer depends on **how the token is transported and stored**.

---

# 227. What is CORS?

CORS means **Cross-Origin Resource Sharing**.

It controls whether a browser is allowed to make cross-origin requests to your application.

Example:

```text
Frontend:
https://frontend.example

Backend:
https://api.example
```

These are different origins.

The server must provide appropriate CORS headers for permitted browser requests.

---

# 228. CORS vs CSRF

### CORS

Controls browser cross-origin access.

### CSRF

Protects against unauthorized actions performed using a user's existing authentication context.

They solve different problems.

```text
CORS ≠ CSRF
```

---

# 229. What is password hashing?

Passwords should not normally be stored as plaintext.

Instead:

```text
Password
   ↓
Strong password hashing algorithm
   ↓
Password hash
   ↓
Database
```

Spring Security commonly supports password encoders designed for password hashing.

The goal is to make password cracking significantly more expensive.

---

# 230. Why shouldn't we use plain SHA-256 for password storage?

General-purpose cryptographic hashes are designed to be fast.

Attackers can use specialized hardware to attempt huge numbers of guesses.

Password hashing algorithms are deliberately designed to be computationally expensive and/or memory-hard.

Examples include:

```text
bcrypt
scrypt
Argon2
PBKDF2
```

Choose an appropriate algorithm supported by your security requirements and current framework guidance.

---

# SECTION 2 — METHOD-LEVEL SECURITY

# 231. What is method-level security?

It allows security rules to be applied directly to methods.

Example:

```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) {
}
```

This provides authorization closer to the business operation.

---

# 232. Why is method-level security useful?

URL security alone may not be enough.

For example:

```text
DELETE /orders/100
```

The user may have general permission to access the endpoint but still shouldn't be able to delete **this specific order**.

Business-level authorization can therefore be enforced in the service/domain layer.

---

# SECTION 3 — SPRING CACHING

# 233. What is caching?

Caching stores frequently used data closer to the application so that repeated requests don't always need to access the slower underlying data source.

Conceptually:

```text
Request
  ↓
Cache
  ↓
Hit? ── Yes → Return
  |
  No
  ↓
Database
  ↓
Store in cache
  ↓
Return
```

---

# 234. What is @Cacheable?

`@Cacheable` caches a method result.

Example:

```java
@Cacheable("products")
public Product getProduct(Long id) {
    return repository.findById(id)
            .orElseThrow();
}
```

First call:

```text
Method executes
   ↓
Database
   ↓
Result cached
```

Second call with the same cache key can return from cache without executing the method.

---

# 235. What is @CachePut?

`@CachePut` always executes the method and then updates the cache with the returned value.

Example:

```java
@CachePut(value = "products", key = "#product.id")
public Product update(Product product) {
    return repository.save(product);
}
```

Difference:

```text
@Cacheable
→ May skip method execution on cache hit

@CachePut
→ Method executes
→ Cache updated
```

---

# 236. What is @CacheEvict?

It removes data from the cache.

Example:

```java
@CacheEvict(value = "products", key = "#id")
public void delete(Long id) {
    repository.deleteById(id);
}
```

This is important when cached data becomes invalid.

---

# 237. What is a cache stampede?

Suppose a popular cache entry expires:

```text
10,000 requests
      ↓
Cache miss
      ↓
10,000 database calls
```

This can overload the database.

This is called a cache stampede/cache avalanche scenario depending on the exact failure pattern.

Possible mitigation strategies include:

- Request coalescing
- Locking
- Staggered expiration
- Prewarming
- Appropriate TTL design

---

# 238. What is stale data in caching?

Suppose:

```text
Database:
price = 100

Cache:
price = 100
```

Database changes:

```text
price = 120
```

but cache still contains:

```text
price = 100
```

The application returns stale data.

Therefore, cache invalidation is a major distributed-systems problem.

---

# 239. Cache-aside pattern

A common pattern is:

```text
Read:
    Cache
      ↓ miss
    Database
      ↓
    Put into cache
```

Write:

```text
Database update
      ↓
Invalidate/update cache
```

The exact ordering matters and should be designed carefully.

---

# 240. Why is cache invalidation difficult?

Because you now have multiple copies of state:

```text
Database
   +
Cache
   +
Possibly other service caches
```

When one changes, all relevant copies must eventually become consistent.

This introduces:

```text
stale data
race conditions
expiration issues
invalidation failures
```

---

# SECTION 4 — @ASYNC AND CONCURRENCY

# 241. What is @Async?

`@Async` allows a method to execute asynchronously using a Spring-managed executor.

Example:

```java
@Async
public void sendEmail() {
    ...
}
```

The caller may return without waiting for the asynchronous work to finish, depending on the method/executor configuration.

---

# 242. Does @Async create a new thread every time?

No.

A properly configured `@Async` method uses a task executor/thread pool.

Conceptually:

```text
Request
  ↓
Async Executor
  ↓
Worker Thread
```

You should configure and monitor the executor rather than assuming unlimited threads.

---

# 243. What is the biggest @Async trap?

Self-invocation.

Example:

```java
@Service
class EmailService {

    public void process() {
        sendEmail();
    }

    @Async
    public void sendEmail() {
    }
}
```

Calling:

```java
sendEmail();
```

from another method in the same instance can bypass the Spring proxy.

Therefore, `@Async` may not take effect as expected.

---

# 244. Why does self-invocation cause problems with @Transactional and @Async?

Spring commonly implements these features using proxies.

Conceptually:

```text
Caller
  ↓
Spring Proxy
  ↓
Target Object
```

The proxy can intercept the call and apply:

```text
Transaction
Security
Async
Caching
```

But:

```java
this.someMethod();
```

is an internal call directly on the target object.

It can bypass the proxy.

Therefore:

```text
self-invocation
    ↓
proxy may be bypassed
    ↓
annotation behavior may not occur
```

This is one of the most important Spring interview concepts.

---

# 245. How can you solve self-invocation problems?

Common approaches:

### 1. Move the method to another Spring bean

```text
Service A
   ↓
Service B
   ↓
@Async / @Transactional
```

### 2. Call through the appropriate Spring proxy

Possible, but generally less clean.

### 3. Redesign the service boundary

Often the cleanest solution.

---

# 246. What happens if an @Async method throws an exception?

It depends on the method's return type and configuration.

For example, exceptions from a `void` asynchronous method cannot simply be propagated back to the original caller because the caller has already continued.

An appropriate asynchronous exception handler can be configured.

For `Future`/`CompletableFuture`-based methods, the exception can be represented in the asynchronous result.

---

# 247. Why should @Async thread pools be configured?

Because the default executor behavior may not match production requirements.

A production application should think about:

```text
Core pool size
Maximum pool size
Queue capacity
Thread naming
Rejection policy
Shutdown behavior
Monitoring
```

Otherwise, a traffic spike can cause:

```text
Too many tasks
   ↓
Queue growth
   ↓
Memory pressure
   ↓
Latency
   ↓
Rejected tasks
```

---

# SECTION 5 — MICROSERVICES

# 248. What is a microservice?

A microservice architecture decomposes a system into independently deployable services around business capabilities.

Example:

```text
                    API Gateway
                         |
        +----------------+----------------+
        |                |                |
        v                v                v
   User Service     Order Service    Payment Service
        |                |                |
        v                v                v
     User DB          Order DB        Payment DB
```

The important point is not simply:

> "Many small services."

The services should have meaningful boundaries and operational independence.

---

# 249. What is the biggest disadvantage of microservices?

Distributed complexity.

With a monolith:

```text
Method A → Method B
```

With microservices:

```text
Service A
   ↓ network
Service B
```

Now you have:

```text
Network failures
Timeouts
Retries
Partial failures
Distributed tracing
Service discovery
Versioning
Data consistency
Deployment complexity
```

Microservices solve some problems while creating others.

---

# 250. Why shouldn't every application start as microservices?

Because microservices introduce substantial operational and architectural complexity.

For a small application, a modular monolith may be simpler:

```text
Application
  |
  +-- User module
  +-- Order module
  +-- Payment module
```

You can later extract services when there is a real business/organizational/scale reason.

---

# 251. What is service discovery?

Service discovery allows services to locate other service instances dynamically.

Instead of hardcoding:

```text
http://10.10.10.21:8080
```

a service can discover available instances through infrastructure/service discovery.

Conceptually:

```text
Order Service
     ↓
Service Discovery
     ↓
Payment Service instances
```

Modern cloud environments often provide service discovery through orchestration/platform infrastructure.

---

# 252. What is an API Gateway?

An API Gateway provides a common entry point for clients.

It can handle concerns such as:

```text
Routing
Authentication
Authorization
Rate limiting
Request transformation
Observability
TLS termination
```

Conceptually:

```text
Client
  ↓
API Gateway
  ↓
+---------+---------+
|         |         |
Order    User    Payment
```

---

# 253. What is the difference between API Gateway and Load Balancer?

A load balancer primarily distributes network traffic among instances.

An API Gateway is typically more application-aware and may provide:

```text
Routing
Authentication
Rate limiting
Transformation
Aggregation
Policies
```

They can coexist.

---

# 254. What happens if Service A calls Service B and B is down?

Without resilience:

```text
A
 ↓
B
 ↓
Timeout
 ↓
A thread waits
```

If many requests do this:

```text
Many A threads
      ↓
Waiting for B
      ↓
Thread pool exhaustion
      ↓
A also becomes unhealthy
```

This is a cascading failure.

---

# 255. What is a timeout?

A timeout limits how long a request waits for an operation.

For example:

```text
Service A → Service B
             |
             | max 2 seconds
             |
             X
```

If B doesn't respond within the configured limit, A stops waiting.

Timeouts are essential in distributed systems.

---

# 256. Why is an infinite timeout dangerous?

Suppose:

```text
Service B becomes slow
```

Without a timeout:

```text
Requests to A
      ↓
Wait forever
      ↓
Threads accumulate
      ↓
Resources exhausted
      ↓
Service A fails
```

A timeout is therefore an important resilience mechanism.

---

# 257. What is retry?

Retry means attempting an operation again after a transient failure.

Example:

```text
Attempt 1 → timeout
Attempt 2 → timeout
Attempt 3 → success
```

Retries can help with transient failures.

But retries can also make outages worse.

---

# 258. Why can retries be dangerous?

Suppose Service B is overloaded.

Service A receives:

```text
100 requests
```

Each request retries 3 times.

B could receive:

```text
300 attempts
```

instead of 100.

This can amplify the outage.

Therefore, use:

```text
limited retries
timeouts
backoff
jitter
idempotency
```

where appropriate.

---

# 259. What is exponential backoff?

Instead of retrying immediately:

```text
Retry 1 → 100 ms
Retry 2 → 200 ms
Retry 3 → 400 ms
Retry 4 → 800 ms
```

The waiting time increases.

This reduces immediate pressure on the failing dependency.

---

# 260. What is jitter?

Jitter adds randomness to retry delays.

Without jitter:

```text
1000 clients
   ↓
all retry at exactly 1 second
```

This can create a synchronized traffic spike.

With jitter:

```text
Client 1 → 0.8 sec
Client 2 → 1.1 sec
Client 3 → 1.4 sec
...
```

The retry load is spread out.

---

# 261. What is a circuit breaker?

A circuit breaker prevents repeatedly calling an unhealthy dependency.

Conceptually:

```text
CLOSED
  ↓ failures increase
OPEN
  ↓ reject calls quickly
HALF-OPEN
  ↓ test dependency
CLOSED
```

### CLOSED

Requests flow normally.

### OPEN

Calls are short-circuited.

### HALF-OPEN

A limited number of test calls determine whether recovery occurred.

---

# 262. Retry vs Circuit Breaker

### Retry

> Maybe the next attempt will succeed.

### Circuit breaker

> The dependency is unhealthy; stop hammering it.

They solve different problems and can be used together carefully.

---

# 263. What is bulkhead isolation?

Bulkheads prevent one failing dependency or workload from consuming all available resources.

Example:

```text
Application
 |
 +-- Payment thread pool
 |
 +-- Notification thread pool
 |
 +-- Order thread pool
```

If notifications become slow, their resource pool can become exhausted without necessarily consuming all resources needed by order processing.

This is analogous to compartments in a ship.

---

# SECTION 6 — DISTRIBUTED TRANSACTIONS

# 264. Why is @Transactional not enough across microservices?

Consider:

```text
Order Service
    ↓
Payment Service
    ↓
Inventory Service
```

Spring's local transaction normally controls a transaction within the relevant resource/context.

It does not magically make three independent services one ACID transaction.

This is a major interview trap.

---

# 265. How do you maintain consistency across microservices?

Common approaches include:

```text
Saga
Outbox Pattern
Events
Compensating Transactions
Idempotency
Eventual Consistency
```

---

# 266. What is the Saga pattern?

A Saga breaks a distributed business transaction into a sequence of local transactions.

Example:

```text
Create Order
    ↓
Reserve Inventory
    ↓
Process Payment
    ↓
Confirm Order
```

If payment fails:

```text
Cancel Order
    ↓
Release Inventory
```

These are compensating actions rather than one giant distributed database transaction.

---

# 267. What is the Outbox Pattern?

Suppose Order Service needs to:

```text
1. Save order
2. Publish OrderCreated event
```

Doing these independently can fail:

```text
DB commit succeeds
Event publishing fails
```

Now the database says order exists, but other services never receive the event.

The Outbox Pattern solves this by storing the event in the same local database transaction:

```text
Transaction
   |
   +--> Save Order
   |
   +--> Save Outbox Event
   |
   +--> COMMIT
```

A separate publisher later reads the outbox and publishes the event.

This provides a more reliable bridge between database state and messaging.

---

# SECTION 7 — KAFKA

# 268. What is Apache Kafka?

Kafka is a distributed event streaming platform.

Core concepts include:

```text
Topic
Partition
Producer
Consumer
Consumer Group
Offset
Broker
```

---

# 269. What is a Kafka topic?

A topic is a logical stream/category of records.

Example:

```text
orders
payments
inventory-events
```

Producers write records to topics.

Consumers read records from topics.

---

# 270. What is a partition?

A topic can be divided into partitions.

Example:

```text
orders
 |
 +-- Partition 0
 +-- Partition 1
 +-- Partition 2
```

Partitions provide scalability and parallelism.

---

# 271. Why is partitioning important?

Suppose:

```text
Topic
  ↓
10 partitions
```

Different consumers can process different partitions concurrently.

Therefore throughput can increase.

Ordering is guaranteed within a partition, not globally across all partitions.

---

# 272. What is a Kafka consumer group?

A consumer group is a group of consumers cooperating to consume a topic.

For a given consumer group:

```text
One partition
    ↓
At most one consumer within that group
```

can actively consume it at a time under normal assignment semantics.

Example:

```text
Topic: 4 partitions

Consumer Group:
C1 → P0, P1
C2 → P2
C3 → P3
```

This enables parallel consumption.

---

# 273. Can two different consumer groups consume the same Kafka topic?

Yes.

Example:

```text
orders topic
     |
     +---- Group A → Analytics
     |
     +---- Group B → Notifications
     |
     +---- Group C → Fraud Detection
```

Each group maintains its own consumption position.

---

# 274. What is a Kafka offset?

An offset identifies a record's position within a partition.

Conceptually:

```text
Partition 0

Offset 100
Offset 101
Offset 102
Offset 103
```

Consumers track their progress through offsets.

---

# 275. Does Kafka delete a message when a consumer reads it?

Not in the traditional queue sense.

Kafka retains records according to topic retention policies.

A consumer tracks its offset.

Therefore:

```text
Message read
    ≠
Message immediately deleted
```

This is an important difference from traditional queue mental models.

---

# 276. What is at-least-once delivery?

At-least-once means a message may be delivered more than once, but the system attempts not to lose it.

Therefore consumers should often be designed to handle duplicates.

Example:

```text
Event received
   ↓
Process
   ↓
Crash before offset commit
   ↓
Event delivered again
```

The consumer may process the event twice.

---

# 277. How do you make Kafka consumers idempotent?

Use an idempotency key/event ID.

Example:

```text
Event ID = payment-123
```

Before processing:

```text
Has payment-123 already been processed?
```

If yes:

```text
Skip duplicate
```

If no:

```text
Process
Record event ID
```

The storage mechanism for processed IDs depends on the architecture.

---

# 278. What is exactly-once processing?

"Exactly once" is often misunderstood.

Kafka can provide strong exactly-once semantics in specific Kafka processing scenarios, but **end-to-end exactly-once business effects** are much harder.

For example:

```text
Kafka transaction
    ≠
Database transaction
    ≠
External payment provider transaction
```

You should not casually claim:

> "Kafka guarantees exactly once everywhere."

Senior interviewers often use this as a trap.

---

# SECTION 8 — SPRING BOOT ACTUATOR AND OBSERVABILITY

# 279. What is Spring Boot Actuator?

Actuator provides production-oriented endpoints and features for monitoring and management.

Common capabilities include:

```text
Health
Metrics
Environment/configuration information
Application mappings
Loggers
Startup information
```

The exact exposed endpoints depend on configuration and version.

---

# 280. Why is Actuator useful?

It helps answer:

```text
Is the application healthy?

Are database dependencies healthy?

How many requests are happening?

How long are requests taking?

Are errors increasing?

Are JVM resources under pressure?
```

---

# 281. What are metrics?

Metrics are numerical measurements of system behavior.

Examples:

```text
Request count
Request latency
Error rate
JVM memory
CPU
Thread count
Database connection pool usage
Cache hits/misses
```

A useful production model is:

```text
Traffic
Errors
Latency
Saturation
```

---

# 282. What is distributed tracing?

Tracing follows a request across multiple services.

Example:

```text
Client
  |
  v
API Gateway
  |
  v
Order Service
  |
  v
Payment Service
  |
  v
Database
```

A trace allows you to understand where time was spent.

For example:

```text
Total request = 2.4 sec

Gateway = 20 ms
Order = 100 ms
Payment = 2.1 sec
```

Now the bottleneck is obvious.

---

# 283. Logs vs Metrics vs Traces

### Logs

Detailed events.

```text
"Payment failed for order 100"
```

### Metrics

Aggregated numerical measurements.

```text
payment_failure_rate = 2.3%
```

### Traces

Follow a request across components.

```text
Request
 → Order
 → Payment
 → Database
```

Strong production systems generally use all three.

---

# SECTION 9 — THREADING AND PRODUCTION

# 284. Is a Spring singleton bean thread-safe?

**No, not automatically.**

Singleton means Spring usually creates one bean instance per application context.

It does NOT mean:

```text
thread-safe
```

Bad:

```java
@Service
public class CounterService {

    private int counter;

    public void increment() {
        counter++;
    }
}
```

Multiple request threads can access the same instance concurrently.

---

# 285. Why are stateless Spring services preferred?

A stateless service stores request-specific state in local variables rather than mutable instance fields.

Good:

```java
public Order createOrder(CreateOrderRequest request) {

    BigDecimal amount = calculate(request);

    ...
}
```

Potentially dangerous:

```java
private CreateOrderRequest currentRequest;
```

because multiple requests may use the same singleton instance concurrently.

---

# 286. Can Spring singleton beans be used safely with multiple threads?

Yes, if they are designed to be thread-safe.

For example:

```java
@Service
public class OrderService {

    private final OrderRepository repository;

    public OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
```

Immutable dependencies and local variables are generally safer than mutable shared state.

---

# 287. What is a race condition?

A race condition occurs when the result depends on timing/order of concurrent operations.

Example:

```text
balance = 100

Thread A reads 100
Thread B reads 100

A subtracts 80
B subtracts 80

Both think sufficient balance exists.
```

Without proper concurrency control, the system can violate business rules.

---

# 288. synchronized vs database locking

`synchronized` protects code execution within a JVM/process.

It does not automatically coordinate multiple application instances.

Suppose:

```text
Instance A
Instance B
Instance C
```

A Java:

```java
synchronized
```

block on Instance A does not lock Instance B's JVM.

For distributed data consistency, database/distributed coordination mechanisms may be required.

---

# 289. Why is synchronized not enough in microservices?

Because:

```text
synchronized
    ↓
one JVM
```

while:

```text
microservice
    ↓
multiple JVM/container instances
```

If five instances process the same resource concurrently, each has its own JVM lock.

This is a classic senior interview trap.

---

# SECTION 10 — DATABASE AND PERFORMANCE SCENARIOS

# 290. How would you investigate a slow API?

I would work systematically:

```text
1. Check request latency metrics
2. Check application logs
3. Check distributed trace
4. Identify slow dependency
5. Inspect SQL execution
6. Check database indexes
7. Check connection pool
8. Check locks
9. Check external service latency
10. Check thread-pool saturation
```

Don't immediately rewrite code without measuring where the time is spent.

---

# 291. API response is slow, but SQL is fast. What could be wrong?

Possible causes:

```text
External API call
JSON serialization
Large response
Network latency
Thread pool waiting
Connection pool waiting
Lock contention
CPU-intensive processing
GC pauses
Cache miss
```

Database performance is only one part of request latency.

---

# 292. SQL is fast in the database console but slow from the application. Why?

Potential causes include:

```text
Different parameters
Different execution plans
Connection acquisition time
Network latency
Transaction/locking
ORM-generated SQL
Result-set processing
Object mapping
Application-side processing
```

Always compare the **actual SQL, parameters, execution plan, and surrounding timings**.

---

# 293. Why can an index improve query performance?

Without a suitable index, the database may scan many rows.

With an appropriate index:

```text
Query
 ↓
Index
 ↓
Relevant rows
```

However, indexes also have costs:

```text
INSERT cost
UPDATE cost
DELETE cost
Storage
Maintenance
```

Therefore, don't create indexes blindly.

---

# 294. Why can too many indexes hurt performance?

Every write may need to update multiple indexes.

Example:

```text
INSERT row
 ↓
Update table
 ↓
Update index 1
 ↓
Update index 2
 ↓
Update index 3
 ↓
Update index 4
```

So indexes improve reads but can increase write overhead and storage.

---

# SECTION 11 — SENIOR-LEVEL SPRING TRAPS

# 295. Does @Autowired make a class thread-safe?

No.

Dependency injection has nothing inherently to do with thread safety.

This:

```java
@Autowired
private UserRepository repository;
```

doesn't protect mutable shared fields.

---

# 296. Does @Transactional create a transaction every time the method is called?

Not necessarily.

Transaction behavior depends on:

```text
Proxy interception
Propagation
Existing transaction
Transaction manager
Invocation path
```

With default `REQUIRED`:

```text
Existing transaction?
    ↓
Yes → join it
No  → create one
```

---

# 297. Does @Transactional work when one method calls another method in the same class?

Potentially not as expected for proxy-based interception.

Example:

```java
public void methodA() {
    methodB();
}

@Transactional
public void methodB() {
}
```

The internal call can bypass the Spring proxy.

Therefore the transaction interceptor may not run for `methodB()` as an independently intercepted invocation.

---

# 298. Does @Async work with self-invocation?

Same fundamental problem.

```java
public void methodA() {
    methodB();
}

@Async
public void methodB() {
}
```

The internal invocation may bypass the proxy.

Therefore the asynchronous behavior may not be applied.

---

# 299. Does @Cacheable work with self-invocation?

Again, proxy-based interception is the key.

```java
public void methodA() {
    methodB();
}

@Cacheable("data")
public Data methodB() {
}
```

The internal call may bypass the cache interceptor.

This is why understanding Spring proxies is much more important than memorizing individual annotations.

---

# 300. What is the common concept behind @Transactional, @Async and @Cacheable?

A major common concept is:

```text
Spring AOP / Proxy-based interception
```

Conceptually:

```text
Caller
  ↓
Spring Proxy
  ↓
Interceptor
  ↓
Target Method
```

Depending on the annotation:

```text
@Transactional
    → transaction interceptor

@Async
    → async interceptor

@Cacheable
    → cache interceptor
```

This is one of the **highest-value concepts for Spring interviews**.

---

# SECTION 12 — REAL INTERVIEW SCENARIOS

# 301. Your payment API is called twice. How do you prevent duplicate payment?

I would design the operation to be idempotent.

For example:

```text
Client
  ↓
POST /payments
Idempotency-Key: payment-123
```

Server:

```text
Check idempotency record
       ↓
Already processed?
   ├── Yes → return previous result
   └── No
        ↓
    Process payment
        ↓
    Store result
```

The implementation must also consider concurrency so that two simultaneous requests with the same key cannot both execute the payment.

---

# 302. Two users buy the last available item simultaneously. How do you prevent overselling?

Possible solutions include:

```text
Optimistic locking
Pessimistic locking
Atomic SQL update
Database constraints
Inventory reservation
```

For example, an atomic update can conceptually be:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = ?
  AND quantity > 0;
```

Then verify that exactly one row was updated for the reservation attempt.

The best solution depends on scale and business requirements.

---

# 303. Order is saved but Kafka event isn't published. What do you do?

This is a classic distributed consistency problem.

Use an Outbox Pattern:

```text
Single DB transaction
    |
    +--> Save Order
    |
    +--> Save Outbox Event
    |
    +--> Commit
```

Then:

```text
Outbox Publisher
      ↓
Kafka
```

If Kafka is temporarily unavailable, the event remains in the outbox and can be retried.

---

# 304. Payment service is down. Should Order Service retry forever?

Absolutely not.

A better design might use:

```text
Timeout
+
Limited Retry
+
Exponential Backoff
+
Jitter
+
Circuit Breaker
+
Idempotency
```

For asynchronous workflows, an event-driven approach may be more appropriate.

---

# 305. One service is slow and the entire system becomes slow. Why?

Potential cascading failure:

```text
Service A
   ↓
Service B
   ↓
Service C (slow)
```

Threads in A wait for B.

B waits for C.

Eventually:

```text
Thread pools exhausted
Connection pools exhausted
Requests timeout
```

This is why distributed systems need:

```text
Timeouts
Circuit breakers
Bulkheads
Backpressure
Bounded queues
```

---

# 306. Your cache says balance = $100 but database says $50. Which one should you trust?

Usually the database is the authoritative source unless your architecture explicitly defines another source of truth.

The deeper question is:

> Why did cache and database diverge?

Investigate:

```text
Cache invalidation
Write ordering
Concurrent updates
TTL
Multiple application instances
Event delivery
Transaction boundaries
```

For financial data, stale cache should generally not be treated as authoritative.

---

# 307. How would you design a high-throughput order creation API?

A reasonable high-level design could be:

```text
Client
   ↓
API Gateway
   ↓
Order Service
   |
   +--> Validate request
   |
   +--> Idempotency check
   |
   +--> Persist Order
   |
   +--> Persist Outbox Event
   |
   +--> Commit
   |
   v
Kafka
   |
   +--> Inventory Service
   +--> Payment Service
   +--> Notification Service
```

Important concerns:

```text
Idempotency
Transactions
Concurrency
Event ordering
Retries
Dead-letter handling
Observability
Timeouts
Scalability
Data consistency
```

---

# SECTION 13 — TRICKY RAPID-FIRE QUESTIONS

## 308. Is Spring singleton the same as Java Singleton?

No.

Spring singleton means one bean instance per Spring IoC container/application context, whereas the classic Java Singleton pattern is a programming/design pattern with different scope and semantics.

---

## 309. Is @Component a singleton?

By default, Spring beans have singleton scope, so a `@Component` is normally singleton-scoped unless another scope is configured.

---

## 310. Is singleton bean thread-safe?

No.

Scope and thread safety are different concepts.

---

## 311. Is @Autowired responsible for object creation?

Spring's container manages bean creation and dependency injection.

`@Autowired` indicates a dependency injection point; it is not itself the entire object-creation mechanism.

---

## 312. Can you inject a prototype bean into a singleton?

Yes, but there is a catch.

If you directly inject a prototype bean into a singleton:

```text
Singleton
   ↓
Prototype dependency
```

the singleton normally receives one prototype instance at injection time.

It does **not** automatically receive a new prototype instance every time a method is called.

For dynamic lookup, mechanisms such as `ObjectProvider` can be used.

---

## 313. What happens if a singleton injects a prototype?

The prototype dependency is created according to prototype semantics when resolved/injected, but the singleton retains that injected reference.

Therefore:

```text
Singleton created
     ↓
Prototype instance A injected
     ↓
Singleton keeps A
```

It doesn't mean:

```text
every method call → new prototype
```

---

## 314. How can you obtain a new prototype instance each time?

For example:

```java
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
class TaskProcessor {
}
```

Then inject:

```java
private final ObjectProvider<TaskProcessor> provider;
```

and:

```java
TaskProcessor processor = provider.getObject();
```

This allows the container to resolve a new instance according to the prototype scope.

---

## 315. What is circular dependency?

Example:

```text
ServiceA → ServiceB
ServiceB → ServiceA
```

This creates a dependency cycle.

Modern Spring versions have stricter handling around circular references, and constructor-based cycles generally cannot simply be resolved automatically.

Best solution:

> Redesign the dependencies to remove the cycle.

Don't treat `@Lazy` as the universal solution.

---

# SECTION 14 — SCENARIO-BASED SENIOR QUESTIONS

# 316. Production suddenly has 100% CPU. What do you check?

I would investigate:

```text
1. CPU metrics
2. Thread dumps
3. Hot threads
4. Infinite loops
5. Excessive logging
6. Serialization/deserialization
7. Large collections
8. GC behavior
9. Expensive algorithms
10. Traffic increase
```

Then correlate with deployment and traffic changes.

---

# 317. Production suddenly has high memory usage. What do you check?

Look for:

```text
Heap usage
GC activity
Heap dump
Large collections
Caches without limits
Unbounded queues
Thread count
Large HTTP responses
Object retention
Memory leaks
```

A cache with no sensible size/expiration policy can become a memory problem.

---

# 318. Application has many threads waiting. What could be happening?

Potential causes:

```text
Database connection pool exhaustion
Slow external APIs
Lock contention
Thread pool exhaustion
Blocking I/O
Deadlock
Slow disk operations
```

A thread dump can reveal what the threads are waiting for.

---

# 319. What is a deadlock?

A deadlock occurs when threads/resources wait on each other indefinitely.

Example:

```text
Thread A
  holds Lock 1
  waits for Lock 2

Thread B
  holds Lock 2
  waits for Lock 1
```

Neither can proceed.

Databases can also experience transaction deadlocks.

---

# 320. How do you reduce deadlock risk?

Possible strategies:

```text
Consistent lock ordering
Short transactions
Avoid unnecessary locks
Appropriate indexes
Smaller units of work
Retry deadlock victims where appropriate
```

For example, if every transaction locks:

```text
Account A → Account B
```

in the same deterministic order, certain lock-order deadlocks can be avoided.

---

# 321. What is backpressure?

Backpressure means slowing producers when consumers cannot keep up.

Example:

```text
Producer
  ↓
100,000 events/sec

Consumer
  ↓
10,000 events/sec
```

Without control:

```text
Queue grows
   ↓
Memory grows
   ↓
System becomes unstable
```

Backpressure mechanisms prevent unlimited accumulation.

---

# SECTION 15 — VERY IMPORTANT INTERVIEW "WHY" QUESTIONS

# 322. Why use constructor injection?

Constructor injection makes dependencies explicit.

Example:

```java
@Service
public class OrderService {

    private final OrderRepository repository;

    public OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
```

Advantages:

```text
Explicit dependencies
Immutable fields
Easier unit testing
Fail-fast construction
No partially initialized object
```

---

# 323. Why is field injection often discouraged?

Example:

```java
@Autowired
private OrderRepository repository;
```

The dependency is hidden in the class definition and cannot be supplied directly through the constructor.

Constructor injection generally makes dependency requirements clearer and improves testability.

---

# 324. Why use interfaces for services/repositories?

Interfaces can provide abstraction and decoupling.

For example:

```java
public interface PaymentService {
    PaymentResult pay(PaymentRequest request);
}
```

But don't create interfaces mechanically for every class just because "Spring requires it."

Use abstractions where they provide value.

---

# 325. Why use final fields for dependencies?

Example:

```java
private final OrderRepository repository;
```

This communicates:

> This dependency should not change after construction.

It also works naturally with constructor injection.

---

# SECTION 16 — TOP 30 PART-3 QUESTIONS TO MASTER

If you have limited interview preparation time, prioritize these:

```text
1. Authentication vs Authorization

2. Explain SecurityFilterChain.

3. Explain Spring Security request flow.

4. Explain JWT internally.

5. Is JWT encrypted?

6. Access token vs refresh token.

7. CORS vs CSRF.

8. Password hashing.

9. @PreAuthorize.

10. @Cacheable vs @CachePut vs @CacheEvict.

11. Cache stampede.

12. Cache invalidation problems.

13. @Async internals.

14. @Async self-invocation problem.

15. Thread pool configuration.

16. Why singleton beans are not automatically thread-safe.

17. Microservice disadvantages.

18. API Gateway.

19. Service discovery.

20. Timeout vs retry.

21. Exponential backoff + jitter.

22. Circuit breaker.

23. Bulkhead pattern.

24. Why @Transactional doesn't create distributed transactions.

25. Saga pattern.

26. Outbox pattern.

27. Kafka topic/partition/consumer group/offset.

28. At-least-once delivery and idempotent consumers.

29. Optimistic locking and race conditions.

30. Production debugging methodology.
```

---

# SECTION 17 — THE ULTIMATE SPRING INTERVIEW MENTAL MODEL

When an interviewer asks:

> "What happens when a request comes into your Spring Boot application?"

A strong answer should mentally look like this:

```text
                    CLIENT
                       |
                       v
                 Load Balancer
                       |
                       v
                  API Gateway
                       |
                       v
              Servlet Container
                       |
                       v
               DispatcherServlet
                       |
                       v
             Spring Security Filters
                       |
                       v
                  Controller
                       |
                       v
                Spring Proxy
                       |
              +--------+--------+
              |                 |
              v                 v
        Transaction          Other AOP
              |
              v
             Service
              |
              v
          Repository
              |
              v
          EntityManager
              |
              v
       Persistence Context
              |
              v
           Hibernate
              |
              v
             JDBC
              |
              v
        Connection Pool
              |
              v
           DATABASE
```

For asynchronous/event-driven processing:

```text
Database
   |
   v
Outbox
   |
   v
Kafka
   |
   +----------+----------+
   |          |          |
   v          v          v
Inventory   Payment   Notification
```

For resilience:

```text
Service A
   |
   +--> Timeout
   |
   +--> Retry
   |
   +--> Backoff
   |
   +--> Circuit Breaker
   |
   +--> Bulkhead
   |
   v
Service B
```

For observability:

```text
Application
   |
   +--> Logs
   |
   +--> Metrics
   |
   +--> Traces
   |
   v
Monitoring / Observability Platform
```

---

# FINAL INTERVIEW RULE

For senior interviews, don't stop at:

> "We use @Transactional."

Explain:

```text
Where is the transaction boundary?
        ↓
Which transaction manager?
        ↓
How does Spring intercept it?
        ↓
What is the propagation?
        ↓
What is the isolation?
        ↓
What happens on exception?
        ↓
When does Hibernate flush?
        ↓
When does DB commit?
        ↓
What happens if another transaction modifies the same row?
```

Similarly, don't stop at:

> "We use Kafka."

Explain:

```text
Topic
 ↓
Partition
 ↓
Key
 ↓
Ordering
 ↓
Consumer Group
 ↓
Offset
 ↓
Delivery semantics
 ↓
Retry
 ↓
Duplicate handling
 ↓
Dead-letter strategy
 ↓
Idempotency
```

And don't stop at:

> "We use microservices."

Explain:

```text
Service boundaries
 ↓
Communication
 ↓
Timeouts
 ↓
Retries
 ↓
Circuit breaker
 ↓
Data ownership
 ↓
Consistency
 ↓
Events
 ↓
Observability
 ↓
Failure handling
```

That is the difference between an answer that sounds **memorized** and an answer that sounds like it comes from **real production experience**.

# END OF PART 3

## PART 1 + PART 2 + PART 3 COVERAGE

Together, the three parts now cover:

```text
SPRING CORE
✓ IoC
✓ DI
✓ Bean lifecycle
✓ Scopes
✓ @Component / @Service / @Repository
✓ @Configuration / @Bean
✓ Profiles
✓ Properties
✓ Environment
✓ AOP
✓ Proxies
✓ Circular dependencies

SPRING BOOT
✓ Auto-configuration
✓ Starters
✓ Application startup
✓ Configuration
✓ Profiles
✓ Actuator
✓ Production configuration

SPRING MVC / REST
✓ DispatcherServlet
✓ Controllers
✓ REST
✓ HTTP methods
✓ DTOs
✓ Validation
✓ Exception handling
✓ CORS

JPA / HIBERNATE
✓ Entity lifecycle
✓ Persistence Context
✓ First-level cache
✓ Dirty checking
✓ Flush
✓ Commit
✓ LAZY / EAGER
✓ N+1
✓ Relationships
✓ Cascade
✓ orphanRemoval
✓ JPQL
✓ Native SQL
✓ Projections

TRANSACTIONS
✓ ACID
✓ Isolation
✓ Propagation
✓ REQUIRED
✓ REQUIRES_NEW
✓ Rollback
✓ Self-invocation
✓ Optimistic locking
✓ Pessimistic locking
✓ Lost updates

SECURITY
✓ Authentication
✓ Authorization
✓ Security filters
✓ SecurityContext
✓ JWT
✓ Access/refresh tokens
✓ CORS
✓ CSRF
✓ Password hashing
✓ Method security

CACHING
✓ @Cacheable
✓ @CachePut
✓ @CacheEvict
✓ Cache invalidation
✓ Cache stampede

ASYNC
✓ @Async
✓ Thread pools
✓ Self-invocation
✓ Async exceptions
✓ Concurrency

MICROSERVICES
✓ API Gateway
✓ Service discovery
✓ Timeouts
✓ Retry
✓ Backoff
✓ Jitter
✓ Circuit breaker
✓ Bulkhead
✓ Saga
✓ Outbox
✓ Eventual consistency

KAFKA
✓ Topic
✓ Partition
✓ Consumer
✓ Consumer group
✓ Offset
✓ Ordering
✓ At-least-once
✓ Idempotency
✓ Exactly-once concepts

PRODUCTION
✓ Thread pools
✓ DB connection pools
✓ Slow APIs
✓ Slow SQL
✓ CPU problems
✓ Memory problems
✓ Deadlocks
✓ Race conditions
✓ Backpressure
✓ Logs
✓ Metrics
✓ Tracing
```