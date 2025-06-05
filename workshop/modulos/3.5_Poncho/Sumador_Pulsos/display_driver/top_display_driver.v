module top_display_driver #(
    parameter PRESCALER_BITS = 14
) (
    input wire clk, 
    input wire rst,
    input wire [3:0] hex_0_in,
    input wire [3:0] hex_1_in,
    input wire [3:0] hex_2_in,
    input wire [3:0] hex_3_in,
    input wire [3:0] dp_in,
    output wire [3:0] en_disp,
    output wire [7:0] digit_out
);



wire [6:0] digit_0;
wire [6:0] digit_1;
wire [6:0] digit_2;
wire [6:0] digit_3;

hex_to_7seg decoder0 (
    .hex(hex_0_in),
    .seg(digit_0)
);

hex_to_7seg decoder1 (
    .hex(hex_1_in),
    .seg(digit_1)
);

hex_to_7seg decoder2 (
    .hex(hex_2_in),
    .seg(digit_2)
);

hex_to_7seg decoder3 (
    .hex(hex_3_in),
    .seg(digit_3)
);

display_driver #(
    .PRESCALER_BITS(PRESCALER_BITS)
) display_mux (
    .clk(clk),
    .rst(rst),
    .digit_0_in(digit_0),
    .digit_1_in(digit_1),
    .digit_2_in(digit_2),
    .digit_3_in(digit_3),
    .dp_in(dp_in),
    .en_disp(en_disp),
    .digit_out(digit_out)
);

endmodule