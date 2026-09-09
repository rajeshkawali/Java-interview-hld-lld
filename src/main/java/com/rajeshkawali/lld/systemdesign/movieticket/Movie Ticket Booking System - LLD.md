# Movie Ticket Booking System — LLD

## 1. Problem Statement

Design a movie ticket booking system similar to **BookMyShow**.

The system should allow users to:

- Search for movies
- Find cinemas/theatres
- View movie shows
- View available seats
- Select seats
- Temporarily lock seats
- Make payment
- Confirm booking
- Cancel booking

The most important part of this LLD is handling **multiple users trying to book the same seat at the same time**.

---

# 2. Requirements

## Functional Requirements

### User

A user should be able to:

1. Search for a movie.
2. Select a movie.
3. Select a city/theatre.
4. View available shows.
5. View available seats.
6. Select one or more seats.
7. Lock the selected seats temporarily.
8. Make payment.
9. Confirm booking.
10. Cancel a booking.

### Theatre

A theatre should contain:

- Multiple screens.
- Each screen contains multiple seats.
- Each screen can have multiple movie shows.

### Show

A show represents:

```text
Movie + Screen + Start Time + End Time
```

Example:

```text
Movie: Avengers
Screen: Screen 2
Start Time: 7:00 PM
End Time: 10:00 PM
```

### Booking

A booking contains:

- User
- Show
- Selected seats
- Amount
- Booking status
- Payment information

---

# 3. Important Non-Functional Requirement

The most important technical requirement is:

> Two users should not be able to successfully book the same seat for the same show.

For example:

```text
User A → selects Seat A1
User B → selects Seat A1

Only one user should finally get A1.
```

This introduces **concurrency control**.

---

# 4. High-Level Flow

```text
User
  |
  v
Search Movie
  |
  v
Select Movie
  |
  v
Select Theatre
  |
  v
Select Show
  |
  v
View Seats
  |
  v
Select Seats
  |
  v
Lock Seats
  |
  v
Make Payment
  |
  +---- Payment Failed ----> Release Seats
  |
  v
Payment Successful
  |
  v
Confirm Booking
  |
  v
Generate Ticket
```

---

# 5. Identify the Main Entities

Let's convert requirements into objects.

Main entities:

```text
User
Movie
Theatre
Screen
Seat
Show
Booking
Payment
Ticket
```

We also need services:

```text
MovieBookingSystem
BookingService
PaymentService
SeatLockService
```

And enums:

```text
SeatType
SeatStatus
BookingStatus
PaymentStatus
```

---

# 6. Relationship Between Entities

The important relationships are:

```text
MovieBookingSystem
        |
        +---- Movies
        |
        +---- Theatres
                 |
                 +---- Screens
                         |
                         +---- Seats
                         |
                         +---- Shows
                                  |
                                  +---- Movie
```

For a particular show:

```text
Show
 |
 +---- Movie
 |
 +---- Screen
 |
 +---- Seat Availability
```

A booking:

```text
Booking
 |
 +---- User
 |
 +---- Show
 |
 +---- Seats
 |
 +---- Payment
```

---

# 7. Important Design Decision

One common beginner mistake is to put seat availability directly inside `Seat`.

For example:

```java
class Seat {
    boolean booked;
}
```

This is incorrect.

Why?

Because the same physical seat can be available for one show and booked for another.

Example:

```text
Screen 1
    |
    +---- Seat A1
```

Suppose:

```text
Show 1 → A1 booked
Show 2 → A1 available
Show 3 → A1 booked
```

Therefore:

> Seat is a physical entity, but seat availability belongs to a particular `Show`.

This is an important interview point.

---

# 8. Enums

## SeatType

```java
public enum SeatType {
    REGULAR,
    PREMIUM,
    RECLINER
}
```

---

## SeatStatus

```java
public enum SeatStatus {
    AVAILABLE,
    LOCKED,
    BOOKED
}
```

---

## BookingStatus

```java
public enum BookingStatus {
    CREATED,
    PENDING_PAYMENT,
    CONFIRMED,
    CANCELLED,
    EXPIRED
}
```

---

## PaymentStatus

```java
public enum PaymentStatus {
    INITIATED,
    SUCCESS,
    FAILED
}
```

---

# 9. Movie

The `Movie` class represents movie information.

```java
public class Movie {

    private final String movieId;
    private final String title;
    private final int durationInMinutes;
    private final String language;

    public Movie(
            String movieId,
            String title,
            int durationInMinutes,
            String language) {

        this.movieId = movieId;
        this.title = title;
        this.durationInMinutes = durationInMinutes;
        this.language = language;
    }

    public String getMovieId() {
        return movieId;
    }

    public String getTitle() {
        return title;
    }

    public int getDurationInMinutes() {
        return durationInMinutes;
    }

    public String getLanguage() {
        return language;
    }
}
```

