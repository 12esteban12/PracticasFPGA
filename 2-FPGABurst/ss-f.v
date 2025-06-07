/*
 * Módulo: PwmFrequencySwitcher (con Soft-Start)
 * Descripción: Genera una señal PWM con una fase de arranque suave que introduce
 * gradualmente pulsos de una segunda frecuencia, antes de entrar en un ciclo normal.
 */
module PwmFrequencySwitcher #(
    // --- Parámetros de Configuración ---
    parameter CLK_SISTEMA_FREQ   = 12_000_000,   // Frecuencia del reloj del sistema en Hz (ej. 12 MHz)
    parameter FREQ_A             = 10,           // Frecuencia para el estado A en Hz
    parameter PULSES_A           = 10,           // Número de pulsos a generar en estado A
    parameter FREQ_B             = 2,            // Frecuencia para el estado B en Hz
    parameter PULSES_B           = 5,            // Número de pulsos a generar en estado B
    parameter DUTY_CYCLE_PERCENT = 50,           // Ciclo de trabajo de la señal PWM (0 a 100)
    parameter SOFTSTART_MS       = 3000          // Duración del arranque suave en milisegundos
)(
    // --- Puertos de Entrada/Salida ---
    // Basado en el pinout corregido:
    input  wire clk,        // Reloj del sistema (Pin 94)
    input  wire rst_n,      // Reset activo en bajo (Pulsador 1 - Pin 31)
    input  wire fault_in,   // Entrada de falla (Pulsador 2 - Pin 32)
    
    output reg  pwm_out,    // Salida PWM principal (LED 1 - Pin 1)
    
    // Salidas de estado para debugging (ej. LED 2, 3, 4)
    output wire state_A_out,
    output wire state_B_out,
    output wire state_SS_out
);

    // --- Constantes Locales Calculadas ---
    localparam PERIODO_A_MAX = (CLK_SISTEMA_FREQ / FREQ_A) - 1;
    localparam PERIODO_B_MAX = (CLK_SISTEMA_FREQ / FREQ_B) - 1;
    localparam DUTY_A_VALUE = (PERIODO_A_MAX * DUTY_CYCLE_PERCENT) / 100;
    localparam DUTY_B_VALUE = (PERIODO_B_MAX * DUTY_CYCLE_PERCENT) / 100;
    
    // Ancho de los contadores (calculado para el valor más grande posible)
    localparam PERIODO_WIDTH = (PERIODO_A_MAX > PERIODO_B_MAX) ? $clog2(PERIODO_A_MAX + 1) : $clog2(PERIODO_B_MAX + 1);
    localparam PULSE_WIDTH   = (PULSES_A > PULSES_B) ? $clog2(PULSES_A) : $clog2(PULSES_B);
    
    // Para el temporizador de 1ms
    localparam MS_TICK_COUNTER_MAX = (CLK_SISTEMA_FREQ / 1000) - 1;


    // --- FSM: Declaración de Estados ---
    localparam [1:0] STATE_SS_A      = 2'b00; // Soft-Start, fase A
    localparam [1:0] STATE_SS_B      = 2'b01; // Soft-Start, fase B (rampa)
    localparam [1:0] STATE_NORMAL_A  = 2'b10; // Ciclo Normal, fase A
    localparam [1:0] STATE_NORMAL_B  = 2'b11; // Ciclo Normal, fase B


    // --- Señales Internas ---
    reg [1:0] state, next_state;

    // Contadores
    reg [PERIODO_WIDTH-1:0] period_counter;
    reg [PULSE_WIDTH-1:0]   pulse_counter;
    
    // Lógica del Soft-Start
    reg [$clog2(MS_TICK_COUNTER_MAX)-1:0] ms_tick_counter;
    reg [$clog2(SOFTSTART_MS)-1:0]       softstart_timer_ms;
    reg [PULSE_WIDTH-1:0]                target_pulses_b; // Pulsos B a generar en el ciclo SS actual

    // Señales de control que la FSM genera
    reg [PERIODO_WIDTH-1:0] current_period_max;
    reg [PERIODO_WIDTH-1:0] current_duty_value;
    reg reset_pulse_counter;
    
    wire end_of_cycle_tick;

    // --- Lógica del Diseño ---

    // 1. Registro de estado de la FSM (secuencial)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_SS_A; // El estado inicial ahora es el soft-start
        end else begin
            state <= next_state;
        end
    end

    // 2. Lógica Combinacional de la FSM (cerebro)
    always @(*) begin
        // Valores por defecto
        next_state = state;
        reset_pulse_counter = 1'b0;

        case (state)
            STATE_SS_A: begin
                current_period_max = PERIODO_A_MAX;
                current_duty_value = DUTY_A_VALUE;
                if (pulse_counter >= PULSES_A - 1 && end_of_cycle_tick) begin
                    next_state = STATE_SS_B;
                    reset_pulse_counter = 1'b1;
                end
            end
            
            STATE_SS_B: begin
                current_period_max = PERIODO_B_MAX;
                current_duty_value = DUTY_B_VALUE;
                if (pulse_counter >= target_pulses_b - 1 && end_of_cycle_tick) begin
                    // Al terminar la ráfaga de pulsos B, decidimos si continuar el soft-start o pasar al ciclo normal
                    if (softstart_timer_ms >= SOFTSTART_MS) begin
                        next_state = STATE_NORMAL_A; // Fin del soft-start
                    end else begin
                        next_state = STATE_SS_A; // Volver a la fase A del soft-start
                    end
                    reset_pulse_counter = 1'b1;
                end
            end

            STATE_NORMAL_A: begin
                current_period_max = PERIODO_A_MAX;
                current_duty_value = DUTY_A_VALUE;
                if (pulse_counter >= PULSES_A - 1 && end_of_cycle_tick) begin
                    next_state = STATE_NORMAL_B;
                    reset_pulse_counter = 1'b1;
                end
            end

            STATE_NORMAL_B: begin
                current_period_max = PERIODO_B_MAX;
                current_duty_value = DUTY_B_VALUE;
                if (pulse_counter >= PULSES_B - 1 && end_of_cycle_tick) begin
                    next_state = STATE_NORMAL_A;
                    reset_pulse_counter = 1'b1;
                end
            end
        endcase
    end
    
    // 3. Generador de Tick de Fin de Ciclo PWM
    assign end_of_cycle_tick = (period_counter == current_period_max);

    // 4. Lógica de los Contadores y Salida PWM (lógica secuencial principal)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Estado de reset
            period_counter     <= 0;
            pulse_counter      <= 0;
            ms_tick_counter    <= 0;
            softstart_timer_ms <= 0;
            target_pulses_b    <= 0;
            pwm_out            <= 0;
        end else begin
            // --- Lógica del Temporizador de 1ms ---
            if (ms_tick_counter == MS_TICK_COUNTER_MAX) begin
                ms_tick_counter <= 0;
                // Solo incrementa el timer principal si el soft-start no ha terminado
                if (softstart_timer_ms < SOFTSTART_MS) begin
                    softstart_timer_ms <= softstart_timer_ms + 1;
                end
            end else begin
                ms_tick_counter <= ms_tick_counter + 1;
            end

            // --- Lógica de Contadores PWM y de Pulsos ---
            if (reset_pulse_counter) begin
                pulse_counter <= 0;
            end else if (end_of_cycle_tick) begin
                pulse_counter <= pulse_counter + 1;
            end
            
            if (end_of_cycle_tick) begin
                period_counter <= 0;
            end else begin
                period_counter <= period_counter + 1;
            end

            // --- Lógica de cálculo de la rampa de pulsos ---
            // Se calcula y actualiza el objetivo de pulsos B justo antes de entrar al estado SS_B
            if (next_state == STATE_SS_B && state == STATE_SS_A) begin
                // Fórmula de la rampa: (tiempo_actual * pulsos_max) / tiempo_total
                // Nota: Esta operación de multiplicación/división puede consumir recursos.
                // Como los parámetros son constantes, el sintetizador puede optimizarlo.
                target_pulses_b <= (softstart_timer_ms * PULSES_B) / SOFTSTART_MS;
            end else if (next_state == STATE_NORMAL_B) begin
                // Para el ciclo normal, el objetivo es siempre el máximo.
                target_pulses_b <= PULSES_B;
            end

            // --- Lógica de la Salida PWM ---
            pwm_out <= (period_counter < current_duty_value);
        end
    end

endmodule