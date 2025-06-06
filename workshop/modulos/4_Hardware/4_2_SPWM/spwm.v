/*------------------------------------------------------------------------
---- Modules:  counter, PWM_generator, RAM_DUAL and spwm              ----
---- Description: SPWM generator without PLL                          ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:  None                                              ----
------------------------------------------------------------------------*/

/**************************** Modulo Contador *******************************/

//Parametros y E/S
module counter #(parameter N_bits = 4) (

    //Clock y reset
    input  wire clk,
    input  wire rst,

    //Estado del contador
    output reg[N_bits-1:0] count
);

//Proceso asincronico
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

endmodule //counter

/************************** Modulo Generador PWM ****************************/

//Parametros y E/S
module PWM_generator #(parameter N_bits = 8) (

    // Clock y reset
    input wire clk,
    input wire rst,

    // Duty cycle
    input wire[N_bits-1 : 0] duty,

    // Salida
    output wire PWM_out
);

//Conexiones del contador interno
wire[N_bits-1 : 0] int_cnt_conn;

//Instanciar contador interno
counter int_cnt (.clk(clk),.rst(rst),.count(int_cnt_conn));
defparam int_cnt.N_bits = N_bits;

//Comparador de salida
assign PWM_out = (int_cnt_conn < duty)?(1'b1):(1'b0);

endmodule //PWM_generator

/******************************** Memoria RAM ********************************/

module RAM_DUAL 

  #(parameter WORD_LENGTH = 8,	  //Bits de cada palabra
    parameter ADDR_LENGTH = 8,	  //Bits de direcciones
    parameter MEM_INIT_FILE = "mem_data.mem"  //Archivo de inicializacion de memoria
    )

  (input wire w_clk,				            //Write clock
   input wire r_clk,							//Read clock
   input wire write,			                  //Write enable
   input [ADDR_LENGTH-1 : 0] w_addr,	        //Write address
   input [ADDR_LENGTH-1 : 0] r_addr,	        //Read address
   input wire [WORD_LENGTH-1 : 0] data_in,		//Dato de entrada
   output reg [WORD_LENGTH-1 : 0] data_out);    //Dato de salida
  
  //Bloque de memoria (** denota potencia)
  reg[WORD_LENGTH-1:0] MEMORY[0:2**ADDR_LENGTH-1];

  //LEER EL CONTENIDO DE LA MEMORIA DESDE UN ARCHIVO .mem
    initial begin
        $readmemh(MEM_INIT_FILE, MEMORY);
    end
  
  // Lectura (dominio w_clk)
  always @(posedge w_clk) begin
    if (write==1'b1) begin
      MEMORY[w_addr] <= data_in;
    end
  end
  
  //Escritura (dominio r_clk)
  always @(posedge r_clk) begin
    data_out <= MEMORY[r_addr];
  end

endmodule

/************************** Modulador SPWM (sin PLL) **************************/

module spwm (
    input wire clk,
    input wire rst,
    output wire pwm_out,
    output wire[2:0] dummy
);

// Negar entrada reset
wire global_rst;
assign global_rst = ~rst;

// Anular los otros 3 LEDs
assign dummy = 3'b000;

// Parametros internos del modulo
parameter MEM_CLK_DIVIDER_BITS = 19;
parameter ADDRESS_BITS  = 8;
parameter MEM_WORD_BITS = 8;

// Linea interna de clock para barrido de memoria
wire[MEM_CLK_DIVIDER_BITS-1:0] internal_mem_clk;

// Direccion de memoria de lectura
wire[ADDRESS_BITS-1:0] addr;

// Duty cycle interno
wire[MEM_WORD_BITS-1:0] dc;

////// Instanciar y conectar componentes

// Instanciar divisor de frecuencia para obtener un clock de 190 Hz
counter divisor_freq(.clk(clk),
                     .rst(global_rst),
                     .count(internal_mem_clk));
defparam divisor_freq.N_bits = MEM_CLK_DIVIDER_BITS;

// Instanciar contador para el barrido de la memoria
counter barrido_mem(.clk(internal_mem_clk[MEM_CLK_DIVIDER_BITS-1]),
                    .rst(global_rst),
                    .count(addr));
defparam barrido_mem.N_bits = ADDRESS_BITS;

// Instanciar memoria RAM
RAM_DUAL my_ram(.r_clk(clk),
               .w_clk(clk),
               .write(1'b0),
               .w_addr(addr),
               .r_addr(addr),
               .data_in(),
               .data_out(dc));

defparam my_ram.WORD_LENGTH = MEM_WORD_BITS;
defparam my_ram.ADDR_LENGTH = ADDRESS_BITS;

// Instanciar generador PWM
PWM_generator pwm(.clk(clk),
                  .rst(global_rst),
                  .duty(dc),
                  .PWM_out(pwm_out));
defparam pwm.N_bits = MEM_WORD_BITS;

endmodule