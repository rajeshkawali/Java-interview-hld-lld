# Elevator System — Low-Level Design (LLD)

A beginner-friendly, step-by-step design of an Elevator System using Java.

---

# 1. Problem Statement

Design an elevator system for a building.

The building has:

- Multiple floors
- Multiple elevators
- Users can request an elevator from a floor
- Users can select a destination floor inside an elevator
- Elevator moves up/down
- Elevator opens/closes its doors
- Elevator should decide which floor to visit next
- The system should assign an appropriate elevator to a request

Example:

```text
Building
   |
   +---- Elevator 1
   |
   +---- Elevator 2
   |
   +---- Elevator 3
```

Suppose a user is on floor 5 and wants to go to floor 10:

```text
User
 |
 | Request UP
 v
Elevator System
 |
 | Find suitable elevator
 v
Elevator 2
 |
 | Move
 v
Floor 5
 |
 | User enters destination 10
 v
Floor 10
 |
 v
Door opens
```

---

# 2. First Understand the Requirements

Before writing classes, let's clarify what the system should do.

## Functional Requirements

We will assume:

1. Building has multiple floors.
2. Building has multiple elevators.
3. Each elevator knows its current floor.
4. Elevator can move UP or DOWN.
5. Elevator has doors.
6. Users can request an elevator from a floor.
7. User can specify direction: UP or DOWN.
8. User can select a destination floor.
9. Elevator should stop at requested floors.
10. System should assign an elevator to a request.
11. Elevator should process requests in a reasonable order.
12. Elevator should open doors when it reaches a requested floor.
13. Elevator should close doors before moving again.

---

# 3. Non-Functional Considerations

In a real system we may also care about:

- Safety
- Concurrency
- Fault tolerance
- Performance
- Elevator capacity
- Emergency mode
- Maintenance mode

For our initial LLD, we'll focus on the core elevator behavior.

---

# 4. Important Questions

Before designing an LLD, we should ask questions such as:

### Question 1

How many elevators?

Answer:

```text
Multiple
```

---

### Question 2

How many floors?

Answer:

```text
Multiple
```

---

### Question 3

Can users request UP/DOWN?

Yes.

```text
UP
DOWN
```

---

### Question 4

Can an elevator have multiple pending destinations?

Yes.

For example:

```text
Elevator is on floor 2.

Requests:

5
8
10
```

The elevator needs to visit all requested floors.

---

### Question 5

How should the elevator choose the next floor?

This is an important design decision.

For example, if elevator is moving UP:

```text
Current floor = 3

Requests:
5
8
10
2
```

A reasonable strategy is:

```text
3 → 5 → 8 → 10
```

Then:

```text
10 → 2
```

This avoids unnecessarily changing direction.

This behavior will become an important part of our design.

---

# 5. Identify Entities

Now look at the nouns.

From:

> Building has multiple floors and elevators. Users request elevators and elevators move between floors.

Potential classes:

```text
Building
Floor
Elevator
ElevatorSystem
Request
Door
```

Potential enums:

```text
Direction
ElevatorState
DoorState
```

Let's understand each one.

---

# 6. Main Classes

Our initial design will contain:

```text
Building
ElevatorSystem
Elevator
Floor
ElevatorRequest
Door
```

And enums:

```text
Direction
ElevatorState
DoorState
```

Later we'll introduce:

```text
ElevatorSchedulingStrategy
```

for elevator selection/scheduling.

---

# 7. Direction

An elevator can move:

```text
UP
DOWN
IDLE
```

Create an enum:

```java
public enum Direction {
    UP,
    DOWN,
    IDLE
}
```

Why enum?

Because direction is a fixed set of values.

We don't want:

```java
String direction;
```

because someone could write:

```text
"UPP"
"up"
"Downn"
"ABC"
```

Instead:

```java
Direction.UP
```

is type-safe.

---

# 8. Elevator State

An elevator can be in different states.

For example:

```text
MOVING
IDLE
```

We can also later add:

```text
MAINTENANCE
EMERGENCY
```

For now:

```java
public enum ElevatorState {
    IDLE,
    MOVING
}
```

---

# 9. Door State

An elevator door can be:

```text
OPEN
CLOSED
```

So:

```java
public enum DoorState {
    OPEN,
    CLOSED
}
```

---

# 10. Floor

Do we really need a `Floor` class?

It depends on requirements.

For a basic system, a floor can simply be represented by:

```java
int floorNumber;
```

For example:

```java
int currentFloor = 5;
```

However, if the floor has behavior or additional information, we can create:

```java
public class Floor {

    private int floorNumber;

    public Floor(int floorNumber) {
        this.floorNumber = floorNumber;
    }

    public int getFloorNumber() {
        return floorNumber;
    }
}
```

For our initial implementation, we'll keep floor numbers as integers because we don't currently need much behavior from `Floor`.

This is an important LLD lesson:

> Don't create a class just because a noun exists. Create a class when it provides useful state or behavior.

---

# 11. Door Class

The elevator has a door.

The door has state:

```text
OPEN
CLOSED
```

And behavior:

```text
open()
close()
```

So:

```java
public class Door {

    private DoorState state;

    public Door() {
        this.state = DoorState.CLOSED;
    }

    public void open() {

        if (state == DoorState.OPEN) {
            return;
        }

        state = DoorState.OPEN;

        System.out.println("Door opened");
    }

    public void close() {

        if (state == DoorState.CLOSED) {
            return;
        }

        state = DoorState.CLOSED;

        System.out.println("Door closed");
    }

    public DoorState getState() {
        return state;
    }
}
```

---

# 12. Why Is Door a Separate Class?

We could write inside `Elevator`:

```java
private boolean doorOpen;
```

and:

```java
openDoor();
closeDoor();
```

But the door itself has state and behavior.

So it makes sense to model:

```text
Elevator
    |
    +---- Door
```

This is:

```text
HAS-A relationship
```

The elevator **has a door**.

---

# 13. ElevatorRequest

When a user presses a button, we need to represent the request.

Suppose:

```text
Floor = 5
Direction = UP
```

We can create:

```java
public class ElevatorRequest {

    private int floor;
    private Direction direction;

    public ElevatorRequest(
            int floor,
            Direction direction) {

        this.floor = floor;
        this.direction = direction;
    }

    public int getFloor() {
        return floor;
    }

    public Direction getDirection() {
        return direction;
    }
}
```