---

# 10. User

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

# 11. Seat

A seat represents a physical seat inside a screen.

```java
public class Seat {

    private final String seatId;
    private final String seatNumber;
    private final SeatType seatType;
    private final double price;

    public Seat(
            String seatId,
            String seatNumber,
            SeatType seatType,
            double price) {

        this.seatId = seatId;
        this.seatNumber = seatNumber;
        this.seatType = seatType;
        this.price = price;
    }

    public String getSeatId() {
        return seatId;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public SeatType getSeatType() {
        return seatType;
    }

    public double getPrice() {
        return price;
    }
}
```

Notice:

```java
Seat
```

does **not** contain:

```java
boolean booked;
```

because booking status depends on the show.

---

# 12. Screen

A theatre can have multiple screens.

```java
import java.util.*;

public class Screen {

    private final String screenId;
    private final String name;
    private final List<Seat> seats;

    public Screen(
            String screenId,
            String name,
            List<Seat> seats) {

        this.screenId = screenId;
        this.name = name;
        this.seats = seats;
    }

    public String getScreenId() {
        return screenId;
    }

    public String getName() {
        return name;
    }

    public List<Seat> getSeats() {
        return Collections.unmodifiableList(seats);
    }
}
```

Relationship:

```text
Screen HAS-A Seats
```

---

# 13. Theatre

```java
import java.util.*;

public class Theatre {

    private final String theatreId;
    private final String name;
    private final String city;
    private final List<Screen> screens;

    public Theatre(
            String theatreId,
            String name,
            String city,
            List<Screen> screens) {

        this.theatreId = theatreId;
        this.name = name;
        this.city = city;
        this.screens = screens;
    }

    public String getTheatreId() {
        return theatreId;
    }

    public String getName() {
        return name;
    }

    public String getCity() {
        return city;
    }

    public List<Screen> getScreens() {
        return Collections.unmodifiableList(screens);
    }
}
```

Relationship:

```text
Theatre
   |
   +---- Screen
            |
            +---- Seat
```

---

# 14. Show

A show connects:

```text
Movie + Screen + Time
```

```java
import java.time.LocalDateTime;

public class Show {

    private final String showId;
    private final Movie movie;
    private final Screen screen;
    private final LocalDateTime startTime;
    private final LocalDateTime endTime;

    public Show(
            String showId,
            Movie movie,
            Screen screen,
            LocalDateTime startTime,
            LocalDateTime endTime) {

        this.showId = showId;
        this.movie = movie;
        this.screen = screen;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public String getShowId() {
        return showId;
    }

    public Movie getMovie() {
        return movie;
    }

    public Screen getScreen() {
        return screen;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }
}
```

---

# 15. Seat Availability

Now comes the important part.

We need to track:

```text
Show + Seat → Status
```

For example:

```text
Show 101 + A1 → BOOKED
Show 101 + A2 → AVAILABLE

Show 102 + A1 → AVAILABLE
Show 102 + A2 → BOOKED
```

We can model this using:

```java
Map<String, SeatStatus>
```

inside a show-level seat inventory.

---

# 16. ShowSeat

Instead of mixing physical seat information and show-specific status, we can introduce `ShowSeat`.

```java
public class ShowSeat {

    private final Seat seat;
    private SeatStatus status;

    public ShowSeat(Seat seat) {
        this.seat = seat;
        this.status = SeatStatus.AVAILABLE;
    }

    public Seat getSeat() {
        return seat;
    }

    public SeatStatus getStatus() {
        return status;
    }

    public void lock() {
        if (status != SeatStatus.AVAILABLE) {
            throw new IllegalStateException(
                    "Seat is not available"
            );
        }

        status = SeatStatus.LOCKED;
    }

    public void book() {
        if (status != SeatStatus.LOCKED) {
            throw new IllegalStateException(
                    "Seat must be locked before booking"
            );
        }

        status = SeatStatus.BOOKED;
    }

    public void release() {
        if (status == SeatStatus.BOOKED) {
            throw new IllegalStateException(
                    "Booked seat cannot be released"
            );
        }

        status = SeatStatus.AVAILABLE;
    }
}
```

This gives us:

```text
Seat
  ↓
Physical seat

ShowSeat
  ↓
Seat's status for a particular show
```

This is a very good design distinction to explain in an interview.

---

# 17. Seat Locking

Why do we need locking?

Imagine:

```text
10:00:00

User A selects A1

10:00:01

User B selects A1
```

If we don't lock A1:

```text
User A → Payment
User B → Payment

Both think A1 is available.
```

We need:

```text
AVAILABLE
    |
    | select
    v
LOCKED
    |
    | payment success
    v
BOOKED
```

If payment fails:

```text
LOCKED
   |
   | payment failed / timeout
   v
AVAILABLE
```

---

# 18. Seat Lock Service

```java
import java.time.LocalDateTime;
import java.util.*;

public class SeatLockService {

    private static final int LOCK_DURATION_SECONDS = 300;

    private final Map<String, LocalDateTime> lockExpiry =
            new HashMap<>();

    public boolean lock(
            String showSeatId,
            LocalDateTime currentTime) {

        removeExpiredLocks(currentTime);

        if (lockExpiry.containsKey(showSeatId)) {
            return false;
        }

        lockExpiry.put(
                showSeatId,
                currentTime.plusSeconds(LOCK_DURATION_SECONDS)
        );

        return true;
    }

    public void release(
            String showSeatId) {

        lockExpiry.remove(showSeatId);
    }

    public boolean isLocked(
            String showSeatId,
            LocalDateTime currentTime) {

        removeExpiredLocks(currentTime);

        return lockExpiry.containsKey(showSeatId);
    }

    private void removeExpiredLocks(
            LocalDateTime currentTime) {

        lockExpiry.entrySet().removeIf(
                entry -> entry.getValue().isBefore(currentTime)
        );
    }
}
```

This is an educational implementation.

In a real distributed system, seat locks should generally be stored in a shared durable/appropriate coordination layer rather than a single JVM's `HashMap`.

---

# 19. Payment

Create a payment abstraction.

```java
public interface PaymentService {

    PaymentStatus pay(
            String paymentId,
            double amount
    );
}
```

Why interface?

Because tomorrow we may support:

```text
Credit Card
Debit Card
UPI
Wallet
Net Banking
```

We don't want:

```java
if (paymentType == UPI) {
   ...
} else if (paymentType == CARD) {
   ...
}
```

everywhere.

---

# 20. Payment Implementations

## UPI

```java
public class UPIPaymentService
        implements PaymentService {

    @Override
    public PaymentStatus pay(
            String paymentId,
            double amount) {

        System.out.println(
                "Processing UPI payment: " + amount
        );

        return PaymentStatus.SUCCESS;
    }
}
```

## Card

```java
public class CardPaymentService
        implements PaymentService {

    @Override
    public PaymentStatus pay(
            String paymentId,
            double amount) {

        System.out.println(
                "Processing card payment: " + amount
        );

        return PaymentStatus.SUCCESS;
    }
}
```

This is a simple example of the **Strategy Pattern**.

---

# 21. Payment Entity

```java
public class Payment {

    private final String paymentId;
    private final double amount;
    private PaymentStatus status;

    public Payment(
            String paymentId,
            double amount) {

        this.paymentId = paymentId;
        this.amount = amount;
        this.status = PaymentStatus.INITIATED;
    }

    public void markSuccess() {
        status = PaymentStatus.SUCCESS;
    }

    public void markFailed() {
        status = PaymentStatus.FAILED;
    }

    public PaymentStatus getStatus() {
        return status;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public double getAmount() {
        return amount;
    }
}
```

---

# 22. Booking

The booking represents the customer's reservation.

```java
import java.util.*;

public class Booking {

    private final String bookingId;
    private final User user;
    private final Show show;
    private final List<Seat> seats;
    private final double amount;

    private BookingStatus status;

    public Booking(
            String bookingId,
            User user,
            Show show,
            List<Seat> seats,
            double amount) {

        this.bookingId = bookingId;
        this.user = user;
        this.show = show;
        this.seats = new ArrayList<>(seats);
        this.amount = amount;
        this.status = BookingStatus.CREATED;
    }

    public void markPendingPayment() {
        status = BookingStatus.PENDING_PAYMENT;
    }

    public void confirm() {
        status = BookingStatus.CONFIRMED;
    }

    public void cancel() {
        status = BookingStatus.CANCELLED;
    }

    public String getBookingId() {
        return bookingId;
    }

    public User getUser() {
        return user;
    }

    public Show getShow() {
        return show;
    }

    public List<Seat> getSeats() {
        return Collections.unmodifiableList(seats);
    }

    public double getAmount() {
        return amount;
    }

    public BookingStatus getStatus() {
        return status;
    }
}
```

---

# 23. Booking Service

The booking service coordinates the booking workflow.

