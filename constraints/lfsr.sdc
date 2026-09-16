# Example constraints only; values use the loaded library's time units.
# With a nanosecond library, the default period is 10 ns (100 MHz).
set PERIOD 10.0
if {[info exists ::env(CLOCK_PERIOD)]} { set PERIOD $::env(CLOCK_PERIOD) }
create_clock -name clk -period $PERIOD [get_ports clk]
# Set realistic external input/output delays and a reset strategy for your target.
# No timing-closure claim is made with this clock-only template.
