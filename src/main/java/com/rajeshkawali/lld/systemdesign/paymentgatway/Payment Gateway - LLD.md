# Payment Gateway | Low Level Design | Example

## 1. Problem Statement

Design a **Payment Gateway** that allows an application to process payments using different payment methods such as:

- Credit/Debit Card
- UPI
- Net Banking
- Wallet

The system should:

1. Create a payment request.
2. Select the appropriate payment method.
3. Process the payment.
4. Return success/failure.
5. Support multiple payment providers.
6. Handle refunds.
7. Avoid duplicate payments when the same request is retried.
8. Be easily extensible for new payment methods/providers.

---

# 2. Example

Suppose an e-commerce application wants to charge a customer ₹1,000.

```text
Customer
   |
   | Pay ₹1000
   v
E-Commerce Application
   |
   v
Payment Gateway
   |
   |----------------------|
   |                      |
   v                      v
Card Payment          UPI Payment
   |                      |
   v                      v
Stripe/Razorpay/etc.   UPI Provider
   |
   v
Payment Result
   |
   v
SUCCESS / FAILED
```

The application should **not** need to know how each payment method works internally.

It should simply say:

```java
paymentGateway.pay(paymentRequest);
```

---

# 3. Requirements

## Functional Requirements

### Payment

- User can make a payment.
- Payment can be made using:
  - Card
  - UPI
  - Wallet
  - Net Banking
- System returns payment status.

### Refund

- Successful payments can be refunded.
- Refund amount cannot exceed original payment amount.

### Multiple Providers

For example:

```text
Card → Stripe
Card → Razorpay

UPI → Razorpay
UPI → PayU
```

The system should allow different providers.

### Payment Status

A payment can have:

```text
CREATED
PROCESSING
SUCCESS
FAILED
REFUNDED
```

### Idempotency

If the client sends the same payment request twice:

```text
requestId = REQ123
```

we should not charge the customer twice.

---

# 4. Non-Functional Requirements

The system should be:

- Extensible
- Maintainable
- Thread-safe
- Reliable
- Testable
- Provider-independent

Payment systems also require strong concerns around:

- Idempotency
- Security
- Transaction consistency
- Auditability
- Failure handling

---

# 5. High-Level Design

```text
                    +----------------------+
                    |   E-Commerce App     |
                    +----------+-----------+
                               |
                               | PaymentRequest
                               v
                    +----------------------+
                    |   PaymentGateway     |
                    +----------+-----------+
                               |
                    +----------v-----------+
                    | PaymentService       |
                    +----------+-----------+
                               |
                  +------------+-------------+
                  |                          |
                  v                          v
          PaymentMethodStrategy       PaymentProvider
                  |                          |
          +-------+-------+          +-------+-------+
          |       |       |          |       |       |
          v       v       v          v       v       v
        Card     UPI   Wallet     Stripe  Razorpay PayU
```

---

# 6. Main Entities

We can identify the following classes:

```text
PaymentGateway
PaymentService
PaymentRequest
Payment
PaymentMethod
PaymentProvider
CardPayment
UPIPayment
WalletPayment
Refund
```

Let's understand their responsibilities.

---

# 7. PaymentGateway

This is the main entry point for clients.

```java
PaymentGateway
```

Responsibilities:

- Accept payment request.
- Delegate processing.
- Return result.

It should **not** contain provider-specific logic.

Example:

```java
PaymentGateway gateway = new PaymentGateway(paymentService);

gateway.pay(request);
```

---

# 8. PaymentRequest

Represents an incoming payment request.

```java
public class PaymentRequest {

    private final String requestId;
    private final String customerId;
    private final double amount;
    private final PaymentMethod paymentMethod;

    public PaymentRequest(
            String requestId,
            String customerId,
            double amount,
            PaymentMethod paymentMethod) {

        this.requestId = requestId;
        this.customerId = customerId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
    }

    public String getRequestId() {
        return requestId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public double getAmount() {
        return amount;
    }

    public PaymentMethod getPaymentMethod() {
        return paymentMethod;
    }
}
```

In a production system, use `BigDecimal` instead of `double` for money.

---

# 9. PaymentMethod

```java
public enum PaymentMethod {
    CARD,
    UPI,
    WALLET,
    NET_BANKING
}
```

---

# 10. PaymentStatus

```java
public enum PaymentStatus {
    CREATED,
    PROCESSING,
    SUCCESS,
    FAILED,
    REFUNDED
}
```

---

# 11. Payment

Represents the actual payment transaction.