---

# 14. Why Do We Need ElevatorRequest?

Instead of passing:

```java
requestElevator(5, Direction.UP);
```

everywhere, we can create an object:

```java
ElevatorRequest request =
        new ElevatorRequest(
                5,
                Direction.UP
        );
```

Now the request becomes a first-class entity.

This becomes useful when the request grows.

For example, later we may add:

```text
requestId
timestamp
priority
sourceFloor
direction
```

Then:

```java
public class ElevatorRequest {

    private String requestId;
    private int floor;
    private Direction direction;
    private long timestamp;
}
```

---

# 15. Elevator

Now we reach the most important class.

An elevator needs to know:

```text
id
current floor
direction
state
door
pending requests
```

So:

```java
public class Elevator {

    private int id;
    private int currentFloor;
    private Direction direction;
    private ElevatorState state;
    private Door door;

    private List<Integer> destinationFloors;
}
```

---

# 16. Elevator Responsibilities

What should `Elevator` do?

It should know how to:

```text
move
open door
close door
add destination
remove destination
check whether it has a destination
```

It should NOT be responsible for:

```text
finding which elevator should serve a user
managing all elevators
creating the entire building
```

Those responsibilities belong elsewhere.

This is **Single Responsibility Principle**.

---

# 17. Elevator Class — Basic Version

```java
import java.util.ArrayList;
import java.util.List;

public class Elevator {

    private int id;
    private int currentFloor;

    private Direction direction;
    private ElevatorState state;

    private Door door;

    private List<Integer> destinationFloors;

    public Elevator(int id) {

        this.id = id;
        this.currentFloor = 0;

        this.direction = Direction.IDLE;
        this.state = ElevatorState.IDLE;

        this.door = new Door();

        this.destinationFloors =
                new ArrayList<>();
    }

    public void addDestination(int floor) {

        if (!destinationFloors.contains(floor)) {
            destinationFloors.add(floor);
        }
    }

    public boolean hasDestination() {
        return !destinationFloors.isEmpty();
    }

    public int getId() {
        return id;
    }

    public int getCurrentFloor() {
        return currentFloor;
    }

    public Direction getDirection() {
        return direction;
    }

    public ElevatorState getState() {
        return state;
    }

    public Door getDoor() {
        return door;
    }

    public List<Integer> getDestinationFloors() {
        return destinationFloors;
    }
}
```

This is only the starting point.

We haven't implemented movement yet.

---

# 18. Elevator Movement

Suppose:

```text
Current floor = 2
Destination = 7
```

The elevator needs to move:

```text
2
3
4
5
6
7
```

Conceptually:

```java
currentFloor++;
```

while going UP.

For DOWN:

```java
currentFloor--;
```

---

# 19. Move Up

We can implement:

```java
private void moveUp() {

    direction = Direction.UP;
    state = ElevatorState.MOVING;

    currentFloor++;

    System.out.println(
            "Elevator " + id +
            " moved to floor " +
            currentFloor
    );
}
```

---

# 20. Move Down

```java
private void moveDown() {

    direction = Direction.DOWN;
    state = ElevatorState.MOVING;

    currentFloor--;

    System.out.println(
            "Elevator " + id +
            " moved to floor " +
            currentFloor
    );
}
```

---

# 21. But How Does Elevator Decide Where to Go?

This is where the problem becomes interesting.

Suppose:

```text
Current floor = 5

Destinations:
2
8
10
3
```

Should it go:

```text
5 → 2 → 3 → 8 → 10
```

or:

```text
5 → 8 → 10 → 3 → 2
```

A common elevator strategy is:

> Continue in the current direction and serve requests in that direction before reversing.

This resembles the **SCAN / elevator scheduling algorithm**.

---

# 22. Elevator Scheduling

We could put this logic directly inside `Elevator`:

```java
if (direction == UP) {
    ...
} else {
    ...
}
```

But scheduling is a behavior that may change.

For example, we may later want:

```text
Nearest elevator
Nearest request
SCAN
LOOK
Priority scheduling
Load-based scheduling
```

Therefore, scheduling is a good candidate for a Strategy Pattern.

---

# 23. Strategy Pattern

Create:

```java
public interface ElevatorSchedulingStrategy {

    Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request
    );
}
```

This strategy answers:

> Which elevator should handle this request?

---

# 24. Nearest Elevator Strategy

A simple strategy:

> Select the closest available elevator.

```java
import java.util.List;

public class NearestElevatorStrategy
        implements ElevatorSchedulingStrategy {

    @Override
    public Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request) {

        Elevator bestElevator = null;
        int minimumDistance = Integer.MAX_VALUE;

        for (Elevator elevator : elevators) {

            if (elevator.getState()
                    != ElevatorState.IDLE) {

                continue;
            }

            int distance =
                    Math.abs(
                            elevator.getCurrentFloor()
                                    - request.getFloor()
                    );

            if (distance < minimumDistance) {

                minimumDistance = distance;
                bestElevator = elevator;
            }
        }

        return bestElevator;
    }
}
```

---

# 25. Why Strategy?

Suppose tomorrow the business says:

> Don't simply select the nearest elevator. Prefer elevators already moving toward the user's floor.

We can create:

```text
ElevatorSchedulingStrategy
        |
        +--- NearestElevatorStrategy
        |
        +--- DirectionAwareStrategy
        |
        +--- LoadAwareStrategy
```

We don't need to rewrite `ElevatorSystem`.

This follows:

**Open/Closed Principle**

---

# 26. ElevatorSystem

Now we need something that manages all elevators.

Responsibilities:

```text
add elevator
receive external request
select elevator
send request to elevator
```

This becomes:

```java
public class ElevatorSystem {

    private List<Elevator> elevators;
    private ElevatorSchedulingStrategy schedulingStrategy;

    public ElevatorSystem(
            ElevatorSchedulingStrategy schedulingStrategy) {

        this.elevators = new ArrayList<>();
        this.schedulingStrategy =
                schedulingStrategy;
    }
}
```

---

# 27. ElevatorSystem Request

Suppose user presses:

```text
Floor 5
UP
```

