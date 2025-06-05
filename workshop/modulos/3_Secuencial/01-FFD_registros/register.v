/*------------------------------------------------------------------------
---- Module:  register                                                ----
---- Description: simple N bits register                              ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module register
#(
    parameter N = 8
)
(
    input  wire              clk,
    input  wire [N-1:0]      d,
    input  wire              rst,
    input  wire              ena,
    output reg  [N-1:0]      q
);

always @ (posedge clk, posedge rst)
begin
    if(rst)
        q <= {N{1'b0}};
    else if(ena)
        q <= d;
end

endmodule