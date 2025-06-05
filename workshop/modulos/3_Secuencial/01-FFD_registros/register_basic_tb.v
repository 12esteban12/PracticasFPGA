/*------------------------------------------------------------------------
---- Module:  register_basic_tb                                       ----
---- Description: testbench for register                              ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     register.v                                                   ----
------------------------------------------------------------------------*/

`timescale 1 ns/100 ps
`include "register.v"

module register_basic_tb();

//Parámetros locales del test:
localparam PER2         = 10.00;
localparam N            = 10;

//Señales del DUT:
reg          test_clk ;
reg          test_rst ;
reg  [N-1:0] test_d   ;
reg          test_ena ;
wire [N-1:0] test_q   ;

//Señales internas:
integer i = 0;

//DUT:
register 
#(
    .N(N)
)
dut
(
    .clk    ( test_clk    ),
    .rst    ( test_rst    ),
    .d      ( test_d      ),
    .ena    ( test_ena    ),
    .q      ( test_q      )
);

//Generación de clock:
always
begin
    test_clk = 1'b1;
    #PER2;
    test_clk = 1'b0;
    #PER2;
end

//Cuerpo del test:
initial 
begin
    $dumpfile("test.vcd");
    $dumpvars(0, register_basic_tb);
    
    $display("Test begins\n");

    test_rst = 1'b1;
    test_ena = 1'b0;
    test_d   = {N{1'b1}};
    #(PER2*20);
    test_rst = 1'b0;
    #(PER2*20);
    test_ena = 1'b1;
    #(PER2*2);

    for(i=0; i<2**N; i=i+1)
    begin
        test_d = i;
        #(PER2*2);
    end

    test_rst = 1'b1;

    #(PER2*10);

    $display("Test end\n");

    $finish();
end

endmodule