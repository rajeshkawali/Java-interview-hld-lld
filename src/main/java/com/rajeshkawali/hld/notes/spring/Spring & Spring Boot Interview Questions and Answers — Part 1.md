# Spring & Spring Boot Interview Questions and Answers
## Part 1 — Spring Core + Spring Boot Fundamentals

> **Target:** Java developers preparing for Spring/Spring Boot interviews  
> **Level:** Easy → Intermediate → Deep → Tricky  
> **Focus:** Understanding concepts, not memorizing definitions

---

# SECTION 1 — SPRING CORE FUNDAMENTALS

## 1. What is Spring Framework?

**Answer:**

Spring is a Java-based application development framework that provides infrastructure for building enterprise applications.

The major features of Spring include:

- Dependency Injection / Inversion of Control
- Aspect-Oriented Programming
- Transaction management
- Spring MVC
- Spring Data
- Spring Security
- Integration with databases and messaging systems
- Testing support

The central idea of Spring is to reduce tight coupling between classes by managing object creation and dependencies.

### Simple example

Without Spring:

```java
class OrderService {
    private PaymentService paymentService = new PaymentService();
}
```

`OrderService` is tightly coupled to `PaymentService`.

With Spring:

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Spring creates and injects the `PaymentService`.

---

# 2. What is IoC?

**IoC means Inversion of Control.**

Normally, a class controls the creation of its dependencies:

```java
PaymentService paymentService = new PaymentService();
```

With IoC, the responsibility of creating and managing objects is transferred to the Spring container.

Instead of:

```java
OrderService service = new OrderService(
        new PaymentService()
);
```

Spring manages the objects.

Conceptually:

```text
Without IoC:

Application
    |
    +--> creates objects
    +--> manages dependencies
    +--> controls lifecycle


With IoC:

Application
    |
    +--> asks Spring for objects

Spring Container
    |
    +--> creates objects
    +--> injects dependencies
    +--> manages lifecycle
```

### Interview one-liner

> IoC means the control of object creation and dependency management is transferred from the application code to the Spring container.

---

# 3. What is Dependency Injection?

Dependency Injection is the mechanism through which Spring provides an object's dependencies from outside rather than the object creating them itself.

Example:

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Here `OrderService` depends on `PaymentService`.

Spring injects the dependency.

### Types of Dependency Injection

There are mainly:

1. Constructor injection
2. Setter injection
3. Field injection

---

# 4. Constructor Injection vs Setter Injection vs Field Injection

### Constructor Injection

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Advantages:

- Dependencies are mandatory
- Supports `final`
- Easier unit testing
- Makes dependencies explicit
- Helps create immutable objects

Generally preferred.

---

### Setter Injection

```java
@Service
class OrderService {

    private PaymentService paymentService;

    @Autowired
    public void setPaymentService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Useful when a dependency is optional or can be changed.

---

### Field Injection

```java
@Service
class OrderService {

    @Autowired
    private PaymentService paymentService;
}
```

Easy to write, but generally discouraged because:

- Dependencies are hidden
- Difficult to unit test without Spring
- Cannot easily make the dependency `final`
- Encourages mutable design

### Interview answer

> Constructor injection is generally preferred because it makes dependencies explicit, supports immutability, improves testability, and ensures required dependencies are available when the object is created.

---

# 5. What is a Spring Bean?

A Spring Bean is an object that is created, configured, and managed by the Spring IoC container.

Example:

```java
@Service
public class PaymentService {
}
```

Spring detects this class and creates a bean.

You can also explicitly define a bean:

```java
@Configuration
public class AppConfig {

    @Bean
    public PaymentService paymentService() {
        return new PaymentService();
    }
}
```

The important point is:

> Not every Java object is a Spring Bean. A Spring Bean is an object managed by the Spring container.

---

# 6. What is the Spring IoC Container?

The Spring IoC container is responsible for:

- Creating beans
- Configuring beans
- Injecting dependencies
- Managing bean lifecycle
- Managing bean scopes

Common container interfaces include:

```text
BeanFactory
ApplicationContext
```

`ApplicationContext` provides more functionality than `BeanFactory` and is commonly used in Spring applications.

---

# 7. BeanFactory vs ApplicationContext

### BeanFactory

Basic IoC container.

Provides:

- Bean creation
- Dependency injection
- Basic lifecycle management

### ApplicationContext

A more feature-rich container.

It additionally supports things such as:

- Event publishing
- Internationalization
- Application-level configuration
- Better integration with Spring infrastructure
- Automatic detection of components

### Interview answer

> `BeanFactory` is the basic IoC container, while `ApplicationContext` is a more advanced container providing additional enterprise features and is normally used in Spring applications.

---

# 8. What are the different ways to create Spring Beans?

Common approaches:

### 1. `@Component`

```java
@Component
public class PaymentService {
}
```

### 2. Specialized stereotype annotations

```java
@Service
public class PaymentService {
}
```

```java
@Repository
public class PaymentRepository {
}
```

```java
@Controller
public class PaymentController {
}
```

### 3. `@Bean`

```java
@Configuration
public class AppConfig {

    @Bean
    public PaymentClient paymentClient() {
        return new PaymentClient();
    }
}
```

### 4. XML configuration

Older Spring applications may use:

```xml
<bean id="paymentService"
      class="com.example.PaymentService"/>
```

Modern Spring Boot applications primarily use annotations and Java configuration.

---

# 9. Difference between @Component, @Service, @Repository and @Controller

All are Spring stereotype annotations.

### `@Component`

Generic Spring-managed component.

```java
@Component
class EmailValidator {
}
```

### `@Service`

Usually used for service/business logic.

```java
@Service
class OrderService {
}
```

### `@Repository`

Usually used for persistence/data-access classes.

```java
@Repository
class OrderRepository {
}
```

It also participates in Spring's persistence exception translation mechanism.

### `@Controller`

Used for Spring MVC controllers.

```java
@Controller
class OrderController {
}
```

### Important interview point

`@Service` does not magically make business logic transactional.

Likewise, `@Repository` is not simply another name for `@Component`; it has additional persistence-related semantics.

---

# 10. Is @Service different from @Component internally?

Conceptually, both are component stereotypes and are detected during component scanning.

For basic bean registration, `@Service` is effectively a specialization of `@Component`.

The main difference is semantic:

```text
@Component → generic component

@Service → business/service layer

@Repository → persistence layer

@Controller → web/controller layer
```

Using the appropriate stereotype improves readability and communicates architectural intent.

---

# 11. What is Component Scanning?

Component scanning allows Spring to automatically find classes annotated with component stereotypes.

For example:

```java
@Service
public class OrderService {
}
```

Spring scans configured packages and discovers the class.

Spring Boot commonly starts scanning from the package containing the main application class.

Example:

```java
@SpringBootApplication
public class Application {
}
```

If:

```text
com.example.Application

