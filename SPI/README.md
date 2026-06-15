# SPI Master-Slave Communication Protocol in Verilog

## Overview

This project implements a simple **SPI (Serial Peripheral Interface)** communication system in Verilog.

The design consists of:

- 1 SPI Master
- 3 SPI Slaves
- Configurable data width
- Slave selection using Slave Select (SS)
- Full-duplex communication
- Verification using a custom testbench

The master can communicate with any one of the three slaves by selecting the appropriate Slave Select line.

---

## SPI Basics

SPI is a synchronous serial communication protocol commonly used to communicate with:

- Sensors
- ADCs/DACs
- EEPROMs
- Flash Memories
- Microcontrollers
- FPGA peripherals

SPI uses four signals:

| Signal | Direction | Description |
|----------|----------|-------------|
| SCLK | Master → Slave | Serial Clock |
| MOSI | Master → Slave | Master Out Slave In |
| MISO | Slave → Master | Master In Slave Out |
| SS | Master → Slave | Slave Select (Active Low) |

---

## SPI Architecture

```text
                    +----------------+
                    |   SPI Master   |
                    +----------------+
                     |    |    |   |
                     |    |    |   |
                   SCLK MOSI MISO SS
                     |    |    |   |
                     |    |    |   |
        -----------------------------------------
          |               |                |
          |               |                |
      +--------+      +--------+      +--------+
      |Slave 0 |      |Slave 1 |      |Slave 2 |
      +--------+      +--------+      +--------+
```

Only the selected slave drives the MISO line.

All unselected slaves place MISO in high-impedance (`Z`) state.

---

## Features

- Parameterized data width
- Multiple slave support
- Full-duplex communication
- Master controlled clock generation
- Slave Select based slave targeting
- Shift-register based transmission
- Shift-register based reception
- Custom verification testbench

---

## Design Modules

### Top Module (`spi`)

The top-level module instantiates:

- SPI Master
- Slave 0
- Slave 1
- Slave 2

It also connects:

```text
Master
  |
  +-- SCLK
  +-- MOSI
  +-- MISO
  +-- SS
  |
Slaves
```

---

### SPI Master (`spi_master`)

The master is responsible for:

- Generating SPI clock
- Selecting slave
- Sending transmit data
- Receiving slave response
- Managing communication state machine

---

### Master FSM

The master uses four states:

```text
IDLE
  ↓
START
  ↓
TRANSFER
  ↓
STOP
  ↓
IDLE
```

---

#### IDLE

```text
Waiting for start signal
Ready = 1
```

---

#### START

```text
Load first MOSI bit
Activate Slave Select
```

---

#### TRANSFER

```text
Generate SPI clock
Shift TX data out
Shift RX data in
```

Communication continues until all bits are transferred.

---

#### STOP

```text
Store received data
Deactivate Slave Select
Return to IDLE
```

---

### SPI Slave (`spi_slave`)

Each slave contains:

- Transmit shift register
- Receive shift register
- Bit counter
- MISO driver

The selected slave:

```text
Loads TX data
Shifts data onto MISO
Receives data from MOSI
```

---

## Data Transfer

SPI is a full-duplex protocol.

During every clock cycle:

```text
Master Transmits 1 Bit
Slave Receives 1 Bit

Slave Transmits 1 Bit
Master Receives 1 Bit
```

Example:

```text
Master TX = D5h
Slave TX  = 39h
```

After transfer:

```text
Master RX = 39h
Slave RX  = D5h
```

---

## Slave Selection

The master selects one slave at a time.

### Slave 0

```verilog
ss = 3'b110;
```

---

### Slave 1

```verilog
ss = 3'b101;
```

---

### Slave 2

```verilog
ss = 3'b011;
```

---

### No Slave Selected

```verilog
ss = 3'b111;
```

---

## Verification

A custom testbench was developed to verify:

- Correct slave selection
- MOSI transmission
- MISO transmission
- Master reception
- Slave reception
- FSM transitions
- Multiple transaction support

---

## Test Case 1

### Inputs

```text
Target Slave : Slave 1
Master TX    : 0xD5
Slave1 TX    : 0x39
```

### Expected Results

```text
Master RX = 0x39
Slave RX  = 0xD5
```

### Simulation Result

```text
PASS
```

---

## Test Case 2

### Inputs

```text
Target Slave : Slave 2
Master TX    : 0xAA
Slave2 TX    : 0x55
```

### Expected Results

```text
Master RX = 0x55
Slave RX  = 0xAA
```

### Simulation Result

```text
PASS
```

---

## Simulation Results

Verified:

- Slave 1 communication
- Slave 2 communication
- Full-duplex operation
- Correct data shifting
- Correct slave selection
- Correct master reception
- Correct slave reception

Example waveform observations:

```text
Master TX : D5
Slave RX  : D5

Slave TX  : 39
Master RX : 39
```

```text
Master TX : AA
Slave RX  : AA

Slave TX  : 55
Master RX : 55
```

---

## Debugging & Learning Outcomes

During development, several protocol-level issues were identified and fixed:

### Slave TX Loading Issue

Initially the slave transmit register was loaded when:

```text
SS ↑
```

This caused the slave to transmit invalid data.

The design was corrected by loading transmit data when:

```text
SS ↓
```

which matches actual SPI transaction behavior.

---

### Receive Data Visibility

The slave receive data was initially cleared whenever the slave was deselected.

This prevented correct observation of received data during verification.

The receive register handling was updated to preserve the received value after transaction completion.

---

## Parameters

```verilog
parameter WIDTH = 8;
```

The design can be configured for different SPI word sizes.

Example:

```verilog
spi #(
    .WIDTH(16)
)
```

---

## Future Improvements

- Support SPI Modes 0/1/2/3
- Configurable clock divider
- Burst transfers
- Multiple-byte transactions
- FIFO integration
- Interrupt generation
- SystemVerilog assertions
- Formal verification

---

## Concepts Learned

Through this project:

- SPI Protocol
- Full-Duplex Communication
- Finite State Machines (FSM)
- Shift Registers
- Clock Generation
- Slave Selection Logic
- Multi-module RTL Design
- Protocol Debugging using Waveforms
- Verilog Verification

---
