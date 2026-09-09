# Logging System — LLD

## 1. Problem Statement

Design a logging framework similar to:

```text
Log4j
SLF4J
java.util.logging
```

The system should allow an application to write logs at different levels:

```text
DEBUG
INFO
WARN
ERROR
FATAL
```

Example:

```java
logger.info("User logged in");
logger.error("Payment failed");
logger.debug("Request received");
```

The logging system should decide:

- Which log messages should be processed?
- Where should they go?
- What format should they have?
- Can we add new destinations later?

---

# 2. Requirements

## Functional Requirements

The logging system should support:

1. Different log levels.
2. Logging messages.
3. Console output.
4. File output.
5. Multiple handlers.
6. Different log formats.
7. Filtering based on log level.
8. Ability to add new handlers easily.

For example:

```text
INFO  → Console
ERROR → Console + File
DEBUG → File
```

---

# 3. Example Usage

We want application code to look simple:

```java
Logger logger = Logger.getLogger();

logger.info("Application started");

logger.debug("Fetching user");

logger.warn("Low disk space");

logger.error("Database connection failed");
```

The application should not care about:

```text
File handling
Console handling
Formatting
Filtering
```

That should be handled by the logging framework.

---

# 4. High-Level Architecture

```text
Application
     |
     v
   Logger
     |
     v
 LogRecord
     |
     v
 LogManager / Handler Chain
     |
     +----------+-----------+
     |          |           |
     v          v           v
 Console     File        Database
 Handler     Handler      Handler
```

A more extensible version:

```text
Logger
  |
  v
Handlers
  |
  +---- ConsoleHandler
  |
  +---- FileHandler
  |
  +---- DatabaseHandler
  |
  +---- RemoteHandler
```

---

# 5. Identify Entities

Main classes:

```text
Logger
LogRecord
LogHandler
ConsoleHandler
FileHandler
Formatter
ConsoleFormatter
FileFormatter
LoggerConfig
```

Enums:

```text
LogLevel
```

Optional classes:

```text
LoggerManager
AsyncLogger
DatabaseHandler
```

---

# 6. Log Level

First define the log levels.

```java
public enum LogLevel {

    DEBUG(1),
    INFO(2),
    WARN(3),
    ERROR(4),
    FATAL(5);

    private final int priority;

    LogLevel(int priority) {
        this.priority = priority;
    }

    public int getPriority() {
        return priority;
    }
}
```

Why do we need priority?

Because we may configure:

```text
Minimum level = INFO
```

Then:

```text
DEBUG → ignored
INFO  → processed
WARN  → processed
ERROR → processed
FATAL → processed
```

---

# 7. LogRecord

A log message should contain more than just text.

For example:

```text
2026-09-07 23:30:10
ERROR
Payment failed
OrderService
Thread-12
```

Create a `LogRecord`.

```java
import java.time.LocalDateTime;

public class LogRecord {

    private final LogLevel level;
    private final String message;
    private final String loggerName;
    private final LocalDateTime timestamp;
    private final String threadName;

    public LogRecord(
            LogLevel level,
            String message,
            String loggerName) {

        this.level = level;
        this.message = message;
        this.loggerName = loggerName;
        this.timestamp = LocalDateTime.now();
        this.threadName =
                Thread.currentThread().getName();
    }

    public LogLevel getLevel() {
        return level;
    }

    public String getMessage() {
        return message;
    }

    public String getLoggerName() {
        return loggerName;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public String getThreadName() {
        return threadName;
    }
}
```

---

# 8. Why `LogRecord`?

Instead of passing:

```java
handler.handle(
    level,
    message,
    timestamp,
    loggerName,
    threadName
);
```

we pass:

```java
handler.handle(logRecord);
```

This is cleaner.

Tomorrow we can add:

```text
requestId
userId
serviceName
machineName
exception
traceId
```

without changing every method signature.

---

# 9. Formatter

Now we need to decide how a log should look.

Example:

```text
2026-09-07T23:30:10 [ERROR] Payment failed
```

Create:

```java
public interface Formatter {

    String format(LogRecord record);
}
```

---

# 10. Simple Formatter

```java
public class SimpleFormatter
        implements Formatter {

    @Override
    public String format(LogRecord record) {

        return String.format(
                "%s [%s] [%s] %s",
                record.getTimestamp(),
                record.getLevel(),
                record.getLoggerName(),
                record.getMessage()
        );
    }
}
```