com.example.service.OrderService

com.example.repository.OrderRepository
```

are under the same package hierarchy, they can normally be discovered automatically.

---

# 12. What is @Configuration?

`@Configuration` indicates that a class contains bean definitions.

Example:

```java
@Configuration
public class AppConfig {

    @Bean
    public PaymentService paymentService() {
        return new PaymentService();
    }
}
```

Spring processes the configuration class and registers the returned object as a bean.

---

# 13. What is @Bean?

`@Bean` tells Spring that the returned object should be registered as a Spring Bean.

Example:

```java
@Configuration
public class AppConfig {

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

This is particularly useful when you need to configure objects from third-party libraries that you cannot annotate with `@Component`.

---

# 14. @Component vs @Bean — important interview question

### `@Component`

Placed on the class:

```java
@Component
class MyService {
}
```

Spring discovers it through component scanning.

### `@Bean`

Placed on a method:

```java
@Configuration
class Config {

    @Bean
    MyService myService() {
        return new MyService();
    }
}
```

You explicitly tell Spring how to construct the object.

### Key difference

```text
@Component
    ↓
Spring discovers the class

@Bean
    ↓
Developer explicitly defines bean creation
```

---

# 15. What is the default scope of a Spring Bean?

The default scope is:

```text
singleton
```

This means Spring normally creates one bean instance per Spring container.

Example:

```java
@Service
public class OrderService {
}
```

By default, Spring manages it as a singleton-scoped bean.

### Important trick

Spring singleton does NOT mean:

> One object for the entire JVM.

It means:

> One bean instance per Spring IoC container.

---

# 16. What are Spring Bean scopes?

Common scopes include:

### Singleton

One bean instance per container.

```java
@Scope("singleton")
```

### Prototype

A new instance is created when requested.

```java
@Scope("prototype")
```

### Request

One instance per HTTP request.

```java
@Scope("request")
```

### Session

One instance per HTTP session.

```java
@Scope("session")
```

### Application

One instance per ServletContext.

### WebSocket

One instance per WebSocket lifecycle.

The web-related scopes apply in web-aware application contexts.

---

# 17. Singleton vs Prototype — tricky question

Suppose:

```java
@Component
@Scope("prototype")
class PrototypeBean {
}
```

and:

```java
@Component
class SingletonBean {

    private final PrototypeBean prototypeBean;

    public SingletonBean(PrototypeBean prototypeBean) {
        this.prototypeBean = prototypeBean;
    }
}
```

Will `prototypeBean` be different every time you call a method on `SingletonBean`?

**No.**

The prototype dependency is resolved when the singleton is created.

Therefore the singleton effectively keeps the same injected prototype instance.

If you need a fresh prototype instance repeatedly, you need mechanisms such as:

- `ObjectProvider`
- `Provider`
- `@Lookup`
- appropriate scoped proxy mechanisms

Example:

```java
@Component
class SingletonBean {

    private final ObjectProvider<PrototypeBean> provider;

    SingletonBean(ObjectProvider<PrototypeBean> provider) {
        this.provider = provider;
    }

    public void execute() {
        PrototypeBean bean = provider.getObject();
    }
}
```

---

# 18. What is the Spring Bean lifecycle?

A simplified lifecycle is:

```text
Bean definition
      ↓
Bean instantiation
      ↓
Dependency injection
      ↓
Aware callbacks
      ↓
BeanPostProcessor before initialization
      ↓
@PostConstruct
      ↓
InitializingBean / init method
      ↓
BeanPostProcessor after initialization
      ↓
Bean ready
      ↓
@PreDestroy
      ↓
DisposableBean / destroy method
```

The exact internal lifecycle contains more details, but this is a useful interview-level representation.

---

# 19. What is @PostConstruct?

`@PostConstruct` is used for initialization logic after dependency injection has completed.

Example:

```java
@Component
class CacheService {

    @PostConstruct
    public void initialize() {
        System.out.println("Initializing cache...");
    }
}
```

It is useful when the bean needs initialization after its dependencies are available.

---

# 20. What is @PreDestroy?

`@PreDestroy` is used for cleanup before a managed bean is destroyed.

```java
@Component
class ConnectionManager {

    @PreDestroy
    public void cleanup() {
        System.out.println("Closing resources...");
    }
}
```

Important:

Spring does not guarantee the same destruction behavior for every scope.

For example, prototype-scoped beans are created by Spring, but their complete destruction lifecycle is not managed by the container in the same way as singleton beans.

---

# SECTION 2 — AUTOWIRING AND DEPENDENCY RESOLUTION

# 21. What is @Autowired?

`@Autowired` tells Spring to resolve and inject a dependency.

Example:

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    @Autowired
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

In modern Spring, if a class has a single constructor, `@Autowired` can generally be omitted.

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

# 22. What happens if Spring finds multiple beans of the same type?

Suppose:

```java
interface PaymentService {
}
```

and:

```java
@Service
class CardPaymentService implements PaymentService {
}
```

```java
@Service
class UpiPaymentService implements PaymentService {
}
```

Now:

```java
@Service
class OrderService {

    public OrderService(PaymentService paymentService) {
    }
}
```

Spring sees two candidates.

This can result in:

```text
NoUniqueBeanDefinitionException
```

unless you tell Spring which bean to use.

---

# 23. How do you resolve multiple beans of the same type?

Several approaches exist.

### Option 1: @Primary

```java
@Service
@Primary
class CardPaymentService implements PaymentService {
}
```

Spring chooses it as the default candidate.

---

### Option 2: @Qualifier

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(
            @Qualifier("upiPaymentService")
            PaymentService paymentService) {

        this.paymentService = paymentService;
    }
}
```

### Difference

```text
@Primary
    → default preferred bean

@Qualifier
    → explicitly select a particular bean
```

---

# 24. @Primary vs @Qualifier — tricky question

Suppose one bean is marked:

```java
@Primary
```

but injection uses:

```java
@Qualifier("anotherBean")
```

Which one wins?

**The qualifier wins.**

`@Primary` is used when there are multiple candidates and no more specific qualifier selection resolves the dependency.

---

# 25. What happens if no bean is found for an @Autowired dependency?

For a required dependency, Spring generally fails application context creation with an exception such as:

```text
NoSuchBeanDefinitionException
```

or a related dependency-resolution exception.

You can make some dependencies optional, for example using:

```java
@Autowired(required = false)
```

or preferably use approaches such as:

```java
Optional<MyService>
```

or:

```java
ObjectProvider<MyService>
```

depending on the design.

---

# 26. Can an interface be autowired?

Yes.

Example:

```java
interface NotificationService {
    void send();
}
```

```java
@Service
class EmailNotificationService
        implements NotificationService {

    public void send() {
    }
}
```

Then:

```java
@Service
class OrderService {

