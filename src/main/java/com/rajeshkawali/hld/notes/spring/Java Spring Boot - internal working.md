# Java & Spring Boot Backend


## Table of Contents

1. Tomcat Architecture and Request Flow
2. Spring Boot Internal Working
3. @EnableAutoConfiguration Internals
4. API Request Flow: Client to Server
5. TCP, UDP, HTTP, gRPC, and WebSocket
6. Spring Transactions and Internals
7. Redis Strategies and Eviction
8. Load Balancers and Algorithms
9. Spring Security Internals
10. OAuth 2.0 and JWT
11. Industry-Standard Spring Boot API Design
12. Spring Bean Lifecycle and Scopes
13. Hibernate/JPA Internals, Lazy Loading, and N+1 Queries
14. Kafka: Partitions, Consumer Groups, and Delivery Semantics
15. Microservices, Saga, Outbox, and Distributed Tracing
16. Docker, Kubernetes, and Deployment Strategies
17. Database Indexing, Locking, and Query Optimization
18. Resilience4j, Rate Limiting, and Circuit Breakers
19. Rapid Revision Questions
20. Template for New Topics
21. Corrections and Interview-Ready Spring Boot Summary


---

## 1. Tomcat architecture and request flow

### What is Tomcat?
- **Apache Tomcat** is a Java web server and Servlet container.
- It receives HTTP requests and runs Java Servlet-based applications.
- In Spring Boot MVC applications, Tomcat is often the **embedded** web server.
- Tomcat is **not** the Spring framework; Spring MVC uses Tomcat's Servlet infrastructure.

### Main components
- **Server:** Top-level Tomcat instance; manages services and lifecycle.
- **Service:** Associates one **Engine** (container) with one or more **Connectors**.
- **Connector:** Listens on a port (often `8080`), manages connections, parses HTTP, and writes responses.
- **Engine:** Routes a request to the correct virtual host.
- **Host:** Represents a virtual host/domain.
- **Context:** Represents a deployed web application.
- **Wrapper:** Represents an individual Servlet.
- **Servlet filters:** Intercept requests/responses before and after the Servlet.
- **Thread pool:** Executes request processing using worker threads in a typical blocking Servlet setup.

### Request flow
```text
Browser / API Client
       |
       v
TCP connection -> Tomcat Connector (e.g., NIO HTTP/1.1)
       |
       v
HTTP parsing -> request processing / worker thread
       |
       v
Engine -> Host -> Context -> Servlet mapping
       |
       v
Servlet Filter Chain
       |
       v
Spring DispatcherServlet
       |
       v
Controller -> Service -> Repository -> Database
       |
       v
HTTP response <- DispatcherServlet <- Tomcat Connector
```

### Internal details
- Tomcat NIO connectors can use nonblocking I/O to manage network connections efficiently.
- A typical synchronous Spring MVC request still occupies a worker thread during blocking application work.
- `DispatcherServlet` is the central Spring MVC Servlet; Tomcat invokes it.
- Tomcat handles networking and Servlet execution; Spring MVC handles handler mapping and controller invocation.
- Connection handling, request threads, and DB connection pools are **different resources**.

### Example
```java
@RestController
@RequestMapping("/hello")
class HelloController {
    @GetMapping
    String hello() {
        return "Hello from Spring Boot on Tomcat";
    }
}
```
- Request: `GET http://localhost:8080/hello`.
- Tomcat accepts the connection and dispatches to Spring's `DispatcherServlet`.
- Spring maps `/hello` to `hello()` and serializes the returned String as the response body.

### Interview answer
- **Q: Does Tomcat directly call a Spring controller?**
  - No. Tomcat invokes the Servlet; Spring's `DispatcherServlet` resolves and invokes the controller.
- **Q: What happens when all request threads are busy?**
  - Additional requests may wait in connection/request queues or be rejected/time out, depending on connector configuration and resource limits.
- **Q: Embedded vs external Tomcat?**
  - Embedded Tomcat starts inside the Spring Boot process; external Tomcat deploys the app into an independently managed server.

---

## 2. Spring Boot internal working

### What is Spring Boot?
- Spring Boot simplifies Spring application setup using starter dependencies, auto-configuration, and embedded servers.
- It still uses the **Spring IoC container**, **dependency injection**, and the **Spring MVC** framework where applicable.
- Spring Boot is opinionated, but most defaults can be overridden.

### Startup flow
```text
main() -> SpringApplication.run()
       -> Determine application type (Servlet / Reactive / None)
       -> Prepare Environment and load configuration
       -> Create the appropriate ApplicationContext
       -> Load bean definitions (component scan, @Bean, auto-configuration)
       -> Refresh context: register post-processors, create and wire beans
          (the embedded web server is created/started during web-context refresh)
       -> Publish started event; run ApplicationRunner / CommandLineRunner
       -> Publish ready event (if startup completes successfully)
```

### Important concepts
- **IoC container:** Creates, wires, and manages Spring beans.
- **Bean:** An object managed by the Spring container; not every Java object is a Spring bean.
- **Component scan:** Discovers eligible annotated classes in the configured scan packages (normally the application package and its subpackages).
- **Dependency injection:** Supplies dependencies, preferably through constructors.
- **Starter:** Dependency bundle such as `spring-boot-starter-web`.
- **Auto-configuration:** Contributes configuration and bean definitions when relevant conditions match; custom beans can often override defaults.
- **Externalized configuration:** Reads properties from files, environment variables, and other sources with precedence rules.
- **Actuator:** Exposes operational endpoints such as health and metrics when configured.

### Example
```java
@SpringBootApplication
public class ShopApplication {
    public static void main(String[] args) {
        SpringApplication.run(ShopApplication.class, args);
    }
}

@Service
class PriceService {
    int discountedPrice(int price) { return price - 10; }
}

@RestController
class PriceController {
    private final PriceService priceService;

    PriceController(PriceService priceService) {
        this.priceService = priceService;
    }

    @GetMapping("/price")
    int price() { return priceService.discountedPrice(100); }
}
```
- Spring scans the classes, registers beans, and injects `PriceService` into `PriceController`.
- The response from `GET /price` is `90`.

### Interview answer
- **Q: Why use constructor injection?**
  - It makes dependencies explicit, supports immutable fields, and simplifies unit testing.
- **Q: Is Spring Boot a replacement for Spring?**
  - No. It configures and runs Spring applications with less manual setup.
- **Q: When is a bean created?**
  - Most singleton beans are initialized during context refresh; lazy/prototype beans differ.

---

## 3. @EnableAutoConfiguration internals

### Purpose
- `@EnableAutoConfiguration` tells Spring Boot to consider configuration classes based on classpath libraries, properties, and existing beans.
- `@SpringBootApplication` includes `@EnableAutoConfiguration` alongside `@SpringBootConfiguration` and `@ComponentScan`.
- It does **not** blindly create every possible bean.

### Internal flow (modern Spring Boot 3.x / 4.x approach)
```text
@SpringBootApplication
       |
@EnableAutoConfiguration
       |
@Import(AutoConfigurationImportSelector.class)
       |
Read META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
       |
Filter exclusions / evaluate conditions
       |
Register matching auto-configuration classes
       |
Create eligible bean definitions -> instantiate beans
```

### Common conditions
- `@ConditionalOnClass`: Configure only if a library/class is present.
- `@ConditionalOnMissingBean`: Back off when the application already defines a bean.
- `@ConditionalOnProperty`: Enable behavior based on a property.
- `@ConditionalOnBean`: Requires an existing bean.
- `@ConditionalOnWebApplication`: Requires a matching web application type.
- `@ConditionalOnResource`: Requires a particular resource.
- Conditions may be checked at different phases; **configuration order matters** for some conditions.

