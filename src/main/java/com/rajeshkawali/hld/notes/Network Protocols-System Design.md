# NETWORK PROTOCOLS — SYSTEM DESIGN INTERVIEW NOTES

## 1. What is a Network Protocol?

A **network protocol** is a set of rules that defines how two or more systems communicate over a network.

It defines things like:

- How a connection is established
- How data is formatted
- How data is transmitted
- How errors are handled
- How lost packets are handled
- How the receiver knows when data is complete
- How communication is secured

### Simple Example

When you open:

```text
https://example.com
```

many protocols work together:

```text
DNS
 ↓
Find server IP

TCP
 ↓
Establish reliable connection

TLS
 ↓
Encrypt communication

HTTP
 ↓
Send request/receive response
```

So a real application usually uses **multiple protocols together**.

---

# 2. Network Protocol Stack — Big Picture

A simplified view:

```text
Application Layer
-------------------------
HTTP
HTTPS
WebSocket
gRPC
DNS
SMTP
etc.

Transport Layer
-------------------------
TCP
UDP

Internet Layer
-------------------------
IP

Link Layer
-------------------------
Ethernet
Wi-Fi
```

Example:

```text
Browser
   ↓
HTTP
   ↓
TCP
   ↓
IP
   ↓
Wi-Fi/Ethernet
   ↓
Internet
   ↓
Server
```

---

# 3. TCP

## Definition

**TCP (Transmission Control Protocol)** is a connection-oriented transport protocol that provides:

- Reliable delivery
- Ordered delivery
- Error detection
- Retransmission
- Flow control
- Congestion control

TCP is designed to make communication reliable.

---

## TCP Example

Suppose we want to send:

```text
HELLOWORLD
```

TCP breaks the data into segments.

```text
HELLO
WORLD
```

The receiver acknowledges received data.

If a segment is lost:

```text
Sender
  ↓
Segment 1 → Received
Segment 2 → LOST
Segment 3 → Received

Receiver
  ↓
ACK / retransmission request
```

TCP retransmits the missing data.

---

# 4. TCP 3-Way Handshake

Before transferring data, TCP establishes a connection.

```text
Client                    Server

   SYN  -------------------->

        <-------------------- SYN + ACK

   ACK  -------------------->

       Connection established
```

### Step 1 — SYN

Client says:

> I want to establish a connection.

### Step 2 — SYN + ACK

Server says:

> I received your request and I'm ready.

### Step 3 — ACK

Client says:

> Confirmed.

Now data transfer begins.

---

# 5. Advantages of TCP

- Reliable
- Ordered
- Error detection
- Retransmission
- Flow control
- Congestion control
- Widely supported

### Common Uses

```text
HTTP/HTTPS
gRPC
WebSocket
SSH
FTP
Database connections
```

---

# 6. Disadvantages of TCP

- Connection establishment adds overhead
- Retransmission can increase latency
- Head-of-line blocking can occur
- More protocol overhead than UDP

### Recall

> **TCP = Reliable + Ordered + Connection-oriented**

---

# 7. UDP

## Definition

**UDP (User Datagram Protocol)** is a connectionless transport protocol.

UDP does not guarantee:

- Delivery
- Ordering
- Retransmission

It sends datagrams without establishing a traditional TCP-style connection.

---

## Example

Suppose:

```text
Packet 1
Packet 2
Packet 3
Packet 4
```

The receiver may receive:

```text
Packet 1
Packet 3
Packet 4
```

Packet 2 may be lost.

UDP does not automatically retransmit it.

---

# 8. Why Use UDP?

UDP is useful when:

> **Low latency is more important than perfect delivery.**

Examples:

```text
Online gaming
Voice calls
Video calls
Live streaming components
DNS
Real-time telemetry
```

For real-time media, an old packet may be less useful than receiving the latest packet quickly.

Example:

```text
Video frame at 10:00:01
Video frame at 10:00:02
Video frame at 10:00:03
```

If frame 10:00:01 is lost, retransmitting it several seconds later may not be useful.

---

# 9. Advantages of UDP

- Low overhead
- Low latency
- No connection establishment
- Suitable for real-time traffic
- Application can implement its own reliability if needed

---

# 10. Disadvantages of UDP

- No guaranteed delivery
- No guaranteed ordering
- No built-in retransmission
- Application may need to handle reliability
- Congestion behavior must be handled by the protocol/application stack

### Recall

