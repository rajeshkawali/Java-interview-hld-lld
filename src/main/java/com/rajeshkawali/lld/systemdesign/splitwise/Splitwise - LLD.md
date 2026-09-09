# Splitwise — Low-Level Design

## 1. Problem Statement

Design a simplified version of **Splitwise**.

Users should be able to:

- Create users
- Create groups
- Add users to groups
- Add an expense
- Split an expense among users
- Support different split types
- Calculate who owes whom
- Show balances
- Settle debts

Example:

```text
Rahul pays ₹900 for
Rahul, Amit and Priya.

Split equally:

Rahul → ₹300
Amit  → ₹300
Priya → ₹300
```

Since Rahul paid the entire ₹900:

```text
Amit owes Rahul ₹300
Priya owes Rahul ₹300
```

---

# 2. Requirements

## Functional Requirements

### User Management

The system should allow:

```text
Create User
Get User
```

---

### Group Management

Users should be able to:

```text
Create Group
Add member
Remove member
View group members
```

---

### Expense Management

Users should be able to:

```text
Add expense
Split expense equally
Split expense by exact amount
Split expense by percentage
```

---

### Balance

The system should calculate:

```text
Who owes whom?
How much does a user owe?
How much does a user need to receive?
```

---

### Settlement

A user should be able to settle an amount.

Example:

```text
A owes B ₹500

A pays B ₹500

Debt becomes ₹0
```

---

# 3. Example

Suppose we have:

```text
Users:

A = Rahul
B = Amit
C = Priya
```

Rahul pays:

```text
₹900 dinner
```

Split equally:

```text
Rahul → ₹300
Amit  → ₹300
Priya → ₹300
```

Rahul paid ₹900 but his own share is only ₹300.

Therefore:

```text
Amit owes Rahul ₹300
Priya owes Rahul ₹300
```

Final balances:

```text
Rahul → +₹600
Amit  → -₹300
Priya → -₹300
```

Where:

```text
+ = should receive
- = owes
```

---

# 4. Another Example

Suppose:

```text
Rahul pays ₹1000
```

Split:

```text
Rahul → ₹200
Amit  → ₹300
Priya → ₹500
```

Then:

```text
Rahul paid: ₹1000
Rahul's share: ₹200
```

So Rahul should receive:

```text
₹1000 - ₹200 = ₹800
```

Amit owes:

```text
₹300
```

Priya owes:

```text
₹500
```

Therefore:

```text
Amit  → Rahul ₹300
Priya → Rahul ₹500
```

---

# 5. Identify the Main Entities

From the requirements, identify objects.

```text
User
Group
Expense
Split
Balance
```

We also need services:

```text
ExpenseService
BalanceService
SettlementService
```

And different split behaviors:

```text
EqualSplit
ExactAmountSplit
PercentageSplit
```

---

# 6. Basic Class Diagram

```text
                         +----------------+
                         |      User      |
                         +-------+--------+
                                 |
                                 |
                    +------------+------------+
                    |                         |
                    v                         v
               +---------+               +---------+
               |  Group  |               | Balance |
               +----+----+               +---------+
                    |
                    |
                    v
               +---------+
               | Expense |
               +----+----+
                    |
                    |
                    v
               +---------+
               |  Split  |
               +----+----+
                    |
          +---------+---------+
          |         |         |
          v         v         v
     EqualSplit ExactSplit PercentageSplit
```

---

# 7. User

A `User` represents a Splitwise user.

```java
public class User {

    private final String userId;
    private final String name;
    private final String email;

    public User(
            String userId,
            String name,
            String email) {

        this.userId = userId;
        this.name = name;
        this.email = email;
    }

    public String getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }
}
```

---

# 8. Group

A group contains multiple users.

```java
import java.util.*;

public class Group {

    private final String groupId;
    private final String name;

    private final Set<User> members;

    public Group(
            String groupId,
            String name) {

        this.groupId = groupId;
        this.name = name;
        this.members = new HashSet<>();
    }

    public void addMember(User user) {
        members.add(user);
    }

    public void removeMember(User user) {
        members.remove(user);
    }

    public Set<User> getMembers() {
        return Collections.unmodifiableSet(members);
    }

    public String getGroupId() {
        return groupId;
    }

    public String getName() {
        return name;
    }
}
```