### Example: custom auto-configuration
```java
@AutoConfiguration
@ConditionalOnClass(NotificationClient.class)
public class NotificationAutoConfiguration {
    @Bean
    @ConditionalOnMissingBean
    NotificationClient notificationClient() {
        return new NotificationClient();
    }
}

class NotificationClient {
    String send() { return "sent"; }
}
```
- For a reusable starter, list the auto-configuration class in:
  - `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`
- File content (fully qualified class name):
```text
com.example.autoconfigure.NotificationAutoConfiguration
```
- If an application provides its own `NotificationClient` bean, `@ConditionalOnMissingBean` allows it to take precedence.
- In older Spring Boot 2.x codebases, you may encounter `spring.factories`; do not confuse it with the modern auto-configuration imports mechanism.

### Debugging
- Run with `--debug` to inspect the conditions evaluation report.
- Inspect Actuator's `conditions` endpoint when available and securely exposed.
- Exclude specific auto-configurations using `@SpringBootApplication(exclude = ...)` or `spring.autoconfigure.exclude`.

### Interview answer
- **Q: How does Boot know what to configure?**
  - It loads auto-configuration candidates and evaluates conditional annotations.
- **Q: How do you override auto-configuration?**
  - Define your own bean, configure properties, or exclude the auto-configuration as appropriate.

---

## 4. API request flow: client to server

### End-to-end request flow
```text
Client -> DNS lookup -> TCP connection -> TLS handshake (HTTPS)
       -> CDN / WAF / reverse proxy / load balancer (if present)
       -> Application server (Tomcat)
       -> Servlet filters / Spring Security
       -> DispatcherServlet -> HandlerMapping
       -> HandlerAdapter -> Controller
       -> Service -> Repository -> Database / Cache
       -> Response serialization -> HTTP response -> Client
```

### Step by step
- **1. URL:** Client prepares method, path, headers, and optional request body.
- **2. DNS:** Resolves the hostname to an IP address (unless already cached/resolved).
- **3. Transport:** Usually opens/reuses a TCP connection; HTTPS negotiates TLS (HTTP/3 uses QUIC over UDP).
- **4. Edge layer:** Optional proxy/load balancer applies routing, rate limits, and TLS termination.
- **5. Server:** Tomcat parses HTTP and invokes the Servlet filter chain.
- **6. Security:** Spring Security authenticates the request and checks authorization.
- **7. Routing:** `DispatcherServlet` locates the controller handler using `HandlerMapping`.
- **8. Binding:** Spring converts JSON/parameters to Java objects and validates inputs.
- **9. Business logic:** Service executes rules; repository reads/writes data.
- **10. Result:** Spring serializes response (often Jackson JSON) and sends status/headers/body.
- **11. Failure:** Exceptions may be mapped by `@RestControllerAdvice` into a consistent error response.

### Example request and response
```http
POST /api/v1/orders HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer <access-token>

{"productId":42,"quantity":2}
```
```http
HTTP/1.1 201 Created
Location: /api/v1/orders/1001
Content-Type: application/json

{"id":1001,"productId":42,"quantity":2,"status":"CREATED"}
```

### Interview distinctions
- **Filter:** Servlet-level cross-cutting behavior, e.g., security or tracing.
- **Interceptor:** Spring MVC handler-level hooks, e.g., handler timing.
- **Controller:** HTTP contract, input validation, status and response shaping.
- **Service:** Business rules and transaction boundaries.
- **Repository:** Persistence operations.
- **Connection pool:** Reuses DB connections; separate from HTTP connection management.

---

## 5. TCP, UDP, HTTP, gRPC and WebSocket

### Important distinction
- **TCP and UDP** are transport-layer protocols.
- **HTTP** is an application-layer protocol; HTTP/1.1 and HTTP/2 commonly use TCP, while HTTP/3 uses QUIC over UDP.
- **gRPC** is an RPC framework, commonly using HTTP/2 and Protocol Buffers.
- **WebSocket** is a full-duplex application protocol, often established through an HTTP upgrade handshake (HTTP/1.1) or extended CONNECT (HTTP/2).

| Technology | How it works | Best suited for | Key trade-off |
|---|---|---|---|
| **TCP** | Connection-oriented, reliable, ordered byte stream; acknowledgments and retransmission | Web traffic, DB connections, file transfer | Reliability can add latency and head-of-line blocking |
| **UDP** | Connectionless datagrams; no built-in delivery/order guarantees | Real-time games, VoIP, DNS, telemetry | Application must handle reliability if required |
| **HTTP REST** | Request/response over HTTP; often JSON | Public APIs, CRUD, browser/mobile integrations | More payload overhead than compact binary RPC |
| **gRPC** | Contract-first RPC, Protobuf, HTTP/2; supports streaming | Internal microservice-to-microservice calls | Browser support and debugging can require extra tooling |
| **WebSocket** | Persistent, bidirectional messages after handshake | Chat, live dashboards, collaborative editing | Requires connection lifecycle and scale management |

### TCP working
```text
Client -> SYN -> Server
Client <- SYN-ACK <- Server
Client -> ACK -> Server
        Data exchange
```
- TCP sequence numbers preserve byte ordering.
- Retransmission helps recover lost data.
- Flow and congestion control manage receiver/network capacity.
- TCP is a **byte stream**, not a message-boundary protocol.

### UDP working
```text
Sender -> datagram 1 -> Receiver
Sender -> datagram 2 -> Receiver (may arrive first or not arrive)
```
- No transport handshake is required.
- Lower overhead does not automatically guarantee lower end-to-end latency.
- QUIC builds secure, reliable streams over UDP; it is not raw unreliable UDP messaging.

### gRPC working
```text
service OrderService {
  rpc GetOrder(GetOrderRequest) returns (OrderResponse);
}
```
- Define methods/messages in `.proto`.
- Generate strongly typed client/server stubs.
- Client calls a stub; gRPC serializes Protobuf and sends it over HTTP/2.
- Supports **unary**, **server streaming**, **client streaming**, and **bidirectional streaming**.
- Use deadlines, retries (only where safe), TLS, and observability.

### WebSocket working
```text
Client -- HTTP handshake --> Server
Client <-- upgrade/accept -- Server
Client <---- messages ----> Server
```
- Once established, both sides can send messages independently.
- Add authentication, heartbeat/ping-pong, reconnect, and backpressure handling.
- For one-way browser updates, **Server-Sent Events (SSE)** may be simpler.

### How to choose
- **CRUD/public API:** HTTP REST with JSON.
- **Low-latency typed internal RPC:** gRPC.
- **Real-time two-way messaging:** WebSocket.
- **Real-time voice/game datagrams:** UDP or higher-level protocols built on it.
- **Reliable custom transport:** TCP (but avoid inventing an application protocol without a good reason).
- **Simple server-to-browser notifications:** SSE.

### Interview answer
- **Q: Is gRPC faster than REST?**
  - Often efficient for internal RPC, but actual performance depends on payloads, network, infrastructure, and workload; benchmark.
- **Q: Is WebSocket always better for live updates?**
  - No. SSE is often easier for one-directional updates.

---

## 6. Spring transactions and internals

### What is a transaction?
- A transaction groups operations that should succeed or fail together.
- **ACID:** Atomicity, Consistency, Isolation, Durability (as supported by the database and configuration).
- Spring's `@Transactional` defines transaction behavior around a method invocation.

### Internal working (typical proxy mode)
```text
Caller -> Spring AOP proxy -> TransactionInterceptor
       -> PlatformTransactionManager
       -> Begin/join transaction; bind resources to thread
       -> Invoke service method -> repository / JDBC / JPA
       -> Commit on success OR rollback on matching exception
       -> Cleanup resources -> return
```

### Example
```java
@Service
class TransferService {
    private final AccountRepository accounts;

    TransferService(AccountRepository accounts) {
        this.accounts = accounts;
    }

    @Transactional
    public void transfer(long fromId, long toId, int amount) {
        Account from = accounts.findById(fromId).orElseThrow();
        Account to = accounts.findById(toId).orElseThrow();
        if (from.getBalance() < amount) throw new IllegalStateException("Insufficient funds");
        from.setBalance(from.getBalance() - amount);
        to.setBalance(to.getBalance() + amount);
        // JPA dirty checking writes changes at flush/commit for managed entities.
    }
}
```
- If a matching exception triggers rollback, neither balance change should commit.
- Real payment systems also need concurrency controls and idempotency.