```java
import java.time.LocalDateTime;
import java.util.*;

public class BookingService {

    private final SeatLockService seatLockService;
    private final PaymentService paymentService;

    public BookingService(
            SeatLockService seatLockService,
            PaymentService paymentService) {

        this.seatLockService = seatLockService;
        this.paymentService = paymentService;
    }

    public Booking createBooking(
            User user,
            Show show,
            List<ShowSeat> selectedSeats) {

        // 1. Validate seats
        for (ShowSeat showSeat : selectedSeats) {

            if (showSeat.getStatus() != SeatStatus.AVAILABLE) {
                throw new IllegalStateException(
                        "Seat is not available"
                );
            }
        }

        // 2. Lock seats
        List<String> lockedSeats = new ArrayList<>();

        try {

            for (ShowSeat showSeat : selectedSeats) {

                String showSeatId =
                        show.getShowId()
                        + "-"
                        + showSeat.getSeat().getSeatId();

                boolean locked =
                        seatLockService.lock(
                                showSeatId,
                                LocalDateTime.now()
                        );

                if (!locked) {
                    throw new IllegalStateException(
                            "Could not lock seat"
                    );
                }

                showSeat.lock();
                lockedSeats.add(showSeatId);
            }

            // 3. Calculate amount
            double amount = calculateAmount(selectedSeats);

            // 4. Create booking
            Booking booking = new Booking(
                    UUID.randomUUID().toString(),
                    user,
                    show,
                    getSeats(selectedSeats),
                    amount
            );

            booking.markPendingPayment();

            // 5. Payment
            PaymentStatus paymentStatus =
                    paymentService.pay(
                            UUID.randomUUID().toString(),
                            amount
                    );

            if (paymentStatus != PaymentStatus.SUCCESS) {
                releaseSeats(selectedSeats, lockedSeats);
                booking.cancel();
                return booking;
            }

            // 6. Confirm seats
            for (ShowSeat showSeat : selectedSeats) {
                showSeat.book();
            }

            // 7. Confirm booking
            booking.confirm();

            return booking;

        } catch (Exception e) {

            for (String seatId : lockedSeats) {
                seatLockService.release(seatId);
            }

            throw e;
        }
    }

    private double calculateAmount(
            List<ShowSeat> seats) {

        return seats.stream()
                .mapToDouble(
                        seat -> seat.getSeat().getPrice()
                )
                .sum();
    }

    private List<Seat> getSeats(
            List<ShowSeat> showSeats) {

        List<Seat> seats = new ArrayList<>();

        for (ShowSeat showSeat : showSeats) {
            seats.add(showSeat.getSeat());
        }

        return seats;
    }

    private void releaseSeats(
            List<ShowSeat> selectedSeats,
            List<String> lockedSeats) {

        for (int i = 0;
             i < selectedSeats.size();
             i++) {

            selectedSeats.get(i).release();
            seatLockService.release(lockedSeats.get(i));
        }
    }
}
```

---

# 24. Important Interview Discussion

The above code demonstrates the design, but there is an important production problem.

Consider:

```text
1. Seat locked
2. Payment successful
3. Application crashes
4. Seat never becomes BOOKED
```

Or:

```text
1. Seat locked
2. Seat marked BOOKED
3. Payment fails
```

Therefore, in a real system:

> Seat reservation and payment require carefully designed transaction boundaries, idempotency, retries, and reconciliation.

Do not claim that the above in-memory Java implementation gives production-grade atomicity.

---

# 25. Movie Booking System

We can create a facade/coordinator for the entire system.

```java
import java.util.*;

public class MovieBookingSystem {

    private final List<Movie> movies;
    private final List<Theatre> theatres;
    private final BookingService bookingService;

    public MovieBookingSystem(
            List<Movie> movies,
            List<Theatre> theatres,
            BookingService bookingService) {

        this.movies = movies;
        this.theatres = theatres;
        this.bookingService = bookingService;
    }

    public List<Movie> searchMovie(
            String title) {

        List<Movie> result = new ArrayList<>();

        for (Movie movie : movies) {

            if (movie.getTitle()
                    .toLowerCase()
                    .contains(title.toLowerCase())) {

                result.add(movie);
            }
        }

        return result;
    }

    public List<Theatre> getTheatres() {
        return Collections.unmodifiableList(theatres);
    }

    public Booking bookTickets(
            User user,
            Show show,
            List<ShowSeat> seats) {

        return bookingService.createBooking(
                user,
                show,
                seats
        );
    }
}
```

---

# 26. Example Main