> **UDP = Fast + Lightweight + No guaranteed delivery**

---

# 11. TCP vs UDP

| Feature | TCP | UDP |
|---|---|---|
| Connection | Connection-oriented | Connectionless |
| Reliable | Yes | No |
| Ordered | Yes | No |
| Retransmission | Yes | No |
| Latency | Higher | Usually lower |
| Overhead | Higher | Lower |
| Use case | APIs, databases | Gaming, real-time media |
| Packet loss | Handled by TCP | Application/protocol handles it |

### Easy Recall

```text
TCP → "Make sure it arrives correctly."

UDP → "Send it quickly."
```

---

# 12. HTTP

## Definition

**HTTP (Hypertext Transfer Protocol)** is an application-layer request/response protocol.

Example:

```http
GET /users/123
```

Server:

```http
HTTP/1.1 200 OK
```

with response data.

---

# 13. HTTP Request Flow

```text
Client
  |
  | HTTP Request
  ↓
Load Balancer
  |
  ↓
Application Server
  |
  ↓
Database
  |
  ↓
Application Server
  |
  | HTTP Response
  ↓
Client
```

---

# 14. Common HTTP Methods

### GET

Retrieve data.

```http
GET /users/123
```

### POST

Create/process something.

```http
POST /orders
```

### PUT

Replace/update a resource.

```http
PUT /users/123
```

### PATCH

Partially update a resource.

```http
PATCH /users/123
```

### DELETE

Delete a resource.

```http
DELETE /users/123
```

---

# 15. HTTP Status Codes

```text
2xx → Success
3xx → Redirection
4xx → Client error
5xx → Server error
```

Examples:

```text
200 → OK
201 → Created
204 → No Content

301 → Moved Permanently
304 → Not Modified

400 → Bad Request
401 → Unauthorized
403 → Forbidden
404 → Not Found
409 → Conflict
429 → Too Many Requests

500 → Internal Server Error
502 → Bad Gateway
503 → Service Unavailable
504 → Gateway Timeout
```

---

# 16. HTTP/1.1

HTTP/1.1 commonly uses persistent TCP connections.

Example:

```text
Client
 ↓
TCP connection
 ↓
Request 1
 ↓
Response 1
 ↓
Request 2
 ↓
Response 2
```

### Problem

HTTP/1.1 can suffer from **head-of-line blocking at the HTTP request level** when pipelining is used, and browsers historically worked around this using multiple connections.

---

# 17. HTTP/2

HTTP/2 introduces:

- Binary framing
- Multiplexing
- Header compression
- Multiple concurrent streams over one TCP connection

Example:

```text
TCP Connection
       |
 ┌─────┼─────┐
 ↓     ↓     ↓
Req1  Req2  Req3
 ↓     ↓     ↓
Res1  Res2  Res3
```

This reduces the need for many parallel TCP connections.

### Important

HTTP/2 still uses TCP, so **TCP-level packet loss can cause transport-level head-of-line blocking**.

---

# 18. HTTP/3

HTTP/3 uses:

```text
HTTP/3
  ↓
QUIC
  ↓
UDP
```

QUIC provides features such as:

- Reliable streams
- Encryption
- Connection migration
- Reduced connection establishment latency
- Avoidance of TCP-level head-of-line blocking across independent streams

### Important Interview Point

Do not say:

> "HTTP/3 is unreliable because it uses UDP."

That is incorrect.

QUIC runs over UDP but provides reliable transport semantics for its streams.

---

# 19. HTTP/1.1 vs HTTP/2 vs HTTP/3

| Feature | HTTP/1.1 | HTTP/2 | HTTP/3 |
|---|---|---|---|
| Transport | TCP | TCP | QUIC/UDP |
| Multiplexing | Limited | Yes | Yes |
| Binary framing | No | Yes | Yes |
| Header compression | Limited | HPACK | QPACK |
| Encryption | HTTPS optional | Common in practice | Required with QUIC |
| TCP HOL blocking | Yes | Yes | No at TCP layer |
| Connection migration | No | No | Yes |

### Recall

```text
HTTP/1.1 → Basic
HTTP/2   → Multiplexing
HTTP/3   → QUIC + UDP
```

---

# 20. HTTPS

HTTPS means:

```text
HTTP + TLS
```

TLS provides:

- Encryption
- Authentication
- Integrity

Flow:

```text
Client
 ↓
TLS handshake
 ↓
Secure encrypted connection
 ↓
HTTP request
 ↓
HTTP response
```

---

# 21. Why HTTPS?

Without encryption:

```text
Client
 ↓
HTTP
 ↓
Attacker may observe/modify traffic
```

With HTTPS:

```text
Client
 ↓
Encrypted TLS connection
 ↓
Server
```

An attacker may still observe metadata such as destination/IP and traffic timing, but cannot normally read or modify the protected HTTP payload without breaking the cryptographic protections.

---

# 22. DNS

## Definition

**DNS (Domain Name System)** converts domain names into IP addresses.

Example:

```text
google.com
     ↓
DNS
     ↓
142.x.x.x
```

---

# 23. DNS Request Flow

Simplified:

```text
Browser
 ↓
OS / DNS cache
 ↓
Recursive DNS resolver
 ↓
Root DNS
 ↓
TLD DNS
 ↓
Authoritative DNS
 ↓
IP address
```

The result is cached according to DNS TTL.

---

# 24. WebSocket

## Definition

WebSocket provides a **persistent, full-duplex communication channel** between client and server.

It is useful when the server needs to push updates to the client without the client continuously polling.

---

# 25. HTTP vs WebSocket

HTTP:

```text
Client → Request
Server → Response
```

WebSocket:

```text
Client ↔ Server
       persistent connection
```

After the WebSocket handshake, both sides can send messages independently.

---

# 26. WebSocket Handshake

Initially, WebSocket uses HTTP:

```text
Client
  |
  | HTTP Upgrade request
  ↓
Server
  |
  | 101 Switching Protocols
  ↓
WebSocket connection
```

Then:

```text
Client ↔ Server
     WebSocket frames
```

---

# 27. WebSocket Use Cases

Good for:

```text
Chat
Live notifications
Collaborative editing
Live dashboards
Trading updates
Online presence
Multiplayer state updates
```

---

# 28. WebSocket Scaling

Suppose:

```text
1 million connected users
```

We cannot depend on one server.

Use:

```text
                   Load Balancer
                        |
          ┌─────────────┼─────────────┐
          ↓             ↓             ↓
       Server 1      Server 2      Server 3
          |             |             |
          └─────────────┼─────────────┘
                        ↓
                 Message Broker
                 Redis/Kafka/etc.
```

A shared messaging mechanism helps route events between instances.

---

# 29. WebSocket Heartbeat

Long-lived connections can become stale.

Use:

```text
Ping
 ↓
Pong
```

If a client stops responding:

```text
Connection considered dead
 ↓
Close connection
 ↓
Client reconnects
```

Use reconnect logic with exponential backoff and jitter to avoid a reconnect storm.

---

# 30. WebSocket Advantages

- Full duplex
- Persistent connection
- Low overhead after handshake
- Server can push messages
- Good for real-time applications

## Disadvantages

- Long-lived connections consume resources
- Scaling is more complex
- Load balancers/proxies need proper WebSocket support
- Reconnection handling is required
- Connection state needs careful management

### Recall

> **WebSocket = Persistent client-server real-time communication.**

---

# 31. WebRTC

## Definition

**WebRTC** is designed for real-time communication such as:

- Audio
- Video
- Screen sharing
- Peer-to-peer data

Example:

```text
User A
   ↕
WebRTC
   ↕
User B
```

The media path can be direct between peers when network conditions allow.

---

# 32. WebRTC Architecture

Important components:

```text
Browser
 |
 ├── getUserMedia()
 |
 ├── RTCPeerConnection
 |
 └── RTCDataChannel
```

Infrastructure:

```text
Signaling Server
STUN Server
TURN Server
SFU/MCU for multiparty communication
```

---

# 33. WebRTC Signaling

WebRTC itself does not define a specific signaling transport.

You can use:

```text
WebSocket
HTTP
```

to exchange:

```text
SDP
ICE candidates
Session information
```

Example:

```text
User A
 ↓
Signaling Server
 ↓
User B
```

---

# 34. STUN

STUN helps a client discover its public-facing network address and determine NAT behavior.

Example:

```text
Private IP
192.168.1.10

     ↓ STUN

Public address
203.x.x.x
```

This can help peers attempt a direct connection.

---

# 35. TURN

Sometimes direct peer-to-peer communication fails.

Examples:

```text
Strict NAT
Firewall
Enterprise network
Symmetric NAT
```

