# Java I/O and Java NIO — Interview Guide

A practical interview-oriented reference covering **Java I/O (`java.io`)** and **Java NIO (`java.nio`, `java.nio.file`, `java.nio.channels`)**.

Includes:

- Core concepts
- Commented Java examples
- Java I/O vs Java NIO comparisons
- `Path` and `Files`
- Streams, Readers, Writers
- Buffers and Channels
- `ByteBuffer` operations
- Selectors and non-blocking I/O
- NIO.2 asynchronous I/O
- Memory-mapped files
- Scenario-based interview questions
- Sequence diagrams
- Common interview questions
- Interview tips
- Quick decision trees
- Common mistakes

---

# 1. Java I/O vs Java NIO — Big Picture

| Feature | Java I/O | Java NIO |
|---|---|---|
| Main packages | `java.io` | `java.nio`, `java.nio.file`, `java.nio.channels` |
| Programming model | Stream-oriented | Buffer/channel-oriented |
| Blocking | Primarily blocking | Supports blocking and non-blocking |
| Data handling | Streams | Buffers |
| File API | `File` | `Path`, `Files` |
| Directory traversal | `File` APIs | `Files.walk()`, `DirectoryStream` |
| Large-file handling | Streams | Channels / mapped buffers |
| Network programming | Traditional sockets | Channels/selectors |
| Non-blocking I/O | ❌ | ✅ |
| Asynchronous I/O | Limited | Better support through NIO.2 / `Asynchronous*` APIs |
| Modern Java recommendation | Legacy but still useful | Preferred for most new file-system code |

## Mental Model

### Java I/O

```text
Application
    |
    v
InputStream / Reader
    |
    v
  Data
    |
    v
File / Socket
```

### Java NIO

```text
Application
    |
    v
 Channel
    |
    v
 Buffer
    |
    v
File / Socket
```

### Key interview point

> **I/O is stream-oriented, while NIO is primarily buffer/channel-oriented and provides APIs for non-blocking and asynchronous I/O.**

---

# 2. Java I/O — Basic File Reading

## Example: Reading a text file using `BufferedReader`

```java
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class ReadFileExample {

    public static void main(String[] args) {

        // try-with-resources automatically closes the reader
        // even if an exception occurs.
        try (BufferedReader reader =
                     new BufferedReader(new FileReader("input.txt"))) {

            String line;

            // Read the file one line at a time.
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }

        } catch (IOException e) {
            // Handle file-related errors.
            e.printStackTrace();
        }
    }
}
```

## Why use `BufferedReader`?

Reading one character directly from a file repeatedly can result in many underlying I/O operations.

`BufferedReader` keeps data in memory temporarily:

```text
Disk
  |
  | large read
  v
Buffer
  |
  | small reads
  v
Application
```

This generally reduces expensive calls to the underlying resource.

---

# 3. Java I/O — Writing a File

```java
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class WriteFileExample {

    public static void main(String[] args) {

        // false means overwrite the existing file.
        // true would append to the file.
        try (BufferedWriter writer =
                     new BufferedWriter(new FileWriter("output.txt"))) {

            writer.write("Hello Java!");
            writer.newLine();

            writer.write("This is Java I/O.");
            writer.newLine();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## Append instead of overwrite

```java
try (BufferedWriter writer =
         new BufferedWriter(new FileWriter("output.txt", true))) {

    writer.write("New line");
    writer.newLine();
}
```

---

# 4. Byte Stream vs Character Stream

This is one of the most common Java I/O interview questions.

## Byte Streams

Byte streams are used for binary data such as:

- Images
- PDFs
- ZIP files
- Audio
- Video

Main classes:

```text
InputStream
OutputStream
```

### Example

```java
try (InputStream input =
         new FileInputStream("image.jpg");
     OutputStream output =
         new FileOutputStream("copy.jpg")) {

    byte[] buffer = new byte[8192];

    int bytesRead;

    while ((bytesRead = input.read(buffer)) != -1) {

        output.write(buffer, 0, bytesRead);
    }
}
```

## Character Streams

Character streams are primarily used for text.

```text
Reader
Writer
```

### Example

```java
try (Reader reader =
         new FileReader("input.txt")) {

    char[] buffer = new char[1024];

    int charsRead;

    while ((charsRead = reader.read(buffer)) != -1) {
        System.out.print(
            new String(buffer, 0, charsRead)
        );
    }
}
```

## Interview Comparison

| Byte Stream | Character Stream |
|---|---|
| `InputStream` | `Reader` |
| `OutputStream` | `Writer` |
| Works with bytes | Works with characters |
| Binary data | Text data |
| Example: image | Example: text file |

---

# 5. Character Encoding

A common real-world problem is character encoding.

Avoid relying on the platform default encoding when reading/writing important text.

Instead, specify the encoding explicitly.

```java
import java.io.*;
import java.nio.charset.StandardCharsets;