We can do:

```java
public void requestElevator(
        int floor,
        Direction direction) {

    ElevatorRequest request =
            new ElevatorRequest(
                    floor,
                    direction
            );

    Elevator elevator =
            schedulingStrategy.selectElevator(
                    elevators,
                    request
            );

    if (elevator == null) {

        throw new IllegalStateException(
                "No elevator available"
        );
    }

    elevator.addDestination(floor);

    System.out.println(
            "Elevator " +
            elevator.getId() +
            " assigned"
    );
}
```

---

# 28. Internal vs External Requests

This is an important distinction.

There are two types of elevator requests.

## External Request

A person is outside the elevator.

Example:

```text
Floor 5
Press UP
```

This asks:

> Which elevator should come to floor 5?

---

## Internal Request

Person is already inside the elevator.

Example:

```text
Current elevator floor = 5

User presses 10
```

This asks:

> Elevator, take me to floor 10.

These are different operations.

---

# 29. External Request

We can represent:

```java
ElevatorRequest
```

with:

```text
floor
direction
```

Example:

```java
new ElevatorRequest(
        5,
        Direction.UP
);
```

---

# 30. Internal Request

For an internal request, we don't need direction.

We only need:

```text
destination floor
```

We could create another class:

```java
public class ElevatorDestinationRequest {

    private int destinationFloor;

    public ElevatorDestinationRequest(
            int destinationFloor) {

        this.destinationFloor =
                destinationFloor;
    }

    public int getDestinationFloor() {
        return destinationFloor;
    }
}
```

However, for a simple LLD we can just expose:

```java
elevator.addDestination(10);
```

---

# 31. Important Design Decision

Should `ElevatorSystem` control elevator movement?

Bad design:

```java
class ElevatorSystem {

    moveElevator();
    openDoor();
    closeDoor();
    selectElevator();
    calculateNextFloor();
}
```

This makes `ElevatorSystem` too powerful.

Better:

```text
ElevatorSystem
    |
    | selects
    v
Elevator
    |
    +--- moves
    +--- opens door
    +--- closes door
```

The system decides **which elevator**.

The elevator controls **its own movement**.

---

# 32. Implementing Elevator Movement

Let's improve the `Elevator` class.

We can maintain destination floors.

When moving UP:

```text
Current = 2

Destinations:
5
8
10
```

We want:

```text
2 → 5 → 8 → 10
```

When moving DOWN:

```text
Current = 10

Destinations:
8
5
2
```

we want:

```text
10 → 8 → 5 → 2
```

---

# 33. Sorting Destinations

For UP:

```java
Collections.sort(destinationFloors);
```

For DOWN:

```java
destinationFloors.sort(
        Collections.reverseOrder()
);
```

But we also need to handle direction changes.

---

# 34. Simple Elevator Movement Algorithm

For a beginner-friendly implementation, we can use:

```text
If destination > current floor:
    move UP

If destination < current floor:
    move DOWN

If destination == current floor:
    open door
    remove destination
```

Example:

```text
Current = 5

Destination = 10

10 > 5

Therefore:
direction = UP
```

---

# 35. Elevator `step()` Method

A useful way to model the elevator is with a `step()` method.

Each call represents one movement step.

```java
public void step() {

    if (destinationFloors.isEmpty()) {

        direction = Direction.IDLE;
        state = ElevatorState.IDLE;

        return;
    }

    int target =
            destinationFloors.get(0);

    if (currentFloor < target) {

        direction = Direction.UP;
        state = ElevatorState.MOVING;

        currentFloor++;

    } else if (currentFloor > target) {

        direction = Direction.DOWN;
        state = ElevatorState.MOVING;

        currentFloor--;

    } else {

        arriveAtFloor();
    }
}
```

---

# 36. Arrive at Floor

When the elevator reaches the destination:

```java
private void arriveAtFloor() {

    state = ElevatorState.IDLE;

    door.open();

    System.out.println(
            "Elevator " + id +
            " reached floor " +
            currentFloor
    );

    destinationFloors.remove(
            Integer.valueOf(currentFloor)
    );

    door.close();

    if (destinationFloors.isEmpty()) {

        direction = Direction.IDLE;

    } else {

        state = ElevatorState.MOVING;
    }
}
```

---

# 37. Complete Elevator Class

Now we can combine everything.

```java
import java.util.ArrayList;
import java.util.List;

public class Elevator {

    private int id;
    private int currentFloor;

    private Direction direction;
    private ElevatorState state;

    private Door door;

    private List<Integer> destinationFloors;

    public Elevator(int id) {

        this.id = id;
        this.currentFloor = 0;

        this.direction = Direction.IDLE;
        this.state = ElevatorState.IDLE;

        this.door = new Door();

        this.destinationFloors =
                new ArrayList<>();
    }

    public void addDestination(int floor) {

        if (!destinationFloors.contains(floor)) {

            destinationFloors.add(floor);
        }
    }

    public void step() {

        if (destinationFloors.isEmpty()) {

            direction = Direction.IDLE;
            state = ElevatorState.IDLE;

            return;
        }

        int target =
                destinationFloors.get(0);

        if (currentFloor < target) {

            direction = Direction.UP;
            state = ElevatorState.MOVING;

            currentFloor++;

            System.out.println(
                    "Elevator " + id +
                    " moved UP to floor " +
                    currentFloor
            );

        } else if (currentFloor > target) {

            direction = Direction.DOWN;
            state = ElevatorState.MOVING;

            currentFloor--;

            System.out.println(
                    "Elevator " + id +
                    " moved DOWN to floor " +
                    currentFloor
            );

        } else {

            arriveAtFloor();
        }
    }

    private void arriveAtFloor() {

        state = ElevatorState.IDLE;

        System.out.println(
                "Elevator " + id +
                " arrived at floor " +
                currentFloor
        );

        door.open();

        destinationFloors.remove(
                Integer.valueOf(currentFloor)
        );

        door.close();

        if (destinationFloors.isEmpty()) {

            direction = Direction.IDLE;
            state = ElevatorState.IDLE;
        }
    }

    public int getId() {
        return id;
    }

    public int getCurrentFloor() {
        return currentFloor;
    }

    public Direction getDirection() {
        return direction;
    }

    public ElevatorState getState() {
        return state;
    }

    public Door getDoor() {
        return door;
    }

    public List<Integer> getDestinationFloors() {
        return destinationFloors;
    }
}
```

