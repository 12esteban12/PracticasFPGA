module negedge_detector(
    input wire clk,    // Clock signal
    input wire rst,    // Reset signal
    input wire signal, // Input signal to detect edges off
    output reg neg_edge // Output signal for negative edge detection
);

reg signal_d; // Delayed version of the input signal

always @(posedge clk or posedge rst) begin
    if (rst) begin
        signal_d <= 1'b0;
        neg_edge <= 1'b0;
    end else begin
        neg_edge <= ~signal & signal_d;
        signal_d <= signal;
    end
end


endmodule