### Propagation
- **REQUIRED (default):** Join an existing transaction or start one.
- **REQUIRES_NEW:** Suspend existing transaction and start an independent one.
- **SUPPORTS:** Use a transaction if one exists; otherwise run without one.
- **MANDATORY:** Fail if no transaction exists.
- **NOT_SUPPORTED:** Run without a transaction, suspending any existing one.
- **NEVER:** Fail if a transaction exists.
- **NESTED:** Use savepoints when supported by the transaction manager/resource.

### Isolation levels
- **READ_UNCOMMITTED:** Can allow dirty reads (database-dependent).
- **READ_COMMITTED:** Prevents dirty reads; non-repeatable reads may occur.
- **REPEATABLE_READ:** Typically prevents non-repeatable reads; phantom behavior varies by database/implementation.
- **SERIALIZABLE:** Strongest standard isolation; lower concurrency / possible retries.
- **DEFAULT:** Uses the database default isolation.
- Isolation is not a replacement for correct locking or optimistic version checks.

### Rollback and common pitfalls
- By default, Spring rolls back on `RuntimeException` and `Error`, **not** ordinary checked exceptions.
- Use `@Transactional(rollbackFor = Exception.class)` when checked exceptions must trigger rollback.
- **Self-invocation:** `this.someTransactionalMethod()` bypasses the Spring proxy in normal proxy mode.
- **Non-Spring-managed objects:** `new Service()` bypasses proxy-based transactions.
- **Private methods:** Do not rely on proxy-based `@Transactional` interception for private methods.
- **External APIs:** Database rollback cannot undo an already-sent email/payment/API call.
- **Long transactions:** Increase lock duration and DB resource pressure.
- **Async work:** Thread-bound transactions do not automatically carry into another thread.
- **Multiple services/databases:** A local transaction is not a distributed transaction; consider saga/outbox patterns.

### Interview answer
- **Q: Why does @Transactional sometimes not work?**
  - Most commonly self-invocation, missing Spring proxy, incorrect exception expectations, or an unsupported transaction manager/resource.
- **Q: Where should it be placed?**
  - Usually on service methods that represent one business unit of work.

---

## 7. Redis strategies and eviction

### What is Redis?
- Redis is a high-performance in-memory data store, often used as a cache, session store, rate limiter, and for queues/streams.
- Common types: **String, Hash, List, Set, Sorted Set, Stream**.
- Redis can persist data, but durability depends on configuration and deployment.

### Caching strategies
- **Cache-aside (lazy loading):** App checks cache, then DB on miss, then fills cache.
- **Read-through:** Cache abstraction fetches from backing store on miss.
- **Write-through:** Writes update cache and backing store synchronously through a coordinated layer.
- **Write-behind/write-back:** Cache buffers writes for later persistence; faster but adds loss/consistency risk.
- **Write-around:** Write to DB; populate cache on a later read.

### Cache-aside flow
```text
GET /products/42
       |
Redis GET product:42
       | hit -> return cached value
       | miss
       v
Database SELECT -> Redis SET with TTL -> return
```

### Example using Spring Cache
```java
@Configuration
@EnableCaching
class CacheConfig {}

@Service
class ProductService {
    private final ProductRepository repository;
    ProductService(ProductRepository repository) { this.repository = repository; }

    @Cacheable(cacheNames = "products", key = "#id")
    public Product getProduct(Long id) {
        return repository.findById(id).orElseThrow();
    }

    @CacheEvict(cacheNames = "products", key = "#id")
    public void evictProduct(Long id) { }
}
```
- Configure `RedisCacheManager` and TTL through Spring Boot/Spring Data Redis.
- Cache annotation behavior is proxy-based in typical Spring configurations; self-invocation can bypass it.
- Ensure cache invalidation follows successful DB updates; consider transaction timing.

### Redis expiration vs eviction
- **Expiration:** Key disappears after its TTL, using passive and active expiration mechanisms.
- **Eviction:** Redis removes keys when configured memory limits/policies require space.
- Configure `maxmemory` and `maxmemory-policy` appropriately.

### Common eviction policies
| Policy | Meaning | When useful |
|---|---|---|
| `noeviction` | Reject memory-growing writes when over limit (subject to command behavior) | Data you must not silently evict |
| `allkeys-lru` | Approximate least recently used across all keys | General-purpose cache |
| `allkeys-lfu` | Approximate least frequently used across all keys | Stable hot-key workloads |
| `allkeys-random` | Random eviction across all keys | Simple workloads with similar access |
| `volatile-lru` | Approximate LRU among keys with TTL | Mixed cache/persistent-key deployments |
| `volatile-lfu` | Approximate LFU among keys with TTL | TTL-limited frequently used items |
| `volatile-ttl` | Prefer keys with shortest remaining TTL | When near-expiry data should go first |
| `volatile-random` | Random among TTL keys | Simple TTL-only eviction |

### Operational best practices
- Use TTLs with **jitter** to avoid simultaneous expiration spikes.
- Prevent **cache stampedes** with request coalescing/locking or stale-while-revalidate where suitable.
- Prevent **cache penetration** with validation, negative caching, or Bloom filters.
- Avoid **hot keys** by monitoring traffic and distributing load where feasible.
- Avoid caching secrets or sensitive data without appropriate controls.
- Monitor hit ratio, evictions, memory fragmentation, latency, and replication health.
- Choose a strategy based on tolerated staleness and consistency requirements.

### Interview answer
- **Q: LRU vs LFU?**
  - LRU favors recently accessed keys; LFU favors frequently accessed keys.
- **Q: Does a TTL guarantee immediate deletion at the exact millisecond?**
  - No. Expired keys are logically unavailable; physical removal can occur via passive or active expiration.

---

## 8. Load balancers and algorithms

### What is a load balancer?
- A load balancer distributes incoming traffic across healthy application instances.
- Benefits: availability, capacity, maintenance, and controlled traffic routing.
- **L4:** Routes using transport information such as IP and port.
- **L7:** Routes using HTTP details such as host, path, or headers.

### Flow
```text
Client -> DNS -> Load Balancer
                     | health checks
                     +--> App instance A
                     +--> App instance B
                     +--> App instance C
```

### Common algorithms
| Algorithm | How it chooses | Use case / limitation |
|---|---|---|
| Round robin | Next server in rotation | Similar-capacity stateless servers |
| Weighted round robin | More requests to higher-weight servers | Different server capacities |
| Least connections | Server with fewest active connections | Long-lived connections; not always least work |
| Weighted least connections | Connection count adjusted by weight | Unequal capacities |
| Least response time | Uses observed latency/load signals | Dynamic workloads; metric sensitivity |
| Random / power of two choices | Random server or choose less loaded of two | Simple, scalable balancing |
| IP hash / consistent hashing | Deterministic mapping by key | Affinity/sharding; skew and rebalancing risks |

### Example
- Servers A, B, C use round robin.
- Requests `R1..R6` go `A, B, C, A, B, C` if all are healthy.
- With weights `A:2, B:1`, a weighted strategy aims for roughly twice as much traffic to A over time; exact ordering depends on implementation.

### Production best practices
- Use readiness/health checks and stop routing to unhealthy instances.
- Configure timeouts, connection limits, and connection draining for deployments.
- Keep APIs stateless where possible; store shared session data outside an instance if required.
- TLS can terminate at the balancer or be passed through, depending on architecture.
- Retries must be bounded and safe for non-idempotent operations.
- Sticky sessions can help legacy apps but complicate scaling and failover.
- Rate limiting and circuit breakers solve different problems from load balancing.

