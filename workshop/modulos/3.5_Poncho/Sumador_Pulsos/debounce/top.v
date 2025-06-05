`include "debounce_fsm.v"

module top (
    input wire clk,
    input wire rst,
    input wire signal_in,
    output wire signal_out,
    output wire en_disp_out
);

// module debounce_fsm #(
//     parameter CLK_FREQ_HZ = 12000000,
//     parameter DEBOUNCE_TIME_MS = 10
// ) (
//     input wire clk,
//     input wire rst,
//     input wire signal_in,
//     output reg signal_out
// );

debounce_fsm debouncer (
    .clk(clk),
    .rst(rst),
    .signal_in(signal_in),
    .signal_out(signal_out)
);

assign en_disp_out = 1'b0;

endmodule