---

# 9. Expense

An expense contains:

```text
Who paid?
How much?
What was it for?
How should it be split?
```

```java
import java.util.*;

public class Expense {

    private final String expenseId;
    private final String description;
    private final double amount;

    private final User paidBy;
    private final List<Split> splits;

    public Expense(
            String expenseId,
            String description,
            double amount,
            User paidBy,
            List<Split> splits) {

        this.expenseId = expenseId;
        this.description = description;
        this.amount = amount;
        this.paidBy = paidBy;
        this.splits = new ArrayList<>(splits);
    }

    public String getExpenseId() {
        return expenseId;
    }

    public String getDescription() {
        return description;
    }

    public double getAmount() {
        return amount;
    }

    public User getPaidBy() {
        return paidBy;
    }

    public List<Split> getSplits() {
        return Collections.unmodifiableList(splits);
    }
}
```

---

# 10. Why Do We Need Split?

This is one of the most important design decisions.

An expense can be split in different ways.

```text
₹900
```

could be:

```text
Equal:

A → ₹300
B → ₹300
C → ₹300
```

or:

```text
Exact:

A → ₹100
B → ₹300
C → ₹500
```

or:

```text
Percentage:

A → 20%
B → 30%
C → 50%
```

If we put all this logic inside `Expense`, it becomes messy.

Instead:

```text
Expense
   |
   +---- Split
            |
            +---- EqualSplit
            +---- ExactSplit
            +---- PercentageSplit
```

This is where **polymorphism / Strategy Pattern** becomes useful.

---

# 11. Split

Create an abstract base class.

```java
public abstract class Split {

    protected final User user;
    protected final double amount;

    protected Split(
            User user,
            double amount) {

        this.user = user;
        this.amount = amount;
    }

    public User getUser() {
        return user;
    }

    public double getAmount() {
        return amount;
    }
}
```

Every split says:

```text
This user owes X amount.
```

---

# 12. Equal Split

For equal splitting:

```text
₹900 / 3 = ₹300
```

We can represent it using:

```java
public class EqualSplit extends Split {

    public EqualSplit(
            User user,
            double amount) {

        super(user, amount);
    }
}
```

The amount is calculated by the service that creates the splits.

---

# 13. Exact Amount Split

```java
public class ExactSplit extends Split {

    public ExactSplit(
            User user,
            double amount) {

        super(user, amount);
    }
}
```

Example:

```java
new ExactSplit(rahul, 200);
new ExactSplit(amit, 300);
new ExactSplit(priya, 500);
```

---

# 14. Percentage Split

Percentage is slightly different.

We need to store the percentage.

```java
public class PercentageSplit extends Split {

    private final double percentage;

    public PercentageSplit(
            User user,
            double amount,
            double percentage) {

        super(user, amount);
        this.percentage = percentage;
    }

    public double getPercentage() {
        return percentage;
    }
}
```

Example:

```text
Rahul → 20%
Amit  → 30%
Priya → 50%
```

For ₹1000:

```text
Rahul → ₹200
Amit  → ₹300
Priya → ₹500
```

---

# 15. Split Type

We can define:

```java
public enum SplitType {
    EQUAL,
    EXACT,
    PERCENTAGE
}
```

---

# 16. Balance

This is the heart of Splitwise.

We need to represent:

```text
A owes B ₹500
```

We can model this as:

```text
Balance[A][B] = 500
```

Meaning:

```text
A owes B ₹500
```

A convenient representation is:

```java
Map<User, Map<User, Double>>
```

Example:

```text
balance[A][B] = 500
balance[B][C] = 200
```

---

# 17. Balance Sheet

Create:

```java
import java.util.*;

public class BalanceSheet {

    private final Map<String, Map<String, Double>> balances =
            new HashMap<>();

    public void addDebt(
            User debtor,
            User creditor,
            double amount) {

        if (debtor.getUserId()
                .equals(creditor.getUserId())) {

            return;
        }

        balances
                .computeIfAbsent(
                        debtor.getUserId(),
                        k -> new HashMap<>()
                )
                .merge(
                        creditor.getUserId(),
                        amount,
                        Double::sum
                );
    }

    public Map<String, Double> getBalances(
            User user) {

        return balances.getOrDefault(
                user.getUserId(),
                Collections.emptyMap()
        );
    }
}
```

