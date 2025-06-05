

module pulse_adder
(
    input wire clk,  
    input wire rst,  
    input wire btn_0_in,  
    input wire btn_1_in,  
    input wire btn_2_in,  
    input wire btn_3_in,  
    output reg [3:0] count_0_out,
    output reg [3:0] count_1_out,
    output reg [3:0] count_2_out,
    output reg [3:0] count_3_out
);

reg [15:0] pulse_count;
reg [15:0] next_pulse_count;

//Lógica secuencial
always @(posedge clk, posedge rst) begin
    if (rst) begin
        pulse_count <= {16{1'b0}};
    end else begin
        pulse_count <= next_pulse_count;
    end
end

reg [15:0] increment;

//Lógica combinacional de estado siguiente
always @(*) begin
    increment = {3'b000, btn_3_in, 3'b000, btn_2_in, 3'b000, btn_1_in, 3'b000, btn_0_in};
        
    next_pulse_count = pulse_count + increment;
end

//Lógica combinacional de salida
always @(*) begin
    count_0_out = pulse_count[3:0];
    count_1_out = pulse_count[7:4];
    count_2_out = pulse_count[11:8];
    count_3_out = pulse_count[15:12];
end

endmodule
