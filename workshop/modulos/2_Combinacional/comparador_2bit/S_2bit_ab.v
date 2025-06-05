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
    input wire [1:0] A, B, //Definición del wire de 2 bits
    output reg AyB
    );
	always @ * //El asterisco representa todas las señales
    if (A=B)
        AyB = 1'b1;
    else
        AyB = 1'b0;     
endmodule
