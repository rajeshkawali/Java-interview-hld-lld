# Apache Kafka — Complete Interview Preparation Guide
---
# Table of Contents

1. What Is Apache Kafka?
2. Kafka Core Architecture
3. Kafka Workflow
4. Messaging Models
5. When to Use Kafka
6. When NOT to Use Kafka
7. Advantages and Disadvantages
8. Real-World Examples
9. Most Frequently Asked Questions
10. Scenario-Based Interview Questions
11. Deeper Technical Questions
12. Comparison Questions
13. Performance and Reliability Cheat Sheet
14. Interview Tips
15. Final Kafka Cheat Sheet


---

# 1. What Is Apache Kafka?

## Definition

Apache Kafka is a **distributed event-streaming platform** designed to publish, store, process, and consume large volumes of events in a scalable and fault-tolerant manner.

At its core, Kafka stores events in **partitioned, append-only logs**. Producers write events to topics, and consumers read those events from topics. Unlike a traditional queue where a message is normally removed after successful consumption, Kafka retains events according to configurable retention policies, allowing consumers to read or replay historical data.

A useful mental model is:

> **Kafka is a distributed, durable event log that multiple applications can independently consume and replay.**

---

## Why Was Kafka Created?

Large distributed systems often have many services that need to communicate.

For example:

```text
                    ┌───────────────┐
                    │ Order Service │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Payment       │
                    │ Service       │
                    └───────────────┘
```

Direct service-to-service communication creates tight coupling.

With Kafka:

```text
Order Service
      │
      ▼
┌─────────────────┐
│ Kafka Topic     │
│ order-events    │
└─────────────────┘
   │       │       │
   ▼       ▼       ▼
Payment  Inventory  Email
Service   Service   Service
```

The producer does not need to know which consumers exist.

This provides:

- Loose coupling
- Asynchronous communication
- Scalability
- Fault tolerance
- Event replay
- Independent consumers
- High throughput

---

# 2. Kafka Core Architecture

The major Kafka concepts are:

| Component | Purpose |
|---|---|
| Producer | Publishes events |
| Consumer | Reads events |
| Topic | Logical category/feed of events |
| Partition | Ordered log within a topic |
| Broker | Kafka server that stores/serves data |
| Consumer Group | Group of consumers cooperating to process partitions |
| Offset | Position of a record within a partition |
| Replication | Copies partitions across brokers |
| Controller | Manages cluster metadata and leadership |
| KRaft | Kafka's modern metadata/consensus architecture |

---

## 2.1 Producer

A **producer** is an application that writes events to Kafka.

Example:

```json
{
  "orderId": "ORD-1001",
  "customerId": "C123",
  "amount": 2500,
  "status": "PLACED"
}
```

The producer sends the event to a topic such as:

```text
orders
```

The producer can specify:

- Topic
- Key
- Value
- Partition
- Headers

The key is particularly important because Kafka can use it to determine the partition.

For example:

```text
key = customerId
```

can ensure that events for the same customer are routed consistently to the same partition, preserving ordering for that key.

---

## 2.2 Topic

A **topic** is a logical stream/category of events.

Examples:

```text
orders
payments
inventory-events
user-events
application-logs
click-events
```

A topic is not simply a queue. It can have multiple producers and multiple independent consumer groups. Kafka retains records rather than deleting them merely because one consumer has read them.

Example:

```text
Topic: orders

Partition 0:
offset 0 → Order A
offset 1 → Order B
offset 2 → Order C

Partition 1:
offset 0 → Order D
offset 1 → Order E
offset 2 → Order F
```

---

## 2.3 Partition

A **partition** is an ordered, append-only log within a topic.

If a topic has three partitions:

```text
orders

Partition 0: [A] [D] [G] [J]
Partition 1: [B] [E] [H] [K]
Partition 2: [C] [F] [I] [L]
```

Each partition has its own offsets:

```text
Partition 0:
0 → A
1 → D
2 → G
3 → J
```

Kafka's ordering guarantee is fundamentally **per partition**, not globally across an entire topic.

This is one of the most important Kafka interview concepts.

### Interview phrase

> "Kafka guarantees ordering within a partition, not across all partitions of a topic."

Partitions are the primary mechanism for Kafka scalability because different partitions can be distributed across brokers and processed concurrently.

---

## 2.4 Offset

An **offset** identifies a record's position within a partition.

Example:

```text
Partition 0

Offset 0 → Order A
Offset 1 → Order B
Offset 2 → Order C
Offset 3 → Order D
```

Offsets are not globally unique.

This:

```text
Partition 0, Offset 10
```

and:

```text
Partition 1, Offset 10
```

are different records.

A consumer tracks its position using offsets, which allows it to resume processing after a restart or deliberately replay earlier records.

---

## 2.5 Broker

A **broker** is a Kafka server.

A Kafka cluster might look like:

```text
Kafka Cluster

Broker 1
Broker 2
Broker 3
Broker 4
```

A broker can store partitions and serve producer/consumer requests.

For example:

```text
Topic: orders

Broker 1 → Partition 0
Broker 2 → Partition 1
Broker 3 → Partition 2
```

With replication:

```text
Partition 0
Leader  → Broker 1
Follower → Broker 2
Follower → Broker 3
```

Replication allows Kafka to survive broker failures.

---

## 2.6 Consumer

A **consumer** reads records from Kafka.

Example:

```text
Kafka
  │
  ▼
orders topic
  │
  ▼
Order Consumer
  │
  ▼
Database
```

Consumers control their position by committing offsets.

Depending on configuration and application logic, offsets can be committed automatically or manually.

Manual commits are often preferred when processing has important side effects because the application can coordinate processing and offset management more carefully.

---

## 2.7 Consumer Group

A **consumer group** is a set of consumers cooperating to consume a topic.

Suppose:

```text
Topic: orders
Partitions: 4

P0 P1 P2 P3
```

Consumer group:

```text
Consumer A → P0
Consumer B → P1
Consumer C → P2
Consumer D → P3
```

Each partition is assigned to at most one active consumer within a consumer group.

Therefore:

> **Maximum parallelism for a consumer group is bounded by the number of partitions.**

If there are:

```text
4 partitions
10 consumers
```

only up to four consumers can actively own partitions at a time.

The remaining consumers are idle until more partitions are available.

---

## 2.8 Replication

Kafka replicates partitions across brokers.

Example:

```text
Partition 0

Broker 1 → Leader
Broker 2 → Follower
Broker 3 → Follower
```

If Broker 1 fails:

```text
Broker 2
   ↓
becomes leader
```

The replication factor is the total number of replicas.

For example:

```text
replication.factor = 3
```

means three copies of the partition exist across brokers.

Kafka's replication mechanism is one of the major reasons it can provide fault tolerance.

---

## 2.9 ISR — In-Sync Replicas

ISR means **In-Sync Replicas**.

These are replicas considered sufficiently caught up with the partition leader.

Example:

```text
Partition 0

Leader:   Broker 1
Follower: Broker 2  ← ISR
Follower: Broker 3  ← ISR
```

If Broker 3 falls significantly behind, Kafka can remove it from the ISR.

Then:

```text
ISR = Broker 1, Broker 2
```

This concept is critical for understanding:

- Durability
- `acks`
- `min.insync.replicas`
- Failover
- Producer availability

Kafka documentation describes committed-message durability in terms of replicas and ISR state.

---

# 3. Kafka Controller and ZooKeeper/KRaft

## Historical Architecture: ZooKeeper

Older Kafka deployments used **Apache ZooKeeper** for cluster coordination and metadata management.

Conceptually:

```text
              ZooKeeper
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
     Broker 1  Broker 2  Broker 3
```

ZooKeeper was involved in things such as:

- Cluster metadata
- Controller election
- Broker registration
- Leadership information

However, this architecture introduced an additional distributed system that Kafka operators had to deploy and maintain.

---

## Modern Architecture: KRaft

Kafka has moved to **KRaft**, Kafka's own metadata/consensus architecture.

Kafka 4.0 operates entirely without ZooKeeper; ZooKeeper mode was removed.

Modern Kafka:

```text
             KRaft Controller Quorum
             ┌──────────────────────┐
             │ Controller 1         │
             │ Controller 2         │
             │ Controller 3         │
             └──────────┬───────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
     Broker 1        Broker 2        Broker 3
```

One controller acts as the active leader for metadata operations while the controller quorum maintains metadata using Kafka's consensus mechanism.

### Interview answer

If asked:

**"Does Kafka use ZooKeeper?"**

A modern answer is:

> "Historically Kafka used ZooKeeper, but Kafka 4.0 removed ZooKeeper support. Modern Kafka uses KRaft for metadata management and controller quorum. So ZooKeeper is now a legacy architecture rather than something you deploy with current Kafka."

---

# 4. Kafka Workflow

The basic workflow is:

```text
                  PRODUCER
                     │
                     │ send(record)
                     ▼
              ┌───────────────┐
              │ Kafka Broker  │
              │               │
              │ Topic         │
              │  ├─ P0        │
              │  ├─ P1        │
              │  └─ P2        │
              └───────┬───────┘
                      │
                fetch(records)
                      │
                      ▼
                  CONSUMER
                      │
                      ▼
               Business Logic
```

---

## Sequence Diagram

```text
Producer              Kafka Broker             Consumer
   |                       |                       |
   |--- Produce Event ---->|                       |
   |                       |                       |
   |                       |--- Append to Log ---> |
   |                       |                       |
   |<------ ACK -----------|                       |
   |                       |                       |
   |                       |<---- Fetch ----------|
   |                       |                       |
   |                       |----- Records -------->|
   |                       |                       |
   |                       |                       | Process
   |                       |                       |
   |                       |<--- Offset Commit ---|
   |                       |                       |
```

More precisely, Kafka producers write to the **leader of the target partition**. Consumers fetch records from Kafka and maintain/commit their position using offsets.

---

## Example: Order Event

A customer places an order.

```text
Application
     │
     │ OrderCreated
     ▼
Kafka topic: orders
     │
     ├──────────────► Payment Service
     │
     ├──────────────► Inventory Service
     │
     ├──────────────► Shipping Service
     │
     └──────────────► Analytics Service
```

Each service can have its own consumer group:

```text
orders
  │
  ├── payment-group
  ├── inventory-group
  ├── shipping-group
  └── analytics-group
```

Each group independently receives the event stream.

---

# 5. Messaging Models

Kafka can support patterns resembling both **publish/subscribe** and **queue-style load balancing**, although its underlying abstraction is a retained distributed log.

## 5.1 Publish/Subscribe

Multiple consumer groups independently consume the same topic.

```text
                  orders
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
    Payment       Inventory    Analytics
     Group          Group        Group
```

Every group gets its own logical consumption position.

If Payment has processed offset 100 while Analytics is at offset 80, that is completely acceptable.

---

## 5.2 Queue-Like Model

Multiple consumers belong to the same group.

```text
              orders
                 │
        ┌────────┼────────┐
        ▼        ▼        ▼
       C1       C2       C3
        \        |        /
         └── same group ─┘
```

Partitions are distributed among consumers.

Example:

```text
P0 → C1
P1 → C2
P2 → C3
P3 → C1
```

This gives queue-like work distribution.

### Important distinction

Kafka does not primarily think:

> "This message belongs to consumer X."

Instead:

> "This partition belongs to a consumer within this group, and the consumer processes records from that partition."

---

# 6. When to Use Kafka

Kafka is particularly appropriate when you need **high-throughput event streaming, durable event retention, multiple independent consumers, replayability, and horizontal scalability**.

## Good Kafka Use Cases

### 1. Event-driven microservices

```text
Order Service
     │
     ▼
Kafka
 ┌───┼────────┐
 ▼   ▼        ▼
Payment Inventory Shipping
```

Benefits:

- Loose coupling
- Asynchronous processing
- Independent scaling
- Event replay

---

### 2. Log aggregation

Applications produce logs:

```text
Server 1 ─┐
Server 2 ─┤
Server 3 ─┼──► Kafka ──► Log Processing
Server 4 ─┘              │
                         ▼
                    Storage/Search
```

Kafka can act as a durable buffer between log producers and downstream processing.

---

### 3. Streaming analytics

Example:

```text
User clicks
     │
     ▼
Kafka
     │
     ├──► Stream Processor
     │        │
     │        ▼
     │    Aggregations
     │
     └──► Data Lake
```

---

### 4. Event sourcing

Instead of storing only the current state:

```text
Account Balance = ₹10,000
```

the system stores events:

```text
Deposit ₹5,000
Withdrawal ₹2,000
Deposit ₹7,000
```

