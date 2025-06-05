/*------------------------------------------------------------------------
---- Module: mux2_to_1_tb                                             ----
---- Description:  testbench for mux2_to_1                            ----
---- Author/s:  Héctor Lacomi                                         ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----    mux2_to_1.v                                                   ----
------------------------------------------------------------------------*/

`timescale 1ns / 1ps
`include "mux2_to_1.v"

module mux2_to_1_tb; 
    //Inputs
    reg [1:0] in_aux;//input
    reg  sel_aux;   //selection
    wire out_aux;        //output
    //auxiliar
    //integer i
    //Instanciar la UUT 
    mux2_to_1 uut (
        .in(in_aux),
        .sel(sel_aux),
        .out(out_aux)
    );
    initial 
        begin
            $display ("<< Comenzando el test >>");
            $dumpfile("test.vcd"); // Change filename as appropriate. 
            $dumpvars(2, mux2_to_1_tb );
            // Initialize inputs
            in_aux = 2'b00;
            sel_aux = 1'b0;
            #100;  //espera 100ns
            //Espera 100ns para cada conmutación
            
            //Estímulo 1 entrada 1
            in_aux = 2'b01;
            sel_aux = 1'b0;
            #100;

            //Estímulo 2 entrada 1
            in_aux = 2'b00;
            sel_aux = 1'b1;
            #100;

            //Estímulo 3 entrada 1
            in_aux = 2'b10;
            sel_aux = 1'b1;
            #100;
    
        end   
//Probar los estímulos con un lazo for usando i como selector y case como selector



//$monitor("At time = %t, Output = %d", $time, out); 
endmodule
