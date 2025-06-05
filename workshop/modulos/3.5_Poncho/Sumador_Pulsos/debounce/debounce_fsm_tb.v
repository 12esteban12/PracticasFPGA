`timescale 1 ns/10 ps
`include "debounce_fsm.v"


module debounce_fsm_tb;

localparam T = 10000;

reg clk;
reg rst;
reg signal_in;
wire signal_out;


debounce_fsm #(
    .CLK_FREQ_HZ(100000),
    .DEBOUNCE_TIME_MS(7)
) dut (
    .clk(clk),
    .rst(rst),
    .signal_in(signal_in),
    .signal_out(signal_out)
);


always #(T/2) clk <= !clk;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, debounce_fsm_tb);

    clk <= 1'b1;
    rst <= 1'b0;
    signal_in <= 1'b0;
    #(T);
    rst <= 1'b1;
    #(T);
    rst <= 1'b0;

    signal_in <= 1'b1;
    #(80*T);
    signal_in <= 1'b0;
    #(20*T);
    signal_in <= 1'b1;
    #(90*T);
    signal_in <= 1'b0;
    #(10*T);
    signal_in <= 1'b1;
    #(90*T);
    signal_in <= 1'b0;
    #(10*T);
    signal_in <= 1'b1;
    #(1000*T);

    signal_in <= 1'b0;
    #(1200*T);
    $finish();
end

endmodule