The state can be reconstructed from the event history.

---

### 5. CDC — Change Data Capture

A database change stream can be published to Kafka:

```text
Database
   │
   ▼
CDC Connector
   │
   ▼
Kafka
   │
   ├──► Search Index
   ├──► Data Warehouse
   └──► Cache
```

This is useful when multiple systems need database changes without tightly coupling them to the database.

---

# 7. When NOT to Use Kafka

Kafka is powerful, but it is not automatically the best messaging solution.

## 7.1 Simple request/response

If an application simply needs:

```text
Client → Server → Response
```

Kafka may add unnecessary complexity.

HTTP/gRPC is often more appropriate.

---

## 7.2 Very small applications

If you have:

```text
One application
One database
Very low traffic
No event-streaming requirement
```

introducing Kafka can create operational overhead without providing enough benefit.

---

## 7.3 Complex per-message routing

If your requirements look like:

```text
Message
  ├── route based on header
  ├── route based on priority
  ├── route based on pattern
  ├── route to one exact consumer
  └── expire after a short TTL
```

a traditional broker such as RabbitMQ may be more natural.

---

## 7.4 Strictly synchronous workflows

If the caller must immediately know whether the operation succeeded, Kafka is not necessarily the right primary communication mechanism.

For example:

```text
Browser → API → Database → Response
```

does not need Kafka simply because Kafka is available.

---

## 7.5 Very low-latency transient messaging

Kafka can achieve low latency, but its architecture is optimized heavily around durable distributed logs and throughput.

If you need specialized ultra-low-latency transient messaging, another technology may be more appropriate.

---

# 8. Advantages and Disadvantages

## Advantages

### High throughput

Kafka is designed for large-scale sequential writes and reads.

### Horizontal scalability

Add partitions and brokers to distribute workload.

### Durability

Events can be persisted and replicated across brokers.

### Replayability

Consumers can move backward and reread historical records, subject to retention/compaction behavior.

### Multiple consumers

The same event can independently feed many consumer groups.

### Fault tolerance

Replication provides failover when brokers fail.

### Loose coupling

Producers do not need direct knowledge of downstream consumers.

### Event-driven architecture

Kafka works naturally with microservices, streaming systems, and event-based designs.

---

## Disadvantages

### Operational complexity

Kafka clusters require careful management of:

- Brokers
- Partitions
- Replication
- Storage
- Consumer groups
- Monitoring
- Network
- Security
- Upgrades

### Partition management

Poor partitioning can produce:

- Hot partitions
- Uneven load
- Consumer bottlenecks
- Reduced parallelism

### Consumer lag

A slow consumer can fall behind significantly.

### Ordering limitations

Global ordering across partitions is not guaranteed.

### Duplicate processing

At-least-once processing can result in duplicate application-side processing unless consumers are designed to handle it.

### Large operational footprint

Kafka can be excessive for simple applications.

---

# 9. Most Frequently Asked Questions

## Question 1: What is Kafka?

### Answer

Kafka is a distributed event-streaming platform based around durable, partitioned logs. Producers publish events to topics and consumers read them from those topics. Kafka is designed for high throughput, horizontal scalability, fault tolerance, and the ability to retain and replay events.

The key distinction from many traditional queues is that Kafka does not normally delete a record merely because one consumer processed it. Records remain available according to topic retention or compaction policies, allowing multiple consumer groups to independently process or replay the same data.

---

## Question 2: What is a Kafka topic?

### Answer

A topic is a logical category or stream to which producers publish events. Examples include `orders`, `payments`, and `user-events`.

A topic is divided into partitions. Consumers read the partitions, and Kafka retains the events according to configured retention policies rather than deleting them immediately after consumption.

---

## Question 3: What is a Kafka partition?

### Answer

A partition is an ordered, append-only sequence of records within a Kafka topic. Each record receives an offset that identifies its position within that partition.

Partitions provide Kafka's primary mechanism for parallelism and scalability. Different partitions can be distributed across brokers and processed concurrently. However, ordering is guaranteed only within an individual partition.

---

## Question 4: Why does Kafka use partitions?

### Answer

Partitions allow a topic to be distributed across multiple brokers. Instead of one broker handling every write and read, different partitions can be processed by different brokers concurrently.

They also provide consumer parallelism. If a topic has 20 partitions, a consumer group can theoretically have up to 20 active partition owners. Adding more consumers beyond the partition count does not increase parallelism for that topic.

---

## Question 5: Does Kafka guarantee message ordering?

### Answer

Kafka guarantees ordering **within a partition**. It does not guarantee global ordering across multiple partitions.

If all events requiring strict ordering use the same key and therefore map to the same partition, their order can be preserved. For example, using `customerId` as the key can ensure a customer's events are consistently routed to the same partition.

---

## Question 6: What is a consumer group?

### Answer

A consumer group is a set of consumers cooperating to process a topic. Within a group, a partition is assigned to at most one active consumer at a time.

Different groups act independently. Therefore, if `payment-group` and `analytics-group` both subscribe to `orders`, both groups can process every event while consumers inside each group divide the partitions among themselves.

---

## Question 7: What happens if there are more consumers than partitions?

### Answer

Extra consumers become idle because a partition can be actively assigned to only one consumer within a consumer group.

For example:

```text
6 partitions
10 consumers

C1 → P0
C2 → P1
C3 → P2
C4 → P3
C5 → P4
C6 → P5

C7-C10 → idle
```

Therefore, if you need more consumer parallelism, increasing the number of consumers alone is insufficient; you need enough partitions.

---

## Question 8: What is an offset?

### Answer

An offset is the position of a record within a partition.

For example:

```text
P0:
0 → A
1 → B
2 → C
3 → D
```

If a consumer has committed offset 2, its restart behavior depends on the exact offset semantics/configuration, but conceptually it has recorded its progress so that it can resume from a known position. Offsets make replay and recovery possible.

---

## Question 9: What is consumer lag?

### Answer

Consumer lag represents how far a consumer's processing position is behind the available data in a partition.

Conceptually:

```text
Log End Offset = 1,000,000
Consumer Position = 950,000

Lag ≈ 50,000 records
```

Lag can be caused by slow processing, insufficient consumers, downstream database bottlenecks, GC pauses, network problems, hot partitions, or insufficient partition-level parallelism.

---

## Question 10: What is replication factor?

### Answer

Replication factor is the number of copies of each partition maintained across brokers.

