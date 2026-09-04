**Types of thread dumps**, what they show, and **how to analyze** them. This is super useful when debugging **performance issues, deadlocks, memory leaks**, or CPU spikes in Java applications.

---

## 🧠 What is a Thread Dump?

A **thread dump** is a snapshot of **all threads** in the Java Virtual Machine (JVM), showing:

* Thread states (e.g., RUNNABLE, BLOCKED, WAITING)
* Stack traces (what each thread is doing)
* Locks held or waited on (for deadlock detection)
* Thread priorities, daemon status, IDs, etc.

---

## 🧾 Types of Thread Dumps

### 1. **Full Thread Dump**

**Shows all threads**, their states, and full stack traces.

🔍 Useful for:

* CPU usage analysis
* Blocked threads
* Thread leaks
* Performance bottlenecks

🧩 Contains:

```text
"main" #1 prio=5 os_prio=31 tid=0x0000000103081000 nid=0x5103 runnable
   java.lang.Thread.State: RUNNABLE
   at com.app.MyClass.processData(MyClass.java:44)
```

---

### 2. **Deadlock Information (found within Full Dumps)**

If threads are deadlocked, the dump shows it.

📌 Example:

```text
Found one Java-level deadlock:
Thread-1: waiting to lock object A held by Thread-2
Thread-2: waiting to lock object B held by Thread-1
```

🧠 Use case: Identify mutual locking cycles.

---

### 3. **Lightweight Thread Dump**

Only contains **basic info** like thread names, states, and IDs.
No full stack trace.

🧩 Shows:

```text
"Worker-1" prio=5 tid=0x0012345 waiting
```

✅ Useful for quick status checks, but not detailed debugging.

---

### 4. **JFR (Java Flight Recorder) Thread Dump**

From **Java Mission Control (JMC)** or `jcmd`, more structured.

📈 Shows:

* Thread activity over time
* GC, CPU, memory, locks
* Thread lifecycle events

🎯 Best for performance tuning and long-term analysis.

---

### 5. **Thread Dump with Monitor Locks**

Shows which threads hold or are waiting for object monitors (locks).

📌 Contains:

```text
- waiting to lock <0x00000000f1a5c1d0> (a java.lang.Object)
- locked <0x00000000f1a5c1e0> (a java.lang.Object)
```

✅ Helps trace:

* BLOCKED or WAITING threads
* Lock contention issues

---

### 6. **Native Thread Dump**

Generated via OS tools like `gdb` (Linux) or `procdump` (Windows).
Shows **native stack frames**, useful for JNI-level debugging or JVM crashes.

---

## 🔍 How to Generate Thread Dumps

### A. **At Runtime**

* **`jstack <pid>`** – Standard and most used.
* **`jcmd <pid> Thread.print`** – Faster and more modern.
* **Ctrl + \ (SIGQUIT)** – On Unix (prints to console).
* **Kill -3 <pid>** – Sends `SIGQUIT`, prints thread dump to stdout.

### B. **Inside Application**

```java
Thread.getAllStackTraces();
```

---

## 🔎 Thread States in Dumps

| State             | Meaning                                                 |
| ----------------- | ------------------------------------------------------- |
| **RUNNABLE**      | Actively using CPU                                      |
| **WAITING**       | Waiting indefinitely (`Object.wait()`, `Thread.join()`) |
| **TIMED_WAITING** | Waiting with timeout (`sleep()`, `wait(timeout)`)       |
| **BLOCKED**       | Waiting to enter a synchronized block/method            |
| **TERMINATED**    | Completed execution                                     |
| **NEW**           | Created but not started                                 |

---

## ✅ When to Use Which Type?

| Dump Type              | Best Use Case                    |
| ---------------------- | -------------------------------- |
| **Full Thread Dump**   | General debugging, stack traces  |
| **Deadlock Section**   | Detecting thread lock cycles     |
| **Lightweight Dump**   | Quick status checks              |
| **With Monitor Locks** | Lock contention, blocked threads |
| **JFR Thread View**    | Visual analysis, profiling       |
| **Native Thread Dump** | JNI/native crash debugging       |

---

## 📁 Sample Tools to View Thread Dumps

* **VisualVM**
* **Java Mission Control (JMC)**
* **Thread Dump Analyzer** (TDA)
* **FastThread.io** – online analyzer

---


