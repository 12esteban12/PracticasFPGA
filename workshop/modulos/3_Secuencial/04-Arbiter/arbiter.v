/*------------------------------------------------------------------------
---- Module:  ARBITER                                                 ----
---- Description: FSM to manage access to Hardware resources          ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

module ARBITER (

  //Entradas
  input wire req1,
  input wire req2,

  //Reset
  input wire rst,
  //Clock
  input wire clk,

  //Salidas
  output reg gnt1,
  output reg gnt2
);

//Bits de representacion de estado
parameter N_BITS_STATE = 2;

//Estado actual
reg[N_BITS_STATE-1:0] state;

//Proximo estado
reg[N_BITS_STATE-1:0] next_state;

//Estados del sistema
localparam IDLE = 2'b00 ;
localparam GNT_1 = 2'b01 ;
localparam GNT_2 = 2'b10 ;
// (localparam permite definir parametetros no configurables externamente)

// Normalmente en ASIC se configura 1 bit por estado posible para simplificar la lógica de estado siguiente.
// (Es decir, ahorrar compuertas). Esta es la regla que se uso para codificar los estados de este ejemplo.
// Sin embargo, en FPGA no es necesario seguir este formato (ya que siempre se usara una LUT),
// y pueden usarse n bits para codificar 2^n estados.
// Lo importante es que el estado IDLE siempre este definido. Sera el estado por default o de arranque de la FSM.

//Definicion combinacional del próximo estado
always @(*) begin

   //Asignación de próximo estado
   case (state)

      IDLE : begin
         if (req1==1'b1 && req2==1'b0) begin
            next_state = GNT_1;
         end else if (req2==1'b1 && req1==1'b0) begin
            next_state = GNT_2;
         end else begin
            next_state = IDLE;
         end
      end

      GNT_1 :begin
         if (req1==1'b1) begin
            next_state = GNT_1;
         end else begin
            next_state = IDLE;
         end
      end

      GNT_2 : begin
         if (req2==1'b1) begin
            next_state = GNT_2;
         end else begin
            next_state = IDLE;
         end
      end

      //Caso por default
      default : next_state = IDLE;
   endcase
end

//Actualizacion sincronica del estado (bloque constante para todas las FSM)
always @(posedge rst or posedge clk) begin
   if (rst==1'b1) begin
      state <= IDLE;
   end else begin
      state <= next_state;
   end
end

//Definicion combinacional de las salidas segun el estado actual (Maquina de Moore)
always @(*) begin
   
   case (state)
      IDLE : begin
         gnt1 = 0;
         gnt2 = 0;
      end

      GNT_1 : begin
         gnt1 = 1;
         gnt2 = 0;
      end

      GNT_2 : begin
         gnt1 = 0;
         gnt2 = 1;
      end
      
      default: begin
         gnt1 = 0;
         gnt2 = 0;
      end
   endcase
end

endmodule
