# Original source mapping

- `input_files/RTL/fibonacci.v` → `rtl/fibonacci/programmable_lfsr.v`
- `input_files/RTL/galios.v` → `rtl/galois/programmable_lfsr.v`
- `input_files/RTL/programmable_lfsr.v` → `rtl/runtime/programmable_lfsr.v`
- `input_files/RTL/Programmable_lfsr2.v` → `rtl/locked/programmable_lfsr.v`
- `input_files/RTL/Seq.v` → `rtl/sequence/recognizer_100.v`
- `input_files/RTL/fibonnaci_tb.v` → `tb/tb_fibonacci.v`
- `input_files/RTL/tb_galios.v` → `tb/tb_galois.v`
- `input_files/RTL/recognizer_100.v` → `tb/tb_runtime.v`

Packaging changes: corrected the missing `#` in the locked variant parameter declaration; propagated testbench width parameters to Fibonacci and Galois DUTs; corrected the runtime MSB-tap comment. Functional equations remain unchanged. New synthesis scripts replace the original machine-specific paths and mismatched sequence-detector constraints.

Excluded: Cadence caches, core dumps, wave databases, session logs, command histories and generated formal/synthesis databases. No foundry library or license was added.
