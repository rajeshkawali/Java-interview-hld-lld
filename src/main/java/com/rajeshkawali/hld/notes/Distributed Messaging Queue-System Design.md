# Distributed Messaging Queue — System Design
## Design a Messaging Queue like Kafka / RabbitMQ

---

# 1. What is a Messaging Queue?

A **Messaging Queue** is a system that allows one service to send messages to another service **asynchronously**.

Instead of:

```text
Producer → Consumer
```

we introduce a broker:

```text
Producer → Message Broker → Consumer
```

Example:

```text
Order Service
     |
     | OrderCreated
     v
Message Queue
     |
     v
Email Service
```

The Order Service does not need to wait for Email Service to finish.

---

# 2. Why Do We Need a Message Queue?

Without a queue:

```text
Order Service
     |
     v
Payment Service
     |
     v
Inventory Service
     |
     v
Email Service
```

If Email Service is slow, the entire request may become slow.

With a queue:

```text
                 +→ Payment Service
                 |
Order Service → Queue
                 |
                 +→ Email Service
```

The producer can continue after publishing the message.

---

# 3. Main Benefits

```text
+ Asynchronous communication
+ Decouples services
+ Handles traffic spikes
+ Buffer between producer and consumer
+ Retry failed messages
+ Enables event-driven architecture
+ Improves scalability
+ Provides fault tolerance
```

---

# 4. Kafka vs RabbitMQ — Basic Idea

Both are messaging systems, but their designs are different.

### Kafka

Kafka is primarily a **distributed event streaming/log platform**.

```text
Producer
   |
   v
Kafka Topic
   |
   +---- Consumer Group A
   |
   +---- Consumer Group B
```

Kafka stores messages in an ordered, append-only log.

### RabbitMQ

RabbitMQ is primarily a **message broker / queueing system**.

```text
Producer
   |
   v
Exchange
   |
   v
Queue
   |
   v
Consumer
```

RabbitMQ routes messages to queues using exchanges and routing rules.

---

# 5. High-Level Architecture

A distributed messaging system can contain:

```text
                         Producers
                       /     |      \
                      v      v       v
                  Producer Producer Producer
                       \      |      /
                        \     |     /
                         v    v    v
                    +-------------+
                    | Message     |
                    | Broker      |
                    +-------------+
                    /      |      \
                   v       v       v
               Broker1  Broker2  Broker3
                   |       |       |
                   +-------+-------+
                           |
                     Consumer Groups
                    /       |       \
                   v        v        v
              Consumer   Consumer  Consumer
```

---

# 6. Core Components

## 6.1 Producer

A **Producer** sends messages to the messaging system.

Example:

```text
Order Service
    |
    | OrderCreated
    v
Kafka
```

Producer responsibilities:

```text
+ Serialize message
+ Select topic/queue
+ Partition message if needed
+ Send message
+ Handle acknowledgement
+ Retry failures
```

---

# 7. Consumer

A **Consumer** reads messages.

Example:

```text
Kafka
  |
  v
Email Service
```

Consumer responsibilities:

```text
+ Read messages
+ Deserialize
+ Process message
+ Acknowledge / commit progress
+ Retry failures
```

---

# 8. Topic

A **Topic** is a logical category of messages.

Example:

```text
order-created
payment-completed
user-created
notification
```

Kafka heavily uses topics.

Example:

```text
Kafka

Topics:
 ├── orders
 ├── payments
 ├── users
 └── notifications
```

---

# 9. Queue

A queue stores messages waiting to be consumed.

Example:

```text
Producer
   |
   v
+-------------------------+
| M1 | M2 | M3 | M4 | M5 |
+-------------------------+
              |
              v
           Consumer
```

Usually the consumer processes messages from the queue.

---

# 10. Partition

Partitioning is one of the most important concepts for distributed messaging systems.

A topic can be divided into multiple partitions.

```text
Topic: orders

Partition 0:
M1 → M4 → M7 → M10

Partition 1:
M2 → M5 → M8 → M11

Partition 2:
M3 → M6 → M9 → M12
```

This allows multiple consumers to process messages in parallel.