---

# 38. Problem With This Simple Implementation

Notice:

```java
int target = destinationFloors.get(0);
```

Suppose:

```text
Current floor = 5

Destinations:

10
7
2
```

The elevator goes:

```text
5 → 6 → 7 → 8 → 9 → 10
```

Then:

```text
10 → 9 → ... → 2
```

It works, but it isn't optimal because destination order depends on insertion order.

A better design would maintain requests according to direction.

This is where we can introduce a better scheduling strategy.

---

# 39. Better Scheduling Strategy

We can define:

```java
public interface ElevatorMovementStrategy {

    Integer getNextDestination(
            Elevator elevator
    );
}
```

This separates:

```text
How elevator moves
```

from:

```text
Elevator itself
```

For a simple interview design, this abstraction is useful if the interviewer asks about different scheduling algorithms.

---

# 40. SCAN / Elevator Algorithm

A common approach is:

```text
Continue in current direction
until no more requests exist in that direction.

Then reverse direction.
```

Example:

```text
Current floor = 5
Direction = UP

Requests:
2
7
8
10
3
```

The elevator serves:

```text
5 → 7 → 8 → 10
```

Then reverses:

```text
10 → 3 → 2
```

This reduces unnecessary direction changes.

---

# 41. A Simple Way to Implement SCAN

We can maintain two collections:

```text
upRequests
downRequests
```

For example:

```java
private TreeSet<Integer> upRequests;
private TreeSet<Integer> downRequests;
```

Why `TreeSet`?

Because it automatically keeps elements sorted.

For UP:

```java
upRequests.first()
```

For DOWN:

```java
downRequests.last()
```

depending on the direction.

---

# 42. Why TreeSet?

Suppose we add:

```text
10
5
8
7
```

A normal `ArrayList` contains:

```text
10, 5, 8, 7
```

A `TreeSet` keeps:

```text
5, 7, 8, 10
```

This is useful for elevator scheduling.

It also prevents duplicate destinations.

---

# 43. Advanced Elevator Request Storage

Instead of:

```java
List<Integer> destinationFloors;
```

we could use:

```java
private TreeSet<Integer> upRequests;
private TreeSet<Integer> downRequests;
```

Then:

```text
UP requests:
5, 8, 10

DOWN requests:
2, 3
```

The elevator can efficiently choose the next destination.

---

# 44. Which Design Should a Beginner Use?

For your **first LLD**, don't immediately start with the most complicated version.

Start with:

```text
List<Integer> destinations
```

Understand:

- Classes
- Responsibilities
- Interfaces
- Strategy Pattern
- State
- Relationships

Then improve it using:

```text
TreeSet
```

and direction-aware scheduling.

This is exactly how you should approach LLD.

---

# 45. ElevatorSystem Class

Now let's create the complete system.

```java
import java.util.ArrayList;
import java.util.List;

public class ElevatorSystem {

    private List<Elevator> elevators;

    private ElevatorSchedulingStrategy
            schedulingStrategy;

    public ElevatorSystem(
            ElevatorSchedulingStrategy schedulingStrategy) {

        this.elevators = new ArrayList<>();

        this.schedulingStrategy =
                schedulingStrategy;
    }

    public void addElevator(Elevator elevator) {

        elevators.add(elevator);
    }

    public void requestElevator(
            int floor,
            Direction direction) {

        ElevatorRequest request =
                new ElevatorRequest(
                        floor,
                        direction
                );

        Elevator elevator =
                schedulingStrategy.selectElevator(
                        elevators,
                        request
                );

        if (elevator == null) {

            throw new IllegalStateException(
                    "No suitable elevator available"
            );
        }

        elevator.addDestination(floor);

        System.out.println(
                "Elevator " +
                elevator.getId() +
                " assigned to floor " +
                floor
        );
    }

    public List<Elevator> getElevators() {
        return elevators;
    }
}
```

---

# 46. Complete Strategy Interface

```java
import java.util.List;

public interface ElevatorSchedulingStrategy {

    Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request
    );
}
```

---

# 47. Complete Nearest Elevator Strategy

```java
import java.util.List;

public class NearestElevatorStrategy
        implements ElevatorSchedulingStrategy {

    @Override
    public Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request) {

        Elevator bestElevator = null;

        int minimumDistance =
                Integer.MAX_VALUE;

        for (Elevator elevator : elevators) {

            if (elevator.getState()
                    != ElevatorState.IDLE) {

                continue;
            }

            int distance =
                    Math.abs(
                            elevator.getCurrentFloor()
                                    - request.getFloor()
                    );

            if (distance < minimumDistance) {

                minimumDistance = distance;
                bestElevator = elevator;
            }
        }

        return bestElevator;
    }
}
```

---

# 48. Main Class

Now let's see how the system is used.

```java
public class Main {

    public static void main(String[] args) {

        ElevatorSchedulingStrategy strategy =
                new NearestElevatorStrategy();

        ElevatorSystem system =
                new ElevatorSystem(strategy);

        Elevator elevator1 =
                new Elevator(1);

        Elevator elevator2 =
                new Elevator(2);

        elevator2.addDestination(8);

        system.addElevator(elevator1);
        system.addElevator(elevator2);

        system.requestElevator(
                5,
                Direction.UP
        );

        Elevator elevator =
                elevator1;

        elevator.addDestination(10);

        for (int i = 0; i < 15; i++) {

            elevator.step();
        }
    }
}
```

---

# 49. Full System Flow

Let's understand the system from beginning to end.

Suppose:

```text
Building floors: 0 - 10

Elevator 1: floor 0
Elevator 2: floor 8
```

User is on:

```text
Floor 5
```

and wants:

```text
UP
```

---

## Step 1 — User presses UP

```text
User
 |
 v
ElevatorSystem
```

Call:

```java
system.requestElevator(
        5,
        Direction.UP
);
```

---

## Step 2 — Create Request

```text
ElevatorRequest

floor = 5
direction = UP
```

---

## Step 3 — Select Elevator

`ElevatorSystem` delegates to:

```text
ElevatorSchedulingStrategy
```

