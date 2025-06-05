/*------------------------------------------------------------------------
---- Module: top_pulse_adder                                          ----
---- Description: This is the top level module for the pulse adder.   ----
----     Pulses are generated using the active low pushbuttons of the ----
----     shield board. The signals  go through a debouncing circuit   ----
----     and an edge detection circuit to make sure only user input   ----
----     is registered.                                               ----
----     The adder circuit sums 1, 16, 256 or 4096 to a register      ----
----     depending on which button is pressed. The current value      ----
----     of the register is shown on the 7 segment displays of the    ----
----     shield.                                                      ----
----     Pressing rst clears the content of the register.             ----
---- Author/s:  Manuel Ayala, Matías I. Monopoli                      ----
---- Last revision: Jun. 2024                                         ----
---- Dependencies:                                                    ----
----     pulse_adder.v                                                ----
----     top_display_driver.v                                          ----
----     debounce_fsm.v                                               ----
----     negedge_detector.v                                           ----
------------------------------------------------------------------------*/


`include "pulse_adder/pulse_adder.v"
`include "display_driver/hex_to_7seg.v"
`include "display_driver/display_driver.v"
`include "display_driver/top_display_driver.v"
`include "debounce/debounce_fsm.v"
`include "negedge_detector/negedge_detector.v"

module top_pulse_adder #(
    parameter CLK_FREQ_HZ = 12000000,
    parameter DEBOUNCE_TIME_MS = 10
) (
    input wire clk, 
    input wire rst,
    input wire btn_0_in,  
    input wire btn_1_in,  
    input wire btn_2_in,  
    input wire btn_3_in,
    output wire [3:0] en_disp,
    output wire [7:0] digit_out,
    output wire rst_led
);

wire rst_inv;

assign rst_inv = ~rst;
assign rst_led = rst_inv;



wire [3:0] filtered_btn;

debounce_fsm #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
) btn0 (
    .clk(clk),
    .rst(rst_inv),
    .signal_in(btn_0_in),
    .signal_out(filtered_btn[0])
);

debounce_fsm #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
) btn1 (
    .clk(clk),
    .rst(rst_inv),
    .signal_in(btn_1_in),
    .signal_out(filtered_btn[1])
);

debounce_fsm #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
) btn2 (
    .clk(clk),
    .rst(rst_inv),
    .signal_in(btn_2_in),
    .signal_out(filtered_btn[2])
);

debounce_fsm #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
) btn3 (
    .clk(clk),
    .rst(rst_inv),
    .signal_in(btn_3_in),
    .signal_out(filtered_btn[3])
);



wire [3:0] negedge_btn;

negedge_detector edge0 (
    .clk(clk),
    .rst(rst_inv),
    .signal(filtered_btn[0]),
    .neg_edge(negedge_btn[0])
);

negedge_detector edge1 (
    .clk(clk),
    .rst(rst_inv),
    .signal(filtered_btn[1]),
    .neg_edge(negedge_btn[1])
);

negedge_detector edge2 (
    .clk(clk),
    .rst(rst_inv),
    .signal(filtered_btn[2]),
    .neg_edge(negedge_btn[2])
);

negedge_detector edge3 (
    .clk(clk),
    .rst(rst_inv),
    .signal(filtered_btn[3]),
    .neg_edge(negedge_btn[3])
);



wire [3:0] count_0;
wire [3:0] count_1;
wire [3:0] count_2;
wire [3:0] count_3;

pulse_adder adder (
    .clk(clk),
    .rst(rst_inv),
    .btn_0_in(negedge_btn[0]),
    .btn_1_in(negedge_btn[1]),
    .btn_2_in(negedge_btn[2]),
    .btn_3_in(negedge_btn[3]),
    .count_0_out(count_0),
    .count_1_out(count_1),
    .count_2_out(count_2),
    .count_3_out(count_3)
);



wire [3:0] dp_in;
assign dp_in = {btn_3_in, btn_2_in, btn_1_in, btn_0_in};

top_display_driver mux1 (
    .clk(clk),
    .rst(rst_inv),
    .hex_0_in(count_0),
    .hex_1_in(count_1),
    .hex_2_in(count_2),
    .hex_3_in(count_3),
    .dp_in(dp_in),
    .en_disp(en_disp),
    .digit_out(digit_out)
);


endmodule