public class EncodingExample {

    public static void main(String[] args) throws IOException {

        try (BufferedReader reader =
                 new BufferedReader(
                     new InputStreamReader(
                         new FileInputStream("input.txt"),
                         StandardCharsets.UTF_8))) {

            String line;

            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }
    }
}
```

Modern Java code should generally make the encoding explicit when it matters.

---

# 6. Java I/O — Object Serialization

Java I/O also includes serialization.

```java
import java.io.*;

class Employee implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String name;

    public Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }
}

public class SerializationExample {

    public static void main(String[] args) throws IOException {

        Employee employee =
                new Employee(101, "John");

        // Convert object into bytes and store it.
        try (ObjectOutputStream out =
                     new ObjectOutputStream(
                         new FileOutputStream("employee.ser"))) {

            out.writeObject(employee);
        }
    }
}
```

## Deserialization

```java
try (ObjectInputStream in =
         new ObjectInputStream(
             new FileInputStream("employee.ser"))) {

    Employee employee =
            (Employee) in.readObject();
}
```

## Interview Warning

Java native serialization has security, compatibility, and maintenance concerns.

For modern external data interchange, formats such as **JSON** or **Protocol Buffers** are often preferred.

---

# 7. Java NIO — `Path` and `Files`

Modern Java file operations are usually much cleaner with `Path` and `Files`.

## Read a complete file

```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class NioReadExample {

    public static void main(String[] args) throws IOException {

        Path path = Path.of("input.txt");

        // Reads the entire file into a String.
        String content = Files.readString(path);

        System.out.println(content);
    }
}
```

For a relatively small text file, this is very convenient.

## Write a file

```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class NioWriteExample {

    public static void main(String[] args) throws IOException {

        Path path = Path.of("output.txt");

        Files.writeString(
                path,
                "Hello from Java NIO!"
        );
    }
}
```

---

# 8. Copy, Move and Delete

```java
import java.io.IOException;
import java.nio.file.*;

public class FileOperations {

    public static void main(String[] args)
            throws IOException {

        Path source = Path.of("source.txt");
        Path target = Path.of("backup.txt");

        // Copy file.
        Files.copy(
                source,
                target,
                StandardCopyOption.REPLACE_EXISTING
        );

        // Move file.
        Files.move(
                target,
                Path.of("archive.txt"),
                StandardCopyOption.REPLACE_EXISTING
        );

        // Delete file.
        Files.deleteIfExists(
                Path.of("archive.txt")
        );
    }
}
```

---

# 9. `Path` vs `File`

This is a very commonly asked interview question.

## Old Java I/O

```java
File file = new File("data/input.txt");

System.out.println(file.exists());
System.out.println(file.length());
```

## NIO

```java
Path path = Path.of("data/input.txt");

