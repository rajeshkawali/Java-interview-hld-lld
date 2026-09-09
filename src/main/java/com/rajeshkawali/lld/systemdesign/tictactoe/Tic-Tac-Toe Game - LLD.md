# Tic-Tac-Toe Game — LLD

## 1. Problem Statement

Design a Tic-Tac-Toe game where:

- Two players play against each other.
- The board is `N x N`.
- Each player has a symbol such as `X` or `O`.
- Players take turns.
- A player wins when they get `N` symbols in a row.
- A game ends when:
  - A player wins, or
  - The board is completely filled and the game is a draw.

For the basic implementation, we'll use a `3 x 3` board.

---

# 2. First Understand the Game Flow

Suppose we have:

```text
Player 1 → X
Player 2 → O
```

The game looks like:

```text
        Game
         |
         v
     Initialize
       Board
         |
         v
    Player X turn
         |
         v
      Make move
         |
         v
    Check winner
      /       \
    Yes        No
    |           |
    v           v
  Game Over   Switch
              Player
                |
                v
           Player O turn
                |
                v
             Make move
```

The important LLD question is:

> **What objects are involved in this game?**

---

# 3. Identify the Main Entities

From the requirements, we can identify:

```text
Game
Player
Board
Cell
Symbol
```

We can also have:

```text
GameStatus
```

So our initial design is:

```text
Game
 |
 +-- Board
 |    |
 |    +-- Cell[][]
 |
 +-- Player
 |
 +-- Player
```

---

# 4. Symbol

Each player needs a symbol.

```java
public enum Symbol {
    X,
    O
}
```

We can also have an empty cell represented by `null`.

For example:

```text
+---+---+---+
| X | O |   |
+---+---+---+
|   | X |   |
+---+---+---+
| O |   | X |
+---+---+---+
```

---

# 5. Game Status

The game can have three basic states:

```java
public enum GameStatus {
    IN_PROGRESS,
    X_WON,
    O_WON,
    DRAW
}
```

Alternatively, we can simply store the winner as a `Player` and use:

```text
IN_PROGRESS
DRAW
WON
```

For a beginner implementation, we'll use:

```java
public enum GameStatus {
    IN_PROGRESS,
    X_WON,
    O_WON,
    DRAW
}
```

---

# 6. Player

A player should have:

```text
Player
 |
 +-- id
 +-- name
 +-- symbol
```

Java:

```java
public class Player {

    private int id;
    private String name;
    private Symbol symbol;

    public Player(
            int id,
            String name,
            Symbol symbol) {

        this.id = id;
        this.name = name;
        this.symbol = symbol;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Symbol getSymbol() {
        return symbol;
    }
}
```

---

# 7. Why Do We Need a Player Class?

We could simply do:

```java
String playerName;
Symbol symbol;
```

inside `Game`.

But that's not a good design.

A player is an independent entity.

For example:

```text
Player 1
    |
    +-- name = Rahul
    +-- symbol = X

Player 2
    |
    +-- name = Amit
    +-- symbol = O
```

So it makes sense to have:

```java
Player
```

as its own class.

---

# 8. Cell

Should we create a `Cell` class?

For a simple 3×3 implementation, we don't necessarily need one.

We could use:

```java
Symbol[][] board;
```

But if the interviewer asks for extensibility, a `Cell` class can make the model clearer.

For example:

```java
public class Cell {

    private Symbol symbol;

    public Cell() {
        this.symbol = null;
    }

    public boolean isEmpty() {
        return symbol == null;
    }

    public void mark(Symbol symbol) {

        if (!isEmpty()) {
            throw new IllegalStateException(
                    "Cell is already occupied"
            );
        }

        this.symbol = symbol;
    }

    public Symbol getSymbol() {
        return symbol;
    }
}
```

Now:

```text
Board
 |
 +-- Cell
 +-- Cell
 +-- Cell
 ...
```

---

# 9. Board

The board is one of the most important classes.

Responsibilities of `Board`:

- Store cells.
- Check whether a cell is empty.
- Place a symbol.
- Check whether the board is full.
- Check whether a player has won.

We can represent the board as:

```java
private Cell[][] cells;
```

---

# 10. Board Class