    private final NotificationService notificationService;

    public OrderService(NotificationService notificationService) {
        this.notificationService = notificationService;
    }
}
```

Spring injects the implementation.

If multiple implementations exist, you need a mechanism such as `@Qualifier`, `@Primary`, or another appropriate resolution strategy.

---

# 27. Can we inject a List of implementations?

Yes.

This is extremely useful for strategy-pattern designs.

Example:

```java
public interface PaymentProcessor {
    void process();
}
```

```java
@Component
class CardPaymentProcessor implements PaymentProcessor {
    public void process() {}
}
```

```java
@Component
class UpiPaymentProcessor implements PaymentProcessor {
    public void process() {}
}
```

Then:

```java
@Component
class PaymentManager {

    private final List<PaymentProcessor> processors;

    public PaymentManager(List<PaymentProcessor> processors) {
        this.processors = processors;
    }
}
```

Spring can inject all matching beans.

You can also inject a:

```java
Map<String, PaymentProcessor>
```

which is useful when selecting implementations dynamically.

---

# 28. What is @Qualifier?

`@Qualifier` provides additional information to Spring about which bean should be injected.

Example:

```java
@Component("smsService")
class SmsNotificationService
        implements NotificationService {
}
```

```java
@Component("emailService")
class EmailNotificationService
        implements NotificationService {
}
```

Then:

```java
public NotificationManager(
        @Qualifier("emailService")
        NotificationService service) {
}
```

The email implementation is selected.

---

# SECTION 3 — SPRING BOOT

# 29. What is Spring Boot?

Spring Boot is a project built on top of Spring that simplifies the creation and configuration of Spring applications.

It provides features such as:

- Auto-configuration
- Starter dependencies
- Embedded servers
- Externalized configuration
- Production-ready features
- Actuator
- Convention-over-configuration

The goal is not to replace Spring.

> Spring Boot simplifies using Spring.

---

# 30. Spring Framework vs Spring Boot

### Spring Framework

Provides the core framework and infrastructure.

Examples:

- IoC
- Dependency Injection
- AOP
- MVC
- Transactions

### Spring Boot

Provides an opinionated way of configuring and running Spring applications.

Examples:

- Auto-configuration
- Starters
- Embedded server
- Actuator
- Simplified configuration

### Interview answer

> Spring is the framework; Spring Boot is an opinionated layer on top of Spring that reduces configuration and simplifies application development and deployment.

---

# 31. What is @SpringBootApplication?

This is one of the most important Spring Boot annotations.

```java
@SpringBootApplication
public class Application {
}
```

Conceptually, it combines three major annotations:

```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

Therefore:

```text
@SpringBootApplication
        |
        +--> @SpringBootConfiguration
        |
        +--> @EnableAutoConfiguration
        |
        +--> @ComponentScan
```

---

# 32. What does @EnableAutoConfiguration do?

It tells Spring Boot to automatically configure parts of the application based on:

- Classes available on the classpath
- Existing beans
- Application properties
- Conditional configuration

For example, if Spring MVC-related dependencies are present, Boot can configure relevant MVC infrastructure automatically.

If a database driver and relevant Spring Data/JDBC/JPA dependencies are present, Boot can configure database-related infrastructure according to the application's configuration.

---

# 33. What is Auto-Configuration?

Auto-configuration means Spring Boot attempts to configure the application automatically based on its environment.

For example:

```text
Add web dependency
       ↓
Boot detects web-related classes
       ↓
Auto-configuration activates
       ↓
MVC infrastructure gets configured
```

But auto-configuration is conditional.

It does not blindly configure everything.

---

# 34. How does Spring Boot Auto-Configuration work internally?

This is a common senior-level interview question.

Spring Boot uses auto-configuration classes and conditional configuration.

Conditions can depend on things such as:

```java
@ConditionalOnClass
@ConditionalOnMissingBean
@ConditionalOnProperty
@ConditionalOnBean
```

Conceptually:

```text
Application starts
       ↓
Boot discovers auto-configuration candidates
       ↓
Conditions are evaluated
       ↓
Matching configurations are applied
       ↓
Beans are registered
```

For example:

```java
@Configuration
@ConditionalOnClass(SomeLibrary.class)
class SomeAutoConfiguration {
}
```

This configuration is only relevant when the required class exists.

---

# 35. What is a Spring Boot Starter?

A starter is a convenient dependency descriptor that brings together commonly required dependencies for a particular capability.

Examples include:

```text
spring-boot-starter-web
spring-boot-starter-data-jpa
spring-boot-starter-security
spring-boot-starter-test
```

Instead of manually adding many related dependencies, a starter provides a curated dependency set.

---

# 36. What is the difference between a starter and auto-configuration?

This is a common trick question.

They are related but different.

### Starter

Primarily helps bring required dependencies onto the classpath.

### Auto-configuration

Uses the available environment and conditions to configure Spring beans automatically.

Therefore:

```text
Starter
   ↓
adds dependencies

Auto-configuration
   ↓
configures application infrastructure
```

Adding a starter does not mean every possible feature is automatically enabled unconditionally.

---

# 37. Why does Spring Boot use an embedded server?

Traditional Java web applications were commonly deployed to an externally managed application server.

Spring Boot can package the application with an embedded server, allowing it to run as an executable application.

For example:

```bash
java -jar application.jar
```

This simplifies:

- Deployment
- Containerization
- Local development
- CI/CD
- Microservice deployment

---

# 38. What is the default embedded server in Spring Boot?

For a typical Spring MVC application using the standard web starter, the default embedded servlet container is commonly Tomcat.

However, Spring Boot can be configured to use alternatives such as Jetty or Undertow where supported by the relevant stack/version.

---

# 39. What is application.properties?

It is a configuration file commonly used for externalized application configuration.

Example:

```properties
server.port=8081
spring.application.name=order-service
```

It can contain:

- Server configuration
- Database configuration
- Logging configuration
- Custom application properties
- Spring configuration

---

# 40. application.properties vs application.yml

Both can be used for configuration.

### Properties

```properties
server.port=8081
spring.datasource.url=jdbc:mysql://localhost/test
```

### YAML

```yaml
server:
  port: 8081

spring:
  datasource:
    url: jdbc:mysql://localhost/test
```

YAML is often easier to read for hierarchical configuration.

The choice is largely a matter of project convention and configuration complexity.

---

# 41. What is externalized configuration?

Externalized configuration means configuration is kept outside application code so that the same application artifact can run in different environments.

For example:

```text
Development
DB = development database

Testing
DB = test database

Production
DB = production database
```

The application code remains unchanged.

Sources can include:

- Properties files
- YAML
- Environment variables
- Command-line arguments
- Other supported configuration sources

---

# 42. What is @Value?