The nearest elevator strategy checks:

```text
Elevator 1 → floor 0
Distance = 5

Elevator 2 → floor 8
Distance = 3
```

So:

```text
Elevator 2
```

is selected.

---

## Step 4 — Add Destination

```java
elevator.addDestination(5);
```

Now elevator 2 knows:

```text
Destination = 5
```

---

## Step 5 — Elevator Moves

If:

```text
Current = 8
Target = 5
```

then:

```text
8
 ↓
7
 ↓
6
 ↓
5
```

---

## Step 6 — Door Opens

At floor 5:

```java
door.open();
```

---

## Step 7 — User Enters

User enters the elevator and presses:

```text
10
```

So:

```java
elevator.addDestination(10);
```

---

## Step 8 — Elevator Moves Up

```text
5
 ↓
6
 ↓
7
 ↓
8
 ↓
9
 ↓
10
```

---

## Step 9 — Door Opens

At floor 10:

```java
door.open();
```

Then:

```java
door.close();
```

---

# 50. Class Diagram

The basic design is:

```text
                    +----------------------+
                    |    ElevatorSystem    |
                    +----------------------+
                    | - elevators          |
                    | - schedulingStrategy |
                    +----------------------+
                    | + addElevator()      |
                    | + requestElevator()  |
                    +----------+-----------+
                               |
                               | HAS MANY
                               v
                    +----------------------+
                    |      Elevator        |
                    +----------------------+
                    | - id                 |
                    | - currentFloor       |
                    | - direction          |
                    | - state              |
                    | - door               |
                    | - destinations       |
                    +----------------------+
                    | + addDestination()   |
                    | + step()             |
                    +----------+-----------+
                               |
                               | HAS-A
                               v
                    +----------------------+
                    |        Door          |
                    +----------------------+
                    | - state              |
                    +----------------------+
                    | + open()             |
                    | + close()            |
                    +----------------------+


+--------------------------+
|   ElevatorRequest        |
+--------------------------+
| - floor                  |
| - direction              |
+--------------------------+


+--------------------------------+
| ElevatorSchedulingStrategy     |
+--------------------------------+
| + selectElevator()             |
+---------------+----------------+
                |
        +-------+--------+
        |                |
        v                v
+----------------+ +-------------------+
| Nearest        | | DirectionAware    |
| Elevator       | | Elevator          |
+----------------+ +-------------------+
```

---

# 51. Relationships

Let's understand the relationships.

## ElevatorSystem HAS-A Elevators

```java
private List<Elevator> elevators;
```

Therefore:

```text
ElevatorSystem
      |
      +--- Elevator
      +--- Elevator
      +--- Elevator
```

---

## Elevator HAS-A Door

```java
private Door door;
```

Therefore:

```text
Elevator
   |
   +--- Door
```

---

## ElevatorSystem USES-A SchedulingStrategy

```java
private ElevatorSchedulingStrategy schedulingStrategy;
```

This is dependency through abstraction.

---

## Strategy IS-A ElevatorSchedulingStrategy

```java
public class NearestElevatorStrategy
        implements ElevatorSchedulingStrategy
```

This is polymorphism.

---

# 52. OOP Concepts Used

This design demonstrates several OOP concepts.

---

# 53. Encapsulation

Fields are private:

```java
private int currentFloor;
private Direction direction;
private ElevatorState state;
```

We don't allow arbitrary external modification.

Instead:

```java
elevator.addDestination(10);
```

controls how state changes.

---

# 54. Abstraction

We don't expose scheduling implementation.

Instead:

```java
ElevatorSchedulingStrategy
```

defines:

```java
selectElevator()
```

The system doesn't care whether the strategy uses:

```text
nearest elevator
direction
load
distance
priority
```

---

# 55. Polymorphism

We can write:

```java
ElevatorSchedulingStrategy strategy =
        new NearestElevatorStrategy();
```

Later:

```java
ElevatorSchedulingStrategy strategy =
        new DirectionAwareStrategy();
```

The `ElevatorSystem` remains unchanged.

---

# 56. Composition

Examples:

```text
ElevatorSystem HAS elevators

Elevator HAS door
```

These are HAS-A relationships.

---

# 57. Strategy Pattern

This is the most important design pattern in this problem.

We have:

```text
ElevatorSchedulingStrategy
          |
          +--- NearestElevatorStrategy
          |
          +--- DirectionAwareStrategy
          |
          +--- LoadAwareStrategy
```

The behavior that changes is:

> How do we select an elevator?

Therefore Strategy Pattern is a natural fit.

---

# 58. Factory Pattern — Do We Need It?

Not necessarily.

We could create:

```java
new NearestElevatorStrategy();
```

directly.

There is no strong reason to introduce a Factory yet.

Remember:

> Don't use a design pattern just because you know it.

Use a pattern when it solves a real design problem.

---

# 59. State Pattern — Do We Need It?

We currently have:

```java
ElevatorState.IDLE
ElevatorState.MOVING
```

An enum is sufficient.

But imagine we have:

```text
IDLE
MOVING
DOOR_OPEN
MAINTENANCE
EMERGENCY
OVERLOADED
```

and behavior changes heavily depending on state.

For example:

```text
Maintenance:
    cannot accept requests

Emergency:
    stop immediately

Overloaded:
    cannot move

Door Open:
    cannot move
```

At that point, the **State Pattern** may become useful.

---

# 60. State Pattern

We could eventually have:

```text
ElevatorState
      |
      +--- IdleState
      +--- MovingState
      +--- MaintenanceState
      +--- EmergencyState
```

Each state could define behavior.

For example:

```java
public interface ElevatorState {

    void move(Elevator elevator);

    void openDoor(Elevator elevator);

    void closeDoor(Elevator elevator);
}
```

But this is more advanced.

For your first LLD, use an enum until the state behavior becomes complex.

---

# 61. SOLID — Single Responsibility

Each class has a focused responsibility.

```text
Elevator
    → controls elevator movement

Door
    → controls door

ElevatorSystem
    → manages elevators and external requests

ElevatorRequest
    → represents a request

SchedulingStrategy
    → decides which elevator to use
```

This is SRP.

---

# 62. SOLID — Open/Closed

Suppose we currently have:

```text
NearestElevatorStrategy
```

Later:

```text
DirectionAwareStrategy
```

We add a new class rather than rewriting:

```text
ElevatorSystem
```

Therefore the system is open for extension.

---

# 63. SOLID — Dependency Inversion

`ElevatorSystem` depends on:

```java
ElevatorSchedulingStrategy
```

rather than:

```java
NearestElevatorStrategy
```

So:

```java
private ElevatorSchedulingStrategy
        schedulingStrategy;
```

is better than:

```java
private NearestElevatorStrategy
        schedulingStrategy;
```

---

# 64. Dependency Injection

We pass the strategy through the constructor:

```java
public ElevatorSystem(
        ElevatorSchedulingStrategy schedulingStrategy) {

    this.schedulingStrategy =
            schedulingStrategy;
}
```

Usage:

```java
ElevatorSystem system =
        new ElevatorSystem(
                new NearestElevatorStrategy()
        );
```

This is constructor dependency injection.

---

# 65. Why Is This Better?

Suppose the company changes the requirement.

Old:

```text
Nearest elevator
```

New:

```text
Nearest elevator moving in the same direction
```

We can do:

```java
ElevatorSystem system =
        new ElevatorSystem(
                new DirectionAwareStrategy()
        );
```

We don't need to modify:

```text
ElevatorSystem
Elevator
Door
ElevatorRequest
```

This is good design.

---

# 66. Important Design Question

## Who decides which elevator moves?

Answer:

```text
ElevatorSchedulingStrategy
```

---

## Who actually moves the elevator?

Answer:

```text
Elevator
```

---

## Who controls the door?

Answer:

```text
Door
```

---

## Who manages all elevators?

Answer:

```text
ElevatorSystem
```

This separation is very important.

---

# 67. Common Beginner Mistake

Don't put everything inside `ElevatorSystem`.

Avoid:

```java
class ElevatorSystem {

    selectElevator();

    moveElevator();

    openDoor();

    closeDoor();

    calculateNextFloor();

    addFloor();

    handleEmergency();

    ...
}
```

This becomes a God Class.

Instead:

```text
ElevatorSystem
    |
    +--- Elevator
    |       |
    |       +--- Door
    |
    +--- SchedulingStrategy
    |
    +--- ElevatorRequest
```

---

# 68. Another Beginner Mistake

Don't create unnecessary classes.

For example:

```text
ElevatorButton
FloorButton
UpButton
DownButton
FloorDisplay
ElevatorDisplay
Motor
Cable
Pulley
```

These may be useful in a very detailed physical elevator simulation, but they're unnecessary for a basic LLD interview unless requirements specifically ask for them.

Start simple.

Add classes when requirements justify them.

---

# 69. Capacity

A real elevator has a capacity.

For example:

```text
Maximum people = 10
Maximum weight = 800 kg
```

We could introduce:

```java
private int currentLoad;
private int maximumLoad;
```

Then:

```java
public boolean canAcceptPassenger(int weight) {

    return currentLoad + weight
            <= maximumLoad;
}
```

This is a natural extension.

---

# 70. Emergency Mode

Suppose there is an emergency.

The elevator should:

```text
Stop
Open doors at safe floor
Reject new requests
```

We could add:

```java
public void enterEmergencyMode() {
    ...
}
```

But again, don't add it until the requirement exists.

---

# 71. Maintenance Mode

Maintenance elevator should not accept normal requests.

Possible state:

```java
MAINTENANCE
```

Then:

```java
if (state == ElevatorState.MAINTENANCE) {
    rejectRequest();
}
```

For a more complex system, State Pattern becomes attractive.

---

# 72. Concurrency

Concurrency is important in a real elevator system.

Imagine:

```text
User A → requests floor 5
User B → requests floor 8
User C → requests floor 10
```

at almost exactly the same time.

Multiple threads may modify:

```text
destination requests
elevator state
current floor
```

Therefore shared state may need synchronization.

Possible Java tools:

```text
synchronized
Lock
ReentrantLock
Concurrent collections
```

For a simple LLD interview, you can say:

> "In a production implementation, elevator request queues and elevator state transitions would need appropriate concurrency control because multiple floor requests can arrive concurrently."

That's usually enough unless the interviewer asks you to implement it.

---

# 73. Better Production-Level Request Queue

For a more realistic design, instead of:

```java
List<Integer> destinationFloors;
```

we could maintain:

```java
TreeSet<Integer> upRequests;
TreeSet<Integer> downRequests;
```

Conceptually:

```text
Elevator 1

Current floor: 5
Direction: UP

UP requests:
7
8
10

DOWN requests:
2
3
```

Then the elevator can process:

```text
5 → 7 → 8 → 10
```

then:

```text
10 → 3 → 2
```

This is closer to a real elevator scheduling algorithm.

---

# 74. Complexity

For our simple implementation:

Finding an elevator:

```text
O(E)
```

where `E` = number of elevators.

Finding a destination in a list:

```text
O(D)
```

where `D` = number of destinations.

If we use a `TreeSet`, request management can become more efficient for ordered access.

But don't over-optimize a small LLD unless the interviewer asks about scalability.

---

# 75. Complete Basic Code Structure

Our project can look like:

```text
src/
 |
 +-- Direction.java
 |
 +-- ElevatorState.java
 |
 +-- DoorState.java
 |
 +-- ElevatorRequest.java
 |
 +-- Door.java
 |
 +-- Elevator.java
 |
 +-- ElevatorSchedulingStrategy.java
 |
 +-- NearestElevatorStrategy.java
 |
 +-- ElevatorSystem.java
 |
 +-- Main.java
```

---

# 76. Complete Code

## Direction.java

```java
public enum Direction {
    UP,
    DOWN,
    IDLE
}
```

---

## ElevatorState.java

```java
public enum ElevatorState {
    IDLE,
    MOVING
}
```

---

## DoorState.java

```java
public enum DoorState {
    OPEN,
    CLOSED
}
```

---

## ElevatorRequest.java

```java
public class ElevatorRequest {

    private int floor;
    private Direction direction;

    public ElevatorRequest(
            int floor,
            Direction direction) {

        this.floor = floor;
        this.direction = direction;
    }

    public int getFloor() {
        return floor;
    }

    public Direction getDirection() {
        return direction;
    }
}
```