---

# 11. Why Partition?

Suppose:

```text
1 consumer
= 1,000 messages/sec
```

But traffic is:

```text
10,000 messages/sec
```

We can create:

```text
10 partitions
10 consumers
```

Approximately:

```text
Consumer 1 → Partition 1
Consumer 2 → Partition 2
...
Consumer 10 → Partition 10
```

Now processing can happen in parallel.

---

# 12. Ordering

Ordering is an important interview topic.

Kafka guarantees ordering **within a partition**, not globally across all partitions.

Example:

```text
Partition 0

M1 → M2 → M3 → M4
```

The consumer sees:

```text
M1
M2
M3
M4
```

But:

```text
Partition 0: M1 M3
Partition 1: M2 M4
```

does not guarantee global ordering:

```text
M1 → M2 → M3 → M4
```

---

# 13. How to Maintain Ordering?

Suppose we have events for:

```text
userId = 101
```

Send all events for the same user to the same partition.

```text
partition = hash(userId) % numberOfPartitions
```

Example:

```text
User 101
   |
   v
Hash
   |
   v
Partition 3
```

Therefore:

```text
User 101 events
→ Partition 3
→ ordered
```

---

# 14. Consumer Group

A **Consumer Group** allows multiple consumers to process partitions in parallel.

Example:

```text
Topic
 ├── P0
 ├── P1
 ├── P2
 └── P3

Consumer Group A

 C1 → P0
 C2 → P1
 C3 → P2
 C4 → P3
```

Each partition is assigned to one consumer within the same consumer group.

---

# 15. Multiple Consumer Groups

Different applications can consume the same topic independently.

```text
                 Kafka Topic
                     |
          +----------+----------+
          |                     |
          v                     v
     Consumer Group A      Consumer Group B
          |                     |
     Email Service         Analytics Service
```

Both groups can receive the same events.

Example:

```text
OrderCreated
    |
    +---- Email Service
    |
    +---- Analytics
    |
    +---- Recommendation Service
```

---

# 16. Kafka Offset

Kafka tracks the position of a consumer using an **offset**.

Example:

```text
Partition 0:

Offset:
  0   1   2   3   4   5
  M1  M2  M3  M4  M5  M6
              ^
           Consumer
```

If consumer has processed M3:

```text
Current offset = 3
```

The consumer can continue from the next position.

---

# 17. Why Offset Is Important?

If a consumer crashes:

```text
Consumer
   |
   X
Crash
```

After restart:

```text
Read committed offset
       |
       v
Continue processing
```

This provides fault tolerance.

---

# 18. Message Acknowledgement

A consumer may acknowledge that a message has been processed.

```text
Broker
  |
  v
Consumer
  |
  | process
  v
Success
  |
  | ACK
  v
Broker
```

If processing fails:

```text
Broker
  |
  v
Consumer
  |
  X
Failure
```

The message can be retried depending on the system/configuration.

---

# 19. Delivery Semantics

Very common interview question.

There are three major delivery semantics.

---

## 19.1 At-Most-Once

Message is processed:

```text
0 or 1 time
```

Example:

```text
Read message
   |
   v
Commit offset
   |
   v
Process
```

If processing fails after committing:

```text
Message may be lost
```

### Advantage

```text
+ No duplicate processing
+ Lower overhead
```

### Disadvantage

```text
- Possible message loss
```

---

# 20. At-Least-Once

Message is processed:

```text
1 or more times
```

Example:

```text
Process message
      |
      v
Commit offset
```

If consumer crashes before committing:

```text
Message processed
       |
       X
Crash before ACK
       |
       v
Message processed again
```

Therefore duplicates can occur.

### Advantage

```text
+ Less chance of message loss
```

### Disadvantage

```text
- Duplicate processing possible
```

Therefore consumers should be **idempotent**.

---

# 21. Exactly-Once

The goal is:

```text
Message effect happens exactly once
```

This is much harder in distributed systems.

It generally requires coordination between message processing and the resulting side effects.

Example problem:

```text
Kafka
  |
  v
Payment Consumer
  |
  v
Database
```