`@Value` injects configuration values.

Example:

```properties
payment.timeout=5000
```

Then:

```java
@Value("${payment.timeout}")
private int timeout;
```

It is convenient for individual values.

However, for a group of related configuration properties, `@ConfigurationProperties` is often cleaner.

---

# 43. @Value vs @ConfigurationProperties

### @Value

Good for small/simple values:

```java
@Value("${app.name}")
private String appName;
```

### @ConfigurationProperties

Better for structured configuration.

```yaml
payment:
  timeout: 5000
  retry-count: 3
  enabled: true
```

Then:

```java
@ConfigurationProperties(prefix = "payment")
public class PaymentProperties {

    private int timeout;
    private int retryCount;
    private boolean enabled;

    // getters/setters
}
```

Advantages include:

- Type-safe configuration
- Grouping related properties
- Better maintainability
- Better IDE support when metadata is available

---

# SECTION 4 — PROFILES

# 44. What is a Spring Profile?

Profiles allow different configurations to be activated for different environments.

Typical environments:

```text
dev
test
staging
prod
```

Example:

```java
@Configuration
@Profile("dev")
class DevelopmentConfig {
}
```

It will be active when the `dev` profile is active.

---

# 45. How do you activate a Spring profile?

For example:

```properties
spring.profiles.active=dev
```

or through an environment/configuration mechanism appropriate to the deployment environment.

You can also use profile-specific configuration files such as:

```text
application-dev.properties
application-prod.properties
```

---

# 46. Why should we avoid putting production passwords directly in application.properties?

Because configuration files can accidentally be:

- Committed to Git
- Exposed through logs
- Shared with developers
- Included in artifacts
- Leaked through configuration management

Production secrets should generally be managed using secure secret-management mechanisms, environment configuration, or a dedicated secrets platform.

---

# SECTION 5 — SPRING BOOT STARTUP

# 47. What happens when a Spring Boot application starts?

A simplified startup sequence is:

```text
main()
  ↓
SpringApplication.run()
  ↓
Create/configure ApplicationContext
  ↓
Determine environment
  ↓
Load configuration
  ↓
Process component scanning
  ↓
Process auto-configuration
  ↓
Register beans
  ↓
Create singleton beans
  ↓
Inject dependencies
  ↓
Run initialization callbacks
  ↓
Start embedded server if applicable
  ↓
Application ready
```

This is a simplified view; the actual lifecycle is more detailed.

---

# 48. What does SpringApplication.run() do?

Example:

```java
public static void main(String[] args) {

    SpringApplication.run(Application.class, args);
}
```

It bootstraps the Spring Boot application.

It roughly handles:

- Creating the application context
- Preparing the environment
- Loading configuration
- Registering beans
- Applying auto-configuration
- Refreshing the context
- Starting the application
- Publishing lifecycle events

For a web application, it also starts the embedded web server.

---

# 49. Why is the main application class usually placed in the root package?

Because component scanning normally starts from the package of the application class and scans its subpackages.

Example:

```text
com.company.app
    Application.java

com.company.app.controller
    OrderController.java

com.company.app.service
    OrderService.java

com.company.app.repository
    OrderRepository.java
```

This structure allows component scanning to discover those components naturally.

### Tricky question

What if you put:

```text
Application.java
```

in:

```text
com.company
```

and your services are in:

```text
org.othercompany.service
```

They won't automatically be discovered merely because they are Spring components.

You may need explicit component scanning or another configuration mechanism.

---

# SECTION 6 — BEAN CREATION AND CONFIGURATION

# 50. What is the difference between @Configuration and @Component?

Both can result in Spring-managed beans.

But they communicate different intent.

```java
@Configuration
class DatabaseConfig {
}
```

means:

> This class primarily contains configuration/bean definitions.

Whereas:

```java
@Component
class EmailValidator {
}
```

means:

> This is an application component managed by Spring.

A configuration class commonly contains:

```java
@Bean
public DataSource dataSource() {
    ...
}
```

---

# 51. Why is @Configuration special?

Consider:

```java
@Configuration
class AppConfig {

    @Bean
    public A a() {
        return new A(b());
    }

    @Bean
    public B b() {
        return new B();
    }
}
```

Spring treats configuration classes specially so that calls between `@Bean` methods can participate in container-managed bean semantics.

This is different from simply treating the class as an ordinary component.

---

# 52. What happens if you create a Spring Bean using `new`?

Suppose:

```java
@Service
class OrderService {
}
```

Spring manages an instance of it.

But:

```java
OrderService service = new OrderService();
```

creates an ordinary Java object.

Spring does not automatically manage that manually-created object.

Therefore it may not have:

- Dependency injection
- Spring AOP proxies
- Transaction interception
- Lifecycle callbacks
- Other container-managed behavior

### Very important interview concept

> Spring manages objects it creates/manages through its container. Calling `new` yourself bypasses the container.

---

# 53. Can we use @Autowired on a manually created object?

Consider:

```java
OrderService service = new OrderService();
```

Will Spring automatically inject dependencies?

**No.**

Spring does not automatically know about this object.

If an object must participate in Spring dependency injection and lifecycle management, it should normally be obtained/managed through the Spring container.

---

# 54. What is circular dependency?

A circular dependency occurs when beans depend on each other directly or indirectly.

Example:

```text
A → B
B → A
```

Code:

```java
@Service
class A {
    A(B b) {}
}
```

```java
@Service
class B {
    B(A a) {}
}
```

Constructor injection makes this dependency cycle problematic because both objects require the other during construction.

Spring may fail application startup with a circular dependency-related exception.

---

# 55. How should you solve circular dependencies?

The best solution is generally **not** to find a clever Spring annotation.

Instead, fix the design.

For example:

```text
A → B
B → A
```

may indicate that responsibilities are incorrectly divided.

Possible solutions:

- Extract common functionality into a third service
- Change the dependency direction
- Introduce an abstraction
- Redesign responsibilities
- Use events where appropriate

Avoid treating `@Lazy` as the default solution.

---

# 56. What does @Lazy do?

`@Lazy` delays bean creation until the bean is actually needed.

Example:

```java
@Lazy
@Component
class ExpensiveService {
}
```

Instead of eagerly creating it during normal singleton initialization, Spring can defer creation.

`@Lazy` can sometimes help with circular dependency scenarios, but using it to hide a poor architecture is generally not the best solution.

---

# SECTION 7 — AOP

# 57. What is AOP?

AOP stands for Aspect-Oriented Programming.

It is used to separate cross-cutting concerns from business logic.

Examples:

- Logging
- Transactions
- Security
- Auditing
- Performance monitoring

Instead of adding logging everywhere:

```java
public void createOrder() {
    log.info("start");
    ...
    log.info("end");
}
```

AOP can centralize that behavior.

---

