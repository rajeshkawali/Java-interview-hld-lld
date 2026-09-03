# Kafka vs RabbitMQ — Detailed Notes for System Design Interviews

---

# 1. What is Kafka?

**Apache Kafka** is a distributed event-streaming platform designed to handle **high-throughput, durable, scalable, and replayable streams of events**.

Think of Kafka as:

> **"A distributed commit log / event streaming system."**

### Simple Example

An e-commerce application creates an order:

```text
Order Service
     |
     | OrderCreated
     v
   Kafka
     |
     +--------> Payment Service
     |
     +--------> Inventory Service
     |
     +--------> Email Service
     |
     +--------> Analytics Service
```

One event can be consumed independently by multiple consumer groups.

---

# 2. Why Do We Need Kafka?

Suppose we have:

```text
Order Service
     |
     +----> Payment
     +----> Inventory
     +----> Email
     +----> Analytics
```

If Order Service directly calls every service:

```text
Order → Payment
Order → Inventory
Order → Email
Order → Analytics
```

Problems:

- Tight coupling
- More network calls
- One service failure can affect the order flow
- Difficult to scale independently
- High latency
- Difficult to replay events

With Kafka:

```text
Order Service
      |
      v
    Kafka
   / | | \
  /  | |  \
Payment Inventory Email Analytics
```

The Order Service only needs to publish an event.

---

# 3. Kafka Core Architecture

```text
                    Kafka Cluster

              +---------------------+
              |      Topic: orders  |
              +---------------------+
                |        |        |
                v        v        v
             P0        P1        P2
             |          |         |
             v          v         v
          Broker 1   Broker 2   Broker 3
```

Important Kafka concepts:

```text
Producer
Topic
Partition
Broker
Consumer
Consumer Group
Offset
Replication
Leader
Follower/Replica
Retention
```

---

# 4. Kafka Producer

A **Producer** publishes records/events to Kafka.

Example:

```text
Order Service
      |
      | OrderCreated
      v
orders topic
```

Example event:

```json
{
  "eventId": "evt-123",
  "orderId": "ORD-1001",
  "userId": "USER-10",
  "amount": 500
}
```

The producer can specify a **key**.

Example:

```text
key = orderId
```

Kafka can use the key to determine the partition.

---

# 5. Kafka Topic

A **Topic** is a logical category for events.

Examples:

```text
orders
payments
notifications
user-events
inventory-events
```

Example:

```text
orders topic

OrderCreated
OrderPaid
OrderCancelled
OrderShipped
```

A topic is divided into partitions.

---

# 6. Kafka Partition

A partition is an ordered append-only log.

Example:

```text
orders topic

Partition 0:
M1 → M4 → M7 → M10

Partition 1:
M2 → M5 → M8 → M11

Partition 2:
M3 → M6 → M9 → M12
```

Partitions provide:

- Horizontal scalability
- Parallel processing
- Ordering within a partition

### Important Interview Point

Kafka guarantees ordering **within a partition**, not globally across all partitions.

---

# 7. Kafka Message Key

Suppose we need all events for the same order to be processed in order.

Use:

```text
key = orderId
```

Example:

```text
Order 1001
   |
   +→ OrderCreated
   +→ OrderPaid
   +→ OrderShipped
```

If they are routed to the same partition:

```text
Partition 2:

OrderCreated
OrderPaid
OrderShipped
```

The ordering is preserved.

### Interview Answer

> "If ordering is required for an entity, I would use the entity ID such as orderId or userId as the Kafka message key so related events are routed to the same partition."

---

# 8. Kafka Consumer

A consumer reads messages from Kafka.

```text
Kafka
  |
  v
Consumer
  |
  v
Process event
```

Example:

```text
orders topic
      |
      v
Payment Service
      |
      v
Process payment
```

---

# 9. Kafka Consumer Group

A consumer group allows multiple consumers to share the work.

Example:

```text
Topic: orders

P0    P1    P2    P3
|     |     |     |
v     v     v     v
C1    C2    C3    C4
```

Each partition is assigned to one consumer in the group at a time.

### Why?

Parallel processing.

Suppose:

```text
1 consumer = 10K msg/sec
```

With 5 consumers/partitions, we can potentially process much more traffic.

The actual throughput depends on processing cost, partition count, broker capacity, and downstream systems.