The consumer updates DB but crashes before recording its progress.

The message may be processed again.

Therefore "exactly once" must be carefully defined; broker-level guarantees alone do not automatically make arbitrary external side effects exactly-once.

---

# 22. Quick Comparison

| Delivery | Message Loss | Duplicate | Complexity |
|---|---|---|---|
| At-most-once | Possible | No | Low |
| At-least-once | Low/controlled | Possible | Medium |
| Exactly-once | Minimized by coordinated design | Minimized | High |

### Interview Recommendation

For many business systems:

```text
At-Least-Once
+
Idempotent Consumer
```

is a practical design.

---

# 23. Message Persistence

Messages should not necessarily live only in memory.

```text
Producer
   |
   v
Broker
   |
   v
Disk
```

Persistence protects messages if a broker crashes.

Kafka is especially designed around durable append-only logs.

---

# 24. Replication

For high availability, replicate partitions/messages across brokers.

Example:

```text
Partition 0

Broker 1 → Leader
Broker 2 → Replica
Broker 3 → Replica
```

If Broker 1 fails:

```text
Broker 1
   X
   |
   v
Broker 2
   |
   v
New Leader
```

---

# 25. Leader and Replica

Example:

```text
Partition 0

Broker 1
  Leader

Broker 2
  Replica

Broker 3
  Replica
```

Producer typically writes to the leader.

Replicas copy the data.

```text
Producer
   |
   v
Leader
 /   \
v     v
R1    R2
```

---

# 26. What Happens if a Broker Fails?

```text
Before:

P0 Leader → Broker1
P0 Replica → Broker2
P0 Replica → Broker3
```

Broker1 fails:

```text
Broker1 → DOWN

Broker2 → promoted to Leader
```

Consumers/producers reconnect to the new leader.

This provides fault tolerance.

---

# 27. Replication Factor

Example:

```text
Replication Factor = 3
```

Means each partition has three copies.

```text
P0
├── Broker1
├── Broker2
└── Broker3
```

Higher replication:

```text
+ Better fault tolerance
- More storage
- More network traffic
```

---

# 28. Backpressure

Suppose:

```text
Producer = 100,000 msg/sec
Consumer = 20,000 msg/sec
```

Messages accumulate.

```text
Producer
   |
   v
Queue
 ↑ ↑ ↑
messages accumulating
   |
   v
Consumer
```

This is where the queue acts as a **buffer**.

Solutions:

```text
+ Increase consumers
+ Increase partitions
+ Batch processing
+ Rate limit producers
+ Apply backpressure
+ Scale consumers
```

---

# 29. Retry Mechanism

If processing fails:

```text
Message
   |
   v
Consumer
   |
   X
Failure
   |
   v
Retry
```

Avoid immediate infinite retries.

Use:

```text
Exponential Backoff
+
Maximum Retry Count
```

Example:

```text
Retry 1 → 1 sec
Retry 2 → 2 sec
Retry 3 → 4 sec
Retry 4 → 8 sec
```

---

# 30. Dead Letter Queue (DLQ)

If a message repeatedly fails:

```text
Main Queue
    |
    v
Consumer
    |
    X
Failure
    |
 Retry
    |
 Retry
    |
 Retry
    |
    v
DLQ
```

The DLQ allows engineers to inspect and fix problematic messages.

Example:

```text
OrderProcessingFailed
```

could be moved to:

```text
order-dlq
```

---

# 31. Poison Message

A **poison message** is a message that repeatedly causes consumer failure.

Example:

```text
Invalid JSON
Invalid data
Unsupported schema
Corrupted payload
```

Without DLQ:

```text
Message
  ↓
Fail
  ↓
Retry
  ↓
Fail
  ↓
Retry
  ↓
Infinite loop
```

Solution:

```text
Retry limit
+
DLQ
```

---

# 32. Schema Evolution

Messages may change over time.

Version 1:

```json
{
  "userId": 101,
  "name": "John"
}
```

Version 2:

```json
{
  "userId": 101,
  "name": "John",
  "email": "john@example.com"
}
```

Consumers should handle schema evolution safely.