# 58. What is a cross-cutting concern?

A cross-cutting concern is functionality that affects multiple parts of an application.

Examples:

```text
Logging
Security
Transactions
Auditing
Metrics
Tracing
```

These concerns don't belong exclusively to one business method.

AOP helps modularize them.

---

# 59. What is a Spring AOP proxy?

Spring AOP commonly works by wrapping a target bean with a proxy.

Conceptually:

```text
Client
   |
   v
Proxy
   |
   +--> Before advice
   |
   v
Target Bean
   |
   +--> Business logic
   |
   v
Proxy
   |
   +--> After advice
```

This proxy is important for understanding:

- `@Transactional`
- `@Async`
- caching
- security interception
- many Spring AOP features

---

# 60. Why can self-invocation break Spring AOP behavior?

This is one of the most important Spring interview questions.

Suppose:

```java
@Service
class OrderService {

    public void methodA() {
        methodB();
    }

    @Transactional
    public void methodB() {
    }
}
```

If `methodA()` calls `methodB()` directly:

```java
methodB();
```

the call happens inside the same object.

It does not pass through the Spring proxy in the normal proxy-based AOP model.

Therefore the transactional interceptor may not run as expected.

### Interview answer

> Spring's proxy-based AOP intercepts calls that pass through the proxy. A direct self-invocation from one method to another on the same object bypasses the proxy.

---

# 61. What is the difference between JDK dynamic proxy and CGLIB-style proxying?

At a high level:

### JDK dynamic proxy

Works through interfaces.

```text
Interface
    ↑
Proxy
    ↑
Implementation
```

### Class-based proxying

Creates a subclass-style proxy around a concrete class.

Spring can use class-based proxying when appropriate.

The exact proxy mechanism depends on the configuration and Spring version.

### Interview point

Don't say:

> Spring always uses CGLIB.

That is too simplistic.

---

# SECTION 8 — TRANSACTIONS

# 62. What is @Transactional?

`@Transactional` tells Spring to apply transaction management around a method/class.

Example:

```java
@Transactional
public void transferMoney() {
    debitAccount();
    creditAccount();
}
```

Conceptually:

```text
Begin transaction
      ↓
debit
      ↓
credit
      ↓
Commit

If failure:
      ↓
Rollback
```

The exact rollback behavior depends on the exception type and transaction configuration.

---

# 63. Is @Transactional implemented using AOP?

In typical Spring proxy-based transaction management, yes.

Conceptually:

```text
Client
  ↓
Spring proxy
  ↓
Transaction interceptor
  ↓
Target method
```

The interceptor manages transaction boundaries around the method invocation.

---

# 64. Why doesn't @Transactional work in some cases?

Common reasons include:

### 1. Self-invocation

```java
this.someTransactionalMethod();
```

does not normally pass through the proxy.

### 2. Method/class isn't managed by Spring

```java
new OrderService()
```

bypasses the container.

### 3. Incorrect transaction configuration

### 4. Visibility/proxy limitations

Proxy-based interception has limitations around certain method/class structures.

### 5. Exception behavior is misunderstood

The transaction may not roll back for every exception automatically.

---

# 65. Does @Transactional rollback on checked exceptions?

By default, Spring's standard declarative transaction behavior rolls back on:

```text
RuntimeException
Error
```

but not every checked exception automatically.

For a checked exception where rollback is required, you can configure it explicitly.

Example:

```java
@Transactional(rollbackFor = Exception.class)
public void process() throws Exception {
}
```

### Important

Do not memorize:

> @Transactional always rolls back when any exception occurs.

That is incorrect.

---

# 66. What is transaction propagation?

Propagation determines how a transactional method behaves when another transaction already exists.

Common propagation types include:

```text
REQUIRED
REQUIRES_NEW
SUPPORTS
MANDATORY
NOT_SUPPORTED
NEVER
NESTED
```

The most important interview ones are:

### REQUIRED

Join an existing transaction or create one if none exists.

```text
Existing transaction?
    YES → join it
    NO  → create new transaction
```

### REQUIRES_NEW

Suspend an existing transaction and create a new one.

```text
Transaction A
     |
     +--> suspend A
             |
             +--> Transaction B
             |
             +--> commit/rollback B
     |
     +--> resume A
```

---

# 67. REQUIRED vs REQUIRES_NEW — tricky scenario

Suppose:

```java
@Transactional
public void order() {
    saveOrder();
    paymentService.processPayment();
}
```

and:

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void processPayment() {
}
```

What happens?

The outer transaction is suspended.

A new transaction is created for `processPayment()`.

Therefore the payment transaction can commit independently of the outer transaction.

This is useful in certain scenarios such as independent audit logging, but it should not be used casually because it changes transaction boundaries and resource usage.

---

# SECTION 9 — SPRING BOOT CONFIGURATION

# 68. What is configuration precedence?

Spring Boot supports multiple configuration sources.

The exact precedence depends on the Spring Boot version and configuration source involved, but generally more specific/external configuration can override values from packaged defaults.

Common sources include:

- Application configuration files
- Profile-specific configuration
- Environment variables
- System properties
- Command-line arguments

### Interview advice

Don't blindly state a single fixed precedence list without considering the Spring Boot version.

The important concept is:

> Spring Boot supports layered externalized configuration, and higher-precedence sources can override lower-precedence ones.

---

# 69. How do environment variables map to Spring properties?

For example:

```properties
server.port=8080
```

can be supplied using an environment-variable style configuration such as:

```text
SERVER_PORT=8080
```

Spring Boot supports relaxed binding conventions for configuration properties.

This is especially useful in Docker/Kubernetes deployments.

---

# 70. What is relaxed binding?

Spring Boot can map different naming conventions to the same logical configuration property.

For example, a property such as:

```text
payment.timeout
```

can be represented through supported environment/configuration naming conventions.

This makes external configuration easier across different deployment systems.

---

# SECTION 10 — SPRING BOOT ACTUATOR

# 71. What is Spring Boot Actuator?

Spring Boot Actuator provides production-oriented features for monitoring and managing an application.

It exposes endpoints that can provide information about:

- Application health
- Metrics
- Environment
- Beans
- Mappings
- Configuration
- Application information

Common endpoints include concepts such as:

```text
/actuator/health
/actuator/metrics
```

Exact exposure depends on configuration and Spring Boot version.

---

# 72. Why is Actuator important in production?

Because production systems need more than business APIs.

Operations teams need to know:

```text
Is the application alive?
Is it ready to receive traffic?
Are dependencies healthy?
How much memory is being used?
How many requests are occurring?
Are errors increasing?
```

Actuator integrates with monitoring and observability systems to help answer these questions.

---

# 73. What is the difference between liveness and readiness?

This is especially important in Kubernetes environments.

### Liveness

Answers approximately:

> Is this application process healthy enough to continue running?

A failed liveness check can cause the platform to restart the application.

### Readiness

Answers:

> Is this application currently ready to receive traffic?

A failed readiness check can cause the platform to stop sending traffic without necessarily restarting the application.

### Important

Do not confuse:

```text
Not ready
```

with:

```text
Dead
```

An application can be alive but temporarily not ready.

---

# SECTION 11 — TRICKY SPRING QUESTIONS

# 74. If a class has @Component, will Spring always create a bean?

No.

The class must be discovered and processed by the Spring application context.

Potential reasons it may not become a bean include:

- Package is outside component scanning
- Component scanning configuration excludes it
- Conditional configuration prevents registration
- Configuration isn't loaded into the relevant context

So:

```java
@Component
class MyService {
}
```

does not mean:

> Every Spring application everywhere will automatically create this bean.

---

# 75. Does Spring create a new object every time I autowire a singleton bean?

No.

For a singleton-scoped bean, Spring normally returns the same managed instance within the same container.

Example:

```java
@Autowired
OrderService orderService;
```

Another bean requesting the same singleton bean normally receives the same instance.

---

# 76. Is a Spring singleton automatically thread-safe?

**No.**

This is a very important interview trap.

Suppose:

```java
@Service
class CounterService {

