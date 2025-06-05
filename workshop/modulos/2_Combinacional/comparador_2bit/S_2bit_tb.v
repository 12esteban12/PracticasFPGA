/*------------------------------------------------------------------------
---- Module: S_2bit_tb                                                ----
---- Description: testbench for 2 bits comparator                     ----
---- Author/s:  Héctor Lacomi                                         ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     S_2bit.v                                                     ----
------------------------------------------------------------------------*/

`timescale 1ns / 10ps
`include "S_2bit.v"

module S_2bit_tb;

	// Inputs
	reg [1:0] A;						//Declaración de la variable de 2 bits idem a la entrada del Comparador
	reg [1:0] B;

	// Outputs
	wire AyB;							//Una salidad de un bit tipo wire

	// Instanciar la Unit Under Test (UUT)
	S_2bit uut (
		.A(A), 
		.B(B), 
		.AyB(AyB)
	);

	initial begin
	$display ("<< Comenzando el test >>");
    $dumpfile("test.vcd"); // Change filename as appropriate. 
    $dumpvars(2, S_2bit_tb );
		#10;
		// Estimulo 1
		A = 2'b00;
		B = 2'b00;
		
		#100;
		// Estimulo 2
		A = 2'b01;
		B = 2'b11;
		
		#100;
		// Estimulo 3
		A = 2'b10;
		B = 2'b01;
		
		#100;
		// Estimulo 4
		A = 2'b11;
		B = 2'b10;
		
		#100;
		// Estimulo 5
		A = 2'b11;
		B = 2'b11;
		
		#100;

	end
      
endmodule

