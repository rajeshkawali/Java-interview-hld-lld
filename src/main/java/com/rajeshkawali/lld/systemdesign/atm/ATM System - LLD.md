# ATM System — Low-Level Design (LLD)

## 1. Problem Statement

Design an ATM system that allows a bank customer to:

- Insert a card.
- Enter a PIN.
- Check account balance.
- Withdraw cash.
- Deposit cash.
- Transfer money.
- Eject the card.

The ATM should:

- Validate the card.
- Authenticate the customer.
- Check account balance.
- Check whether enough cash is available in the ATM.
- Dispense the correct denominations.
- Update the customer's account.
- Handle invalid operations safely.

For the basic design, we'll focus on:

```text
Insert Card
     ↓
Enter PIN
     ↓
Authenticate
     ↓
Select Transaction
     ↓
Perform Transaction
     ↓
Eject Card
```

---

# 2. First Understand the Flow

A typical withdrawal looks like this:

```text
Customer
   |
   | Insert Card
   v
ATM
   |
   | Enter PIN
   v
Authenticate
   |
   | Valid
   v
Select "Withdraw"
   |
   | Enter Amount
   v
Check Account Balance
   |
   | Enough balance
   v
Check ATM Cash
   |
   | Enough cash
   v
Dispense Cash
   |
   v
Update Account
   |
   v
Transaction Complete
```

The important LLD question is:

> What objects are responsible for each part of this process?

---

# 3. Identify the Main Entities

From the requirements, we can identify:

```text
ATM
Card
Account
Customer
Transaction
CashDispenser
Bank
```

We can further divide transactions into:

```text
Withdrawal
Deposit
BalanceInquiry
Transfer
```

---

# 4. Basic Class Structure

Our initial design:

```text
ATM
 |
 +-- Card
 |
 +-- Bank
      |
      +-- Customer
      |
      +-- Account
      |
      +-- Transaction

ATM
 |
 +-- CashDispenser
```

The ATM acts as the coordinator.

But we should **not put every piece of business logic inside ATM**.

---

# 5. Important Principle

A common beginner mistake is creating one huge class:

```text
ATM
 |
 +-- authenticate()
 +-- withdraw()
 +-- deposit()
 +-- calculateBalance()
 +-- dispenseCash()
 +-- validateCard()
 +-- updateAccount()
 +-- transferMoney()
 +-- ...
```

This makes `ATM` responsible for too many things.

Instead:

```text
ATM
 → Controls ATM workflow

Bank
 → Handles banking operations

Account
 → Owns account balance

Card
 → Represents card

CashDispenser
 → Manages physical cash

Transaction
 → Represents a transaction
```

This is much cleaner.

---

# 6. ATM States

An ATM goes through different states.

```java
public enum ATMState {
    IDLE,
    CARD_INSERTED,
    AUTHENTICATED,
    TRANSACTION_IN_PROGRESS,
    OUT_OF_SERVICE
}
```

The basic flow is:

```text
IDLE
  |
  | Insert card
  v
CARD_INSERTED
  |
  | Valid PIN
  v
AUTHENTICATED
  |
  | Select transaction
  v
TRANSACTION_IN_PROGRESS
  |
  | Complete
  v
IDLE
```

---

# 7. Card

A card contains information required to identify the customer's account.

```java
public class Card {

    private String cardNumber;
    private String expiryDate;
    private String pin;
    private boolean blocked;

    public Card(
            String cardNumber,
            String expiryDate,
            String pin) {

        this.cardNumber = cardNumber;
        this.expiryDate = expiryDate;
        this.pin = pin;
        this.blocked = false;
    }

    public boolean validatePin(String enteredPin) {

        return !blocked && pin.equals(enteredPin);
    }

    public void block() {
        blocked = true;
    }

    public boolean isBlocked() {
        return blocked;
    }

    public String getCardNumber() {
        return cardNumber;
    }
}
```

### Important note

In a real system, we should **never store a plaintext PIN like this**. Authentication would normally involve secure cryptographic handling and a bank-side authorization service.

For LLD learning, we're simplifying it.

---

# 8. Account

The account owns the customer's balance.