System.out.println(Files.exists(path));
System.out.println(Files.size(path));
```

## Comparison

| `File` | `Path` |
|---|---|
| Older API | Modern API |
| `java.io.File` | `java.nio.file.Path` |
| Limited functionality | Richer API |
| Basic file operations | Advanced file-system operations |
| Less flexible | Better provider support |
| Legacy code | Preferred for new code |

### Interview Answer

`Path` is not simply a "faster File."

It is a more capable abstraction for representing file-system paths and works with the `Files` API for operations.

---

# 10. Directory Traversal with NIO

Suppose we have:

```text
project/
├── src/
│   ├── Main.java
│   └── Test.java
├── README.md
└── pom.xml
```

We can traverse it with:

```java
import java.io.IOException;
import java.nio.file.*;

public class DirectoryWalkExample {

    public static void main(String[] args)
            throws IOException {

        Path root = Path.of("project");

        try (var paths = Files.walk(root)) {

            paths.filter(Files::isRegularFile)
                 .forEach(System.out::println);
        }
    }
}
```

Possible output:

```text
project/src/Main.java
project/src/Test.java
project/README.md
project/pom.xml
```

### Important

`Files.walk()` returns a stream that should be closed.

Therefore:

```java
try (var paths = Files.walk(root)) {
    // process paths
}
```

---

# 11. Java NIO `ByteBuffer`

One of the biggest differences between traditional I/O and NIO is the use of buffers.

```java
import java.nio.ByteBuffer;

public class BufferExample {

    public static void main(String[] args) {

        ByteBuffer buffer =
                ByteBuffer.allocate(10);

        // Write data into the buffer.
        buffer.put((byte) 10);
        buffer.put((byte) 20);
        buffer.put((byte) 30);

        // Switch from writing mode to reading mode.
        buffer.flip();

        while (buffer.hasRemaining()) {

            byte value = buffer.get();

            System.out.println(value);
        }
    }
}
```

---

# 12. Understand `flip()`, `clear()`, `rewind()`

This is a very common NIO interview topic.

A `ByteBuffer` has three important properties:

```text
capacity
position
limit
```

## Initially

```text
capacity = 10
position = 0
limit    = 10
```

## After writing 3 bytes

```text
capacity = 10
position = 3
limit    = 10
```

## After `flip()`

```java
buffer.flip();
```

we get:

```text
capacity = 10
position = 0
limit    = 3
```

This means the three written bytes are now ready to be read.

## Visual Representation

```text
+----+----+----+----+----+----+----+----+----+----+
| 10 | 20 | 30 |    |    |    |    |    |    |    |
+----+----+----+----+----+----+----+----+----+----+
  ^
  position

              ^
              limit
```

## Important Methods

| Method | Purpose |
|---|---|
| `flip()` | Prepare buffer for reading |
| `clear()` | Prepare buffer for writing again |
| `rewind()` | Read from the beginning again |
| `remaining()` | Number of elements between position and limit |
| `hasRemaining()` | Whether data remains |

---

# 13. NIO FileChannel

A `FileChannel` is a channel for reading/writing files.

```java
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.*;

public class FileChannelExample {

    public static void main(String[] args)
            throws IOException {

        Path path = Path.of("input.txt");

        try (FileChannel channel =
                     FileChannel.open(
                         path,
                         StandardOpenOption.READ)) {

            ByteBuffer buffer =
                    ByteBuffer.allocate(1024);

            int bytesRead;

            while ((bytesRead = channel.read(buffer)) != -1) {

                // Prepare buffer for reading.
                buffer.flip();

                while (buffer.hasRemaining()) {
                    System.out.print(
                        (char) buffer.get()
                    );
                }

                // Prepare buffer for the next read.
                buffer.clear();
            }
        }
    }
}
```

---

# 14. NIO Channel + Buffer Model

The basic flow is:

```text
             READ

File ───────────────────> Channel
                            |
                            v
                         Buffer
                            |
                            v
                       Application
```

For writing:

```text
             WRITE

Application ─────────────> Buffer
                            |
                            v
                         Channel
                            |
                            v
                           File
