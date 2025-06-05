#!/bin/make

# Modificar segun sea necesario
ROOT = $(shell pwd)
TEST = ramdual_tb.v
PINS = pins.pcf
TOP  = ramdual.v

sim:
	docker run -v"${ROOT}":/home/iVerilog/src --rm educiaafpga/x64 /bin/sh -c "cd .. && cd home/iVerilog/src && iverilog -o main.vvp ${TEST} && vvp main.vvp" | tee sim.log
	gtkwave test.vcd

syn:
	docker run --privileged -v"${ROOT}":/home/iVerilog/src --rm educiaafpga/x64 /bin/sh -c "cd .. && cd home/iVerilog/src && yosys -p \"synth_ice40 -json top.json\" ${TOP} && nextpnr-ice40 --hx4k --package tq144 --pcf ${PINS} --json top.json --asc top.asc && icepack top.asc top.bin && iceprog top.bin" | tee syn.log
	rm *.json
	rm *.asc
	rm *.bin