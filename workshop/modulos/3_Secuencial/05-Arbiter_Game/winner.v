/*------------------------------------------------------------------------
---- Module:  winner                                                  ----
---- Description: this is a sequential circuit using a counter as     ----
----     prescaler to reduce clock frequency and some extra logic to  ----
----     display the winner player at the output ports connected to   ----
----     LEDs. The LEDs will shift left or right depending on which   ----
----     player won the game.                                         ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies: None                                               ----
------------------------------------------------------------------------*/

module winner
#(
    parameter CLOCK_FREQ      = 12000000,
    parameter PRESCALER_COUNT = CLOCK_FREQ/4
)
(
    input reset,
    input clk,
    input w1_in,
    input w2_in,
    output reg w_done_out,
    output reg [3:0] leds_out
);

//Parámetros locales
localparam N_BITS_PRESCALER    = $clog2(PRESCALER_COUNT);
localparam N_BITS_TIMEOUT_CNTR = 4;
//Contador prescaler
reg [N_BITS_PRESCALER-1:0] prescaler_cntr;
reg prescaler_tc;
//Contador timeout
reg [N_BITS_TIMEOUT_CNTR-1:0] timeout_cntr;
//Registro de desplazamiento
reg [3:0] shift_reg;

//Prescaler
always @ (posedge clk, posedge reset)
begin
    if(reset)
    begin
        prescaler_cntr <= {N_BITS_PRESCALER{1'b0}};
        prescaler_tc   <= 1'b0;
    end
    else
    begin
        if(prescaler_cntr >= PRESCALER_COUNT-1)
        begin
            prescaler_cntr <= {N_BITS_PRESCALER{1'b0}};
            prescaler_tc   <= 1'b1;
        end
        else
        begin
            prescaler_cntr <= prescaler_cntr+1;
            prescaler_tc   <= 1'b0;
        end
    end
end

//Registro de desplazamiento
always @ (posedge clk, posedge reset)
begin
    if(reset)
        shift_reg <= 4'b0010;
    else if(prescaler_tc)
    begin
        if(w1_in && !w2_in)
            shift_reg <= {shift_reg[2:0],shift_reg[3]};
        else if(!w1_in && w2_in)
            shift_reg <= {shift_reg[0],shift_reg[3:1]};
    end
end

//Timeout
always @ (posedge clk, posedge reset)
begin
    if(reset)
        timeout_cntr <= {N_BITS_TIMEOUT_CNTR{1'b0}};
    else if(prescaler_tc && ~&timeout_cntr)
        timeout_cntr <= timeout_cntr+1;
end

//Salidas
always @ (posedge clk, posedge reset)
begin
    if(reset)
    begin
        leds_out   <= 4'b0000;
        w_done_out <= 1'b0;
    end
    else if(prescaler_tc)
    begin
        leds_out   <= shift_reg;
        w_done_out <= &timeout_cntr;
    end
end

endmodule