### Interview answer
- **Q: Load balancer vs API gateway?**
  - Load balancer primarily distributes traffic; API gateway often also handles auth, routing, quotas, and API-specific policies.
- **Q: Can load balancing prevent all outages?**
  - No. Shared DB failures, bad deployments, and overloaded dependencies still affect service health.

---

## 9. Spring Security internals

### What is Spring Security?
- A framework for authentication, authorization, and common web security defenses.
- **Authentication:** Who are you? (Verification of identity or credentials.)
- **Authorization:** Are you allowed to do this? (Requires both endpoint and resource-level checks where appropriate.)
- Spring Security commonly runs through Servlet filters **before** the controller.

### Internal request flow
```text
Request -> Servlet container
        -> DelegatingFilterProxy
        -> FilterChainProxy
        -> matching SecurityFilterChain
        -> authentication filter / token validation
        -> SecurityContext (authenticated principal)
        -> authorization check
        -> DispatcherServlet -> Controller
```

### Key components
- **SecurityFilterChain:** Ordered security filters for matching requests.
- **Authentication:** Principal, credentials (when relevant), and authorities.
- **AuthenticationManager:** Coordinates authentication.
- **AuthenticationProvider:** Verifies a particular authentication type.
- **UserDetailsService:** Loads user information for certain username/password flows.
- **PasswordEncoder:** Securely hashes/verifies passwords, e.g., BCrypt or Argon2.
- **SecurityContextHolder:** Holds the current security context (commonly thread-local for synchronous requests).
- **AuthorizationFilter:** Applies authorization rules in modern configurations.
- **ExceptionTranslationFilter:** Bridges certain auth/authz exceptions to HTTP responses.

### Example: JWT-protected API (Spring Security 6-style)
```java
@Configuration
@EnableWebSecurity
class SecurityConfig {
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Only for stateless APIs not relying on browser cookies
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/products/**").permitAll()
                .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        return http.build();
    }
}
```
- Imports omitted for brevity.
- Configure a trusted issuer/JWK set and token validation properties separately.
- Disabling CSRF is **not** universally correct; cookie-based browser sessions generally need CSRF protection.

### What happens with a bearer token?
- Security filter reads `Authorization: Bearer <token>`.
- Resource server validates JWT signature and relevant claims.
- Successful authentication creates an authenticated security context.
- Authorization rules check roles/scopes/permissions.
- Request proceeds to controller if permitted.

### 401 vs 403
- **401 Unauthorized:** Authentication is missing or invalid for a protected resource (despite the HTTP status name).
- **403 Forbidden:** Identity may be known, but access is denied (or a security policy blocks the request).

### Best practices
- Use HTTPS; never store plaintext passwords.
- Apply least privilege and method-level checks where appropriate.
- Validate audience, issuer, signature, and expiry for JWTs.
- Restrict CORS to allowed origins/methods/headers; CORS is not authentication.
- Configure CSRF according to credential transport and browser threat model.
- Avoid logging bearer tokens, passwords, or sensitive personal data.

---

## 10. OAuth 2.0 and JWT

### Know the difference
- **OAuth 2.0:** Framework for delegated authorization.
- **OpenID Connect (OIDC):** Identity layer on OAuth 2.0 for user login/authentication.
- **JWT:** A compact token format containing claims; not itself an authorization protocol.
- OAuth access tokens can be **opaque** or **JWT**; they are not always JWTs.

### OAuth 2.0 roles
- **Resource owner:** User or entity controlling protected data.
- **Client:** App requesting access.
- **Authorization server:** Authenticates/authorizes and issues tokens.
- **Resource server:** API that validates tokens and protects resources.

### Authorization Code + PKCE flow (common user login / delegated access)
```text
User -> Client app -> Authorization server /authorize + code_challenge
User authenticates and approves requested scopes
Authorization server -> Redirect with authorization code
Client -> /token with code + code_verifier
Authorization server -> Access token (+ optional refresh / ID token)
Client -> Resource API with access token
Resource API -> Validates token and scopes -> Response
```
- **PKCE** helps protect the authorization code from interception/reuse.
- Use exact registered redirect URIs, `state` for request correlation/CSRF protection, and `nonce` when required by OIDC.
- **Client credentials flow:** Machine-to-machine access without a user.
- **Refresh token:** Gets new access tokens; protect it and rotate when supported.
- Avoid legacy password grant and implicit flow for new designs.

### JWT structure
```text
BASE64URL(header).BASE64URL(payload).BASE64URL(signature)
```
```json
{
  "sub": "user-123",
  "iss": "https://auth.example.com",
  "aud": "orders-api",
  "scope": "orders:read",
  "iat": 1760000000,
  "exp": 1760000900
}
```
- **Header:** Signing algorithm and optional key identifier.
- **Payload:** Claims such as `sub`, `iss`, `aud`, `exp`.
- **Signature:** Detects tampering and verifies the signer with the correct key.
- A normal signed JWT (JWS) is **encoded, not encrypted**; do not put secrets in the payload.
- JWT validation must restrict accepted algorithms and validate issuer/audience/expiry, not merely decode the payload.

### JWT request flow
```text
Client -> Authorization: Bearer <JWT> -> API
API -> verify signature + issuer + audience + expiry + scopes
    -> build authenticated principal
    -> allow or deny endpoint
```

### Token storage and revocation
- Keep access tokens short-lived; use refresh tokens where appropriate.
- For browser apps, weigh secure `HttpOnly`, `Secure`, `SameSite` cookies and CSRF protection against in-memory bearer token approaches.
- Avoid persisting sensitive tokens in browser local storage when XSS risk matters.
- JWTs are not automatically revocable before expiry; use short TTLs, deny lists, key rotation, or introspection/reference tokens when needed.

### Interview answer
- **Q: OAuth vs JWT?**
  - OAuth defines delegated authorization flows; JWT is one possible token representation.
- **Q: OAuth vs OIDC?**
  - OAuth is for delegated authorization; OIDC adds standardized identity/login information.
- **Q: Is JWT stateless?**
  - Signature verification can be stateless, but revocation, sessions, and authorization decisions may still require state.

---

## 11. Industry-standard Spring Boot API design

### Core design principles
- Design **resource-oriented**, predictable HTTP endpoints.
- Separate transport contracts (**DTOs**) from JPA entities.
- Keep controllers thin; place business logic in services.
- Validate at API boundaries and enforce business invariants in services/domain logic.
- Use standard HTTP status codes and consistent errors.
- Prefer idempotency, observability, security, and backward compatibility from the start.

### Example REST endpoints
| Operation | Endpoint | Typical status |
|---|---|---|
| List products | `GET /api/v1/products` | `200 OK` |
| Get product | `GET /api/v1/products/{id}` | `200 OK` or `404 Not Found` |
| Create product | `POST /api/v1/products` | `201 Created` |
| Replace product | `PUT /api/v1/products/{id}` | `200 OK` or `204 No Content` |
| Partially update | `PATCH /api/v1/products/{id}` | `200 OK` or `204 No Content` |
| Delete product | `DELETE /api/v1/products/{id}` | `204 No Content` |

### Suggested project structure
```text
src/main/java/com/example/shop/
  ShopApplication.java
  config/
  security/
  common/
    exception/
    response/
  product/
    ProductController.java
    ProductService.java
    ProductRepository.java
    Product.java
    dto/
      CreateProductRequest.java
      ProductResponse.java
  order/
    OrderController.java
    OrderService.java
    OrderRepository.java
    dto/
src/main/resources/
  application.yml
src/test/java/com/example/shop/
```
- Group by **feature/domain** for growing systems; keep shared utilities small.
- Add package boundaries and modules as complexity grows, not just for appearance.

