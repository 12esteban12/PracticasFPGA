module debounce_fsm #(
    parameter CLK_FREQ_HZ = 12000000,
    parameter DEBOUNCE_TIME_MS = 10
) (
    input wire clk,
    input wire rst,
    input wire signal_in,
    output reg signal_out
);

//Contador
//Debo contar hasta que se establezca la señal
//El tiempo por defecto es 10 ms
localparam MAX_COUNT = (CLK_FREQ_HZ*DEBOUNCE_TIME_MS)/1000;
localparam N_BITS_COUNT = $clog2(MAX_COUNT);

reg clr_timer;
reg en_counter;
reg [N_BITS_COUNT-1:0] count_reg;
wire [N_BITS_COUNT-1:0] next_reg;
reg max_count_tick;

//El contador avanza solo si está habilitado
assign next_reg = (en_counter == 1'b1) ? (count_reg+1):(count_reg);
always @(posedge clk) begin
    if (clr_timer) begin
        count_reg <= {N_BITS_COUNT{1'b0}};
        max_count_tick <= 1'b0;
    end else begin
        if (count_reg == MAX_COUNT-1) begin
            max_count_tick <= 1'b1;
        end else begin
            max_count_tick <= 1'b0;
        end

    count_reg <= next_reg;     
    end
end


//------------------------------------------



//FSM
localparam N_BITS_STATES = 3;
localparam [N_BITS_STATES-1:0] STATE_IDLE = 3'b000,
                               STATE_WAIT = 3'b001,
                               STATE_ONE  = 3'b010,
                               STATE_ZERO = 3'b100;

reg [N_BITS_STATES-1:0] state;
reg [N_BITS_STATES-1:0] next_state;

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
            if (signal_in == 1'b1) begin
                en_counter = 1'b1;
                clr_timer = 1'b1;
                next_state = STATE_WAIT;
            end else begin
                en_counter = 1'b1;
                clr_timer = 1'b1;
                next_state = STATE_WAIT;
            end
        end
        STATE_WAIT: begin
            if (signal_in == 1'b1 && max_count_tick == 1'b1) begin
                en_counter = 1'b0;
                clr_timer = 1'b1;
                next_state = STATE_ONE;
            end else if (signal_in == 1'b0 && max_count_tick == 1'b1) begin
                en_counter = 1'b0;
                clr_timer = 1'b1;
                next_state = STATE_ZERO;
            end else begin
                //Todavía no paso DEBOUNCE_TIME_MS, no cambio de estado
                en_counter = 1'b1;
                clr_timer = 1'b0;
                next_state = STATE_WAIT;
            end
        end
        STATE_ONE: begin
            if (signal_in == 1'b1) begin
                //Autotransición
                en_counter = 1'b0;
                clr_timer = 1'b1;
                next_state = STATE_ONE;
            end else begin
                en_counter = 1'b1;
                clr_timer = 1'b0;
                next_state = STATE_WAIT;
            end
        end
        STATE_ZERO: begin
            if (signal_in == 1'b0) begin
                //Autotransición
                en_counter = 1'b0;
                clr_timer = 1'b1;
                next_state = STATE_ZERO;
            end else begin
                en_counter = 1'b1;
                clr_timer = 1'b0;
                next_state = STATE_WAIT;
            end
        end
        default: begin
            en_counter = 1'b0;
            clr_timer = 1'b1;
            next_state = STATE_IDLE;
        end
    endcase
end

// Definición de salida
always @(posedge clk) begin
    case (state)
        STATE_WAIT : signal_out <= signal_out;
        STATE_ONE : signal_out <= 1'b1;
        STATE_ZERO : signal_out <= 1'b0;
        default: signal_out <= 1'b0;
    endcase 
end
//------------------------------------------


endmodule