```java
public class Account {

    private String accountNumber;
    private double balance;

    public Account(
            String accountNumber,
            double balance) {

        this.accountNumber = accountNumber;
        this.balance = balance;
    }

    public boolean hasSufficientBalance(double amount) {

        return balance >= amount;
    }

    public void debit(double amount) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Amount must be positive"
            );
        }

        if (!hasSufficientBalance(amount)) {
            throw new IllegalStateException(
                    "Insufficient account balance"
            );
        }

        balance -= amount;
    }

    public void credit(double amount) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Amount must be positive"
            );
        }

        balance += amount;
    }

    public double getBalance() {
        return balance;
    }

    public String getAccountNumber() {
        return accountNumber;
    }
}
```

---

# 9. Why Does Account Manage Balance?

We don't want:

```java
account.balance -= 1000;
```

from arbitrary classes.

Instead:

```java
account.debit(1000);
```

The `Account` class can enforce rules.

For example:

```text
Balance = ₹5000

debit(₹3000)
       ↓
Balance = ₹2000
```

But:

```text
debit(₹6000)
       ↓
ERROR
```

This protects the object's state.

---

# 10. Customer

A customer represents the bank customer.

```java
public class Customer {

    private String customerId;
    private String name;
    private Card card;
    private Account account;

    public Customer(
            String customerId,
            String name,
            Card card,
            Account account) {

        this.customerId = customerId;
        this.name = name;
        this.card = card;
        this.account = account;
    }

    public String getCustomerId() {
        return customerId;
    }

    public String getName() {
        return name;
    }

    public Card getCard() {
        return card;
    }

    public Account getAccount() {
        return account;
    }
}
```

For simplicity, we're assuming one card and one account.

A real banking system would likely support multiple accounts/cards and a more sophisticated relationship.

---

# 11. Bank

The ATM should not directly maintain every customer account.

The bank can maintain customer/card information.

```java
import java.util.HashMap;
import java.util.Map;

public class Bank {

    private Map<String, Customer> customers;

    public Bank() {
        customers = new HashMap<>();
    }

    public void addCustomer(Customer customer) {

        customers.put(
                customer.getCard().getCardNumber(),
                customer
        );
    }

    public Customer authenticate(
            String cardNumber,
            String pin) {

        Customer customer =
                customers.get(cardNumber);

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Invalid card"
            );
        }

        Card card = customer.getCard();

        if (card.isBlocked()) {
            throw new IllegalStateException(
                    "Card is blocked"
            );
        }

        if (!card.validatePin(pin)) {
            throw new IllegalArgumentException(
                    "Invalid PIN"
            );
        }

        return customer;
    }
}
```

---

# 12. Why Does ATM Need Bank?

The ATM is only a machine/interface.

It should not own all bank accounts.

Think:

```text
                ATM
                 |
                 | request
                 v
               Bank
                 |
       +---------+---------+
       |                   |
       v                   v
   Customer             Account
```

The ATM asks the bank to authenticate and perform banking operations.

In a real system, the ATM would communicate with bank servers over a secure network rather than keeping the entire customer database locally.

---

# 13. Cash Dispenser

The ATM needs to manage physical cash.

For example:

```text
ATM Cash:

₹500 × 10
₹200 × 5
₹100 × 20
```

We can model this with:

```java
import java.util.Map;
import java.util.TreeMap;

public class CashDispenser {

    private Map<Integer, Integer> cash;

    public CashDispenser() {

        cash = new TreeMap<>();
    }

    public void addCash(
            int denomination,
            int count) {

        cash.put(
                denomination,
                cash.getOrDefault(denomination, 0) + count
        );
    }

    public int getTotalCash() {

        int total = 0;

        for (Map.Entry<Integer, Integer> entry
                : cash.entrySet()) {

            total +=
                    entry.getKey()
                    * entry.getValue();
        }

        return total;
    }
}
```

---

# 14. Can ATM Dispense Any Amount?

No.

Suppose ATM contains:

```text
₹500 notes
₹200 notes
₹100 notes
```

Customer asks for:

```text
₹750
```

It cannot dispense ₹750 if it only has these denominations.

Therefore we need a method:

```java
canDispense(amount)
```

and:

```java
dispense(amount)
```

---

# 15. Cash Dispensing Algorithm

For a simple ATM, we can use a greedy approach.

Example:

```text
Requested = ₹2700

Available:
₹500 × 5
₹200 × 5
₹100 × 10
```

We can dispense:

```text
₹500 × 5 = ₹2500
₹200 × 1 = ₹200

Total = ₹2700
```

Implementation:

```java
import java.util.Map;
import java.util.TreeMap;

public class CashDispenser {

    private Map<Integer, Integer> cash;

    public CashDispenser() {
        cash = new TreeMap<>();
    }

    public void addCash(
            int denomination,
            int count) {

        cash.put(
                denomination,
                cash.getOrDefault(denomination, 0) + count
        );
    }

    public boolean canDispense(int amount) {

        int remaining = amount;

        for (Integer denomination
                : cash.descendingKeySet()) {

            int available =
                    cash.get(denomination);

            int notesNeeded =
                    Math.min(
                            remaining / denomination,
                            available
                    );

            remaining -=
                    notesNeeded * denomination;

            if (remaining == 0) {
                return true;
            }
        }

        return false;
    }

    public Map<Integer, Integer> dispense(
            int amount) {

        if (!canDispense(amount)) {
            throw new IllegalStateException(
                    "Cannot dispense requested amount"
            );
        }

        int remaining = amount;

        Map<Integer, Integer> result =
                new TreeMap<>(
                        (a, b) -> b - a
                );

        for (Integer denomination
                : cash.descendingKeySet()) {

            int available =
                    cash.get(denomination);

            int notesNeeded =
                    Math.min(
                            remaining / denomination,
                            available
                    );

            if (notesNeeded > 0) {

                result.put(
                        denomination,
                        notesNeeded
                );

                remaining -=
                        notesNeeded * denomination;

                cash.put(
                        denomination,
                        available - notesNeeded
                );
            }

            if (remaining == 0) {
                break;
            }
        }

        return result;
    }
}
```

---

# 16. Important Caveat About Greedy

Greedy doesn't work for every possible denomination system.

For example, arbitrary denominations can require a different algorithm.

For a real ATM, denominations and cassette constraints are known and controlled, so a suitable dispensing algorithm can be selected accordingly.

For an interview, you can say:

> "I'll assume standard denominations for which the greedy approach is valid. If arbitrary denominations are supported, I would use a bounded subset/coin-change style algorithm."

This demonstrates good design thinking.

---

# 17. Transaction

Now we need to represent transactions.

```java
public abstract class Transaction {

    protected String transactionId;
    protected Account account;
    protected double amount;

    public Transaction(
            String transactionId,
            Account account,
            double amount) {

        this.transactionId = transactionId;
        this.account = account;
        this.amount = amount;
    }

    public abstract void execute();
}
```

This allows us to create:

```text
Transaction
    |
    +---- Withdrawal
    |
    +---- Deposit
    |
    +---- BalanceInquiry
    |
    +---- Transfer
```

---

# 18. Withdrawal Transaction

```java
import java.util.Map;

public class WithdrawalTransaction
        extends Transaction {

    private CashDispenser cashDispenser;

    public WithdrawalTransaction(
            String transactionId,
            Account account,
            double amount,
            CashDispenser cashDispenser) {

        super(
                transactionId,
                account,
                amount
        );

        this.cashDispenser = cashDispenser;
    }

    @Override
    public void execute() {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Invalid withdrawal amount"
            );
        }

        if (!account.hasSufficientBalance(amount)) {
            throw new IllegalStateException(
                    "Insufficient account balance"
            );
        }

        if (!cashDispenser.canDispense(
                (int) amount)) {

            throw new IllegalStateException(
                    "ATM cannot dispense this amount"
            );
        }

        Map<Integer, Integer> notes =
                cashDispenser.dispense(
                        (int) amount
                );

        account.debit(amount);

        System.out.println(
                "Cash dispensed: " + notes
        );
    }
}
```

---

# 19. Important Ordering Problem

Notice something important.

We need to avoid this situation:

```text
ATM cash successfully removed
       |
       v
Account debit fails
       |
       v
Customer loses money
```

In a real system, cash dispensing and account debit involve **different systems/resources**, so this needs transactional/reconciliation logic rather than a simple Java method call.

For an LLD interview, mention:

> "Withdrawal needs atomicity across authorization, account debit, and cash dispensing. In production, I'd use a transaction protocol/idempotency/reconciliation mechanism so a failure at any step doesn't cause double debit or lost funds."

For the simple in-memory model, we can perform validation before dispensing and then debit after successful dispensing.

---

# 20. Deposit Transaction

```java
public class DepositTransaction
        extends Transaction {

    public DepositTransaction(
            String transactionId,
            Account account,
            double amount) {

        super(
                transactionId,
                account,
                amount
        );
    }

    @Override
    public void execute() {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Invalid deposit amount"
            );
        }

        account.credit(amount);

        System.out.println(
                "Deposited: " + amount
        );
    }
}
```

