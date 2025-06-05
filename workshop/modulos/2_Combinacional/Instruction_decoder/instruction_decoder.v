/*------------------------------------------------------------------------
---- Module: instruction_decoder                                      ----
---- Description:  this is a decoder that takes an N-bit instruction  ----
----     and generates the output signals to drive the ALU of a       ----
----     hypotetical processor.                                       ----
---- Author/s:  student                                               ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module instruction_decoder
#(
  parameter N_BITS = 4
)
(
    input  wire [N_BITS-1:0] a_in ,
    output reg load               ,
    output reg add                ,
    output reg bitand             ,
    output reg sub                ,
    output reg input_out          ,
    output reg output_out         ,
    output reg jump               ,
    output reg jump_cond                        
);

//TODO...
endmodule