```

### Core mental model

```text
Channel <----> Buffer <----> Application
```

---

# 15. Java NIO Non-Blocking I/O

One of NIO's important capabilities is non-blocking network I/O.

## Traditional Blocking Model

```text
Thread 1
   |
   | read()
   |
   +---------- WAIT ----------+
                              |
                         data arrives
                              |
                              v
                           continue
```

## Non-Blocking Model

A thread can monitor multiple channels.

```text
                    +-------------+
                    |   Selector  |
                    +-------------+
                     /     |      \
                    /      |       \
                   v       v        v
               Channel  Channel  Channel
                  1        2        3
```

This can be useful for servers handling many connections.

---

# 16. Selector Example

A simplified example:

```java
Selector selector = Selector.open();

SocketChannel channel =
        SocketChannel.open();

channel.configureBlocking(false);

channel.register(
        selector,
        SelectionKey.OP_READ
);

while (true) {

    // Wait until one or more registered
    // channels are ready.
    selector.select();

    for (SelectionKey key :
            selector.selectedKeys()) {

        if (key.isReadable()) {

            // The channel has data available.
            SocketChannel socket =
                    (SocketChannel) key.channel();

            // Read data here.
        }
    }

    selector.selectedKeys().clear();
}
```

## Key Idea

Instead of:

```text
Thread -> Connection 1 -> WAIT

Thread -> Connection 2 -> WAIT

Thread -> Connection 3 -> WAIT
```

you can conceptually have:

```text
             One event loop
                   |
              Selector
             /    |    \
            /     |     \
          C1      C2     C3
```

---

# 17. Java NIO.2 Asynchronous File I/O

NIO.2 provides asynchronous APIs.

```java
import java.nio.ByteBuffer;
import java.nio.channels.AsynchronousFileChannel;
import java.nio.file.Path;
import java.util.concurrent.Future;

public class AsyncFileExample {

    public static void main(String[] args)
            throws Exception {

        Path path = Path.of("input.txt");

        try (AsynchronousFileChannel channel =
                     AsynchronousFileChannel.open(path)) {

            ByteBuffer buffer =
                    ByteBuffer.allocate(1024);

            Future<Integer> future =
                    channel.read(buffer, 0);

            // Do other work here while the
            // asynchronous operation is in progress.
            System.out.println("Doing other work...");

            int bytesRead = future.get();

            System.out.println(
                    "Bytes read: " + bytesRead
            );
        }
    }
}
```

### Important nuance

Calling `future.get()` eventually waits for the operation.

For a truly asynchronous design, use a completion handler or compose the asynchronous operation without immediately blocking on the result.

---

# 18. `InputStream` vs `Reader`

## Question

**What's the difference between `InputStream` and `Reader`?**

## Answer

`InputStream` works with raw bytes, while `Reader` works with characters.

### InputStream hierarchy

```text
InputStream
    |
    +-- FileInputStream
    +-- BufferedInputStream
```

### Reader hierarchy

```text
Reader
    |
    +-- FileReader
    +-- BufferedReader
    +-- InputStreamReader
```

For text where encoding matters:

```text
InputStream
      |
      v
InputStreamReader
      |
      v
BufferedReader
```

---

# 19. `BufferedInputStream` vs `FileInputStream`

Without buffering:

```text
FileInputStream
      |
      v
File
```

With buffering:

```text
BufferedInputStream
      |
      v
FileInputStream
      |
      v
File
```

The buffered version adds an in-memory buffer, reducing the number of direct underlying reads.

## Example

```java
try (InputStream input =
         new BufferedInputStream(
             new FileInputStream("data.bin"))) {

    byte[] buffer = new byte[8192];

    int count;

    while ((count = input.read(buffer)) != -1) {
        // Process count bytes.
    }
}
```

---

# 20. Try-With-Resources

This is very frequently asked.

## Traditional approach

```java
FileInputStream input = null;

