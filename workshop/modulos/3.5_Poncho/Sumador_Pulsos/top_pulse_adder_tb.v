/*------------------------------------------------------------------------
---- Module: top_pulse_adder_tb                                       ----
---- Description: testbench for the pulse adder top level. In order   ----
----     to make the output easier to analyze, the clock frequency    ----
----     and the debounce wait time are reduced down to 100 KHz and   ----
----     1 ms respectively.                                           ----
---- Author/s:  Manuel Ayala, Matías I. Monopoli                      ----
---- Last revision: Jun. 2024                                         ----
---- Dependencies:                                                    ----
----    top_pulse_adder.v                                             ----
------------------------------------------------------------------------*/

`timescale 1ns/1ps
`include "top_pulse_adder.v"

module top_pulse_adder_tb ();


localparam T = 10000;
localparam T_DEBOUNCE_NS = 1000000;
integer i;

reg clk;
reg rst;
reg btn_0_in;
reg btn_1_in;  
reg btn_2_in;  
reg btn_3_in;
wire [3:0] en_disp;
wire [7:0] digit_out;
wire rst_led;


top_pulse_adder #(
    .CLK_FREQ_HZ(100000),
    .DEBOUNCE_TIME_MS(1)
) dut (
    .clk(clk),
    .rst(rst),
    .btn_0_in(btn_0_in),
    .btn_1_in(btn_1_in),
    .btn_2_in(btn_2_in),
    .btn_3_in(btn_3_in),
    .en_disp(en_disp),
    .digit_out(digit_out),
    .rst_led(rst_led)
);


always #(T/2) clk <= !clk;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,top_pulse_adder_tb);

    clk <= 1'b1;
    rst <= 1'b0;
    btn_0_in <= 1'b1;
    btn_1_in <= 1'b1;
    btn_2_in <= 1'b1;
    btn_3_in <= 1'b1;
    #(T_DEBOUNCE_NS);
    rst <= 1'b1;
    #(3*T_DEBOUNCE_NS);

    for (i = 0 ; i < 16 ; i++) begin
        btn_0_in <= 1'b0;
        #(T_DEBOUNCE_NS);
        #(20*T);
        btn_0_in <= 1'b1;
        #(T_DEBOUNCE_NS);    
        #(20*T);
    end
    btn_0_in <= 1'b1;

    for (i = 0 ; i < 16 ; i++) begin
        btn_1_in <= 1'b0;
        #(T_DEBOUNCE_NS);
        #(20*T);
        btn_1_in <= 1'b1;
        #(T_DEBOUNCE_NS);    
        #(20*T);
    end
    btn_1_in <= 1'b1;
    
    for (i = 0 ; i < 16 ; i++) begin
        btn_2_in <= 1'b0;
        #(T_DEBOUNCE_NS);
        #(20*T);
        btn_2_in <= 1'b1;
        #(T_DEBOUNCE_NS);    
        #(20*T);
    end
    btn_2_in <= 1'b1;

    for (i = 0 ; i < 16 ; i++) begin
        btn_3_in <= 1'b0;
        #(T_DEBOUNCE_NS);
        #(20*T);
        btn_3_in <= 1'b1;
        #(T_DEBOUNCE_NS);    
        #(20*T);
    end
    btn_3_in <= 1'b1;
    
    $finish();
end

endmodule