/*------------------------------------------------------------------------
---- Module:  test                                                    ----
---- Description: testbench for RAM_DUAL                              ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     ramdual.v                                                    ----
------------------------------------------------------------------------*/

`include "ramdual.v"

// Verilog no tiene asserts por defecto, 
// pero se pueden implementar mediante una macro como esta
`define assert(signal, value, msg) \
  if (signal !== value) begin \
      $display(msg); \
      $display("Expected: %2x, got %2x",value,signal); \
      /*$finish;*/ \
  end

module test;
  
  reg wclk;
  reg rclk;
  
  reg [7:0] data_in;
  wire[7:0] data_out;
  
  reg wr_en;
  
  reg[7:0] raddress;
  reg[7:0] waddress;
  
  RAM_DUAL ram(.r_clk(rclk),
               .w_clk(wclk),
               .write(wr_en),
               .w_addr(waddress),
               .r_addr(raddress),
               .data_in(data_in),
               .data_out(data_out));

  //Descriptor de archivo
  integer file;

  //Resultado de fscanf
  integer fscanf_res;

  //Lectura para assert
  integer holder;
  
  // Generacion de reloj
  always #5 rclk = !rclk;
  always #3 wclk = !wclk;
  
  initial begin
    
    $dumpfile("test.vcd");
    $dumpvars(0,test); //Abrir archivo
    
    // Estado inicial
    #0 data_in <= 8'h00;
    #0 rclk	   <= 1'b0;
    #0 wclk    <= 1'b0;
    #0 wr_en   <= 1'b0;
    #0 raddress <= 0;
    #0 waddress <= 0;

    /******************** 1) CARGA DE DATOS A LA MEMORIA ***********************/

    // Leer estimulos de un archivo externo
    file = $fopen("stimulus.txt","r");
    
    //Verificar el archivo haya sido correctamente abierto
    #1 if (!file) begin
      //En caso de error, avisar
      $display("Error al abrir el archivo");
    end else begin

      // Iniciar la escritura
      #6 wr_en   <= 1'b1;

      //Mientras no lleguemos al final del archivo
      while (!$feof(file)) begin

        //Cada 3 unidades de tiempo escribir un valor
        #0 fscanf_res = $fscanf(file,"%x",data_in);
        #6 waddress = waddress + 1;
            
      end
    end

    #0 wr_en   <= 1'b0;

    //Cerrar archivo y terminar
    #30 $fclose(file);

    /****************** 2) LECTURA DE DATOS DE LA MEMORIA *********************/

    // Leer nuevamente los estimulos del un archivo externo
    file = $fopen("stimulus.txt","r");
    
    //Verificar el archivo haya sido correctamente abierto
    #1 if (!file) begin
      //En caso de error, avisar
      $display("Error al abrir el archivo");
    end else begin

      //Mientras no lleguemos al final del archivo
      while (!$feof(file)) begin
        #0 raddress = raddress + 1;
        #0 fscanf_res = $fscanf(file,"%x",holder);
        #5 `assert(data_out,holder,"BEWARE: Memory integrity failed");
        #5 ;
      end
    end

    #0 wr_en   <= 1'b0;

    //Cerrar archivo y terminar
    #30 $fclose(file);



    $finish;
  end
endmodule