```java
public class Payment {

    private final String paymentId;
    private final String requestId;
    private final String customerId;
    private final double amount;

    private PaymentMethod paymentMethod;
    private PaymentStatus status;

    public Payment(
            String paymentId,
            String requestId,
            String customerId,
            double amount,
            PaymentMethod paymentMethod) {

        this.paymentId = paymentId;
        this.requestId = requestId;
        this.customerId = customerId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = PaymentStatus.CREATED;
    }

    public void markProcessing() {
        this.status = PaymentStatus.PROCESSING;
    }

    public void markSuccess() {
        this.status = PaymentStatus.SUCCESS;
    }

    public void markFailed() {
        this.status = PaymentStatus.FAILED;
    }

    public void markRefunded() {
        this.status = PaymentStatus.REFUNDED;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public String getRequestId() {
        return requestId;
    }

    public double getAmount() {
        return amount;
    }

    public PaymentStatus getStatus() {
        return status;
    }
}
```

---

# 12. Payment Provider

A payment provider is the external service that actually processes the payment.

For example:

```text
Stripe
Razorpay
PayU
Adyen
```

Instead of tightly coupling our application to one provider, create an interface.

```java
public interface PaymentProvider {

    PaymentResult process(Payment payment);

    PaymentResult refund(Payment payment, double amount);
}
```

Now we can have:

```text
PaymentProvider
      |
      +---- RazorpayProvider
      |
      +---- StripeProvider
      |
      +---- PayUProvider
```

---

# 13. PaymentResult

```java
public class PaymentResult {

    private final boolean success;
    private final String transactionId;
    private final String message;

    public PaymentResult(
            boolean success,
            String transactionId,
            String message) {

        this.success = success;
        this.transactionId = transactionId;
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public String getMessage() {
        return message;
    }
}
```

---

# 14. Razorpay Provider

For our example:

```java
public class RazorpayProvider implements PaymentProvider {

    @Override
    public PaymentResult process(Payment payment) {

        System.out.println(
                "Processing payment using Razorpay..."
        );

        // Simulate external API call

        return new PaymentResult(
                true,
                "RZP_TXN_123",
                "Payment successful"
        );
    }

    @Override
    public PaymentResult refund(
            Payment payment,
            double amount) {

        System.out.println(
                "Refunding payment using Razorpay..."
        );

        return new PaymentResult(
                true,
                "RZP_REFUND_123",
                "Refund successful"
        );
    }
}
```

---

# 15. Stripe Provider

```java
public class StripeProvider implements PaymentProvider {

    @Override
    public PaymentResult process(Payment payment) {

        System.out.println(
                "Processing payment using Stripe..."
        );

        return new PaymentResult(
                true,
                "STRIPE_TXN_123",
                "Payment successful"
        );
    }

    @Override
    public PaymentResult refund(
            Payment payment,
            double amount) {

        return new PaymentResult(
                true,
                "STRIPE_REFUND_123",
                "Refund successful"
        );
    }
}
```

---

# 16. Why PaymentProvider Interface?

Without an interface, we might write:

```java
if (provider.equals("stripe")) {
    // Stripe logic
} else if (provider.equals("razorpay")) {
    // Razorpay logic
} else if (provider.equals("payu")) {
    // PayU logic
}
```

This becomes difficult to maintain.

Instead:

```java
PaymentProvider provider;
provider.process(payment);
```

The caller doesn't care which provider is being used.

This follows:

> **Program to an interface, not an implementation.**

---

# 17. Payment Method Strategy

Payment methods can have different processing requirements.

For example:

```text
CARD
    ↓
Validate card
    ↓
Process authorization

UPI
    ↓
Create UPI request
    ↓
Wait for confirmation

WALLET
    ↓
Check wallet
    ↓
Debit wallet
```

We can model this using the **Strategy Pattern**.

```java
public interface PaymentMethodStrategy {

    PaymentResult pay(
            Payment payment,
            PaymentProvider provider
    );
}
```

---

# 18. Card Payment Strategy

```java
public class CardPaymentStrategy
        implements PaymentMethodStrategy {

    @Override
    public PaymentResult pay(
            Payment payment,
            PaymentProvider provider) {

        System.out.println(
                "Validating card details..."
        );

        return provider.process(payment);
    }
}
```

---

# 19. UPI Payment Strategy

```java
public class UPIPaymentStrategy
        implements PaymentMethodStrategy {

    @Override
    public PaymentResult pay(
            Payment payment,
            PaymentProvider provider) {

        System.out.println(
                "Creating UPI payment request..."
        );

        return provider.process(payment);
    }
}
```