try {
    input = new FileInputStream("data.txt");

    // Read file.

} finally {

    if (input != null) {
        input.close();
    }
}
```

## Modern approach

```java
try (FileInputStream input =
         new FileInputStream("data.txt")) {

    // Read file.

}
```

Java automatically closes resources implementing:

```text
AutoCloseable
```

including its `Closeable` subinterface.

---

# 21. Multiple Resources

You can manage several resources in one try-with-resources statement.

```java
try (
    InputStream input =
        new FileInputStream("input.txt");

    OutputStream output =
        new FileOutputStream("output.txt")
) {

    byte[] buffer = new byte[8192];

    int count;

    while ((count = input.read(buffer)) != -1) {
        output.write(buffer, 0, count);
    }
}
```

Resources are closed automatically in **reverse order of declaration**.

```text
Open:
    input
    output

Close:
    output
    input
```

---

# 22. Scenario-Based Interview Questions

## Scenario 1 — Copy a 10 GB File

### Question

> You need to copy a 10 GB file. Would you use `Files.readAllBytes()`?

### Answer

No.

That would attempt to load the whole file into memory.

Prefer streaming or a channel-based approach.

```java
try (
    InputStream in =
        Files.newInputStream(source);

    OutputStream out =
        Files.newOutputStream(target)
) {

    byte[] buffer = new byte[1024 * 1024];

    int count;

    while ((count = in.read(buffer)) != -1) {
        out.write(buffer, 0, count);
    }
}
```

For straightforward copying, you can also use:

```java
Files.copy(
    source,
    target,
    StandardCopyOption.REPLACE_EXISTING
);
```

---

# 23. Scenario 2 — Read a 20 GB Log File

## Bad Approach

```java
String content =
        Files.readString(path);
```

Why?

```text
20 GB file
   |
   v
Memory
   |
   X
Possible memory pressure / OutOfMemoryError
```

## Better Approach

```java
try (var lines = Files.lines(path)) {

    lines.filter(line -> line.contains("ERROR"))
         .forEach(System.out::println);
}
```

This allows the file to be processed incrementally rather than requiring the entire content to be held in memory.

---

# 24. Scenario 3 — Millions of Network Connections

### Question

> You are designing a high-concurrency server. Creating one blocking thread per connection becomes expensive. What could you use?

Potential answer:

```text
SocketChannel
      |
      v
non-blocking mode
      |
      v
Selector
      |
      +------ Client 1
      +------ Client 2
      +------ Client 3
      +------ Client N
```

NIO's non-blocking channels and selectors can allow a smaller number of threads to monitor many connections.

### Modern Java nuance

Also consider whether **virtual threads** are a better fit for the application's architecture.

NIO non-blocking I/O is not automatically the right choice simply because concurrency is high.

---

# 25. Scenario 4 — Binary Image Processing

### Question

> You need to copy an image. Would you use `Reader`?

No.

An image is binary data.

Use:

```text
InputStream
OutputStream
```

or:

```text
FileChannel
ByteBuffer
```

depending on the requirements.

---

# 26. Scenario 5 — UTF-8 File

### Question

> Your application works correctly on your laptop but fails on another machine because special characters are corrupted. What might be wrong?

Potential cause:

```text
Platform default encoding
```

Prefer explicit encoding:

```java
Files.readString(
    path,
    StandardCharsets.UTF_8
);
```

and:

```java
Files.writeString(
    path,
    content,
    StandardCharsets.UTF_8
);
```

---

# 27. `Files` vs `FileChannel`

A useful interview distinction:

| `Files` | `FileChannel` |
|---|---|
| High-level API | Lower-level API |
| Very convenient | More control |
| `readString()` | Buffer-based reads |
| `writeString()` | Buffer-based writes |
| Copy/move/delete | Position/channel operations |
| Great for normal file operations | Useful for advanced I/O and certain large-file workloads |

## Rule of Thumb

```text
Simple file operation?
       |
       +---- YES ---> Files / Path

