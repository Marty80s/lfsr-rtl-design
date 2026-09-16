# Cadence Genus legacy-UI style, following the original project flow.
set ROOT [file normalize [file join [file dirname [info script]] ..]]
if {![info exists ::env(LIBERTY_FILE)]} {
    error "Set LIBERTY_FILE to a locally licensed Liberty timing library."
}
set VARIANT runtime
if {[info exists ::env(LFSR_VARIANT)]} { set VARIANT $::env(LFSR_VARIANT) }
if {$VARIANT ni {runtime fibonacci galois locked}} { error "Unsupported LFSR_VARIANT" }
set DESIGN programmable_lfsr
set OUT [file join $ROOT build synthesis $VARIANT]
file mkdir $OUT
set_attribute library [list $::env(LIBERTY_FILE)]
read_hdl [file join $ROOT rtl $VARIANT programmable_lfsr.v]
elaborate $DESIGN
check_design -unresolved
read_sdc [file join $ROOT constraints lfsr.sdc]
syn_gen
syn_map
syn_opt -incr
report area > $OUT/${DESIGN}_area.rpt
report gates > $OUT/${DESIGN}_gates.rpt
report timing -worst 200 > $OUT/${DESIGN}_timing.rpt
report power > $OUT/${DESIGN}_power.rpt
write_hdl -mapped > $OUT/${DESIGN}_map.v
write_sdc > $OUT/${DESIGN}_map.sdc
write_sdf > $OUT/${DESIGN}_map.sdf
