/*------------------------------------------------------------------------
---- Module:  ffd_srst_en                                             ----
---- Description: simple flip-flop D with synchronous reset and       ----
----     enable                                                       ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module ffd_srst_en
(
    input  wire clk,
    input  wire   d,
    input  wire rst,
    input  wire ena,
    output reg    q
);

always @ (posedge clk)
begin
    if(rst)
        q <= 1'b0;
    else if(ena)
        q <= d;
end

endmodule