# Java & Spring Boot Backend Interview Guide

> **Goal:** Simple, detailed, interview-ready notes in short bullet points, with request flows, examples, trade-offs, and practical best practices.
>
> **How to extend:** Add a new numbered section using the [topic template](#template-for-new-topics), then add its link to the contents.

## 📚 Table of Contents

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
12. Rapid Revision Questions
13. Template for New Topics

---

## 1. Tomcat architecture and request flow

### What is Tomcat?
- **Apache Tomcat** is a Java web server and Servlet container.
- It receives HTTP requests and runs Java Servlet-based applications.
- In Spring Boot MVC applications, Tomcat is often the **embedded** web server.
- Tomcat is **not** the Spring framework; Spring MVC uses Tomcat's Servlet infrastructure.

### Main components
- **Server:** Top-level Tomcat instance; manages services and lifecycle.
- **Service:** Groups a **Connector** with an **Engine**.
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
       -> Create ApplicationContext
       -> Register configuration classes and bean definitions
       -> Apply auto-configuration and bean post-processors
       -> Instantiate eligible singleton beans / inject dependencies
       -> Start embedded server (Servlet web app)
       -> Run ApplicationRunner / CommandLineRunner
       -> Application ready
```

### Important concepts
- **IoC container:** Creates, wires, and manages Spring beans.
- **Bean:** An object managed by the Spring container.
- **Component scan:** Discovers `@Component`, `@Service`, `@Repository`, `@Controller`, etc.
- **Dependency injection:** Supplies dependencies, preferably through constructors.
- **Starter:** Dependency bundle such as `spring-boot-starter-web`.
- **Auto-configuration:** Creates infrastructure beans only when relevant conditions match.
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
- **Authentication:** Who are you?
- **Authorization:** Are you allowed to do this?
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
- **401 Unauthorized:** No valid authentication credentials for a protected resource.
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

## 12. Rapid revision questions

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