For example:

```text
Replication Factor = 3

Broker 1 → Leader
Broker 2 → Follower
Broker 3 → Follower
```

Replication protects data from broker failures. Kafka replicates at the partition level and can elect another replica as leader after failure.

---

## Question 11: What is ISR?

### Answer

ISR stands for **In-Sync Replicas**. It represents replicas that are sufficiently caught up with the partition leader.

ISR is important for durability because producer acknowledgement and commit behavior can depend on the relationship between ISR and `min.insync.replicas`.

A replica falling behind can leave the ISR, reducing fault tolerance until it catches up.

---

## Question 12: Explain `acks=0`, `acks=1`, and `acks=all`.

### Answer

`acks=0` means the producer does not wait for an acknowledgement from the broker. It provides the lowest acknowledgement latency but the weakest delivery assurance.

`acks=1` means the leader acknowledges after accepting the record. `acks=all`/`acks=-1` requires stronger acknowledgement involving the in-sync replica set. In production systems where durability matters, `acks=all` is commonly combined with appropriate replication and `min.insync.replicas` settings. Kafka's documentation describes these settings as the producer's durability/latency trade-off.

---

## Question 13: What is `min.insync.replicas`?

### Answer

`min.insync.replicas` specifies the minimum number of in-sync replicas required for certain successful producer writes when strong acknowledgements are requested.

A common durability-oriented design might use:

```text
replication.factor = 3
min.insync.replicas = 2
acks = all
```

This means the system aims to require at least two in-sync replicas for the acknowledgement policy, reducing the chance of accepting writes when the cluster has insufficient healthy replicas.

---

## Question 14: What is the difference between a topic and a partition?

### Answer

A topic is a logical stream; a partition is one ordered log that makes up part of that stream.

Example:

```text
orders topic
   ├── partition 0
   ├── partition 1
   └── partition 2
```

The topic gives applications a logical name. Partitions provide storage distribution, ordering boundaries, and parallel processing.

---

## Question 15: What happens when a Kafka broker fails?

### Answer

If a broker contains leaders for some partitions, Kafka can detect the failure and elect eligible replicas as new leaders.

For example:

```text
Before:

P0 Leader → Broker 1
P0 Replica → Broker 2

Broker 1 fails.

After:

P0 Leader → Broker 2
```

The exact availability and durability depend on replication, ISR health, acknowledgement settings, and cluster configuration. Kafka's replicated design is intended to keep partitions available through broker failures after failover.

---

## Question 16: Is Kafka a queue or a pub/sub system?

### Answer

It can support patterns resembling both.

Different consumer groups give Kafka a publish/subscribe model:

```text
orders
 ├── payment-group
 ├── inventory-group
 └── analytics-group
```

Multiple consumers inside one group provide queue-like load distribution:

```text
orders
 └── worker-group
      ├── C1
      ├── C2
      └── C3
```

The underlying abstraction is a retained distributed log rather than a traditional destructive queue.

---

## Question 17: Why is Kafka fast?

### Answer

Kafka benefits from sequential append-oriented storage, batching, efficient network I/O, partition-level parallelism, and the ability to leverage the operating system's filesystem/page-cache behavior.

Producers can batch records, compress batches, and pipeline requests. Consumers fetch batches rather than requiring a separate broker-side operation for every individual record.

---

## Question 18: What is log compaction?

### Answer

Log compaction is a retention mechanism based on keys. Kafka can retain the latest known value for each key rather than retaining every historical version indefinitely.

For example:

```text
user-123 → name=Alice
user-123 → name=Bob
user-123 → name=Carol
```

After compaction, older versions can eventually be removed while the latest state remains.

Compaction is useful for state reconstruction, caches, changelogs, and database-style change streams. It does not simply mean "delete everything after a short time"; it is a key-based retention mechanism.

---

## Question 19: What is the difference between retention and compaction?

### Answer

Time/size retention answers:

> "How long or how much data should remain?"

For example:

```text
Retain for 7 days
```

Log compaction answers:

> "For each key, which historical records can eventually be removed while preserving the latest state?"

A topic can use retention, compaction, or configurations that combine the two behaviors depending on the use case.

---

## Question 20: Can Kafka guarantee exactly-once processing?

### Answer

Kafka supports mechanisms for **exactly-once semantics** within appropriate Kafka producer/consumer processing workflows, including transactions and idempotent producers.

However, "exactly once" should not be casually interpreted as "the entire business system can never execute an operation twice." If a Kafka consumer updates an external database and crashes at the wrong moment, coordinating Kafka offsets and an external side effect requires additional design.

A strong interview answer distinguishes **Kafka-level exactly-once processing** from **end-to-end exactly-once business effects**.

---

# 10. Scenario-Based Interview Questions

## Scenario 1: Consumer Lag Is Increasing

### Question

You have:

```text
Topic: orders
Partitions: 12

Consumer group:
Consumers: 4

Lag: continuously increasing
```

How would you troubleshoot?

### Answer

First determine whether the bottleneck is Kafka consumption or downstream processing.

Check:

```text
1. Consumer lag per partition
2. Consumer throughput
3. Processing latency
4. Poll frequency
5. Rebalances
6. CPU/memory/GC
7. Network throughput
8. Database/API latency
9. Partition distribution
```

If four consumers process 12 partitions, each consumer may own roughly three partitions. If processing is slow, increasing consumers to 12 may improve throughput because more partitions can be processed concurrently.

But do not blindly add consumers. If the database can process only 2,000 operations/sec, adding Kafka consumers may simply overload the database.

### Strong interview response

> "I would identify whether lag is uniform or concentrated in particular partitions. If lag is concentrated, I would investigate a hot partition or skewed key distribution. If lag is uniform, I would examine consumer processing throughput and downstream dependencies."

---

# Scenario 2: One Partition Has Huge Lag

### Question

You see:

```text
P0 → lag 10,000,000
P1 → lag 20,000
P2 → lag 15,000
P3 → lag 18,000
```

What could be wrong?

### Answer

A likely cause is a **hot partition**.

For example, the producer might use:

```text
key = country
```

and 70% of events could be:

```text
country = India
```

If the partitioning scheme maps those events to one partition, that partition receives disproportionate traffic.

Solutions include:

- Choose a better distribution key.
- Increase partition count where appropriate.
- Avoid keys with extremely skewed cardinality.
- Consider whether ordering requirements truly require the current key.
- Use a carefully designed composite key if business semantics allow it.