Then traffic can be relayed through a TURN server:

```text
User A
  ↓
TURN
  ↓
User B
```

### Disadvantage

TURN consumes significant bandwidth because media flows through the relay.

### Recall

```text
STUN → Discover public connectivity information

TURN → Relay traffic when direct connection fails
```

---

# 36. WebRTC Media Transport

A simplified view:

```text
Media
 ↓
RTP
 ↓
UDP
```

Media is protected using:

```text
SRTP
```

WebRTC data channels use:

```text
DataChannel
 ↓
SCTP
 ↓
DTLS
 ↓
UDP
```

---

# 37. WebRTC Multiparty Communication

Suppose:

```text
A
B
C
D
```

## Mesh

Every user connects to every other user.

```text
A ↔ B
A ↔ C
A ↔ D
B ↔ C
B ↔ D
C ↔ D
```

### Problem

Connections grow rapidly.

---

# 38. SFU

**SFU = Selective Forwarding Unit**

Users send media to the SFU.

```text
A ──┐
B ──┼──→ SFU ──→ Participants
C ──┤
D ──┘
```

The SFU forwards selected streams rather than mixing all media into one stream.

### Advantages

- Scales much better than mesh
- Lower server CPU than MCU
- Common for group calls

### Disadvantages

- Server bandwidth usage is high
- More infrastructure

---

# 39. MCU

**MCU = Multipoint Control Unit**

The server receives streams and mixes them.

```text
A ──┐
B ──┼──→ MCU → Combined stream
C ──┤
D ──┘
```

### Advantages

- Clients receive fewer streams
- Can simplify some client-side processing

### Disadvantages

- High CPU usage
- More processing on server
- Encoding/mixing adds complexity

---

# 40. WebSocket vs WebRTC

| WebSocket | WebRTC |
|---|---|
| Client-server | P2P or server-assisted |
| Persistent | Real-time session |
| Usually TCP | Primarily UDP-based |
| Chat/events | Audio/video/data |
| Server handles communication | Media may flow peer-to-peer |
| Easier architecture | More networking complexity |

### Recall

```text
Chat → WebSocket

Video/Audio → WebRTC
```

---

# 41. gRPC

## Definition

**gRPC** is a high-performance RPC framework commonly used for service-to-service communication.

It commonly uses:

```text
gRPC
 ↓
HTTP/2
 ↓
TCP
```

Data is commonly serialized using:

```text
Protocol Buffers (Protobuf)
```

---

# 42. REST vs gRPC

### REST

Usually:

```text
HTTP
+
JSON
```

Example:

```http
GET /users/123
```

Response:

```json
{
  "id": 123,
  "name": "John"
}
```

### gRPC

Define service using protobuf:

```text
service UserService {
    rpc GetUser(GetUserRequest) returns (User);
}
```

Communication uses generated client/server code.

---

# 43. gRPC Advantages

- Efficient binary serialization
- Strongly typed contracts
- Code generation
- HTTP/2 multiplexing
- Streaming support
- Good for internal microservices

## Disadvantages

- Less browser-friendly than REST
- More tooling complexity
- Human readability is lower than JSON
- Public APIs may still prefer REST/HTTP APIs depending on consumers

### Recall

> **gRPC = Fast typed service-to-service RPC using Protobuf + HTTP/2.**

---

# 44. gRPC Streaming

gRPC supports:

### Unary

```text
Client → Request
Server → Response
```

### Server Streaming

```text
Client → Request

Server → Response 1
Server → Response 2
Server → Response 3
```

### Client Streaming

```text
Client → Request 1
Client → Request 2
Client → Request 3

Server → Response
```

### Bidirectional Streaming

```text
Client ↔ Server
continuous messages
```

This is useful for real-time internal service communication.

---

# 45. Client-Server Architecture

## Definition

A centralized server provides services to clients.

```text
Client 1 ──┐
Client 2 ──┼──→ Server
Client 3 ──┘
```

Examples:

```text
Web applications
REST APIs
Banking systems
E-commerce
Social media
```

---

## Advantages

- Centralized control
- Easier authentication
- Easier authorization
- Easier monitoring
- Easier data consistency
- Easier data management

## Disadvantages

- Server infrastructure costs
- Potential bottleneck
- Requires high availability
- Server-side scaling is necessary

---

# 46. Peer-to-Peer Architecture

In P2P, nodes communicate directly when possible.

