/*------------------------------------------------------------------------
---- Modules:  test                                                   ----
---- Description: testbench for SPWM generator without PLL            ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     spwm.v                                                       ----
------------------------------------------------------------------------*/

`include "spwm.v"

module test;

// Estimulos
reg clk;
reg rst;
wire pwm_out;
wire[2:0] dummy;

// DUT
spwm dut(  
    .clk(clk),
    .rst(rst),
    .pwm_out(pwm_out),
    .dummy(dummy)
);

// Reducir la division de frecuencia
defparam dut.MEM_CLK_DIVIDER_BITS = 4;

// Generacion clock
always #1 clk = !clk;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test); //Abrir archivo

    #0 rst <= 1'b0;
    #0 clk <= 1'b0;
    #2 rst <= 1'b1; // RST NEGADO !!

    #32768 $finish;
end

endmodule