The trade-off is important: changing the key can improve distribution but may sacrifice the ordering guarantee previously associated with that key.

---

# Scenario 3: Need Ordering for Customer Events

### Question

A system receives:

```text
CustomerCreated
CustomerUpdated
CustomerSuspended
CustomerDeleted
```

The events for each customer must be processed in order. How would you design the topic?

### Answer

Use:

```text
key = customerId
```

Kafka's partitioning mechanism will consistently map the same key to a partition under the same partitioning scheme.

For example:

```text
customerId = C100

C100 Created
C100 Updated
C100 Suspended
C100 Deleted

             ↓

        Partition 7
```

Because these records are in the same partition, their relative order is preserved there.

The important trade-off is that you cannot simultaneously expect arbitrary scaling and global ordering across all customers. You are trading global ordering for scalable per-key ordering.

---

# Scenario 4: Consumer Crashes After Processing

### Question

A consumer receives:

```text
OrderCreated
```

It successfully charges the customer's card but crashes before committing the Kafka offset.

What happens?

### Answer

After restart, the consumer may read the same record again because its committed position does not reflect the completed processing.

Therefore:

```text
Kafka
  │
  ▼
Consumer
  │
  ├── Charge card ✓
  │
  ├── Crash ✗
  │
  └── Offset NOT committed
```

After restart:

```text
Kafka
  │
  ▼
Consumer
  │
  └── Charge card AGAIN
```

This is why consumers must often be **idempotent**.

For example, use:

```text
paymentId = orderId
```

and ensure the payment system rejects duplicate processing for an already completed payment.

---

# Scenario 5: Need to Process a Failed Event Again

### Question

A consumer accidentally processed bad data and you need to replay events from yesterday. Can Kafka do this?

### Answer

Yes, assuming the records are still available under the topic's retention/compaction policy.

Kafka's offset-based model makes replay possible. A consumer can reset its offsets to an earlier position or use a new consumer group to read historical data.

This is one of Kafka's major advantages over traditional destructive queues:

```text
Yesterday's events
       │
       ▼
     Kafka
       │
       ├── Consumer A
       ├── Consumer B
       └── New Replay Consumer
```

---

# Scenario 6: Database Is Down

### Question

Your consumer reads Kafka events and writes them to a database. The database goes down for two hours. What should happen?

### Answer

A good design allows Kafka to act as a durable buffer.

Conceptually:

```text
Producer
   │
   ▼
Kafka
   │
   ▼
Consumer
   │
   X
Database unavailable
```

The consumer should stop or slow down appropriately rather than acknowledging work that has not been successfully processed.

Once the database recovers:

```text
Kafka backlog
     │
     ▼
Consumer
     │
     ▼
Database
```

The consumer catches up.

The key concerns are retention duration, backlog size, consumer lag, database recovery capacity, and whether processing is idempotent.

---

# Scenario 7: Ten Consumers but Only Three Partitions

### Question

Why aren't all consumers doing work?

### Answer

Because consumer-group parallelism is bounded by partitions.

```text
Partitions = 3
Consumers = 10

P0 → C1
P1 → C2
P2 → C3

C4-C10 → idle
```

To increase active parallelism, increase the number of partitions, assuming the workload and cluster can support it.

However, increasing partitions is not free: it affects metadata, file descriptors, replication traffic, recovery time, and operational complexity.

---

# Scenario 8: Broker Disk Is Filling Up

### Question

Kafka disks are approaching 90% utilization. What would you investigate?

### Answer

First inspect:

```text
Topic retention
Partition sizes
Replication factor
Producer throughput
Consumer lag
Compaction configuration
Segment configuration
Unexpected high-volume topics
```

Remember that replication means storage usage is greater than the raw logical event volume.

For example:

```text
Logical data = 10 TB
Replication factor = 3

Approximate cluster storage requirement
≈ 30 TB
```

Actual storage planning must also include overhead and operational headroom.

Do not simply delete data manually. Review topic retention policies and cluster capacity planning.

---

# Scenario 9: Producer Throughput Is Too Low

### Question

A producer publishes 5,000 messages/sec but the business requires 50,000/sec. What would you check?

### Answer

Investigate:

```text
1. Number of partitions
2. Producer batching
3. linger configuration
4. Compression
5. Message size
6. Network bandwidth
7. Broker CPU
8. Broker disk throughput
9. Replication overhead
10. Acknowledgement latency
11. Number of producer connections
12. Request size limits
```

Batching can significantly improve efficiency because Kafka can process groups of records together rather than treating every message as a separate expensive network operation.

Compression can also reduce network and storage usage, although it increases CPU usage.

---

# Scenario 10: Duplicate Events Appear

### Question

Your downstream application sees the same event twice. Is Kafka broken?

### Answer

Not necessarily.

With at-least-once processing, duplicates can occur during failure windows.

For example:

```text
1. Consumer reads event
2. Consumer processes event
3. Consumer crashes
4. Offset commit did not complete
5. Consumer restarts
6. Same event is read again
```

The correct solution is often **idempotent processing**, rather than assuming the broker itself must prevent every duplicate side effect.

For example:

```text
eventId = E123

if E123 already processed:
    ignore
else:
    process
    record E123 as processed
```

---

# 11. Deeper Technical Questions

## Question 1: How does Kafka choose a partition?

### Answer

A producer can explicitly specify a partition, or it can use a partitioning strategy based on the record key and producer configuration.

A common conceptual model is:

```text
key
 ↓
partitioner
 ↓
partition number
```

The important design consideration is consistency: if events for the same entity must remain ordered, the producer should use an appropriate stable key.

---

## Question 2: Why can a key cause a hot partition?

### Answer

Suppose there are eight partitions but the producer uses:

```text
key = country
```

and 80% of traffic has:

```text
country = India
```

The same key maps consistently to one partition, potentially creating:

```text
P0 → 80%
P1 → 3%
P2 → 3%
P3 → 3%
...
```

This destroys the expected load distribution.

Therefore, partition-key design is both a correctness and scalability decision.

---

## Question 3: What is a leader replica?

### Answer

Each partition normally has one leader and zero or more follower replicas.

Writes go to the leader. Followers replicate the partition data.

Example:

```text
Partition 0

Broker 1 → Leader
Broker 2 → Follower
Broker 3 → Follower
```

