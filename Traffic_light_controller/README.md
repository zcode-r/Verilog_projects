# 🚦 Adaptive Sensor-Driven Traffic Light Controller (FSMD)

An adaptive traffic light controller implemented in Verilog using a **Finite State Machine with Datapath (FSMD)** architecture. Unlike traditional fixed-time traffic lights, this design responds dynamically to real-time traffic conditions using a side-street vehicle sensor, allowing more efficient traffic flow and reduced waiting times.

The controller is divided into two major components:

* **Datapath Unit (`down_timer`)** – A programmable countdown timer used to generate traffic-light intervals.
* **Control Unit (`traffic_light`)** – A Moore Finite State Machine (FSM) that monitors sensor inputs, manages state transitions, and controls the traffic lights.

---

# 📋 Features

* FSMD-based architecture
* Moore FSM implementation
* Vehicle sensor-based adaptive control
* Programmable countdown timer
* Safe yellow-light transition periods
* Early-release optimization for side-street traffic
* Modular and synthesizable Verilog design
* Functional verification using simulation waveforms

---

# 🏗️ System Architecture

## 1. Datapath Unit (`down_timer`)

The datapath consists of a 32-bit synchronous down-counter responsible for generating timing intervals used by the controller.

### Responsibilities

* Load programmable countdown values
* Count down on each clock cycle
* Assert a completion signal when the timer reaches zero

### Signals

| Signal       | Description                    |
| ------------ | ------------------------------ |
| `load_en`    | Loads a new countdown value    |
| `load_val`   | Timer preload value            |
| `timer_done` | Indicates countdown completion |

---

## 2. Control Unit (`traffic_light`)

The control unit is implemented as a **Moore FSM**, meaning outputs depend only on the current state and not directly on sensor inputs.

### Responsibilities

* Monitor side-street vehicle sensor (`car`)
* Monitor timer completion signal (`timer_done`)
* Determine state transitions
* Program timer intervals
* Control traffic-light outputs

---

# 🔌 Input / Output Interface

| Signal            | Direction | Description                              |
| ----------------- | --------- | ---------------------------------------- |
| `clk`             | Input     | System clock                             |
| `reset`           | Input     | Asynchronous active-high reset           |
| `car`             | Input     | Side-street vehicle detection sensor     |
| `main_light[2:0]` | Output    | Main street light `[Red, Yellow, Green]` |
| `side_light[2:0]` | Output    | Side street light `[Red, Yellow, Green]` |

---

# 🚥 Traffic Light Encoding

| Color  | Encoding |
| ------ | -------- |
| Red    | `3'b100` |
| Yellow | `3'b010` |
| Green  | `3'b001` |

---

# 🔄 FSM States

## M_GREEN

**Main Street: Green**
**Side Street: Red**

| Output      | Value |
| ----------- | ----- |
| Main Street | `001` |
| Side Street | `100` |

### Behavior

* Default operating state
* Main road receives priority
* Waits for a vehicle to be detected on the side street

---

## M_YELLOW

**Main Street: Yellow**
**Side Street: Red**

| Output      | Value |
| ----------- | ----- |
| Main Street | `010` |
| Side Street | `100` |

### Duration

* 5 clock cycles

### Purpose

Provides a safe transition period before granting right-of-way to the side street.

---

## S_GREEN

**Main Street: Red**
**Side Street: Green**

| Output      | Value |
| ----------- | ----- |
| Main Street | `100` |
| Side Street | `001` |

### Duration

* Maximum: 30 clock cycles

### Optimization

If the side street becomes empty before the timer expires, the controller can terminate the green phase early and proceed to the yellow transition.

---

## S_YELLOW

**Main Street: Red**
**Side Street: Yellow**

| Output      | Value |
| ----------- | ----- |
| Main Street | `100` |
| Side Street | `010` |

### Duration

* 5 clock cycles

### Purpose

Provides a safe transition before returning control to the main road.

---

# 📊 State Transition Table

| Current State | Condition                  | Next State |
| ------------- | -------------------------- | ---------- |
| M_GREEN       | `car = 0`                  | M_GREEN    |
| M_GREEN       | `car = 1`                  | M_YELLOW   |
| M_YELLOW      | `timer_done = 1`           | S_GREEN    |
| S_GREEN       | `car = 1` and timer active | S_GREEN    |
| S_GREEN       | `car = 0`                  | S_YELLOW   |
| S_GREEN       | `timer_done = 1`           | S_YELLOW   |
| S_YELLOW      | `timer_done = 1`           | M_GREEN    |

---
# 📈 Simulation Waveform

> Paste simulation waveform screenshot here

<p align="center">
   <img width="1887" height="182" alt="Screenshot 2026-06-04 004600" src="https://github.com/user-attachments/assets/e16b43e2-5978-4a5a-bd8e-77282b03a809" />
</p>

---

# 🔬 Waveform Analysis

## 1. Reset Verification

At startup, the reset signal is asserted, forcing the controller into a known safe state:

* Main Street → Green
* Side Street → Red
* Timer cleared

This ensures deterministic startup behavior.

---

## 2. Vehicle Detection

The side-street vehicle sensor (`car`) transitions high during simulation.

On the next clock edge, the controller detects the request and transitions from:

```
M_GREEN → M_YELLOW
```

demonstrating proper sensor responsiveness.

---

## 3. Yellow-Light Timing Verification

The waveform shows:

```
main_light = 010
```

during the `M_YELLOW` state.

The controller remains in this state for exactly five clock cycles before transitioning to `S_GREEN`, validating the programmed yellow-light interval.

---

## 4. Side-Street Service Verification

During the side-street service phase:

```
main_light = 100
side_light = 001
```

which corresponds to:

* Main Street → Red
* Side Street → Green

The waveform confirms that the FSM correctly grants right-of-way to side-street traffic while maintaining safe control of the main road.

---

## 5. Return-to-Main Sequence

After the side-street interval completes, the controller transitions through:

```
S_GREEN → S_YELLOW → M_GREEN
```

The waveform confirms:

* Proper yellow-light transition
* Safe handoff between roads
* Successful return to the default highway-priority state

---

# ✅ Verification Summary

| Test Case            | Result |
| -------------------- | ------ |
| Reset Initialization | ✅ Pass |
| Vehicle Detection    | ✅ Pass |
| Main Yellow Timing   | ✅ Pass |
| Side Green Timing    | ✅ Pass |
| State Transitions    | ✅ Pass |
| Return to Main Road  | ✅ Pass |
| Moore FSM Operation  | ✅ Pass |

---

# 🛠️ Simulation Environment

| Tool             | Purpose                  |
| ---------------- | ------------------------ |
| Icarus Verilog   | Compilation & Simulation |
| EPWave / GTKWave | Waveform Visualization   |

---

# 🚀 Future Improvements

* Multiple traffic sensors
* Traffic density estimation
* Emergency vehicle priority
* Pedestrian crossing support
* Night-mode flashing operation
* FPGA deployment and hardware validation

---
