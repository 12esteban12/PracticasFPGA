/*------------------------------------------------------------------------
---- Module:  shift_register                                          ----
---- Description: register that shifts N bits to the right            ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module shift_register
#(
    parameter N=8
)
(
    input wire clk,
    input wire rst,
    input wire sh_in,
    output wire sh_out
);

//Declaración de señales:
reg  [N-1:0] r_reg;
wire [N-1:0] r_next;

//Actualización del estado interno:
always @ (posedge clk, posedge rst)
begin
    if(rst)
        r_reg <= {N{1'b0}};
    else
        r_reg <= r_next;
end

//Lógica del estado siguiente:
assign r_next = {sh_in,r_reg[N-1:1]};

//Lógica de salida:
assign sh_out = r_reg[0];

endmodule