    private int count;

    public void increment() {
        count++;
    }
}
```

Because the bean is singleton-scoped, many requests may use the same object concurrently.

The bean is therefore responsible for being thread-safe.

Spring singleton scope does not automatically make fields thread-safe.

### Better design

Prefer stateless singleton services:

```java
@Service
class OrderService {

    public Order createOrder(OrderRequest request) {
        // local variables
    }
}
```

Local variables belong to individual method invocations.

---

# 77. Should Spring Service classes be stateless?

Generally, yes.

A typical service should avoid mutable shared state such as:

```java
private int counter;
private List<Order> orders;
```

unless proper synchronization/concurrency management is intentionally implemented.

Stateless services are easier to:

- Scale
- Test
- Reason about
- Run concurrently

---

# 78. Can a Spring Bean be immutable?

Yes, and constructor injection makes this easy.

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

The dependency cannot be reassigned.

This is generally a clean design.

---

# 79. What happens if two classes have the same bean name?

Spring bean names need to be resolvable within the relevant application context.

For example:

```java
@Component("paymentService")
class A {
}
```

and:

```java
@Component("paymentService")
class B {
}
```

can create a bean-name conflict.

Depending on Spring Boot/Spring configuration and version, duplicate definitions may be rejected rather than silently replacing one another.

### Interview advice

Do not rely on bean overriding as an application design strategy.

---

# 80. How does Spring decide which constructor to use?

For dependency injection, Spring resolves the appropriate constructor according to its constructor-injection rules.

If there is a single constructor, it can generally be used without explicitly adding `@Autowired`.

If there are multiple constructors, you may need to explicitly indicate the intended constructor or otherwise configure the bean appropriately.

Example:

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

No `@Autowired` is required for a single constructor.

---

# 81. What is @PostConstruct execution order?

If bean A depends on bean B:

```text
A → B
```

B must be available as part of satisfying A's dependency.

But don't oversimplify this into:

> All @PostConstruct methods execute globally in dependency order.

Spring's bean lifecycle and initialization ordering are more nuanced.

If strict initialization ordering is required between independent beans, use appropriate dependency mechanisms such as:

```java
@DependsOn
```

when genuinely necessary.

---

# 82. What is @DependsOn?

`@DependsOn` tells Spring that one bean should be initialized after specified beans.

Example:

```java
@Component
@DependsOn("databaseInitializer")
class OrderService {
}
```

This is useful when there is a real initialization dependency that isn't represented by normal bean injection.

It should not be used as a replacement for proper dependency modeling.

---

# SECTION 12 — SPRING BOOT AUTO-CONFIGURATION TRAPS

# 83. If I add spring-boot-starter-data-jpa, will Spring automatically connect to any database?

**No.**

Spring Boot can auto-configure JPA infrastructure when the required conditions are met, but the application still needs appropriate database configuration and dependencies.

For example, you typically need:

```text
JPA dependencies
+
database driver
+
database configuration
```

Depending on the setup.

If required configuration is missing, startup can fail.

---

# 84. If I define my own bean, can it affect auto-configuration?

Yes.

This is a core principle of Spring Boot.

Auto-configuration commonly uses conditions such as:

```java
@ConditionalOnMissingBean
```

Meaning:

> Configure the default only if the application hasn't already provided an appropriate bean.

Conceptually:

```text
Boot:
"Should I create the default bean?"

        ↓

Does user-defined bean exist?

YES → don't create default
NO  → create default
```

This is one reason Spring Boot is customizable.

---

# 85. What does @ConditionalOnMissingBean mean?

It means configuration should be applied only when a matching bean is missing.

Conceptually:

```java
@Bean
@ConditionalOnMissingBean
public PaymentClient paymentClient() {
    return new DefaultPaymentClient();
}
```

If the application already provides its own suitable `PaymentClient`, Boot can back off from creating the default.

---

# 86. What is conditional configuration?

Conditional configuration means a configuration or bean is activated only when certain conditions are satisfied.

Examples:

```java
@ConditionalOnClass
@ConditionalOnBean
@ConditionalOnMissingBean
@ConditionalOnProperty
```

This mechanism is heavily used by Spring Boot auto-configuration.

---

# SECTION 13 — REAL INTERVIEW SCENARIOS

# 87. Your application starts locally but fails in production. What Spring Boot things would you check?

A strong interview answer should be systematic.

I would check:

### 1. Configuration

```text
Database URL
Credentials
Ports
Profiles
Environment variables
```

### 2. Active profile

```text
dev vs test vs prod
```

### 3. Dependencies

Check whether production has the required:

- Database driver
- External service configuration
- Runtime dependencies

### 4. Logs

Look for:

```text
BeanCreationException
Configuration errors
Connection errors
Port conflicts
Authentication failures
```

### 5. Auto-configuration report

Check why an expected configuration was or wasn't activated.

### 6. Network

Check:

```text
DNS
Firewall
Service discovery
Database accessibility
```

### 7. Secrets

Check whether secrets are correctly injected.

A senior developer should not answer only:

> "I will check the logs."

They should explain a structured debugging process.

---

# 88. Your Spring Boot application is very slow during startup. How would you investigate?

I would investigate:

1. Startup logs
2. Bean initialization
3. Database connection initialization
4. External service calls during startup
5. Excessive component scanning
6. Expensive `@PostConstruct` logic
7. Auto-configuration
8. Large classpath/dependency graph
9. Lazy vs eager initialization where appropriate
10. JVM startup and class loading

I would avoid randomly adding:

```java
@Lazy
```

everywhere.

First identify what is actually slow.

---

# 89. A Spring Boot API works with one request but fails under concurrent load. What might be wrong?

Possible causes include:

- Mutable state inside singleton beans
- Non-thread-safe shared objects
- Database connection pool exhaustion
- Thread pool exhaustion
- Blocking external calls
- Race conditions
- Incorrect synchronization
- Poor database indexing
- Excessive locks
- Memory pressure

For example, this is dangerous:

```java
@Service
class OrderService {