---

# 10. Multiple Consumer Groups

This is one of Kafka's most important concepts.

```text
                    orders topic
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
     Payment Group   Email Group   Analytics Group
```

Every consumer group can independently consume the same events.

Example:

```text
OrderCreated
    |
    +----> Payment Service
    |
    +----> Email Service
    |
    +----> Analytics Service
```

This is excellent for event-driven architecture.

---

# 11. Kafka Offset

Each message in a partition has an offset.

```text
Partition 0

Offset:
0     1     2     3     4
M1    M2    M3    M4    M5
```

Consumer progress might be:

```text
Processed until offset 3
```

If the consumer crashes, it can resume from its committed position.

---

# 12. Kafka Retention

Kafka normally stores messages for a configured retention period or until configured storage limits are reached.

Example:

```text
Retention = 7 days
```

Messages can remain available for replay during that period.

This is different from the idea of a traditional queue where a successfully acknowledged message is normally removed from the queue.

---

# 13. Kafka Replay

Suppose Analytics Service has a bug.

Normally:

```text
Kafka
  ↓
Analytics
```

After fixing the bug, Analytics can process historical events again by reading from an earlier offset.

```text
Kafka
 |
 | old events
 v
Replay
 |
 v
Analytics
```

This is a major Kafka advantage.

---

# 14. Kafka Replication

Kafka replicates partitions across brokers.

Example:

```text
Partition 0

Broker 1 → Leader
Broker 2 → Replica
Broker 3 → Replica
```

If Broker 1 fails:

```text
Broker 1 → DOWN

Broker 2 → New Leader
```

Replication provides fault tolerance and durability.

---

# 15. Kafka Consumer Lag

Consumer lag represents how far behind a consumer group is from the latest available records.

Conceptually:

```text
Lag = Latest Position - Consumer Position
```

Example:

```text
Latest = 100,000
Consumer = 95,000

Lag = 5,000
```

High lag means the consumer is not keeping up.

Possible solutions:

```text
Scale consumers
Increase partitions if needed
Optimize processing
Batch processing
Reduce downstream latency
Apply backpressure
```

---

# 16. Kafka Delivery Semantics

## At-Most-Once

Message may be processed:

```text
0 or 1 time
```

Possible message loss.

---

## At-Least-Once

Message is processed:

```text
1 or more times
```

Duplicates are possible.

This is a very common practical model.

Therefore:

```text
At-least-once
+
Idempotent consumer
```

is important.

---

## Exactly-Once

Kafka supports mechanisms for exactly-once processing within certain Kafka workflows, but exactly-once business effects across arbitrary external systems are still difficult.

Example:

```text
Kafka
  |
  v
Payment Service
  |
  v
External Payment Provider
```

Kafka transactions alone do not magically make the external payment operation exactly once.

### Interview Answer

> "I would not casually claim exactly-once across the entire distributed system. For external side effects, I would use idempotency and transactional patterns where appropriate."

---

# 17. Kafka Advantages

### 1. Very High Throughput

Kafka is designed for large-scale event streaming.

### 2. Horizontal Scalability

Add:

```text
Brokers
Partitions
Consumers
```

to scale different parts of the system.

### 3. Message Replay

Historical events can be consumed again.

### 4. Durable Storage

Messages can be persisted and replicated.

### 5. Loose Coupling

Producers do not need to know every consumer.

### 6. Multiple Consumers

Many independent consumer groups can consume the same events.

### 7. Event Streaming

Excellent for:

```text
Analytics
Event-driven architecture
Data pipelines
CDC
Logs
Real-time processing
```

---

# 18. Kafka Disadvantages

### 1. Operational Complexity

Kafka clusters require proper management and monitoring.

### 2. Ordering Is Limited

Global ordering across many partitions is not available as a normal scalable pattern.

### 3. Consumer Management

Developers need to understand:

```text
Offsets
Partitions
Consumer Groups
Rebalancing
Lag
```

### 4. Not Always Ideal for Simple Task Queues

If the requirement is simply:

```text
Send task → Worker processes task → ACK
```

RabbitMQ may be simpler.

### 5. Partition Planning

Too few partitions can limit parallelism.

Too many partitions can increase operational overhead.

---

# 19. What is RabbitMQ?

