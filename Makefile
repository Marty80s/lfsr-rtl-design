IVERILOG ?= iverilog
VVP ?= vvp
VARIANT ?= runtime
.PHONY: sim fibonacci galois runtime check clean
sim:
	bash scripts/simulate.sh $(VARIANT) "$(IVERILOG)" "$(VVP)"
fibonacci galois runtime:
	bash scripts/simulate.sh $@ "$(IVERILOG)" "$(VVP)"
check: fibonacci galois runtime
	mkdir -p build
	$(IVERILOG) -g2012 -s programmable_lfsr -o build/locked.vvp rtl/locked/programmable_lfsr.v
	$(IVERILOG) -g2012 -s recognizer_100 -o build/sequence.vvp rtl/sequence/recognizer_100.v
clean:
	rm -rf build
