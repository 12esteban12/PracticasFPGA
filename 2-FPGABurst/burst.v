/*
 * Módulo: PwmFrequencySwitcher
 * Descripción: Genera una señal PWM que alterna entre dos frecuencias (FREQ_A y FREQ_B)
 * después de un número específico de pulsos en cada una.
 */
module PwmFrequencySwitcher #(
    // --- Parámetros de Configuración ---
    parameter CLK_SISTEMA_FREQ   = 12_000_000,   // Frecuencia del reloj del sistema en Hz (ej. 12 MHz)
    parameter FREQ_A             = 10,         // Frecuencia para el estado A en Hz
    parameter PULSES_A           = 10,           // Número de pulsos a generar en estado A
    parameter FREQ_B             = 5,         // Frecuencia para el estado B en Hz
    parameter PULSES_B           = 20,           // Número de pulsos a generar en estado B
    parameter DUTY_CYCLE_PERCENT = 50            // Ciclo de trabajo de la señal PWM (0 a 100)
)(
    input  wire clk,
    input  wire rst_n,
    output reg  pwm_out
);

    // --- Constantes Locales Calculadas ---
    // Se calculan en tiempo de compilación a partir de los parámetros.

    // Valores máximos del contador de período para cada frecuencia
    localparam PERIODO_A_MAX = (CLK_SISTEMA_FREQ / FREQ_A) - 1;
    localparam PERIODO_B_MAX = (CLK_SISTEMA_FREQ / FREQ_B) - 1;

    // Valores de comparación para el ciclo de trabajo en cada frecuencia
    localparam DUTY_A_VALUE = (PERIODO_A_MAX * DUTY_CYCLE_PERCENT) / 100;
    localparam DUTY_B_VALUE = (PERIODO_B_MAX * DUTY_CYCLE_PERCENT) / 100;

    // Determinar el ancho de los contadores para que no haya desborde
    localparam PERIODO_WIDTH = (PERIODO_A_MAX > PERIODO_B_MAX) ? $clog2(PERIODO_A_MAX + 1) : $clog2(PERIODO_B_MAX + 1);
    localparam PULSE_WIDTH   = (PULSES_A > PULSES_B) ? $clog2(PULSES_A) : $clog2(PULSES_B);


    // --- FSM: Declaración de Estados ---
    localparam STATE_A = 1'b0;
    localparam STATE_B = 1'b1;


    // --- Señales Internas ---
    
    // Registros de la FSM
    reg state, next_state;

    // Contadores
    reg [PERIODO_WIDTH-1:0] period_counter;
    reg [PULSE_WIDTH-1:0]   pulse_counter;

    // Señales de control que la FSM genera
    reg [PERIODO_WIDTH-1:0] current_period_max;
    reg [PERIODO_WIDTH-1:0] current_duty_value;
    reg reset_pulse_counter;

    // Señal para detectar el fin de un ciclo PWM
    wire end_of_cycle_tick;


    // --- Lógica del Diseño ---

    // 1. Registro de estado de la FSM (lógica secuencial)
    // Actualiza el estado actual en cada flanco de reloj o con el reset.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_A; // Estado inicial al resetear
        end else begin
            state <= next_state;
        end
    end

    // 2. Lógica Combinacional de la FSM
    // Determina el próximo estado y las señales de control basadas en el estado actual y las entradas.
    always @(*) begin
        // Valores por defecto
        next_state = state;
        reset_pulse_counter = 1'b0;
        
        // Asigna la configuración según el estado actual
        case (state)
            STATE_A: begin
                current_period_max = PERIODO_A_MAX;
                current_duty_value = DUTY_A_VALUE;
                
                // Lógica de transición: si se alcanza el número de pulsos, cambia de estado
                if (pulse_counter >= PULSES_A -1 && end_of_cycle_tick) begin
                    next_state = STATE_B;
                    reset_pulse_counter = 1'b1; // Resetea el contador de pulsos en la transición
                end
            end
            STATE_B: begin
                current_period_max = PERIODO_B_MAX;
                current_duty_value = DUTY_B_VALUE;
                
                // Lógica de transición: si se alcanza el número de pulsos, cambia de estado
                if (pulse_counter >= PULSES_B -1 && end_of_cycle_tick) begin
                    next_state = STATE_A;
                    reset_pulse_counter = 1'b1; // Resetea el contador de pulsos en la transición
                end
            end
        endcase
    end
    
    // 3. Generador de Tick de Fin de Ciclo
    // Genera un pulso de un ciclo de reloj cuando el contador de período alcanza su máximo.
    assign end_of_cycle_tick = (period_counter == current_period_max);

    // 4. Lógica de los Contadores y Salida PWM (lógica secuencial principal)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Estado de reset
            period_counter <= 0;
            pulse_counter  <= 0;
            pwm_out        <= 0;
        end else begin
            // Lógica del contador de período (para generar la frecuencia)
            if (end_of_cycle_tick) begin
                period_counter <= 0;
            end else begin
                period_counter <= period_counter + 1;
            end

            // Lógica del contador de pulsos (para contar ciclos PWM)
            if (reset_pulse_counter) begin
                pulse_counter <= 0;
            end else if (end_of_cycle_tick) begin
                pulse_counter <= pulse_counter + 1;
            end

            // Lógica de la salida PWM
            pwm_out <= (period_counter < current_duty_value);
        end
    end

endmodule