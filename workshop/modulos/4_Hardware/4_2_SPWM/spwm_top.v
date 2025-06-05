/*------------------------------------------------------------------------
---- Modules:  pll and top                                            ----
---- Description: SPWM generator with PLL                             ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     spwm.v                                                       ----
------------------------------------------------------------------------*/

`include "spwm.v"

/******************************** Modulo PLL ********************************/

//Parametros y E/S
module pll(
	input  wire clock_in,   // Clock de entrada
	output wire global_out, // Clock de salida
	output wire locked      // PLL enganchado
);

wire clock_int; // Linea auxiliar interna
    
// Instanciar la primitiva del PLL (parametros y puertos)
SB_PLL40_CORE #(
	.FEEDBACK_PATH("SIMPLE"), // Realimentación simple
	.DIVR(4'b0000),		      // DIVR =  0
	.DIVF(7'b1000010),	      // DIVF =  66
	.DIVQ(3'b011),		      // DIVQ =  3
	.FILTER_RANGE(3'b001)     // Filtro de salida
) uut (
	.LOCK(locked),            // Indicador de PLL bloqueado
	.RESETB(1'b1),            // Linea de reset (activa en bajo)
	.BYPASS(1'b0),            // Sin Bypass
	.REFERENCECLK(clock_in),  // Clock de referencia (desde cristal externo)
    .PLLOUTGLOBAL(clock_int)  // Clock de salida (conectado a linea auxiliar)
	);

// Instanciar la primitiva del Buffer Global
SB_GB sbGlobalBuffer_inst( .USER_SIGNAL_TO_GLOBAL_BUFFER(clock_int) // Entrada
		                , .GLOBAL_BUFFER_OUTPUT(global_out) );      // Salida
endmodule // PLL

/********************************* Top Level **********************************/

module top (
    input wire clk,
    input wire rst,
    output wire pwm_out,
    output wire[2:0] dummy
);

////// Instanciar y conectar componentes

// Linea interna de clock a 100 MHz
wire internal_clk;

// Instanciar PLL a 100 MHz
pll my_pll(.clock_in(clk),
           .global_out(internal_clk),
           .locked());

spwm my_spwm(.clk(internal_clk),
             .rst(rst),
             .pwm_out(pwm_out),
             .dummy(dummy));

endmodule