---

# 20. Wallet Payment Strategy

```java
public class WalletPaymentStrategy
        implements PaymentMethodStrategy {

    @Override
    public PaymentResult pay(
            Payment payment,
            PaymentProvider provider) {

        System.out.println(
                "Validating wallet..."
        );

        return provider.process(payment);
    }
}
```

---

# 21. Strategy Factory

We need to select the appropriate strategy.

```java
public class PaymentStrategyFactory {

    public static PaymentMethodStrategy getStrategy(
            PaymentMethod method) {

        return switch (method) {

            case CARD ->
                    new CardPaymentStrategy();

            case UPI ->
                    new UPIPaymentStrategy();

            case WALLET ->
                    new WalletPaymentStrategy();

            case NET_BANKING ->
                    new WalletPaymentStrategy(); // simplified
        };
    }
}
```

In production, these strategies would generally be managed/injected rather than constructed every time.

---

# 22. Payment Repository

We need to store payments.

For an LLD example, we can use an in-memory repository.

```java
public interface PaymentRepository {

    void save(Payment payment);

    Payment findByRequestId(String requestId);

    Payment findByPaymentId(String paymentId);
}
```

Implementation:

```java
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class InMemoryPaymentRepository
        implements PaymentRepository {

    private final Map<String, Payment> payments =
            new ConcurrentHashMap<>();

    @Override
    public void save(Payment payment) {

        payments.put(
                payment.getPaymentId(),
                payment
        );
    }

    @Override
    public Payment findByRequestId(
            String requestId) {

        return payments.values()
                .stream()
                .filter(p ->
                        p.getRequestId()
                                .equals(requestId))
                .findFirst()
                .orElse(null);
    }

    @Override
    public Payment findByPaymentId(
            String paymentId) {

        return payments.get(paymentId);
    }
}
```

In a real system, `requestId` should have a database uniqueness constraint rather than relying only on this in-memory lookup.

---

# 23. Payment Service

This is the core business service.

```java
import java.util.UUID;

public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PaymentProvider paymentProvider;

    public PaymentService(
            PaymentRepository paymentRepository,
            PaymentProvider paymentProvider) {

        this.paymentRepository = paymentRepository;
        this.paymentProvider = paymentProvider;
    }

    public PaymentResult pay(
            PaymentRequest request) {

        // 1. Idempotency check
        Payment existing =
                paymentRepository
                        .findByRequestId(
                                request.getRequestId());

        if (existing != null) {

            return new PaymentResult(
                    existing.getStatus()
                            == PaymentStatus.SUCCESS,
                    existing.getPaymentId(),
                    "Request already processed"
            );
        }

        // 2. Validate request
        if (request.getAmount() <= 0) {

            return new PaymentResult(
                    false,
                    null,
                    "Invalid amount"
            );
        }

        // 3. Create payment
        Payment payment = new Payment(
                UUID.randomUUID().toString(),
                request.getRequestId(),
                request.getCustomerId(),
                request.getAmount(),
                request.getPaymentMethod()
        );

        paymentRepository.save(payment);

        // 4. Mark processing
        payment.markProcessing();

        // 5. Select strategy
        PaymentMethodStrategy strategy =
                PaymentStrategyFactory
                        .getStrategy(
                                request.getPaymentMethod()
                        );

        // 6. Process payment
        PaymentResult result =
                strategy.pay(
                        payment,
                        paymentProvider
                );

        // 7. Update status
        if (result.isSuccess()) {
            payment.markSuccess();
        } else {
            payment.markFailed();
        }

        return result;
    }
}
```

---

# 24. Payment Gateway

Now we expose a simple API to the client.

```java
public class PaymentGateway {

    private final PaymentService paymentService;

    public PaymentGateway(
            PaymentService paymentService) {

        this.paymentService = paymentService;
    }

    public PaymentResult pay(
            PaymentRequest request) {

        return paymentService.pay(request);
    }
}
```

The client doesn't need to know about:

- Stripe
- Razorpay
- Strategies
- Repository
- Payment status management

It only interacts with:

```java
gateway.pay(request);
```

---

# 25. Refund

A refund should be represented separately.

```java
public class Refund {

    private final String refundId;
    private final String paymentId;
    private final double amount;

    public Refund(
            String refundId,
            String paymentId,
            double amount) {

        this.refundId = refundId;
        this.paymentId = paymentId;
        this.amount = amount;
    }

    public String getRefundId() {
        return refundId;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public double getAmount() {
        return amount;
    }
}
```

Refund service:

```java
import java.util.UUID;

public class RefundService {

    private final PaymentRepository paymentRepository;
    private final PaymentProvider paymentProvider;

    public RefundService(
            PaymentRepository paymentRepository,
            PaymentProvider paymentProvider) {

        this.paymentRepository = paymentRepository;
        this.paymentProvider = paymentProvider;
    }

    public PaymentResult refund(
            String paymentId,
            double amount) {

        Payment payment =
                paymentRepository
                        .findByPaymentId(paymentId);

        if (payment == null) {

            return new PaymentResult(
                    false,
                    null,
                    "Payment not found"
            );
        }

        if (payment.getStatus()
                != PaymentStatus.SUCCESS) {

            return new PaymentResult(
                    false,
                    null,
                    "Payment cannot be refunded"
            );
        }

        if (amount <= 0 ||
                amount > payment.getAmount()) {

            return new PaymentResult(
                    false,
                    null,
                    "Invalid refund amount"
            );
        }

        return paymentProvider.refund(
                payment,
                amount
        );
    }
}
```

A production design would track **total refunded amount**, refund status, refund idempotency, and partial refunds explicitly.

---

# 26. Main Example

Let's see the complete flow.

```java
public class Main {

    public static void main(String[] args) {

        // Repository
        PaymentRepository repository =
                new InMemoryPaymentRepository();

        // Provider
        PaymentProvider provider =
                new RazorpayProvider();

        // Service
        PaymentService paymentService =
                new PaymentService(
                        repository,
                        provider
                );

        // Gateway
        PaymentGateway gateway =
                new PaymentGateway(
                        paymentService
                );

        // Request
        PaymentRequest request =
                new PaymentRequest(
                        "REQ123",
                        "USER100",
                        1000,
                        PaymentMethod.CARD
                );

        // Pay
        PaymentResult result =
                gateway.pay(request);

        System.out.println(
                result.getMessage()
        );
    }
}
```

Output:

```text
Validating card details...
Processing payment using Razorpay...
Payment successful
```

---

# 27. Complete Payment Flow

```text
Client
  |
  | PaymentRequest
  v
PaymentGateway
  |
  v
PaymentService
  |
  | Check requestId
  |
  +---- Existing? ---- YES ---> Return existing result
  |
  NO
  |
  v
Create Payment
  |
  v
Save Payment
  |
  v
Select Payment Strategy
  |
  +--------+--------+---------+
  |        |        |         |
 Card     UPI     Wallet   NetBanking
  |        |        |         |
  +--------+--------+---------+
           |
           v
     PaymentProvider
           |
       +---+----+
       |        |
    Stripe   Razorpay
       |        |
       +---+----+
           |
           v
      External API
           |
           v
    PaymentResult
           |
           v
    Update Payment
           |
           v
     Return Result
```

---

# 28. Class Diagram

```text
                         +----------------------+
                         |   PaymentGateway     |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |   PaymentService     |
                         +----------+-----------+
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
        +------------------+                  +------------------+
        | PaymentRepository|                  | PaymentProvider  |
        +--------+---------+                  +--------+---------+
                 |                                     |
                 v                          +----------+----------+
       +------------------+                 |          |          |
       | Payment          |                 v          v          v
       +------------------+              Stripe    Razorpay     PayU
       | paymentId        |
       | requestId        |
       | amount           |
       | status           |
       +------------------+

                    PaymentMethodStrategy
                             |
             +---------------+---------------+
             |               |               |
             v               v               v
        CardStrategy     UPIStrategy    WalletStrategy
```

---

# 29. Relationships

### PaymentGateway HAS-A PaymentService

```text
PaymentGateway
      |
      +---- PaymentService
```

### PaymentService HAS-A PaymentRepository

```text
PaymentService
      |
      +---- PaymentRepository
```

### PaymentService HAS-A PaymentProvider

```text
PaymentService
      |
      +---- PaymentProvider
```

### PaymentProvider IS-A abstraction

```text
PaymentProvider
      |
      +---- RazorpayProvider
      +---- StripeProvider
      +---- PayUProvider
```

### PaymentMethodStrategy IS-A abstraction

```text
PaymentMethodStrategy
      |
      +---- CardPaymentStrategy
      +---- UPIPaymentStrategy
      +---- WalletPaymentStrategy
```

---

# 30. Design Patterns

The most important patterns here are:

## 1. Strategy Pattern

Used for payment methods.

```text
PaymentMethodStrategy
        |
        +-- Card
        +-- UPI
        +-- Wallet
```

Why?

Because payment processing logic varies by payment method.

Adding:

```text
CryptoPayment
```

should not require modifying existing payment strategies.

---

## 2. Strategy Pattern for Providers

`PaymentProvider` is also effectively a strategy abstraction.

```text
PaymentProvider
      |
      +-- Stripe
      +-- Razorpay
      +-- PayU
```

We can change providers without changing the core payment service.

---

## 3. Factory Pattern

We use:

```java
PaymentStrategyFactory.getStrategy(method);
```

to select the appropriate strategy.

---

## 4. Repository Pattern

```java
PaymentRepository
```

separates persistence from business logic.

Today:

```text
InMemoryPaymentRepository
```

Tomorrow:

```text
MySQLPaymentRepository
PostgresPaymentRepository
MongoPaymentRepository
```

The service doesn't need to change.

---

# 31. Why Not Put Everything Inside PaymentService?

A common beginner design is:

```java
class PaymentService {

    void pay(...) {

        if (method == CARD) {
            // card logic
        }

        if (method == UPI) {
            // UPI logic
        }

        if (provider == STRIPE) {
            // Stripe logic
        }

        if (provider == RAZORPAY) {
            // Razorpay logic
        }

        // database logic

        // refund logic

        // validation logic
    }
}
```

This becomes a **God Class**.

Instead:

```text
PaymentGateway
      |
PaymentService
      |
      +---- Strategy
      |
      +---- Provider
      |
      +---- Repository
```

Each class has a focused responsibility.

---

# 32. Idempotency — Very Important

This is one of the most important payment-system interview topics.

Imagine:

```text
Client → Payment Gateway
```

Request:

```text
requestId = REQ123
amount = ₹1000
```

The gateway processes it successfully.

But before the response reaches the client, the network fails.

The client retries:

```text
requestId = REQ123
amount = ₹1000
```

Without idempotency:

```text
First request  → ₹1000 charged
Second request → ₹1000 charged

Total = ₹2000 ❌
```

With idempotency:

```text
First request  → ₹1000 charged
Second request → Existing transaction returned

Total = ₹1000 ✅
```

Therefore:

```text
requestId
   |
   v
Unique constraint
   |
   v
One logical payment
```

In production, the idempotency key should be persisted with a uniqueness constraint and the request/result handling should be designed transactionally.

---

# 33. Payment State Machine

A useful way to think about payment lifecycle:

```text
             +---------+
             | CREATED |
             +----+----+
                  |
                  v
            +-----------+
            | PROCESSING|
            +-----+-----+
                  |
             +----+----+
             |         |
             v         v
        +---------+ +--------+
        | SUCCESS | | FAILED |
        +----+----+ +--------+
             |
             v
        +----------+
        | REFUNDED |
        +----------+
```

Not every real provider follows exactly this simple state machine.

For example, asynchronous payments may have:

```text
PENDING
AUTHORIZED
CAPTURED
FAILED
CANCELLED
REFUND_PENDING
REFUNDED
```

The exact state model should reflect provider behavior and business requirements.

---

# 34. Authorization vs Capture

This is a common payment interview follow-up.

A card payment can conceptually have:

```text
Authorization
      |
      v
Money is reserved
      |
      v
Capture
      |
      v
Money is actually collected
```

For example, an e-commerce company may:

```text
Order placed
     |
     v
Authorize ₹5000
     |
     v
Order shipped
     |
     v
Capture ₹5000
```

So a more advanced design may expose:

```java
authorize()
capture()
voidPayment()
refund()
```

instead of only:

```java
pay()
```

---

# 35. Payment Provider Failure

Suppose:

```text
PaymentService
      |
      v
Razorpay
      |
      X
Network timeout
```

What should happen?

We cannot automatically assume:

```text
FAILED
```

because the provider may have successfully charged the customer but the response was lost.

Example:

```text
Our system → Provider
                |
                | Charge ₹1000
                v
             SUCCESS
                |
                X
          Response lost
```

Our system sees:

```text
TIMEOUT
```

But the customer's money may already have been charged.

Therefore:

> A timeout is not necessarily the same thing as payment failure.

Production systems need:

- Provider transaction IDs
- Status inquiry APIs
- Webhooks
- Reconciliation
- Idempotency
- Retry policies

---

# 36. Webhooks

Payment providers often notify our system asynchronously.

```text
Payment Gateway
       |
       v
Provider
       |
       | Payment processing
       |
       v
Provider
       |
       | Webhook
       v
Our Webhook Endpoint
       |
       v
PaymentService
       |
       v
Update Payment
```

Example:

```text
POST /payment/webhook
```