Common approaches:

```text
Backward compatibility
Forward compatibility
Schema Registry
Versioned events
```

---

# 33. Serialization

Messages must be converted into bytes.

Common formats:

```text
JSON
Avro
Protobuf
MessagePack
```

### JSON

```text
+ Easy to understand
+ Easy debugging
- Larger messages
- Slower serialization
```

### Protobuf / Avro

```text
+ Compact
+ Fast
+ Strong schema
- More complexity
```

---

# 34. Kafka Architecture

Simplified Kafka architecture:

```text
                  Producers
               /      |      \
              v       v       v

        +---------------------------+
        |           Kafka            |
        |                           |
        | Topic: orders             |
        |                           |
        | P0 | P1 | P2 | P3         |
        +---------------------------+
          |    |    |    |
          v    v    v    v
        Consumer Group
          C1   C2   C3   C4
```

Kafka cluster:

```text
Broker 1
Broker 2
Broker 3
Broker 4
```

Partitions are distributed across brokers.

---

# 35. RabbitMQ Architecture

Simplified RabbitMQ:

```text
Producer
   |
   v
Exchange
   |
   +--------+
   |        |
   v        v
Queue A   Queue B
   |        |
   v        v
Consumer  Consumer
```

Exchange types include:

```text
Direct
Topic
Fanout
Headers
```

---

# 36. Kafka vs RabbitMQ

| Feature | Kafka | RabbitMQ |
|---|---|---|
| Primary model | Event streaming/log | Message broker/queue |
| Storage | Durable log | Queue-based |
| Ordering | Per partition | Queue ordering with caveats |
| Replay | Strong support | More limited/different model |
| Consumer model | Consumer groups | Consumers/queues |
| High throughput | Excellent | Excellent, but different strengths |
| Routing | Topic/partition model | Powerful exchanges/routing |
| Typical use | Event streaming, analytics | Task queues, routing, messaging |
| Message retention | Configurable retention | Typically removed/acknowledged |
| Replay old events | Natural | Not the primary model |

### Simple Memory

```text
Kafka
→ Distributed Event Log
→ High throughput
→ Replay
→ Streaming

RabbitMQ
→ Message Broker
→ Queues
→ Routing
→ Task processing
```

---

# 37. Example — E-commerce System

Suppose a customer places an order.

```text
Client
  |
  v
Order Service
  |
  | OrderCreated
  v
Kafka
  |
  +--------→ Payment Service
  |
  +--------→ Inventory Service
  |
  +--------→ Notification Service
  |
  +--------→ Analytics Service
```

Benefits:

```text
Order Service does not need to synchronously call
every downstream service.
```

---

# 38. Detailed Order Flow

### Step 1

Customer creates order.

```text
POST /orders
```

### Step 2

Order Service stores:

```text
Order ID
Customer ID
Items
Status = CREATED
```

### Step 3

Publish:

```text
OrderCreated
```

### Step 4

Consumers process independently:

```text
Payment Service
Inventory Service
Notification Service
Analytics Service
```

---

# 39. Failure Scenario — Consumer Crashes

```text
Kafka
  |
  v
Consumer
  |
  X
Crash
```

If offset was not committed:

```text
Consumer restarts
      |
      v
Reads message again
```

This can create duplicate processing.

Solution:

```text
Idempotent Consumer
+
Unique Event ID
+
Deduplication
```

---

# 40. Failure Scenario — Broker Crashes

Suppose:

```text
Broker1 → Leader
Broker2 → Replica
Broker3 → Replica
```

Broker1 crashes:

```text
Broker1 → DOWN

Broker2 → New Leader
```

Clients reconnect to the new leader.

---

# 41. Failure Scenario — Consumer Is Too Slow

Suppose:

```text
Producer = 50,000 msg/sec
Consumer = 10,000 msg/sec
```

Backlog grows.

```text
Queue:
M1 M2 M3 M4 M5 M6 M7 M8 ...
```

Solution:

```text
Increase consumer instances
+
Increase partitions
+
Optimize consumer
+
Batch processing
+
Autoscaling
```

---

