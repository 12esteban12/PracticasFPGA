module debounce_fsm #(
    parameter CLK_FREQ_HZ = 12000000,
    parameter DEBOUNCE_TIME_MS = 10
) (
    input wire clk,
    input wire rst,
    input wire signal_in,
    output wire signal_out
);



//Debo contar hasta que se establezca la señal
//El tiempo por defecto es 10 ms
localparam MAX_COUNT = (CLK_FREQ_HZ*DEBOUNCE_TIME_MS)/1000;
localparam N_BITS_COUNT = $clog2(MAX_COUNT);

reg timer_clr;
reg timer_ena;
reg [N_BITS_COUNT-1:0] count_reg;
reg timer_tc;
reg r_next;
reg r_reg;

//FSM
localparam N_BITS_STATES = 3;
localparam [N_BITS_STATES-1:0] STATE_IDLE = 3'b000,
                               STATE_ZERO = 3'b001,
                               STATE_ONE  = 3'b010,
                               STATE_WAIT_ZERO = 3'b011,
                               STATE_WAIT_ONE = 3'b100,
                               STATE_COMPARE_ZERO = 3'b101,
                               STATE_COMPARE_ONE = 3'b110;

reg [N_BITS_STATES-1:0] state;
reg [N_BITS_STATES-1:0] next_state;



always @(posedge clk) begin
    if (timer_clr) begin
        timer_tc <= 1'b0;
        count_reg <= {N_BITS_COUNT{1'b0}};
    end else if (timer_ena == 1'b1) begin
        if (count_reg == MAX_COUNT-1) begin
            timer_tc <= 1'b1;
        end else begin
            count_reg <= count_reg + 1;
        end  
    end
end


//------------------------------------------

//Lógica de actualización de estado
always @(posedge clk, posedge rst) begin
    if (rst) begin
        state <= STATE_IDLE;
    end else begin
        state <= next_state;
    end
end

//Lógica de estado siguiente
always @(*) begin
    case (state)
        STATE_IDLE: begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b0;
            if (signal_in == 1'b0) begin
                next_state = STATE_ZERO;
            end else if (signal_in == 1'b1) begin
                next_state = STATE_ONE;
            end else begin
                next_state = STATE_IDLE;
            end
        end
        STATE_ZERO: begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b0;
            if (signal_in == 1'b1) begin
                next_state = STATE_WAIT_ZERO;
            end else begin
                next_state = STATE_ZERO;
            end
        end
        STATE_ONE: begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b1;
            if (signal_in == 1'b0) begin
                next_state = STATE_WAIT_ONE;
            end else begin
                next_state = STATE_ONE;
            end
        end
        STATE_WAIT_ZERO: begin
            timer_clr = 1'b0;
            timer_ena = 1'b1;
            r_next = 1'b0;
            if (timer_tc == 1'b1) begin
                next_state = STATE_COMPARE_ZERO;
            end else begin
                next_state = STATE_WAIT_ZERO;
            end
        end
        STATE_WAIT_ONE: begin
            timer_clr = 1'b0;
            timer_ena = 1'b1;
            r_next = 1'b1;
            if (timer_tc == 1'b1) begin
                next_state = STATE_COMPARE_ONE;
            end else begin
                next_state = STATE_WAIT_ONE;
            end
        end
        STATE_COMPARE_ZERO:begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b0;
            if (signal_in == 1'b1) begin
                next_state = STATE_ONE;
            end else begin
                next_state = STATE_ZERO;
            end
        end
        STATE_COMPARE_ONE:begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b1;
            if (signal_in == 1'b1) begin
                next_state = STATE_ONE;
            end else begin
                next_state = STATE_ZERO;
            end
        end
        default: begin
            timer_clr = 1'b1;
            timer_ena = 1'b0;
            r_next = 1'b0;
            next_state = STATE_IDLE;
        end
    endcase
end


always @(posedge clk, posedge rst) begin
    if (rst) begin
        r_reg <= 1'b0;        
    end else begin
        r_reg <= r_next;
    end
end

assign signal_out = r_reg;

endmodule