```java
import java.time.LocalDateTime;
import java.util.*;

public class Main {

    public static void main(String[] args) {

        // -------------------------
        // Create Movie
        // -------------------------

        Movie movie = new Movie(
                "M1",
                "Avengers",
                180,
                "English"
        );

        // -------------------------
        // Create Seats
        // -------------------------

        Seat seatA1 = new Seat(
                "S1",
                "A1",
                SeatType.PREMIUM,
                300
        );

        Seat seatA2 = new Seat(
                "S2",
                "A2",
                SeatType.PREMIUM,
                300
        );

        // -------------------------
        // Create Screen
        // -------------------------

        Screen screen = new Screen(
                "SC1",
                "Screen 1",
                Arrays.asList(
                        seatA1,
                        seatA2
                )
        );

        // -------------------------
        // Create Theatre
        // -------------------------

        Theatre theatre = new Theatre(
                "T1",
                "PVR",
                "Mumbai",
                Arrays.asList(screen)
        );

        // -------------------------
        // Create Show
        // -------------------------

        Show show = new Show(
                "SH1",
                movie,
                screen,
                LocalDateTime.now(),
                LocalDateTime.now().plusHours(3)
        );

        // -------------------------
        // Show-specific seats
        // -------------------------

        ShowSeat showSeatA1 =
                new ShowSeat(seatA1);

        ShowSeat showSeatA2 =
                new ShowSeat(seatA2);

        // -------------------------
        // User
        // -------------------------

        User user = new User(
                "U1",
                "Rahul",
                "rahul@example.com"
        );

        // -------------------------
        // Services
        // -------------------------

        SeatLockService seatLockService =
                new SeatLockService();

        PaymentService paymentService =
                new UPIPaymentService();

        BookingService bookingService =
                new BookingService(
                        seatLockService,
                        paymentService
                );

        // -------------------------
        // Booking
        // -------------------------

        Booking booking =
                bookingService.createBooking(
                        user,
                        show,
                        Arrays.asList(
                                showSeatA1,
                                showSeatA2
                        )
                );

        System.out.println(
                "Booking Status: "
                + booking.getStatus()
        );

        System.out.println(
                "Booking ID: "
                + booking.getBookingId()
        );
    }
}
```

Expected output:

```text
Processing UPI payment: 600.0

Booking Status: CONFIRMED

Booking ID: <generated-id>
```

---

# 27. Class Diagram

```text
                    +----------------------+
                    | MovieBookingSystem   |
                    +----------+-----------+
                               |
              +----------------+----------------+
              |                                 |
              v                                 v
        +-----------+                      +-----------+
        |   Movie   |                      | Theatre   |
        +-----------+                      +-----+-----+
                                               |
                                               |
                                               v
                                         +-----------+
                                         |  Screen   |
                                         +-----+-----+
                                               |
                                               v
                                         +-----------+
                                         |   Seat    |
                                         +-----+-----+
                                               |
                                               |
                                               v
                                         +-----------+
                                         | ShowSeat  |
                                         +-----------+
                                         | status    |
                                         +-----+-----+
                                               |
                                               |
                                               v
                                         +-----------+
                                         |   Show    |
                                         +-----+-----+
                                         | Movie     |
                                         | Screen    |
                                         | Time      |
                                         +-----+-----+
                                               |
                                               |
                                               v
                                         +-----------+
                                         |  Booking  |
                                         +-----+-----+
                                         | User      |
                                         | Seats     |
                                         | Amount    |
                                         | Status    |
                                         +-----+-----+
                                               |
                                               v
                                         +-----------+
                                         |  Payment  |
                                         +-----------+
```

---

# 28. Important Relationships

## Theatre HAS-A Screen

```text
Theatre
   |
   +---- Screen
```

One theatre can contain multiple screens.

---

## Screen HAS-A Seat

```text
Screen
   |
   +---- Seat
```

A screen has physical seats.

---

## Show HAS-A Movie

```text
Show
   |
   +---- Movie
```

A show represents one movie at a particular time.

---

## Show HAS-A Screen

```text
Show
   |
   +---- Screen
```

The show happens on a particular screen.

---

## ShowSeat HAS-A Seat

```text
ShowSeat
   |
   +---- Seat
```

`ShowSeat` adds show-specific availability to the physical seat.

---

## Booking HAS-A Show

```text
Booking
   |
   +---- Show
```

---

## Booking HAS-A User

```text
Booking
   |
   +---- User
```

---

# 29. Design Patterns

There are a few patterns that make sense here.

Don't use patterns just because an interviewer asks for them.

---

## 29.1 Strategy Pattern — Payment

We have:

```java
public interface PaymentService {
    PaymentStatus pay(String paymentId, double amount);
}
```

Implementations:

```text
PaymentService
      |
      +---- UPIPaymentService
      |
      +---- CardPaymentService
      |
      +---- WalletPaymentService
```

Why?

Because payment behavior can change.

---

## 29.2 Strategy Pattern — Pricing

Suppose pricing changes:

```text
Regular seat → ₹200
Premium seat → ₹300
Weekend      → +₹100
Holiday      → +₹200
Morning show → discount
```

Instead of putting everything into `BookingService`, create:

```java
public interface PricingStrategy {

    double calculatePrice(
            Show show,
            List<ShowSeat> seats
    );
}
```

Example:

```java
public class NormalPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(
            Show show,
            List<ShowSeat> seats) {

        return seats.stream()
                .mapToDouble(
                        s -> s.getSeat().getPrice()
                )
                .sum();
    }
}
```