    private Order currentOrder;

    public void process(Order order) {
        this.currentOrder = order;
    }
}
```

Multiple requests can access the same singleton instance concurrently.

A better design usually keeps request-specific state inside method-local variables.

---

# 90. Why is storing request-specific data in a singleton service dangerous?

Because singleton beans are shared.

Suppose:

```java
@Service
class UserService {

    private String currentUser;

    public void process(String user) {
        currentUser = user;
    }
}
```

Request A:

```text
currentUser = Alice
```

Request B:

```text
currentUser = Bob
```

They can execute concurrently.

The shared field can therefore contain incorrect data.

### Correct principle

> Request-specific data should normally be kept in request scope, method-local variables, or another appropriately scoped/contextual mechanism—not shared mutable fields in singleton services.

---

# 91. Why does constructor injection help circular dependency detection?

Suppose:

```java
A → B
B → A
```

With constructor injection:

```java
class A {
    A(B b) {}
}

class B {
    B(A a) {}
}
```

Both objects require the other before construction can complete.

This makes the cycle immediately apparent.

Constructor injection therefore encourages explicit dependency graphs and often exposes architectural problems earlier.

---

# 92. What is the difference between dependency and collaboration?

Suppose:

```java
OrderService
    ↓
PaymentService
```

`OrderService` depends on `PaymentService` to perform its work.

The important design question is not merely:

> "Can Spring inject this?"

It is:

> "Should this object actually depend on that object?"

Spring can make bad architecture easier to wire.

It cannot automatically make the architecture good.

This is an excellent point to mention in senior interviews.

---

# SECTION 14 — VERY TRICKY QUESTIONS

# 93. If Spring singleton means one instance, why can two different application contexts have two instances?

Because singleton scope is:

> One instance per Spring container/application context.

For example:

```text
ApplicationContext A
    └── OrderService instance #1

ApplicationContext B
    └── OrderService instance #2
```

Both can exist.

Therefore:

```text
Spring singleton ≠ JVM singleton
```

---

# 94. Does @Autowired create the object?

No.

`@Autowired` expresses dependency injection.

The Spring container is responsible for bean creation and dependency resolution.

For example:

```java
@Autowired
private PaymentService paymentService;
```

does not itself mean:

```java
new PaymentService()
```

Spring determines how the dependency is obtained based on bean definitions and configuration.

---

# 95. Is dependency injection the same as dependency inversion?

No.

These concepts are related but different.

### Dependency Injection

A technique for supplying dependencies.

### Dependency Inversion Principle

A SOLID design principle stating that high-level modules should depend on abstractions rather than concrete implementations.

Example:

Better:

```java
OrderService
    ↓
PaymentProcessor interface
    ↑
CardPaymentProcessor
```

rather than:

```java
OrderService
    ↓
CardPaymentProcessor
```

Spring DI can help implement dependency inversion, but DI itself is not the same as DIP.

---

# 96. Does using Spring automatically make code loosely coupled?

**No.**

Spring provides mechanisms that can help reduce coupling.

But you can still write highly coupled Spring code:

```java
@Service
class OrderService {

    private final ConcretePaymentService paymentService;

