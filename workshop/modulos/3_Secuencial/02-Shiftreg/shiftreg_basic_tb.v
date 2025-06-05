/*------------------------------------------------------------------------
---- Module:  shiftreg_basic_tb                                       ----
---- Description: simple testbench of shift_register. No self-check.  ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     shift_register.v                                             ----
------------------------------------------------------------------------*/

`timescale 1 ns/100 ps
`include "shift_register.v"

module shiftreg_basic_tb();

//Parámetros locales del test:
localparam PER2         = 10.00;
localparam N            = 10;

//Señales del DUT:
reg   test_clk     ;    
reg   test_rst     ;     
reg   test_sh_in   ; 
wire  test_sh_out  ;

//Señales internas:
integer i = 0;
integer seed = 0;

//DUT:
shift_register 
#(
    .N(N)
)
dut
(
    .clk    ( test_clk    ),
    .rst    ( test_rst    ),
    .sh_in  ( test_sh_in  ),
    .sh_out ( test_sh_out )
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
    $dumpvars(0, shiftreg_basic_tb);
    
    $display("Test begins\n");

    test_rst = 1'b1;
    test_sh_in = 1'b0;
    #(PER2*21);
    
    for(i=0;i<1000;i=i+1)
    begin
        test_sh_in = $urandom(seed)%2;
        if(i > 200)
            test_rst = 1'b0;
        #(PER2*2);
    end

    $display("Test end\n");

    $finish();
end

endmodule