```java
public class Board {

    private int size;
    private Cell[][] cells;

    public Board(int size) {

        if (size < 3) {
            throw new IllegalArgumentException(
                    "Board size must be at least 3"
            );
        }

        this.size = size;
        this.cells = new Cell[size][size];

        initializeBoard();
    }

    private void initializeBoard() {

        for (int row = 0; row < size; row++) {

            for (int col = 0; col < size; col++) {

                cells[row][col] = new Cell();
            }
        }
    }

    public void placeSymbol(
            int row,
            int col,
            Symbol symbol) {

        validatePosition(row, col);

        cells[row][col].mark(symbol);
    }

    private void validatePosition(
            int row,
            int col) {

        if (row < 0 || row >= size
                || col < 0 || col >= size) {

            throw new IllegalArgumentException(
                    "Invalid board position"
            );
        }
    }

    public boolean isFull() {

        for (int row = 0; row < size; row++) {

            for (int col = 0; col < size; col++) {

                if (cells[row][col].isEmpty()) {
                    return false;
                }
            }
        }

        return true;
    }

    public Cell getCell(int row, int col) {
        validatePosition(row, col);
        return cells[row][col];
    }

    public int getSize() {
        return size;
    }
}
```

At this point we have:

```text
Game
 |
 +-- Board
      |
      +-- Cell[][]
```

---

# 11. Where Should Winner Logic Go?

This is an important LLD question.

Should `Game` check:

```text
row complete?
column complete?
diagonal complete?
```

Or should `Board` check it?

The board knows:

```text
What is inside each cell?
```

Therefore, the board is a natural place to ask:

> "Does this symbol have a winning combination?"

However, we can make the design even cleaner by introducing a separate:

```text
WinningStrategy
```

This becomes useful when the board can have different winning rules.

---

# 12. Simple Approach — Winner Logic Inside Board

For a basic interview implementation, we can add:

```java
public boolean hasWon(Symbol symbol) {

    // Check rows
    for (int row = 0; row < size; row++) {

        boolean win = true;

        for (int col = 0; col < size; col++) {

            if (cells[row][col].getSymbol() != symbol) {
                win = false;
                break;
            }
        }

        if (win) {
            return true;
        }
    }

    // Check columns
    for (int col = 0; col < size; col++) {

        boolean win = true;

        for (int row = 0; row < size; row++) {

            if (cells[row][col].getSymbol() != symbol) {
                win = false;
                break;
            }
        }

        if (win) {
            return true;
        }
    }

    // Check main diagonal

    boolean diagonalWin = true;

    for (int i = 0; i < size; i++) {

        if (cells[i][i].getSymbol() != symbol) {
            diagonalWin = false;
            break;
        }
    }

    if (diagonalWin) {
        return true;
    }

    // Check opposite diagonal

    boolean oppositeDiagonalWin = true;

    for (int i = 0; i < size; i++) {

        if (cells[i][size - 1 - i].getSymbol() != symbol) {
            oppositeDiagonalWin = false;
            break;
        }
    }

    return oppositeDiagonalWin;
}
```

This works well for a basic design.

---

# 13. Better Approach — Winning Strategy

Now imagine the interviewer says:

> "What if the winning rules change?"

For example:

```text
3 × 3
→ Need 3 in a row

4 × 4
→ Need 4 in a row

Connect Four
→ Need 4 connected symbols

Custom game
→ Different winning rules
```

Instead of putting all winning logic inside `Board`, create:

```java
public interface WinningStrategy {

    boolean checkWinner(
            Board board,
            Symbol symbol,
            int row,
            int col
    );
}
```

Then:

```text
WinningStrategy
       |
       +---- RowColumnDiagonalStrategy
       |
       +---- CustomWinningStrategy
```

This is the **Strategy Pattern**.

---

# 14. Why Strategy Pattern?

Because the algorithm for deciding a winner can change.

This is exactly when Strategy Pattern is useful.

```text
Game
 |
 | uses
 v
WinningStrategy
 |
 +---- StandardWinningStrategy
 |
 +---- CustomWinningStrategy
```

The `Game` class doesn't need to know how winning is calculated.

It only asks:

```java
winningStrategy.checkWinner(...);
```

---

# 15. Move

We also need to represent a move.

A move contains:

```text
Move
 |
 +-- player
 +-- row
 +-- column
```

Java:

```java
public class Move {

    private Player player;
    private int row;
    private int column;

    public Move(
            Player player,
            int row,
            int column) {

        this.player = player;
        this.row = row;
        this.column = column;
    }

    public Player getPlayer() {
        return player;
    }

    public int getRow() {
        return row;
    }

    public int getColumn() {
        return column;
    }
}
```

Why is `Move` useful?

Because we can maintain:

```java
List<Move> moves;
```

This gives us game history.

For example:

```text
Move 1 → X → (0,0)
Move 2 → O → (1,1)
Move 3 → X → (0,1)
Move 4 → O → (2,2)
```

This becomes useful for:

- Undo
- Replay
- Game history
- Auditing

---

# 16. Game Class

Now we need the main class responsible for controlling the game.

Responsibilities:

- Maintain players.
- Maintain current player.
- Maintain board.
- Process moves.
- Check winner.
- Check draw.
- Switch turns.
- Maintain game status.

```text
Game
 |
 +-- Board
 +-- Player 1
 +-- Player 2
 +-- currentPlayer
 +-- WinningStrategy
 +-- GameStatus
 +-- moves
```

---

# 17. Game Implementation

```java
import java.util.ArrayList;
import java.util.List;

public class Game {

    private Board board;

    private Player player1;
    private Player player2;

    private Player currentPlayer;

    private WinningStrategy winningStrategy;

    private GameStatus status;

    private List<Move> moves;

    public Game(
            Board board,
            Player player1,
            Player player2,
            WinningStrategy winningStrategy) {

        this.board = board;
        this.player1 = player1;
        this.player2 = player2;
        this.currentPlayer = player1;
        this.winningStrategy = winningStrategy;

        this.status = GameStatus.IN_PROGRESS;

        this.moves = new ArrayList<>();
    }

    public void makeMove(int row, int col) {

        if (status != GameStatus.IN_PROGRESS) {
            throw new IllegalStateException(
                    "Game is already over"
            );
        }

        board.placeSymbol(
                row,
                col,
                currentPlayer.getSymbol()
        );

        Move move = new Move(
                currentPlayer,
                row,
                col
        );

        moves.add(move);

        if (winningStrategy.checkWinner(
                board,
                currentPlayer.getSymbol(),
                row,
                col)) {

            if (currentPlayer.getSymbol() == Symbol.X) {
                status = GameStatus.X_WON;
            } else {
                status = GameStatus.O_WON;
            }

            return;
        }

        if (board.isFull()) {
            status = GameStatus.DRAW;
            return;
        }

        switchPlayer();
    }

    private void switchPlayer() {

        if (currentPlayer == player1) {
            currentPlayer = player2;
        } else {
            currentPlayer = player1;
        }
    }

    public GameStatus getStatus() {
        return status;
    }

    public Player getCurrentPlayer() {
        return currentPlayer;
    }

    public Board getBoard() {
        return board;
    }

    public List<Move> getMoves() {
        return new ArrayList<>(moves);
    }
}
```

---

# 18. Winning Strategy Implementation

Now let's create the standard strategy.

```java
public class StandardWinningStrategy
        implements WinningStrategy {

    @Override
    public boolean checkWinner(
            Board board,
            Symbol symbol,
            int row,
            int col) {

        int size = board.getSize();

        // Check row

        boolean rowWin = true;

        for (int c = 0; c < size; c++) {

            if (board.getCell(row, c).getSymbol()
                    != symbol) {

                rowWin = false;
                break;
            }
        }

        if (rowWin) {
            return true;
        }

        // Check column

        boolean columnWin = true;

        for (int r = 0; r < size; r++) {

            if (board.getCell(r, col).getSymbol()
                    != symbol) {

                columnWin = false;
                break;
            }
        }

        if (columnWin) {
            return true;
        }

        // Check main diagonal

        if (row == col) {

            boolean diagonalWin = true;

            for (int i = 0; i < size; i++) {

                if (board.getCell(i, i).getSymbol()
                        != symbol) {

                    diagonalWin = false;
                    break;
                }
            }

            if (diagonalWin) {
                return true;
            }
        }

        // Check opposite diagonal

        if (row + col == size - 1) {

            boolean diagonalWin = true;

            for (int i = 0; i < size; i++) {

                if (board.getCell(
                        i,
                        size - 1 - i
                ).getSymbol() != symbol) {

                    diagonalWin = false;
                    break;
                }
            }

            if (diagonalWin) {
                return true;
            }
        }

        return false;
    }
}
```

---

# 19. Main Class

Now let's use our design.