**RabbitMQ** is a message broker commonly used for **asynchronous messaging, task queues, routing, and work distribution**.

Think of RabbitMQ as:

> **"A flexible message-routing and queueing system."**

Simple architecture:

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

---

# 20. RabbitMQ Core Components

Important concepts:

```text
Producer
Exchange
Queue
Binding
Routing Key
Consumer
ACK
Dead Letter Exchange / Queue
```

---

# 21. RabbitMQ Producer

Producer sends a message to an exchange.

```text
Producer
   |
   v
Exchange
```

Example:

```text
Order Service
    |
    v
order.exchange
```

Unlike the simplified Kafka mental model, RabbitMQ typically routes messages through exchanges to queues.

---

# 22. RabbitMQ Exchange

Exchange decides where messages should go.

```text
Producer
   |
   v
Exchange
 / | \
v  v  v
Q1 Q2 Q3
```

Common exchange types:

```text
Direct
Topic
Fanout
Headers
```

---

# 23. Direct Exchange

Routes based on an exact routing key.

Example:

```text
routingKey = payment
```

Then:

```text
payment → Payment Queue
```

Example:

```text
Producer
   |
   v
Exchange
   |
   | payment
   v
Payment Queue
```

---

# 24. Topic Exchange

Supports pattern-based routing.

Example:

```text
order.created
order.cancelled
payment.created
payment.failed
```

Binding:

```text
order.*
```

could receive matching order events.

Useful for flexible routing.

---

# 25. Fanout Exchange

Broadcasts messages to bound queues.

```text
             +→ Queue 1 → Email
             |
Producer → Exchange → Queue 2 → Analytics
             |
             +→ Queue 3 → Audit
```

Useful when multiple independent consumers need their own queues.

---

# 26. RabbitMQ Queue

A queue stores messages waiting for consumers.

```text
Queue

M1
M2
M3
M4
```

Workers consume messages from the queue.

Example:

```text
Image Queue
     |
     +→ Worker 1
     +→ Worker 2
     +→ Worker 3
```

This is excellent for work distribution.

---

# 27. RabbitMQ ACK

A consumer acknowledges successful processing.

```text
RabbitMQ
   |
   v
Consumer
   |
   v
Process
   |
   v
Success
   |
   v
ACK
```

If the consumer crashes before acknowledgement, depending on configuration, the message can be redelivered.

---

# 28. RabbitMQ Prefetch

RabbitMQ can limit how many unacknowledged messages a consumer receives.

Example:

```text
prefetch = 10
```

A consumer can receive up to a configured number of unacknowledged messages before receiving more.

This helps prevent one worker from being overwhelmed.

---

# 29. RabbitMQ Dead Letter Queue

If a message repeatedly fails:

```text
Queue
 ↓
Consumer
 ↓
Failure
 ↓
Retry
 ↓
Failure
 ↓
DLQ
```

DLQ is useful for:

```text
Poison messages
Failed processing
Manual investigation
Recovery
```

---

# 30. RabbitMQ Advantages

### 1. Excellent Routing

Exchange types provide flexible routing.

### 2. Great for Task Queues

Example:

```text
Generate PDF
Send Email
Process Image
Resize Video
```

### 3. ACK-Based Processing

Consumers explicitly acknowledge messages.

### 4. Mature Messaging Model

It provides strong messaging features such as:

```text
Queues
Exchanges
Bindings
Routing
ACK
Prefetch
Dead lettering
```

### 5. Lower Barrier for Simple Messaging

For straightforward asynchronous work queues, RabbitMQ can be easier to understand than a full Kafka streaming architecture.

---

# 31. RabbitMQ Disadvantages

### 1. Less Suitable for Large Event Replay Workflows

Traditional queue consumption generally removes/settles messages after successful acknowledgement.

Kafka is usually a better fit when long-lived event retention and replay are central requirements.

### 2. Scaling Can Be More Complex at Very Large Streaming Volumes

RabbitMQ can scale significantly, but Kafka is generally designed around very large distributed event streams and partitioned logs.

### 3. Message Routing Adds Complexity

Large routing topologies can become difficult to manage.

### 4. Not Primarily a Distributed Event Log

Its mental model is messaging and routing rather than a durable partitioned event log.

---

# 32. Kafka vs RabbitMQ — Main Difference

