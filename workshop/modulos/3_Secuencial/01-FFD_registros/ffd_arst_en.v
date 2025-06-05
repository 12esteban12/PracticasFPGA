/*------------------------------------------------------------------------
---- Module:  ffd_arst_en                                             ----
---- Description: simple flip-flop D with asynchronous reset and      ----
----     enable                                                       ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module ffd_arst_en
(
    input  wire clk,
    input  wire   d,
    input  wire rst,
    input  wire ena,
    output reg    q
);

always @ (posedge clk, posedge rst)
begin
    if(rst)
        q <= 1'b0;
    else if(ena)
        q <= d;
end

endmodule