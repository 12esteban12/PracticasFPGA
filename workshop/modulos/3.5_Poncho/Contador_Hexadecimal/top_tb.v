`include "top.v"
`timescale 1ns / 1ps

module top_tb;

    parameter T = 100;
    parameter fclk = 1;
    parameter Tclk = 1;

    reg clk  ;
    reg reset;
    reg [3:0] hex3 ;
    reg [3:0] hex2 ;
    reg [3:0] hex1 ;
    reg [3:0] hex0 ;
    wire [3:0] dp_in;
    wire [3:0] an   ;
    wire [7:0] sseg ;

top #(
    .CLK_FREQ_HZ(12000000),
    .CLK_SND(12),
    .DEBOUNCE_TIME_MS(10)
) uut (
    .clk(clk),
    .reset(reset),
    .hex(hex0),
    .dp_in(dp_in),
    .an(an),
    .sseg(sseg)
);

always #(42) clk <= !clk;

initial begin
    $dumpfile("wf.vcd");
    $dumpvars(0, top_tb);

    clk <= 1'b1;
    reset <= 1'b1;
    hex0 <= 1'b1;

    #100;

    reset <= 1'b0;

    #10000;

    $finish();
end

endmodule