| Feature | Kafka | RabbitMQ |
|---|---|---|
| Main purpose | Event streaming | Message broker / queues |
| Data model | Distributed log | Queues + exchanges |
| Routing | Topic/partition/key | Exchange/binding/routing key |
| Replay | Excellent | Not the primary model |
| Ordering | Within partition | Queue-level ordering with important caveats |
| Throughput | Very high | High |
| Consumer model | Consumer groups | Consumers on queues |
| Message position | Offset | ACK/unacknowledged state |
| Retention | Central feature | Queue lifecycle/ack model |
| Task queues | Possible | Excellent |
| Event streaming | Excellent | Possible |
| Flexible routing | Good | Excellent |
| Analytics pipelines | Excellent | Less common |
| Simple async jobs | Good | Excellent |
| Operational model | More streaming-oriented | More broker/routing-oriented |

---

# 33. Easy Way to Remember

```text
Kafka
=
EVENT STREAM
+
PARTITIONS
+
OFFSETS
+
REPLAY
+
HIGH THROUGHPUT
```

```text
RabbitMQ
=
MESSAGE BROKER
+
EXCHANGE
+
QUEUE
+
ROUTING
+
ACK
```

---

# 34. Example — Order Processing

## Using Kafka

```text
Order Service
      |
      v
Kafka: orders
      |
      +→ Payment Group
      |
      +→ Inventory Group
      |
      +→ Email Group
      |
      +→ Analytics Group
```

Every consumer group independently receives the event.

Best when:

```text
OrderCreated
```

is an important business event that many systems may consume.

---

## Using RabbitMQ

```text
Order Service
      |
      v
Exchange
   /   |   \
  v    v    v
 Q1   Q2    Q3
  |    |     |
Payment Email Inventory
```

RabbitMQ is especially useful when routing messages to different work queues is the main requirement.

---

# 35. Scenario-Based Interview Questions

---

## Q1. Why would you choose Kafka instead of RabbitMQ?

### Answer

I would choose Kafka when I need:

```text
High throughput
+
Event streaming
+
Longer retention
+
Event replay
+
Multiple independent consumer groups
+
Large-scale data pipelines
```

Example:

```text
E-commerce
     |
     v
Kafka
     |
     +→ Analytics
     +→ Recommendation
     +→ Fraud Detection
     +→ Data Lake
```

---

# Q2. When would you choose RabbitMQ instead of Kafka?

### Answer

I would choose RabbitMQ when the main requirement is:

```text
Task distribution
+
Flexible routing
+
ACK-based processing
+
Work queues
```

Example:

```text
API
 |
 v
RabbitMQ
 |
 +→ Worker 1
 +→ Worker 2
 +→ Worker 3
```

For example, generating thousands of PDFs asynchronously.

---

# Q3. Consumer crashes after processing a Kafka message. What happens?

If the consumer processed the message but crashed before committing its offset:

```text
Process
 ↓
Crash
 ↓
Offset not committed
 ↓
Message can be processed again
```

Therefore:

```text
At-least-once
+
Idempotency
```

is important.

---

# Q4. Consumer crashes after processing a RabbitMQ message but before ACK. What happens?

The message may be redelivered.

Therefore the consumer should be idempotent.

Example:

```text
Message ID = 123

First processing → success
Crash before ACK
Redelivery → same message
```

Use:

```text
Idempotency key
+
Deduplication
+
Database constraint
```

where required.

---

# Q5. Kafka consumer is too slow. What would you do?

First check:

```text
Consumer Lag
```

Then:

```text
1. Increase consumer instances
2. Check partition count
3. Increase partitions if appropriate
4. Optimize consumer processing
5. Batch work
6. Scale downstream dependencies
7. Apply backpressure
```

Important:

> If there are only 3 partitions, adding 20 consumers to the same consumer group will not give 20-way partition parallelism.

---

# Q6. Can I have 10 Kafka consumers for 3 partitions?

Yes.

Example:

```text
Partitions = 3
Consumers = 10
```

Only up to approximately 3 consumers can actively own partitions in that consumer group at one time.

The remaining consumers will be idle until more partitions become available.

---

# Q7. How do you maintain ordering in Kafka?

Use a meaningful key.

Example:

```text
key = orderId
```

Then related events can be routed to the same partition.

```text
Order 101
   ↓
Partition 2

Created
Paid
Shipped
```