However, this representation has an important issue.

Suppose:

```text
A owes B ₹500
B owes A ₹200
```

We don't want two separate debts.

We can simplify them:

```text
A owes B ₹300
```

Therefore, a better implementation should **net opposite balances**.

---

# 18. Better Balance Logic

```java
import java.util.*;

public class BalanceSheet {

    private final Map<String, Map<String, Double>> balances =
            new HashMap<>();

    public void addTransaction(
            User paidBy,
            User owedBy,
            double amount) {

        if (paidBy.getUserId()
                .equals(owedBy.getUserId())) {

            return;
        }

        // owedBy owes paidBy
        double reverseAmount =
                getBalance(
                        paidBy.getUserId(),
                        owedBy.getUserId()
                );

        if (reverseAmount >= amount) {

            setBalance(
                    paidBy.getUserId(),
                    owedBy.getUserId(),
                    reverseAmount - amount
            );

        } else {

            setBalance(
                    paidBy.getUserId(),
                    owedBy.getUserId(),
                    0
            );

            double remaining =
                    amount - reverseAmount;

            setBalance(
                    owedBy.getUserId(),
                    paidBy.getUserId(),
                    remaining
            );
        }
    }

    private double getBalance(
            String debtor,
            String creditor) {

        return balances
                .getOrDefault(
                        debtor,
                        Collections.emptyMap()
                )
                .getOrDefault(
                        creditor,
                        0.0
                );
    }

    private void setBalance(
            String debtor,
            String creditor,
            double amount) {

        balances
                .computeIfAbsent(
                        debtor,
                        k -> new HashMap<>()
                )
                .put(creditor, amount);
    }

    public Map<String, Double> getBalances(
            User user) {

        return balances.getOrDefault(
                user.getUserId(),
                Collections.emptyMap()
        );
    }
}
```

---

# 19. Understand `addTransaction()`

Suppose:

```text
Rahul pays ₹900.

Rahul's share = ₹300
Amit's share = ₹300
Priya's share = ₹300
```

For Amit:

```text
Amit owes Rahul ₹300
```

We call:

```java
balanceSheet.addTransaction(
    rahul,
    amit,
    300
);
```

Meaning:

```text
amit owes rahul ₹300
```

For Priya:

```java
balanceSheet.addTransaction(
    rahul,
    priya,
    300
);
```

Now:

```text
Amit  → Rahul ₹300
Priya → Rahul ₹300
```

---

# 20. Expense Service

Now let's create the service responsible for adding expenses.

```java
import java.util.*;

public class ExpenseService {

    private final BalanceSheet balanceSheet;

    public ExpenseService(
            BalanceSheet balanceSheet) {

        this.balanceSheet = balanceSheet;
    }

    public Expense addExpense(
            String description,
            double amount,
            User paidBy,
            List<Split> splits) {

        validateExpense(
                amount,
                splits
        );

        Expense expense = new Expense(
                UUID.randomUUID().toString(),
                description,
                amount,
                paidBy,
                splits
        );

        for (Split split : splits) {

            if (!split.getUser()
                    .getUserId()
                    .equals(paidBy.getUserId())) {

                balanceSheet.addTransaction(
                        paidBy,
                        split.getUser(),
                        split.getAmount()
                );
            }
        }

        return expense;
    }

    private void validateExpense(
            double amount,
            List<Split> splits) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Expense amount must be positive"
            );
        }

        double total = splits.stream()
                .mapToDouble(Split::getAmount)
                .sum();

        if (Math.abs(total - amount) > 0.01) {
            throw new IllegalArgumentException(
                    "Split amounts do not match expense"
            );
        }
    }
}
```

---

# 21. Problem With the Above Design

There is one thing we haven't handled yet.

How do we create:

```text
EqualSplit
ExactSplit
PercentageSplit
```

correctly?

For example:

```text
₹900

Users:
A
B
C
```

Equal split should automatically become:

```text
A → ₹300
B → ₹300
C → ₹300
```

So let's create a split strategy.