If the leader fails, Kafka can elect an eligible replica as the new leader.

---

## Question 4: What happens during a consumer rebalance?

### Answer

A rebalance occurs when partition ownership within a consumer group changes.

Examples:

```text
Consumer joins
Consumer leaves
Consumer crashes
Subscription changes
Partition assignment changes
```

Kafka redistributes partitions among group members.

Example:

```text
Before:

C1 → P0 P1
C2 → P2 P3

C3 joins

After:

C1 → P0
C2 → P2 P3
C3 → P1
```

Frequent rebalances can hurt throughput and increase latency, so consumer configuration and application behavior should be designed to avoid unnecessary churn.

---

## Question 5: What is `max.poll.interval.ms` conceptually used for?

### Answer

It controls the maximum interval between consumer poll calls before the consumer is considered to have failed to make sufficient progress.

If message processing takes too long, the consumer may be removed from the group and trigger a rebalance.

Therefore:

```text
poll
 ↓
process batch
 ↓
poll
```

must happen within appropriate timing constraints.

A common mistake is setting the poll interval without considering actual processing time.

---

## Question 6: How would you tune Kafka for throughput?

### Answer

Start with measurement rather than blindly changing configuration.

Potential levers include:

```text
Producer:
- batching
- compression
- linger
- request size

Broker:
- disk throughput
- network bandwidth
- replication
- partition distribution

Consumer:
- fetch sizes
- batch processing
- number of consumers
- partition count
```

The goal is to improve **records/sec or bytes/sec while keeping latency, durability, and resource usage within acceptable limits**.

---

## Question 7: How would you tune Kafka for low latency?

### Answer

Reduce batching delays and avoid unnecessarily large processing buffers.

But low latency usually conflicts with throughput efficiency.

For example:

```text
Large batches
    ↓
Better throughput
    ↓
Potentially higher waiting time
```

while:

```text
Small batches
    ↓
Lower waiting time
    ↓
Potentially worse throughput
```

A good interview answer explicitly states the latency-throughput trade-off rather than claiming one configuration is universally best.

---

## Question 8: What is idempotent producer behavior?

### Answer

Producer retries can create duplicate records in some failure scenarios if writes are not protected appropriately.

Kafka supports idempotent producer mechanisms so retries can be handled without producing unintended duplicate records in the relevant Kafka write path.

This is particularly important when network failures cause uncertainty about whether the broker accepted a previous request.

---

## Question 9: What are Kafka transactions?

### Answer

Kafka transactions allow a producer to atomically write records to multiple partitions/topics while coordinating transactional state.

They are especially useful in stream-processing workflows where the application wants:

```text
Read input
   ↓
Process
   ↓
Write output + commit offsets
```

to have stronger atomicity guarantees within Kafka.

Transactions are not automatically a solution for arbitrary external systems such as databases or payment gateways.

---

## Question 10: What is `read_committed`?

### Answer

Kafka consumers can use an isolation level that controls visibility of transactional records.

Conceptually:

```text
READ_UNCOMMITTED
    ↓
May see transactional records before completion

READ_COMMITTED
    ↓
Only committed transactional results are exposed
```

Kafka's protocol documentation distinguishes transactional visibility using the consumer isolation level.

---

## Question 11: What happens if a consumer commits an offset before processing?

### Answer

This is dangerous.

Example:

```text
Read Event
   ↓
Commit Offset
   ↓
Process Event
   ↓
Crash
```

After restart, Kafka may consider the event consumed even though business processing failed.

Result:

```text
Message lost from application's processing perspective
```

A safer pattern for many applications is:

```text
Read
 ↓
Process
 ↓
Successfully complete side effect
 ↓
Commit offset
```

while also designing the side effect to be idempotent.

---

## Question 12: What happens if the consumer processes first and commits later?

### Answer

This prevents some forms of message loss but can cause duplicate processing.

Example:

```text
Read
 ↓
Process successfully
 ↓
Crash before commit
 ↓
Restart
 ↓
Process again
```

This is why at-least-once systems commonly require idempotent consumers.

---

## Question 13: What is the trade-off between at-most-once and at-least-once?

### Answer

### At-most-once

```text
Commit
 ↓
Process
```

A crash can result in the message never being processed.

Advantage:

- Lower duplicate risk

Disadvantage:

- Possible message loss

### At-least-once

```text
Process
 ↓
Commit
```

A crash can cause the message to be processed again.

Advantage:

- Lower message-loss risk

Disadvantage:

- Possible duplicates

For many business systems, at-least-once plus idempotent processing is a practical choice.

---

## Question 14: How do you choose the number of partitions?

### Answer

Consider:

```text
Expected producer throughput
Expected consumer throughput
Number of consumers
Message size
Broker capacity
Replication factor
Future growth
Ordering requirements
```

Suppose:

```text
Expected traffic = 100 MB/sec
One partition safely handles = 20 MB/sec

Required partitions ≈ 100 / 20
                    = 5
```

You would normally add headroom rather than provision exactly five.

Partition count is an architectural decision because changing it later can affect key-to-partition mapping and operational behavior.

---

## Question 15: Why not create thousands of partitions for everything?

### Answer

Partitions are not free.

More partitions can mean:

- More metadata
- More files/segments
- More replication work
- More leader management
- More recovery work
- More network traffic
- More operational complexity

Therefore, partition count should be based on actual throughput and parallelism requirements rather than "the more, the better."

---

## Question 16: What happens if all replicas of a partition fail?

### Answer

If no replica containing the required data is available, that partition cannot provide normal availability.

This is why replication factor alone is not enough. You also need:

- Multiple brokers
- Proper failure-domain placement
- Healthy ISR
- Adequate disk capacity
- Monitoring
- Disaster recovery strategy

A replication factor of three does not help if all three replicas are effectively lost in the same failure domain.

---

## Question 17: Why are rack/zone-aware replicas important?

### Answer

Suppose:

```text
RF = 3

Broker 1 → Availability Zone A
Broker 2 → Availability Zone A
Broker 3 → Availability Zone A
```

An entire zone failure could remove all replicas.

A better design spreads replicas:

```text
Broker 1 → AZ-A
Broker 2 → AZ-B
Broker 3 → AZ-C
```

This reduces correlated failure risk.

---

## Question 18: What is the difference between Kafka retention and a database?

### Answer

Kafka is optimized for sequential event-log storage and streaming consumption, not arbitrary relational querying.