```text
Peer A ↔ Peer B
   ↕       ↕
Peer C ↔ Peer D
```

Examples:

```text
BitTorrent
Some WebRTC communication
Blockchain networks
Some distributed systems
```

---

## Advantages

- Distributed load
- Can reduce centralized bandwidth
- Potentially lower latency
- No single central server for all traffic

## Disadvantages

- More complex
- NAT traversal
- Security/trust challenges
- Peer availability varies
- Harder monitoring
- Data consistency can be difficult

---

# 47. Client-Server vs P2P

| Client-Server | P2P |
|---|---|
| Centralized | Distributed |
| Easier control | Harder control |
| Easier security | More complex security |
| Easier consistency | Harder consistency |
| Server handles traffic | Peers share traffic |
| Easier monitoring | More difficult monitoring |

### Recall

```text
Client-Server → Centralized control

P2P → Distributed communication
```

---

# 48. NAT

## What is NAT?

NAT allows multiple devices with private IP addresses to share a public IP.

Example:

```text
Laptop
192.168.1.10
     |
Phone
192.168.1.11
     |
     ↓
   Router
     |
Public IP
     |
Internet
```

NAT makes direct peer-to-peer connections more difficult.

This is why WebRTC uses:

```text
STUN
TURN
ICE
```

---

# 49. Firewall

A firewall controls network traffic based on rules such as:

```text
IP
Port
Protocol
Direction
Application rules
```

Example:

```text
Internet
   ↓
Firewall
   ↓
Only allow HTTPS : 443
   ↓
Application
```

---

# 50. Ports

A port identifies a logical service endpoint on a host.

Common examples:

```text
HTTP   → 80
HTTPS  → 443
SSH    → 22
DNS    → 53
```

Conceptually:

```text
IP address = Machine

Port = Service endpoint
```

Example:

```text
192.168.1.10:443
```

means:

```text
Host: 192.168.1.10
Port: 443
```

---

# 51. Connection-Oriented vs Connectionless

## Connection-Oriented

Connection established before communication.

Example:

```text
TCP
```

```text
Connect
 ↓
Transfer
 ↓
Close
```

## Connectionless

No traditional connection setup.

Example:

```text
UDP
```

```text
Send datagram
 ↓
Send another datagram
```

---

# 52. Request-Response vs Persistent Communication

## Request-Response

```text
Client → Request
Server → Response
```

Examples:

```text
HTTP
REST
```

Good for:

```text
CRUD
APIs
Web pages
```

---

## Persistent Communication

```text
Client ↔ Server
```

Examples:

```text
WebSocket
WebRTC
gRPC streaming
```

Good for:

```text
Chat
Live updates
Calls
Streaming
```

---

# 53. Polling vs Long Polling vs WebSocket

## Polling

Client repeatedly asks:

```text
Any new message?
```

Example:

```text
Every 5 seconds:
GET /messages
```

### Disadvantages

- Many unnecessary requests
- Higher latency
- More server load

---

## Long Polling

Client sends request:

```text
Any new message?
```

Server holds the request until data is available or timeout occurs.

Then:

```text
Response
 ↓
Client reconnects
```

Better than normal polling but still has request lifecycle overhead.

---

## WebSocket

Persistent connection:

```text
Client ↔ Server
```

Server can push immediately.

### Recall

```text
Polling
→ Ask repeatedly

Long Polling
→ Ask and wait

WebSocket
→ Stay connected
```

---

# 54. Protocol Selection — How to Decide?

Ask:

### Question 1

Do I need reliable ordered delivery?

```text
YES → TCP-based protocol / QUIC stream
NO/real-time loss tolerant → UDP-based protocol may fit
```

### Question 2

Is it request-response?

```text
YES → HTTP/REST
```

### Question 3

Do I need persistent server push?

```text
YES → WebSocket
```

### Question 4

Do I need audio/video?

```text
YES → WebRTC / media protocols
```

### Question 5

Is it internal microservice communication?

```text
YES → gRPC can be a strong choice
```

---

# 55. Protocol Decision Table

| Requirement | Suitable Choice |
|---|---|
| Web API | HTTP/HTTPS |
| REST API | HTTP/HTTPS |
| Secure API | HTTPS |
| Chat | WebSocket |
| Live notification | WebSocket |
| Video call | WebRTC |
| Voice call | WebRTC |
| Browser P2P data | WebRTC |
| Microservice RPC | gRPC |
| File transfer | TCP/HTTP |
| Online gaming | UDP-based protocols |
| DNS lookup | DNS |
| Secure shell | SSH |

