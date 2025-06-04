library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity led_fader is
    port (
        clk         : in  std_logic; -- Reloj del sistema (12 MHz)
        rst_n       : in  std_logic; -- Reset asíncrono, activo en bajo
        led_1_out   : out std_logic; -- Salida para el LED 1
        led_2_out   : out std_logic; -- Salida para el LED 2
        led_3_out   : out std_logic;  -- Salida para el LED 3
        led_4_out   : out std_logic  -- Salida para el LED 4
    );
end entity led_fader;

architecture behavioral of led_fader is

    -- Frecuencia del reloj del sistema
    constant SYS_CLK_FREQ : natural := 12_000_000; -- 12 MHz

    -- Configuración del PWM
    constant PWM_BITS           : natural := 8;
    constant PWM_MAX_VALUE      : natural := 2**PWM_BITS - 1; -- 255 para 8 bits (0 a 255)
    -- Prescaler para el reloj del PWM:
    -- Frec_PWM_ciclo = SYS_CLK_FREQ / (PWM_CLK_PRESCALER_MAX + 1)
    -- Frec_PWM_señal = Frec_PWM_ciclo / (PWM_MAX_VALUE + 1)
    -- Objetivo Frec_PWM_señal ~1kHz: 12MHz / ((N+1) * 256) = 1kHz => N+1 = 12000/256 = 46.875
    -- Escogemos N+1 = 47, entonces N = 46.
    constant PWM_CLK_PRESCALER_MAX : natural := 46; -- Contador de 0 a 46 (47 ciclos)
                                                -- Frec_PWM_señal = 12MHz / (47 * 256) ~ 997 Hz
    signal pwm_clk_prescaler_cnt : natural range 0 to PWM_CLK_PRESCALER_MAX := 0;
    signal pwm_counter           : natural range 0 to PWM_MAX_VALUE       := 0;
    signal pwm_tick              : std_logic := '0'; -- Pulso para incrementar pwm_counter

    -- Configuración del Fundido (Fade)
    constant TOTAL_SEQUENCE_TIME_S  : real    := 4.0;   -- 1 segundo para la secuencia 
    constant NUM_STATES       : natural := 4;     -- 
    constant TIME_PER_STATE_S : real    := TOTAL_SEQUENCE_TIME_S / real(NUM_STATES); 

    -- Pasos de brillo para un ciclo completo de fundido (0 -> MAX -> 0)
    constant BRIGHTNESS_LEVELS      : natural := PWM_MAX_VALUE + 1; -- 256 niveles (0 a 255)
    constant FADE_STEPS_PER_LED   : natural := 2 * BRIGHTNESS_LEVELS; -- 512 pasos (subir y bajar)

    -- Prescaler para la actualización del brillo:
    constant CYCLES_PER_STEP_REAL : real := (TIME_PER_STATE_S * real(SYS_CLK_FREQ)) / real(FADE_STEPS_PER_LED);

    -- Prescaler para la actualización del brillo:
    constant BRIGHTNESS_UPDATE_PRESCALER_MAX : natural := natural(floor(CYCLES_PER_STEP_REAL)) - 1;
    
    signal brightness_update_prescaler_cnt : natural range 0 to BRIGHTNESS_UPDATE_PRESCALER_MAX := 0;
    signal brightness_update_tick          : std_logic := '0'; -- Pulso para actualizar el nivel de brillo

    -- Máquina de estados para la secuencia
    type led_state_type is (STATE_FADE_L1, STATE_FADE_L2, STATE_FADE_L3, STATE_FADE_L4);
    signal current_led_state : led_state_type := STATE_FADE_L1;

    -- Ciclos de trabajo (duty cycles)
    signal duty_cycle_led1 : natural range 0 to PWM_MAX_VALUE := 0;
    signal duty_cycle_led2 : natural range 0 to PWM_MAX_VALUE := 0;
    signal duty_cycle_led3 : natural range 0 to PWM_MAX_VALUE := 0;
    signal duty_cycle_led4 : natural range 0 to PWM_MAX_VALUE := 0;

    -- Brillo actual y dirección del fundido
    signal current_brightness     : natural range 0 to PWM_MAX_VALUE := 0;
    type fade_direction_type is (DIR_UP, DIR_DOWN);
    signal current_fade_direction : fade_direction_type := DIR_UP;

