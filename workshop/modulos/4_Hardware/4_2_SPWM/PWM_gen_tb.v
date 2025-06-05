/*------------------------------------------------------------------------
---- Module:  PWM_gen_tb                                              ----
---- Description: testbench for PWM modulator                         ----
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


module PWM_gen_tb #(parameter N_bits = 8) (
    
);
    

// Clock y reset
reg clk;
reg rst;
reg[N_bits-1 : 0] duty;
wire PWM_out;

PWM_generator dut (
    .clk(clk),
    .rst(rst),
    .duty(duty),
    .PWM_out(PWM_out)
);

defparam dut.N_bits = N_bits;

integer max_count;
integer i;
integer j;

// Testbench
initial begin
    clk<=1'b0;
    rst<=1'b1;
    #1 rst<=1'b0;
    max_count = 2**N_bits;
    for (i=0;i<max_count;i++) begin
        duty<=i;
        for (j=0;j<max_count;j++) begin
            #1 clk = !clk;
            if (j<i) begin
                `assert(PWM_out,1,"BEWARE: PWM syn error");
            end else begin
                `assert(PWM_out,0,"BEWARE: PWM syn error");
            end
            #1 clk = !clk;
        end
    end
end

endmodule