Later:

```text
PricingStrategy
       |
       +---- NormalPricingStrategy
       |
       +---- WeekendPricingStrategy
       |
       +---- FestivalPricingStrategy
```

This is a strong interview extension.

---

# 30. State Pattern — Booking

Booking has states:

```text
CREATED
   |
   v
PENDING_PAYMENT
   |
   +------> CONFIRMED
   |
   +------> CANCELLED
   |
   +------> EXPIRED
```

Initially, an enum is enough:

```java
BookingStatus status;
```

If each state starts having complex behavior, we can introduce the **State Pattern**.

For example:

```text
BookingState
      |
      +---- CreatedState
      +---- PendingPaymentState
      +---- ConfirmedState
      +---- CancelledState
      +---- ExpiredState
```

Interview rule:

> Start with enum. Introduce State Pattern only when state-specific behavior becomes complex.

---

# 31. Factory Pattern

Suppose we support many payment types.

Instead of:

```java
if (type == UPI) {
    ...
}

if (type == CARD) {
    ...
}

if (type == WALLET) {
    ...
}
```

we could have:

```java
public class PaymentServiceFactory {

    public static PaymentService getService(
            String type) {

        if (type.equalsIgnoreCase("UPI")) {
            return new UPIPaymentService();
        }

        if (type.equalsIgnoreCase("CARD")) {
            return new CardPaymentService();
        }

        throw new IllegalArgumentException(
                "Unsupported payment type"
        );
    }
}
```

This can be useful when object creation becomes more complicated.

---

# 32. Most Important Part — Concurrency

This is probably the most important follow-up question.

### Interviewer:

> What happens if two users try to book the same seat simultaneously?

Suppose:

```text
User A                  User B

   |                       |
   | Select A1             |
   |                       |
   |                 Select A1
   |                       |
   v                       v
 Check A1 available
```

If both perform:

```java
if (seat.isAvailable()) {
    seat.book();
}
```

they could both see:

```text
AVAILABLE
```

This is a race condition.

---

# 33. Correct Mental Model

The operation must effectively be:

```text
Check availability
       +
Acquire lock
       +
Change state
```

as one protected operation.

Conceptually:

```text
AVAILABLE
    |
    | atomic operation
    v
LOCKED
```

Only one request should succeed.

---

# 34. Database Approach

In a real application, seat inventory would likely be persisted.

For example:

```text
show_seat

show_id
seat_id
status
locked_by
lock_expiry
```

Then we can use transactional database operations.

Conceptually:

```sql
UPDATE show_seat
SET status = 'LOCKED',
    locked_by = ?,
    lock_expiry = ?
WHERE show_id = ?
  AND seat_id = ?
  AND status = 'AVAILABLE';
```

Then check:

```text
rows updated == 1
```

If:

```text
rows updated = 1
```

we successfully locked the seat.

If:

```text
rows updated = 0
```

someone else already took it.

The exact implementation depends on the database and architecture.

---

# 35. Distributed Locking

If we have multiple application servers:

```text
             Load Balancer
                  |
        +---------+---------+
        |         |         |
        v         v         v
     Server A  Server B  Server C
```

A local:

```java
HashMap
```

is not enough.

We need coordination shared across instances, commonly using mechanisms such as:

```text
Database transaction / row locking
Redis-based locking
Distributed coordination system
```

But the database inventory transaction is often the simpler source of truth for seat ownership.

---

# 36. Seat Lock Expiration

Suppose:

```text
User selects A1
```

We lock:

```text
A1 → LOCKED
```

But the user closes the application.

A1 cannot remain locked forever.

Therefore:

```text
LOCKED
   |
   | 5 minutes
   v
AVAILABLE
```

Example:

```java
lockExpiry = currentTime + 5 minutes;
```

A background job or request-time cleanup can release expired locks.

---

# 37. Payment Failure

Suppose:

```text
Seat A1 → LOCKED

Payment → FAILED
```

Then:

```text
A1 → AVAILABLE
```

Flow:

```text
Lock seats
    |
    v
Create booking
    |
    v
Payment
    |
    +---- FAILED
    |       |
    |       v
    |   Release seats
    |
    +---- SUCCESS
            |
            v
        Confirm booking
```

---

# 38. Payment Timeout

What if:

```text
Payment request sent
        |
        v
No response
```

We cannot blindly assume:

```text
FAILED
```

because the payment provider might have processed it but the response was lost.

This is why real systems need:

- Payment transaction ID
- Idempotency key
- Payment status query
- Retry handling
- Reconciliation

---

# 39. Idempotency

Suppose payment request:

```text
paymentId = P123
```

gets sent.

The client retries because it didn't receive a response.

Without idempotency:

```text
Request 1 → ₹600 deducted
Request 2 → ₹600 deducted again
```