---

# 21. Balance Inquiry

A balance inquiry doesn't modify the account.

```java
public class BalanceInquiryTransaction
        extends Transaction {

    public BalanceInquiryTransaction(
            String transactionId,
            Account account) {

        super(
                transactionId,
                account,
                0
        );
    }

    @Override
    public void execute() {

        System.out.println(
                "Current balance: "
                        + account.getBalance()
        );
    }
}
```

---

# 22. Transaction Type

We could also define:

```java
public enum TransactionType {
    WITHDRAWAL,
    DEPOSIT,
    BALANCE_INQUIRY,
    TRANSFER
}
```

This is useful if we need to record transaction history.

---

# 23. ATM Class

Now we can create the central `ATM`.

Its responsibilities:

- Accept card.
- Authenticate user.
- Maintain ATM state.
- Start transactions.
- Eject card.
- Coordinate bank and cash dispenser.

```java
public class ATM {

    private ATMState state;

    private Bank bank;
    private CashDispenser cashDispenser;

    private Card currentCard;
    private Customer currentCustomer;

    public ATM(
            Bank bank,
            CashDispenser cashDispenser) {

        this.bank = bank;
        this.cashDispenser = cashDispenser;

        this.state = ATMState.IDLE;
    }

    public void insertCard(Card card) {

        if (state != ATMState.IDLE) {
            throw new IllegalStateException(
                    "ATM is not ready"
            );
        }

        this.currentCard = card;
        this.state = ATMState.CARD_INSERTED;

        System.out.println("Card inserted");
    }

    public void authenticate(String pin) {

        if (state != ATMState.CARD_INSERTED) {
            throw new IllegalStateException(
                    "Insert card first"
            );
        }

        currentCustomer =
                bank.authenticate(
                        currentCard.getCardNumber(),
                        pin
                );

        state = ATMState.AUTHENTICATED;

        System.out.println(
                "Authentication successful"
        );
    }

    public double checkBalance() {

        validateAuthenticated();

        return currentCustomer
                .getAccount()
                .getBalance();
    }

    public void withdraw(double amount) {

        validateAuthenticated();

        state = ATMState.TRANSACTION_IN_PROGRESS;

        Transaction transaction =
                new WithdrawalTransaction(
                        "TXN-" + System.currentTimeMillis(),
                        currentCustomer.getAccount(),
                        amount,
                        cashDispenser
                );

        transaction.execute();

        state = ATMState.AUTHENTICATED;
    }

    public void deposit(double amount) {

        validateAuthenticated();

        state = ATMState.TRANSACTION_IN_PROGRESS;

        Transaction transaction =
                new DepositTransaction(
                        "TXN-" + System.currentTimeMillis(),
                        currentCustomer.getAccount(),
                        amount
                );

        transaction.execute();

        state = ATMState.AUTHENTICATED;
    }

    public void ejectCard() {

        if (currentCard == null) {
            return;
        }

        currentCard = null;
        currentCustomer = null;

        state = ATMState.IDLE;

        System.out.println("Card ejected");
    }

    private void validateAuthenticated() {

        if (state != ATMState.AUTHENTICATED) {
            throw new IllegalStateException(
                    "Please authenticate first"
            );
        }
    }
}
```

---

# 24. Main Class

Let's use the system.

```java
public class Main {

    public static void main(String[] args) {

        // Create account

        Account account =
                new Account(
                        "ACC1001",
                        10000
                );

        // Create card

        Card card =
                new Card(
                        "CARD123",
                        "12/29",
                        "1234"
                );

        // Create customer

        Customer customer =
                new Customer(
                        "CUST1",
                        "Rahul",
                        card,
                        account
                );

        // Create bank

        Bank bank = new Bank();

        bank.addCustomer(customer);

        // Create cash dispenser

        CashDispenser cashDispenser =
                new CashDispenser();

        cashDispenser.addCash(500, 20);
        cashDispenser.addCash(200, 20);
        cashDispenser.addCash(100, 20);

        // Create ATM

        ATM atm =
                new ATM(
                        bank,
                        cashDispenser
                );

        // Start ATM transaction

        atm.insertCard(card);

        atm.authenticate("1234");

        System.out.println(
                "Balance: "
                        + atm.checkBalance()
        );

        atm.withdraw(2700);

        System.out.println(
                "Balance after withdrawal: "
                        + atm.checkBalance()
        );

        atm.deposit(1000);

        System.out.println(
                "Balance after deposit: "
                        + atm.checkBalance()
        );

        atm.ejectCard();
    }
}
```

