`include "contador.v"
`include "debounce_fsm.v"

//wrapper para poder mostrar el mismo dígito en los diferentes display
//usando un solo juego de llaves
module top #(
    parameter CLK_FREQ_HZ = 12000000,
    parameter CLK_SND = 12000000,
    parameter DEBOUNCE_TIME_MS = 10
) (
    input wire clk, reset,
    input wire [3:0] hex,
    input wire [3:0] dp_in,
    output wire [3:0] an,
    output wire [7:0] sseg
);

wire filtered_btn;

debounce_fsm #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
) btnrst (
    .clk(clk),
    .rst(rst),
    .signal_in(reset),
    .signal_out(filtered_btn)
);

disp_hex_mux  #(
    .CLK_SND(CLK_SND)
) mux1 (
    .clk(clk),
    .reset(filtered_btn),
    .hex0(hex),
    .hex1(hex),
    .hex2(hex),
    .hex3(hex),
    .dp_in(dp_in),
    .an(an),
    .sseg(sseg)
);

endmodule