---

# 22. Split Strategy

```java
import java.util.*;

public interface SplitStrategy {

    List<Split> calculateSplits(
            double amount,
            List<User> users,
            List<Double> values
    );
}
```

This interface says:

> Given the total amount and users, calculate each user's share.

---

# 23. Equal Split Strategy

```java
import java.util.*;

public class EqualSplitStrategy
        implements SplitStrategy {

    @Override
    public List<Split> calculateSplits(
            double amount,
            List<User> users,
            List<Double> values) {

        if (users.isEmpty()) {
            throw new IllegalArgumentException(
                    "Users cannot be empty"
            );
        }

        double splitAmount =
                amount / users.size();

        List<Split> splits = new ArrayList<>();

        for (User user : users) {

            splits.add(
                    new EqualSplit(
                            user,
                            splitAmount
                    )
            );
        }

        return splits;
    }
}
```

---

# 24. Exact Split Strategy

```java
import java.util.*;

public class ExactSplitStrategy
        implements SplitStrategy {

    @Override
    public List<Split> calculateSplits(
            double amount,
            List<User> users,
            List<Double> values) {

        if (users.size() != values.size()) {
            throw new IllegalArgumentException(
                    "Users and amounts must match"
            );
        }

        double total = 0;

        List<Split> splits = new ArrayList<>();

        for (int i = 0; i < users.size(); i++) {

            double splitAmount = values.get(i);

            if (splitAmount < 0) {
                throw new IllegalArgumentException(
                        "Split amount cannot be negative"
                );
            }

            total += splitAmount;

            splits.add(
                    new ExactSplit(
                            users.get(i),
                            splitAmount
                    )
            );
        }

        if (Math.abs(total - amount) > 0.01) {
            throw new IllegalArgumentException(
                    "Exact amounts do not match total"
            );
        }

        return splits;
    }
}
```

---

# 25. Percentage Split Strategy

```java
import java.util.*;

public class PercentageSplitStrategy
        implements SplitStrategy {

    @Override
    public List<Split> calculateSplits(
            double amount,
            List<User> users,
            List<Double> percentages) {

        if (users.size() != percentages.size()) {
            throw new IllegalArgumentException(
                    "Users and percentages must match"
            );
        }

        double totalPercentage = 0;

        for (double percentage : percentages) {

            if (percentage < 0) {
                throw new IllegalArgumentException(
                        "Percentage cannot be negative"
                );
            }

            totalPercentage += percentage;
        }

        if (Math.abs(totalPercentage - 100.0) > 0.01) {
            throw new IllegalArgumentException(
                    "Percentages must add up to 100"
            );
        }

        List<Split> splits = new ArrayList<>();

        for (int i = 0; i < users.size(); i++) {

            double percentage =
                    percentages.get(i);

            double splitAmount =
                    amount * percentage / 100.0;

            splits.add(
                    new PercentageSplit(
                            users.get(i),
                            splitAmount,
                            percentage
                    )
            );
        }

        return splits;
    }
}
```

---

# 26. Why Strategy Pattern?

Without Strategy:

```java
if (type == EQUAL) {
    ...
} else if (type == EXACT) {
    ...
} else if (type == PERCENTAGE) {
    ...
}
```

This logic can keep growing.

With Strategy:

```text
SplitStrategy
      |
      +---- EqualSplitStrategy
      |
      +---- ExactSplitStrategy
      |
      +---- PercentageSplitStrategy
```

Adding:

```text
ShareBasedSplit
WeightedSplit
CustomSplit
```

doesn't require changing existing strategies.

This is a classic interview use case for the **Strategy Pattern**.

---

# 27. Split Strategy Factory

We can use a Factory to select the strategy.

```java
public class SplitStrategyFactory {

    public static SplitStrategy getStrategy(
            SplitType type) {

        switch (type) {

            case EQUAL:
                return new EqualSplitStrategy();

            case EXACT:
                return new ExactSplitStrategy();

            case PERCENTAGE:
                return new PercentageSplitStrategy();

            default:
                throw new IllegalArgumentException(
                        "Unsupported split type"
                );
        }
    }
}
```

---

# 28. Main Splitwise Service

Now create a facade/coordinator.

