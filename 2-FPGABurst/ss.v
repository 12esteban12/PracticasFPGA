/*
 * Módulo: PwmFrequencySwitcher
 * Versión: 3.0 (con Soft-Start corregido y Estado de Falla)
 *
 * Descripción: 
 * Genera una señal PWM que, tras un reset, inicia en una fase de "arranque suave".
 * Durante esta fase, introduce gradualmente ráfagas de pulsos de una frecuencia B
 * dentro de un ciclo con una frecuencia A. La duración del arranque es configurable.
 * * Una vez finalizado el arranque suave, la máquina entra en un ciclo de operación normal,
 * alternando ráfagas de pulsos entre la frecuencia A y la frecuencia B.
 * * El módulo incluye un estado de falla que se activa por una entrada externa,
 * deteniendo la salida PWM y señalizando el error visualmente.
 *
 * Autor: Asistente de Programación (con la colaboración de Esteban)
 * Fecha: 2025-06-07
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
    
    // FIX: Cálculo de ancho de bits robusto
    localparam MAX_PULSES = (PULSES_A > PULSES_B) ? PULSES_A : PULSES_B;
    localparam PULSE_WIDTH = $clog2(MAX_PULSES + 1);
    
    localparam PERIODO_WIDTH = (PERIODO_A_MAX > PERIODO_B_MAX) ? $clog2(PERIODO_A_MAX + 1) : $clog2(PERIODO_B_MAX + 1);
    localparam MS_TICK_COUNTER_MAX = (CLK_SISTEMA_FREQ / 1000) - 1;
    
    // Ancho para el acumulador de la rampa
    localparam ACCUM_WIDTH = $clog2(SOFTSTART_MS) + $clog2(PULSES_B);

    // --- FSM: Declaración de Estados ---
    localparam [2:0] STATE_SS_A      = 3'b000;
    localparam [2:0] STATE_SS_B      = 3'b001;
    localparam [2:0] STATE_NORMAL_A  = 3'b010;
    localparam [2:0] STATE_NORMAL_B  = 3'b011;
    localparam [2:0] STATE_FAULT     = 3'b100;

    // --- Señales Internas ---
    reg [2:0] state, next_state;
    reg [PERIODO_WIDTH-1:0] period_counter;
    reg [PULSE_WIDTH-1:0]   pulse_counter;
    
    // Soft-Start
    reg [$clog2(MS_TICK_COUNTER_MAX)-1:0] ms_tick_counter;
    reg [$clog2(SOFTSTART_MS)-1:0]       softstart_timer_ms;
    reg [ACCUM_WIDTH-1:0]                ramp_accumulator;
    reg [PULSE_WIDTH-1:0]                latched_target_pulses_b;

    // Fault
    reg [$clog2(CLK_SISTEMA_FREQ)-1:0] fault_blinker_cnt;
    reg                               fault_led_status;

    // Control
    reg [PERIODO_WIDTH-1:0] current_period_max;
    reg [PERIODO_WIDTH-1:0] current_duty_value;
    reg                       reset_pulse_counter;
    reg                       end_of_cycle_tick_reg; // FIX: Señal registrada

    // --- Asignación de Salidas de Estado (con lógica de parpadeo en falla) ---
    assign state_A_out  = (state == STATE_FAULT) ? fault_led_status : (state == STATE_NORMAL_A || state == STATE_SS_A);
    assign state_B_out  = (state == STATE_FAULT) ? fault_led_status : (state == STATE_NORMAL_B || state == STATE_SS_B);
    assign state_SS_out = (state == STATE_FAULT) ? fault_led_status : (state == STATE_SS_A || state == STATE_SS_B);

    // --- Lógica del Diseño ---

    // 1. Registro de estado de la FSM (secuencial)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= STATE_SS_A;
        else        state <= next_state;
    end

    // 2. Lógica Combinacional de la FSM (cerebro)
    always @(*) begin
        next_state = state;
        reset_pulse_counter = 1'b0;

        if (fault_in) begin
            next_state = STATE_FAULT;
        end else begin
            case (state)
                STATE_SS_A: begin
                    current_period_max = PERIODO_A_MAX;
                    current_duty_value = DUTY_A_VALUE;
                    if (pulse_counter >= PULSES_A - 1 && end_of_cycle_tick_reg) begin
                        next_state = STATE_SS_B;
                        reset_pulse_counter = 1'b1;
                    end
                end
                STATE_SS_B: begin
                    current_period_max = PERIODO_B_MAX;
                    current_duty_value = DUTY_B_VALUE;
                    if (latched_target_pulses_b == 0) begin
                        if (softstart_timer_ms >= SOFTSTART_MS) next_state = STATE_NORMAL_A;
                        else                                    next_state = STATE_SS_A;
                        reset_pulse_counter = 1'b1;
                    end else if (pulse_counter >= latched_target_pulses_b - 1 && end_of_cycle_tick_reg) begin
                        if (softstart_timer_ms >= SOFTSTART_MS) next_state = STATE_NORMAL_A;
                        else                                    next_state = STATE_SS_A;
                        reset_pulse_counter = 1'b1;
                    end
                end
                STATE_NORMAL_A: begin
                    current_period_max = PERIODO_A_MAX;
                    current_duty_value = DUTY_A_VALUE;
                    if (pulse_counter >= PULSES_A - 1 && end_of_cycle_tick_reg) begin
                        next_state = STATE_NORMAL_B;
                        reset_pulse_counter = 1'b1;
                    end
                end
                STATE_NORMAL_B: begin
                    current_period_max = PERIODO_B_MAX;
                    current_duty_value = DUTY_B_VALUE;
                    if (pulse_counter >= PULSES_B - 1 && end_of_cycle_tick_reg) begin
                        next_state = STATE_NORMAL_A;
                        reset_pulse_counter = 1'b1;
                    end
                end
                STATE_FAULT: begin
                    current_period_max = PERIODO_A_MAX;
                    current_duty_value = 0;
                    if (!fault_in) begin
                        next_state = STATE_SS_A;
                    end
                end
            endcase
        end
    end

    // 3. Lógica secuencial principal (Contadores, Salidas, etc.)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Estado de reset
            period_counter          <= 0;
            pulse_counter           <= 0;
            ms_tick_counter         <= 0;
            softstart_timer_ms      <= 0;
            latched_target_pulses_b <= 0;
            ramp_accumulator        <= 0;
            fault_blinker_cnt       <= 0;
            fault_led_status        <= 1'b0;
            pwm_out                 <= 1'b0;
            end_of_cycle_tick_reg   <= 1'b0;
        end else begin
            // FIX: Registrar el tick para romper lazos combinacionales
            end_of_cycle_tick_reg <= (period_counter == current_period_max);

            if (state == STATE_FAULT) begin
                pwm_out <= 1'b0;
                pulse_counter <= 0;
                
                if (fault_blinker_cnt >= CLK_SISTEMA_FREQ - 1) begin
                    fault_blinker_cnt <= 0;
                    fault_led_status <= ~fault_led_status;
                end else begin
                    fault_blinker_cnt <= fault_blinker_cnt + 1;
                end
            end else begin
                fault_blinker_cnt <= 0;
                
                // Lógica del Temporizador de 1ms
                if (ms_tick_counter >= MS_TICK_COUNTER_MAX) begin
                    ms_tick_counter <= 0;
                    if (softstart_timer_ms < SOFTSTART_MS) begin
                        softstart_timer_ms <= softstart_timer_ms + 1;
                    end
                end else begin
                    ms_tick_counter <= ms_tick_counter + 1;
                end

                // Lógica del Acumulador para la Rampa (sin división/multiplicación)
                if (state == STATE_SS_A || state == STATE_SS_B) begin
                    if (ms_tick_counter >= MS_TICK_COUNTER_MAX) begin
                        if (ramp_accumulator >= SOFTSTART_MS - PULSES_B) begin
                            latched_target_pulses_b <= latched_target_pulses_b + 1;
                            ramp_accumulator <= ramp_accumulator + PULSES_B - SOFTSTART_MS;
                        end else begin
                            ramp_accumulator <= ramp_accumulator + PULSES_B;
                        end
                    end
                end
                
                if (state == STATE_NORMAL_A && next_state == STATE_NORMAL_B) begin
                    latched_target_pulses_b <= PULSES_B;
                end

                // Lógica de Contadores y Salida PWM
                if (reset_pulse_counter) begin
                    pulse_counter <= 0;
                end else if (end_of_cycle_tick_reg) begin
                    pulse_counter <= pulse_counter + 1;
                end
                
                if (end_of_cycle_tick_reg) begin
                    period_counter <= 0;
                end else begin
                    period_counter <= period_counter + 1;
                end

                pwm_out <= (period_counter < current_duty_value);
            end
        end
    end
endmodule