---

# 25. Complete Class Diagram

```text
                         +----------------+
                         |      ATM       |
                         +----------------+
                         | - state        |
                         | - bank         |
                         | - cashDispenser|
                         | - currentCard  |
                         | - customer     |
                         +-------+--------+
                                 |
                +----------------+----------------+
                |                                 |
                v                                 v
         +-------------+                  +----------------+
         |    Bank     |                  | CashDispenser  |
         +-------------+                  +----------------+
         | - customers |                  | - cash         |
         +------+------+                  +----------------+
                |
                | HAS MANY
                v
         +-------------+
         |  Customer   |
         +------+------+
                |
          +-----+-----+
          |           |
          v           v
       +------+   +---------+
       | Card |   | Account |
       +------+   +---------+


              +-------------------+
              |    Transaction    |
              +-------------------+
              | transactionId     |
              | account           |
              | amount            |
              +---------+---------+
                        |
          +-------------+-------------+
          |             |             |
          v             v             v
    +-----------+ +-----------+ +----------------+
    |Withdrawal | | Deposit   | |BalanceInquiry |
    +-----------+ +-----------+ +----------------+
```

---

# 26. Relationships

## ATM HAS-A Bank

```text
ATM
 |
 +---- Bank
```

The ATM communicates with the bank to authenticate customers and access accounts.

---

## ATM HAS-A CashDispenser

```text
ATM
 |
 +---- CashDispenser
```

The dispenser manages the physical cash.

---

## Customer HAS-A Card

```text
Customer
 |
 +---- Card
```

---

## Customer HAS-A Account

```text
Customer
 |
 +---- Account
```

---

## Transaction HAS-A Account

```text
Transaction
 |
 +---- Account
```

A transaction operates on an account.

---

## Withdrawal IS-A Transaction

```text
WithdrawalTransaction
          |
          | extends
          v
     Transaction
```

Same for:

```text
DepositTransaction
BalanceInquiryTransaction
```

---

# 27. Why Use an Abstract Transaction?

We could have simply put:

```java
atm.withdraw();
atm.deposit();
atm.checkBalance();
```

directly inside ATM.

But transaction objects become useful when we need:

```text
Transaction
 |
 +-- ID
 +-- timestamp
 +-- account
 +-- amount
 +-- status
 +-- type
```

Now we can maintain transaction history:

```text
Transaction History

TXN001 → Withdrawal → ₹2000
TXN002 → Deposit    → ₹5000
TXN003 → Withdrawal → ₹1000
```

This is valuable in a banking system.

---

# 28. Transaction Status

We can add:

```java
public enum TransactionStatus {
    CREATED,
    PROCESSING,
    SUCCESS,
    FAILED
}
```

Then:

```text
CREATED
   |
   v
PROCESSING
   |
   +---- SUCCESS
   |
   +---- FAILED
```

This becomes especially important when dealing with external banking/payment systems.

---

# 29. State Pattern

Our current ATM uses:

```java
ATMState
```

as an enum.

That's enough for a simple system.

But imagine ATM behavior becomes more complicated:

```text
IDLE
CARD_INSERTED
PIN_ENTRY
AUTHENTICATED
TRANSACTION
OUT_OF_SERVICE
```

Each state might allow different operations.

For example:

```text
IDLE
→ insertCard()

CARD_INSERTED
→ enterPin()
→ ejectCard()

AUTHENTICATED
→ withdraw()
→ deposit()
→ checkBalance()
→ ejectCard()

OUT_OF_SERVICE
→ nothing
```

At this point, the **State Pattern** can be useful.

For a basic interview:

> Start with an enum. Explain that State Pattern can be introduced if state-specific behavior becomes complex.

---

# 30. PIN Retry Logic

A realistic ATM should limit PIN attempts.

For example:

```text
Attempt 1 → Wrong
Attempt 2 → Wrong
Attempt 3 → Wrong
                  |
                  v
              Card Blocked
```

We can add:

```java
private int failedAttempts;
private static final int MAX_ATTEMPTS = 3;
```

Then:

```java
public boolean validatePin(String enteredPin) {

    if (blocked) {
        return false;
    }

    if (pin.equals(enteredPin)) {

        failedAttempts = 0;
        return true;
    }

    failedAttempts++;

    if (failedAttempts >= MAX_ATTEMPTS) {
        blocked = true;
    }

    return false;
}
```

