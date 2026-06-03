# 🚦 Adaptive Sensor-Driven Traffic Light Controller (FSMD)

An industry-style adaptive traffic light controller implemented in Verilog using a **Finite State Machine with Datapath (FSMD)** architecture.

Unlike conventional fixed-timer traffic lights, this design dynamically responds to real-time traffic conditions using an inductive loop sensor embedded in the side street. The controller intelligently allocates green-light time to improve traffic flow, reduce unnecessary waiting, and minimize fuel consumption.

---

# 📋 Features

- FSMD-based architecture (Control Path + Datapath)
- Adaptive traffic control using vehicle detection
- Independent programmable countdown timer
- Safe yellow-light transition intervals
- Early-release optimization support for low traffic conditions
- Clean Moore FSM implementation
- Fully verified through simulation using Icarus Verilog and EPWave

---

# 🏗️ System Architecture

The design is divided into two major blocks:

## 1. Datapath Unit (`down_timer`)

A synchronous 32-bit down-counter responsible for timing all traffic-light intervals.

### Responsibilities

- Loads predefined countdown values
- Counts down once per clock cycle
- Generates a `timer_done` flag when the count reaches zero

### Outputs

| Signal | Description |
|----------|-------------|
| `timer_done` | Asserted when countdown reaches zero |

---

## 2. Control Unit (`traffic_light`)

A Moore Finite State Machine that controls traffic-light sequencing.

### Responsibilities

- Monitors vehicle sensor input (`car`)
- Monitors timer status (`timer_done`)
- Determines state transitions
- Programs timer intervals
- Drives physical traffic-light outputs

---

# 🔌 Input / Output Interface

| Signal | Direction | Description |
|----------|-----------|-------------|
| `clk` | Input | 1 Hz system clock |
| `reset` | Input | Asynchronous active-high reset |
| `car` | Input | Side-street vehicle detection sensor |
| `main_light[2:0]` | Output | Main street traffic light `[R,Y,G]` |
| `side_light[2:0]` | Output | Side street traffic light `[R,Y,G]` |

---

# 🚥 Traffic Light Encoding

| Color | Encoding |
|---------|---------|
| Green | `3'b001` |
| Yellow | `3'b010` |
| Red | `3'b100` |

---

# 🔄 FSM States

## M_GREEN

Main street has priority.

| Signal | Value |
|----------|---------|
| Main Street | Green (`001`) |
| Side Street | Red (`100`) |

### Behavior

- Default operating state
- Remains active while no side-street vehicle is detected
- Transitions to `M_YELLOW` when `car = 1`

---

## M_YELLOW

| Signal | Value |
|----------|---------|
| Main Street | Yellow (`010`) |
| Side Street | Red (`100`) |

### Duration

- Fixed 5-second interval

### Purpose

Provides safe stopping distance before handing control to side traffic.

---

## S_GREEN

| Signal | Value |
|----------|---------|
| Main Street | Red (`100`) |
| Side Street | Green (`001`) |

### Duration

- Maximum: 30 seconds
- Can terminate early if no vehicle remains on the side street

### Optimization

Supports adaptive release when traffic demand disappears before timeout.

---

## S_YELLOW

| Signal | Value |
|----------|---------|
| Main Street | Red (`100`) |
| Side Street | Yellow (`010`) |

### Duration

- Fixed 5-second interval

### Purpose

Safely returns control to the main road.

---

# 📊 State Transition Table

| Current State | Condition | Next State |
|---------------|-----------|------------|
| M_GREEN | `car = 0` | M_GREEN |
| M_GREEN | `car = 1` | M_YELLOW |
| M_YELLOW | `timer_done = 1` | S_GREEN |
| S_GREEN | `car = 1` and timer running | S_GREEN |
| S_GREEN | `car = 0` | S_YELLOW |
| S_GREEN | `timer_done = 1` | S_YELLOW |
| S_YELLOW | `timer_done = 1` | M_GREEN |

---

# 📈 Simulation Waveform

## Verification Result

> Paste waveform screenshot here

<p align="center">
  <img width="1887" height="182" alt="Screenshot 2026-06-04 004600" src="https://github.com/user-attachments/assets/e16b43e2-5978-4a5a-bd8e-77282b03a809" />
</p>

---

# 🔬 Waveform Analysis

## 1. Reset Verification

At startup, `reset` is asserted, forcing the controller into a known safe state:

- Main Street → Green
- Side Street → Red
- Timer cleared to zero

This guarantees deterministic startup behavior.

---

## 2. Vehicle Detection

Around the beginning of the simulation, the `car` sensor transitions high.

The controller responds by:

```
M_GREEN → M_YELLOW
```

confirming successful sensor detection.

---

## 3. Yellow Interval Validation

The waveform shows:

```
main_light = 010
```

during the `M_YELLOW` state.

The state persists for exactly:

- 5 clock cycles
- Corresponding to the programmed 5-second yellow interval

before transitioning to `S_GREEN`.

---

## 4. Side-Street Green Operation

During the side-street service phase:

```
main_light = 100
side_light = 001
```

which correctly represents:

- Main Street → Red
- Side Street → Green

The waveform shows the controller maintaining the green interval while side traffic is present.

---

## 5. Return-to-Main Sequence

After the side-street interval completes:

```
S_GREEN → S_YELLOW → M_GREEN
```

The waveform confirms:

- Proper yellow transition
- Safe handoff
- Successful return to default highway-priority operation

---

# ✅ Functional Verification Summary

| Feature | Status |
|----------|---------|
| Reset Initialization | ✅ Pass |
| Vehicle Detection | ✅ Pass |
| Main Yellow Timing | ✅ Pass |
| Side Green Timing | ✅ Pass |
| State Transitions | ✅ Pass |
| Return to Main Road | ✅ Pass |
| FSMD Operation | ✅ Pass |

---

# 🛠️ Simulation Environment

| Tool | Purpose |
|--------|---------|
| Icarus Verilog | Compilation & Simulation |
| GTKWave / EPWave | Waveform Visualization |

---

# 🚀 Future Improvements

- Multiple lane sensors
- Emergency vehicle priority
- Pedestrian crossing support
- Adaptive timing based on traffic density
- Night-mode flashing operation
- FPGA deployment and hardware testing

---
