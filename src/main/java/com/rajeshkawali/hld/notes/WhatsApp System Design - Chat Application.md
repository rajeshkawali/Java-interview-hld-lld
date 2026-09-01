# WhatsApp System Design — Chat Application

## 1. Problem Statement

Design a chat application like WhatsApp that supports:

- 1-to-1 messaging
- Group messaging
- Online/offline users
- Message delivery
- Read receipts
- Typing indicators
- Push notifications
- Message history
- Media sharing
- High availability
- Millions/billions of messages

---

# 2. Functional Requirements

### Core Features

1. User registration/login
2. Send message
3. Receive message
4. 1-to-1 chat
5. Group chat
6. Message history
7. Delivery status
8. Read status
9. Online/offline status
10. Typing indicator
11. Push notifications
12. Image/video/file sharing

---

# 3. Non-Functional Requirements

We need:

- Low latency
- High availability
- High scalability
- Durable message storage
- Fault tolerance
- Horizontal scaling
- Eventually consistent presence/read states where acceptable
- Strong ordering guarantees within a conversation where required

Example:

```text
User A → User B

Message should normally arrive within milliseconds/seconds,
depending on network conditions.
```

---

# 4. High-Level Architecture

```text
                    ┌──────────────┐
                    │ Mobile Client│
                    └──────┬───────┘
                           │
                    WebSocket / HTTPS
                           │
                           ↓
                 ┌──────────────────┐
                 │ Load Balancer    │
                 └────────┬─────────┘
                          ↓
              ┌───────────────────────┐
              │ Chat Gateway Servers  │
              │ WebSocket Connections│
              └───────────┬───────────┘
                          │
                          ↓
                  ┌──────────────┐
                  │ Message      │
                  │ Service      │
                  └──────┬───────┘
                         │
             ┌───────────┼────────────┐
             ↓           ↓            ↓
        Message DB    Message Queue   Presence
             │           │            │
             │           ↓            │
             │     Notification       │
             │        Service         │
             │           │             │
             │           ↓             │
             │        APNs/FCM        │
             │                         │
             ↓                         ↓
        Message History           Online/Offline
```

---

# 5. Why WebSocket?

For real-time chat, we don't want the client to continuously ask:

```text
Client → "Any new message?"
Client → "Any new message?"
Client → "Any new message?"
```

This is polling.

Instead, use a persistent connection:

```text
Client
   │
   │ WebSocket
   │
   ↓
Chat Server
```

The server can push a new message immediately.

### Benefits

- Real-time communication
- Low latency
- Avoids repeated polling
- Bidirectional communication

### Alternative

HTTP long polling can be used, but WebSocket is generally a better fit for persistent bidirectional chat connections.

---

# 6. User Connection Flow

Suppose:

```text
Alice → WhatsApp
```

Alice opens the application.

```text
Alice
  ↓
Load Balancer
  ↓
Chat Gateway
  ↓
WebSocket connection
```

The server maintains:

```text
userId → connection/server
```

Example:

```text
Alice → Gateway-10
Bob   → Gateway-25
```

This helps route messages toward the server holding the recipient's active connection.

---

# 7. Sending a Message

Suppose:

```text
Alice → Hello → Bob
```

Flow:

```text
Alice
 ↓
WebSocket
 ↓
Chat Gateway
 ↓
Message Service
 ↓
Validate message
 ↓
Generate messageId
 ↓
Persist message
 ↓
Publish event
 ↓
Find Bob's connection
 ↓
Send to Bob
```

---

# 8. Message ID

Every message needs a unique ID.

Example:

```text
messageId = 8f7c-1234-....
```

Requirements:

- Globally unique
- Efficient to generate
- Can be generated without a single centralized bottleneck

Possible approaches:

### Option 1 — UUID

```text
UUID
```

### Advantages

- Simple
- Globally unique

### Disadvantages