---

# 31. ATM Cash Limit

The ATM itself can have a cash limit.

For example:

```text
ATM total cash = ₹100,000
```

If the customer asks:

```text
₹120,000
```

the ATM rejects the request.

We already indirectly handle this with:

```java
cashDispenser.canDispense(amount)
```

because it considers the actual notes available.

---

# 32. Withdrawal Validation

A withdrawal should pass all these checks:

```text
             Withdrawal
                  |
        +---------+---------+
        |         |         |
        v         v         v
   Authenticated Balance   ATM Cash
        |         |         |
        +---------+---------+
                  |
                  v
              Valid?
             /      \
           No        Yes
           |          |
           v          v
         Reject    Dispense
```

Additional checks can include:

```text
Amount > 0
Amount within daily limit
Amount within per-transaction limit
Valid denominations
Account not frozen
ATM operational
```

---

# 33. Daily Withdrawal Limit

Suppose the bank allows:

```text
Daily withdrawal limit = ₹50,000
```

Then the account/customer needs to track withdrawal usage.

We could introduce:

```java
private double dailyWithdrawalAmount;
```

or, preferably, derive it from transaction history/a bank-side limit service.

Conceptually:

```text
Requested = ₹20,000

Already withdrawn today = ₹40,000

Daily limit = ₹50,000

Remaining limit = ₹10,000

₹20,000 → REJECT
```

This business rule should not live inside `CashDispenser`.

The dispenser only cares about:

> Can I physically dispense these notes?

The bank/account side should handle financial limits.

---

# 34. Important Separation

This is a very important LLD concept.

### CashDispenser asks:

```text
Can I physically dispense ₹5000?
```

### Account asks:

```text
Does the customer have ₹5000?
```

### Bank asks:

```text
Is this withdrawal allowed?
```

### ATM asks:

```text
What is the current workflow?
```

Different objects have different responsibilities.

---

# 35. Transfer Transaction

If requirements include transferring money, we can add:

```text
TransferTransaction
 |
 +-- sourceAccount
 +-- destinationAccount
 +-- amount
```

Example:

```java
public class TransferTransaction
        extends Transaction {

    private Account destinationAccount;

    public TransferTransaction(
            String transactionId,
            Account sourceAccount,
            Account destinationAccount,
            double amount) {

        super(
                transactionId,
                sourceAccount,
                amount
        );

        this.destinationAccount =
                destinationAccount;
    }

    @Override
    public void execute() {

        account.debit(amount);

        destinationAccount.credit(amount);
    }
}
```

In production, this must be an **atomic bank transaction** so that you never end up with the source debited but the destination not credited.

---

# 36. SOLID Principles

## Single Responsibility Principle

```text
Card
→ Card information/authentication state

Account
→ Balance and account operations

CashDispenser
→ Physical cash management

Bank
→ Customer/account authentication and banking authority

ATM
→ ATM workflow

Transaction
→ Transaction behavior
```

Each class has a focused responsibility.

---

# 37. Open/Closed Principle

We can add:

```text
MiniStatementTransaction
TransferTransaction
BillPaymentTransaction
```

without changing the basic transaction abstraction.

---

# 38. Liskov Substitution Principle

Because:

```text
WithdrawalTransaction
DepositTransaction
BalanceInquiryTransaction
```

are all `Transaction`s, code that works with a `Transaction` should be able to work with each concrete transaction.

---

# 39. Dependency Inversion Principle

The ATM could depend on abstractions instead of concrete banking implementations.

For example:

```java
public interface BankingService {

    Customer authenticate(
            String cardNumber,
            String pin
    );

    void debit(
            Account account,
            double amount
    );
}
```

Then:

```text
ATM
 |
 v
BankingService
 |
 +---- BankService
 +---- MockBankingService
```

This is particularly useful for testing.

---

# 40. Testing Becomes Easier

Suppose ATM directly creates:

```java
new Bank();
```

inside itself.

Testing becomes harder.

Instead:

```java
public ATM(
        BankingService bankingService,
        CashDispenser cashDispenser) {

    ...
}
```

Now we can inject a fake/mock banking service.

This is **Dependency Injection**.

---

# 41. Design Patterns in ATM

The useful patterns are:

### 1. State Pattern

Useful when ATM states become complex.

```text
IDLE
CARD_INSERTED
AUTHENTICATED
TRANSACTION
OUT_OF_SERVICE
```