```java
public class Main {

    public static void main(String[] args) {

        Player player1 =
                new Player(
                        1,
                        "Rahul",
                        Symbol.X
                );

        Player player2 =
                new Player(
                        2,
                        "Amit",
                        Symbol.O
                );

        Board board = new Board(3);

        WinningStrategy winningStrategy =
                new StandardWinningStrategy();

        Game game =
                new Game(
                        board,
                        player1,
                        player2,
                        winningStrategy
                );

        game.makeMove(0, 0); // X

        game.makeMove(1, 1); // O

        game.makeMove(0, 1); // X

        game.makeMove(2, 2); // O

        game.makeMove(0, 2); // X wins

        System.out.println(
                "Game Status: "
                        + game.getStatus()
        );
    }
}
```

The board becomes:

```text
+---+---+---+
| X | X | X |
+---+---+---+
|   | O |   |
+---+---+---+
|   |   | O |
+---+---+---+
```

Therefore:

```text
X WON
```

---

# 20. Complete Class Diagram

```text
                         +------------------+
                         |       Game       |
                         +------------------+
                         | - board         |
                         | - player1       |
                         | - player2       |
                         | - currentPlayer |
                         | - status        |
                         | - moves         |
                         | - winningStrategy|
                         +--------+---------+
                                  |
                 +----------------+----------------+
                 |                |                |
                 v                v                v
           +-----------+    +-----------+    +-----------+
           |   Board   |    |  Player   |    |   Move    |
           +-----------+    +-----------+    +-----------+
           | - size    |    | - id      |    | - player  |
           | - cells   |    | - name    |    | - row     |
           +-----+-----+    | - symbol  |    | - column  |
                 |           +-----------+    +-----------+
                 |
                 | HAS MANY
                 v
            +---------+
            |  Cell   |
            +---------+
            | - symbol|
            +---------+


                +---------------------------+
                |    WinningStrategy        |
                +---------------------------+
                | + checkWinner()           |
                +-------------+-------------+
                              |
                              | implements
                              v
                +---------------------------+
                | StandardWinningStrategy   |
                +---------------------------+
                | + checkWinner()           |
                +---------------------------+
```

---

# 21. Relationships

Let's understand each relationship.

### Game HAS-A Board

```text
Game
 |
 +-- Board
```

The game owns the board.

---

### Game HAS-A Players

```text
Game
 |
 +-- Player 1
 +-- Player 2
```

---

### Board HAS-MANY Cells

```text
Board
 |
 +-- Cell
 +-- Cell
 +-- Cell
 ...
```

---

### Move HAS-A Player

```text
Move
 |
 +-- Player
```

A move records which player made it.

---

### Game USES-A WinningStrategy

```text
Game
 |
 +-- WinningStrategy
```

---

### StandardWinningStrategy IS-A WinningStrategy

```text
StandardWinningStrategy
          |
          | implements
          v
WinningStrategy
```

---

# 22. Why Separate `Game` and `Board`?

This is a very important LLD concept.

The `Board` represents:

> **The current state of the playing area.**

The `Game` represents:

> **The game flow and rules around turns/status.**

For example:

```text
Board responsibilities:

+ place symbol
+ get cell
+ check full
```

While:

```text
Game responsibilities:

+ whose turn?
+ can player make a move?
+ is game over?
+ switch player
+ record moves
```

This separation gives us better **Single Responsibility**.

---

# 23. Why `Move` Instead of Just Updating the Board?

Without `Move`:

```text
Board
```

only tells us:

```text
Current state
```

With `Move`:

```text
moves = [
    X -> (0,0),
    O -> (1,1),
    X -> (0,1),
    O -> (2,2)
]
```

we also know:

```text
History of the game
```

This allows future features such as:

```text
Undo
Replay
Game history
Save/load game
```

---

# 24. Adding Undo

Because we already maintain:

```java
List<Move> moves;
```

we can potentially support undo.

For example:

```text
Current:

X O X
O X
```

Undo:

```text
X O
O X
```

A simple implementation could remove the last move and restore the cell.

However, for a production-quality implementation, we'd want to carefully handle:

- Game status
- Current player
- Winning state
- Move history

This is why keeping `Move` as an explicit object is useful.

---

# 25. Strategy Pattern

The key design pattern in this solution is:

```text
Strategy Pattern
```

We have:

```java
public interface WinningStrategy {

    boolean checkWinner(
            Board board,
            Symbol symbol,
            int row,
            int col
    );
}
```

The game doesn't care about the implementation.

It simply says:

```java
winningStrategy.checkWinner(...);
```

We could later add:

```text
StandardWinningStrategy
CustomWinningStrategy
KInARowWinningStrategy
```

without changing the core `Game` logic.

---

# 26. Can We Avoid Strategy Pattern?

Yes.