Kafka can retain huge quantities of events and replay them, but it should not automatically be treated as a replacement for:

```text
SQL database
Document database
Data warehouse
Search engine
```

A common architecture uses Kafka as the event backbone and specialized systems as downstream storage/query layers.

---

## Question 19: Can Kafka lose messages?

### Answer

Kafka can be configured for different durability/latency trade-offs.

Weak acknowledgement settings, insufficient replication, misconfiguration, infrastructure failures, or application-level errors can compromise guarantees.

A durability-oriented configuration generally combines:

```text
Replication
+
Healthy ISR
+
Appropriate min.insync.replicas
+
Strong producer acknowledgements
+
Reliable storage
```

Kafka's documentation specifically ties committed-message durability to replication and ISR conditions.

---

## Question 20: Is Kafka a database?

### Answer

Kafka provides durable storage, but its abstraction is a distributed event log rather than a general-purpose database.

It is excellent for:

```text
Append events
Replay events
Stream events
Distribute events
Build event histories
```

It is not intended to replace a relational database's arbitrary indexed queries, transactions across unrelated tables, or rich relational modeling.

---

# 12. Comparison Questions

## Kafka vs RabbitMQ

| Feature | Kafka | RabbitMQ |
|---|---|---|
| Core model | Distributed log | Message broker |
| Primary strength | High-throughput streaming | Flexible messaging/routing |
| Replay | Excellent | Not its primary model |
| Partitioning | Core concept | Different model |
| Consumer groups | Core concept | Queue consumers |
| Routing | Topic/partition model | Exchanges/bindings |
| Retention | Core feature | Usually queue-oriented |
| Ordering | Per partition | Queue/order dependent |
| Huge event streams | Excellent | Usually less natural |
| Complex routing | Less natural | Excellent |
| Simple task queues | Can work | Excellent |

### When Kafka?

Use Kafka when:

```text
Large event streams
+
Multiple consumers
+
Replay
+
High throughput
+
Long-lived event history
```

### When RabbitMQ?

Use RabbitMQ when:

```text
Complex routing
+
Task queues
+
Per-message delivery semantics
+
Traditional broker patterns
```

---

## Kafka vs Apache Pulsar

| Feature | Kafka | Pulsar |
|---|---|---|
| Architecture | Brokers + storage integrated traditionally | Broker/storage separation |
| Streaming | Excellent | Excellent |
| Multi-tenancy | Strong | Strong |
| Geo-replication | Strong | Strong |
| Operational ecosystem | Extremely mature | Strong |
| Storage separation | More integrated | BookKeeper-based separation |
| Simplicity | Often simpler conceptually | Can be more complex |
| Existing Kafka ecosystem | Massive | Smaller |

### Interview answer

> "Kafka is often the default choice when the organization already has a mature Kafka ecosystem and needs high-throughput event streaming. Pulsar is attractive when architectural requirements such as storage/compute separation, multi-tenancy, or particular geo-distribution capabilities are important."

---

## Kafka vs Traditional Message Queue

Traditional queue:

```text
Producer
   │
   ▼
Queue
   │
   ▼
Consumer
   │
   └── Message removed
```

Kafka:

```text
Producer
   │
   ▼
Partitioned Log
   │
   ├── Consumer Group A
   ├── Consumer Group B
   └── Consumer Group C
```

The major conceptual difference is **retained event history and independent consumer positions**.

---

# 13. Performance and Reliability Cheat Sheet

## Producer

Important concepts:

```text
acks
compression
batching
linger
retries
idempotence
request size
```

General goal:

```text
Increase batch efficiency
+
Avoid unnecessary network calls
+
Use compression appropriately
+
Maintain required durability
```

---

## Broker

Monitor:

```text
CPU
Memory
Disk usage
Disk I/O
Network throughput
Request latency
Replication health
Under-replicated partitions
Controller health
```

---

## Consumer

Monitor:

```text
Consumer lag
Records/sec
Bytes/sec
Processing latency
Poll frequency
Rebalances
Commit failures
Exceptions
Downstream latency
```

---

## Partition

Watch for:

```text
Hot partitions
Uneven traffic
Uneven storage
Too few partitions
Excessive partitions
```

---

## Reliability

A production design should consider:

```text
Replication factor
min.insync.replicas
acks
Idempotent producers
Idempotent consumers
Consumer offset strategy
Retry strategy
Dead-letter strategy
Monitoring
Capacity planning
Failure domains
Disaster recovery
```

---

# 14. Interview Tips

## Tip 1: Start With the Core Mental Model

A strong opening answer is:

> "Kafka is a distributed, durable, partitioned event log. Producers write events to topics, topics are divided into partitions for scalability, and consumer groups read those partitions independently."

This immediately demonstrates that you understand Kafka's architecture rather than simply memorizing components.

---

## Tip 2: Always Mention Partitions

When discussing Kafka, remember:

```text
Topic
  ↓
Partitions
  ↓
Parallelism
  ↓
Scalability
```

Many Kafka interview questions ultimately come back to partitioning.

---

## Tip 3: Explain Ordering Correctly

Avoid saying:

> "Kafka guarantees ordering."

Instead say:

> "Kafka guarantees ordering within a partition. If ordering for an entity is required, use an appropriate key so those events are routed to the same partition."

---

## Tip 4: Explain Consumer Groups Clearly

Remember:

```text
Same group
    ↓
Load sharing

Different groups
    ↓
Independent consumption
```

This is one of the easiest ways to explain Kafka's queue-like and pub/sub behavior.

---

## Tip 5: Explain Consumer Lag as a Symptom

Do not just say:

> "Lag means the consumer is slow."

Instead say:

> "I would inspect lag per partition and determine whether the issue is processing throughput, a hot partition, insufficient partitions/consumers, downstream latency, rebalance churn, or resource saturation."

That demonstrates production-level troubleshooting ability.

---

## Tip 6: Discuss Trade-offs

Interviewers often care more about reasoning than configuration memorization.

For example:

```text
More partitions
     ↓
More parallelism
     ↓
But more operational overhead
```

or:

```text
More batching
     ↓
Higher throughput
     ↓
Potentially higher latency
```

or:

```text
At-least-once
     ↓
Lower message-loss risk
     ↓
Possible duplicates
     ↓
Need idempotency
```

---

## Tip 7: Mention Idempotency

