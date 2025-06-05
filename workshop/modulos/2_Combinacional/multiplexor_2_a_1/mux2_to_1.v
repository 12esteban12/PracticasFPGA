/*------------------------------------------------------------------------
---- Module: mux2_to_1                                                ----
---- Description:  2 to 1 multiplexor                                 ----
---- Author/s:  student                                               ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

`timescale 1ns / 1ps
module mux2_to_1
    (input wire [1:0] in,
    input wire sel, //Selección de la entrada
    output reg  out //salida del mux
    );

// Declaración de las Señales internas
	reg  sel_in;
//

always@(*)
    begin
        sel_in = sel;
        case(sel_in)
            1'b0: out=in[0];
            1'b1: out=in[1];
            default: out=1'b0;
        endcase
    end
endmodule