---

### 2. Strategy Pattern

Potentially useful for cash dispensing algorithms.

```text
CashDispensingStrategy
       |
       +---- GreedyStrategy
       |
       +---- OptimalDispensingStrategy
```

However, for a simple ATM, this may be unnecessary.

---

### 3. Factory Pattern

Could be used to create transactions:

```java
TransactionFactory.create(
    TransactionType.WITHDRAWAL,
    ...
);
```

Useful if transaction creation becomes complicated.

But don't introduce it just for the sake of using a pattern.

---

# 42. Interview-Level Architecture

A clean interview-level design can be:

```text
                       +----------------+
                       |      ATM       |
                       +-------+--------+
                               |
               +---------------+---------------+
               |                               |
               v                               v
       +---------------+               +---------------+
       | BankingService|               | CashDispenser |
       +-------+-------+               +---------------+
               |
               v
           +-------+
           | Bank  |
           +---+---+
               |
       +-------+-------+
       |               |
       v               v
    Customer        Account
       |
       v
     Card


             +----------------+
             |  Transaction   |
             +-------+--------+
                     |
          +----------+----------+
          |          |          |
          v          v          v
     Withdrawal   Deposit   BalanceInquiry
```

---

# 43. Complete ATM Flow

Let's put everything together.

### Step 1

Customer inserts card.

```java
atm.insertCard(card);
```

ATM:

```text
IDLE
 ↓
CARD_INSERTED
```

---

### Step 2

Customer enters PIN.

```java
atm.authenticate("1234");
```

Bank validates:

```text
Card
 +
PIN
 ↓
Bank
 ↓
Customer
```

ATM:

```text
CARD_INSERTED
 ↓
AUTHENTICATED
```

---

### Step 3

Customer selects withdrawal.

```java
atm.withdraw(5000);
```

---

### Step 4

System checks:

```text
Is customer authenticated?
        ↓
Does account have ₹5000?
        ↓
Can ATM dispense ₹5000?
        ↓
Is withdrawal within limits?
```

---

### Step 5

Cash is dispensed.

```text
₹500 × 10
```

---

### Step 6

Account is debited.

```text
₹20,000
   ↓
₹15,000
```

---

### Step 7

Transaction completes.

```text
TRANSACTION_IN_PROGRESS
          ↓
      AUTHENTICATED
```

---

### Step 8

Customer ejects card.

```java
atm.ejectCard();
```

ATM:

```text
AUTHENTICATED
      ↓
     IDLE
```

---

# 44. Important Edge Cases

An interviewer may ask about these.

### Invalid card

```text
Reject transaction
```

### Invalid PIN

```text
Reject
Increment failed attempts
```

### Three wrong PIN attempts

```text
Block card
```

### Insufficient balance

```text
Reject withdrawal
```

### Insufficient ATM cash

```text
Reject withdrawal
```

### Invalid denomination

```text
Reject withdrawal
```

### ATM out of service

```text
Reject new transaction
```

### Card removed unexpectedly

```text
Terminate session
Return ATM to safe state
```

### Cash dispenser failure

```text
Do not blindly mark transaction successful
Reconcile transaction
```

### Network failure

```text
Transaction should be safely retryable/idempotent
```

---

# 45. Concurrency Problem

This is an important interview topic.

Suppose the customer's account has:

```text
Balance = ₹10,000
```

Two ATMs simultaneously process:

```text
ATM 1 → Withdraw ₹8,000
ATM 2 → Withdraw ₹8,000
```

Without proper concurrency control:

```text
ATM 1 reads balance = ₹10,000
ATM 2 reads balance = ₹10,000

ATM 1 → debit ₹8,000
ATM 2 → debit ₹8,000

Final balance could become invalid.
```

The bank-side account operation needs proper transactional concurrency control.

For example:

```text
BEGIN TRANSACTION

SELECT account
FOR UPDATE

Check balance

Debit amount

COMMIT
```

The exact implementation depends on the persistence/database architecture.

---

# 46. Idempotency

This is another important real-world concern.

Imagine:

```text
ATM
 |
 | Withdrawal request
 v
Bank
 |
 | Debit successful
 v
ATM
```

But the network response is lost.

ATM doesn't know whether the transaction succeeded.

If it retries blindly:

```text
Debit ₹5000
Debit ₹5000
```

Customer could be charged twice.

Therefore transactions should have a unique:

```text
transactionId
```