Need fine-grained I/O?
       |
       +---- YES ---> FileChannel / Buffer
```

---

# 28. Memory-Mapped Files

Another important NIO feature is memory mapping.

```java
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.*;

public class MemoryMappedExample {

    public static void main(String[] args)
            throws Exception {

        Path path = Path.of("large-file.dat");

        try (FileChannel channel =
                     FileChannel.open(
                         path,
                         StandardOpenOption.READ)) {

            MappedByteBuffer buffer =
                    channel.map(
                        FileChannel.MapMode.READ_ONLY,
                        0,
                        channel.size()
                    );

            while (buffer.hasRemaining()) {

                byte value = buffer.get();

                // Process the byte.
            }
        }
    }
}
```

## Conceptual Model

```text
File
 |
 | map
 v
Virtual Memory
 |
 v
MappedByteBuffer
 |
 v
Application
```

Memory mapping can be useful for certain workloads involving large files and random access, but it is not automatically faster for every workload.

---

# 29. Sequence Diagram — Traditional File Read

```text
Application       BufferedReader       FileReader       OS / File
     |                  |                  |                |
     | readLine()       |                  |                |
     |----------------->|                  |                |
     |                  | read()           |                |
     |                  |----------------->|                |
     |                  |                  | read           |
     |                  |                  |---------------> |
     |                  |                  | <---------------|
     |                  | <----------------|                |
     | <----------------|                  |                |
     |                  |                  |                |
```

The important point is that the application interacts with a stream abstraction, while buffering can reduce the number of underlying file-system reads.

---

# 30. Sequence Diagram — NIO FileChannel

```text
Application       ByteBuffer        FileChannel       File
     |                |                 |               |
     | read(buffer)   |                 |               |
     |------------------------------->  |               |
     |                |                 | read          |
     |                | <---------------|               |
     |                |                 |-------------->|
     |                |                 |<--------------|
     |                |                 |               |
     | process buffer |                 |               |
     |--------------->|                 |               |
```

### Core concept

```text
Application
     |
     v
 ByteBuffer
     ^
     |
FileChannel
     ^
     |
   File
```

---

# 31. Blocking vs Non-Blocking

## Blocking

```text
Thread
  |
  v
read()
  |
  | WAIT
  |
  | WAIT
  |
  v
data available
  |
  v
continue
```

## Non-Blocking

```text
Thread
  |
  v
Selector
  |
  +---- Channel A
  |
  +---- Channel B
  |
  +---- Channel C
  |
  v
Ready event
  |
  v
Process it
```

## Interview Nuance

Do not say:

> "NIO is always non-blocking."

That is incorrect.

NIO channels can operate in blocking mode, and file channels do not provide the same selectable non-blocking model as socket channels.

---

# 32. Important `ByteBuffer` Interview Question

### Question

What happens here?

```java
ByteBuffer buffer =
        ByteBuffer.allocate(10);

buffer.put((byte) 100);

System.out.println(buffer.position());

buffer.flip();

System.out.println(buffer.position());
System.out.println(buffer.limit());
```

### Answer

After `put()`:

```text
position = 1
limit    = 10
capacity = 10
```

After `flip()`:

```text
position = 0
limit    = 1
capacity = 10
```

This is an excellent question because it tests whether you actually understand NIO buffers rather than simply memorizing API names.

---

# 33. Heap vs Direct `ByteBuffer`

Two common allocation methods:

```java
ByteBuffer buffer =
        ByteBuffer.allocate(1024);
```

and:

```java
ByteBuffer buffer =
        ByteBuffer.allocateDirect(1024);