When discussing retries, consumer crashes, or at-least-once processing, use the phrase:

> "The downstream operation should be idempotent."

This is especially important for:

- Payments
- Orders
- Inventory
- Database updates
- External APIs

---

## Tip 8: Mention KRaft in Modern Interviews

If asked about Kafka architecture today:

> "Older Kafka deployments used ZooKeeper, but modern Kafka uses KRaft. Kafka 4.0 removed ZooKeeper mode entirely."

This shows current Kafka knowledge.

---

# Common Kafka Interview Pitfalls

Avoid these answers:

### Wrong

> "Kafka deletes a message after the consumer reads it."

### Correct

> "Kafka retains records according to retention/compaction policies. A consumer's progress is tracked independently through offsets."

---

### Wrong

> "Kafka guarantees global ordering."

### Correct

> "Kafka guarantees ordering within a partition."

---

### Wrong

> "Adding more consumers always increases performance."

### Correct

> "Consumer-group parallelism is bounded by the number of partitions."

---

### Wrong

> "Kafka provides exactly-once for every external side effect."

### Correct

> "Kafka supports exactly-once mechanisms within appropriate Kafka workflows, but end-to-end exactly-once semantics involving external systems require additional coordination and design."

---

### Wrong

> "ZooKeeper is required for Kafka."

### Correct

> "ZooKeeper was used historically. Modern Kafka uses KRaft, and Kafka 4.0 removed ZooKeeper mode."

---

### Wrong

> "More partitions are always better."

### Correct

> "Partitions provide scalability and parallelism, but excessive partitions create metadata, storage, replication, recovery, and operational overhead."

---

# Key Phrases Interviewers Expect

Use these naturally:

- "Kafka is a distributed event log."
- "Topics are divided into partitions."
- "Ordering is guaranteed within a partition."
- "Partitions provide horizontal scalability."
- "Consumer groups provide parallel processing."
- "Different consumer groups independently consume the same events."
- "Offsets track consumer progress."
- "Kafka retains events based on retention policies."
- "Log compaction retains the latest state for keys."
- "Replication provides fault tolerance."
- "ISR means in-sync replicas."
- "`acks=all` provides stronger producer acknowledgement semantics."
- "`min.insync.replicas` controls the minimum ISR requirement for relevant writes."
- "Consumer lag indicates the consumer is behind the available log."
- "Hot partitions can cause uneven load."
- "At-least-once processing requires idempotent consumers when duplicates are unacceptable."
- "KRaft replaced ZooKeeper in modern Kafka."
- "Kafka is optimized for high-throughput distributed event streaming."
- "Kafka is not automatically the right choice for simple synchronous request/response."

---

# 15. Final Kafka Cheat Sheet

## One-Minute Kafka Explanation

```text
Kafka
 │
 ├── Cluster
 │     ├── Broker
 │     ├── Broker
 │     └── Broker
 │
 ├── Topic
 │     ├── Partition 0
 │     ├── Partition 1
 │     └── Partition 2
 │
 ├── Producer
 │     └── Writes events
 │
 ├── Consumer
 │     └── Reads events
 │
 ├── Consumer Group
 │     └── Shares partitions
 │
 ├── Offset
 │     └── Consumer position
 │
 ├── Replication
 │     └── Fault tolerance
 │
 └── KRaft
       └── Cluster metadata/controller architecture
```

## Kafka Flow

```text
Producer
   │
   ▼
Topic
   │
   ├── Partition 0 ──┐
   ├── Partition 1 ──┼──► Consumer Group
   └── Partition 2 ──┘
                         │
                         ▼
                     Processing
```

## Most Important Relationships

```text
Topic
  ↓
Partitions
  ↓
Parallelism
  ↓
Scalability
```

```text
Consumer Group
  ↓
Partition Assignment
  ↓
Load Sharing
```

```text
Replication
  ↓
ISR
  ↓
Fault Tolerance
```

```text
Offset
  ↓
Consumer Progress
  ↓
Replay / Recovery
```

```text
Key
  ↓
Partition
  ↓
Per-key Ordering
```

---

# Top 15 Questions to Memorize Before an Interview

1. What is Kafka?
2. Why does Kafka use partitions?
3. What is a topic?
4. What is an offset?
5. What is a consumer group?
6. How does Kafka guarantee ordering?
7. What happens when a broker fails?
8. What are ISR and replication factor?
9. Explain `acks=0`, `acks=1`, and `acks=all`.
10. What is consumer lag and how do you troubleshoot it?
11. What causes partition imbalance?
12. How do you achieve idempotent processing?
13. What is the difference between at-most-once, at-least-once, and exactly-once?
14. Kafka vs RabbitMQ — when would you choose each?
15. ZooKeeper vs KRaft — what changed?

---

# Ideal 60-Second Interview Answer

> "Apache Kafka is a distributed event-streaming platform built around durable, partitioned logs. Producers publish events to topics, and each topic is divided into partitions that provide scalability and parallelism. Kafka assigns offsets to records, allowing consumers to track their position and replay data.
>
> Consumers normally operate in consumer groups. Consumers within the same group share partitions for parallel processing, while different consumer groups can independently consume the same topic. Kafka replicates partitions across brokers for fault tolerance, with leaders and in-sync replicas handling replication and failover.
>
> Kafka is particularly useful for event-driven microservices, log aggregation, CDC, streaming analytics, and high-throughput asynchronous processing. Its major advantages are throughput, scalability, durability, replayability, and decoupling. Its trade-offs include operational complexity, partition-management challenges, consumer lag, and the fact that ordering is only guaranteed within a partition.
>
> Historically Kafka depended on ZooKeeper, but modern Kafka uses KRaft; Kafka 4.0 removed ZooKeeper mode. For reliability, I would think about replication factor, ISR, `acks`, `min.insync.replicas`, idempotent processing, consumer lag, and failure recovery."

---

# Final Mental Model

Think of Kafka as:

> **A distributed, replicated, partitioned, durable event log that lets many independent applications consume and replay streams of events at scale.**

If you remember only five things, remember:

```text
1. Topic = logical event stream

2. Partition = ordered unit of storage and parallelism

3. Consumer Group = consumers sharing the work

4. Offset = position in a partition

5. Replication = fault tolerance
```

And the most important interview rule:

> **Kafka's scalability comes from partitions; Kafka's consumer parallelism comes from partitions; Kafka's ordering guarantee is per partition.**