`timescale 1 ns/10 ps
`include "hex_to_7seg.v"
`include "display_driver.v"
`include "top_display_driver.v"

module top_display_driver_tb ();
    
localparam T = 10;
localparam PRESCALER_BITS = 6;

reg clk; 
reg rst;
reg [3:0] hex_0_in;
reg [3:0] hex_1_in;
reg [3:0] hex_2_in;
reg [3:0] hex_3_in;
reg [3:0] dp_in;
wire [3:0] en_disp;
wire [7:0] digit_out;


top_display_driver #(
    .PRESCALER_BITS(PRESCALER_BITS)
) dut (
    .clk(clk),
    .rst(rst),
    .hex_0_in(hex_0_in),
    .hex_1_in(hex_1_in),
    .hex_2_in(hex_2_in),
    .hex_3_in(hex_3_in),
    .dp_in(dp_in),
    .en_disp(en_disp),
    .digit_out(digit_out)
);

always #(T/2) clk <= !clk;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, top_display_driver_tb);

    clk <= 1'b1;
    rst <= 1'b1;
    dp_in <= 4'h0;
    hex_0_in <= 4'h0;
    hex_1_in <= 4'h0;
    hex_2_in <= 4'h0;
    hex_3_in <= 4'h0;
    #(T);
    rst <= 1'b0;
    #(T);

    dp_in <= 4'ha;
    hex_0_in <= 4'h1;
    hex_1_in <= 4'h5;
    hex_2_in <= 4'ha;
    hex_3_in <= 4'hf;

    #((2**PRESCALER_BITS)*T);


    $finish();
end


endmodule