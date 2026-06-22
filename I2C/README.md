# I2C Master-Slave Communication in Verilog

## Overview

This project implements a simplified **I2C (Inter-Integrated Circuit) communication protocol** in Verilog.

The design includes:

* I2C Master
* I2C Slave
* Bidirectional SDA line using tri-state logic
* Start and Stop condition generation/detection
* Address transmission and reception
* Read and Write operations
* ACK/NACK handling
* Self-checking testbench

The project was simulated and verified using Verilog simulation tools and waveform analysis.

---

## Features

### Master

* Generates START condition
* Generates STOP condition
* Sends 7-bit slave address
* Sends Read/Write bit
* Waits for ACK from slave
* Writes data to slave
* Reads data from slave
* Handles protocol errors

### Slave

* Detects START condition
* Detects STOP condition
* Receives slave address
* Compares received address with configured slave ID
* Generates ACK when address matches
* Receives data from master
* Sends data to master during read transactions

### Bus

* Open-drain style SDA implementation
* Tri-state control

```verilog
assign sda = (sda_en) ? sda_out : 1'bz;
```

---

## Project Structure

```text
.
├── i2c_top.v
├── i2c_master.v
├── i2c_slave.v
├── i2c_tb.v
└── README.md
```

---

## I2C Transaction Flow

### Write Transaction

```text
Master
  |
  | START
  |
  | Address + Write Bit
  |
  | Slave ACK
  |
  | Data Byte
  |
  | Slave ACK
  |
  | STOP
```

Example:

```text
Address = 0x2A
Data    = 0xD4
```

Result:

```text
Slave Received = 0xD4
```

---

### Read Transaction

```text
Master
  |
  | START
  |
  | Address + Read Bit
  |
  | Slave ACK
  |
  | Slave sends Data
  |
  | Master receives Data
  |
  | STOP
```

Example:

```text
Slave Data = 0xA5
```

Result:

```text
Master Received = 0xA5
```

---

## State Machines

### Master FSM

```text
IDLE
 ↓
START
 ↓
SLAVE_ADDR
 ↓
RW_BIT
 ↓
ACK_ADDR
 ↓
DATA
 ↓
ACK_DATA
 ↓
STOP
 ↓
IDLE
```

### Slave FSM

```text
IDLE
 ↓
SLAVE_ADDR
 ↓
RW_BIT
 ↓
ACK_ADDR
 ↓
DATA
 ↓
ACK_DATA
 ↓
IDLE
```

---

## Verification

A self-checking testbench was developed to verify both write and read operations.

### Write Test

```text
Master Transmitted : 0xD4
Slave Received     : 0xD4

STATUS : PASS
```

### Read Test

```text
Slave Transmitted  : 0xA5
Master Received    : 0xA5

STATUS : PASS
```

---

## Sample Simulation Output

```text
=== STARTING I2C WRITE TRANSACTION ===

Master Transmitted : 0xD4
Slave Received     : 0xD4

STATUS : SUCCESS

=== STARTING I2C READ TRANSACTION ===

Slave Transmitted  : 0xA5
Master Received    : 0xA5

STATUS : SUCCESS
```

---

## Concepts Practiced

* Finite State Machines (FSM)
* Serial Communication Protocols
* I2C Protocol Basics
* Bidirectional Buses
* Tri-State Buffers
* Read/Write Transactions
* Protocol Verification
* Self-Checking Testbenches
* RTL Design in Verilog

---

## Future Improvements

* Repeated START support
* Multiple slave support
* Clock stretching
* Multi-byte transfers
* Parameterized clock generation
* NACK handling improvements
* SystemVerilog assertions
* UVM-based verification

---
