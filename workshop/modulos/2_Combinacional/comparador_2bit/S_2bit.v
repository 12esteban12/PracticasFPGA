/*------------------------------------------------------------------------
---- Module: S_2bit                                                   ----
---- Description: 2 bits comparator                                   ----
---- Author/s:  Héctor Lacomi                                         ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     S_1bit.v                                                     ----
------------------------------------------------------------------------*/

`include "S_1bit.v"

module S_2bit(
    input wire [1:0] A,                         //Definición del wire de 2 bits
    input wire [1:0] B,                         //Definición del wire de 2 bits
    output wire AyB
    );
	wire P0, P1;
	S_1bit uut0 (.A(A[0]), .B(B[0]), .S(P0));  //Instanciación de los módulos de los comparadores
	S_1bit uut1 (.A(A[1]), .B(B[1]), .S(P1));   //de 1 bits (otra forma de describir HW)
	assign AyB=P0 & P1;                        //Asignación continua a la salida AyB de P0 y P1
endmodule
