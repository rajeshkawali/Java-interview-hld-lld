# Apache Kafka Interview Questions & Answers

## 1. Most Frequently Asked Questions

### Question 1: What is Apache Kafka?

### Answer
Apache Kafka is a distributed event-streaming platform designed to publish, store, process, and consume streams of records at high throughput and low latency. It is commonly used for event-driven architectures, log aggregation, data integration, real-time analytics, and communication between microservices.

Kafka stores records durably in **topics**, which are divided into **partitions**. Producers write records to partitions, while consumers read them independently and track their position using offsets. Kafka's distributed architecture allows it to scale horizontally by adding brokers and partitions.

**Example:** An e-commerce system can publish `OrderCreated` events to Kafka. Inventory, payment, shipping, analytics, and notification services can consume the same event independently.

---

### Question 2: What are the main components of Kafka?

### Answer
The core concepts are:

| Component | Purpose |
|---|---|
| Producer | Publishes records to Kafka |
| Consumer | Reads records from Kafka |
| Topic | Logical stream/category of records |
| Partition | Ordered, append-only log within a topic |
| Broker | Kafka server that stores partitions |
| Consumer Group | Set of consumers sharing partition work |
| Offset | Position of a record within a partition |
| Replication | Copies partitions across brokers |
| Controller | Coordinates cluster-level metadata/operations |

A Kafka deployment is therefore a distributed collection of brokers. Producers and consumers communicate with brokers, while Kafka coordinates partition leadership and replication across the cluster.

---

### Question 3: What is a Kafka topic?

### Answer
A topic is a logical name used to categorize records. For example, `orders`, `payments`, and `customer-events` can be separate topics.

A topic is divided into one or more partitions. Kafka guarantees ordering **within a partition**, not across an entire multi-partition topic. Partitions are the primary mechanism for Kafka's horizontal scalability.

```text
orders topic
   |
   +-- Partition 0: O1 O4 O7 O10
   +-- Partition 1: O2 O5 O8 O11
   +-- Partition 2: O3 O6 O9 O12
```

---

### Question 4: What is a Kafka partition?

### Answer
A partition is an ordered, append-only sequence of records. Each record receives an offset that identifies its position in that partition.

Partitions enable parallelism. If a topic has 12 partitions, up to 12 consumers in one consumer group can actively process different partitions concurrently.

However, increasing partitions has operational consequences: more files, metadata, replication traffic, and potentially more consumer/broker overhead. Partition count should therefore be selected based on expected throughput, consumer parallelism, and future growth.

---

### Question 5: Does Kafka guarantee message ordering?

### Answer
Kafka guarantees ordering **within a single partition**. If records A, B, and C are written to the same partition, consumers read them in that order.

Kafka does not guarantee global ordering across multiple partitions.

**Practical solution:** If all events for a particular entity must remain ordered, use a stable key such as `customerId` or `orderId`.

```text
Producer
   |
key = order-123
   |
hash(order-123)
   |
Partition 4
   |
Created -> Paid -> Shipped
```

This works because records with the same key are normally mapped to the same partition, preserving per-key ordering.

---

### Question 6: What is a Kafka offset?

### Answer
An offset is the sequential position of a record within a partition. Consumers use offsets to remember how far they have processed a partition.

Offsets are scoped to a partition; offset `100` in partition 0 is unrelated to offset `100` in partition 1.

Consumer progress is commonly stored in Kafka's internal `__consumer_offsets` topic. A consumer can commit offsets automatically or explicitly.

---

### Question 7: What is a consumer group?

### Answer
A consumer group is a set of consumers that collectively consume a topic. Within one consumer group, a partition is assigned to only one active consumer at a time.

For example:

```text
Topic: orders
Partitions: P0 P1 P2 P3

Consumer Group A
  C1 -> P0, P1
  C2 -> P2
  C3 -> P3
```

If there are more consumers than partitions, some consumers remain idle. Therefore, maximum active consumer parallelism within a group is generally bounded by the number of partitions.

---

### Question 8: What happens when a Kafka consumer crashes?

### Answer
Kafka detects that the consumer has stopped participating in the group, typically through the consumer group's membership/liveness mechanism. The group coordinator triggers a rebalance and assigns the affected partitions to remaining consumers.

The amount of duplicate processing depends on when offsets were committed. If a consumer processes records but crashes before committing its offsets, another consumer may process those records again.

This is why consumers should generally be designed to tolerate duplicate delivery through idempotent processing or transactional patterns.

---