Output:

```text
2026-09-07T23:30:10 [ERROR] [PaymentService] Payment failed
```

---

# 11. JSON Formatter

Suppose another application wants JSON:

```text
{
  "timestamp": "...",
  "level": "ERROR",
  "message": "Payment failed"
}
```

We can create:

```java
public class JsonFormatter
        implements Formatter {

    @Override
    public String format(LogRecord record) {

        return String.format(
                "{\"timestamp\":\"%s\","
                + "\"level\":\"%s\","
                + "\"logger\":\"%s\","
                + "\"message\":\"%s\"}",
                record.getTimestamp(),
                record.getLevel(),
                record.getLoggerName(),
                record.getMessage()
        );
    }
}
```

Now:

```text
Formatter
    |
    +---- SimpleFormatter
    |
    +---- JsonFormatter
```

This is another example of **Strategy Pattern**.

---

# 12. Log Handler

A handler decides where the log goes.

Create an abstraction:

```java
public abstract class LogHandler {

    protected LogLevel level;
    protected LogHandler next;
    protected Formatter formatter;

    public LogHandler(
            LogLevel level,
            Formatter formatter) {

        this.level = level;
        this.formatter = formatter;
    }

    public void setNext(LogHandler next) {
        this.next = next;
    }

    public void handle(LogRecord record) {

        if (record.getLevel().getPriority()
                >= level.getPriority()) {

            write(record);
        }

        if (next != null) {
            next.handle(record);
        }
    }

    protected abstract void write(
            LogRecord record);
}
```

This is the important part.

---

# 13. Why `next`?

We can create a chain:

```text
Logger
  |
  v
ConsoleHandler
  |
  v
FileHandler
  |
  v
DatabaseHandler
```

A log is passed through the chain.

This is the **Chain of Responsibility Pattern**.

---

# 14. Console Handler

```java
public class ConsoleHandler
        extends LogHandler {

    public ConsoleHandler(
            LogLevel level,
            Formatter formatter) {

        super(level, formatter);
    }

    @Override
    protected void write(
            LogRecord record) {

        System.out.println(
                formatter.format(record)
        );
    }
}
```

---

# 15. File Handler

```java
import java.io.FileWriter;
import java.io.IOException;

public class FileHandler
        extends LogHandler {

    private final String fileName;

    public FileHandler(
            LogLevel level,
            Formatter formatter,
            String fileName) {

        super(level, formatter);
        this.fileName = fileName;
    }

    @Override
    protected void write(
            LogRecord record) {

        try (FileWriter writer =
                     new FileWriter(
                             fileName,
                             true)) {

            writer.write(
                    formatter.format(record)
                    + System.lineSeparator()
            );

        } catch (IOException e) {

            System.err.println(
                    "Failed to write log: "
                    + e.getMessage()
            );
        }
    }
}
```

---

# 16. Database Handler

We can later add:

```java
public class DatabaseHandler
        extends LogHandler {

    public DatabaseHandler(
            LogLevel level,
            Formatter formatter) {

        super(level, formatter);
    }

    @Override
    protected void write(
            LogRecord record) {

        // Insert record into database.
        System.out.println(
                "Writing log to database: "
                + record.getMessage()
        );
    }
}
```

Notice:

We didn't change `Logger`.

This is the benefit of programming against abstractions.

---

# 17. Logger

Now create the main `Logger`.

```java
import java.util.*;

public class Logger {

    private final String name;
    private final List<LogHandler> handlers;

    public Logger(String name) {

        this.name = name;
        this.handlers = new ArrayList<>();
    }

    public void addHandler(
            LogHandler handler) {

        handlers.add(handler);
    }

    public void debug(String message) {
        log(LogLevel.DEBUG, message);
    }

    public void info(String message) {
        log(LogLevel.INFO, message);
    }

    public void warn(String message) {
        log(LogLevel.WARN, message);
    }

    public void error(String message) {
        log(LogLevel.ERROR, message);
    }

    public void fatal(String message) {
        log(LogLevel.FATAL, message);
    }

    private void log(
            LogLevel level,
            String message) {

        LogRecord record =
                new LogRecord(
                        level,
                        message,
                        name
                );

        for (LogHandler handler : handlers) {
            handler.handle(record);
        }
    }
}
```

---

# 18. Main Example