# 42. Failure Scenario — Consumer Processing Fails

```text
Message
   |
   v
Consumer
   |
   X
Failure
```

Flow:

```text
Retry
  ↓
Retry
  ↓
Retry
  ↓
DLQ
```

Use exponential backoff.

---

# 43. Failure Scenario — Duplicate Message

Example:

```text
Message ID = 123
```

Consumer processes:

```text
Order #123
```

Consumer crashes before committing offset.

Message is delivered again.

Solution:

```text
Message ID
+
Idempotency
+
Database Unique Constraint
```

Example:

```text
processed_events
----------------
event_id = 123
```

Before processing:

```text
if event_id already exists:
    ignore
else:
    process
    save event_id
```

---

# 44. Failure Scenario — Producer Crashes

Suppose producer sends a message but does not receive acknowledgement.

```text
Producer
   |
   v
Broker
   |
   v
Message stored
   |
   X
ACK lost
```

Producer may retry.

Now duplicate messages may occur.

Solution:

```text
Producer ID
+
Message ID
+
Idempotent Producer
```

---

# 45. Exactly-Once Problem

Important interview scenario:

```text
Kafka
  |
  v
Consumer
  |
  v
Database
```

Consumer does:

```text
1. Update DB
2. Commit Kafka offset
```

If failure occurs between these operations:

```text
Update DB
   |
   X
Crash
   |
Kafka offset not committed
```

Message is processed again.

Therefore distributed systems require careful coordination.

Common solutions:

```text
Idempotent writes
Transactional processing
Outbox/Inbox patterns
Kafka transactions where applicable
Unique constraints
```

---

# 46. Transactional Outbox Pattern

Useful when an application needs to update DB and publish an event reliably.

### Problem

```text
DB Update
   |
   v
Success

Publish Message
   |
   X
Failure
```

Database changed but event was not published.

### Solution

```text
Application
   |
   v
Database Transaction
   |
   +---- Business Data
   |
   +---- Outbox Event
              |
              v
        Outbox Publisher
              |
              v
         Message Broker
```

Both DB changes happen in one local transaction.

---

# 47. Message Ordering vs Scalability

Important trade-off.

Suppose:

```text
One partition
```

Ordering is easy:

```text
M1 → M2 → M3 → M4
```

But parallelism is limited.

If we use:

```text
100 partitions
```

we get high parallelism but global ordering becomes difficult.

Therefore:

```text
More partitions
→ More scalability
→ Harder global ordering
```

---

# 48. Queue Size / Lag

Monitor consumer lag.

Example:

```text
Latest message offset = 10,000
Consumer offset = 9,000

Lag = 1,000
```

Increasing lag means consumers are falling behind.

Important metrics:

```text
Consumer Lag
Throughput
Processing Latency
Publish Rate
Consume Rate
Error Rate
Retry Count
DLQ Size
Broker CPU
Broker Disk
Network
```

---

# 49. Retention

Kafka can retain messages for a configured period.

Example:

```text
Retention = 7 days
```

Messages can remain available for replay.

```text
Day 1 → Message
Day 2 → Message
...
Day 7 → Message
Day 8 → Removed
```

This is different from a traditional queue where a successfully acknowledged message is typically removed from the queue.

---

# 50. Replay

One major Kafka advantage is replay.

Example:

```text
Analytics Service
```

has a bug.

We can reset the consumer position and replay historical events.

```text
Kafka
 |
 +-- M1
 +-- M2
 +-- M3
 +-- M4
      ^
      |
   Replay
```

Useful for:

```text
Analytics
Data recovery
Bug fixes
New consumers
Rebuilding projections
```

---

# 51. Scaling the Messaging System

## Producer Scaling

```text
Producer 1
Producer 2
Producer 3
      |
      v
Kafka Cluster
```

Producers are usually stateless and can scale horizontally.

---

## Broker Scaling

Add more brokers:

```text
Broker 1
Broker 2
Broker 3
Broker 4
Broker 5
```

Redistribute partitions.

---

## Consumer Scaling