For a very simple Tic-Tac-Toe interview, this is perfectly acceptable:

```text
Game
 |
 +-- Board
      |
      +-- hasWon()
```

You don't have to use Strategy Pattern everywhere.

Use Strategy when:

> **A behavior/algorithm is likely to vary independently.**

That's the important concept.

---

# 27. Could We Use State Pattern?

Potentially.

The game has states:

```text
IN_PROGRESS
X_WON
O_WON
DRAW
```

But for such a small problem, an enum is sufficient.

Don't unnecessarily create:

```text
InProgressState
XWonState
OWonState
DrawState
```

That would be overengineering.

If the game had many state-specific behaviors, then the State Pattern could become useful.

---

# 28. Making the Board Generic

Our board already accepts:

```java
new Board(3);
```

So we can create:

```java
new Board(4);
```

or:

```java
new Board(5);
```

This gives us:

```text
3 × 3
4 × 4
5 × 5
...
```

But there's an important distinction.

A `4 × 4` board doesn't necessarily mean:

> Need 4 symbols in a row.

That is a **game rule**, and therefore it belongs naturally in the winning strategy.

---

# 29. N × N Tic-Tac-Toe

A better model is:

```text
Game
 |
 +-- Board(size)
 |
 +-- WinningStrategy
```

For example:

```text
Board = 5 × 5

Winning condition = 4 in a row
```

The board size and winning condition are separate concepts.

This is a good example of **separating data from behavior**.

---

# 30. Invalid Move Handling

Suppose the board is:

```text
+---+---+---+
| X | O |   |
+---+---+---+
|   | X |   |
+---+---+---+
|   |   | O |
+---+---+---+
```

Player X tries:

```java
game.makeMove(0, 0);
```

But `(0,0)` already contains X.

Our `Cell.mark()` throws:

```text
Cell is already occupied
```

This is good because the invalid-state rule is enforced by the `Cell`.

---

# 31. Invalid Position

Suppose:

```java
game.makeMove(10, 10);
```

for a 3×3 board.

The board validates:

```java
if (row < 0 || row >= size
        || col < 0 || col >= size)
```

and throws:

```text
Invalid board position
```

Again:

> The class that owns the data should ideally protect its invariants.

---

# 32. Game Already Over

Suppose X has already won:

```text
X X X
O O
```

and somebody tries another move.

`Game` checks:

```java
if (status != GameStatus.IN_PROGRESS)
```

and rejects it.

This rule belongs to `Game`, because `Game` controls the game lifecycle.

---

# 33. SOLID Principles

## Single Responsibility Principle

We have:

```text
Player
→ Player information

Cell
→ Cell state

Board
→ Board state

Move
→ Move information

Game
→ Game flow

WinningStrategy
→ Winning logic
```

Each class has a clear responsibility.

---

## Open/Closed Principle

We can add:

```text
CustomWinningStrategy
```

without modifying:

```text
Game
```

---

## Dependency Inversion Principle

`Game` depends on:

```java
WinningStrategy
```

rather than:

```java
StandardWinningStrategy
```

This is good:

```java
private WinningStrategy winningStrategy;
```

---

# 34. Could We Use Factory Pattern?

Not necessary.

Creating a player is simple:

```java
new Player(...)
```

There is no complicated creation logic.

So a Factory would add unnecessary complexity.

---

# 35. Could We Use Observer Pattern?

Potentially, if we have requirements such as:

```text
When a move happens:

       Game
        |
        +---- Board UI
        |
        +---- Scoreboard
        |
        +---- Game Logger
        |
        +---- Network Client
```

Then Observer Pattern might make sense.

But for basic Tic-Tac-Toe:

> Don't use it.

---

# 36. Could We Use Command Pattern?

If we need:

```text
Undo
Redo
Replay
```

then `Move` could evolve into a command-like object.

But again, don't introduce it unless the requirement calls for it.

---

# 37. Interview-Level Design

If asked in an interview:

> "Design Tic-Tac-Toe."

Start by saying:

> "I'll assume two players, an N×N board, alternating turns, and a player wins when their symbols satisfy the configured winning condition. I'll keep the board and game flow separate. Since the winning algorithm may change, I'll isolate it behind a WinningStrategy interface."

Then identify:

```text
Player
Board
Cell
Move
Game
WinningStrategy
```

Then explain relationships.

---

# 38. Interview Questions You Should Expect

### Q1. Why separate Board and Game?

Answer:

> Board manages board state, while Game manages turns and game lifecycle.

