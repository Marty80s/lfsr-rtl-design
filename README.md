# Programmable LFSR RTL Design

A Verilog prototype for exploring **Fibonacci and Galois linear-feedback shift registers (LFSRs)**, runtime tap programming, seed loading, and ASIC synthesis. The repository also includes an independent two-flip-flop `100` sequence recognizer.

LFSRs generate deterministic bit sequences using a shift register and XOR feedback. They are useful building blocks for pattern generation, scrambling, and hardware test experiments. These implementations are educational prototypes, not cryptographic random-number generators.

## Contents

- [Design variants](#design-variants)
- [How the logic works](#how-the-logic-works)
- [Run simulations](#run-simulations)
- [Synthesize with Cadence Genus](#synthesize-with-cadence-genus)
- [Repository layout](#repository-layout)
- [Limitations and validation](#limitations-and-validation)

## Design variants

Each LFSR source declares the same module name, `programmable_lfsr`. **Compile exactly one variant at a time.** The Makefile selects the correct source and testbench pair.

| Variant | Default width | Feedback and configuration | Testbench |
| --- | ---: | --- | --- |
| `fibonacci` | 3 | XOR reduction of state bits selected by live `tap_in`; seed sampled during reset | `tb/tb_fibonacci.v` |
| `galois` | 3 | Old LSB enters MSB and conditionally XORs into lower stages; live `tap_in` | `tb/tb_galois.v` |
| `runtime` | 3 | Registered XOR mask with `tap_we`; explicit `seed_we` | `tb/tb_runtime.v` |
| `locked` | 8 | Fibonacci feedback with taps locked after the first enabled edge | Not supplied |
| Sequence recognizer | 2 state bits | Standalone `recognizer_100` module | Not supplied |

Use `N >= 2` for these LFSR implementations. The slices used in the sources do not support the single-bit case.

## How the logic works

All LFSRs shift right and expose `state[0]` as `out_bit`. When `en` is low, the state holds unless a seed load is available and asserted. LFSR reset is asynchronous and active low (`rst_n`).

### Fibonacci feedback

The Fibonacci variant selects state bits with the tap mask and XORs them into one feedback bit:

```verilog
feedback = ^(state & tap_in);
next_state = {feedback, state[N-1:1]};
```

For example, with `N=3`, mask `3'b011`, and seed `3'b001`, the mathematical recurrence is:

```text
001 → 100 → 010 → 101 → 110 → 111 → 011 → 001
```

This example visits all seven nonzero states. It is a worked recurrence, not a reported simulator result. Other masks may have shorter periods or enter zero. Changing `tap_in` changes feedback directly; this variant does not latch or lock the mask.

### Galois feedback

The basic Galois implementation copies the old LSB into the MSB. For each lower bit `i`, it uses:

```verilog
next_state[i] = state[i+1] ^ (tap_in[i] & state[0]);
```

Only `tap_in[N-2:0]` is used; `tap_in[N-1]` is ignored. The top feedback connection is unconditional. This indexing convention differs from the runtime variant, so do not reuse masks without checking the resulting recurrence.

### Runtime-programmable Galois variant

This implementation stores the tap mask in `tap_reg` and calculates:

```verilog
shifted = {1'b0, state[N-1:1]};
next_state = state[0] ? (shifted ^ tap_reg) : shifted;
```

| Signal | Purpose |
| --- | --- |
| `clk` | State and configuration update on rising edges |
| `rst_n` | Active-low asynchronous reset; state becomes 1 and taps become 0 |
| `en` | Advance the sequence when high, unless `seed_we` is high |
| `tap_we` | Latch `tap_in` into the tap register |
| `tap_in[N-1:0]` | Complete feedback XOR mask, including the MSB |
| `seed_we` | Load `seed_in`; takes priority over shifting |
| `seed_in[N-1:0]` | Caller-provided seed; zero is allowed by RTL but locks an XOR LFSR |
| `state[N-1:0]` | Parallel current state |
| `out_bit` | Current LSB |

Recommended startup: assert reset, release reset, load a suitable tap mask, load a nonzero seed, then enable shifting. The RTL does **not** automatically set the mask's MSB. If `tap_we` and `en` are asserted on the same rising edge, that shift uses the **old** mask; the new mask applies afterward because configuration uses nonblocking assignments.

The supplied runtime testbench loads `011`, then changes it to `101` during operation. This demonstrates reconfiguration; it is not a maximal-period test.

### Locked-tap Fibonacci variant

`tap_sel_we` programs `tap_sel_in` while `locked` is low. The first rising edge with `en=1` sets the lock, which remains set until reset. `seed_we` remains usable after locking.

Program the taps before enabling. A tap write coincident with the first enabled edge is accepted using the previous lock value, but that edge's feedback still uses the previous mask. Reset initializes the state to 1 and taps to 0.

### Sequence recognizer

`rtl/sequence/recognizer_100.v` contains a separate Moore-style detector. For state shown as `{q1,q0}`:

| Current state | Next state for `x=0` | Next state for `x=1` | `y` |
| --- | --- | --- | ---: |
| `00` | `00` | `01` | 0 |
| `01` | `11` | `01` | 0 |
| `11` | `00` | `01` | 1 |
| `10` | `10` | `01` | 0 |

**Known behavior:** despite its original name, the equations assert `y` after `10`, not after `100`, starting from reset. The source is preserved and should be corrected and tested before using it as a `100` detector. Its `reset` input is active low and **synchronous**, unlike the LFSRs.

## Run simulations

```bash
git clone https://github.com/Marty80s/lfsr-rtl-design.git
cd lfsr-rtl-design
```

Requirements: a Verilog simulator; the provided automation uses Icarus Verilog (`iverilog` and `vvp`), Bash, and GNU Make. Run commands from the repository root after installing these tools through your system's package manager.

```bash
make runtime       # Runtime tap and seed programming demo
make fibonacci     # Fibonacci demo
make galois        # Basic Galois demo
make check         # Run three demos; compile locked LFSR and recognizer
make clean         # Remove generated build outputs
```

Equivalent direct example:

```bash
mkdir -p build
iverilog -g2012 -s tb_prog_galois_lfsr_rt \
  -o build/runtime.vvp \
  rtl/runtime/programmable_lfsr.v tb/tb_runtime.v
vvp build/runtime.vvp
```

The demonstrations print time, state, output bit, and a completion message. The wrapper saves console output under `build/`. They do not currently dump waveform files or contain pass/fail assertions. `make check` is therefore a simulation/compilation smoke check, not a functional regression.

For a configured Cadence Xcelium installation, the corresponding runtime command is:

```bash
xrun -64bit -sv -top tb_prog_galois_lfsr_rt \
  rtl/runtime/programmable_lfsr.v tb/tb_runtime.v
```

Never compile `rtl/*/*.v` together: the four LFSRs intentionally share a module name. To change width, adjust `N` in the applicable testbench and update its tap and seed literals. The supplied testbenches use three-bit examples.

## Synthesize with Cadence Genus

You need a licensed Genus installation and a compatible, locally available Liberty timing library. Technology libraries are not included.

```bash
export LIBERTY_FILE=/absolute/path/to/your/timing-library.lib
export LFSR_VARIANT=runtime   # runtime, fibonacci, galois, or locked
export CLOCK_PERIOD=10.0
# Invoke in an environment configured for the Genus legacy-UI command style:
genus -legacy_ui -files scripts/synth_genus.tcl
```

The script elaborates the selected variant at its default width, checks unresolved references, reads the clock constraint, performs generic synthesis, mapping, and incremental optimization, then exports:

| Output under `build/synthesis/<variant>/` | Purpose |
| --- | --- |
| `programmable_lfsr_area.rpt` | Mapped area report |
| `programmable_lfsr_gates.rpt` | Gate/cell report |
| `programmable_lfsr_timing.rpt` | Timing paths |
| `programmable_lfsr_power.rpt` | Tool-generated power estimate |
| `programmable_lfsr_map.v` | Mapped gate-level netlist |
| `programmable_lfsr_map.sdc` | Exported constraints |
| `programmable_lfsr_map.sdf` | Exported timing delays |

The clock period uses the loaded library's time units. `10.0` corresponds to 100 MHz only when the unit is nanoseconds. The constraint file is a **clock-only starting point**: add realistic I/O delays, loading, clock assumptions, and reset treatment for your target. Power estimates require appropriate activity and operating assumptions. No frequency, area, power, or timing-closure result is claimed here.

The original synthesis script used machine-specific paths and constraints referencing a different design. This package replaces them with repository-relative source paths and environment-controlled library settings. Genus commands and reset-cell mapping must be checked in your installed tool/library environment.

## Repository layout

| Path | Contents |
| --- | --- |
| `rtl/fibonacci/` | Live-tap Fibonacci LFSR |
| `rtl/galois/` | Live-tap Galois LFSR |
| `rtl/runtime/` | Galois LFSR with tap and seed write enables |
| `rtl/locked/` | Fibonacci LFSR with startup tap locking |
| `rtl/sequence/` | Original sequence-detector prototype |
| `tb/` | Three simulation demonstrations |
| `scripts/simulate.sh` | Explicit source selection and simulator wrapper |
| `scripts/synth_genus.tcl` | Configurable synthesis flow |
| `constraints/lfsr.sdc` | Initial clock constraint |
| `docs/source-map.md` | Original filenames and preparation changes |

## Limitations and validation

- HDL simulation and Genus synthesis were **not executed during repository preparation** because these tools were unavailable. Shell syntax, source mapping, and Makefile command generation were checked.
- The original locked variant had a missing `#` in its parameter declaration; this syntax error is corrected. Testbench width parameters now propagate to the basic Fibonacci and Galois DUTs.
- The sequence recognizer's implemented behavior differs from its name, as documented above.
- Existing testbenches are stimulus demonstrations. Add self-checking tests for reset, enable hold, seed priority, tap-update timing, period length, and locked-tap rejection before relying on these designs.
- Some original testbench controls change at clock edges; move stimulus to falling edges and sample after sequential updates when building deterministic regressions.
- Maximum length depends on the feedback convention and primitive polynomial. Programmable taps alone do not guarantee a period of `2^N - 1`.
- All-zero state is absorbing for XOR feedback, and zero masks can cause a nonzero state to shift into zero. The caller must configure and seed the design appropriately.
- Loading an external seed in an asynchronous reset branch may need adaptation to the available standard cells or FPGA reset resources.
- Large widths, timing closure, physical design, and formal equivalence are not validated by this package.

## Attribution and licensing

Prepared from the supplied `Project_prototype` archive. Original source names and changes are documented in [the source map](docs/source-map.md). No license was supplied, so no open-source license has been assigned. The owner should choose an appropriate license before inviting reuse.
