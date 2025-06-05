





module display_driver #(
    parameter PRESCALER_BITS = 14
) (
    input wire       clk,
    input wire       rst,
    input wire [6:0] digit_0_in,
    input wire [6:0] digit_1_in,
    input wire [6:0] digit_2_in,
    input wire [6:0] digit_3_in,
    input wire [3:0] dp_in,  
    output reg [3:0] en_disp,
    output reg [7:0] digit_out
);

// 12 MHz / 2^14 = 732 Hz
// 12 MHz / 2^16 = 183 Hz
// 12 MHz / 2^22 = 3 Hz


reg [PRESCALER_BITS-1:0] r_reg;
wire [PRESCALER_BITS-1:0] r_next;

//Lógica del contador.
always @ (posedge clk, posedge rst)
    if (rst)
        r_reg <= {PRESCALER_BITS{1'b0}};
    else
        r_reg <= r_next;

assign r_next = r_reg + 1 ;

//Lógica de selección de display
always @(*)
    case (r_reg[PRESCALER_BITS-1: PRESCALER_BITS-2])
    2'b00:
        begin
            en_disp = 4'b1110;
            digit_out = {dp_in[0], digit_0_in};
        end
    2'b01:
        begin
            en_disp = 4'b1101;
            digit_out = {dp_in[1], digit_1_in};
        end
    2'b10:
        begin
            en_disp = 4'b1011;
            digit_out = {dp_in[2], digit_2_in};
        end
    default:
        begin
            en_disp = 4'b0111;
            digit_out = {dp_in[3], digit_3_in};
        end
endcase

endmodule