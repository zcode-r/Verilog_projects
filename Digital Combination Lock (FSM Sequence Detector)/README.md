# Digital Combination Lock (FSM Sequence Detector)

This project implements a secure, 3-digit digital combination lock controlled by an industrial-standard **Moore Finite State Machine (FSM)** in Verilog. It represents a major leap into control-path hardware design, demonstrating how synchronous sequential logic can be used to process multi-bit input sequences and make autonomous state decisions.

## Technical Specifications
- **Target Combination:** `2` $\rightarrow$ `3` $\rightarrow$ `5` (Processed as 4-bit binary codes: `4'b0010` $\rightarrow$ `4'b0011` $\rightarrow$ `4'b0101`).
- **FSM Architecture:** Moore Machine (The `unlock` output depends strictly on the current state register).
- **Design Style:** Two-Process Style (Separated clock-driven sequential memory block and pure combinational next-state evaluation logic).
- **Control Pins:**
  - `key[3:0]`: 4-bit input bus capturing the binary value of the pressed button.
  - `keypressed`: 1-bit validation strobe signal indicating active keypad entry.
  - `unlock`: 1-bit system output ($1 = \text{Unlocked}$, $0 = \text{Secure}$).

---

## FSM Architecture & State Table
The internal controller keeps track of code history by managing 4 distinct binary state allocations:
- `idle` (`2'b00`): Default secure state. Waiting for first valid key (`2`).
- `got_2` (`2'b01`): Successfully registered the first digit. Decoder checks for `3`.
- `got_23` (`2'b10`): Successfully registered the first two digits. Decoder checks for `5`.
- `got_235` (`2'b11`): Sequence fully authenticated. System drives `unlock` output High.

### State Transition Truth Table

| Present State | Input Key (`key`) | `keypressed` | Next State | Output (`unlock`) |
| :---: | :---: | :---: | :---: | :---: |
| **`idle`** | `4'd2` | `1` | **`got_2`** | `0` (Locked) |
| **`idle`** | Any other key | `1` | **`idle`** | `0` (Locked) |
| **`got_2`** | `4'd3` | `1` | **`got_23`** | `0` (Locked) |
| **`got_2`** | Any other key | `1` | **`idle`** | `0` (Locked) |
| **`got_23`** | `4'd5` | `1` | **`got_235`** | `0` (Locked) |
| **`got_23`** | Any other key | `1` | **`idle`** | `0` (Locked) |
| **`got_235`**| Any Key | `1` | **`idle`** | `1` (Unlocked) |

If an incorrect key is hit at any point in the chain, the FSM instantly executes an error recovery step, overriding history registers and booting the tracker completely back to the `idle` base state.

---

## Verification & Simulation Analysis
The structural control logic was fully simulated and verified using a custom testbench file via the **Icarus Verilog** compiler tools on **EDA Playground**. 

### Behavioral Waveform Verification (EPWave Analysis):
- **Intruder Attempt Rejection:** A simulated sequence of `2 -> 3 -> 9` was injected. Waveform logs confirm that the moment the invalid `9` (`4'b1001`) was evaluated, the internal state vector skipped the unlock phase entirely and fell straight back to `idle`. The `unlock` flag remained cleanly at `0`.
- **Successful Authentication:** A valid sequence of `2 -> 3 -> 5` was fed into the module on consecutive clock strobe edges. At the exact edge where `5` (`4'b0101`) was sampled, the `unlock` wave immediately transitioned from `0` to a constant steady `1`, opening the mechanism.
- **Relocking Security Loop:** Tapping a subsequent key value once inside the unlocked configuration cleanly cleared the state registers and lowered the `unlock` drive line back to a safe zero state.
