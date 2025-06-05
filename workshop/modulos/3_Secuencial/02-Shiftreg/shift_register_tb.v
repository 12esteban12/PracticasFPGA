/*------------------------------------------------------------------------
---- Module:  shift_register_tb                                       ----
---- Description: testbench of shift_register with self check         ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     shift_register.v                                             ----
------------------------------------------------------------------------*/

`timescale 1 ns/100 ps
`include "shift_register.v"

module shift_register_tb();

//Parámetros locales del test:
localparam PER2         = 10.00;
localparam N            = 10;
localparam N_ITERATIONS = 100;

//Señales del DUT:
reg   test_clk     ;    
reg   test_rst     ;     
reg   test_sh_in   ; 
wire  test_sh_out  ;

//Señales internas:
integer i = 0;
integer j = 0;
integer k = 0;
integer seed = 0;
reg [N-1:0] stim_vec;
reg [N-1:0] result_vec = 0;

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
    $dumpvars(0, shift_register_tb);
    
    $display("Test begins\n");

    test_rst = 1'b1;
    test_sh_in = 1'b0;
    #(PER2*20);
    test_rst = 1'b0;

    for(k=0;k<N_ITERATIONS;k=k+1)
    begin
        
        stim_vec = $urandom(seed);
        test_sh_in = stim_vec[0];

        for(i=0; i<N; i=i+1)
        begin
            test_sh_in = stim_vec[i];
            #(PER2*2);
        end

        for(i=0; i<N; i=i+1)
        begin
            for(j=0;j<N-1;j=j+1)
                result_vec[j] = result_vec[j+1];
            result_vec[N-1] = test_sh_out;
            #(PER2*2);
        end

        if(stim_vec != result_vec)
            $error("stim_vec = 0x%x\nresult_vec = 0x%x\n",stim_vec,result_vec);
    end
    
    $display("Test end\n");

    $finish();
end

endmodule