---

# 56. Network Protocol in System Design

When designing a system, don't simply say:

> "I'll use HTTP."

Explain why.

Example:

## Design WhatsApp-like Chat

```text
Mobile Client
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
     ↓
Kafka
     |
     ↓
Message Storage
```

Why WebSocket?

Because chat requires:

```text
Persistent connection
+
Server push
+
Low latency
```

---

# 57. Video Calling System

```text
Client A
   |
   | WebSocket/HTTP
   ↓
Signaling Server
   |
   | SDP/ICE exchange
   ↓
Client B

Media:
Client A
   ↕
WebRTC
   ↕
Client B

If direct connection fails:

Client A
   ↓
TURN
   ↓
Client B
```

For group calls:

```text
Clients
   ↓
SFU
   ↓
Clients
```

---

# 58. Chat Application Protocol Design

For WhatsApp-like chat:

### Client → Server

```text
WebSocket
```

### Server → Client

```text
WebSocket
```

### Internal service communication

```text
gRPC
```

### Event processing

```text
Kafka
```

### Database communication

```text
Database-specific protocol
```

So a single system can use **multiple protocols simultaneously**.

---

# 59. Protocols vs API Styles

Don't confuse these concepts.

### HTTP

A network/application protocol.

### REST

An architectural style for designing APIs using HTTP semantics.

### WebSocket

A protocol for persistent two-way communication.

### gRPC

An RPC framework/protocol ecosystem commonly using HTTP/2 and Protobuf.

Example:

```text
REST
 ↓
HTTP
 ↓
TCP
 ↓
IP
```

and:

```text
gRPC
 ↓
HTTP/2
 ↓
TCP
 ↓
IP
```

---

# 60. HLD View

In HLD, focus on:

```text
Clients
 ↓
DNS
 ↓
Load Balancer
 ↓
API Gateway
 ↓
Services
 ↓
Cache
 ↓
Database
 ↓
Message Broker
```

Then decide protocols:

```text
Client → Gateway
HTTPS

Real-time client communication
WebSocket

Service → Service
gRPC

Async communication
Kafka/RabbitMQ/etc.

Video
WebRTC
```

---

# 61. LLD View

In LLD, focus on:

- Connection management
- Serialization
- Authentication
- Message framing
- Retry
- Timeout
- Heartbeat
- Reconnection
- Backpressure
- Error handling
- Threading/concurrency
- Connection state

Example:

```text
WebSocketServer
      |
      ↓
ConnectionManager
      |
      ↓
MessageRouter
      |
      ↓
MessageHandler
      |
      ↓
EventPublisher
```

---

# 62. WebSocket LLD Components

```text
WebSocketServer
        |
        ↓
AuthHandler
        |
        ↓
SessionManager
        |
        ↓
MessageRouter
        |
        ├── Local Session
        |
        └── Message Broker
                  |
                  ↓
             Other Servers
```

### Components

```text
WebSocketServer
→ Accept connections

AuthHandler
→ Authenticate client

SessionManager
→ Track active connections

MessageRouter
→ Route messages

HeartbeatManager
→ Ping/pong

Broker
→ Cross-server communication
```

---

# 63. Reliability Considerations

Network communication can fail.

Possible failures:

```text
Timeout
Connection reset
Packet loss
Server crash
Network partition
DNS failure
Load balancer failure
```

Therefore design:

```text
Timeouts
Retries
Backoff
Idempotency
Circuit breaker
Dead-letter handling
Reconnection
Health checks
```

---

# 64. Retry Strategy

Never blindly retry immediately.

Bad:

```text
Failure
 ↓
Retry
 ↓
Failure
 ↓
Retry
 ↓
Failure
```

This can create a retry storm.

Use:

```text
Exponential Backoff
+
Jitter
```

Example:

```text
Retry 1 → 100ms
Retry 2 → 200ms
Retry 3 → 400ms
Retry 4 → 800ms
```

Add random jitter.

---

# 65. Timeout

Every network call should have an appropriate timeout.

Example:

```text
Service A
   |
   | 2 sec timeout
   ↓
Service B
```

If Service B does not respond:

```text
Timeout
 ↓
Retry / fallback / error
```

Never allow requests to wait forever.

---

# 66. Backpressure

Backpressure means:

> When the consumer cannot process data as fast as the producer sends it, the system must control the incoming rate.

Example:

```text
Producer
100K msg/sec
     ↓
Queue
     ↓
Consumer
10K msg/sec
```

Without backpressure:

```text
Queue grows
 ↓
Memory grows
 ↓
System crashes
```

Possible solutions:

- Bounded queues
- Rate limiting
- Flow control
- Load shedding
- Consumer scaling

---

# 67. Network Security

Important controls:

```text
TLS
Authentication
Authorization
Encryption
Certificate validation
Firewall
API Gateway
Rate Limiting
DDoS protection
```

Example:

```text
Internet
 ↓
DDoS Protection
 ↓
WAF
 ↓
Load Balancer
 ↓
API Gateway
 ↓
Application
```

---

# 68. Common Interview Questions

## Q1. TCP vs UDP?

> TCP provides reliable, ordered delivery with connection management. UDP is connectionless and does not guarantee delivery or ordering, making it useful for latency-sensitive applications.

---

## Q2. Why does HTTP use TCP?

> Traditional HTTP/1.1 and HTTP/2 use TCP because applications such as web APIs generally need reliable, ordered delivery. HTTP/3 instead uses QUIC over UDP.

---

## Q3. Why use WebSocket instead of HTTP polling?

> WebSocket maintains a persistent bidirectional connection, allowing the server to push updates immediately and avoiding repeated polling requests.

---

## Q4. Why use WebRTC for video calls?

> WebRTC is designed for real-time audio/video and data communication and can use direct peer-to-peer connectivity when possible, with TURN/SFU infrastructure when required.

---

## Q5. What is STUN?

> STUN helps a client discover public-facing connectivity information for NAT traversal.

---

## Q6. What is TURN?

> TURN relays traffic through a server when direct peer-to-peer communication cannot be established.

---

## Q7. What is gRPC?

> gRPC is an RPC framework commonly using HTTP/2 and Protobuf, well suited for strongly typed, efficient service-to-service communication.

---

## Q8. HTTP/1.1 vs HTTP/2?

> HTTP/2 adds binary framing and multiplexing over a TCP connection, reducing application-level request blocking and improving connection efficiency.

---

## Q9. HTTP/2 vs HTTP/3?

> HTTP/2 uses TCP, while HTTP/3 uses QUIC over UDP. HTTP/3 avoids TCP-level head-of-line blocking between independent streams and supports connection migration.

---

## Q10. WebSocket vs WebRTC?

> WebSocket is primarily for persistent client-server messaging, while WebRTC is designed for real-time media and peer-to-peer data communication.

---

## Q11. Why can't WebRTC work directly for every user?

> NATs and firewalls can prevent direct connectivity, so ICE uses mechanisms such as STUN and TURN to establish connectivity.

---

## Q12. Why do we need a heartbeat?

> To detect stale or broken long-lived connections and clean up connection state.

---

## Q13. What happens when a WebSocket server crashes?

> The client should reconnect, usually using exponential backoff with jitter. The system should restore session state from shared storage where required.

---

## Q14. Can one system use multiple protocols?

> Yes. A modern distributed system commonly uses HTTPS for APIs, WebSocket for real-time events, gRPC for internal RPC, Kafka for asynchronous events, and WebRTC for media.

---

# 69. Most Important Comparisons

## TCP vs UDP

```text
TCP
→ Reliable
→ Ordered
→ Higher overhead

UDP
→ Lightweight
→ Lower latency
→ No guaranteed delivery
```

---

## HTTP vs WebSocket

```text
HTTP
→ Request/Response
→ Short-lived or persistent connections depending on version/usage

WebSocket
→ Persistent
→ Bidirectional
→ Server push
```

---

## WebSocket vs WebRTC

```text
WebSocket
→ Client-server
→ Chat/events
→ TCP

WebRTC
→ Real-time media/data
→ P2P/server-assisted
→ UDP-based media
```

---

## REST vs gRPC

```text
REST
→ HTTP APIs
→ Usually JSON
→ Public/browser-friendly

gRPC
→ RPC
→ Protobuf
→ Strong typing
→ Internal microservices
```

---

## STUN vs TURN

```text
STUN
→ Discover connectivity/public address

TURN
→ Relay traffic
```

---

# 70. Interview Design Approach

When asked:

> "Which network protocol would you choose?"

Don't immediately answer.