```java
import java.util.*;

public class Splitwise {

    private final Map<String, User> users;
    private final Map<String, Group> groups;

    private final BalanceSheet balanceSheet;
    private final ExpenseService expenseService;

    public Splitwise() {

        users = new HashMap<>();
        groups = new HashMap<>();

        balanceSheet = new BalanceSheet();

        expenseService =
                new ExpenseService(
                        balanceSheet
                );
    }

    public void addUser(User user) {

        users.put(
                user.getUserId(),
                user
        );
    }

    public void addGroup(Group group) {

        groups.put(
                group.getGroupId(),
                group
        );
    }

    public Expense addExpense(
            String description,
            double amount,
            User paidBy,
            List<User> participants,
            SplitType splitType,
            List<Double> values) {

        SplitStrategy strategy =
                SplitStrategyFactory
                        .getStrategy(splitType);

        List<Split> splits =
                strategy.calculateSplits(
                        amount,
                        participants,
                        values
                );

        return expenseService.addExpense(
                description,
                amount,
                paidBy,
                splits
        );
    }

    public Map<String, Double> showBalance(
            User user) {

        return balanceSheet
                .getBalances(user);
    }
}
```

---

# 29. Main Example

Let's use the system.

```java
import java.util.*;

public class Main {

    public static void main(String[] args) {

        Splitwise splitwise =
                new Splitwise();

        // ----------------------
        // Users
        // ----------------------

        User rahul = new User(
                "U1",
                "Rahul",
                "rahul@example.com"
        );

        User amit = new User(
                "U2",
                "Amit",
                "amit@example.com"
        );

        User priya = new User(
                "U3",
                "Priya",
                "priya@example.com"
        );

        splitwise.addUser(rahul);
        splitwise.addUser(amit);
        splitwise.addUser(priya);

        // ----------------------
        // Equal Split
        // ----------------------

        splitwise.addExpense(
                "Dinner",
                900,
                rahul,
                Arrays.asList(
                        rahul,
                        amit,
                        priya
                ),
                SplitType.EQUAL,
                Collections.emptyList()
        );

        // ----------------------
        // Show balances
        // ----------------------

        System.out.println(
                "Amit owes: "
                + splitwise.showBalance(amit)
        );

        System.out.println(
                "Priya owes: "
                + splitwise.showBalance(priya)
        );

        System.out.println(
                "Rahul receives: "
                + splitwise.showBalance(rahul)
        );
    }
}
```

Expected conceptual result:

```text
Amit:
Rahul → 300

Priya:
Rahul → 300

Rahul:
Amit → 0
Priya → 0
```

Depending on how you choose to expose balances, you may instead expose Rahul's net receivable as:

```text
Amit  owes Rahul ₹300
Priya owes Rahul ₹300
```

The important thing is to clearly define the direction of the balance map.

---

# 30. Settlement

Now suppose:

```text
Amit owes Rahul ₹300
```

Amit pays Rahul.

We need:

```text
Amit → Rahul ₹0
```

Create a settlement service.

```java
public class SettlementService {

    private final BalanceSheet balanceSheet;

    public SettlementService(
            BalanceSheet balanceSheet) {

        this.balanceSheet = balanceSheet;
    }

    public void settle(
            User debtor,
            User creditor,
            double amount) {

        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "Settlement amount must be positive"
            );
        }

        // A production implementation should
        // validate the existing debt before reducing it.

        balanceSheet.addTransaction(
                creditor,
                debtor,
                amount
        );
    }
}
```

The balance operation effectively offsets the existing debt.

For a production implementation, I would make the balance sheet expose an explicit:

```java
settleDebt(debtor, creditor, amount)
```

operation rather than relying on the semantics of `addTransaction()`.

---

# 31. Better Settlement API

A cleaner design is:

```java
public class BalanceSheet {

    // ...

    public void settleDebt(
            User debtor,
            User creditor,
            double amount) {

        double currentDebt =
                getBalance(
                        debtor.getUserId(),
                        creditor.getUserId()
                );

        if (currentDebt < amount) {
            throw new IllegalArgumentException(
                    "Settlement exceeds existing debt"
            );
        }

        setBalance(
                debtor.getUserId(),
                creditor.getUserId(),
                currentDebt - amount
        );
    }
}
```

