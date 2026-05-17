# 2-Digit Time-Multiplexed Stopwatch (Hierarchical & Multiplexed Logic)

This project implements a 2-digit digital stopwatch in Verilog capable of counting from `00` to `99`. It demonstrates critical advanced hardware design concepts, specifically **hierarchical module instantiation**, **nested sequential tracking**, and **high-speed time-multiplexing (display sharing)** to optimize chip pin count and power consumption.

## Technical Specifications
- **Display Type:** 2-Digit 7-Segment Display (Common Cathode/Anode model).
- **Data Buses:** - `seg[6:0]`: Shared 7-bit bus representing segment segments `[g, f, e, d, c, b, a]`.
  - `digital_sel[1:0]`: 2-bit digit select control bus acting as active-high display power switches.
- **Clock Domains:** Dual-clock design featuring a divided 1Hz clock for counting logic and a raw high-speed clock (`fast_clk`) for display refresh tracking.
- **Target Simulator:** Icarus Verilog via EDA Playground.

## Architecture & Hierarchical Structure
The system architecture follows a modular, top-down structural design approach, utilizing four interconnected modules:

1. **`clk_div` (Clock Divider):** Down-scales a high-frequency master clock to a precise 1Hz heartbeat using a parameterized counter tracking system.
2. **`counter` (Dual-Digit BCD Counter):** Houses nested sequential logic acting like an odometer. The Tens place increments *only* when the Ones place hits `4'd9` and rolls over to `4'd0`.
3. **`seven_seg_dis` (Combinational Decoder):** A pure combinational block that translates a 4-bit binary value into the corresponding 7-bit pattern needed to illuminate an LED digit panel.
4. **`stop_watch` (Top Module / Main Board):** Establishes the physical wiring connections, declares the routing `wire` segments, and contains the multiplexing logic blocks.

---

## The Multiplexing Illusion (How it Works)
To drastically optimize resource usage, this design implements **Time-Division Multiplexing**. Instead of running 14 separate wires to drive two distinct 7-segment digits, both digits completely share the exact same 7-bit segment bus (`seg`). 

The chip alternates active display data at microsecond intervals using a high-speed `refresh_bit` driven by the raw clock:

- **When `refresh_bit == 0`:** The system sends the `w_ones` value to the decoder and sets `digital_sel = 2'b01` (powering ONLY the right-side digit).
- **When `refresh_bit == 1`:** The system sends the `w_tens` value to the decoder and sets `digital_sel = 2'b10` (powering ONLY the left-side digit).

Because this alternation occurs millions of times per second, human *Persistence of Vision* blends the flashes together, creating a perfectly steady display illusion of two distinct digits glowing simultaneously.

---

## Verification & Waveform Analysis
The entire design hierarchy was simulated and validated using a dedicated testbench (`stop_watch_tb`) on **EDA Playground** running the **Icarus Verilog** compiler.

### Simulation Highlights:
- **Fast Parameter Mockup:** To optimize verification runtime without crashing web browsers, the simulation division factor was set to `div=10`. This allows a condensed view of functional rollover behaviors.
- **Signal Tracking:** Successfully captured synchronous tracking between the data line and display activation vectors.
- **Waveform Evaluation:**
  - Verified that `digital_sel[1:0]` rapidly oscillates between state `1` (`2'b01`) and state `2` (`2'b10`).
  - Confirmed that inside a counting window, the value on the shared `seg[6:0]` bus alternates sequentially between the matching active Ones and Tens place parameters (e.g., oscillating between Hex `6` for "1" and Hex `3f` for "0" to smoothly output a combined display readout of `01`).
  - Validated clean wrap-around tracking when reset conditions switch from assert to deassert states.