### Example: DTO + validation + service + controller
```java
// Imports omitted; Java 17+ records and Jakarta Validation are assumed.
public record CreateProductRequest(
    @NotBlank String name,
    @Positive BigDecimal price
) {}

public record ProductResponse(Long id, String name, BigDecimal price) {}

@Entity
class Product {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private BigDecimal price;
    protected Product() {}
    Product(String name, BigDecimal price) {
        this.name = name;
        this.price = price;
    }
    Long getId() { return id; }
    String getName() { return name; }
    BigDecimal getPrice() { return price; }
}

interface ProductRepository extends JpaRepository<Product, Long> {}

@Service
class ProductService {
    private final ProductRepository repository;
    ProductService(ProductRepository repository) { this.repository = repository; }

    @Transactional
    ProductResponse create(CreateProductRequest request) {
        Product saved = repository.save(new Product(request.name(), request.price()));
        return new ProductResponse(saved.getId(), saved.getName(), saved.getPrice());
    }
}

@RestController
@RequestMapping("/api/v1/products")
class ProductController {
    private final ProductService service;
    ProductController(ProductService service) { this.service = service; }

    @PostMapping
    ResponseEntity<ProductResponse> create(@Valid @RequestBody CreateProductRequest request) {
        ProductResponse response = service.create(request);
        return ResponseEntity.created(URI.create("/api/v1/products/" + response.id()))
            .body(response);
    }
}
```
- Add dependencies: Spring Web, Spring Data JPA, Jakarta Validation implementation, DB driver.
- Example is illustrative: add authorization, uniqueness rules, error handling, and tests for production.

### Consistent error handling
```java
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ProblemDetail> validation(MethodArgumentNotValidException ex) {
        ProblemDetail problem = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        problem.setTitle("Validation failed");
        problem.setDetail("Check the submitted fields");
        return ResponseEntity.badRequest().body(problem);
    }
}
```
- Use RFC 9457 **Problem Details** (or another consistent documented error contract).
- Do not leak SQL errors, stack traces, or internal class names to API clients.
- Include a request/correlation ID in logs and, where useful, safe error responses.

### API design checklist
- **Naming:** Plural resource nouns; avoid action-heavy paths like `/getAllProducts`.
- **Methods:** `GET` read, `POST` create/action, `PUT` replace, `PATCH` partial update, `DELETE` remove.
- **Statuses:** `200`, `201`, `202`, `204`, `400`, `401`, `403`, `404`, `409`, `422`, `429`, `500` as appropriate.
- **Pagination:** Use `page`/`size` for simple cases; cursor/keyset for large or changing datasets.
- **Filtering/sorting:** `GET /products?category=books&sort=price,asc`.
- **Validation:** Bean Validation plus domain-specific checks; reject malformed input early.
- **Versioning:** Evolve compatibly first; version deliberately when breaking changes are necessary.
- **Idempotency:** Support `Idempotency-Key` for retryable payment/order creation workflows.
- **Concurrency:** Use optimistic locking (`@Version`) or conditional requests/ETags where needed.
- **Transactions:** Put one local business unit of work in a service transaction.
- **Security:** OAuth2 resource server, least-privilege scopes, ownership checks, TLS, rate limits.
- **Docs:** OpenAPI/Swagger with examples, errors, security requirements, and pagination contracts.
- **Observability:** Structured logs, correlation IDs, metrics, tracing, health/readiness checks.
- **Resilience:** Timeouts, bounded retries, circuit breakers, and bulkheads where justified.
- **Database:** Migrations via Flyway/Liquibase; indexes, constraints, and N+1 query monitoring.
- **Testing:** Unit, MVC slice, integration, contract, and performance tests.
- **Deployment:** External configuration, secrets management, graceful shutdown, rolling deployments.

### Example of safe order creation
```text
POST /api/v1/orders
Idempotency-Key: order-attempt-abc123
       |
Authenticate -> validate request -> verify ownership
       |
Check idempotency record / unique constraint
       |
@Transactional: create order + persist outbox event
       |
Commit DB transaction -> 201 Created
       |
Outbox worker publishes event to message broker
```
- **Why outbox?** Avoids the DB-write-succeeded/message-publish-failed gap.
- **Why idempotency?** Network retries should not create duplicate orders/charges.
- **Why ownership checks?** An authenticated user must not access another user's data merely by guessing an ID.

### Common mistakes to avoid
- Returning JPA entities directly and exposing internal fields.
- Writing all business logic in controllers.
- Using `200 OK` for every outcome, including errors.
- Assuming JWT validation automatically checks resource ownership.
- Running blocking external calls inside long DB transactions.
- Retrying non-idempotent POSTs without safeguards.
- Caching data without invalidation or TTL policies.
- Missing indexes, pagination, timeouts, and monitoring.

### Interview answer: “How would you design a production API?”
- Start with resources, consumers, expected traffic, SLAs, and failure cases.
- Define OpenAPI contracts, DTOs, statuses, validation, and consistent errors.
- Implement controller → service → repository separation.
- Add authentication **and** fine-grained authorization.
- Add pagination, idempotency, optimistic locking, and transactions where needed.
- Add tests, structured logs, metrics, tracing, and rollout safeguards.
- Measure performance and optimize real bottlenecks rather than guessing.

---

## 12. Spring bean lifecycle and scopes

### What is a Spring bean?
- A **bean** is an object created and managed by the Spring IoC container (`ApplicationContext`).
- **Dependency injection (DI)** supplies collaborators instead of classes constructing them directly.
- Typical registration: `@Component`, `@Service`, `@Repository`, `@Controller`, or `@Bean` methods.

### Lifecycle: what happens internally?
1. **Read configuration:** component scanning and `@Bean` definitions create `BeanDefinition` metadata.
2. **Instantiate:** Spring calls a constructor or factory method.
3. **Inject dependencies:** constructor, setter, or field injection (prefer constructors).
4. **Aware callbacks:** e.g., `BeanNameAware` / `ApplicationContextAware` when implemented.
5. **Before initialization:** `BeanPostProcessor#postProcessBeforeInitialization` runs.
6. **Initialize:** `@PostConstruct`, `InitializingBean#afterPropertiesSet`, then custom `initMethod` (when configured).
7. **After initialization:** post-processors can return a proxy (e.g., for `@Transactional`).
8. **Use:** the application retrieves/injects the managed bean.
9. **Destroy:** on context shutdown, `@PreDestroy`, `DisposableBean`, and configured destroy methods apply to managed singleton beans.
- **Important:** post-processors and proxies can change the object returned by the container.
- **Important:** Spring does not automatically call destruction callbacks for ordinary prototype instances.

### Bean scopes
| Scope | Meaning | Example |
|---|---|---|
| `singleton` (default) | One bean instance per Spring container and bean definition | Stateless service |
| `prototype` | New instance each time the container resolves it | Stateful task object |
| `request` | One instance per HTTP request | Request metadata |
| `session` | One instance per HTTP session | Session preferences |
| `application` | One instance per `ServletContext` | Web-app shared state |
| `websocket` | One instance per WebSocket session | Session-specific state |
- Web scopes require a web-aware context.
- Injecting a prototype directly into a singleton **does not** create a new prototype on every method call; use `ObjectProvider<T>` or a scoped proxy when appropriate.

### Example
```java
@Component
class TaskFactoryClient {
    private final ObjectProvider<TaskState> taskStates;

    TaskFactoryClient(ObjectProvider<TaskState> taskStates) {
        this.taskStates = taskStates;
    }

    void process() {
        TaskState fresh = taskStates.getObject(); // new prototype each call
    }
}

@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
class TaskState { }

@Component
class StartupBean {
    @PostConstruct
    void init() { System.out.println("Bean initialized"); }

    @PreDestroy
    void cleanup() { System.out.println("Bean destroyed"); }
}
```

### Interview quick answers
- **Q: Singleton vs prototype?** A: Singleton is one container-managed instance; prototype is a fresh instance per lookup.
- **Q: Is singleton thread-safe?** A: Not automatically; keep shared beans stateless or synchronize mutable state.
- **Q: When does `@Transactional` proxying happen?** A: Usually during bean post-processing after initialization.

---

## 13. Hibernate/JPA internals, lazy loading, and N+1 queries