### Question 9: What is replication factor?

### Answer
Replication factor is the number of copies maintained for each partition. If a topic has replication factor 3, each partition has one leader replica and two follower replicas.

```text
Partition P0
  Broker 1: Leader
  Broker 2: Follower
  Broker 3: Follower
```

Replication improves fault tolerance. If the leader fails, Kafka can elect an eligible follower as the new leader.

A higher replication factor improves resilience but increases storage and network overhead.

---

### Question 10: What is ISR in Kafka?

### Answer
ISR means **In-Sync Replicas**. It is the set of replicas considered sufficiently caught up with the partition leader to participate in safe leadership decisions.

For a partition with replication factor 3:

```text
Leader: B1
Followers: B2, B3

ISR = {B1, B2, B3}
```

If B3 falls too far behind, it may leave the ISR. If `acks=all` is used, Kafka's durability behavior depends on the in-sync replica set and relevant broker/topic configuration.

---

### Question 11: What does `acks` mean for Kafka producers?

### Answer
`acks` controls how much acknowledgment the producer requires from Kafka.

| Setting | Meaning | Typical trade-off |
|---|---|---|
| `acks=0` | No broker acknowledgment required | Lowest latency, weakest delivery guarantee |
| `acks=1` | Leader acknowledges | Good balance, but leader failure can create durability risk depending on timing/configuration |
| `acks=all` | Required in-sync replicas acknowledge | Strongest durability-oriented option |

For important financial or business events, `acks=all` is commonly paired with appropriate replication and idempotence settings.

---

### Question 12: What is idempotent producer behavior?

### Answer
Producer idempotence prevents certain duplicate records caused by producer retries. Kafka assigns producer identity and sequencing information so the broker can recognize duplicate retry attempts.

A robust production configuration often combines idempotence with appropriate acknowledgments and retry behavior.

Idempotence does **not** automatically make an arbitrary downstream business operation idempotent. For example, consuming `ChargeCard` twice can still be dangerous unless the payment operation itself uses a unique transaction/event ID.

---

### Question 13: What is the difference between retention and deletion after consumption?

### Answer
Kafka does not normally delete a record merely because a consumer has read it. Records remain according to the topic's retention policy.

This is a fundamental difference from many traditional queue models. Multiple consumer groups can independently read the same historical data.

Common retention controls include time-based retention and size-based retention. Kafka can also use log compaction for topics where the latest value for each key should be retained.

---

### Question 14: What is log compaction?

### Answer
Log compaction retains the latest record for each key, subject to Kafka's compaction semantics and timing. It is useful for state topics such as customer profiles, account configurations, or entity snapshots.

Example:

```text
Before compaction:
customer-1 -> Bronze
customer-2 -> Gold
customer-1 -> Silver
customer-1 -> Platinum

After compaction:
customer-1 -> Platinum
customer-2 -> Gold
```

Compaction is not the same as immediate deletion. It is an asynchronous cleanup mechanism and should not be treated as a strict database update operation.

---

### Question 15: Kafka vs traditional message queues — what is different?

### Answer
Kafka is fundamentally a distributed append-only event log with durable retention and independent consumer positions. Traditional queue systems often emphasize message delivery and work distribution.

Kafka is especially strong when multiple independent consumers need the same event stream, when replay is valuable, and when high throughput is required.

Queues can be preferable for task-oriented workloads where per-message routing, acknowledgments, priorities, or request/work semantics are central.

---

## 2. Scenario-Based Questions & Answers

### Question 16: You need to process 1 million events per second. How would you design Kafka?

### Answer
Start by estimating the record size and throughput per partition rather than choosing an arbitrary partition count. Suppose each event is 1 KB and the target is 1 million events/sec:

```text
1,000,000 events/sec × 1 KB
≈ 1 GB/sec incoming payload
```

Then benchmark realistic producer, broker, replication, and consumer throughput. If a partition safely handles approximately 20 MB/sec for the workload, a rough initial estimate is:

```text
1,000 MB/sec ÷ 20 MB/sec ≈ 50 partitions
```

Replication factor, compression, network bandwidth, disk throughput, consumer processing rate, and headroom must then be included. A production design should also spread partitions and leaders across brokers and monitor broker network/disk saturation.

---

### Question 17: A consumer is processing slowly and consumer lag keeps increasing. How do you troubleshoot it?

### Answer
First confirm that the problem is actually consumer processing capacity rather than broker/network issues.

**Workflow:**

