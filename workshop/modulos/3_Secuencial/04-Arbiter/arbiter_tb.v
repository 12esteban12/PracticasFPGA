/*------------------------------------------------------------------------
---- Module:  arbiter_tb                                              ----
---- Description: testbench for ARBITER                               ----
---- Author/s:  Ramiro A. Ghignone                                    ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     arbiter.v                                                    ----
------------------------------------------------------------------------*/

`include "arbiter.v"

module arbiter_tb;
  
  wire q[2:0];
  
  reg clock;
  
  reg reset;
  
  reg req1;
  
  reg req2;
  
  //Generar clock
  always #2 clock <= !clock;
  
  //Instanciar modulo
  ARBITER arb(.req1(req1),
              .req2(req2),
              .clk(clock),
              .rst(reset),
              .gnt1(q[0]),
              .gnt2(q[1]));
  
  //Simulacion
  initial begin
    
    //Generar un archivo de salida "wf.vcd" con las formas de onda  
    $dumpfile("test.vcd");
    $dumpvars(0,arbiter_tb);
    
    //Generar estimulos
    #1 reset = 1'b1;
    #0 clock = 1'b0;
    #0 req1 = 1'b0;
    #0 req2 = 1'b0;
    #1 reset = 1'b0;
    
    #7 req1 = 1'b1;
    #3 req2 = 1'b1;
    #4 req2 = 1'b0;
    #3 req1 = 1'b0;
    
    #5 req2 = 1'b1;
    #5 req1 = 1'b1;
    #5 req1 = 1'b0;
    #5 req2 = 1'b0;
    
    
    #90 $finish;
    
  end
  
endmodule