```java
public class Main {

    public static void main(String[] args) {

        Formatter formatter =
                new SimpleFormatter();

        ConsoleHandler consoleHandler =
                new ConsoleHandler(
                        LogLevel.INFO,
                        formatter
                );

        FileHandler fileHandler =
                new FileHandler(
                        LogLevel.ERROR,
                        formatter,
                        "application.log"
                );

        Logger logger =
                new Logger("Application");

        logger.addHandler(consoleHandler);
        logger.addHandler(fileHandler);

        logger.debug(
                "Debug message"
        );

        logger.info(
                "Application started"
        );

        logger.warn(
                "Memory usage is high"
        );

        logger.error(
                "Database connection failed"
        );
    }
}
```

---

# 19. What Happens?

Configuration:

```text
ConsoleHandler → INFO
FileHandler    → ERROR
```

Now:

```text
DEBUG
```

Result:

```text
Console → No
File    → No
```

---

```text
INFO
```

Result:

```text
Console → Yes
File    → No
```

---

```text
WARN
```

Result:

```text
Console → Yes
File    → No
```

---

```text
ERROR
```

Result:

```text
Console → Yes
File    → Yes
```

So:

```text
                    Console   File
DEBUG                 ❌       ❌
INFO                  ✅       ❌
WARN                  ✅       ❌
ERROR                 ✅       ✅
FATAL                 ✅       ✅
```

---

# 20. Important Design Observation

There are actually two different concepts:

```text
Log Level
    ↓
How important is this log?

Handler
    ↓
Where should this log go?
```

Don't mix them.

For example:

```text
ERROR
```

doesn't mean:

```text
File
```

because we could configure:

```text
ERROR → Console
ERROR → File
ERROR → Database
ERROR → Remote server
```

---

# 21. Chain of Responsibility

The classic interview version often expects a chain like:

```text
Logger
  |
  v
DebugHandler
  |
  v
InfoHandler
  |
  v
ErrorHandler
```

For example:

```text
DEBUG → DebugHandler
INFO  → InfoHandler
ERROR → ErrorHandler
```

Each handler decides whether it can process the message.

However, for a production-style logging framework, **multiple independent handlers** are often more natural because the same ERROR log may need to go to several destinations.

So there are two valid designs:

### Chain

```text
Handler
   |
   v
Next Handler
```

Useful when handlers form a sequential processing pipeline.

### Handler list

```text
Logger
 |
 +---- Console
 |
 +---- File
 |
 +---- Database
```

Useful when multiple outputs should independently receive the same record.

In an interview, mention this distinction.

---

# 22. Better Handler Design

For the above reason, I prefer this design for our main implementation:

```java
public interface LogHandler {

    void handle(LogRecord record);
}
```

Then:

```java
ConsoleHandler
FileHandler
DatabaseHandler
```

all implement it.

Logger:

```java
for (LogHandler handler : handlers) {
    handler.handle(record);
}
```

This is simpler and more flexible.

---

# 23. Add Handler-Level Filtering

We can make the handler responsible for filtering.

```java
public abstract class LogHandler {

    protected final LogLevel minLevel;
    protected final Formatter formatter;

    protected LogHandler(
            LogLevel minLevel,
            Formatter formatter) {

        this.minLevel = minLevel;
        this.formatter = formatter;
    }

    public void handle(LogRecord record) {

        if (record.getLevel().getPriority()
                >= minLevel.getPriority()) {

            write(record);
        }
    }

    protected abstract void write(
            LogRecord record);
}
```

This gives:

```text
Logger
   |
   +---- ConsoleHandler(INFO)
   |
   +---- FileHandler(ERROR)
   |
   +---- DatabaseHandler(WARN)
```

Very clean.

---

# 24. Logger Factory / Manager

In a real application, we don't want every class creating:

```java
new Logger("PaymentService");
```

independently.

We want:

```java
Logger logger =
        LoggerManager.getLogger(
                "PaymentService"
        );
```

Create:

```java
import java.util.concurrent.ConcurrentHashMap;

public class LoggerManager {

    private static final
    ConcurrentHashMap<String, Logger> loggers =
            new ConcurrentHashMap<>();

    public static Logger getLogger(
            String name) {

        return loggers.computeIfAbsent(
                name,
                Logger::new
        );
    }
}
```

Now:

```java
Logger logger =
        LoggerManager.getLogger(
                "PaymentService"
        );
```

The same logger can be reused.

---