- Relatively large
- Random IDs can be less storage/index friendly depending on database/index design

---

### Option 2 — Snowflake-style ID

```text
timestamp + machineId + sequence
```

Example:

```text
Timestamp | Worker ID | Sequence
```

### Advantages

- Globally unique
- Roughly time sortable
- Compact compared with some UUID representations

### Disadvantage

- More complex
- Requires worker/time coordination and clock considerations

---

# 9. Message Database

A chat system generates enormous amounts of messages.

A distributed NoSQL database is often a good choice for the message store because the workload can be:

- Very large
- Write-heavy
- Distributed
- Partitionable
- Mostly key/range based

Possible choices:

```text
Cassandra
DynamoDB
ScyllaDB
```

The exact choice depends on requirements and operational environment.

---

# 10. Message Data Model

Example:

```text
Messages

conversationId
messageId
senderId
receiverId
message
timestamp
messageType
status
```

Example:

```text
conversationId = C123
messageId      = M1001
senderId       = Alice
receiverId     = Bob
message        = "Hello"
timestamp      = T1
status         = SENT
```

---

# 11. Important Partition-Key Decision

For a chat system, we frequently need:

```text
Get all messages for conversation C123
ordered by time
```

Therefore, a possible data model is:

```text
Partition Key = conversationId

Sort Key = message timestamp/message sequence
```

Example:

```text
Conversation C123
│
├── M1
├── M2
├── M3
├── M4
└── M5
```

This makes conversation-history queries efficient.

### Problem

A very large or extremely active conversation can become a hot partition depending on the database and data model.

### Solution

Use a time bucket or another carefully designed sharding strategy when required.

Example:

```text
conversationId + day

C123#2026-08-31
C123#2026-09-01
C123#2026-09-02
```

---

# 12. Message Ordering

Ordering is extremely important.

Suppose Alice sends:

```text
M1 = "Hello"
M2 = "How are you?"
M3 = "Good morning"
```

Bob should normally see:

```text
M1
M2
M3
```

not:

```text
M2
M1
M3
```

### How?

Use a conversation-level sequence number.

```text
conversationId = C123

M1 → sequence 100
M2 → sequence 101
M3 → sequence 102
```

The client can use the sequence number to detect missing/out-of-order messages.

### Important Interview Point

Don't claim that global ordering is required.

Usually:

> **We need ordering within a conversation, not across the entire WhatsApp system.**

Global ordering would be unnecessarily expensive.

---

# 13. Message Delivery States

A message can have states:

```text
SENT
  ↓
DELIVERED
  ↓
READ
```

Example:

```text
Alice sends:
"Hello"

        ✓
       SENT

        ↓

       ✓✓
    DELIVERED

        ↓

       ✓✓
      blue
      READ
```

The exact UI differs, but the backend concept is similar.

---

# 14. Sent Status

Alice sends:

```text
Hello
```

The server accepts and durably records the message.

Then:

```text
Server → Alice

SENT
```

Meaning:

> The message has been accepted by the messaging system.

---

# 15. Delivered Status

Bob's device receives the message.

Bob's client sends an acknowledgement:

```text
Bob → Server

ACK(messageId)
```

Server updates the delivery state.

```text
Alice ← DELIVERED
```

---

# 16. Read Status

Bob opens the conversation.

Bob sends:

```text
READ(messageId)
```

Server records the read state and notifies Alice.

```text
Alice → READ
```

---

# 17. What Happens If Bob Is Offline?

Suppose:

```text
Alice → Bob
```

but:

```text
Bob = OFFLINE
```

The message should still be persisted.

```text
Alice
 ↓
Message Service
 ↓
Message DB
 ↓
Bob offline
```

When Bob comes online:

```text
Bob
 ↓
WebSocket
 ↓
Chat Gateway
 ↓
Message Service
 ↓
Fetch pending messages
 ↓
Bob
```

---

# 18. Push Notifications