Now:

```java
balanceSheet.settleDebt(
    amit,
    rahul,
    300
);
```

results in:

```text
Amit → Rahul ₹0
```

This API is much easier to understand.

---

# 32. Important Balance Concept

There are two ways to think about balances.

### Approach 1 — Pairwise balance

```text
A owes B ₹500
B owes C ₹200
```

Store:

```text
balance[A][B] = 500
balance[B][C] = 200
```

This preserves exactly who owes whom.

---

### Approach 2 — Net balance

Calculate:

```text
A → -500
B → +300
C → +200
```

This tells us:

```text
A owes ₹500
B should receive ₹300
C should receive ₹200
```

But it doesn't directly tell us the original pairwise relationships.

For a basic Splitwise LLD:

> Pairwise balances are easier to reason about.

---

# 33. Debt Simplification

This is a great interview follow-up.

Suppose:

```text
A owes B ₹500
B owes C ₹500
```

Instead of:

```text
A → B ₹500
B → C ₹500
```

we can simplify to:

```text
A → C ₹500
```

This reduces the number of payments required.

However:

> Debt simplification is an optimization, not the core expense-recording logic.

We should keep the original expenses intact for history/audit and derive simplified settlement suggestions separately.

---

# 34. Simplification Algorithm

First calculate each user's net balance.

Example:

```text
A = -500
B = 0
C = +500
```

Then divide users into:

```text
Debtors:
A → 500

Creditors:
C → 500
```

Match them:

```text
A → C ₹500
```

A simple algorithm:

```java
while (!debtors.isEmpty()
        && !creditors.isEmpty()) {

    debtor = first debtor;
    creditor = first creditor;

    amount = min(
        debtor.amount,
        creditor.amount
    );

    createTransaction(
        debtor,
        creditor,
        amount
    );

    reduce both balances;
}
```

This is useful for:

```text
"Settle up"
```

features.

---

# 35. Observer Pattern?

Suppose we want:

```text
Expense added
     |
     +---- Send notification
     +---- Update analytics
     +---- Update activity feed
```

We could use an event-based design.

```text
ExpenseCreatedEvent
        |
        +---- NotificationService
        +---- ActivityService
        +---- AnalyticsService
```

But I would **not introduce Observer Pattern in the first version** unless the interviewer asks about notifications.

Start simple.

---

# 36. Factory Pattern

Factory can be used for split strategies:

```text
SplitStrategyFactory
       |
       +---- EqualSplitStrategy
       +---- ExactSplitStrategy
       +---- PercentageSplitStrategy
```

The factory hides object creation from the caller.

---

# 37. Strategy Pattern

Strategy is the most important pattern here.

```text
                  SplitStrategy
                       |
          +------------+------------+
          |            |            |
          v            v            v
        Equal        Exact      Percentage
```

Each strategy has different calculation logic.

---

# 38. Why Not Put Split Logic in Expense?

Bad design:

```java
class Expense {

    if (type == EQUAL) {
        ...
    }

    if (type == EXACT) {
        ...
    }

    if (type == PERCENTAGE) {
        ...
    }
}
```

Now `Expense` knows about every splitting algorithm.

Better:

```text
Expense
  |
  +---- contains Split objects

SplitStrategy
  |
  +---- calculates Split objects
```

This follows SRP.

---

# 39. SOLID Principles

## SRP

```text
User              → user information
Group             → group membership
Expense            → expense information
Split              → individual share
BalanceSheet       → debts
ExpenseService     → expense workflow
SplitStrategy      → split calculation
SettlementService  → settlement
```

Each class has a focused responsibility.

---

## OCP

Adding:

```text
WeightedSplit
```

should require adding:

```java
class WeightedSplitStrategy
        implements SplitStrategy
```

rather than modifying existing strategies.

---

## DIP

Instead of:

```java
ExpenseService {

    EqualSplitStrategy strategy =
        new EqualSplitStrategy();

}
```

depend on:

```java
SplitStrategy
```

abstraction.

---

# 40. Money Representation

One important production-level point:

Avoid:

```java
double amount;
```

for actual financial systems.

Floating-point arithmetic can produce precision problems.