# 25. Why `ConcurrentHashMap`?

Logging is typically called by many application threads.

Example:

```text
Thread 1 → PaymentService
Thread 2 → PaymentService
Thread 3 → PaymentService
Thread 4 → PaymentService
```

We don't want race conditions while creating/retrieving loggers.

Therefore:

```java
ConcurrentHashMap
```

is appropriate for this simple logger registry.

---

# 26. Should LoggerManager Be Singleton?

This is a common interview question.

You could use:

```text
Singleton LoggerManager
```

but Singleton is not automatically required.

A static registry:

```java
ConcurrentHashMap
```

can be enough for this simplified design.

If we need configurable lifecycle/dependency injection, a normal managed component is usually preferable.

Interview answer:

> "I don't need Singleton just for the sake of the pattern. I need a shared logger registry. That can be implemented through a static registry or dependency-injected manager depending on the application's architecture."

This is a better answer than blindly saying "use Singleton."

---

# 27. Logger Configuration

Suppose we want:

```text
Console → INFO
File → DEBUG
Database → ERROR
```

Create a configuration object.

```java
public class LoggerConfig {

    private final LogLevel level;

    public LoggerConfig(
            LogLevel level) {

        this.level = level;
    }

    public LogLevel getLevel() {
        return level;
    }
}
```

In a larger implementation, configuration could contain:

```text
LogLevel
Handlers
Formatter
File path
Rotation settings
Async settings
```

---

# 28. Global Log Level

There are two useful filtering levels.

### Logger-level filter

```text
Logger minimum = INFO
```

Then DEBUG isn't even sent to handlers.

### Handler-level filter

```text
Console = INFO
File = ERROR
```

This lets different destinations have different thresholds.

So the architecture can be:

```text
Application
    |
    v
  Logger
    |
    | Global filter
    v
 LogRecord
    |
    +--------+---------+
    |        |         |
    v        v         v
 Console    File     Database
 INFO       ERROR      WARN
```

---

# 29. Performance Problem

Logging can become expensive.

Consider:

```java
logger.debug(
    "User details: " + expensiveOperation()
);
```

Even if DEBUG logging is disabled, `expensiveOperation()` may execute before `logger.debug()` is called.

A better API can support lazy evaluation:

```java
logger.debug(
    () -> "User details: "
          + expensiveOperation()
);
```

Then the message is constructed only if DEBUG is enabled.

For example:

```java
import java.util.function.Supplier;

public void debug(
        Supplier<String> messageSupplier) {

    if (!isEnabled(LogLevel.DEBUG)) {
        return;
    }

    log(
        LogLevel.DEBUG,
        messageSupplier.get()
    );
}
```

This is an important production-level optimization.

---

# 30. Asynchronous Logging

Synchronous logging:

```text
Application
    |
    v
Logger
    |
    v
File I/O
    |
    v
Continue application
```

File I/O can slow down application threads.

Instead:

```text
Application
    |
    v
Logger
    |
    v
Queue
    |
    v
Logging Worker
    |
    v
File / Database / Remote
```

The application only puts the log into a queue.

A background thread writes it.

---

# 31. Async Logger

Conceptually:

```java
BlockingQueue<LogRecord> queue;
```

Application:

```java
queue.put(record);
```

Worker:

```java
while (true) {

    LogRecord record =
            queue.take();

    write(record);
}
```

Advantages:

```text
Application thread
→ less I/O waiting
→ higher throughput
```

But now we have new problems:

```text
Queue full
Application shutdown
Dropped logs
Backpressure
Ordering
Worker failure
```

---

# 32. Bounded Queue

Never assume:

```java
new LinkedBlockingQueue<>()
```

can grow forever.

A bounded queue:

```java
new ArrayBlockingQueue<>(10000);
```

forces us to define what happens when the queue is full.

Possible policies:

```text
BLOCK
DROP_DEBUG
DROP_OLDEST
DROP_NEWEST
FALLBACK_TO_SYNC
```

This is an excellent production follow-up.

---

# 33. Log Rotation

Suppose:

```text
application.log
```

becomes:

```text
100 GB
```

That's obviously problematic.

We need log rotation.

Possible policies:

```text
Size-based:
application.log
application.log.1
application.log.2

Time-based:
application-2026-09-07.log
application-2026-09-08.log
```

Create an abstraction:

```java
public interface RotationPolicy {

    boolean shouldRotate(
            long currentSize,
            long currentTime
    );
}
```

