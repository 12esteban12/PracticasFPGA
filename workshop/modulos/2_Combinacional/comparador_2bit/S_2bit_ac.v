`include "S_1bit.v"
//`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ASE-FRH
// Engineer: 
// 
// Create Date:    04/24/2023 
// Design Name: 
// Module Name:    S_2bit 
// Project Name: Workshop FPGA 2023
// Target Devices: 
// Tool versions: 
// Description:  Comparador de 2 bits
//
// Dependencies: S_1bit
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module S_2bit(
    input wire [1:0] A, B,                        //Definición del wire de 2 bits                         //Definición del wire de 2 bits
    output wire AyB
    );
	wire P0, P1, P2, P3;  //Declaración interna de señales
    // Términos producto
	assign P0 = (~A[1] & ~B[1]) & (~A[0] & ~B[0]);
    assign P0 = (~A[1] & ~B[1]) & (A[0] & B[0]);
    assign P0 = (A[1] & B[1]) & (~A[0] & ~B[0]);
    assign P0 = (A[1] & B[1]) & (A[0] & B[0]);
	assign AyB=P0 & P1;                        //Asignación continua a la salida AyB de P0 y P1
endmodule