Kafka maintains order within that partition.

---

# Q8. How do you handle duplicate messages?

Use idempotency.

Example:

```text
eventId = 123
```

Store processed event IDs:

```text
processed_events

event_id
---------
123
124
125
```

When event 123 arrives again:

```text
Already exists
     ↓
Ignore duplicate
```

For important operations, enforce uniqueness at the database level where possible.

---

# Q9. What happens if a Kafka broker fails?

Kafka uses replication.

```text
Broker 1 → Leader
Broker 2 → Replica
Broker 3 → Replica
```

If Broker 1 fails:

```text
Broker 2
    ↓
New Leader
```

The system continues if sufficient healthy replicas remain.

---

# Q10. What happens if a RabbitMQ consumer fails?

If the message has not been acknowledged, RabbitMQ can redeliver it to another available consumer, depending on queue/consumer configuration.

Therefore:

```text
Consumer
+
ACK
+
Retry
+
Idempotency
```

are important.

---

# Q11. You need to send an email after an order is created. Kafka or RabbitMQ?

Both can work.

If the requirement is simply:

```text
Create Order
   ↓
Send Email asynchronously
```

RabbitMQ can be a straightforward choice.

If the event is:

```text
OrderCreated
```

and many systems need it:

```text
Payment
Analytics
Fraud
Recommendation
Email
```

Kafka becomes more attractive.

---

# Q12. You need to process images asynchronously. Which one?

RabbitMQ is a strong choice.

```text
Upload Image
     |
     v
RabbitMQ
     |
     +→ Worker 1
     +→ Worker 2
     +→ Worker 3
```

Workers consume jobs and ACK them after successful processing.

---

# Q13. You need to replay 7 days of events. Which one?

Kafka is usually the better fit.

```text
Kafka
 |
 +→ Events retained
 |
 +→ Consumer moves to older offset
 |
 +→ Replay
```

Replay is a fundamental Kafka use case.

---

# Q14. You need millions of events per second. Which one?

Kafka is generally the stronger choice for a large-scale event-streaming workload.

But the final decision depends on:

```text
Message size
Partitions
Broker count
Network
Storage
Consumer processing
Replication
Latency requirements
```

Do not answer only:

> "Kafka is faster."

Explain the workload and architecture.

---

# Q15. Need flexible routing based on message type. Which one?

RabbitMQ is often a strong choice.

Example:

```text
Exchange
 |
 +→ order.* → Order Queue
 |
 +→ payment.* → Payment Queue
 |
 +→ notification.* → Notification Queue
```

Its exchange/binding model is designed for flexible routing.

---

# Q16. One event needs to be consumed by 5 independent applications. Which one?

Kafka is a natural fit:

```text
                 Kafka
                   |
      +------------+------------+
      |            |            |
 Payment         Email       Analytics
 Group            Group         Group
```

Each consumer group tracks its own progress.

RabbitMQ can also implement fanout using separate queues, so the answer should explain the workload rather than claiming RabbitMQ cannot do it.

---

# Q17. What if Kafka consumer processing takes 10 minutes?

Potential issues include:

```text
Long processing time
Consumer timeout/configuration
Consumer lag
Partition ownership
Rebalancing
```

Possible solutions:

```text
Use appropriate consumer configuration
+
Move long-running work to a task system
+
Split processing
+
Use asynchronous workers
+
Make processing idempotent
```

Do not blindly increase every timeout.

---

# Q18. What if RabbitMQ queue becomes huge?

A growing queue means consumers cannot keep up.

Check:

```text
Queue depth
Consumer throughput
Consumer count
Processing latency
Downstream dependencies
```

Then:

```text
Add workers
Optimize processing
Increase prefetch carefully
Rate limit producers
Fix downstream bottlenecks
```

---

# Q19. What happens if a message always fails?

Use retry limits and dead lettering.

```text
Message
   ↓
Consumer
   ↓
Fail
   ↓
Retry
   ↓
Retry
   ↓
Retry limit
   ↓
DLQ
```

Then:

```text
Alert
+
Inspect
+
Fix
+
Replay/reprocess
```

---

# Q20. Can Kafka replace a database?

No.

Kafka and databases solve different problems.

```text
Kafka
→ Event transport/storage/stream processing

Database
→ Queryable application state
```