If Bob is offline, we generally don't maintain an active WebSocket connection to his device.

Instead:

```text
Message Service
      ↓
Notification Service
      ↓
FCM / APNs
      ↓
Bob's phone
```

FCM:

```text
Android
```

APNs:

```text
iOS
```

Push notification example:

```text
"You have a new message"
```

The message content included in the notification depends on privacy/settings and platform behavior.

---

# 19. Online / Offline Status

We need a Presence Service.

Example:

```text
Alice → ONLINE
Bob   → OFFLINE
John  → ONLINE
```

A fast key-value store can be useful:

```text
userId → presence information
```

Example:

```text
Alice → ONLINE
Bob   → OFFLINE
```

Presence is usually highly dynamic and can tolerate some eventual consistency.

---

# 20. Heartbeat

How does the system know a user is online?

Client periodically sends:

```text
PING
```

Server responds:

```text
PONG
```

or the WebSocket protocol/application can maintain equivalent liveness signals.

If heartbeat stops for a configured timeout:

```text
ONLINE
   ↓
No heartbeat
   ↓
OFFLINE
```

---

# 21. Typing Indicator

When Alice types:

```text
Alice → typing
```

The server can send a lightweight ephemeral event:

```text
Alice is typing...
```

to Bob.

Important:

> Typing events usually should **not** be persisted like normal messages.

Why?

Because they are temporary state.

```text
Typing = ephemeral
Message = durable
```

---

# 22. Group Chat

Suppose:

```text
Group = G1

Members:
Alice
Bob
Charlie
David
```

Alice sends:

```text
"Hello everyone"
```

The system needs to deliver the message to all relevant members.

---

# 23. Group Message Fanout

Two common approaches:

## Fanout-on-write

When Alice sends:

```text
Hello
```

we distribute the message to each member.

```text
              Message
                 ↓
       ┌─────────┼─────────┐
       ↓         ↓         ↓
      Bob     Charlie    David
```

### Advantages

- Fast reads
- Easy to retrieve per-user pending messages

### Disadvantages

- Expensive for huge groups
- One message creates many write operations

---

## Fanout-on-read

Store the message once:

```text
Group G1
   ↓
Message M1
```

Members read the group's messages when opening the chat.

### Advantages

- Fewer writes
- Better for large groups

### Disadvantages

- Reads can become more expensive
- More work when generating the user's view

---

# 24. Hybrid Group Strategy

A practical system can use a hybrid approach.

For normal groups:

```text
Fanout-on-write
```

For very large groups:

```text
Fanout-on-read
```

### Interview Point

> Choose fanout strategy based on group size, activity, and read/write workload.

---

# 25. Media Upload

Don't store large videos/images directly inside the message database.

Instead:

```text
Client
 ↓
Media Service
 ↓
Object Storage
 ↓
Media URL / object ID
```

Example:

```text
Message:

{
  "type": "IMAGE",
  "mediaId": "IMG123"
}
```

Actual image:

```text
Object Storage
```

Possible object storage:

```text
Amazon S3
```

The exact service can vary.

---

# 26. Why Object Storage?

Object storage is designed for large files.

Use it for:

- Images
- Videos
- Documents
- Audio

Database stores metadata:

```text
messageId
mediaId
senderId
timestamp
```

---

# 27. Message Queue

A message queue/event stream can decouple services.

```text
Message Service
      ↓
   Queue
      ↓
Consumers
```

Possible technologies:

```text
Kafka
Pulsar
RabbitMQ
SQS
```

depending on the use case.

### Uses

- Message processing
- Notifications
- Analytics
- Retry handling
- Async fanout

---

# 28. Why Use a Queue?

Without a queue:

```text
Message
 ↓
Notification
 ↓
Analytics
 ↓
Fanout
 ↓
...
```

The sender request can become slow.

With a queue:

```text
Message
 ↓
Persist
 ↓
Publish event
 ↓
Return quickly
```