---

## Door.java

```java
public class Door {

    private DoorState state;

    public Door() {
        this.state = DoorState.CLOSED;
    }

    public void open() {

        if (state == DoorState.OPEN) {
            return;
        }

        state = DoorState.OPEN;

        System.out.println(
                "Door opened"
        );
    }

    public void close() {

        if (state == DoorState.CLOSED) {
            return;
        }

        state = DoorState.CLOSED;

        System.out.println(
                "Door closed"
        );
    }

    public DoorState getState() {
        return state;
    }
}
```

---

## Elevator.java

```java
import java.util.ArrayList;
import java.util.List;

public class Elevator {

    private int id;

    private int currentFloor;

    private Direction direction;

    private ElevatorState state;

    private Door door;

    private List<Integer> destinationFloors;

    public Elevator(int id) {

        this.id = id;

        this.currentFloor = 0;

        this.direction = Direction.IDLE;

        this.state = ElevatorState.IDLE;

        this.door = new Door();

        this.destinationFloors =
                new ArrayList<>();
    }

    public void addDestination(int floor) {

        if (!destinationFloors.contains(floor)) {

            destinationFloors.add(floor);
        }
    }

    public void step() {

        if (destinationFloors.isEmpty()) {

            direction = Direction.IDLE;

            state = ElevatorState.IDLE;

            return;
        }

        int target =
                destinationFloors.get(0);

        if (currentFloor < target) {

            direction = Direction.UP;

            state = ElevatorState.MOVING;

            currentFloor++;

            System.out.println(
                    "Elevator " + id +
                    " moved UP to floor " +
                    currentFloor
            );

        } else if (currentFloor > target) {

            direction = Direction.DOWN;

            state = ElevatorState.MOVING;

            currentFloor--;

            System.out.println(
                    "Elevator " + id +
                    " moved DOWN to floor " +
                    currentFloor
            );

        } else {

            arriveAtFloor();
        }
    }

    private void arriveAtFloor() {

        System.out.println(
                "Elevator " + id +
                " arrived at floor " +
                currentFloor
        );

        state = ElevatorState.IDLE;

        door.open();

        destinationFloors.remove(
                Integer.valueOf(currentFloor)
        );

        door.close();

        if (destinationFloors.isEmpty()) {

            direction = Direction.IDLE;

            state = ElevatorState.IDLE;
        }
    }

    public int getId() {
        return id;
    }

    public int getCurrentFloor() {
        return currentFloor;
    }

    public Direction getDirection() {
        return direction;
    }

    public ElevatorState getState() {
        return state;
    }

    public Door getDoor() {
        return door;
    }

    public List<Integer> getDestinationFloors() {
        return destinationFloors;
    }
}
```

---

## ElevatorSchedulingStrategy.java

```java
import java.util.List;

public interface ElevatorSchedulingStrategy {

    Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request
    );
}
```

---

## NearestElevatorStrategy.java

```java
import java.util.List;

public class NearestElevatorStrategy
        implements ElevatorSchedulingStrategy {

    @Override
    public Elevator selectElevator(
            List<Elevator> elevators,
            ElevatorRequest request) {

        Elevator bestElevator = null;

        int minimumDistance =
                Integer.MAX_VALUE;

        for (Elevator elevator : elevators) {

            if (elevator.getState()
                    != ElevatorState.IDLE) {

                continue;
            }

            int distance =
                    Math.abs(
                            elevator.getCurrentFloor()
                                    - request.getFloor()
                    );

            if (distance < minimumDistance) {

                minimumDistance = distance;

                bestElevator = elevator;
            }
        }

        return bestElevator;
    }
}
```

---

## ElevatorSystem.java

```java
import java.util.ArrayList;
import java.util.List;

public class ElevatorSystem {

    private List<Elevator> elevators;

    private ElevatorSchedulingStrategy
            schedulingStrategy;

    public ElevatorSystem(
            ElevatorSchedulingStrategy
                    schedulingStrategy) {

        this.elevators =
                new ArrayList<>();

        this.schedulingStrategy =
                schedulingStrategy;
    }

    public void addElevator(
            Elevator elevator) {

        elevators.add(elevator);
    }

    public void requestElevator(
            int floor,
            Direction direction) {

        ElevatorRequest request =
                new ElevatorRequest(
                        floor,
                        direction
                );

        Elevator elevator =
                schedulingStrategy.selectElevator(
                        elevators,
                        request
                );

        if (elevator == null) {

            throw new IllegalStateException(
                    "No suitable elevator available"
            );
        }

        elevator.addDestination(floor);

        System.out.println(
                "Elevator " +
                elevator.getId() +
                " assigned to floor " +
                floor
        );
    }

    public List<Elevator> getElevators() {
        return elevators;
    }
}
```

---

## Main.java

```java
public class Main {

    public static void main(String[] args) {

        ElevatorSchedulingStrategy strategy =
                new NearestElevatorStrategy();

        ElevatorSystem system =
                new ElevatorSystem(strategy);

        Elevator elevator1 =
                new Elevator(1);

        Elevator elevator2 =
                new Elevator(2);

        elevator1.addDestination(3);

        system.addElevator(elevator1);

        system.addElevator(elevator2);

        // User on floor 5 requests UP
        system.requestElevator(
                5,
                Direction.UP
        );

        // Simulate elevator movement
        for (int i = 0; i < 10; i++) {

            for (Elevator elevator :
                    system.getElevators()) {

                elevator.step();
            }
        }

        // User inside elevator selects floor 10

        Elevator selectedElevator =
                elevator2;

        selectedElevator.addDestination(10);

        // Simulate movement again

        for (int i = 0; i < 15; i++) {

            selectedElevator.step();
        }
    }
}
```

---

# 77. One Important Improvement

The basic code above is intentionally simple for learning.

There is a subtle issue:

```java
elevator1.addDestination(3);
```

makes elevator 1 `IDLE` even though it has a destination because our `state` changes only when `step()` is called.

For a production-quality implementation, we'd centralize state transitions and request management more carefully.

This is normal in an LLD learning progression.

First understand the design.

Then refine the implementation.

---

# 78. Better Mental Model

Think of the system as three levels.

