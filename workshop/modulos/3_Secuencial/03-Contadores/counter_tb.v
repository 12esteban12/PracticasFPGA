/*------------------------------------------------------------------------
---- Module:  counter_tb                                              ----
---- Description: testbench for N bits counter                        ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     counter.v                                                    ----
------------------------------------------------------------------------*/

`timescale 1 ns/100 ps
`include "counter.v"

module counter_tb();

//Parámetros locales del test:
localparam PER2         = 10.00;
localparam N            = 10;
localparam N_ITERATION  = 10;
localparam MAX_COUNTS   = 2**(N+2);
localparam N_COUNTS     = 2**N;

//Señales del DUT:
reg          test_clk      ;    
reg          test_rst      ;     
wire         test_max_tick ; 
wire [N-1:0] test_q        ;

//Señales internas:
wire max_tick_checker;
integer n_cycles = 0;
integer seed = 10;
integer i = 0;

assign max_tick_checker = (&test_q) ^ test_max_tick;

always @ (posedge test_clk)
begin
    if(max_tick_checker)
        $error("max_tick error\nq = 0x%x\nmax_tick = %d",test_q,test_max_tick);
end

//DUT:
counter 
#(
    .N(N)
)
dut
(
    .clk       ( test_clk      ),
    .rst       ( test_rst      ),
    .max_tick  ( test_max_tick ),
    .q         ( test_q        )
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
    $dumpvars(0, counter_tb);
    
    $display("Test begins\n");

    for(i=0;i<N_ITERATION;i=i+1)
    begin
        test_rst = 1'b1;
        #(PER2*20);
        test_rst = 1'b0;
        n_cycles = $urandom(seed)%MAX_COUNTS;
        $display("n_cycles = %d\n",n_cycles);
        #(PER2*2*n_cycles);
        if(test_q != n_cycles%N_COUNTS)
            $error("Count %d does not match the number of cycles %d\n",test_q,n_cycles);
        else
            $display("Result: PASS\n");
    end
    
    $display("Test end\n");

    $finish();
end

endmodule