```text
Partition 0 → Consumer 1
Partition 1 → Consumer 2
Partition 2 → Consumer 3
Partition 3 → Consumer 4
```

But:

> Number of active consumers in a consumer group cannot exceed the number of partitions if each consumer needs its own partition assignment.

---

# 52. Autoscaling Consumers

Monitor:

```text
Consumer Lag
```

Example:

```text
Lag < 1,000
→ 5 consumers

Lag > 100,000
→ 10 consumers
```

However, adding consumers only helps if there are enough partitions and the downstream systems can handle the increased load.

---

# 53. Security

A production messaging system should provide:

```text
Authentication
Authorization
TLS
Encryption
Access Control
Audit Logs
Network Isolation
```

Example:

```text
Order Service
    |
    | only WRITE
    v
orders-topic

Analytics Service
    |
    | only READ
    v
orders-topic
```

Use least-privilege permissions.

---

# 54. High Availability

Messaging brokers should not have a single point of failure.

```text
Broker 1
Broker 2
Broker 3
```

Use:

```text
Replication
+
Automatic leader election/failover
+
Health checks
+
Multiple AZs
```

---

# 55. Multi-AZ Messaging

```text
                 Region
              /    |    \
             v     v     v
            AZ1   AZ2   AZ3

           Broker1
           Broker2
           Broker3
```

Replicas should be distributed across AZs where possible.

If AZ1 fails:

```text
AZ1 → DOWN

AZ2 + AZ3 → Continue
```

---

# 56. Capacity Planning

Before designing, estimate:

```text
Messages/sec
Average message size
Peak traffic
Retention period
Number of consumers
Replication factor
```

Example:

```text
Messages = 100,000/sec
Message size = 1 KB
```

Raw ingress:

```text
100,000 × 1 KB
= 100 MB/sec
```

With replication factor 3:

```text
100 MB/sec × 3
= ~300 MB/sec
```

Then account for protocol overhead, indexes/metadata, compression, replication behavior, and operational headroom.

---

# 57. Storage Estimation

Suppose:

```text
100,000 messages/sec
1 KB/message
Retention = 7 days
```

Messages per day:

```text
100,000 × 60 × 60 × 24
= 8.64 billion messages/day
```

Storage/day:

```text
8.64 billion × 1 KB
≈ 8.64 TB/day
```

For 7 days:

```text
≈ 60.48 TB
```

With replication factor 3:

```text
≈ 181.44 TB
```

This is a rough estimate before compression and system overhead.

---

# 58. API Design

A simple messaging system could expose:

### Publish

```text
POST /topics/{topic}/messages
```

### Consume

```text
GET /topics/{topic}/messages
```

### Acknowledge

```text
POST /messages/{messageId}/ack
```

### Create Topic

```text
POST /topics
```

### Consumer Group

```text
POST /consumer-groups
```

In a real Kafka/RabbitMQ-like system, clients typically communicate through the broker's native protocol rather than a simple REST interface.

---

# 59. Message Structure

Example:

```json
{
  "messageId": "abc-123",
  "topic": "order-created",
  "key": "order-1001",
  "timestamp": "2026-09-01T10:00:00Z",
  "schemaVersion": 1,
  "payload": {
    "orderId": "1001",
    "userId": "500",
    "amount": 2500
  }
}
```

Important fields:

```text
messageId
topic
key
timestamp
schemaVersion
payload
```

---

# 60. Key Design Decisions

During an interview, discuss:

```text
1. Ordering
2. Delivery semantics
3. Durability
4. Replication
5. Partitioning
6. Consumer groups
7. Retry
8. DLQ
9. Backpressure
10. Replay
11. Schema evolution
12. Scaling
13. HA
14. Security
15. Monitoring
```

---

# 61. Kafka-like System — Simplified HLD

```text
                         PRODUCERS
                    /       |       \
                   v        v        v
                Producer Producer Producer
                    \       |       /
                     \      |      /
                      v     v     v
                +--------------------+
                |   Kafka Cluster    |
                |                    |
                | Broker 1           |
                | Broker 2           |
                | Broker 3           |
                +--------------------+
                    |    |    |
                    v    v    v
                 Topics / Partitions
                    |    |    |
                    v    v    v
               Consumer Groups
                 /      |      \
                v       v       v
             Service A Service B Service C

       +----------------------------------+
       | Monitoring / Metrics / Alerting  |
       +----------------------------------+
```