## Level 1 — System

```text
ElevatorSystem
```

Question it answers:

> Which elevator should handle this request?

---

## Level 2 — Elevator

```text
Elevator
```

Question it answers:

> How should I move to my assigned destinations?

---

## Level 3 — Door

```text
Door
```

Question it answers:

> Is my door open or closed?

Therefore:

```text
ElevatorSystem
       |
       v
   Elevator
       |
       v
      Door
```

Each level has a clear responsibility.

---

# 79. Interview Version

If an interviewer says:

> Design an Elevator System.

Start with:

```text
First, I would clarify the requirements.

I'll assume the building has multiple floors and multiple elevators.
Users can request an elevator from a floor by specifying UP or DOWN.
Once inside an elevator, users can select destination floors.

The system needs to select an appropriate elevator for an external
request, while each elevator is responsible for moving to its
pending destinations and controlling its door.

I'll model ElevatorSystem, Elevator, Door and ElevatorRequest as
the main classes.

For elevator selection, I'll use an ElevatorSchedulingStrategy
interface so that different scheduling algorithms can be plugged
in without changing the elevator system.
```

Then draw:

```text
ElevatorSystem
      |
      +---- Elevator
      |        |
      |        +---- Door
      |
      +---- ElevatorSchedulingStrategy
                   |
                   +---- NearestElevatorStrategy
```

Then explain:

```text
External Request
       ↓
ElevatorSystem
       ↓
SchedulingStrategy
       ↓
Elevator
       ↓
Destination Queue
       ↓
Move
       ↓
Door Open
       ↓
Door Close
```

---

# 80. Common Interview Follow-up Questions

After the basic design, an interviewer may ask:

### Q1. How do you choose the elevator?

Answer:

```text
Use ElevatorSchedulingStrategy.
```

Possible strategies:

```text
Nearest
Direction-aware
Load-aware
Priority-based
```

---

### Q2. How do you handle multiple destinations?

Answer:

```text
Maintain pending destination requests.
```

For better scheduling:

```text
TreeSet for UP requests
TreeSet for DOWN requests
```

---

### Q3. What if two requests arrive simultaneously?

Answer:

```text
Use appropriate concurrency control around
shared elevator state and request queues.
```

---

### Q4. What if an elevator is under maintenance?

Answer:

```text
Add MAINTENANCE state.

Maintenance elevators should not receive
normal requests.
```

---

### Q5. What if the elevator is overloaded?

Answer:

```text
Maintain current load and maximum capacity.

Reject movement until load is within limits.
```

---

### Q6. What if an elevator breaks?

Answer:

```text
Mark elevator unavailable.
Pending requests can be reassigned to another elevator.
```

---

### Q7. Can you add emergency mode?

Answer:

```text
Add an emergency state.

For complex state-dependent behavior,
consider the State Pattern.
```

---

# 81. Important Design Patterns

For this problem, remember:

```text
Strategy Pattern
    ↓
Elevator selection / scheduling

State Pattern
    ↓
Useful when elevator states become complex

Factory Pattern
    ↓
Not required initially
Could be useful if object creation becomes complex
```

Don't force all three into the design.

---

# 82. Final Architecture

The beginner version:

```text
                         +---------------------+
                         |   ElevatorSystem     |
                         +---------------------+
                         | - elevators         |
                         | - schedulingStrategy|
                         +----------+----------+
                                    |
                                    |
                                    v
                         +---------------------+
                         |      Elevator       |
                         +---------------------+
                         | - id                |
                         | - currentFloor      |
                         | - direction         |
                         | - state             |
                         | - destinations      |
                         | - door              |
                         +----------+----------+
                                    |
                                    |
                                    v
                         +---------------------+
                         |        Door         |
                         +---------------------+
                         | - state             |
                         +---------------------+


+--------------------------+
|    ElevatorRequest       |
+--------------------------+
| - floor                  |
| - direction              |
+--------------------------+


+--------------------------------+
| ElevatorSchedulingStrategy     |
+--------------------------------+
| + selectElevator()             |
+---------------+----------------+
                |
                v
+--------------------------------+
| NearestElevatorStrategy        |
+--------------------------------+
```

---

# 83. Final Summary

The most important concepts from this Elevator LLD are:

```text
ElevatorSystem
    ↓
Manages multiple elevators
```

```text
Elevator
    ↓
Manages its own movement and destinations
```

```text
Door
    ↓
Manages door state
```

```text
ElevatorRequest
    ↓
Represents an external elevator request
```

```text
ElevatorSchedulingStrategy
    ↓
Defines how an elevator is selected
```

```text
NearestElevatorStrategy
    ↓
One implementation of elevator selection
```

---

# 84. What You Should Learn From This Problem

Don't memorize the code.

Understand this thought process:

```text
Requirement
    ↓
What are the objects?
    ↓
What does each object know?
    ↓
What does each object do?
    ↓
Who should be responsible for what?
    ↓
Which behavior changes?
    ↓
Create abstraction for changing behavior
    ↓
Use Strategy Pattern
    ↓
Define relationships
    ↓
Write code
```

For Elevator specifically:

```text
"What changes?"
        |
        v
How we select an elevator
        |
        v
ElevatorSchedulingStrategy
```

That's the core LLD insight.

---

# 85. Beginner Checklist

Before considering your Elevator LLD complete, you should be able to explain:

- [ ] What is LLD?
- [ ] Why do we need `ElevatorSystem`?
- [ ] Why do we need `Elevator`?
- [ ] Why is `Door` a separate class?
- [ ] What is `ElevatorRequest`?
- [ ] What is an external request?
- [ ] What is an internal request?
- [ ] What is `Direction`?
- [ ] What is `ElevatorState`?
- [ ] What is composition?
- [ ] What is polymorphism?
- [ ] Why use an interface for scheduling?
- [ ] Why use Strategy Pattern?
- [ ] How do we select the nearest elevator?
- [ ] How do we handle multiple destinations?
- [ ] How would we implement SCAN?
- [ ] How would we handle maintenance?
- [ ] How would we handle emergency mode?
- [ ] How would we handle concurrency?
- [ ] How would we extend the system?

If you can answer these questions, you understand the **core LLD of an Elevator System**, rather than merely memorizing its Java code.