Implementations:

```text
SizeBasedRotationPolicy
TimeBasedRotationPolicy
```

Again, **Strategy Pattern**.

---

# 34. File Handler Architecture

A more extensible file handler can become:

```text
FileHandler
     |
     +---- Formatter
     |
     +---- RotationPolicy
     |
     +---- OutputStream
```

So:

```text
FileHandler
   |
   +---- formatting
   +---- writing
   +---- rotation
```

But don't put everything into one class in a production design.

---

# 35. Exception Logging

Real logs often contain exceptions.

Instead of:

```java
logger.error(
    "Payment failed: "
    + exception.getMessage()
);
```

we want:

```java
logger.error(
    "Payment failed",
    exception
);
```

Extend `LogRecord`:

```java
private final Throwable throwable;
```

Then the formatter can print:

```text
ERROR Payment failed

java.lang.NullPointerException
    at PaymentService.process(...)
    at ...
```

This is important because stack traces are valuable debugging information.

---

# 36. Structured Logging

Instead of only:

```text
Payment failed
```

we may want:

```text
{
    "level": "ERROR",
    "message": "Payment failed",
    "service": "payment-service",
    "orderId": "ORD123",
    "userId": "U100",
    "requestId": "REQ456"
}
```

This is called **structured logging**.

A better `LogRecord` can eventually contain:

```text
message
level
timestamp
loggerName
threadName
exception
metadata
```

where:

```java
Map<String, Object> metadata;
```

contains contextual information.

---

# 37. Context / Correlation ID

In distributed systems:

```text
Request
  |
  v
Service A
  |
  v
Service B
  |
  v
Service C
```

One user request can generate logs across many services.

We want:

```text
requestId = REQ123
```

in every log.

Then we can search:

```text
REQ123
```

and reconstruct the request flow.

This is extremely important in production logging.

---

# 38. Class Diagram

```text
                        +------------------+
                        |     Logger       |
                        +--------+---------+
                                 |
                                 |
                                 v
                         +---------------+
                         |   LogRecord   |
                         +-------+-------+
                                 |
                   +-------------+-------------+
                   |             |             |
                   v             v             v
              ConsoleHandler  FileHandler  DBHandler
                   |             |             |
                   +-------------+-------------+
                                 |
                                 v
                             Formatter
                                 |
                    +------------+------------+
                    |                         |
                    v                         v
              SimpleFormatter          JsonFormatter


                     LoggerManager
                          |
                          v
                   Logger Registry
```

---

# 39. Design Patterns Used

## 1. Strategy Pattern

Used for:

```text
Formatter
Pricing-like formatting behavior
RotationPolicy
```

Example:

```text
Formatter
   |
   +---- SimpleFormatter
   +---- JsonFormatter
```

---

## 2. Chain of Responsibility

Useful if log processing is represented as a sequential handler chain:

```text
Handler
   |
   v
Next Handler
   |
   v
Next Handler
```

But for multiple output destinations, a handler list is often cleaner.

---

## 3. Factory Pattern

Can be used to create:

```text
Logger
Handler
Formatter
```

based on configuration.

Example:

```java
Formatter formatter =
        FormatterFactory.getFormatter(
                FormatType.JSON
        );
```

---

## 4. Singleton / Shared Registry

A shared logger manager may be implemented as a singleton or static registry, but the pattern itself isn't mandatory.

---

# 40. SOLID Principles

## SRP

Each component has a focused responsibility.

```text
Logger
→ creates/processes log records

LogRecord
→ stores log information

Handler
→ writes log somewhere

Formatter
→ converts record to text

RotationPolicy
→ decides when file should rotate
```

---

## OCP

Adding:

```text
KafkaHandler
ElasticsearchHandler
DatabaseHandler
```

should not require changing `Logger`.

Just implement:

```java
LogHandler
```

---

## LSP

Any:

```text
ConsoleHandler
FileHandler
DatabaseHandler
```

should be usable wherever a `LogHandler` is expected.

---

## DIP

Logger should depend on:

```java
LogHandler
```

not:

```java
FileHandler
```

specifically.

---

# 41. Thread Safety

Logging is inherently multi-threaded.

Example:

```text
Thread 1 → logger.info()
Thread 2 → logger.error()
Thread 3 → logger.debug()
```

Potential problems:

### Problem 1 — Interleaved file writes

