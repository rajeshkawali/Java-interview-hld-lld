**Garbage Collection (GC)** in Java – what it is, how it works, and all the major types including new ones like **ZGC** and **Shenandoah**.

---

## 🧠 What is Garbage Collection?

In Java, **Garbage Collection** is the process of **automatically identifying and reclaiming memory** that is no longer reachable by any part of the application.

✅ Benefits:

* Prevents memory leaks.
* Eliminates the need for manual memory management (unlike C/C++).
* Increases developer productivity and reduces bugs.

---

## 🧱 Java Memory Structure (simplified view)

Understanding GC types requires some familiarity with the Java memory model:

### **Heap Memory (where GC operates)**

* **Young Generation (Young Gen):**

  * **Eden**: newly created objects.
  * **Survivor**: two spaces (S0 & S1) that hold recently survived objects.
* **Old Generation (Tenured):**

  * Long-living objects.
* **Metaspace:**

  * Class metadata (replaced PermGen in Java 8).

---

## ♻️ Phases of GC

1. **Mark:** Find all reachable objects.
2. **Sweep:** Reclaim memory occupied by unreachable ones.
3. **Compact:** Rearranges memory to avoid fragmentation.
4. **Promotion:** Moves surviving young-gen objects to old-gen.

---

## 🚀 Types of Garbage Collectors in Java

### 1. **Serial GC (Single-threaded)**

* **JVM Option:** `-XX:+UseSerialGC`
* **Best for:** Small applications or single-core machines.
* **How it works:**

  * Uses a single thread for GC.
  * Freezes the application (Stop-The-World pause) during GC.
* **Drawback:** Long pause times for large heaps.

---

### 2. **Parallel GC (Throughput Collector)**

* **JVM Option:** `-XX:+UseParallelGC` (default in Java 8)
* **Best for:** Applications focused on **high throughput**, batch processing.
* **How it works:**

  * Multiple threads for GC.
  * Still Stop-The-World, but shorter due to parallelism.

✅ Focuses on **minimizing total GC time** rather than pause duration.

---

### 3. **CMS (Concurrent Mark-Sweep) GC** *(Deprecated since Java 9, removed in 14)*

* **JVM Option:** `-XX:+UseConcMarkSweepGC`
* **Best for:** Low-latency apps (like GUIs or web servers).
* **How it works:**

  * Performs most GC work concurrently with the application.
  * **Drawback:** Can cause fragmentation and occasional long full GCs.

📛 CMS has been **replaced by G1GC**.

---

### 4. **G1 (Garbage-First) GC**

* **JVM Option:** `-XX:+UseG1GC` (default since Java 9)
* **Best for:** Large heaps with low pause requirements.
* **How it works:**

  * Divides heap into regions.
  * Uses concurrent and parallel phases.
  * Collects regions with the most garbage first.
* **Advantages:**

  * Predictable pause times (`-XX:MaxGCPauseMillis`)
  * Concurrent old-gen collection.
* **Drawback:** Slightly more CPU usage than ParallelGC.

---

### 5. **ZGC (Z Garbage Collector)**

* **JVM Option:** `-XX:+UseZGC` *(Java 11+)*
* **Best for:** Applications with very large heaps (multi-GB to TB scale) and **ultra-low pause requirements**.
* **Pause time:** < 10ms (even for large heaps!)
* **How it works:**

  * Region-based.
  * Uses colored pointers for concurrent GC without stopping the world.
* **Supported on:** Linux, Windows, macOS, starting from Java 15.

✅ ZGC is **concurrent, region-based, compacting, low-latency**.

---

### 6. **Shenandoah GC**

* **JVM Option:** `-XX:+UseShenandoahGC` *(Java 12+, production-ready in Java 15)*
* **Best for:** Low-pause, large heap applications.
* **Pause time:** A few milliseconds.
* **How it works:**

  * Concurrent compacting GC — moves objects concurrently with application running.
  * No Stop-The-World compaction.
* **Difference from ZGC:**

  * ZGC uses colored pointers; Shenandoah uses **load barriers**.

---

### 7. **Epsilon GC (No-Op GC)**

* **JVM Option:** `-XX:+UseEpsilonGC`
* **Best for:** Performance testing or short-lived microservices.
* **How it works:**

  * Allocates memory but **never reclaims** it.
  * Crashes when heap is full.
* ✅ Used to test application memory behavior **without GC interference**.

---

## 🆚 Comparison Table

| GC Type    | Pause Time        | Concurrent? | Heap Size Target | Use Case                                   |
| ---------- | ----------------- | ----------- | ---------------- | ------------------------------------------ |
| Serial     | High              | ❌           | Small (<2GB)     | Single-threaded, embedded apps             |
| Parallel   | Medium            | ❌           | Medium–Large     | Batch jobs, CPU-heavy apps                 |
| CMS        | Low               | ✅           | Medium–Large     | Low-pause legacy apps (deprecated)         |
| G1         | Low (predictable) | ✅           | Large heaps      | Web apps, servers                          |
| ZGC        | Ultra Low (<10ms) | ✅           | Huge (up to TBs) | Real-time, big-data, low-latency systems   |
| Shenandoah | Ultra Low         | ✅           | Large heaps      | Interactive UIs, latency-sensitive systems |
| Epsilon    | None (no GC)      | ❌           | Small–Medium     | Benchmarks, memory stress testing          |

---

## ⚙️ Tuning GC

Common JVM flags:

```bash
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+PrintGCDetails
-Xms512m -Xmx2g
```

To monitor GC:

* Use `jstat`, `jconsole`, `VisualVM`, or **Java Flight Recorder**.
* Add logging with `-Xlog:gc` (Java 9+).

---

## 📌 Summary

| GC         | Type                              | Highlights                         |
| ---------- | --------------------------------- | ---------------------------------- |
| Serial     | Stop-the-world                    | Simple, low memory                 |
| Parallel   | Stop-the-world (parallel threads) | High throughput                    |
| CMS        | Mostly concurrent                 | Low-pause, deprecated              |
| G1         | Concurrent, region-based          | Default GC in Java 9+, predictable |
| ZGC        | Fully concurrent                  | Scales to 16 TB+, ultra-low pause  |
| Shenandoah | Fully concurrent, compacting      | Good for pause-sensitive           |
| Epsilon    | No GC                             | Used for benchmarking              |

---