Use this approach:

```text
1. Understand communication requirement
        ↓
2. Is it request-response?
        ↓
3. Is real-time communication required?
        ↓
4. Is reliable delivery required?
        ↓
5. Is low latency more important?
        ↓
6. Is communication client-server or P2P?
        ↓
7. Browser compatibility?
        ↓
8. Security requirements?
        ↓
9. Scaling requirements?
        ↓
10. Choose protocol
```

---

# 71. Example — Design a Chat Application

Requirements:

```text
1. Send messages
2. Receive messages in real time
3. Online/offline status
4. Millions of users
```

Protocol choice:

```text
Client
  |
  | HTTPS
  ↓
API Gateway
  |
  | Login / REST APIs
  ↓
Services

For real-time messages:

Client
  ↕
WebSocket
  ↕
Chat Gateway

Internal:

Chat Service
  |
  | gRPC
  ↓
Other Services

Async:

Chat Service
  |
  ↓
Kafka
```

Why?

```text
HTTPS
→ Normal APIs

WebSocket
→ Real-time communication

gRPC
→ Internal service communication

Kafka
→ Asynchronous event processing
```

---

# 72. Example — Design Video Calling

Protocol choice:

```text
Login/API
→ HTTPS

Signaling
→ WebSocket or HTTPS

Media
→ WebRTC

NAT traversal
→ STUN/TURN

Group calls
→ SFU

Internal service calls
→ gRPC
```

Architecture:

```text
             HTTPS
Client ─────────────→ API

             WebSocket
Client ─────────────→ Signaling Server
                         |
                         ↓
                   SDP / ICE

             WebRTC
Client A ←────────────→ Client B

If P2P fails:

Client A ←→ TURN ←→ Client B
```

For groups:

```text
Clients
   ↓
WebRTC
   ↓
SFU
   ↓
Other clients
```

---

# 73. QUICK RECALL — NETWORK PROTOCOLS

```text
TCP
→ Reliable + Ordered

UDP
→ Fast + Lightweight

HTTP
→ Request / Response

HTTPS
→ HTTP + TLS

HTTP/2
→ Multiplexing over TCP

HTTP/3
→ QUIC over UDP

WebSocket
→ Persistent + Bidirectional

WebRTC
→ Real-time Audio/Video/P2P Data

gRPC
→ Service-to-Service RPC

DNS
→ Domain → IP

STUN
→ Discover public connectivity information

TURN
→ Relay when P2P fails

SFU
→ Forward media streams

MCU
→ Mix media streams
```

---

# 74. ONE-PAGE INTERVIEW RECALL

```text
NETWORK PROTOCOLS
│
├── TCP
│   ├── Reliable
│   ├── Ordered
│   ├── Connection-oriented
│   └── APIs / DB / HTTP
│
├── UDP
│   ├── Lightweight
│   ├── Low latency
│   ├── No guaranteed delivery
│   └── Real-time applications
│
├── HTTP
│   ├── Request/Response
│   └── REST APIs
│
├── HTTPS
│   └── HTTP + TLS
│
├── HTTP/2
│   ├── Binary framing
│   ├── Multiplexing
│   └── TCP
│
├── HTTP/3
│   ├── QUIC
│   ├── UDP
│   └── No TCP-level HOL blocking
│
├── WebSocket
│   ├── Persistent
│   ├── Bidirectional
│   ├── Client ↔ Server
│   └── Chat / Notifications
│
├── WebRTC
│   ├── Audio / Video
│   ├── P2P
│   ├── STUN
│   ├── TURN
│   └── SFU
│
└── gRPC
    ├── HTTP/2
    ├── Protobuf
    ├── Strongly typed
    └── Microservices
```

# ⭐ FINAL INTERVIEW RULE

```text
Normal API
→ HTTPS

Real-time chat/events
→ WebSocket

Video/voice
→ WebRTC

Internal microservices
→ gRPC

Async communication
→ Kafka / Message Queue

Reliable transport
→ TCP

Latency-sensitive/loss-tolerant traffic
→ UDP-based protocols

HTTP/3
→ QUIC + UDP
```

## ⭐ One-Line Summary

> **Choose the network protocol based on the communication requirement: HTTPS for APIs, WebSocket for persistent real-time client-server messaging, WebRTC for real-time media/P2P data, gRPC for efficient internal RPC, and UDP/QUIC-based protocols when low latency and modern transport features are important.**