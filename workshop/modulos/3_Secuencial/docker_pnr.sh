#!/bin/bash

docker run --privileged -v $(pwd):/home/iVerilog/src --rm educiaafpga/x64 /bin/sh -c "cd home/iVerilog/src &&\
 yosys -p 'synth_ice40 -json top.json' $1 &&\
 nextpnr-ice40 --hx4k --package tq144 --pcf $2 --json top.json --asc top.asc" > synth.log 2> pnr.log

#Note: stdout is redirected to synth.log and stderr is redirected to pnr.log

#Example - how to run:
# bash docker_pnr.sh ad7705_ctrl.v ad7705_ctrl.pcf
