# Documento Explicativo: Código VHDL para Fade LEDS EDU-CIAA-FPGA

**1. Introducción**

Este documento describe el funcionamiento de un módulo VHDL llamado `led_fader`. El propósito de este módulo es controlar los 4 LEDs de la placa para generar un efecto visual de fade secuencial a través de estos cuatro leds. El diseño está pensado para ser implementado en una FPGA, como la iCE40HX4K presente en la placa EDU-CIAA-FPGA, utilizando un reloj de sistema de 12 MHz.

El efecto visual consiste en:
* El LED 1 aumenta su brillo gradualmente desde apagado hasta el máximo, y luego disminuye su brillo gradualmente hasta apagarse.
* A continuación, el LED 2 realiza la misma secuencia de fundido.
* Luego, el LED 3 realiza la misma secuencia de fundido.
* Finalmente, el LED 4 completa su ciclo de fundido.
* Esta secuencia completa se repite, y cada ciclo completo dura aproximadamente 4 segundo.

---
**2. Estructura del Código VHDL**

El módulo `led_fader` se compone de varias partes clave:

**a. Entidad (`led_fader`)**
Define la interfaz del módulo con el exterior:
* **Puertos de Entrada:**
    * `clk (std_logic)`: Señal de reloj principal del sistema (12 MHz).
    * `rst_n (std_logic)`: Señal de reset asíncrona, activa en bajo. Cuando está en '0', el módulo se reinicia a su estado inicial.
* **Puertos de Salida:**
    * `led_1_out (std_logic)`: Controla el LED 1.
    * `led_2_out (std_logic)`: Controla el LED 2.
    * `led_3_out (std_logic)`: Controla el LED 3.
    * `led_4_out (std_logic)`: Controla el LED 4.
    *(Nota: Estas salidas están diseñadas para ser activas en alto, lo que significa que un '1' enciende el LED y un '0' lo apaga, común en la EDU-CIAA).*

**b. Arquitectura (`behavioral`)**
Contiene la lógica interna del diseño:

* **Constantes Principales:**
    * `SYS_CLK_FREQ`: Define la frecuencia del reloj del sistema (12,000,000 Hz).
    * `PWM_BITS` / `PWM_MAX_VALUE`: Configuran la resolución de la Modulación por Ancho de Pulso (PWM) a 8 bits (256 niveles de brillo, de 0 a 255).
    * `PWM_CLK_PRESCALER_MAX`: Define el valor para un contador que divide el reloj del sistema, generando una frecuencia base para el PWM de aproximadamente 1 kHz para evitar parpadeo perceptible.
    * Constantes de Temporización del Fundido (ej. `TOTAL_SEQUENCE_TIME_S`, `TIME_PER_STATE_S`, `FADE_STEPS_PER_LED`): Definen la duración total, el tiempo por color, y los pasos de brillo para un ciclo de fundido.
    * `BRIGHTNESS_UPDATE_PRESCALER_MAX`: Define el valor para un contador que genera un "tick" mucho más lento. Este tick controla la velocidad del cambio de brillo, determinando la velocidad del fundido. Puede ser un valor precalculado o calculado a partir de las constantes de temporización (requiriendo `ieee.math_real.all` si usa funciones como `floor`).

* **Generación de PWM (Modulación por Ancho de Pulso):**
    * Se utiliza un **prescaler de reloj PWM** (`pwm_clk_prescaler_cnt` y `pwm_tick`) para reducir la frecuencia del reloj principal a una adecuada para el contador PWM.
    * Un **contador PWM** (`pwm_counter`) cicla de `0` a `PWM_MAX_VALUE` (255) a la velocidad del `pwm_tick`. La frecuencia de la señal PWM resultante será de (Tick_Freq / 256), aproximadamente 997 Hz.
    * La **salida PWM** para cada LED (`led_1_out`, `led_2_out`, `led_3_out`, `led_4_out`) se genera comparando `pwm_counter` con el `duty_cycle` deseado para ese color. Si `pwm_counter` es menor, el LED se enciende (salida '0').

* **Lógica de Control del Fundido y Máquina de Estados:**
    * Un **prescaler de actualización de brillo** (`brightness_update_prescaler_cnt` y `brightness_update_tick`) genera un pulso a una frecuencia mucho más baja que el PWM. Cada pulso indica un cambio en el nivel de brillo.
    * Una **máquina de estados** (`current_led_state`) controla el color activo: `STATE_FADE_L1`, `STATE_FADE_L2`, o `STATE_FADE_L3`, o `STATE_FADE_L4`.
    * `current_brightness` almacena el nivel de brillo actual (0-255).
    * `current_fade_direction` indica si el brillo aumenta (`DIR_UP`) o disminuye (`DIR_DOWN`).
    * Con cada `brightness_update_tick`:
        * `current_brightness` se incrementa o decrementa.
        * Si alcanza el máximo, la dirección cambia a `DIR_DOWN`.
        * Si alcanza el mínimo (0) en `DIR_DOWN`, el fundido del color se completa, la dirección cambia a `DIR_UP`, y la máquina de estados transiciona al siguiente color.
        * Los `duty_cycle` se actualizan: el `current_brightness` se asigna al color activo, y 0 a los otros.

---
**3. Funcionamiento General**

1.  **Inicialización:** Con `rst_n = '0'`, el sistema se inicializa. El estado es , `STATE_FADE_L3`, `current_brightness` es 0, y la dirección es `DIR_UP`.
2.  **Fundido del Color Activo:** El `current_brightness` del color activo aumenta de 0 a 255 y luego disminuye de 255 a 0, sincronizado con `brightness_update_tick`.
3.  **Transición de Color:** Al completar el fundido descendente (brillo 0), la máquina de estados avanza al siguiente color (Rojo -> Verde -> Azul -> Rojo...).
4.  **Ciclo Continuo:** El proceso se repite indefinidamente.

---
**4. Consideraciones Adicionales**

* **Adaptabilidad de Pines:** Las salidas pueden asignarse a cualquier LED mediante el archivo `.pcf`.
* **Ajuste de Parámetros:** La velocidad del fundido y la duración se pueden modificar ajustando las constantes de temporización y `BRIGHTNESS_UPDATE_PRESCALER_MAX`.
* **Biblioteca `ieee.math_real`:** Necesaria si se utilizan funciones como `floor` o `round` para calcular constantes en el VHDL.