### Core concepts
- **JPA** is a Java persistence specification; **Hibernate** is a common JPA implementation.
- `EntityManager` is the JPA API; Hibernate's `Session` is its underlying persistence context API.
- **Persistence context (first-level cache)** tracks managed entities by identity within an entity manager/session.
- **Entity states:** transient → managed → detached; removed entities are scheduled for deletion.
- **Dirty checking:** Hibernate detects changes to managed entities and can generate SQL updates during flush (the detection strategy depends on configuration/enhancement).
- **Flush** synchronizes queued SQL with the database; **commit** completes the transaction. A flush is not a commit.
- **Second-level cache** is optional and configured separately; it is not a replacement for query optimization.

### Request-to-database flow
```text
Controller → Service (@Transactional) → Repository → EntityManager
    → persistence context → Hibernate SQL generation → JDBC → Database
    ← rows → entity mapping / identity tracking ← results
Transaction completion → flush pending changes when required → database commit (or rollback)
```

### Lazy vs eager loading
- **Lazy:** load a relationship when accessed; can reduce unnecessary work.
- **Eager:** request the relationship as part of entity loading; it does **not** guarantee one SQL join.
- Defaults: `@OneToMany` / `@ManyToMany` are LAZY; `@ManyToOne` / `@OneToOne` are EAGER under JPA defaults.
- Prefer explicit `fetch = FetchType.LAZY` on many-to-one relationships where suitable.
- **LazyInitializationException:** a lazy association is accessed after its persistence context is closed.
- Fix with a transaction-scoped query that fetches required data, or return a DTO; do not rely on Open Session in View as a general solution.

### N+1 query problem
- **Example:** one SQL query loads 100 orders; accessing each `order.getCustomer()` triggers up to 100 additional SQL queries.
- **Symptoms:** high SQL count, slow response, and increased database load.
- **Fixes:** `JOIN FETCH`, `@EntityGraph`, DTO projections, or batch fetching depending on access patterns.
- **Trade-off:** joining multiple collections can multiply rows and break efficient pagination; consider separate queries.

### Example
```java
@Entity
class PurchaseOrder {
    @Id Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    Customer customer;
}

public interface OrderRepository extends JpaRepository<PurchaseOrder, Long> {
    @Query("select o from PurchaseOrder o join fetch o.customer where o.id = :id")
    Optional<PurchaseOrder> findWithCustomer(@Param("id") Long id);
}

@Service
class OrderReader {
    private final OrderRepository orders;
    OrderReader(OrderRepository orders) { this.orders = orders; }

    @Transactional(readOnly = true)
    public String customerName(Long id) {
        PurchaseOrder order = orders.findWithCustomer(id).orElseThrow();
        return order.customer.getName(); // fetched inside transaction
    }
}
```

### Interview quick answers
- **Q: What is dirty checking?** A: Hibernate detects managed entity changes and writes updates during flush.
- **Q: What is N+1?** A: One query loads parents, then additional queries load related data per parent.
- **Q: `save()` vs `flush()`?** A: `save()` persists/merges entity state; `flush()` synchronizes pending changes to SQL without committing.

---

## 14. Kafka: partitions, consumer groups, and delivery semantics

### What Kafka does
- Kafka is a distributed **event-streaming platform** for durable, ordered-per-partition logs.
- **Producer:** publishes records to a topic.
- **Topic:** named stream divided into **partitions**.
- **Broker:** Kafka server storing partition logs.
- **Consumer:** reads records by offset.
- **Replication:** partition replicas improve availability; one replica is leader at a time.
- **Offset:** position within one partition; not a global topic sequence number.

### How messages flow
```text
Producer → topic partition leader → replicated log → consumer polls
                         ↓
             consumer processes event → commits offset
```
- Records with the same key usually map to the same partition while partition configuration stays stable.
- **Ordering is guaranteed within a partition**, not across the whole topic.
- Producers can batch/compress messages for throughput.

### Consumer groups
- Consumers sharing a **group ID** divide topic partitions among themselves.
- Within a group, one partition is assigned to at most one active consumer at a time.
- Different groups each receive their own independent view of the topic.
- **Example:** 6 partitions and 3 consumers → roughly 2 partitions each; 8 consumers → at least 2 idle for that topic.
- A membership or partition change may trigger a **rebalance**; cooperative strategies reduce disruption.

### Delivery semantics
| Mode | Meaning | Typical trade-off |
|---|---|---|
| At-most-once | May lose messages; no duplicates from retry | Commit before processing |
| At-least-once | Retry protects against loss, but duplicates possible | Process then commit |
| Exactly-once | Kafka transactions + compatible read/process/write flow avoid duplicates in Kafka outputs | More coordination; external side effects still need idempotency |
- Producer idempotence reduces duplicate records caused by producer retries.
- `acks=all` and appropriate replica settings improve durability.
- For external databases, use **idempotency keys** or an inbox/deduplication table.
- Handle poison messages with retry limits and a **dead-letter topic (DLT)**.

### Spring Kafka example
```java
@Component
class OrderEvents {
    private final KafkaTemplate<String, String> kafka;
    OrderEvents(KafkaTemplate<String, String> kafka) { this.kafka = kafka; }

    void publish(String orderId) {
        kafka.send("orders.created", orderId, "created:" + orderId);
    }

    @KafkaListener(topics = "orders.created", groupId = "billing-service")
    public void onOrderCreated(String event) {
        // Make billing side effects idempotent before acknowledging completion.
        System.out.println(event);
    }
}
```
- In production, prefer versioned JSON/Avro/Protobuf schemas and explicit error-handling configuration.

### Interview quick answers
- **Q: Why partitions?** A: Parallelism, scale, and per-partition ordering.
- **Q: Why consumer groups?** A: Share processing work among service replicas.
- **Q: Does Kafka guarantee exactly-once database updates?** A: No; Kafka transactions do not automatically make an external database side effect exactly-once.

---

## 15. Microservices, saga, outbox, and distributed tracing

### Microservices basics
- Split a system into independently deployable services around **business capabilities**.
- Each service owns its data and exposes APIs or events.
- Benefits: independent scaling/deployment, team autonomy, fault isolation.
- Costs: network latency, eventual consistency, distributed failures, complex operations.
- **Use when:** team/scale/deployment needs justify the complexity; a modular monolith is often simpler initially.

### Synchronous vs asynchronous communication
- **REST/gRPC:** request-response, useful when the caller needs an immediate answer.
- **Kafka/events:** decoupled, asynchronous processing, useful for background workflows and fan-out.
- Always set timeouts and define retry/idempotency behavior for network calls.

### Saga pattern
- A saga is a sequence of **local transactions** across services with compensating actions on failure.
- **Choreography:** services react to events; simple for small flows but can become hard to trace.
- **Orchestration:** a coordinator directs each step; central visibility but extra component.
- **Example:** Order created → reserve inventory → charge payment → confirm order.
- **Failure example:** payment fails → release inventory → mark order cancelled.
- **Important:** compensation is a business action, not a database rollback across services.

### Transactional outbox pattern
- **Problem:** database update succeeds but publishing the event fails (dual-write problem).
- **Solution:** in **one local database transaction**, write business data and an outbox row.
- A worker or CDC connector publishes pending outbox events to Kafka.
- Mark published records or rely on CDC progress; consumers still need deduplication.

```text
HTTP request → Order Service
             → DB transaction: INSERT order + INSERT outbox event → COMMIT
             → CDC / publisher → Kafka → Inventory Service
             → Inventory Service deduplicates event ID
```

### Outbox pseudocode
```java
@Transactional
public void placeOrder(CreateOrder command) {
    Order order = orderRepository.save(new Order(command));
    outboxRepository.save(new OutboxEvent(
        UUID.randomUUID().toString(), "OrderCreated", order.getId().toString()));
    // No Kafka publish here: publisher/CDC sends committed outbox rows later.
}
```