Consumers process work asynchronously.

### Advantage

- Decoupling
- Better resilience
- Handles traffic spikes
- Retry support

---

# 29. Offline Message Delivery

Suppose:

```text
Alice sends 10 messages
Bob is offline
```

Messages are stored:

```text
M1
M2
M3
...
M10
```

Bob reconnects:

```text
Bob
 ↓
WebSocket
 ↓
Sync Service
 ↓
Get messages after lastAckedSequence
 ↓
M1...M10
```

Bob acknowledges them.

```text
lastAckedSequence = 10
```

---

# 30. Avoiding Duplicate Messages

Distributed systems can retry requests.

Example:

```text
Client sends M1
 ↓
Network timeout
 ↓
Client retries
```

Without protection:

```text
M1
M1
```

### Solution: Idempotency

Client generates a unique:

```text
clientMessageId
```

Server stores it.

If the same request arrives again:

```text
clientMessageId = ABC123
```

server recognizes it as a duplicate.

```text
Already processed
 ↓
Return existing result
```

### Recall

> **Retries + unique message ID = idempotent message sending.**

---

# 31. Exactly Once Delivery

Be careful in interviews.

In distributed systems, true end-to-end exactly-once delivery is difficult.

A better design is usually:

```text
At-least-once delivery
+
Idempotent processing
+
Deduplication
```

This gives users an effectively-once experience.

---

# 32. Load Balancer

We may have millions of persistent connections.

```text
                Load Balancer
               /      |      \
              ↓       ↓       ↓
          Gateway1 Gateway2 Gateway3
```

The load balancer distributes new connections across gateway servers.

### Important

For WebSockets, the connection remains attached to one gateway while active.

The messaging system still needs a way to determine where the recipient's active connection lives.

---

# 33. Connection Registry

Maintain:

```text
userId → gatewayId/device connection
```

Example:

```text
Alice → Gateway 1
Bob   → Gateway 7
John  → Gateway 3
```

This can be stored in a distributed in-memory/fast key-value system.

But this mapping is **ephemeral state**.

If Gateway 7 dies:

```text
Bob reconnects
 ↓
New gateway
 ↓
Registry updated
```

---

# 34. Multiple Devices

Modern chat applications support multiple devices.

Example:

```text
Bob
 ├── Phone
 ├── Tablet
 └── Web
```

Therefore:

```text
userId → multiple active device connections
```

Example:

```text
Bob
 ├── Phone → Gateway 1
 ├── Tablet → Gateway 4
 └── Web → Gateway 8
```

The system may need to synchronize message state across devices.

---

# 35. Message Synchronization

Each device can maintain a synchronization position.

Example:

```text
Device A → lastSequence = 100
Device B → lastSequence = 95
```

Device B reconnects:

```text
Sync messages
where sequence > 95
```

This is much better than downloading the entire conversation again.

---

# 36. Caching

Use caching for frequently accessed data.

Possible cached data:

```text
User profile
Conversation metadata
Presence
Recent messages
```

Example:

```text
Client
 ↓
Cache
 ↓ cache miss
Database
```

### Important

Don't blindly cache everything.

Chat messages are durable data and need a clear consistency/invalidation strategy.

---

# 37. Database Choices

A possible architecture:

```text
Users
  ↓
SQL / NoSQL

Messages
  ↓
Distributed NoSQL

Presence
  ↓
Redis / Key-Value

Media
  ↓
Object Storage

Events
  ↓
Kafka / Queue
```

The exact technology depends on scale and requirements.

---

# 38. Why SQL for Users?

User/account data can have relationships and transactional requirements.

Example:

```text
Users
Devices
Contacts
Settings
```

SQL can be a good fit.

But a large production system can also use distributed NoSQL for selected user/profile workloads.

### Interview Rule

> Don't select a database only because it is popular. Select it based on access patterns and requirements.

---

# 39. Why NoSQL for Messages?

