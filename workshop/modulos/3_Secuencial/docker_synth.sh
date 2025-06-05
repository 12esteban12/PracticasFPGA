#!/bin/bash

docker run --privileged -v $(pwd):/home/iVerilog/src --rm educiaafpga/x64 /bin/sh -c "cd home/iVerilog/src && yosys -p 'synth_ice40 -json top.json' $1" | tee yosys_out.log

#Example - how to run:
# bash docker_synth.sh spi.v
