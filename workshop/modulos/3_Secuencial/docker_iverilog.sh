#!/bin/bash

docker run -v $(pwd):/home/iVerilog/src --rm educiaafpga/x64 /bin/sh -c "cd home/iVerilog/src && iverilog -o main.vvp $1 && vvp main.vvp" ; gtkwave $(pwd)/$2 &

#Example - how to run:
# bash docker_iverilog.sh spi_tb.v test.vcd