begin

    -- Proceso para generar el 'tick' del contador PWM
    pwm_clk_gen_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            pwm_clk_prescaler_cnt <= 0;
            pwm_tick <= '0';
        elsif rising_edge(clk) then
            pwm_tick <= '0'; -- El tick dura un solo ciclo de reloj
            if pwm_clk_prescaler_cnt = PWM_CLK_PRESCALER_MAX then
                pwm_clk_prescaler_cnt <= 0;
                pwm_tick <= '1'; -- Genera un pulso para el contador PWM
            else
                pwm_clk_prescaler_cnt <= pwm_clk_prescaler_cnt + 1;
            end if;
        end if;
    end process pwm_clk_gen_proc;

    -- Proceso del contador PWM (0 a PWM_MAX_VALUE)
    pwm_counter_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            pwm_counter <= 0;
        elsif rising_edge(clk) then
            if pwm_tick = '1' then
                if pwm_counter = PWM_MAX_VALUE then
                    pwm_counter <= 0;
                else
                    pwm_counter <= pwm_counter + 1;
                end if;
            end if;
        end if;
    end process pwm_counter_proc;

    -- Generación de la salida PWM para cada LED (Activo en bajo)
    -- El LED se ENCIENDE ('1') cuando pwm_counter < duty_cycle
    led_1_out <= '1' when pwm_counter < duty_cycle_led1 else '0';
    led_2_out <= '1' when pwm_counter < duty_cycle_led2 else '0';
    led_3_out <= '1' when pwm_counter < duty_cycle_led3 else '0';
    led_4_out <= '1' when pwm_counter < duty_cycle_led4 else '0';

    -- Proceso para generar el 'tick' de actualización de brillo (más lento)
    brightness_update_clk_gen_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            brightness_update_prescaler_cnt <= 0;
            brightness_update_tick <= '0';
        elsif rising_edge(clk) then
            brightness_update_tick <= '0'; -- El tick dura un solo ciclo de reloj
            if brightness_update_prescaler_cnt = BRIGHTNESS_UPDATE_PRESCALER_MAX then
                brightness_update_prescaler_cnt <= 0;
                brightness_update_tick <= '1'; -- Genera un pulso para actualizar el brillo
            else
                brightness_update_prescaler_cnt <= brightness_update_prescaler_cnt + 1;
            end if;
        end if;
    end process brightness_update_clk_gen_proc;

    -- Lógica principal del fading y máquina de estados
    fading_logic_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_led_state    <= STATE_FADE_L1;
            current_brightness   <= 0;
            current_fade_direction <= DIR_UP;
            duty_cycle_led1         <= 0;
            duty_cycle_led2         <= 0;
            duty_cycle_led3         <= 0;
            duty_cycle_led4         <= 0;
        elsif rising_edge(clk) then
            if brightness_update_tick = '1' then
                -- Actualizar el nivel de brillo y la dirección del fundido
                if current_fade_direction = DIR_UP then
                    if current_brightness < PWM_MAX_VALUE then
                        current_brightness <= current_brightness + 1;
                    else -- Alcanzó el brillo máximo (255)
                        current_fade_direction <= DIR_DOWN;
                        -- current_brightness permanece en MAX_VALUE por un paso de actualización
                    end if;
                else -- current_fade_direction = DIR_DOWN
                    if current_brightness > 0 then
                        current_brightness <= current_brightness - 1;
                    else -- Alcanzó el brillo mínimo (0)
                        current_fade_direction <= DIR_UP; -- Preparar para el siguiente fundido hacia arriba
                        -- Transición al siguiente estado de color
                        case current_led_state is
                            when STATE_FADE_L1 =>
                                current_led_state <= STATE_FADE_L2;
                            when STATE_FADE_L2 =>
                                current_led_state <= STATE_FADE_L3;
                            when STATE_FADE_L3 =>
                                current_led_state <= STATE_FADE_L4;
                            when STATE_FADE_L4 =>
                                current_led_state <= STATE_FADE_L1;
                        end case;
                        -- El brillo ya es 0, se asignará al nuevo color activo
                    end if;
                end if;

                -- Asignar el brillo actual al LED correspondiente según el estado
                -- y apagar los otros LEDs.
                case current_led_state is
                    when STATE_FADE_L1 =>
                        duty_cycle_led1 <= current_brightness;
                        duty_cycle_led2 <= 0;
                        duty_cycle_led3 <= 0;
                        duty_cycle_led4 <= 0;

                    when STATE_FADE_L2 =>
                        duty_cycle_led1 <= 0;
                        duty_cycle_led2 <= current_brightness;
                        duty_cycle_led3 <= 0;
                        duty_cycle_led4 <= 0;

                    when STATE_FADE_L3 =>
                        duty_cycle_led1 <= 0;
                        duty_cycle_led2 <= 0;
                        duty_cycle_led3 <= current_brightness;
                        duty_cycle_led4 <= 0;

                    when STATE_FADE_L4 =>
                        duty_cycle_led1 <= 0;
                        duty_cycle_led2 <= 0;
                        duty_cycle_led3 <= 0;
                        duty_cycle_led4 <= current_brightness;
                end case;
            end if;
        end if;
    end process fading_logic_proc;

end architecture behavioral;