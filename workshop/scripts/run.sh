#!/bin/bash

echo ""
OPTIONS="help sim syn bit"
ROOT=$(pwd)
echo "EDU CIAA FPGA - Entorno de desarrollo"
echo "====================================="
echo ""

if [ "$1" == "" ]; then
    echo "Opciones disponibles: ${OPTIONS}"
    echo ""
    echo "Ingrese './run.sh OPCION' para obtener mas informacion"
else
    case $1 in
        help)
            echo "Script para emplear las herramientas de simulacion, sintesis e implementacion"
            echo "existentes en el Docker educiaafpga:x64 para la placa EDU-CIAA-FPGA."
            echo ""
            echo "Para mas herramientas se recomienda emplear la extension de VSCode oficial:"
            echo "https://gitlab.com/educiaafpga/edu-ciaa-fpga-vscode-extension"
            echo ""
            echo "Autor: Ramiro Adrian Ghignone, Grupo UTN-FRH-ASE"
            echo "Licencia: ninguna, sientanse libres de tocar el script como necesiten"
            echo ""
            echo "Desde Haedo con amor..."
        ;;
        sim)
            if [ "$2" == "" ] && [ "$3" == "" ]; then
                SIM_OPTIONS="verilog vhdl"
                echo "Modulo de simulacion"
                echo "--------------------"
                echo ""
                echo "./run.sh HDL TB"
                echo ""
                echo "Argumentos:"
                echo "HDL: las opciones disponibles son --> ${SIM_OPTIONS}"
                echo "TB : nombre del archivo (Verilog, incluir extension .v) o de la entidad (VHDL, sin extension) a simular (testbench)"
                echo ""
                echo "Resultado: archivo .vcd de formas de onda que puede abrirse con gtkWave o con la extension WaveTrace de VSCode"
            else
                case $2 in
                    verilog)
                       docker run\
                        -v "${ROOT}":/home/iVerilog/src \
                        --rm educiaafpga/x64 /bin/sh \
                        -c "cd .. &&\
                            cd home/iVerilog/src &&\
                            iverilog -o main.vvp $3 &&\
                            vvp main.vvp" | tee "$1".log
                    ;;
                    vhdl)
                        docker run \
                            -v "${ROOT}":/home/ghdl/src \
                            --rm educiaafpga/x64 /bin/sh \
                            -c "cd home/ghdl/src ; ghdl -i -fsynopsys -frelaxed --std=08 *.vhdl ;\
                                ghdl -i -fsynopsys -frelaxed --std=08 *.vhd ;\
                                ghdl -m -fsynopsys -frelaxed --std=08 $3 &&\
                                ghdl -r -fsynopsys -frelaxed --std=08 $3 --wave=test.vcd" | tee "$1".log
                    ;;
                    *)
                        echo "ERROR - HDL no reconocido"
                    ;;
                esac 
            fi
        ;;
        syn)
            if [ "$2" == "" ] && [ "$3" == "" ] && [ "$4" == "" ]; then
                SYN_OPTIONS="verilog vhdl"
                echo "Modulo de sintesis"
                echo "------------------"
                echo ""
                echo "./run.sh HDL TOP PCF"
                echo ""
                echo "Argumentos:"
                echo "HDL: las opciones disponibles son --> ${SYN_OPTIONS}"
                echo "TOP: nombre del archivo (Verilog, incluir extension .v) o de la entidad (VHDL, sin extension) a sintetizar"
                echo "PCF: archivo de constraints (pines), incluyendo extension .pcf"
                echo ""
                echo "Resultado: archivo .bin con el bitstream para descargar a la FPGA"
            else
                case $2 in
                    verilog)
                        docker run --privileged\
                            -v "${ROOT}":/home/iVerilog/src \
                            --rm educiaafpga/x64 /bin/sh \
                            -c " cd .. &&\
                                cd home/iVerilog/src &&\
                                yosys -p 'synth_ice40 -json top.json' $3 &&\
                                nextpnr-ice40 --hx4k --package tq144 --pcf $4 --json top.json --asc top.asc &&\
                                icepack top.asc top.bin" | tee "$1".log
                    ;;
                    vhdl)
                    docker run \
                        -v "${ROOT}":/home/ghdl/syn \
                        --rm educiaafpga/x64 /bin/sh \
                        -c  "cd home/ghdl/syn ;\
                            ghdl -i *.vhdl ;\
                            ghdl -i *.vhd ;\
                            ghdl -a *.vhdl ;\
                            ghdl -a *.vhd ;\
                            yosys -m ghdl -p 'ghdl $3\
                            ; synth_ice40 -json top.json' "  | tee syn.log &&\
                    docker run --privileged \
                        -v "${ROOT}":/home/synth/src \
                        --rm educiaafpga/x64 /bin/sh \
                        -c  "cd .. &&\
                            cd home/synth/src &&\
                            nextpnr-ice40 --hx4k --package tq144 --pcf $4 --json top.json --asc top.asc &&\
                            icepack top.asc top.bin" | tee pnr.log
                    ;;
                    *)
                        echo "ERROR - HDL no reconocido"
                    ;;
                esac 
            fi
        ;;
        bit)
            if [ "$2" == "" ] ; then
                echo "Modulo de descarga de bitstream"
                echo "-------------------------------"
                echo ""
                echo "./run.sh BIT"
                echo ""
                echo "Argumentos:"
                echo "BIT: archivo .bin de configuracion de la FPGA"
                echo ""
                echo "IMPORTANTE: la FPGA debe estar conectada a la computadora"
            else
                docker run --privileged\
                    -v "${ROOT}":/home/bit/src \
                    --rm educiaafpga/x64 /bin/sh \
                    -c "cd ..&& cd home/bit/src && iceprog $2" | tee "$1".log
            fi
        ;;
        *)
            echo "Opcion no reconocida: $1"
        ;;
    esac 
fi

echo ""
exit