```text
Lag increasing
    |
    +--> Check consumer processing latency
    |
    +--> Check consumer CPU / memory / GC
    |
    +--> Check downstream DB/API latency
    |
    +--> Check partition count and assignment
    |
    +--> Check broker/network health
    |
    +--> Scale consumers or optimize processing
```

If the topic has 12 partitions and only 3 consumers, increasing the group to 12 consumers may increase parallelism. But if the downstream database is the bottleneck, adding consumers can make the system worse by increasing DB contention.

The key is to identify the bottleneck first, then scale the constrained stage.

---

### Question 18: A consumer processes a payment event twice. How would you prevent duplicate business effects?

### Answer
Assume:

```text
Kafka event: paymentId=PAY-123
Consumer processes payment
Consumer crashes before offset commit
Consumer restarts
PAY-123 is processed again
```

Do not rely solely on Kafka offsets to prevent duplicate business effects. Use an idempotency key such as `paymentId`, and enforce uniqueness in the downstream system.

For example, a database can maintain a processed-events table:

```text
processed_event
-------------------------
event_id     UNIQUE
PAY-123
```

The business transaction and event-id recording should be coordinated appropriately. For stronger Kafka-to-Kafka workflows, Kafka transactions can also be considered.

---

### Question 19: A broker goes down. What happens?

### Answer
If the failed broker hosts partition leaders, Kafka can elect eligible follower replicas as new leaders. Clients refresh metadata and redirect requests to the new leaders.

For example:

```text
Before:
P0 -> B1 Leader, B2 Follower, B3 Follower

B1 fails

After:
P0 -> B2 Leader, B3 Follower
```

The impact depends on replication factor, ISR health, election configuration, client behavior, and whether sufficient replicas remain available. A production cluster should be designed so a single broker failure does not cause unacceptable data loss or availability loss.

---

### Question 20: You must preserve order for each customer but process millions of customers concurrently. What design would you use?

### Answer
Use `customerId` as the Kafka record key.

```text
customer-101 -> hash -> Partition 2
customer-202 -> hash -> Partition 7
customer-101 -> hash -> Partition 2
```

All events for customer 101 therefore remain in the same partition, while different customers can be distributed across many partitions.

The trade-off is that a very hot customer can create a hot partition. If a single key becomes disproportionately large, key-based partitioning alone may not solve the hotspot.

---

### Question 21: How would you handle poison messages?

### Answer
A poison message repeatedly fails processing and can block progress if the consumer keeps retrying it synchronously.

A common workflow is:

```text
Kafka
  |
Consumer
  |
  +-- success --> commit offset
  |
  +-- transient failure --> retry
  |
  +-- repeated/permanent failure --> DLQ
```

A dead-letter topic can store the failed event plus metadata such as error type, stack trace, original topic, partition, offset, and retry count.

Do not blindly retry permanent validation errors forever. Distinguish transient failures (database temporarily unavailable) from permanent failures (invalid schema or malformed data).

---

### Question 22: How would you migrate a legacy application to Kafka without downtime?

### Answer
Use a phased migration rather than switching all traffic at once.

```text
Legacy producer
      |
      +----> Existing system
      |
      +----> Kafka
                 |
              New consumers
```

Start by producing equivalent events to Kafka while keeping the existing path active. Validate event counts, ordering, latency, and business outcomes. Gradually move consumers to Kafka and maintain rollback capability.

For databases, the **transactional outbox pattern** can reduce the risk of a database update succeeding while event publication fails.

---

### Question 23: Your Kafka consumers need to call a slow external API. How do you prevent Kafka from becoming a bottleneck?

### Answer
Avoid coupling Kafka consumption directly to an unbounded synchronous API call. Measure API latency and control concurrency.

Possible design:

```text
Kafka Consumer
      |
bounded worker pool
      |
External API
      |
result topic
```

Use bounded concurrency, timeouts, circuit breakers, retries with backoff, and rate limiting. The consumer should avoid processing so many messages concurrently that it causes API overload.

If strict per-key ordering is required, concurrency must be designed around partition/key boundaries rather than simply maximizing worker count.

---

## 3. Deeper Technical Questions

### Question 24: Explain Kafka's storage model.

### Answer
Kafka stores records in append-only partition logs. A partition is divided into log segments, allowing Kafka to roll segments and efficiently apply retention and compaction.

Kafka relies heavily on sequential I/O patterns, page cache, batching, and efficient network transfer. Consumers generally read records by offset rather than requiring a broker-side destructive dequeue.

This architecture enables high throughput while allowing consumers to replay historical records.