---

### Q2. Why do we need Move?

Answer:

> Move represents a player's action and allows us to maintain history, which can support undo/replay later.

---

### Q3. Why Strategy Pattern?

Answer:

> The winning algorithm can vary independently from the game flow, so Strategy allows us to change the algorithm without modifying Game.

---

### Q4. What if board size changes?

Answer:

> Board accepts its size through the constructor, so the same Board abstraction can support N×N boards.

---

### Q5. What if winning rules change?

Answer:

> Implement another WinningStrategy rather than changing Game.

---

### Q6. What if we need an AI player?

We could introduce:

```java
public interface PlayerStrategy {

    Move getNextMove(
            Board board,
            Player player
    );
}
```

Then:

```text
PlayerStrategy
      |
      +---- HumanPlayerStrategy
      |
      +---- RandomAIPlayerStrategy
      |
      +---- SmartAIPlayerStrategy
```

Again, Strategy Pattern.

---

# 39. Adding AI Later

The architecture can evolve into:

```text
                 Game
                  |
          +-------+-------+
          |               |
       Player          Player
          |               |
          v               v
    Human Strategy    AI Strategy
```

The `Game` doesn't need to know whether a player is:

```text
Human
```

or:

```text
AI
```

It only needs to ask for the next move.

This is another example of programming against an abstraction.

---

# 40. Complexity

For a board of size `N × N`:

### Move

Placing a symbol:

```text
O(1)
```

### Checking whether the board is full

```text
O(N²)
```

### Winner check

The straightforward implementation checks:

```text
row
column
diagonal
```

which is:

```text
O(N)
```

because only the affected row, column, and potentially diagonals need to be checked after a move.

---

# 41. Possible Optimization

For a large board, repeatedly scanning rows and columns isn't always necessary.

We can maintain counters:

```text
rowCount[]
columnCount[]
diagonalCount
antiDiagonalCount
```

For example:

```text
rowCount[0] = 3
```

could mean:

```text
X X X
```

Then checking a winner becomes approximately:

```text
O(1)
```

per move.

However, for normal Tic-Tac-Toe:

> This optimization is unnecessary.

The simple solution is easier to understand and maintain.

---

# 42. Package Structure

A clean Java project:

```text
src/
│
├── model/
│   ├── Player.java
│   ├── Cell.java
│   ├── Board.java
│   └── Move.java
│
├── enums/
│   ├── Symbol.java
│   └── GameStatus.java
│
├── strategy/
│   ├── WinningStrategy.java
│   └── StandardWinningStrategy.java
│
├── Game.java
│
└── Main.java
```

---

# 43. Simplified Version to Remember

For interviews, remember this mental model:

```text
                 +----------------+
                 |      Game      |
                 +----------------+
                 | Board          |
                 | Players        |
                 | Current Player |
                 | Game Status    |
                 | Moves          |
                 +-------+--------+
                         |
                         v
                    +---------+
                    |  Board  |
                    +----+----+
                         |
                         v
                    +---------+
                    |  Cell   |
                    +---------+

Game
 |
 +---- Player
 |
 +---- Player
 |
 +---- Move
 |
 +---- WinningStrategy
             |
             +---- StandardWinningStrategy
```

---

# 44. Final Mental Model for LLD

When you see a problem like Tic-Tac-Toe, don't start with code.

Think:

```text
Requirement
     |
     v
What are the entities?
     |
     v
Player
Board
Cell
Move
Game
     |
     v
What does each entity own?
     |
     v
Who should perform each operation?
     |
     v
Which behavior can change?
     |
     v
WinningStrategy
     |
     v
Define relationships
     |
     v
Handle invalid states
     |
     v
Write Java code
```

---

# 45. Final Summary

The core design is:

```text
Player
→ Represents a player and their symbol.

Cell
→ Represents one position on the board.

Board
→ Maintains cells and board state.

Move
→ Represents a player's move.

Game
→ Controls turns, moves, game status and lifecycle.

WinningStrategy
→ Determines whether the latest move results in a win.
```

The most important LLD lessons from Tic-Tac-Toe are:

1. **Separate game state from game flow.**
2. **Give each class a clear responsibility.**
3. **Represent actions such as moves explicitly when history may matter.**
4. **Use Strategy Pattern when an algorithm can vary.**
5. **Don't overuse design patterns.**
6. **Protect object invariants such as "a cell cannot be occupied twice."**
7. **Design for extensibility only where it is actually useful.**