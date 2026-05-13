# Parameterized Clock Divider (Frequency Scaler)

This project implements a Clock Divider in Verilog. It demonstrates how to use sequential logic and counters to scale down a high-frequency input clock (e.g., 100MHz) to a lower target frequency (e.g., 1Hz or 10MHz). This is a fundamental building block for Baud Rate Generators and time-keeping circuits.

## Technical Specifications
- **Input Clock:** High-frequency reference signal (`clk_in`).
- **Output Clock:** Scaled-down square wave signal (`clk_out`).
- **Parameter (`DIV`):** A configurable divisor that determines the frequency scaling factor.
- **Counter Width:** 32-bit register to support high division ratios (up to 4.2 billion).
- **Reset Logic:** Asynchronous Active-High Reset to initialize the counter and output state.

## How it Works
The module uses an internal counter to track the number of rising edges on the input clock. 
- For a given divisor `N`, the output signal is toggled every `N/2` input cycles.
- This results in a 50% duty cycle output (the signal is HIGH for half the duration and LOW for the other half).
- **Example:** If `DIV = 10`, the output frequency will be exactly 1/10th of the input frequency.

## Verification
The design was verified using a Testbench (`tb_clock_divider.v`) on **EDA Playground**.
- **Test Scenario:** A 500MHz input clock (#1 delay) was scaled down by a factor of 10.
- **Waveform Analysis:** Observed that for every 10 pulses of `clk_in`, `clk_out` completes exactly one full cycle.
- **Reset Test:** Verified that the clock output remains at 0 while the reset signal is active.
