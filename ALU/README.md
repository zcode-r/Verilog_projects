# 8-Bit Parameterized ALU (Combinational Logic)

This is a Verilog implementation of an Arithmetic Logic Unit (ALU). It is the first project in my VLSI journey, focusing on combinational logic and data path design.

## Technical Specifications
- **Data Width:** 8-bit inputs (A and B).
- **Control:** 3-bit selection signal (ALU_Sel).
- **Output:** 16-bit wide to prevent overflow during multiplication.
- **Assignment Type:** Blocking assignments (`=`) as this is combinational logic.

## Supported Operations
The ALU performs 8 distinct operations based on the 3-bit `ALU_Sel` input:
- `000`: Addition
- `001`: Subtraction
- `010`: Multiplication (Full 16-bit result)
- `011`: Bitwise AND
- `100`: Bitwise OR
- `101`: Bitwise XOR
- `110`: Logical Left Shift
- `111`: Logical Right Shift

## Verification
The design was verified using a Testbench (`tb_ALU.v`) with the **Icarus Verilog** simulator.
- **Test Cases:** Addition, Subtraction, and Multiplication were verified via `$display` tasks.
- **Simulation Tool:** EDA Playground.