### Distributed tracing
- A **trace** follows one request across services; a **span** records one operation.
- Propagate `traceparent` / W3C Trace Context across HTTP and messaging boundaries.
- **Example:** Gateway span → Order Service span → Inventory HTTP span → database span.
- Spring Boot commonly uses **Micrometer Tracing** with OpenTelemetry export to a tracing backend.
- Combine trace IDs in logs, metrics for trends, and traces for per-request investigation.
- Avoid logging passwords, tokens, and sensitive personal data.

### Interview quick answers
- **Q: Why saga?** A: Coordinate distributed business steps without a single cross-service ACID transaction.
- **Q: Why outbox?** A: Prevent business data from committing without a durable record of the event to publish.
- **Q: Why tracing?** A: Find latency and errors across service boundaries.

---

## 16. Docker, Kubernetes, and deployment strategies

### Docker basics
- **Image:** immutable packaged application and runtime dependencies.
- **Container:** running isolated process created from an image.
- **Dockerfile:** instructions to build an image in layers.
- **Registry:** stores images for deployment.
- **Volume:** persistent data outside the container's writable layer.
- **Best practice:** small images, non-root user, pinned base image, no secrets baked into images.

### Docker example
```dockerfile
# Assumes target/app.jar is built before docker build.
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/app.jar app.jar
USER 10001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```
```bash
mvn -DskipTests package
docker build -t orders-api:1.0 .
docker run --rm -p 8080:8080 orders-api:1.0
```

### Kubernetes core objects
- **Pod:** smallest deployable unit; usually one main app container.
- **Deployment:** desired replica count and rolling updates for stateless workloads.
- **Service:** stable virtual endpoint that routes traffic to matching Pods.
- **Ingress / Gateway API:** HTTP routing into the cluster through a controller.
- **ConfigMap / Secret:** external configuration; secrets still need encryption/RBAC controls.
- **HPA:** scales replicas based on metrics (CPU or custom metrics).
- **Readiness probe:** decides whether a Pod receives traffic.
- **Liveness probe:** decides whether to restart an unhealthy container.
- **Startup probe:** gives slow-starting applications time before liveness checks.

### Request flow
```text
Client → external load balancer → ingress/gateway → Kubernetes Service
       → ready Pod → Spring Boot app → database/cache
```

### Deployment strategies
| Strategy | Working | When to use |
|---|---|---|
| Recreate | Stop old version, then start new | Downtime acceptable |
| Rolling | Gradually replace old Pods with new | Standard low-downtime updates |
| Blue-green | Run old and new environments, switch traffic | Fast rollback and clear cutover |
| Canary | Send a small share of traffic to new version | Validate changes with real traffic |
- Use **backward-compatible database migrations** when old and new app versions overlap.
- Prefer graceful shutdown and correct readiness behavior to avoid dropped requests.

### Minimal Kubernetes example
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-api
spec:
  replicas: 3
  selector:
    matchLabels: {app: orders-api}
  template:
    metadata:
      labels: {app: orders-api}
    spec:
      containers:
        - name: api
          image: registry.example.com/orders-api:1.0
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet: {path: /actuator/health/readiness, port: 8080}
            initialDelaySeconds: 10
            periodSeconds: 5
```
- Example assumes Spring Boot Actuator and Kubernetes probe endpoints are enabled and accessible.
- A production deployment also needs a Service, resource requests/limits, credentials, and monitoring.

### Interview quick answers
- **Q: Docker vs Kubernetes?** A: Docker builds/runs containers; Kubernetes schedules and manages containerized workloads across nodes.
- **Q: Readiness vs liveness?** A: Readiness controls traffic; liveness controls restarts.
- **Q: Canary vs blue-green?** A: Canary gradually tests limited traffic; blue-green switches between two complete environments.

---

## 17. Database indexing, locking, and query optimization

### Indexing
- An **index** is a data structure (commonly B-tree) that speeds lookup at the cost of extra storage and write work.
- **Primary key index:** supports efficient lookup by primary key.
- **Composite index:** covers multiple columns; column order matters.
- **Unique index:** prevents duplicate key values according to database rules.
- **Covering index:** includes all columns a query needs, potentially avoiding table access.
- **Trade-off:** too many indexes slow INSERT/UPDATE/DELETE and increase storage.

### Example: composite index
```sql
CREATE INDEX idx_orders_customer_created
ON orders (customer_id, created_at);

SELECT id, total
FROM orders
WHERE customer_id = 42
ORDER BY created_at DESC
LIMIT 20;
```
- The index can help filter by `customer_id` and scan in `created_at` order.
- The query may still need table lookups for `total`; inspect the actual execution plan.
- A composite index on `(customer_id, created_at)` is generally not equivalent to one on `(created_at, customer_id)`.

### Query optimization checklist
- Use `EXPLAIN` / `EXPLAIN ANALYZE` to inspect scans, joins, rows, and time (syntax varies by database).
- Select only required columns; avoid unnecessary `SELECT *`.
- Index selective filter/join/order columns based on real query patterns.
- Avoid functions on indexed columns in filters when they prevent index use.
- Use keyset pagination for deep scrolling when possible.
- Batch related reads to avoid N+1 database queries.
- Measure production-like data volumes; small test datasets can hide poor plans.

### Locking and isolation
- **Pessimistic locking:** lock rows during a transaction to prevent conflicting writes.
- **Optimistic locking:** use a version number; fail/retry when another transaction updated the row.
- **MVCC:** many databases keep row versions to let readers and writers overlap; details vary by engine.
- **Deadlock:** transactions wait on each other's locks; database typically aborts one transaction.
- **Isolation levels:** READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE; guarantees differ by database.
- Keep transactions short, access rows in a consistent order, and retry safe operations after deadlocks.

### Spring JPA optimistic lock example
```java
@Entity
class ProductStock {
    @Id Long id;
    @Version Long version;
    int available;

    public void reserveOne() {
        if (available <= 0) throw new IllegalStateException("Out of stock");
        available--;
    }
}
```
- Concurrent transactions loading the same version cannot both successfully update it; one typically gets an optimistic-lock exception.
- Implement bounded retries only when the operation is safe to retry.

### Interview quick answers
- **Q: Why might an index not be used?** A: Low selectivity, unsuitable column order, stale statistics, or a cheaper table scan.
- **Q: Optimistic vs pessimistic lock?** A: Detect conflict at update vs acquire lock to prevent conflicting access.
- **Q: How do you investigate a slow query?** A: Reproduce, inspect execution plan and row counts, add/change indexes or SQL, then measure again.

---

## 18. Resilience4j, rate limiting, and circuit breakers

### Why resilience patterns matter
- A remote service can be slow, unavailable, or overloaded even when your code is correct.
- Resilience patterns protect latency, resources, and user experience under partial failure.
- **Timeout:** bound how long a remote call may wait; configure client/network timeouts too.
- **Retry:** repeat transient failures with backoff and jitter; avoid retrying non-idempotent operations blindly.
- **Circuit breaker:** temporarily reject calls when failures exceed configured thresholds.
- **Bulkhead:** isolate concurrency so one failing dependency cannot consume all resources.
- **Rate limiter:** control allowed request/call frequency.

### Circuit breaker state flow
```text
CLOSED (calls allowed, measure failures)
   └─ threshold reached → OPEN (fail fast)
       └─ wait interval → HALF_OPEN (limited trial calls)
           ├─ successful trial → CLOSED
           └─ failed trial → OPEN