---

### Question 25: What is the difference between leader and follower replicas?

### Answer
Each partition has one leader replica responsible for serving normal client reads/writes for that partition. Followers replicate the leader's log.

```text
Producer
   |
   v
Leader
  / \
 v   v
F1   F2
```

If the leader fails, an eligible follower can become leader. Replication therefore provides fault tolerance while partition leadership distributes workload across brokers.

---

### Question 26: What causes consumer rebalances?

### Answer
A rebalance occurs when consumer-group membership or partition availability changes. Examples include adding/removing consumers, consumer failures, or relevant subscription/metadata changes.

Rebalances can temporarily interrupt processing. Frequent rebalances may indicate unstable consumers, insufficient processing time, poor timeout settings, or operational churn.

Modern Kafka deployments should use cooperative assignment strategies where appropriate and tune consumer behavior based on actual processing characteristics rather than simply increasing timeout values.

---

### Question 27: What is consumer lag?

### Answer
Consumer lag represents how far a consumer group's committed/processed position is behind the latest available data.

Conceptually:

```text
Latest offset:       1,000,000
Consumer position:     980,000
Approximate lag:        20,000
```

Lag should be analyzed per partition and over time. A large lag number alone does not necessarily mean an outage; the important questions are whether lag is growing, how quickly it is growing, and whether the consumer can catch up.

---

### Question 28: How can Kafka throughput be improved?

### Answer
Typical levers include:

- Increase partition parallelism where justified.
- Batch producer records.
- Use compression.
- Tune producer batching and linger settings.
- Avoid unnecessary synchronous calls.
- Increase consumer parallelism up to available partitions.
- Optimize serialization/deserialization.
- Ensure brokers have adequate network, CPU, memory, and storage.
- Avoid oversized messages.

For example, sending many tiny requests individually can waste network and protocol overhead. Batching several records into larger requests can substantially improve throughput, at the cost of some additional latency.

---

### Question 29: What is the trade-off between latency and throughput?

### Answer
Higher batching generally improves throughput because fewer requests and larger sequential operations are needed. However, waiting to accumulate a batch can increase latency.

```text
Small batches
  -> lower waiting time
  -> potentially lower throughput

Large batches
  -> better throughput
  -> potentially higher latency
```

The correct configuration depends on workload. Payment authorization might prioritize latency, while analytics ingestion may prioritize throughput.

---

### Question 30: What happens if a consumer commits an offset before processing the message?

### Answer
If the consumer commits first and crashes before processing, the message may be skipped after restart. This resembles **at-most-once** processing behavior.

If it processes first and commits afterward, a crash between processing and commit can cause duplicate processing. This resembles **at-least-once** behavior.

```text
Process -> Commit
   |
 crash here
   |
duplicate possible

Commit -> Process
   |
 crash here
   |
message may be skipped
```

Exactly-once effects require careful end-to-end design; Kafka's guarantees do not automatically make external side effects exactly once.

---

### Question 31: How does Kafka achieve exactly-once processing?

### Answer
Kafka supports transactions and idempotent producer mechanisms that can provide exactly-once semantics for supported Kafka-to-Kafka processing pipelines when correctly configured.

A typical transactional flow is:

```text
Read input records
       |
Process
       |
Produce output records
       |
Commit transaction + offsets atomically
```

The critical limitation is external systems. Writing to an arbitrary database or calling an external API cannot automatically become exactly once merely because Kafka transactions are enabled. End-to-end correctness requires an appropriate transaction or idempotency strategy.

---

### Question 32: What is the difference between `at-most-once`, `at-least-once`, and exactly-once?

### Answer

| Semantics | Possible loss | Possible duplicate | Typical approach |
|---|---:|---:|---|
| At-most-once | Yes | No | Commit before processing |
| At-least-once | No, assuming durable successful processing | Yes | Process then commit |
| Exactly-once | Designed to avoid duplicates within supported transactional boundaries | Minimized/controlled | Transactions + idempotent processing |

In interviews, emphasize that **exactly-once is a system-level property**, not simply a Kafka checkbox. External side effects need their own correctness mechanism.

---

### Question 33: What are hot partitions?

### Answer
A hot partition receives substantially more traffic than others. This often happens when partitioning is based on a highly skewed key.

Example:

```text
P0 -> 80% traffic
P1 -> 5%
P2 -> 5%
P3 -> 5%
P4 -> 5%
```