```

## Comparison

| Heap Buffer | Direct Buffer |
|---|---|
| Backed by JVM heap | Typically outside ordinary Java heap |
| Simple/general use | Can be beneficial for some native I/O paths |
| Usually cheaper to allocate | Allocation can be more expensive |
| Easy to work with | Different lifecycle/performance characteristics |

### Important interview point

Do not say:

> "Direct buffer is always faster."

Actual performance depends on:

- Workload
- Allocation frequency
- Access pattern
- JVM
- Operating system
- I/O path
- Buffer reuse

---

# 34. Common Interview Questions

| Question | Key Point |
|---|---|
| I/O vs NIO? | Streams vs buffers/channels; NIO adds APIs supporting non-blocking I/O |
| `InputStream` vs `Reader`? | Bytes vs characters |
| `OutputStream` vs `Writer`? | Bytes vs characters |
| `File` vs `Path`? | Legacy vs modern file-system abstraction |
| What is `ByteBuffer`? | Container for data used with NIO channels |
| Why `flip()`? | Switch buffer from writing to reading |
| What does `clear()` do? | Resets buffer for writing |
| What is a Channel? | Abstraction for I/O connection/operations |
| What is Selector? | Monitors multiple selectable channels |
| What is non-blocking I/O? | I/O operations can return without waiting for data |
| What is buffering? | Reduces expensive underlying I/O operations |
| What is try-with-resources? | Automatic resource closing |
| What is serialization? | Object state represented as a byte stream |
| What is NIO.2? | Expanded NIO APIs introduced in Java 7 |
| What is memory mapping? | Mapping file contents into virtual memory |
| `Files.readString()` for huge files? | Usually no; process incrementally |
| `Files.lines()`? | Lazy stream of lines; close the stream |
| `FileChannel` vs `Files`? | Lower-level control vs convenient high-level API |

---

# 35. Common Mistakes in Interviews

## Mistake 1 — "NIO means non-blocking I/O"

Incorrect:

> NIO means non-blocking I/O.

Better:

> NIO introduced buffers/channels and APIs supporting non-blocking I/O; not every NIO operation is non-blocking.

---

## Mistake 2 — Using `readAllBytes()` for everything

Incorrect:

```java
Files.readAllBytes(path);
```

for arbitrarily large files.

Better:

> Use it when the file is appropriately sized and holding the contents in memory is acceptable.

---

## Mistake 3 — Using `Reader` for everything

Incorrect.

Use:

```text
Binary -> InputStream / OutputStream
Text   -> Reader / Writer
```

---

## Mistake 4 — Forgetting `flip()`

When writing into a `ByteBuffer` and then reading from it:

```java
buffer.put(data);
buffer.flip();
buffer.get();
```

The `flip()` is essential because it switches the buffer from writing mode to reading mode.

---

## Mistake 5 — Not closing `Files.lines()`

Remember:

```java
try (Stream<String> lines = Files.lines(path)) {
    // process lines
}
```

---

# 36. Quick Decision Tree

```text
Need file I/O?
      |
      v
Is it text?
   /       \
 YES        NO
  |          |
Reader/      InputStream/
Writer       OutputStream
  |          |
  +----+-----+
       |
       v
Need modern file API?
       |
       YES
       |
       v
   Path + Files
       |
       v
Need advanced I/O?
       |
       +------ YES ------> FileChannel
       |                      |
       |                      v
       |                  ByteBuffer
       |
       +------ Network -----> SocketChannel
                                  |
                                  v
                              Selector
```

---

# 37. Interview Tips

## Tip 1 — Know the hierarchy

Be able to explain:

```text
InputStream
    |
    +-- FileInputStream
    +-- BufferedInputStream
    +-- ObjectInputStream
    +-- DataInputStream
```

And:

```text
Reader
    |
    +-- FileReader
    +-- BufferedReader
    +-- InputStreamReader
