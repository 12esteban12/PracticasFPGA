/*------------------------------------------------------------------------
---- Module: pulse_adder_tb                                           ----
---- Description: testbench for the pulse adder                       ----
---- Author/s:  Manuel Ayala, Matías I. Monopoli                      ----
---- Last revision: Jun. 2024                                         ----
---- Dependencies:                                                    ----
----    pulse_adder.v                                                 ----
------------------------------------------------------------------------*/
`timescale 1 ns/10 ps
`include "pulse_adder.v"


module pulse_adder_tb;

localparam T = 10;
integer i;

reg clk;
reg rst;
reg btn_0_in;
reg btn_1_in;  
reg btn_2_in;  
reg btn_3_in;
wire [3:0] count_0_out;
wire [3:0] count_1_out;
wire [3:0] count_2_out;
wire [3:0] count_3_out;


pulse_adder dut (
    .clk(clk),
    .rst(rst),
    .btn_0_in(btn_0_in),
    .btn_1_in(btn_1_in),
    .btn_2_in(btn_2_in),
    .btn_3_in(btn_3_in),
    .count_0_out(count_0_out),
    .count_1_out(count_1_out),
    .count_2_out(count_2_out),
    .count_3_out(count_3_out)
);

always #(T/2) clk <= !clk;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, pulse_adder_tb);

    clk <= 1'b1;
    rst <= 1'b1;
    btn_0_in <= 1'b0;
    btn_1_in <= 1'b0;
    btn_2_in <= 1'b0;
    btn_3_in <= 1'b0;
    #(T);
    rst <= 1'b0;

    for (i = 0 ; i < 16 ; i++) begin
        btn_0_in <= 1'b1;
        #(T);
        btn_0_in <= 1'b0;
        #(T);
    end
    btn_0_in <= 1'b0;

    for (i = 0 ; i < 16 ; i++) begin
        btn_1_in <= 1'b1;
        #(T);
        btn_1_in <= 1'b0;
        #(T);
    end
    btn_1_in <= 1'b0;
    
    for (i = 0 ; i < 16 ; i++) begin
        btn_2_in <= 1'b1;
        #(T);
        btn_2_in <= 1'b0;
        #(T);
    end
    btn_2_in <= 1'b0;

    for (i = 0 ; i < 16 ; i++) begin
        btn_3_in <= 1'b1;
        #(T);
        btn_3_in <= 1'b0;
        #(T);
    end
    btn_3_in <= 1'b0;


    $finish();
end

endmodule