With idempotency:

```text
P123 → already processed

Return existing result.
```

Therefore:

> Payment and booking operations should have unique transaction IDs and idempotent processing.

---

# 40. Cancellation

Suppose:

```text
Booking B123
Status = CONFIRMED
```

User cancels.

We need business rules:

```text
More than 2 hours before show
→ cancellation allowed

Less than 2 hours
→ cancellation not allowed
```

This rule should not be hardcoded inside `Booking`.

We could create:

```java
public interface CancellationPolicy {

    boolean canCancel(Booking booking);
}
```

Then:

```text
CancellationPolicy
       |
       +---- StandardCancellationPolicy
       |
       +---- PremiumCancellationPolicy
```

Another Strategy Pattern.

---

# 41. Search

The system should support:

```text
Search by movie
Search by city
Search by theatre
Search by language
Search by date
```

For example:

```java
public List<Movie> searchMovie(String title)
```

For a real production system, searching millions of movies/shows should not be implemented by iterating over an in-memory list.

We would typically use:

```text
Database indexes
Search engine
Caching
```

depending on scale.

---

# 42. SOLID Principles

## SRP — Single Responsibility

Each class has a focused responsibility.

```text
Movie              → Movie information
Seat               → Physical seat
ShowSeat           → Seat availability for a show
Show               → Movie + screen + timing
Booking            → Reservation
PaymentService     → Payment
SeatLockService    → Seat locking
BookingService     → Booking workflow
```

---

## OCP — Open/Closed Principle

Payment:

```text
PaymentService
     |
     +---- UPI
     +---- Card
     +---- Wallet
```

Adding a new payment method shouldn't require rewriting booking logic.

---

## LSP — Liskov Substitution

Any implementation of:

```java
PaymentService
```

should be usable where:

```java
PaymentService
```

is expected.

---

## ISP — Interface Segregation

Don't create one giant interface:

```java
interface MovieSystem {
    search();
    book();
    pay();
    cancel();
    refund();
    sendEmail();
    ...
}
```

Prefer smaller interfaces when appropriate.

---

## DIP — Dependency Inversion

Instead of:

```java
BookingService {

    UPIPaymentService payment =
        new UPIPaymentService();

}
```

use:

```java
BookingService {

    PaymentService paymentService;

}
```

and inject the dependency:

```java
new BookingService(
    seatLockService,
    paymentService
);
```

This makes testing and changing implementations easier.

---

# 43. Edge Cases

An interviewer may ask:

### What if seat is already booked?

```text
Reject booking.
```

### What if seat lock expires?

```text
Release seat.
```

### What if payment fails?

```text
Release locked seats.
```

### What if payment succeeds but booking confirmation fails?

```text
Use transaction state + idempotency + reconciliation.
```

### What if two users select the same seat?

```text
Atomic seat locking.
```

### What if application server crashes?

```text
Persist booking/payment/seat state.
Do not rely only on in-memory state.
```

### What if payment provider is unavailable?

```text
Retry / mark pending / reconcile.
```

### What if user cancels?

```text
Check cancellation policy.
Process refund if applicable.
Release seat according to booking state.
```

---

# 44. Common Interview Mistakes

## Mistake 1 — Put booking status inside Seat

Wrong:

```java
class Seat {
    boolean booked;
}
```

Because booking is show-specific.

Correct:

```text
Seat
  +
Show
  =
ShowSeat
```

---

## Mistake 2 — No seat locking

If you only have:

```text
AVAILABLE
BOOKED
```

you miss the payment window.

Better:

```text
AVAILABLE
LOCKED
BOOKED
```

---

## Mistake 3 — God Class

Avoid:

```java
class MovieBookingSystem {

    searchMovie();
    bookSeat();
    processPayment();
    calculatePrice();
    cancelBooking();
    sendEmail();
    ...
}
```

Split responsibilities.

---

## Mistake 4 — Ignore concurrency

For ticket booking, concurrency is one of the first things an interviewer may ask.

Always mention:

```text
Two users → same seat
```

and explain atomic locking.

---

## Mistake 5 — Overuse design patterns

Don't start with:

```text
Factory
Strategy
State
Observer
Builder
Singleton
Abstract Factory
...
```

Use the simplest design first.

Then introduce a pattern when there is a reason.

---

# 45. Optional Notification Service

After successful booking:

```text
Booking Confirmed
       |
       +---- Email
       |
       +---- SMS
       |
       +---- Push Notification
```

We could introduce:

```java
public interface NotificationService {

    void send(
            User user,
            Booking booking
    );
}
```

Implementations:

```text
EmailNotificationService
SMSNotificationService
PushNotificationService
```

This is another Strategy-like abstraction.

For asynchronous systems, this can also become an event-driven flow:

