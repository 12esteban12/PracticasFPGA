/********************** Modulador SPWM Trifásico **********************/
`include "spwm.v"

module spwm_trifasico (
    input wire clk,
    input wire rst,
    output wire pwm_out_a, // Salida Fase A
    output wire pwm_out_b, // Salida Fase B
    output wire pwm_out_c  // Salida Fase C
);

// Negar entrada reset
wire global_rst;
assign global_rst = ~rst;

// Parametros internos
parameter MEM_CLK_DIVIDER_BITS = 19;
parameter ADDRESS_BITS  = 8;
parameter MEM_WORD_BITS = 8;
localparam PHASE_SHIFT_120 = 85;  // 256 / 3
localparam PHASE_SHIFT_240 = 170; // 256 * 2 / 3

// --- Generador de Direcciones Central (para Fase A) ---

wire [MEM_CLK_DIVIDER_BITS-1:0] internal_mem_clk;
wire [ADDRESS_BITS-1:0]         addr_a; // Dirección base para Fase A

// Instanciar divisor de frecuencia para obtener un clock lento
counter divisor_freq (
    .clk(clk),
    .rst(global_rst),
    .count(internal_mem_clk)
);
defparam divisor_freq.N_bits = MEM_CLK_DIVIDER_BITS;

// Instanciar contador para el barrido de la memoria (Fase A)
counter barrido_mem (
    .clk(internal_mem_clk[MEM_CLK_DIVIDER_BITS-1]),
    .rst(global_rst),
    .count(addr_a)
);
defparam barrido_mem.N_bits = ADDRESS_BITS;


// --- Cálculo de Direcciones para Fase B y Fase C ---

wire [ADDRESS_BITS-1:0] addr_b;
wire [ADDRESS_BITS-1:0] addr_c;

// La suma en Verilog con un ancho de bit fijo se comporta como una operación
// modular, por lo que el desborde (wrap-around) se maneja automáticamente.
assign addr_b = addr_a + PHASE_SHIFT_120;
assign addr_c = addr_a + PHASE_SHIFT_240;


// --- Instancias para cada Fase (A, B, C) ---

wire [MEM_WORD_BITS-1:0] duty_a, duty_b, duty_c;

// --- FASE A ---
RAM_DUAL my_ram_a (
    .r_clk(clk), .w_clk(clk), .write(1'b0),
    .r_addr(addr_a), .data_out(duty_a), .w_addr(8'd0), .data_in(8'd0)
);
defparam my_ram_a.WORD_LENGTH = MEM_WORD_BITS;
defparam my_ram_a.ADDR_LENGTH = ADDRESS_BITS;

PWM_generator pwm_a (
    .clk(clk), .rst(global_rst), .duty(duty_a), .PWM_out(pwm_out_a)
);
defparam pwm_a.N_bits = MEM_WORD_BITS;


// --- FASE B ---
RAM_DUAL my_ram_b (
    .r_clk(clk), .w_clk(clk), .write(1'b0),
    .r_addr(addr_b), .data_out(duty_b), .w_addr(8'd0), .data_in(8'd0)
);
defparam my_ram_b.WORD_LENGTH = MEM_WORD_BITS;
defparam my_ram_b.ADDR_LENGTH = ADDRESS_BITS;

PWM_generator pwm_b (
    .clk(clk), .rst(global_rst), .duty(duty_b), .PWM_out(pwm_out_b)
);
defparam pwm_b.N_bits = MEM_WORD_BITS;


// --- FASE C ---
RAM_DUAL my_ram_c (
    .r_clk(clk), .w_clk(clk), .write(1'b0),
    .r_addr(addr_c), .data_out(duty_c), .w_addr(8'd0), .data_in(8'd0)
);
defparam my_ram_c.WORD_LENGTH = MEM_WORD_BITS;
defparam my_ram_c.ADDR_LENGTH = ADDRESS_BITS;

PWM_generator pwm_c (
    .clk(clk), .rst(global_rst), .duty(duty_c), .PWM_out(pwm_out_c)
);
defparam pwm_c.N_bits = MEM_WORD_BITS;


endmodule