Payload:

```json
{
  "transactionId": "TXN123",
  "status": "SUCCESS"
}
```

The webhook handler should also be **idempotent**, because providers may retry webhook delivery.

---

# 37. Refund Flow

```text
Customer
    |
    | Refund ₹500
    v
RefundService
    |
    v
Find Payment
    |
    v
Validate Payment
    |
    v
Validate Refund Amount
    |
    v
PaymentProvider
    |
    v
External Provider
    |
    v
Refund Result
```

Important rule:

```text
Total refunded amount
        <=
Original payment amount
```

For example:

```text
Payment = ₹1000

Refund  = ₹400
Refund  = ₹300

Total refunded = ₹700

Remaining refundable = ₹300
```

---

# 38. Partial Refund

A payment can have multiple refunds.

Therefore, don't simply store:

```java
boolean refunded;
```

Instead track:

```text
originalAmount = ₹1000

refunds:
    ₹200
    ₹300

totalRefunded = ₹500

remaining = ₹500
```

This is a better production model.

---

# 39. Money Representation

Avoid:

```java
double amount;
```

for real payment systems.

Floating-point numbers can introduce precision issues.

Prefer:

```java
BigDecimal amount;
```

Example:

```java
BigDecimal amount =
        new BigDecimal("1000.00");
```

or represent money as integer minor units:

```text
₹1000.50
     ↓
100050 paise
```

with an explicit currency.

For example:

```java
class Money {

    private final long minorUnits;
    private final Currency currency;
}
```

This is often safer for financial calculations.

---

# 40. Security

A real payment gateway must never casually store sensitive card information.

For example, avoid storing:

```text
CVV
Full card number
PIN
Passwords
```

Instead use:

```text
Tokenized card
Last 4 digits
Card brand
Provider token
```

Example:

```text
Card Number:
**** **** **** 1234

Provider Token:
tok_abc123
```

Actual payment systems must follow applicable security/compliance requirements.

---

# 41. Concurrency Problem

Suppose:

```text
Request A → ₹1000
Request B → ₹1000
```

Both arrive simultaneously with the same idempotency key.

If both execute:

```text
Check request exists → NO
Check request exists → NO

Create payment
Create payment
```

we have duplicate processing.

Therefore, idempotency must be enforced atomically.

Typical production mechanisms include:

```text
Database unique constraint
        +
Transaction/locking
        +
Idempotent provider request
```

---

# 42. Provider Selection

Suppose we have:

```text
Razorpay
Stripe
PayU
```

We may want:

```text
Card
   |
   +---- Stripe

UPI
   |
   +---- Razorpay

Wallet
   |
   +---- PayU
```

A provider-selection strategy can be introduced.

```java
public interface ProviderSelectionStrategy {

    PaymentProvider selectProvider(
            PaymentRequest request
    );
}
```

Example implementations:

```text
CostBasedProviderStrategy
AvailabilityBasedProviderStrategy
RoundRobinProviderStrategy
```

This is useful when routing depends on:

- Success rate
- Cost
- Payment method
- Geography
- Provider availability
- Traffic distribution

---

# 43. Retry

Suppose provider call fails due to a transient network issue.

We may retry:

```text
Attempt 1
   |
   X
   |
Attempt 2
   |
   X
   |
Attempt 3
```

But blindly retrying payment requests is dangerous.

Why?

Because:

```text
Request may have succeeded
but response may have been lost.
```

Therefore payment retries must use:

```text
Idempotency Key
+
Provider transaction/reference ID
+
Status verification
```

---

# 44. SOLID Principles

## Single Responsibility

```text
PaymentGateway
    → API entry point

PaymentService
    → Payment orchestration

Payment
    → Payment state

PaymentProvider
    → Provider integration

PaymentRepository
    → Persistence

PaymentStrategy
    → Payment-method-specific behavior
```

Each has a focused responsibility.

---

## Open/Closed Principle

Suppose we add:

```text
CryptoPayment
```

We can add:

```java
CryptoPaymentStrategy
```

without changing existing strategies.

---

## Liskov Substitution

Any:

```text
PaymentProvider
```

should be usable wherever a provider is expected:

```text
StripeProvider
RazorpayProvider
PayUProvider
```

---

## Interface Segregation

Instead of one giant interface:

```java
PaymentProvider {
    pay();
    refund();
    capture();
    authorize();
    settlement();
    chargeback();
    ...
}
```

we may split capabilities if providers support different subsets.

For example:

```java
interface PaymentProcessor {
    PaymentResult process(Payment payment);
}

interface RefundProcessor {
    PaymentResult refund(Payment payment, Money amount);
}
```

