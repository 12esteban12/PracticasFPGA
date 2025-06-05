/*------------------------------------------------------------------------
---- Module:  arbiter_game_fsm                                        ----
---- Description: this is the FSM that controls the logic of the game ----
----     It is proposed to students as a practice of FSM design       ----
---- Author/s:  student                                               ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies: None                                               ----
------------------------------------------------------------------------*/

module arbiter_game_fsm
(
  //Entradas
  input wire req1,
  input wire req2,
  input wire cd_done,
  input wire w_done,
  input wire rst_in_n,
  input wire clk,
  //Salidas
  output gnt1_out,
  output gnt2_out,
  output cd_rst_out,
  output w_rst_out,
  output leds_rst_out,
  output leds_sel_out
);

//Bits de representacion de estado
parameter N_BITS_STATE = 3;

//Salidas de la FSM
reg gnt1;
reg gnt2;
reg cd_rst;
reg w_rst;
reg leds_rst;
reg leds_sel;

//Estado actual
reg[N_BITS_STATE-1:0] state;

//Proximo estado
reg[N_BITS_STATE-1:0] next_state;

//Estados del sistema
localparam RESET     = 3'b111 ;
localparam COUNTDOWN = 3'b110 ;
localparam IDLE      = 3'b000 ;
localparam GNT_1     = 3'b001 ;
localparam GNT_2     = 3'b010 ;
localparam WINNER_1  = 3'b011 ;
localparam WINNER_2  = 3'b100 ;
localparam GAME_END  = 3'b101 ;

//Salidas
assign gnt1_out     = gnt1     ;
assign gnt2_out     = gnt2     ;
assign cd_rst_out   = cd_rst   ;
assign w_rst_out    = w_rst    ;
assign leds_rst_out = leds_rst ;
assign leds_sel_out = leds_sel ;

//Definicion combinacional del próximo estado
// TODO ...

//Actualizacion sincronica del estado (bloque constante para todas las FSM)
// TODO...

//Definicion combinacional de las salidas segun el estado actual (Maquina de Moore)
// TODO...

endmodule
