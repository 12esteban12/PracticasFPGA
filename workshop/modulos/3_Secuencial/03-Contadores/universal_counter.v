/*------------------------------------------------------------------------
---- Module:  universal_counter                                       ----
---- Description: this is a counter that supports different operating ----
----   modes, such like:                                              ----
----       * Count up                                                 ----
----       * Count down                                               ----
----       * Parallel load                                            ----
----       * Pause                                                    ----
---- Author/s:  student                                               ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies: None                                               ----
------------------------------------------------------------------------*/

module universal_counter
#(
    parameter N = 8
)
(
    input           clk      ,
    input           rst      ,
    input           load     ,
    input           en       ,
    input           up       ,
    input  [N-1:0]  D        ,
    output          max_tick ,
    output          min_tick ,
    output [N-1:0]  Q
);

//Declaración de señales internas
reg  [N-1:0] r_reg;
reg  [N-1:0] r_next;
wire [2:0]   ctrl;

//Actualización del estado interno:
always @ (posedge clk, posedge rst) 
begin
    if(rst)
        r_reg <= {N{1'b0}};
    else
        r_reg <= r_next;
end

//Lógica del estado siguiente:
// TODO ...

//Lógica de salida:
assign Q        = // TODO...
assign max_tick = // TODO...
assign min_tick = // TODO...

endmodule