This can be useful when provider capabilities differ.

---

## Dependency Inversion

Instead of:

```java
PaymentService
      |
      v
RazorpayProvider
```

use:

```text
PaymentService
      |
      v
PaymentProvider
      ^
      |
RazorpayProvider
```

The service depends on an abstraction.

---

# 45. Important Interview Question

### Why do we need both PaymentMethod and PaymentProvider?

Because they represent two different concepts.

### Payment Method

How the customer pays:

```text
CARD
UPI
WALLET
NET_BANKING
```

### Payment Provider

Which external company processes the payment:

```text
Stripe
Razorpay
PayU
Adyen
```

So:

```text
Payment Method        Payment Provider

CARD             →    Stripe
CARD             →    Razorpay

UPI              →    Razorpay
UPI              →    PayU
```

They should not be combined into one enum.

---

# 46. Important Interview Question

### Why not create classes like:

```text
RazorpayCardPayment
RazorpayUPIPayment
StripeCardPayment
StripeUPIPayment
```

Because this creates a Cartesian-product problem.

With:

```text
4 payment methods
3 providers
```

we could end up with:

```text
4 × 3 = 12 classes
```

As both dimensions grow, the number of classes explodes.

Instead, separate the dimensions:

```text
Payment Method Strategy
          +
Payment Provider
```

This is a key design insight.

---

# 47. Production Architecture

A more realistic architecture could look like:

```text
                  Client
                    |
                    v
               API Gateway
                    |
                    v
             Payment Service
                    |
          +---------+---------+
          |                   |
          v                   v
   Payment Database      Message Queue
          |                   |
          |                   v
          |             Async Worker
          |                   |
          +---------+---------+
                    |
                    v
            Provider Router
                    |
        +-----------+-----------+
        |           |           |
        v           v           v
    Razorpay     Stripe       PayU
        |           |           |
        +-----------+-----------+
                    |
                    v
             Provider Webhooks
                    |
                    v
             Payment Service
```

---

# 48. Database Model

A simplified payment table:

```text
Payment
--------------------------------
payment_id
request_id
customer_id
amount
currency
payment_method
provider
provider_transaction_id
status
created_at
updated_at
```

Important indexes:

```text
UNIQUE(request_id)

INDEX(customer_id)

INDEX(provider_transaction_id)
```

The exact schema depends on the system and database.

---

# 49. Payment State Transitions

We should validate legal transitions.

For example:

```text
CREATED → PROCESSING
PROCESSING → SUCCESS
PROCESSING → FAILED
SUCCESS → REFUND_PENDING
REFUND_PENDING → REFUNDED
```

But:

```text
FAILED → REFUNDED
```

doesn't make sense.

Likewise:

```text
REFUNDED → SUCCESS
```

should not normally happen.

A state machine or explicit transition validation becomes useful as the system grows.

---

# 50. Edge Cases

An interviewer may ask about:

### Invalid amount

```text
₹0
negative amount
```

Reject.

### Duplicate request

Use:

```text
Idempotency Key
```

### Provider timeout

Don't blindly mark failed.

Use:

```text
status inquiry
webhook
reconciliation
```

### Provider unavailable

Potentially:

```text
Provider A unavailable
        ↓
Provider B
```

if the business/payment method supports fallback.

### Duplicate webhook

Process webhook idempotently.

### Partial refund

Track:

```text
original amount
total refunded
remaining refundable
```

### Concurrent refunds

Prevent two simultaneous requests from refunding more than the original payment amount.

### Database failure

Payment state must be recoverable/reconciled.

### Provider succeeds but database update fails

This is a critical distributed consistency problem.

Use:

- provider transaction ID
- reconciliation
- webhook
- retry
- durable event/outbox mechanisms where appropriate

---

# 51. Common Beginner Mistakes

## Mistake 1: God Class

```text
PaymentService
    |
    +-- Card logic
    +-- UPI logic
    +-- Stripe logic
    +-- Refund logic
    +-- Database logic
    +-- Validation
```

Avoid this.

---

## Mistake 2: Mixing Payment Method and Provider

Don't do:

```java
CARD_RAZORPAY
CARD_STRIPE
UPI_RAZORPAY
```

Separate them.

---

## Mistake 3: Ignoring Idempotency

This is one of the biggest payment-system mistakes.

---

## Mistake 4: Treating Timeout as Failure

A timeout can mean:

```text
Unknown payment state
```

not necessarily:

```text
FAILED
```

---

