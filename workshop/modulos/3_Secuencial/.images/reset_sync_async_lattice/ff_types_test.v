module ff_types_test
(
    input a,
    input b,
    input rst,
    input ena,
    input clk,
    output c
);

localparam USE_ASYNC = 0;

reg a_reg;
reg b_reg;
reg rst_reg;
reg ena_reg;
reg c_reg;

wire a_xor_b;

always @ (posedge clk)
    a_reg <= a;

always @ (posedge clk)
b_reg <= b;

always @ (posedge clk)
    rst_reg <= rst;

always @ (posedge clk)
    ena_reg <= ena;

assign a_xor_b = a_reg ^ b_reg;

generate
    if(USE_ASYNC)
    begin
        always @ (posedge clk, posedge rst_reg)
        begin
            if(rst_reg)
                c_reg <= 1'b0;
            else if(ena_reg)
                c_reg <= a_xor_b;
        end
    end
    else
    begin
        always @ (posedge clk)
        begin
            if(rst_reg)
                c_reg <= 1'b0;
            else if(ena_reg)
                c_reg <= a_xor_b;
        end
    end
endgenerate

assign c = c_reg;

endmodule