and the bank should process retries idempotently.

For example:

```text
TXN123

First request:
SUCCESS

Retry:
Return previous SUCCESS
Do NOT debit again
```

This is a strong real-world design point to mention in an interview.

---

# 47. Why Transaction ID Matters

Every transaction gets:

```text
TXN1001
TXN1002
TXN1003
```

This helps with:

- Idempotency
- Auditing
- Troubleshooting
- Reconciliation
- Customer support

---

# 48. Interview Opening

If asked:

> "Design an ATM."

A strong opening would be:

> "I'll assume the ATM supports card insertion, PIN authentication, balance inquiry, withdrawal, deposit and card ejection. I'll separate ATM workflow from banking/account logic and physical cash management. The main entities are ATM, Card, Customer, Account, Bank, CashDispenser and Transaction. I'll use transaction subclasses for different operations, and represent ATM lifecycle with an enum initially; if state-specific behavior grows, I'd move to the State Pattern."

Then draw:

```text
ATM
 |
 +---- Bank
 |
 +---- CashDispenser
 |
 +---- Card
 |
 +---- Transaction
```

---

# 49. Common Mistakes in ATM LLD

## Mistake 1 — Put everything inside ATM

Bad:

```text
ATM
 |
 +-- account balance
 +-- customer database
 +-- cash
 +-- authentication
 +-- transaction history
```

Too many responsibilities.

---

## Mistake 2 — ATM directly modifies balance

Bad:

```java
account.balance -= amount;
```

Better:

```java
account.debit(amount);
```

or, in a realistic architecture, let the bank/account service perform the authoritative debit.

---

## Mistake 3 — ATM directly manages customer database

Bad:

```text
ATM → all customers
```

Better:

```text
ATM → BankingService → Bank
```

---

## Mistake 4 — Ignore concurrency

Banking systems involve concurrent requests.

Always mention:

```text
transaction
locking
atomicity
idempotency
```

when discussing production behavior.

---

## Mistake 5 — Overuse State Pattern

Don't create:

```text
IdleState
CardInsertedState
PinEnteredState
...
```

for a small coding exercise unless the interviewer specifically asks for extensibility.

Start with:

```java
enum ATMState
```

---

# 50. Recommended Project Structure

```text
src/
│
├── model/
│   ├── ATM.java
│   ├── Card.java
│   ├── Account.java
│   └── Customer.java
│
├── transaction/
│   ├── Transaction.java
│   ├── WithdrawalTransaction.java
│   ├── DepositTransaction.java
│   ├── BalanceInquiryTransaction.java
│   └── TransferTransaction.java
│
├── service/
│   ├── Bank.java
│   └── CashDispenser.java
│
├── enums/
│   ├── ATMState.java
│   ├── TransactionType.java
│   └── TransactionStatus.java
│
└── Main.java
```

---

# 51. Final Mental Model

When you see an ATM LLD question, think:

```text
                    ATM
                     |
          +----------+----------+
          |                     |
          v                     v
         Bank             CashDispenser
          |
      +---+---+
      |       |
      v       v
   Customer Account
      |
      v
    Card


Transaction
     |
     +---- Withdrawal
     |
     +---- Deposit
     |
     +---- Balance Inquiry
     |
     +---- Transfer
```

The key separation is:

```text
ATM
→ Controls workflow

Bank
→ Banking authority

Account
→ Account state

Card
→ Card/authentication information

CashDispenser
→ Physical cash

Transaction
→ Financial operation
```

---

# 52. Final Interview Summary

The most important classes are:

```text
ATM
Card
Customer
Account
Bank
CashDispenser
Transaction
```

Important abstractions:

```text
Transaction
BankingService       // useful for a cleaner architecture
```

Important enums:

```text
ATMState
TransactionType
TransactionStatus
```

Useful patterns:

```text
State Pattern
→ If ATM states become complex

Strategy Pattern
→ If cash dispensing algorithms vary

Factory Pattern
→ If transaction creation becomes complex
```

Important production concerns:

```text
Concurrency
Atomicity
Idempotency
Transaction IDs
Secure PIN handling
Network failures
Cash/account reconciliation
```

The core mental model is:

```text
Requirement
     ↓
Identify entities
     ↓
Separate responsibilities
     ↓
Protect object state
     ↓
Identify changing behavior
     ↓
Use abstraction/pattern where justified
     ↓
Handle edge cases
     ↓
Think about concurrency
     ↓
Write Java code
```