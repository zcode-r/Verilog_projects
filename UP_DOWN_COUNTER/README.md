# Parameterized Up/Down Counter (Sequential Logic)

This project implements a flexible N-bit counter in Verilog. It marks the transition from combinational logic to sequential logic, introducing fundamental hardware concepts like clocking, asynchronous resets, and state management.

## Technical Specifications
- **Data Width:** Parameterized (`WIDTH`), defaulting to 4-bit (0-15).
- **Reset Type:** Asynchronous Active-High Reset. The counter returns to 0 immediately when `reset` is high, independent of the clock.
- **Clocking:** Triggered on the Rising Edge (`posedge`) of the clock signal.
- **Assignment Type:** Non-blocking assignments (`<=`) to ensure accurate sequential hardware behavior.

## Features
- **Direction Control:** A toggle signal (`up_down`) determines the count direction:
    - `1`: Increments the count.
    - `0`: Decrements the count.
- **Natural Roll-over:** The counter automatically wraps around (e.g., in 4-bit mode, `1111` increments to `0000`).

## Verification
The design was verified using a Testbench (`tb_updowncounter.v`) on **EDA Playground** with the **Icarus Verilog** simulator.
- **Clock Generation:** A simulated clock with a 10ns period (100MHz) was used to drive the logic.
- **Asynchronous Reset:** Confirmed the counter clears to zero immediately upon reset activation.
- **Waveform Analysis:** Verified counting sequences and direction switching via **EPWave**.