```
- Circuit breakers **do not fix** the failing downstream service; they limit cascading failures.
- Use a fallback only if the fallback result is valid for the business operation.

### Rate limiting strategies
| Strategy | How it works | Best use |
|---|---|---|
| Fixed window | Count requests in a fixed time bucket | Simple limits; boundary bursts possible |
| Sliding window | Track recent requests across a moving window | Smoother enforcement |
| Token bucket | Refill tokens over time; each request consumes one | Allow controlled bursts |
| Leaky bucket | Process at a steadier output rate | Smooth traffic |
- For multi-instance services, a local in-memory limiter applies **per instance**; use a shared store or gateway-level policy for a global limit.
- Return HTTP **429 Too Many Requests** when rejecting client requests; consider `Retry-After` where appropriate.

### Spring Boot + Resilience4j example
```java
@Service
class InventoryClient {
    private final RestClient client;
    InventoryClient(RestClient.Builder builder) {
        this.client = builder.baseUrl("http://inventory-service").build();
    }

    @CircuitBreaker(name = "inventory", fallbackMethod = "fallback")
    @Retry(name = "inventory")
    public String availability(String sku) {
        return client.get().uri("/inventory/{sku}", sku)
                .retrieve().body(String.class);
    }

    private String fallback(String sku, Throwable error) {
        return "UNKNOWN"; // Do not pretend stock is available.
    }
}
```
```yaml
resilience4j:
  circuitbreaker:
    instances:
      inventory:
        slidingWindowSize: 20
        minimumNumberOfCalls: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 10s
  retry:
    instances:
      inventory:
        maxAttempts: 3
        waitDuration: 200ms
```
- Add compatible Resilience4j Spring Boot integration and AOP dependencies; configuration and annotation behavior vary by version.
- Configure HTTP connect/read timeouts separately; a circuit breaker is **not** a timeout.
- Carefully decide annotation order, exception filters, and whether fallback should apply to retries or circuit breaker failures.

### Interview quick answers
- **Q: Retry vs circuit breaker?** A: Retry handles temporary failures; circuit breaker stops repeated calls to a persistently failing dependency.
- **Q: What is a retry storm?** A: Many clients retry simultaneously and overload an already unhealthy service.
- **Q: How to rate-limit across 10 pods?** A: Use a distributed limiter (often gateway/Redis-backed) instead of independent per-pod counters.

---

## Rapid revision questions

- **Tomcat vs DispatcherServlet?** Tomcat manages HTTP/Servlet infrastructure; `DispatcherServlet` routes Spring MVC requests.
- **Spring vs Spring Boot?** Spring is the framework; Boot adds defaults, starters, auto-configuration, and deployment convenience.
- **Why auto-configuration?** Conditionally register useful infrastructure based on dependencies and app configuration.
- **Filter vs interceptor?** Filter wraps Servlet processing; interceptor hooks into Spring MVC handler execution.
- **TCP vs UDP?** TCP provides ordered reliable byte streams; UDP sends datagrams without delivery guarantees.
- **REST vs gRPC?** REST is broadly interoperable; gRPC offers strongly typed efficient RPC and streaming.
- **WebSocket vs SSE?** WebSocket is bidirectional; SSE is typically one-way server-to-browser streaming.
- **Why @Transactional fails?** Self-invocation/proxy bypass, exception rollback rules, or wrong resource/manager.
- **Redis TTL vs eviction?** TTL expires keys by time; eviction responds to memory pressure.
- **LRU vs LFU?** Recent access vs frequent access.
- **L4 vs L7 load balancer?** Transport routing vs HTTP-aware routing.
- **Authentication vs authorization?** Identity verification vs permission checks.
- **OAuth vs JWT?** Authorization framework vs token format.
- **OAuth vs OIDC?** Delegated authorization vs standardized login/identity.
- **401 vs 403?** Authentication required/invalid vs forbidden access.
- **How to avoid duplicate POSTs?** Use an idempotency key backed by durable uniqueness/recorded outcomes.
- **Why DTOs?** Stable contracts, validation, and separation from persistence models.
- **Why outbox?** Reliable coordination between DB commits and asynchronous event publishing.

---


---

## Corrections and Interview-Ready Spring Boot Summary

### Important clarifications

1. **Spring Boot is not a separate replacement for Spring.** It uses the Spring Framework and simplifies configuration, dependency management, and running applications.
2. **`@SpringBootApplication` is a combination of three annotations:** `@SpringBootConfiguration`, `@EnableAutoConfiguration`, and `@ComponentScan`. Auto-configuration is conditional; it does not create every possible bean.
3. **`SpringApplication.run()` does more than create beans.** It prepares the environment, creates and refreshes the application context, starts the embedded server when appropriate, executes runners, and signals readiness. The server startup happens as part of context refresh, so the startup flow is a conceptual summary rather than a strictly sequential list of all internals.
4. **Embedded Tomcat is not mandatory.** It is a common default for Spring MVC when using the servlet web starter, but Jetty or another supported server can be selected. Reactive applications commonly use Reactor Netty. Non-web applications need no HTTP server.
5. **Tomcat does not directly invoke controller methods.** It invokes the servlet filter chain and the Spring MVC `DispatcherServlet`, which uses handler mappings and adapters to dispatch to a controller.
6. **Dependency injection is not the same as component scanning.** Scanning finds candidate bean definitions; the IoC container creates and wires beans. Constructor injection is generally preferred.
7. **`@Transactional` is normally proxy-based.** Calls made within the same object can bypass the proxy, and checked exceptions do not trigger rollback by default unless configured. A local transaction does not roll back external API calls.
8. **JWT is a token format, not an authentication protocol.** OAuth 2.0 is for delegated authorization; OpenID Connect adds standardized identity. A signed JWT is not encrypted by default.
9. **Kafka guarantees ordering within a partition, not across a topic.** Processing an event and then committing the offset commonly gives at-least-once processing; external database side effects must still be idempotent.
10. **Caching and resilience require explicit trade-offs.** Redis TTL is different from eviction; a circuit breaker is different from a timeout; retries must be bounded and safe.

### Spring Boot internal working — 30-second interview answer

> "When my Spring Boot application starts, the main method calls `SpringApplication.run()`. Spring Boot prepares configuration, creates an ApplicationContext, discovers components, and applies conditional auto-configuration. The Spring IoC container creates beans and injects their dependencies. For a Spring MVC web application, the embedded servlet server starts during application-context initialization. When a request arrives, Tomcat passes it through filters to `DispatcherServlet`, which finds the controller. The controller calls the service and repository, and Spring converts the result into an HTTP response."

**Remember:** `SpringApplication.run()` · `@SpringBootApplication` · `ApplicationContext` · `@ComponentScan` · `@EnableAutoConfiguration` · Dependency Injection · Tomcat · `DispatcherServlet`.

### Simple example

```java
@SpringBootApplication
public class EmployeeApplication {
    public static void main(String[] args) {
        SpringApplication.run(EmployeeApplication.class, args);
    }
}

@Service
class EmployeeService {
    String getEmployeeName() {
        return "Asha";
    }
}

@RestController
class EmployeeController {
    private final EmployeeService service;

    EmployeeController(EmployeeService service) {
        this.service = service;
    }

    @GetMapping("/employees/name")
    String employeeName() {
        return service.getEmployeeName();
    }
}
```

**Request:** `GET /employees/name` → Tomcat → filters → `DispatcherServlet` → `EmployeeController` → `EmployeeService` → response body `Asha`.

### Quick revision keywords

| Area | Keywords |
| --- | --- |
| Startup | `main`, `SpringApplication.run`, Environment, ApplicationContext |
| Auto-configuration | `@EnableAutoConfiguration`, conditions, classpath, properties |
| Beans | IoC, component scanning, constructor injection, scopes |
| Web requests | Tomcat, filters, `DispatcherServlet`, handler mapping |
| Data | JPA, persistence context, transactions, dirty checking |
| Security | `SecurityFilterChain`, OAuth 2.0, OIDC, JWT, authorization |
| Reliability | Kafka offsets, idempotency, retries, circuit breakers |

### Study notes

- The earlier sections provide deeper explanations and illustrative code; use the 30-second answer for the initial interview response.
- Always check the specific Spring Boot, Spring Security, Hibernate, and Resilience4j versions used in your project before copying configuration.
- The examples intentionally omit some imports, persistence configuration, and production concerns.