Message workloads can be:

```text
Huge data
High write throughput
Distributed
Time ordered
Partitionable
```

A distributed NoSQL database can fit this access pattern well.

Example query:

```text
Get messages for conversation C123
after sequence 100
```

This is a predictable key/range access pattern.

---

# 40. Message Retention

Messages may be stored for a long period.

But media and messages have different storage characteristics.

Possible strategy:

```text
Hot data
 ↓
Fast database

Old data
 ↓
Cold/archive storage
```

This reduces cost at very large scale.

---

# 41. Encryption

A production chat application should consider encryption.

### In transit

```text
Client
 ↓ HTTPS / TLS
Server
```

### At rest

Encrypt stored data.

### End-to-end encryption

For applications requiring E2EE:

```text
Alice
  ↓ encrypted message
Server
  ↓ encrypted message
Bob
```

The server should not need plaintext message content.

### Important Interview Point

E2EE significantly changes system design:

- Key management
- Device registration
- Key rotation
- Multi-device synchronization
- Group encryption
- Backup/recovery

---

# 42. High Availability

Avoid a single point of failure.

Bad:

```text
        One Chat Server
             ↓
        Entire system
```

Better:

```text
       Load Balancer
       /     |     \
      ↓      ↓      ↓
     S1     S2     S3
```

Database:

```text
Primary / replicas
or
Distributed replicated database
```

Use multiple availability zones/data centers where appropriate.

---

# 43. Failure Handling

### Chat Gateway failure

```text
Gateway dies
 ↓
Client reconnects
 ↓
New Gateway
 ↓
Restore connection
```

Messages are not lost because durable messages are stored separately from the WebSocket connection.

---

### Message Service failure

Use:

- Multiple instances
- Load balancing
- Queue retries
- Idempotency
- Replicated storage

---

### Database failure

Use:

- Replication
- Automatic failover where supported
- Backups
- Disaster recovery

---

# 44. Retry Strategy

Temporary failures should be retried.

Example:

```text
Request
 ↓
Failure
 ↓
Retry after 100ms
 ↓
Failure
 ↓
Retry after 500ms
 ↓
Retry after 1s
```

Use:

```text
Exponential Backoff
+
Jitter
```

Avoid unlimited retries.

---

# 45. Dead Letter Queue

If a message repeatedly fails processing:

```text
Queue
 ↓
Retry
 ↓
Retry
 ↓
Retry
 ↓
DLQ
```

DLQ = Dead Letter Queue.

It allows engineers to inspect and recover failed messages later.

---

# 46. Rate Limiting

Protect the system from abuse.

Example:

```text
User → 1 million messages/sec
```

This could overload the service.

Use rate limiting:

```text
User
 ↓
Rate Limiter
 ↓
Allowed?
 ├── YES → Process
 └── NO  → Reject/Delay
```

Limits can be applied per:

- User
- Device
- IP
- API
- Conversation

---

# 47. API Design

### Send Message

```http
POST /messages
```

Request:

```json
{
  "conversationId": "C123",
  "clientMessageId": "ABC123",
  "text": "Hello"
}
```

Response:

```json
{
  "messageId": "M1001",
  "status": "SENT"
}
```

---

### Get Messages

```http
GET /conversations/C123/messages?after=100
```

Returns messages after sequence 100.

---

### Mark as Read

```http
POST /messages/M1001/read
```

---

### Presence

```http
GET /users/123/presence
```

Presence updates may be better delivered through the persistent connection rather than frequent REST polling.

---

# 48. Complete Message Flow

```text
                 ALICE
                   |
                   | WebSocket
                   ↓
             Load Balancer
                   |
                   ↓
             Chat Gateway
                   |
                   ↓
             Message Service
                   |
          ┌────────┴─────────┐
          ↓                  ↓
     Message DB            Queue
                              |
                     ┌────────┴─────────┐
                     ↓                  ↓
               Notification        Analytics
                  Service
                     |
                     ↓
                  FCM/APNs
                     |
                     ↓
                    BOB
```

