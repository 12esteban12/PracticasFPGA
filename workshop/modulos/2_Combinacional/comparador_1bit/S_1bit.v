/*------------------------------------------------------------------------
---- Module: S_1bit                                                   ----
---- Description: 1 bit comparator                                    ----
---- Author/s:  Héctor Lacomi                                         ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module S_1bit(
    input wire A, B,  		//Declaración de los puertos de entrada
    output wire S     		//Declaración del puerto de salida
    );

	wire P0, P1;    	//Declaracíón del tipo de dato
	assign S = P0 | P1;	/*Asignación continua S:salida - P0 y P1 entradas. Forma mas sencilla. 
				de describir lógica - | reŕesenta "or" */
	assign P0= A & B;	// & representa "and"//
	assign P1= ~A & ~B;	//~ representa "not"

endmodule