```text
Booking Confirmed
       |
       v
BookingConfirmedEvent
       |
       +---- Email Consumer
       +---- SMS Consumer
       +---- Push Consumer
```

---

# 46. Production-Level Architecture

For an actual large-scale movie booking system:

```text
                    User
                     |
                     v
               API Gateway
                     |
        +------------+-------------+
        |            |             |
        v            v             v
   Movie Service  Show Service  Booking Service
                                   |
                         +---------+---------+
                         |                   |
                         v                   v
                  Seat Inventory        Payment Service
                         |
                         v
                     Database
```

Potential infrastructure:

```text
Database
Cache
Message Queue
Payment Gateway
Notification Service
Search Service
```

But in an LLD interview, don't jump into microservices unless asked.

Start with the object model.

---

# 47. Recommended Project Structure

```text
src/
│
├── model/
│   ├── User.java
│   ├── Movie.java
│   ├── Theatre.java
│   ├── Screen.java
│   ├── Seat.java
│   ├── ShowSeat.java
│   ├── Show.java
│   ├── Booking.java
│   └── Payment.java
│
├── service/
│   ├── BookingService.java
│   ├── SeatLockService.java
│   ├── PaymentService.java
│   ├── UPIPaymentService.java
│   └── CardPaymentService.java
│
├── strategy/
│   ├── PricingStrategy.java
│   └── CancellationPolicy.java
│
├── enums/
│   ├── SeatType.java
│   ├── SeatStatus.java
│   ├── BookingStatus.java
│   └── PaymentStatus.java
│
└── Main.java
```

---

# 48. Interview Opening

If the interviewer says:

> "Design a movie ticket booking system."

You can start with:

> "I'll first clarify the scope. I'll assume users can search movies, select a theatre and show, view available seats, lock seats temporarily, make payment, and confirm or cancel bookings. The key domain entities are Movie, Theatre, Screen, Seat, Show, ShowSeat, User, Booking and Payment. One important design decision is that seat availability is show-specific, so I won't put booking status directly on the physical Seat. I'll model it through ShowSeat. I'll also separate booking, payment and seat-locking responsibilities. Finally, I'll address concurrency because two users may try to book the same seat simultaneously."

That is a **very strong opening** for this problem.

---

# 49. Most Important Interview Follow-Ups

Prepare these especially well:

### 1. Why isn't booking status inside Seat?

Answer:

> Because Seat represents a physical seat, while availability is specific to a Show. The same physical seat can be booked for one show and available for another.

---

### 2. How do you prevent double booking?

Answer:

> Use atomic seat locking at the show-seat level. The availability check and transition from AVAILABLE to LOCKED must be concurrency-safe, typically using a database transaction/row lock or another appropriate distributed coordination mechanism.

---

### 3. Why do we need LOCKED?

Answer:

> Because the user needs time to complete payment. Without a temporary lock, another user could book the same seat while the first user's payment is in progress.

---

### 4. What happens if payment fails?

Answer:

> The booking remains unsuccessful and the temporarily locked seats are released, subject to the transaction and failure-handling design.

---

### 5. What if payment succeeds but the server crashes?

Answer:

> We need persistent transaction state, idempotency, retries and reconciliation between the payment provider and booking system. We shouldn't rely on an in-memory transaction.

---

### 6. Why use Strategy Pattern?

Answer:

> Payment methods and pricing rules can change independently. Strategy lets us add UPI, cards, wallets, weekend pricing, discounts, etc. without changing the core booking workflow.

---

### 7. Would you use State Pattern?

Answer:

> Initially, no. An enum is simpler. If each booking state starts having significant state-specific behavior, I'd introduce the State Pattern.

---

# 50. Final Mental Model

For this LLD, remember this chain:

```text
Movie
  ↓
Theatre
  ↓
Screen
  ↓
Seat
  ↓
Show
  ↓
ShowSeat
  ↓
Seat Lock
  ↓
Booking
  ↓
Payment
  ↓
Confirmation
```

The **three most important concepts** are:

```text
1. Seat availability is SHOW-SPECIFIC

2. Seats need temporary LOCKING

3. Booking + payment need CONCURRENCY,
   IDEMPOTENCY and FAILURE handling
```

And the overall design principle is:

```text
Requirement
     ↓
Identify entities
     ↓
Separate responsibilities
     ↓
Model relationships
     ↓
Protect state
     ↓
Handle changing behavior with interfaces
     ↓
Handle concurrency
     ↓
Handle failure cases
     ↓
Write Java code
```

## One-line interview summary

> **"I would model physical seats separately from show-specific seat inventory, use temporary seat locking to prevent double booking, keep booking and payment responsibilities separate, use Strategy for variable payment/pricing behavior, and handle concurrency, idempotency and payment failures explicitly."**