## Mistake 5: Using `double` for money

Use:

```java
BigDecimal
```

or integer minor units.

---

## Mistake 6: Ignoring Webhooks

Payment providers often complete operations asynchronously.

---

# 52. Suggested Project Structure

```text
src/
│
├── gateway/
│   └── PaymentGateway.java
│
├── service/
│   ├── PaymentService.java
│   └── RefundService.java
│
├── model/
│   ├── Payment.java
│   ├── PaymentRequest.java
│   ├── PaymentResult.java
│   └── Refund.java
│
├── strategy/
│   ├── PaymentMethodStrategy.java
│   ├── CardPaymentStrategy.java
│   ├── UPIPaymentStrategy.java
│   └── WalletPaymentStrategy.java
│
├── provider/
│   ├── PaymentProvider.java
│   ├── StripeProvider.java
│   ├── RazorpayProvider.java
│   └── PayUProvider.java
│
├── repository/
│   ├── PaymentRepository.java
│   └── InMemoryPaymentRepository.java
│
├── factory/
│   └── PaymentStrategyFactory.java
│
└── enums/
    ├── PaymentMethod.java
    └── PaymentStatus.java
```

---

# 53. Interview Opening

You can start your interview answer like this:

> "I'll design the payment gateway as an orchestration layer that is independent of specific payment providers. I'll separate the payment method, such as Card or UPI, from the provider, such as Razorpay or Stripe. I'll use Strategy Pattern for payment-method-specific behavior, an abstraction for provider integrations, and a repository for persistence. I'll also explicitly handle idempotency because duplicate payment processing is a critical requirement. For production, I'd additionally consider asynchronous payments, webhooks, retries, reconciliation, secure tokenization and concurrency."

---

# 54. Interview Follow-Up Questions

Be prepared for:

### Q1. How will you avoid duplicate payments?

```text
Idempotency key
+
Database uniqueness
+
Provider idempotency
```

### Q2. What happens if provider times out?

```text
Don't immediately mark FAILED.

Check provider status
+
Webhook
+
Reconciliation
```

### Q3. How do you add a new payment method?

Add:

```java
NewPaymentStrategy
```

and register it.

### Q4. How do you add a new provider?

Implement:

```java
PaymentProvider
```

### Q5. How do you support multiple providers?

Use:

```text
Provider abstraction
+
Provider selection strategy
```

### Q6. How do you support refunds?

Separate:

```text
RefundService
```

and track refund state/amount.

### Q7. How do you handle asynchronous payments?

Use:

```text
PROCESSING/PENDING
        |
        v
Webhook
        |
        v
SUCCESS / FAILED
```

### Q8. What if payment succeeds but our DB update fails?

Use:

```text
Provider transaction ID
+
Webhook
+
Retry
+
Reconciliation
```

### Q9. How do you handle high traffic?

Use:

```text
Stateless payment services
        +
Database
        +
Queue
        +
Caching where appropriate
        +
Provider routing
```

### Q10. How do you secure card details?

Use:

```text
Tokenization
+
Do not store CVV
+
Encryption
+
Access controls
+
PCI-compliant architecture
```

---

# 55. Final Mental Model

Remember this:

```text
                PAYMENT GATEWAY
                       |
                       v
                PaymentRequest
                       |
                       v
                 PaymentService
                       |
             +---------+---------+
             |                   |
             v                   v
       Payment Method       Payment Provider
          Strategy              Strategy
             |                   |
      +------+------+       +----+----+
      |      |     |        |         |
     Card   UPI  Wallet   Stripe   Razorpay
             |                   |
             +---------+---------+
                       |
                       v
                External Provider
                       |
                       v
                PaymentResult
                       |
                       v
                  Payment
                       |
                       v
                  Database
```

The most important separation is:

```text
HOW customer pays
        ↓
Payment Method

WHO processes it
        ↓
Payment Provider

WHO coordinates everything
        ↓
Payment Service

WHERE payment is stored
        ↓
Payment Repository
```

---

# 56. One-Line Interview Summary

> **"I would design the Payment Gateway with a PaymentService as the orchestration layer, separate PaymentMethod strategies from PaymentProvider integrations, use Repository abstraction for persistence and Factory/Strategy patterns for extensibility, while treating idempotency, asynchronous provider responses, webhooks, refunds, concurrency, security and reconciliation as key production concerns."**

:::end

This is a strong **LLD interview baseline**. The next level would be designing a **production-grade payment gateway with idempotency, webhooks, provider failover, authorization/capture, refunds, and database transactions**—which is where most senior-level follow-up questions go.