    public OrderService(ConcretePaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Dependency injection is present, but the design may still depend directly on a concrete implementation.

A better architecture may depend on:

```java
PaymentProcessor
```

instead.

---

# 97. Is using an interface always better?

No.

Creating interfaces for every class simply because "Spring best practice says interfaces" is unnecessary.

Interfaces are valuable when:

- Multiple implementations exist
- An abstraction represents a meaningful contract
- Different implementations are expected
- Decoupling is architecturally useful
- Testing/design benefits from the abstraction

Don't create:

```text
UserService
IUserService
UserServiceImpl
```

automatically without a reason.

---

# 98. Why can too many Spring Beans become a problem?

Spring can manage many beans, but excessive fragmentation can cause:

- Complex dependency graphs
- Difficult debugging
- Longer startup
- Harder testing
- Poorly defined responsibilities
- Excessive abstraction

A good Spring application is not one where every method has its own bean.

Use beans where lifecycle, dependency management, configuration, cross-cutting concerns, or architectural responsibility justify them.

---

# 99. What is the most common mistake developers make with Spring?

One major mistake is learning annotations without understanding the container.

For example, memorizing:

```text
@Component
@Service
@Repository
@Autowired
@Transactional
@Async
@Cacheable
```

is not enough.

You should understand:

```text
Who creates the object?
Who calls the method?
Does the call pass through a proxy?
What scope does the bean have?
What thread is executing it?
What transaction exists?
What configuration is active?
```

These questions explain many "Spring magic" problems.

---

# 100. Explain Spring in one interview answer.

A strong concise answer:

> Spring is a Java application framework centered around IoC and Dependency Injection. The Spring container manages application objects, their dependencies, and their lifecycle. Spring also provides infrastructure such as AOP, transaction management, web MVC, data access, security, and integration support. Spring Boot builds on Spring by providing opinionated auto-configuration, starter dependencies, embedded servers, externalized configuration, and production-oriented features, allowing us to build and deploy Spring applications with significantly less manual configuration.

---

# QUICK REVISION — 30 QUESTIONS YOU MUST KNOW

Before an interview, make sure you can answer these without memorizing blindly:

```text
1. What is Spring?
2. What is Spring Boot?
3. Spring vs Spring Boot?
4. What is IoC?
5. What is Dependency Injection?
6. Constructor vs Setter vs Field Injection?
7. What is a Spring Bean?
8. What is ApplicationContext?
9. BeanFactory vs ApplicationContext?
10. What is @Component?
11. @Component vs @Service?
12. @Repository vs @Component?
13. @Controller vs @RestController?
14. What is @Configuration?
15. What is @Bean?
16. @Bean vs @Component?
17. What is component scanning?
18. What are Spring bean scopes?
19. What is singleton scope?
20. Is Spring singleton thread-safe?
21. What is @Autowired?
22. What happens with multiple beans of the same type?
23. @Primary vs @Qualifier?
24. What is @SpringBootApplication?
25. What is auto-configuration?
26. What are Spring Boot starters?
27. Starter vs auto-configuration?
28. What is @Transactional?
29. Why does self-invocation affect Spring AOP?
30. What happens when a Spring bean is created using new?
```

---

# INTERVIEWER'S "DEEP UNDERSTANDING" CHECKLIST

If you are targeting a mid-level or senior Java/Spring role, don't stop at definitions.

You should be able to explain this chain:

```text
@SpringBootApplication
        ↓
Component Scanning
        ↓
Bean Definitions
        ↓
ApplicationContext
        ↓
Bean Creation
        ↓
Dependency Injection
        ↓
Bean Lifecycle
        ↓
BeanPostProcessor
        ↓
Proxy Creation
        ↓
AOP
        ↓
@Transactional / @Async / @Cacheable / Security
        ↓
Method Invocation
```

You should also understand this chain:

```text
Spring Boot Starter
        ↓
Dependencies on Classpath
        ↓
Auto-Configuration Candidates
        ↓
Conditional Evaluation
        ↓
@Configuration
        ↓
@Bean Definitions
        ↓
ApplicationContext
```

And this extremely important chain:

```text
Client
   ↓
Spring Proxy
   ↓
Interceptor
   ↓
Transaction / Security / Cache / AOP
   ↓
Target Bean
   ↓
Business Method
```

If you understand these three flows, many advanced Spring interview questions become much easier.

---

# 10 QUESTIONS INTERVIEWERS USE TO TRAP CANDIDATES

## Trap 1

**Question:** Is Spring singleton thread-safe?

**Wrong:**
> Yes.

**Correct:**
> No. Singleton scope only controls bean creation. Multiple threads can access the same instance concurrently, so mutable shared state must be handled safely.

---

## Trap 2

**Question:** Does @Transactional always work?

**Wrong:**
> Yes, whenever I put the annotation.

**Correct:**
> No. It relies on Spring's transaction infrastructure, commonly proxy-based interception. Cases such as self-invocation, unmanaged objects, and incorrect transaction configuration can prevent the expected behavior.

---

## Trap 3

**Question:** Does @Autowired create an object?

**Wrong:**
> Yes.

**Correct:**
> No. It participates in dependency resolution/injection. The Spring container manages bean creation.

---

## Trap 4

**Question:** Is @Service fundamentally different from @Component?

**Correct:**
> @Service is a specialization of @Component used to communicate service-layer semantics. Both can participate in component scanning and bean registration.

---

## Trap 5

**Question:** Is a Spring singleton the same as a Java Singleton pattern?

**Correct:**
> No. Spring singleton means one bean instance per Spring container, whereas the classic Singleton pattern is a design pattern intended to restrict construction to one instance in a broader scope such as the JVM/application.

---

## Trap 6

**Question:** If I have two implementations of an interface, will Spring randomly choose one?

**Correct:**
> No. If there are multiple candidates and no resolution mechanism such as @Qualifier or @Primary applies, dependency resolution can fail with a no-unique-bean error.

---

## Trap 7

**Question:** Does adding a Spring Boot starter automatically configure everything?

**Correct:**
> No. A starter primarily brings dependencies onto the classpath. Auto-configuration then conditionally configures infrastructure based on the environment.

---

## Trap 8

**Question:** If I call a @Transactional method from another method in the same class, will the transaction always start?

**Correct:**
> Not necessarily. With proxy-based Spring AOP, self-invocation bypasses the proxy, so the transactional interceptor may not be invoked.

---

## Trap 9

**Question:** Is constructor injection just a coding style?

**Correct:**
> No. It has meaningful design advantages: required dependencies are explicit, objects can be immutable, testing is easier, and invalid dependency states are harder to construct.

---

## Trap 10

**Question:** Can Spring fix bad architecture?

**Correct:**
> No. Spring provides dependency-management and application infrastructure mechanisms, but developers are still responsible for designing appropriate boundaries, responsibilities, dependency directions, and concurrency behavior.

---

# FINAL PART 1 CHEAT SHEET

```text
IoC
= Spring controls object creation/dependency management.

DI
= Dependencies are supplied from outside the class.

Bean
= Object managed by Spring container.

ApplicationContext
= Feature-rich Spring IoC container.

@Component
= Generic component.

@Service
= Service-layer component.

@Repository
= Persistence-layer component + persistence exception translation semantics.

@Controller
= MVC controller.

@RestController
= Controller whose methods generally write response bodies directly.

@Configuration
= Configuration class.

@Bean
= Explicit bean definition method.

@Component
= Class discovered through component scanning.

@Bean
= Explicitly defined bean.

Default scope
= Singleton.

Spring singleton
= One instance per container, NOT necessarily one instance per JVM.

Prototype
= New instance when requested from the container.

@Primary
= Preferred candidate.

@Qualifier
= Explicit candidate selection.

@SpringBootApplication
= @SpringBootConfiguration + @EnableAutoConfiguration + @ComponentScan.

Starter
= Convenient dependency set.

Auto-configuration
= Conditional automatic configuration.

@Value
= Inject individual configuration values.

@ConfigurationProperties
= Type-safe/grouped configuration binding.

@Profile
= Environment-specific configuration.

@PostConstruct
= Initialization callback.

@PreDestroy
= Destruction callback.

AOP
= Cross-cutting concerns.

Proxy
= Object that intercepts calls around target beans.

@Transactional
= Declarative transaction management.

Self-invocation
= Can bypass Spring proxy and therefore bypass proxy-based AOP advice.

Singleton ≠ thread-safe
= Shared mutable state can still cause concurrency bugs.

new MyService()
= Ordinary Java object; not automatically a Spring-managed bean.

Spring Boot
= Simplifies Spring configuration, startup, deployment and production features.
```

# END OF PART 1

## What you should be able to do after Part 1

You should now be able to explain not only **what** Spring annotations do, but also:

```text
WHY they exist
HOW Spring discovers them
HOW beans are created
HOW dependencies are resolved
HOW bean scopes work
HOW the lifecycle works
HOW auto-configuration works
HOW Spring AOP/proxies work
WHY @Transactional can fail
WHY singleton beans can have concurrency problems
```

These "why/how" questions are what usually separate a candidate who has **used Spring Boot** from one who actually **understands Spring Boot**.

**Part 2 should move into the next major interview area: Spring MVC + REST + JPA/Hibernate + Transactions + Exception Handling**, including questions such as:

```text
@GetMapping vs @RequestMapping
@PathVariable vs @RequestParam vs @RequestBody
@RestController internals
DispatcherServlet
Filters vs Interceptors vs AOP
HTTP status codes
DTO vs Entity
Lazy vs Eager loading
N+1 problem
Hibernate first-level cache
Second-level cache
save() vs saveAndFlush()
JPA persistence context
Dirty checking
@Transactional propagation
Isolation levels
Optimistic vs pessimistic locking
Entity relationships
Cascade types
orphanRemoval
JOIN FETCH
EntityGraph
Pagination
Specification
Global exception handling
@ControllerAdvice
and many real-world debugging scenarios
```