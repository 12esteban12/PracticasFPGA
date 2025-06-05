/*------------------------------------------------------------------------
---- Module:  ffd                                                     ----
---- Description: simple flip-flop D with no reset and no enable      ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module ffd
(
    input  wire clk,
    input  wire   d,
    output reg    q
);

always @ (posedge clk)
    q <= d;

endmodule