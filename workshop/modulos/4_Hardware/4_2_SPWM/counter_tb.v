/*------------------------------------------------------------------------
---- Module:  counter_tb                                              ----
---- Description: testbench for PWM counter                           ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Oct. 2023                                         ----
---- Dependencies:                                                    ----
----     spwm.v                                                       ----
------------------------------------------------------------------------*/

`include "spwm.v"

// Verilog no tiene asserts por defecto, 
// pero se pueden implementar mediante una macro como esta
`define assert(signal, value, msg) \
  if (signal !== value) begin \
      $display(msg); \
      $display("Expected: %2x, got %2x",value,signal); \
      /*$finish;*/ \
  end


module counter_tb #(parameter N_bits = 4) (
    
);
    
// Estimulos
reg clk;
reg rst;
wire[N_bits-1:0] count;

counter dut (
    .clk(clk),
    .rst(rst),
    .count(count)
);

integer max_count;
integer external_cnt;

// Testbench
initial begin
    clk<=1'b0;
    rst<=1'b1;
    #1 rst<=1'b0;
    max_count = 2**N_bits-1;
    for (external_cnt=0;external_cnt<max_count;external_cnt++) begin
        #1 clk = !clk;
        `assert(count,external_cnt,"BEWARE: Count mismatch");
        #1 clk = !clk;
    end
    $finish;
end

endmodule