For example:

```text
0.1 + 0.2
```

may not be represented exactly as decimal currency.

Better options:

```text
BigDecimal
```

or:

```text
long amountInPaise
```

For an interview implementation, `double` is acceptable if you explicitly say:

> "I'm using double to keep the LLD readable; production code should use BigDecimal or integer minor units."

---

# 41. Validation

Whenever an expense is created:

### Amount must be positive

```text
₹0 → invalid
₹-100 → invalid
```

### Exact split

```text
1000

300 + 300 + 400 = valid
```

but:

```text
300 + 300 + 300 = invalid
```

### Percentage split

```text
30 + 30 + 40 = valid
```

but:

```text
30 + 30 + 30 = invalid
```

### Equal split

```text
amount / numberOfUsers
```

---

# 42. Rounding Problem

Suppose:

```text
₹100
3 users
```

Equal split gives:

```text
₹33.3333...
```

But currency cannot have infinite decimal places.

A production system needs a rounding policy.

For example:

```text
A → ₹33.34
B → ₹33.33
C → ₹33.33
```

Total:

```text
₹100.00
```

Important interview point:

> The system must guarantee that the rounded split amounts add exactly back to the original expense amount.

---

# 43. Group-Level Expenses

The system should support:

```text
Group
 |
 +---- Users
 |
 +---- Expenses
```

We can extend `Expense` with:

```java
private final Group group;
```

Then an expense can belong to:

```text
Trip to Goa
```

while users can also have:

```text
Personal expenses
```

outside groups.

---

# 44. Expense History

Don't delete expenses when they are settled.

Example:

```text
Expense:
Dinner ₹900
Paid by Rahul
```

After settlement:

```text
Amit pays Rahul ₹300
```

The expense still exists.

We only change the outstanding balance.

This gives us:

```text
Expense history
+
Current balances
```

as separate concepts.

---

# 45. Important Separation

This is a great interview concept:

```text
Expense
    ↓
What happened?

Balance
    ↓
Who currently owes whom?

Settlement
    ↓
How was the debt paid back?
```

These are different concepts.

Don't make `Expense` responsible for everything.

---

# 46. Concurrency

Suppose:

```text
User A adds expense
User B settles expense
```

at the same time.

If the system is distributed, balance updates need proper consistency.

For example:

```text
Expense creation
       |
       v
Update balance
```

should not partially succeed.

In a production system:

```text
Database transaction
+
Concurrency control
+
Idempotency
```

would be considered.

---

# 47. Idempotency

Suppose a client sends:

```text
Add expense ₹900
```

but doesn't receive the response.

It retries.

Without idempotency:

```text
Expense 1 → ₹900
Expense 2 → ₹900
```

Now users owe twice as much.

Therefore, requests should have a unique idempotency key:

```text
requestId = REQ123
```

If `REQ123` was already processed:

```text
return previous result
```

rather than creating another expense.

---

# 48. Complete Architecture

At the object level:

```text
                         +----------------+
                         |    Splitwise   |
                         +-------+--------+
                                 |
                +----------------+----------------+
                |                |                |
                v                v                v
             Users            Groups         ExpenseService
                                                  |
                                                  |
                                          +-------+-------+
                                          |               |
                                          v               v
                                      Expense        BalanceSheet
                                          |
                                          v
                                        Split
                                          |
                        +-----------------+-----------------+
                        |                 |                 |
                        v                 v                 v
                  EqualSplit        ExactSplit      PercentageSplit
```

---

# 49. Recommended Project Structure

```text
src/
│
├── model/
│   ├── User.java
│   ├── Group.java
│   ├── Expense.java
│   ├── Split.java
│   ├── EqualSplit.java
│   ├── ExactSplit.java
│   └── PercentageSplit.java
│
├── service/
│   ├── ExpenseService.java
│   ├── BalanceSheet.java
│   └── SettlementService.java
│
├── strategy/
│   ├── SplitStrategy.java
│   ├── EqualSplitStrategy.java
│   ├── ExactSplitStrategy.java
│   └── PercentageSplitStrategy.java
│
├── factory/
│   └── SplitStrategyFactory.java
│
├── enums/
│   └── SplitType.java
│
└── Main.java
```