Adding more partitions may not help if the same hot key continues mapping to one partition. Possible solutions include better key distribution, workload-specific partitioning, splitting a hot entity, or redesigning processing semantics if strict ordering is not required.

---

### Question 34: How should Kafka handle schema evolution?

### Answer
Events should use explicit, versioned schemas rather than relying on undocumented JSON structure. Schema compatibility rules should be defined so producers and consumers can evolve independently.

A common approach is to use Avro, Protobuf, or JSON Schema together with a schema registry. Compatibility modes help prevent changes that would break existing consumers.

For example, adding an optional field with a compatible default is generally safer than renaming or changing the meaning of an existing field.

---

## 4. Kafka vs RabbitMQ

### Question 35: Kafka vs RabbitMQ — what is the difference?

### Answer

| Area | Kafka | RabbitMQ |
|---|---|---|
| Primary abstraction | Distributed event log | Message broker |
| Retention | Durable configurable retention | Commonly queue-oriented |
| Replay | Strong/native use case | Not the primary model |
| Ordering | Per partition | Queue ordering with caveats |
| Throughput | Excellent for high-volume streams | Excellent for messaging workloads |
| Routing | Topic/partition/key model | Rich exchanges/routing |
| Consumer model | Pull/fetch-oriented | Push-oriented delivery common |
| Best fit | Event streaming, analytics, event-driven platforms | Task queues, routing, command/work messaging |

Neither is universally better. Kafka is often preferred when many consumers need independent replayable streams. RabbitMQ is often attractive when sophisticated message routing and task delivery are central requirements.

---

### Question 36: When would you choose RabbitMQ over Kafka?

### Answer
Choose RabbitMQ when the workload is primarily message/task-oriented and requires rich routing semantics such as exchanges, routing keys, or request/work distribution.

For example, an application may need to route jobs by priority or business category to specialized workers. RabbitMQ can be a natural fit for that pattern.

Kafka is often the stronger choice when the same durable event must be consumed by many independent applications and replayed later.

---

### Question 37: Can Kafka replace RabbitMQ?

### Answer
Sometimes, but not automatically. Kafka can implement many asynchronous communication patterns, but its architecture and operational model differ.

If the main requirement is a high-volume event backbone with replay and multiple independent consumer groups, Kafka is compelling. If the core requirement is flexible broker-side routing and task delivery semantics, RabbitMQ may be simpler and more natural.

The correct decision should be driven by delivery semantics, routing, throughput, replay, latency, operational expertise, and workload shape.

---

## 5. Kafka vs Other Technologies

### Kafka vs Database

| Kafka | Database |
|---|---|
| Event stream/log | Current state/query system |
| Excellent for asynchronous pipelines | Excellent for transactional queries |
| Replayable history within retention | Rich querying/indexing |
| High streaming throughput | Strong relational constraints/transactions |

Kafka should generally not be treated as a direct replacement for a relational database.

### Kafka vs Redis Streams

Redis Streams can provide stream-like messaging with very low latency and integration with Redis data structures. Kafka is generally stronger for large durable event-streaming platforms, long retention, extensive partition-based scaling, and large multi-consumer ecosystems.

### Kafka vs Amazon SQS

SQS is a managed cloud queue service with simple operational characteristics. Kafka provides richer streaming/log semantics, partitions, replay, and Kafka-native ecosystem capabilities. SQS can be preferable when the requirement is simply reliable managed asynchronous work distribution in AWS.

---

## 6. Advanced Scenario Questions

### Question 38: Design an order-processing architecture using Kafka.

### Answer

```text
                    +----------------+
                    | Order Service  |
                    +-------+--------+
                            |
                            v
                    +---------------+
                    | orders topic  |
                    +---------------+
                      /     |      \
                     v      v       v
                Inventory Payment  Analytics
                   |        |
                   v        v
             inventory   payment-events
```

Use `orderId` as the key if order-level ordering is required. Give the topic enough partitions to support expected consumer parallelism and throughput.

For reliability, use replication, appropriate producer acknowledgments, idempotent producer behavior, durable consumer processing, retries with backoff, and dead-letter handling for unrecoverable events. If an order database update and event publication must be atomic, consider an outbox-based design.

---

### Question 39: How would you recover after a consumer accidentally commits the wrong offsets?

### Answer
First stop or isolate the affected consumer group if continuing consumption could worsen the situation. Determine the intended offsets from monitoring, application logs, timestamps, or another trusted source.

Then reset offsets carefully to the required position, often using timestamp- or offset-based reset procedures. Reprocessing requires downstream idempotency because the same events may be processed again.