Kafka can be used as an event source in some architectures, but it is not a general replacement for a relational or NoSQL database.

---

# 36. System Design Example — Notification System

Suppose we need to send:

```text
Email
SMS
Push Notification
```

after an order.

## Kafka design

```text
                 Order Service
                      |
                      v
                    Kafka
                      |
            notification-events
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
       Email        SMS          Push
       Group        Group        Group
```

Advantages:

- Decoupling
- Replay
- Multiple consumer groups
- High throughput
- Independent scaling

---

## RabbitMQ design

```text
Order Service
      |
      v
Notification Exchange
      |
   +--+--+--+
   |  |  |
   v  v  v
 Email SMS Push
 Queue Queue Queue
```

Advantages:

- Flexible routing
- Queue-based work processing
- ACK/retry model
- Simple worker scaling

---

# 37. Interview Decision Framework

Do NOT start your answer with:

> "Kafka is better than RabbitMQ."

Instead ask:

```text
1. Is this an event stream or a task queue?

2. Do we need replay?

3. How long should messages be retained?

4. Do many independent applications consume the same event?

5. Do we need flexible routing?

6. What throughput is required?

7. What latency is required?

8. Do we need strict ordering? At what scope?

9. What delivery guarantee is required?

10. What is the operational complexity we can accept?
```

Then choose the technology.

---

# 38. Kafka — Interview One-Liner

> **Kafka is a distributed event-streaming platform optimized for high-throughput, durable, scalable, partitioned, and replayable event processing.**

Remember:

```text
Kafka
→ Topic
→ Partition
→ Offset
→ Consumer Group
→ Retention
→ Replay
→ Replication
→ High Throughput
```

---

# 39. RabbitMQ — Interview One-Liner

> **RabbitMQ is a message broker optimized for asynchronous messaging, work queues, acknowledgements, and flexible message routing through exchanges and bindings.**

Remember:

```text
RabbitMQ
→ Producer
→ Exchange
→ Routing Key
→ Queue
→ Consumer
→ ACK
→ Retry
→ DLQ
```

---

# 40. ⭐ Final Kafka vs RabbitMQ Cheat Sheet

```text
KAFKA

Think:
EVENT STREAM

Best for:
- High throughput
- Event-driven architecture
- Analytics
- Data pipelines
- CDC
- Event replay
- Multiple independent consumers

Core:
Producer
→ Topic
→ Partition
→ Broker
→ Consumer Group
→ Offset
→ Retention
```

```text
RABBITMQ

Think:
MESSAGE ROUTING + TASK QUEUE

Best for:
- Background jobs
- Work queues
- Asynchronous processing
- Flexible routing
- ACK-based processing
- Retry/DLQ workflows

Core:
Producer
→ Exchange
→ Binding
→ Queue
→ Consumer
→ ACK
```

---

# 41. ⭐ 10 Questions You MUST Know

Before an interview, make sure you can answer these without notes:

```text
1. What is Kafka?

2. What is RabbitMQ?

3. Kafka topic vs partition?

4. What is a Kafka consumer group?

5. What is Kafka offset?

6. Kafka vs RabbitMQ — when would you choose each?

7. How does Kafka maintain ordering?

8. How do you handle duplicate messages?

9. What happens when a consumer/broker fails?

10. How do you handle slow consumers and growing lag?
```

---

# 42. ⭐ Best Short Recall

```text
Kafka
=
Streaming + Scale + Storage + Replay

RabbitMQ
=
Messaging + Routing + Queue + ACK
```

```text
Kafka:
Topic → Partition → Offset → Consumer Group

RabbitMQ:
Exchange → Binding → Queue → Consumer → ACK
```

```text
Need replay?
→ Kafka

Need huge event streams?
→ Kafka

Need multiple independent event consumers?
→ Kafka

Need task/work queue?
→ RabbitMQ

Need flexible routing?
→ RabbitMQ

Need ACK-based worker processing?
→ RabbitMQ
```

### Most important interview statement

> **"I would choose Kafka when the problem is primarily a durable, scalable event stream with replay and multiple independent consumers. I would choose RabbitMQ when the problem is primarily reliable message delivery, work distribution, and flexible routing. The final choice depends on throughput, ordering, retention, replay, delivery semantics, routing requirements, and operational constraints."**