---

# 50. Interview Opening

If the interviewer says:

> "Design Splitwise."

Start with:

> "I'll assume the system supports users, groups, expenses, equal/exact/percentage splits, balance calculation and settlement. The core entities are User, Group, Expense, Split and Balance. I'll separate the physical expense record from the current outstanding balance because an expense can remain in history even after it is settled. Since split calculation varies by type, I'll use a Strategy Pattern for equal, exact and percentage splits. The main concurrency concern is maintaining consistent balances when multiple expenses or settlements happen concurrently."

This gives the interviewer a clear picture before you start coding.

---

# 51. Common Interview Questions

## Q1. Why do we need Split?

Because one expense can have different splitting rules.

```text
Expense
   |
   +---- Split
```

---

## Q2. Why Strategy Pattern?

Because splitting behavior changes:

```text
Equal
Exact
Percentage
Weighted
```

Strategy lets us add new algorithms without modifying the core expense service.

---

## Q3. Where should balance be stored?

Separate from `Expense`.

```text
Expense → historical event
Balance → current outstanding debt
```

---

## Q4. How do you handle A owing B and B owing A?

Net the two balances.

Example:

```text
A → B ₹500
B → A ₹200
```

becomes:

```text
A → B ₹300
```

---

## Q5. How do you simplify debts?

Calculate net balances first, then match:

```text
Debtors
+
Creditors
```

to generate fewer settlement transactions.

---

## Q6. How do you handle ₹100 split between 3 users?

Use a defined rounding policy:

```text
33.34
33.33
33.33
```

while ensuring:

```text
sum = ₹100
```

---

## Q7. Would you use Singleton?

No need.

There is no inherent requirement for Splitwise's domain objects to be singletons.

---

## Q8. Would you use Observer?

Possibly for notifications/activity feeds, but I would not introduce it into the core design unless that requirement exists.

---

# 52. Common Mistakes

### Mistake 1 — God Class

Don't create:

```text
Splitwise
    |
    +-- users
    +-- groups
    +-- expenses
    +-- balances
    +-- payment
    +-- notification
    +-- split calculation
```

with hundreds of methods.

---

### Mistake 2 — Put all split logic in Expense

Use Strategy.

---

### Mistake 3 — Delete expenses after settlement

Settlement changes the outstanding debt.

It doesn't erase history.

---

### Mistake 4 — Ignore opposite debts

Always consider:

```text
A → B
B → A
```

and net them.

---

### Mistake 5 — Use `double` without mentioning money precision

For interviews:

```text
double → okay for simplified code
BigDecimal / minor units → production
```

---

# 53. Final Mental Model

Remember Splitwise as:

```text
             USER
               |
               v
            EXPENSE
               |
               v
             SPLIT
               |
       +-------+-------+
       |       |       |
     EQUAL   EXACT  PERCENTAGE
       |
       v
    BALANCE
       |
       v
  WHO OWES WHOM?
       |
       v
   SETTLEMENT
```

The most important separation is:

```text
Expense
  ↓
What happened?

Split
  ↓
How should the expense be divided?

Balance
  ↓
Who owes whom now?

Settlement
  ↓
How is the debt cleared?
```

---

# 54. The 5 Things to Remember for the Interview

If you forget everything else, remember these:

### 1. Expense ≠ Balance

```text
Expense = historical transaction
Balance = current debt
```

### 2. Split is polymorphic

```text
Split
 ├── Equal
 ├── Exact
 └── Percentage
```

### 3. Use Strategy for split calculation

```text
SplitStrategy
 ├── EqualSplitStrategy
 ├── ExactSplitStrategy
 └── PercentageSplitStrategy
```

### 4. Net opposite balances

```text
A owes B ₹500
B owes A ₹200

→ A owes B ₹300
```

### 5. Think about precision and concurrency

```text
Money
→ BigDecimal / minor units

Concurrent updates
→ transaction + concurrency control
```

---

# 55. One-Line Interview Summary

> **"I would model users, groups, expenses, splits and balances separately. I would use the Strategy Pattern for different split calculations, maintain pairwise balances independently from expense history, net opposite debts, and use transactional/concurrency-safe updates for balance consistency."**