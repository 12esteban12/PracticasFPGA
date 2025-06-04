# Prácticas de FPGA con la Placa EDU-CIAA-FPGA

## Introducción

Este repositorio contiene una colección de proyectos y prácticas de diseño digital desarrollados para la placa de desarrollo FPGA **EDU-CIAA-FPGA**. El objetivo principal es explorar diversas funcionalidades de la FPGA, conceptos de lógica digital y el uso de lenguajes de descripción de hardware (HDL) como VHDL o Verilog.

Todas las prácticas están diseñadas para ser compatibles y utilizar el entorno de herramientas (toolchain) proporcionado por el proyecto EDU-CIAA.

## Placa de Desarrollo

* **Hardware Principal:** [EDU-CIAA-FPGA](https://gitlab.com/RamadrianG/wiki---fpga-para-todos/-/wikis/FPGA-para-Todos) (Basada en una FPGA Lattice iCE40HX4K).
* **Recursos Clave:**
    * FPGA: Lattice iCE40HX4K-TQ144
    * Memoria Flash para configuración
    * LEDs, pulsadores, puertos de expansión, etc. (Consultar la documentación oficial para el pinout detallado).

## Entorno de Desarrollo y Herramientas (Toolchain)

Para compilar, sintetizar y programar los diseños en la FPGA, se utiliza el toolchain oficial proporcionado por el proyecto EDU-CIAA, que incluye herramientas de código abierto como:

* **Yosys:** Para la síntesis de HDL (VHDL/Verilog).
* **NextPNR (arachne-pnr o similar para iCE40):** Para el place and route.
* **IceStorm Tools (icepack, iceprog):** Para la generación del bitstream y la programación de la FPGA.
* **GHDL / Icarus Verilog (opcionalmente para simulación):** Para simular los diseños antes de la implementación.
* **GTKWave:** Para visualizar formas de onda de las simulaciones.

## Estructura del Repositorio

Este repositorio está organizado (o se organizará) de la siguiente manera:

* **/docs:** Documentación general, hojas de datos, etc.
* **/fade:**
    * `led_fader.vhd`: Archivo fuente HDL.
    * `led_fader.pcf`: Archivo de restricciones de pines (pin constraints).
    * `README.md`: Descripción específica de esta práctica.
* **/uart:**
    * `uart.vhd`: Archivo fuente HDL.
    * `uart.pcf`: Archivo de restricciones de pines (pin constraints).
    * `README.md`: Descripción específica de esta práctica.
* `README.md`: Este archivo.

## Cómo Empezar / Usar las Prácticas

1.  **Clonar el Repositorio:**
    ```bash
    git clone https://github.com/12esteban12/PracticasFPGA
    cd practicasFPGA
    ```

2.  **Configurar el Entorno de Herramientas:**
    Asegúrate de tener instalado y configurado el toolchain de la EDU-CIAA-FPGA. Si usas la imagen Docker, verifica que Docker esté corriendo y que puedas ejecutar los comandos del toolchain.
    * [Instrucciones de Instalación del Toolchain EDU-CIAA](https://gitlab.com/RamadrianG/wiki---fpga-para-todos/-/wikis/Herramientas-de-Desarrollo)

3.  **Navegar a una Práctica Específica:**
    ```bash
    cd nombre_de_la_practica_X
    ```

4.  **Compilar, Sintetizar y Programar:**
    Los comandos exactos pueden variar ligeramente dependiendo de la configuración del toolchain, pero generalmente involucran:
    * **Síntesis (Yosys):** Convertir el código HDL a una netlist.
    * **Place and Route (NextPNR):** Mapear la netlist a los recursos de la FPGA.
    * **Empaquetado (icepack):** Generar el archivo binario (`.bin`) para la FPGA.
    * **Programación (iceprog):** Cargar el archivo `.bin` en la memoria flash de la EDU-CIAA-FPGA.

    Un comando típico proporcionado por el toolchain de la EDU-CIAA podría ser algo como:
    ```bash
    # Ejemplo (ajustar según el script/comando real del toolchain)
    # Si el toolchain es un script que toma el VHDL y el PCF:
    comando_del_toolchain archivo.vhd restricciones.pcf 
    ```
    Revisa la documentación específica del toolchain o los scripts proporcionados para los comandos exactos. Generalmente, se generan archivos como `top.bin` o `nombre_proyecto.bin`.

5.  **Probar en la Placa:**
    Una vez programada la FPGA, verifica el funcionamiento según la descripción de la práctica.

## Listado de Prácticas

A continuación, se listarán las prácticas incluidas en este repositorio (¡actualiza esta sección a medida que agregues más!):

* **Práctica 1: Nombre de la Práctica 1**
    * Descripción breve de lo que hace.
    * Directorio: `[/fader](./fader)`
* **Práctica 2: Nombre de la Práctica 2**
    * Descripción breve.
    * Directorio: `[/uart](./uart)`
* **(Más prácticas aquí)**

## Contribuciones (Opcional)

Si deseas contribuir, por favor sigue las guías estándar (fork, pull request, etc.). (Puedes eliminar esta sección si es un repositorio personal).

## Autor

* **[Esteban De Blasis / 12esteban12]**
* estebandeblasis@gmail.com 

## Licencia (Opcional pero Recomendado)

Este proyecto se distribuye bajo la Licencia [Nombre de la Licencia, ej. MIT, Apache 2.0, GPLv3]. Ver el archivo `LICENSE` para más detalles.
(Si decides agregar una licencia, crea un archivo `LICENSE` en la raíz del repositorio con el texto de la licencia elegida).

---