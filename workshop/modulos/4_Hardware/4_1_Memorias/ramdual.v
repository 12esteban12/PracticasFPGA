/*------------------------------------------------------------------------
---- Module:  RAM_DUAL                                                ----
---- Description: True Dual Port RAM                                  ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/


module RAM_DUAL 

  #(parameter WORD_LENGTH = 8,	//Bits de cada palabra
    parameter ADDR_LENGTH = 8)	//Bits de direcciones

  (input wire w_clk,				                    //Write clock
   input wire r_clk,							              //Read clock
   input wire write,			                      //Write enable
   input [ADDR_LENGTH-1 : 0] w_addr,	  //Write address
   input [ADDR_LENGTH-1 : 0] r_addr,	  //Read address
   input wire [WORD_LENGTH-1 : 0] data_in,		  //Dato de entrada
   output reg [WORD_LENGTH-1 : 0] data_out);		//Dato de salida
  
  //Bloque de memoria (** denota potencia)
  reg[WORD_LENGTH-1:0] MEMORY[2**ADDR_LENGTH-1:0];
  
  // Lectura (dominio w_clk)
  always @(posedge w_clk) begin
    if (write==1'b1) begin
      MEMORY[w_addr] <= data_in;
    end
  end
  
  //Escritura (dominio r_clk)
  always @(posedge r_clk) begin
    data_out <= MEMORY[r_addr];
  end

endmodule