Two threads might write simultaneously.

Use:

```text
synchronization
single writer thread
thread-safe output abstraction
```

---

### Problem 2 — Logger registry

Use:

```java
ConcurrentHashMap
```

---

### Problem 3 — Async queue

Use:

```java
BlockingQueue
```

---

# 42. Ordering

Suppose:

```text
Thread A → Log 1
Thread B → Log 2
```

Which should appear first?

There are different guarantees:

```text
Global ordering
Per-thread ordering
Per-request ordering
Best effort
```

Global ordering is expensive in distributed systems.

A practical design may guarantee:

> Logs emitted by the same logger/thread are ordered, while global ordering across multiple application instances is not guaranteed.

If strict global ordering is required, it needs additional coordination and can become expensive.

---

# 43. Failure Handling

What if the file cannot be written?

Never let logging failure casually crash the application.

Bad:

```java
throw new RuntimeException(
    "Unable to write log"
);
```

because now:

```text
Logging failure
     ↓
Application failure
```

Usually we want a fallback policy:

```text
File failure
    ↓
stderr / console
```

or:

```text
File failure
    ↓
buffer / retry
```

depending on requirements.

But we should be careful: silently dropping critical logs may be unacceptable.

---

# 44. Security

Logging can accidentally expose sensitive data.

Never blindly log:

```text
Password
Credit card number
Authentication token
API secret
Personal sensitive information
```

For example:

Bad:

```text
User login:
password=abc123
```

Better:

```text
User login failed:
userId=12345
```

Potentially sensitive fields should be masked/redacted.

We can introduce:

```java
public interface LogSanitizer {

    LogRecord sanitize(
            LogRecord record
    );
}
```

---

# 45. Logging Levels

Typical interpretation:

```text
DEBUG
    Detailed developer information.

INFO
    Normal application events.

WARN
    Something unexpected but recoverable.

ERROR
    Operation failed.

FATAL
    Severe failure requiring immediate attention.
```

For a simple system:

```text
DEBUG < INFO < WARN < ERROR < FATAL
```

---

# 46. Interview-Level Final Design

I would present the final design like this:

```text
                       Application
                            |
                            v
                         Logger
                            |
                            v
                       LogRecord
                            |
                            v
                      Global Filter
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
       ConsoleHandler   FileHandler    DBHandler
             |              |              |
             v              v              v
         Formatter      Formatter      Formatter
             |              |              |
             +--------------+--------------+
                            |
                            v
                       Log Storage
```

With supporting components:

```text
LoggerManager
    |
    +---- Logger Registry

FileHandler
    |
    +---- RotationPolicy

Logger
    |
    +---- Async Queue (optional)

LogRecord
    |
    +---- Metadata
    +---- Exception
    +---- RequestId
```

---

# 47. Recommended Project Structure

```text
src/
│
├── model/
│   └── LogRecord.java
│
├── logger/
│   ├── Logger.java
│   └── LoggerManager.java
│
├── handler/
│   ├── LogHandler.java
│   ├── ConsoleHandler.java
│   ├── FileHandler.java
│   └── DatabaseHandler.java
│
├── formatter/
│   ├── Formatter.java
│   ├── SimpleFormatter.java
│   └── JsonFormatter.java
│
├── strategy/
│   ├── RotationPolicy.java
│   ├── SizeBasedRotationPolicy.java
│   └── TimeBasedRotationPolicy.java
│
├── enums/
│   └── LogLevel.java
│
└── Main.java
```

---

# 48. Common Interview Follow-Ups

## Q1. How would you add a Kafka handler?

Implement:

```java
LogHandler
```

```text
LogHandler
    |
    +---- KafkaHandler
```

No changes required in `Logger`.

---

## Q2. How would you support JSON logging?

Implement:

```java
Formatter
```

```text
Formatter
    |
    +---- JsonFormatter
```

---

## Q3. How do you prevent DEBUG logs from being generated?

Check the enabled level before constructing expensive log messages.

Prefer:

```java
logger.debug(
    () -> expensiveMessage()
);
```

for expensive message construction.

---

## Q4. How do you handle high traffic?

Use asynchronous logging:

```text
Logger
  ↓
Bounded Queue
  ↓
Worker
  ↓
Handlers
```

---

## Q5. What if queue becomes full?

Define a policy:

```text
Block
Drop low-priority logs
Drop oldest
Fallback to synchronous logging
```