---

# 62. RabbitMQ-like HLD

```text
                 Producer
                    |
                    v
                Exchange
              /    |     \
             v     v      v
          Queue A Queue B Queue C
             |      |       |
             v      v       v
         Consumer Consumer Consumer
```

Exchange determines where messages should go.

---

# 63. Kafka vs RabbitMQ — Interview Answer

### Question:

> "When would you choose Kafka vs RabbitMQ?"

### Answer:

> "I would choose Kafka when I need high-throughput event streaming, durable event retention, partition-based parallel processing, and the ability to replay events. I would choose RabbitMQ when I need traditional message queues, flexible routing through exchanges, task distribution, and request/work dispatch patterns. The final choice depends on throughput, ordering, retention, replay, routing, and operational requirements."

---

# 64. Common Interview Questions

## Q1. Why use a message queue?

**Answer:**

```text
Decoupling
+
Asynchronous processing
+
Traffic buffering
+
Scalability
+
Fault tolerance
```

---

## Q2. Kafka vs RabbitMQ?

**Answer:**

```text
Kafka
→ Event streaming
→ Partitions
→ Durable log
→ Replay

RabbitMQ
→ Message broker
→ Queues
→ Exchanges
→ Routing
```

---

## Q3. How does Kafka scale?

**Answer:**

```text
Topics
→ Partitions
→ Distributed across brokers
→ Consumer groups
→ Parallel consumers
```

---

## Q4. How do you maintain ordering?

**Answer:**

> Put related messages, such as all events for the same `orderId`, into the same partition. Kafka guarantees ordering within that partition.

---

## Q5. What happens when a consumer crashes?

**Answer:**

> The consumer restarts and resumes from its committed position. Depending on when the offset was committed, the message may be processed again, so consumers should generally be idempotent.

---

## Q6. What happens when a broker crashes?

**Answer:**

> Replicated partition data allows another broker to become leader, and producers/consumers reconnect to the new leader.

---

## Q7. How do you handle failed messages?

```text
Retry
→ Exponential Backoff
→ Maximum Retry Count
→ DLQ
```

---

## Q8. How do you handle duplicate messages?

```text
Unique Message ID
+
Idempotent Consumer
+
Deduplication
+
Database Unique Constraint
```

---

## Q9. How do you handle traffic spikes?

```text
Queue acts as buffer
+
Scale consumers
+
Partitioning
+
Backpressure
+
Rate limiting
```

---

## Q10. What metric tells you consumers are falling behind?

**Consumer Lag.**

```text
Latest Offset - Consumer Offset
```

---

# 65. Advanced Interview Scenarios

### Scenario 1 — Producer is 10x faster than Consumer

Answer:

```text
Queue buffers traffic
→ Monitor lag
→ Scale consumers
→ Increase partitions if required
→ Optimize processing
→ Apply backpressure
```

---

### Scenario 2 — Consumer processes the same message twice

Answer:

```text
Likely at-least-once behavior.

Use:
Message ID
+
Idempotent processing
+
Deduplication
```

---

### Scenario 3 — Need strict order for each customer

Answer:

```text
Partition by customerId
```

All events for one customer go to the same partition.

---

### Scenario 4 — Need to replay events from yesterday

Answer:

```text
Kafka-style durable retention
+
Reset consumer offset
+
Replay events
```

---

### Scenario 5 — One message always fails

Answer:

```text
Retry with limit
→ DLQ
→ Alert
→ Investigate
```

---

### Scenario 6 — Entire broker/AZ fails

Answer:

```text
Replication
+
Multiple brokers
+
Multi-AZ deployment
+
Leader failover
```

---

### Scenario 7 — Need to send one event to 5 different services

Use:

```text
Topic
+
Multiple Consumer Groups
```

Example:

```text
OrderCreated
      |
      v
 orders-topic
      |
      +---- Payment Group
      |
      +---- Email Group
      |
      +---- Analytics Group
      |
      +---- Inventory Group
```

---

# 66. Important Trade-offs

## More Partitions

```text
+ More parallelism
+ More throughput
- More management
- Ordering becomes harder
```

## More Replicas

```text
+ Better fault tolerance
+ Better durability
- More storage
- More network traffic
```

## Longer Retention

```text
+ Better replay
+ Better recovery
- More storage
```

## At-Least-Once

```text
+ Better durability
- Duplicates possible
```

## Exactly-Once

```text
+ Stronger processing guarantees
- More complexity
- Higher coordination cost
```

---

# 67. Recommended Design for a Large Distributed Messaging System

For a Kafka-like system:

```text
                Producers
                    |
                    v
              Load / Routing
                    |
                    v
             Kafka Cluster
          /       |       \
       Broker1  Broker2  Broker3
          |       |       |
          +--- Replication ---+
                    |
                 Topics
                    |
                Partitions
                    |
             Consumer Groups
              /     |      \
             v      v       v
          Service Service Service
```

Add:

```text
Replication
Multi-AZ
Durable Storage
Consumer Groups
Retries
DLQ
Monitoring
Authentication
Authorization
TLS
Schema Management
Autoscaling
```

---

# 68. ⭐ Interview Design Flow

When asked:

> **"Design Kafka/RabbitMQ."**

Follow this order:

```text
1. Requirements
      ↓
2. Estimate traffic
      ↓
3. Producer
      ↓
4. Broker
      ↓
5. Topic / Queue
      ↓
6. Partitioning
      ↓
7. Consumer
      ↓
8. Consumer Groups
      ↓
9. Ordering
      ↓
10. Delivery Semantics
      ↓
11. Persistence
      ↓
12. Replication
      ↓
13. Retry + DLQ
      ↓
14. Backpressure
      ↓
15. Scaling
      ↓
16. Failure Handling
      ↓
17. Monitoring
      ↓
18. Security
      ↓
19. Trade-offs
```

---

# 69. ⭐ Short Recall Notes

```text
DISTRIBUTED MESSAGE QUEUE
=========================

Purpose
→ Async communication
→ Decouple services
→ Buffer traffic
→ Retry failures
→ Scale consumers

PRODUCER
→ Sends messages

BROKER
→ Stores/routes messages

TOPIC
→ Logical category of events

QUEUE
→ Messages waiting for consumers

PARTITION
→ Parallelism + scalability
→ Ordering within partition

CONSUMER
→ Processes messages

CONSUMER GROUP
→ Multiple consumers process partitions in parallel

OFFSET
→ Consumer's position

REPLICATION
→ Copies data across brokers

LEADER
→ Handles partition operations

FAILOVER
→ Replica becomes leader

DELIVERY
→ At-most-once
→ At-least-once
→ Exactly-once

PRACTICAL CHOICE
→ At-least-once + idempotent consumer

RETRY
→ Exponential backoff + jitter

DLQ
→ Stores repeatedly failed messages

BACKPRESSURE
→ Producer faster than consumer
→ Queue buffers traffic

ORDERING
→ Same key → same partition

KAFKA
→ Distributed event log
→ High throughput
→ Replay
→ Streaming
→ Partitions

RABBITMQ
→ Message broker
→ Queues
→ Exchanges
→ Routing
→ Task processing

HA
→ Replication
→ Multiple brokers
→ Multi-AZ
→ Automatic failover

MONITOR
→ Consumer lag
→ Throughput
→ Latency
→ Error rate
→ DLQ size
→ Disk
→ CPU
→ Network

KEY TRADE-OFFS
→ Partitions vs ordering
→ Replication vs cost
→ Retention vs storage
→ At-least-once vs duplicates
→ Exactly-once vs complexity
```

# One-Line Interview Memory

> **Kafka = distributed durable event log with partitions, consumer groups, replication and replay; RabbitMQ = message broker built around exchanges, queues and routing.**

> **For a scalable messaging system: Partition + Replicate + Persist + Retry + Idempotency + Monitor.**