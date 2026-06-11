# Asynchronous FIFO (Async FIFO) in Verilog

## Overview

This project implements an **Asynchronous FIFO (First-In First-Out)** buffer in Verilog.

Unlike a synchronous FIFO, the write and read operations occur in **different clock domains**:

- Write Side → `clk_w`
- Read Side → `clk_r`

Since the two clocks are independent, special techniques are required to safely transfer status information between clock domains.

This project implements:

- Independent read and write clocks
- Gray-code pointers
- 2-Flip-Flop synchronizers
- Full detection
- Empty detection
- Pointer wraparound handling
- Verification using a custom testbench

---

## Why Async FIFO?

A normal FIFO works with a single clock.

```text
Write ----+
          |
       FIFO
          |
Read -----+
```

An asynchronous FIFO is used when:

```text
Write Clock ≠ Read Clock
```

Example:

```text
UART Receiver  ---> Async FIFO ---> CPU

clk_uart              clk_cpu
```

Since the clocks are unrelated, direct pointer transfer can cause:

- Setup/Hold violations
- Metastability
- Incorrect Full/Empty detection

---

## Key Concepts Used

### 1. Clock Domain Crossing (CDC)

The write and read pointers belong to different clock domains.

```text
Write Domain            Read Domain
-----------             ----------
w_ptr       --------->   Read Logic

r_ptr       <---------   Write Logic
```

Crossing signals between unrelated clocks is called:

**Clock Domain Crossing (CDC)**

---

### 2. Metastability

When a flip-flop samples an asynchronous signal near a clock edge, the output may not immediately resolve to:

```text
0
or
1
```

It can temporarily enter an undefined state called:

**Metastability**

This can cause unpredictable behavior.

---

### 3. Two-Flip-Flop Synchronizer

To reduce metastability risk, Gray pointers are passed through a 2-stage synchronizer.

```text
Async Signal
     |
     v
+-------+
| FF1   |
+-------+
     |
     v
+-------+
| FF2   |
+-------+
     |
     v
Stable Output
```

This provides an additional clock cycle for metastability to settle.

---

### 4. Gray Code

Binary counters can change multiple bits simultaneously.

Example:

```text
Binary

0111
1000
```

Multiple bits change at once.

If sampled during transition, the receiver may see an invalid value.

Gray code solves this.

```text
Only ONE bit changes at a time.
```

Conversion:

```verilog
gray = binary ^ (binary >> 1);
```

---

## FIFO Architecture

```text
                 WRITE DOMAIN

            Binary Write Pointer
                       |
                       v
                 Gray Write Pointer
                       |
                       v
                2FF Synchronizer
                       |
                       |
                       v

=================================================

                       ^
                       |
                2FF Synchronizer
                       |
                       v
                 Gray Read Pointer
                       |
                       v
            Binary Read Pointer

                  READ DOMAIN
```

---

## Pointer Structure

The FIFO uses an extra pointer bit.

For DEPTH = 8:

```text
Address Bits = 3

Pointer Width = 4
```

Example:

```text
0_101
1_101
```

The extra MSB helps distinguish:

```text
EMPTY
vs
FULL
```

when address bits become equal.

---

## Empty Detection

FIFO is empty when:

```text
Synchronized Write Pointer
        ==
Current Read Pointer
```

```verilog
assign empty = (w_2ffs == r_gray);
```

---

## Full Detection

FIFO is full when:

```text
Address bits match

AND

Upper two Gray bits are inverted
```

```verilog
assign full =
    (w_gray[BITS]   != r_2ffs[BITS]) &&
    (w_gray[BITS-1] != r_2ffs[BITS-1]) &&
    (w_gray[BITS-2:0] == r_2ffs[BITS-2:0]);
```

---

## Features

- Independent read/write clocks
- Gray code pointer synchronization
- 2FF synchronizers
- Full flag generation
- Empty flag generation
- Pointer wraparound support
- Configurable width and depth

---

## Parameters

```verilog
parameter DEPTH = 8;
parameter WIDTH = 8;
```

Example:

```verilog
async_fifo #(
    .DEPTH(16),
    .WIDTH(32)
)
```

---

## Testbench Coverage

The testbench verifies:

### Reset

Checks proper initialization.

### Full Condition

Writes more data than FIFO depth.

Expected:

```text
FULL = 1
```

---

### Empty Condition

Reads all available data.

Expected:

```text
EMPTY = 1
```

---

### Pointer Wraparound

Verifies correct behavior when pointers wrap.

Example:

```text
Write
Read
Write Again
Read Again
```

---

### Different Clock Rates

Write clock and read clock operate at different frequencies.

Example:

```verilog
clk_w : 10ns
clk_r : 24ns
```

This validates CDC functionality.

---

### FIFO Ordering

Verifies:

```text
First In
First Out
```

Example:

```text
Write:
1 2 3 4 5

Read:
1 2 3 4 5
```

---

## Simulation Result

Verified:

- Correct FIFO ordering
- Proper Full detection
- Proper Empty detection
- Correct pointer wraparound
- Correct operation with independent clocks
- Successful Gray-code synchronization

---

## Limitations

This project is intended for learning and verification purposes.

Current implementation:

- Uses register-array memory
- Uses combinational Full/Empty flags

Production-grade FIFOs often include:

- Dual-port RAM
- Registered status flags
- Formal verification
- Advanced CDC verification

---

## What I Learned

Through this project:

- Setup Time
- Hold Time
- Clock Domain Crossing (CDC)
- Metastability
- 2-Flip-Flop Synchronizers
- Gray Code
- Full/Empty Detection Logic
- Pointer Synchronization
- Asynchronous FIFO Design

---

## Future Improvements

- Registered Full/Empty flags
- Dual-Port RAM implementation
- Parameterized almost-full flag
- Parameterized almost-empty flag
- SystemVerilog assertions
- Formal verification

---

## Author

Built as part of a Verilog RTL Design and Digital Design learning journey focused on:

```text
FIFO
→ Timing Analysis
→ CDC
→ Synchronizers
→ Gray Code
→ Asynchronous FIFO
→ UART
→ Advanced RTL Projects
```
