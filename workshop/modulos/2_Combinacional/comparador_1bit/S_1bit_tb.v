/*------------------------------------------------------------------------
---- Module: S_1bit_tb                                                ----
---- Description: testbench for S_1bit                                ----
---- Author/s:  Héctor Lacomi                                         ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     S_1bit.v                                                     ----
------------------------------------------------------------------------*/

`timescale 1ns / 100ps
`include "S_1bit.v"

module S_1bit_tb;

	// Inputs
	reg  A_in;  // Señal donde voy a inyectar el impulso A
	reg  B_in;	// Señal donde voy a inyectar el impulso B

	// Outputs
	wire AyB_out;	//Salida para ser visualizada

	// Instantiate the Unit Under Test (UUT)
	S_1bit uut (
		.A(A_in), 	//Conexión de la entrada física A con la señal de estímulo
		.B(B_in), 	//Conexión de la entrada física B con la señal de estímulo
		.S(AyB_out)	//Conexión de la Salida del módulo 
	);

initial begin
	$display ("<< Comenzando el test >>");
    $dumpfile("test.vcd"); 	// Archivo donde voy a almacenar las señales. 
    $dumpvars(2, S_1bit_tb );	//2 niveles dentro del archivo testbench
		#10;
		// Estimulo 1
		A_in = 1'b0;
		B_in = 1'b0;
		
		#100;	//Espera 100 unidades de tiempo que definí al principio del archivo
		// Estimulo 2
		A_in = 1'b1;
		B_in = 1'b0;
		
		#100;
		// Estimulo 3
		A_in = 1'b0;
		B_in = 1'b1;
		
		#100;
		// Estimulo 4
		A_in = 1'b1;
		B_in = 1'b1;
		#100;

	end

endmodule