```

---

## Tip 2 — Know these five NIO concepts

If you remember nothing else, know:

```text
Path
Files
Channel
Buffer
Selector
```

And understand what each one does.

---

## Tip 3 — Practice `ByteBuffer`

You should be comfortable explaining:

```java
put()
flip()
get()
clear()
rewind()
remaining()
hasRemaining()
```

---

## Tip 4 — Always discuss resource management

When showing file I/O code, use:

```java
try-with-resources
```

unless there is a good reason not to.

---

## Tip 5 — Mention scalability carefully

For a high-concurrency network server, NIO's non-blocking APIs can reduce the number of threads needed to manage many connections.

But do not automatically conclude:

```text
NIO = faster
```

Performance depends on the workload and architecture.

---

# 38. Top 10 Questions to Practice

1. **What is the difference between Java I/O and Java NIO?**
2. **What is the difference between `InputStream` and `Reader`?**
3. **What is the difference between `File` and `Path`?**
4. **What are Channel and Buffer in NIO?**
5. **Explain `ByteBuffer.flip()` with an example.**
6. **What is a Selector and why is it useful?**
7. **What is blocking vs non-blocking I/O?**
8. **How would you process a 20 GB log file?**
9. **How would you copy a large binary file efficiently?**
10. **Why should you use try-with-resources?**

---

# 39. One-Line Cheat Sheet

```text
java.io
  = Streams + traditional blocking I/O

java.nio
  = Buffers + Channels + modern file/network APIs

java.nio.file
  = Path + Files

java.nio.channels
  = FileChannel + SocketChannel + Selector

NIO.2
  = richer file-system + asynchronous I/O APIs
```

---

# 40. Final Interview Takeaway

The goal is not to memorize every Java I/O class.

You should be able to reason about the requirements and choose the appropriate abstraction.

```text
Small text file
    |
    v
Path + Files.readString()

Large text file
    |
    v
Files.lines()
or
BufferedReader

Binary file
    |
    v
InputStream / OutputStream

Advanced file I/O
    |
    v
FileChannel + ByteBuffer

Many network connections
    |
    v
SocketChannel + Selector
or an appropriate modern concurrency model

Asynchronous file operation
    |
    v
AsynchronousFileChannel
```

## The most important interview principle

> **Choose the I/O abstraction based on the data type, file size, concurrency requirements, resource constraints, and application architecture — not simply because NIO is newer.**

A strong interview answer should explain **why** you selected `Files`, streams, `FileChannel`, `ByteBuffer`, or non-blocking channels for the scenario.

---

# Appendix — Quick Revision Table

| Topic | Remember |
|---|---|
| Stream | Sequential flow of data |
| InputStream | Read bytes |
| OutputStream | Write bytes |
| Reader | Read characters |
| Writer | Write characters |
| BufferedReader | Buffered text reading |
| BufferedWriter | Buffered text writing |
| File | Legacy file abstraction |
| Path | Modern path abstraction |
| Files | High-level file operations |
| Channel | NIO I/O abstraction |
| Buffer | Holds data exchanged with a channel |
| `flip()` | Write mode → read mode |
| `clear()` | Prepare buffer for writing |
| `rewind()` | Re-read from beginning |
| Selector | Monitor multiple selectable channels |
| Blocking | Operation may wait |
| Non-blocking | Operation can return without waiting |
| `FileChannel` | Advanced file I/O |
| `AsynchronousFileChannel` | Asynchronous file operations |
| Memory mapping | Map file region into virtual memory |
| Try-with-resources | Automatic resource cleanup |
| Explicit UTF-8 | Avoid platform encoding surprises |
| Large files | Process incrementally |
| Binary data | Byte streams/channels |
| Text data | Reader/Writer or NIO text APIs |

---

## Recommended Study Order

```text
1. InputStream / OutputStream
          |
          v
2. Reader / Writer
          |
          v
3. BufferedReader / BufferedWriter
          |
          v
4. try-with-resources
          |
          v
5. Path + Files
          |
          v
6. ByteBuffer
          |
          v
7. FileChannel
          |
          v
8. SocketChannel
          |
          v
9. Selector
          |
          v
10. AsynchronousFileChannel
          |
          v
11. Memory-mapped files
```

---

**End of Java I/O & NIO Interview Guide**