Always validate the reset in a controlled environment and understand whether downstream side effects are reversible before replaying production data.

---

### Question 40: Kafka has high latency even though CPU is low. What do you investigate?

### Answer
Low CPU does not imply Kafka is healthy. Investigate:

1. Network latency/bandwidth.
2. Disk latency and I/O saturation.
3. Broker request queues.
4. Producer batching/linger configuration.
5. Consumer fetch behavior.
6. Replication lag.
7. Garbage collection.
8. Controller/metadata activity.
9. Partition leadership distribution.
10. Downstream consumer processing.

Also distinguish **producer-to-broker latency**, **broker processing latency**, and **end-to-end business latency**. Measuring only one metric can hide the actual bottleneck.

---

## 7. Interview Quick Reference

### Key Terms

| Term | One-line explanation |
|---|---|
| Broker | Kafka server |
| Topic | Logical event stream |
| Partition | Ordered append-only log |
| Offset | Record position |
| Producer | Writes records |
| Consumer | Reads records |
| Consumer Group | Parallel consumer membership |
| Leader | Replica serving normal partition requests |
| Follower | Replica copying the leader |
| ISR | In-sync replicas |
| Replication Factor | Number of partition copies |
| Lag | Consumer's distance behind latest data |
| Retention | How long/large data is retained |
| Compaction | Keeps latest state per key |
| Rebalance | Redistribution of group partitions |

---

## 8. Interview Tips

### Tip 1: Start with the core model

When asked almost any Kafka question, anchor your explanation around:

> **Producer → Topic → Partition → Broker → Consumer Group → Offset**

This immediately demonstrates that you understand Kafka's architecture rather than memorizing isolated configuration properties.

### Tip 2: Always mention partition-level ordering

A common interview mistake is saying "Kafka guarantees ordering." The precise answer is:

> **Kafka guarantees ordering within a partition, not across partitions.**

Then explain how a message key can preserve ordering for a business entity.

### Tip 3: Explain trade-offs

Strong candidates do not merely say "increase partitions" or "use `acks=all`." Explain the consequence.

For example:

> "Increasing partitions increases consumer parallelism, but also increases metadata, storage, replication, and operational overhead."

### Tip 4: Distinguish Kafka guarantees from application guarantees

A particularly strong interview statement is:

> "Kafka can provide at-least-once delivery and transactional semantics within supported Kafka boundaries, but exactly-once business effects require end-to-end idempotency or transactional design."

### Tip 5: For troubleshooting, use a structured workflow

Use:

```text
Observe
  ↓
Measure
  ↓
Identify bottleneck
  ↓
Change one major variable
  ↓
Load/test
  ↓
Validate
  ↓
Monitor
```

Avoid jumping directly to configuration changes without evidence.

### Tip 6: Know these common pitfalls

- Saying Kafka deletes a message immediately after consumption.
- Claiming global ordering.
- Assuming more consumers always improve performance.
- Treating replication factor as the same thing as durability configuration.
- Assuming Kafka automatically makes external database/API operations exactly once.
- Ignoring hot partitions.
- Using unlimited retries for poison messages.
- Treating consumer lag as an automatically bad metric.
- Increasing partitions without considering key distribution.
- Ignoring schema compatibility.

### Tip 7: High-value phrases to use

Interviewers often respond well when you naturally use phrases such as:

- **"Ordering is guaranteed at the partition level."**
- **"Let's identify the bottleneck before scaling."**
- **"This is an at-least-once processing scenario, so duplicate handling matters."**
- **"The partition key determines distribution and therefore affects ordering and load balance."**
- **"We need to distinguish Kafka-level guarantees from end-to-end business semantics."**
- **"I'd use metrics to validate the hypothesis before changing configuration."**
- **"The trade-off here is latency versus throughput."**
- **"We should design for replay and idempotency."**

---

# Final 30-Second Kafka Answer

If an interviewer asks **"Explain Kafka"**, a concise answer is:

> "Apache Kafka is a distributed event-streaming platform built around durable, partitioned logs. Producers publish records to topics, topics are divided into partitions for scalability and ordering, and consumers read those partitions through consumer groups. Kafka replicates partitions across brokers for fault tolerance and retains records independently of consumer consumption, which enables replay. Its main strengths are high throughput, horizontal scalability, durable event storage, and multiple independent consumers. In production, I pay particular attention to partition-key design, replication, producer acknowledgments, idempotency, consumer lag, rebalancing, schema evolution, and failure handling."

