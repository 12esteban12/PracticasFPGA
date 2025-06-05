/*------------------------------------------------------------------------
---- Module:  counter                                                 ----
---- Description: N bits counter                                      ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module counter
#(
    parameter N = 8
)
(
    input wire clk,
    input wire rst,
    output max_tick,
    output [N-1:0] q
);

//Declaración de señales internas
reg  [N-1:0] r_reg;
wire [N-1:0] r_next;

//Actualización del estado interno:
always @ (posedge clk, posedge rst) 
begin
    if(rst)
        r_reg <= 0; //{N{1'b0}};
    else
        r_reg <= r_next;
end

//Lógica del estado siguiente:
assign r_next = r_reg + 1;

//Lógica de salida:
assign q = r_reg;
assign max_tick = (r_reg == (2**N)-1) ? (1'b1) : (1'b0); //&r_reg;

endmodule