The correct choice depends on requirements.

---

## Q6. How do you rotate files?

Use:

```text
RotationPolicy
```

with implementations:

```text
SizeBased
TimeBased
```

---

## Q7. How do you make logging thread-safe?

Use:

```text
ConcurrentHashMap
BlockingQueue
Synchronization / single writer
Thread-safe handlers
```

depending on the component.

---

## Q8. What if logging itself fails?

Use fallback/retry policies and avoid allowing ordinary logging failures to crash the application.

---

## Q9. How do you trace one request across microservices?

Add:

```text
requestId / correlationId / traceId
```

to `LogRecord`.

---

## Q10. Why not make Logger a Singleton?

Because every class may need a logically different logger name:

```text
PaymentService
OrderService
UserService
```

Instead, use a shared registry:

```text
LoggerManager
    |
    +---- PaymentService Logger
    +---- OrderService Logger
    +---- UserService Logger
```

---

# 49. Common Mistakes

## Mistake 1 — God Logger

Don't do:

```java
class Logger {

    writeToConsole();
    writeToFile();
    writeToDatabase();
    formatJson();
    rotateFile();
    sendToKafka();
    ...
}
```

This violates SRP and becomes difficult to extend.

---

## Mistake 2 — Hardcode destinations

Avoid:

```java
if (level == ERROR) {
    writeToFile();
}
```

Instead use handlers.

---

## Mistake 3 — Mix formatting and output

Don't make:

```text
FileHandler
```

responsible for every formatting format.

Separate:

```text
Handler
+
Formatter
```

---

## Mistake 4 — Ignore concurrency

Logging is called from many threads.

Always mention thread safety.

---

## Mistake 5 — Ignore performance

Synchronous file I/O can become a bottleneck.

Mention:

```text
Async logging
+
Bounded queue
```

for high-throughput systems.

---

## Mistake 6 — Overuse Chain of Responsibility

A handler chain isn't automatically the best design for multiple outputs.

If one ERROR needs to go to:

```text
Console
+
File
+
Database
```

independent handlers are often cleaner.

---

# 50. Interview Opening

When asked:

> "Design a logging system."

Start with:

> "I'll assume the system supports multiple log levels such as DEBUG, INFO, WARN and ERROR, and multiple output destinations such as console, file and database. I'll model each log as a LogRecord, separate formatting from output using Formatter and Handler abstractions, and keep Logger responsible mainly for creating and dispatching records. Different handlers can have different minimum log levels. For extensibility I'll use interfaces for handlers and formatters. For high-throughput production scenarios, I'd add asynchronous logging with a bounded queue, and I'd also consider log rotation, request IDs, idempotent configuration and thread safety."

That's a strong LLD opening.

---

# 51. Final Mental Model

Remember Logging System as:

```text
             LOGGER
                |
                v
           LOG RECORD
                |
                v
             FILTER
                |
       +--------+--------+
       |        |        |
       v        v        v
    CONSOLE    FILE     DB
       |        |        |
       v        v        v
   FORMATTER FORMATTER FORMATTER
```

And remember the responsibilities:

```text
Logger
  ↓
Creates and dispatches logs

LogRecord
  ↓
Contains log information

Handler
  ↓
Decides where to write

Formatter
  ↓
Decides how to represent

RotationPolicy
  ↓
Decides when to rotate files

LoggerManager
  ↓
Manages/reuses logger instances
```

---

# 52. The 5 Things to Remember

### 1. Separate LogRecord from Logger

```text
Logger → behavior
LogRecord → data
```

### 2. Separate Handler from Formatter

```text
Handler → WHERE
Formatter → HOW
```

### 3. Use interfaces for extensibility

```text
LogHandler
Formatter
RotationPolicy
```

### 4. Think about concurrency

```text
Many threads
     ↓
Thread-safe logger
     ↓
Async queue
     ↓
Single/multiple writers
```

### 5. Think beyond the basic LLD

Production logging involves:

```text
Async logging
Log rotation
Structured logs
Correlation IDs
Backpressure
Failure handling
Sensitive-data masking
```

---

# 53. One-Line Interview Summary

> **"I would model logging around an immutable LogRecord, keep Logger responsible for log creation and dispatch, use pluggable Handler implementations for different destinations and Formatter strategies for different representations, and extend the design with asynchronous processing, bounded queues, log rotation, correlation IDs and thread-safe components for production scale."**