If Bob is online:

```text
Message Service
      ↓
Connection Registry
      ↓
Bob's Gateway
      ↓
Bob
```

If Bob is offline:

```text
Message Service
      ↓
Message DB
      ↓
Notification Service
      ↓
FCM/APNs
      ↓
Bob's Device
```

---

# 49. Scaling the System

Suppose:

```text
10 million concurrent users
```

Don't use:

```text
1 Chat Server
```

Instead:

```text
                Load Balancer
                /    |    \
               ↓     ↓     ↓
             G1     G2     G3
             ↓      ↓      ↓
            ...    ...    ...
          Hundreds/Thousands
            of gateways
```

Services are horizontally scalable.

```text
Message Service
     ↓
M1 M2 M3 M4 M5
```

Database:

```text
Shard 1
Shard 2
Shard 3
Shard 4
...
```

---

# 50. Back-of-the-Envelope Estimation

Assume:

```text
100M daily active users

Average 20 messages/user/day
```

Messages per day:

```text
100M × 20
= 2 billion messages/day
```

Average messages/sec:

```text
2B / 86,400
≈ 23,148 messages/sec
```

Assume peak traffic is 5× average:

```text
≈ 116K messages/sec
```

This tells us the architecture needs to support **tens of thousands of messages/sec on average and potentially 100K+ messages/sec at peak** for this hypothetical workload.

Always state assumptions in an interview.

---

# 51. Main Bottlenecks

Potential bottlenecks:

```text
1. WebSocket connections
2. Message database
3. Hot conversations
4. Group fanout
5. Presence updates
6. Push notification service
7. Media storage
8. Network bandwidth
9. Queue lag
```

---

# 52. How to Solve Bottlenecks

### WebSocket connections

```text
More Gateway Servers
```

### Database

```text
Partitioning
+
Replication
+
Horizontal scaling
```

### Hot conversations

```text
Time bucketing
+
Partition strategy
```

### Group fanout

```text
Hybrid fanout
+
Async queue
```

### Presence

```text
Distributed cache
+
Heartbeat
+
TTL
```

### Media

```text
Object Storage
+
CDN
```

---

# 53. CDN for Media

For popular media:

```text
User
 ↓
CDN
 ↓
Object Storage
```

Instead of every request hitting object storage directly.

### Benefits

- Lower latency
- Reduced origin load
- Better global performance

---

# 54. Security Considerations

Need to protect:

- Authentication
- Authorization
- User privacy
- Message data
- Media
- APIs
- WebSocket connections
- Abuse/spam

Use:

```text
TLS
Authentication tokens
Authorization
Rate limiting
Encryption
Input validation
Audit/security monitoring
```

---

# 55. Important Trade-offs

## WebSocket vs Polling

### WebSocket

Advantages:

- Real-time
- Low latency
- Bidirectional

Disadvantages:

- Persistent connection management
- More infrastructure complexity

---

## SQL vs NoSQL

### SQL

Advantages:

- Strong relational model
- Rich queries
- Mature transactions

Disadvantages:

- Horizontal scaling can become complex at extreme scale

### NoSQL

Advantages:

- Horizontal scaling
- High throughput
- Flexible/distributed data models

Disadvantages:

- Query/access-pattern constraints
- Denormalization
- Consistency/trade-off complexity

---

# 56. Most Important Interview Questions

### Q1. Why WebSocket?

> To maintain a persistent bidirectional connection so the server can push messages to clients with low latency.

### Q2. What happens when the user is offline?

> Persist the message in durable storage and use a push notification mechanism to notify the device. When the user reconnects, synchronize messages from the last acknowledged position.

### Q3. How do you guarantee message ordering?

> Use a conversation-level sequence number or ordering mechanism and have clients detect/reconcile missing or out-of-order messages.

### Q4. How do you prevent duplicate messages?

> Use unique client/server message IDs and idempotent processing so retries don't create duplicate messages.

### Q5. How do you scale WebSocket connections?

> Horizontally scale gateway servers behind load balancing and maintain a distributed connection registry mapping users/devices to active gateway connections.

### Q6. How do you scale message storage?

> Partition messages by conversation/user/access pattern and replicate data for availability.

### Q7. How do you handle large groups?

> Use asynchronous fanout and potentially hybrid fanout strategies; avoid synchronously writing to every member during the sender's request.

### Q8. Where do you store images/videos?

> Object storage, not the main message database. Store only metadata/reference IDs with the message.

### Q9. How do you handle presence?

> Use a distributed low-latency store with heartbeats and TTLs. Presence can generally tolerate eventual consistency.

### Q10. What happens if a chat server crashes?

> The WebSocket connection is lost, the client reconnects to another gateway, and durable message storage allows the client to synchronize missed messages.

---

# 57. 1-Minute Interview Answer

If the interviewer says:

> "Design WhatsApp."

Start with:

```text
First, I will clarify the requirements.

The core requirements are 1-to-1 chat, group chat,
message history, delivery/read receipts, presence,
push notifications, and media sharing.

For real-time communication, I would use WebSockets.

Clients connect to horizontally scalable chat gateway
servers through a load balancer.

When Alice sends a message, the gateway forwards it to
the Message Service. The message gets a unique ID and
is durably stored. Then an event can be published to a
queue for asynchronous processing.

If Bob is online, we use a connection registry to find
Bob's active gateway and push the message through his
WebSocket connection.

If Bob is offline, the message remains in durable storage
and a push notification can be sent through FCM/APNs.
When Bob reconnects, he synchronizes messages after his
last acknowledged sequence number.

For message storage, I would use a horizontally scalable
NoSQL database, partitioned according to conversation
access patterns. I would use sequence numbers for
conversation-level ordering.

For presence, I would use a fast distributed key-value
store with heartbeat and TTL.

For media, I would use object storage and a CDN rather
than storing large files in the message database.

Finally, I would add replication, retries, idempotency,
rate limiting, monitoring, and multi-zone deployment
for availability and fault tolerance.
```

---

# 🧠 FINAL RECALL SHEET

```text
WHATSAPP SYSTEM DESIGN
        ↓
WebSocket
        ↓
Load Balancer
        ↓
Chat Gateway
        ↓
Message Service
        ↓
Message DB
        ↓
Message Queue
        ↓
Notification Service
        ↓
FCM / APNs
```

### Remember the 10 Key Components

```text
1. WebSocket       → Real-time communication

2. Gateway         → Maintain client connections

3. Connection Map  → user → gateway/device

4. Message Service → Process messages

5. NoSQL DB        → Store messages at scale

6. Queue           → Async processing

7. Presence Store  → Online/offline

8. Push Service    → Offline users

9. Object Storage  → Images/videos/files

10. CDN             → Fast media delivery
```

### Most Important Concepts

```text
Real-time
    → WebSocket

Offline
    → DB + Push Notification

Ordering
    → Conversation Sequence Number

Duplicate
    → Idempotency + Message ID

Scaling
    → Horizontal Scaling + Partitioning

Availability
    → Replication + Multi-AZ

Presence
    → Heartbeat + TTL

Media
    → Object Storage + CDN

Large Groups
    → Fanout + Queue

Failure
    → Retry + Idempotency + Reconnect
```

## ⭐ Golden Interview Summary

> **WhatsApp = WebSocket + Gateway + Message Service + Durable Message Store + Queue + Presence + Push Notification + Object Storage + CDN + Partitioning + Replication.**

> The most important design principle is to **separate real-time connection handling from durable message storage**. WebSocket connections can fail and reconnect, but messages should remain safely stored and be recoverable through synchronization.