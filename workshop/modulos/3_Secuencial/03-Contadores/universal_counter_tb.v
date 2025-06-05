/*------------------------------------------------------------------------
---- Module:  universal_counter_tb                                    ----
---- Description: testbench for universal_counter with self check     ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----     universal_counter.v                                          ----
------------------------------------------------------------------------*/

`timescale 1 ns/100 ps
`ifndef USE_SOLUTIONS
`include "universal_counter.v"
`else
`include "universal_counter_solution.v"
`endif

module universal_counter_tb();

//Parámetros locales del test:
localparam T         = 20.00;
localparam N         = 5;
localparam N_COUNTS  = 2**N; 

//Señales del DUT:
reg          test_clk      ;    
reg          test_rst      ; 
reg          test_load     ;
reg          test_en       ;
reg          test_up       ;
reg  [N-1:0] test_D        ; 
wire         test_max_tick ; 
wire         test_min_tick ;
wire [N-1:0] test_Q        ;

//Señales internas:
integer seed = 0;
integer rnd_value = 0;
integer rnd_cycles = 0;
integer expected_value = 0;

//DUT:
universal_counter 
#(
    .N(N)
)
dut
(
    .clk       ( test_clk      ),
    .rst       ( test_rst      ),
    .load      ( test_load     ),
    .en        ( test_en       ),
    .up        ( test_up       ),
    .D         ( test_D        ),
    .max_tick  ( test_max_tick ),
    .min_tick  ( test_min_tick ),
    .Q         ( test_Q        )
);

//Generación de clock:
always
begin
    test_clk = 1'b1;
    #(T/2);
    test_clk = 1'b0;
    #(T/2);
end

//Reset
initial
begin
    test_rst = 1'b1;
    #(T);
    test_rst = 1'b0;
end

//Cuerpo del test:
initial 
begin
    $dumpfile("test.vcd");
    $dumpvars(0, universal_counter_tb);
    
    $display("Test begins\n");

    test_load    = 1'b0;
    test_en      = 1'b0;
    test_up      = 1'b1;
    test_D       = {N{1'b0}};
    @(negedge test_rst);
    @(negedge test_clk);

    $display("Test load input\n");
    test_load = 1'b1;
    rnd_value = $urandom(seed)%N_COUNTS;
    test_D    = rnd_value;
    @(negedge test_clk);
    test_load = 1'b0;
    expected_value = test_D;
    if(test_Q != expected_value)
        $error("Q = 0x%x\nExpected value = 0x%x\n",test_Q, expected_value);
    repeat(2) @(negedge test_clk);

    $display("Test count up\n");
    test_en = 1'b1;
    test_up = 1'b1;
    rnd_cycles = $urandom(seed)%100;
    repeat(rnd_cycles) @(negedge test_clk);
    test_en = 1'b0;
    expected_value = ((rnd_value+rnd_cycles)%N_COUNTS);
    if(test_Q != expected_value)
        $error("Q = 0x%x\nExpected valule = 0x%x\n",test_Q, expected_value);
    repeat(2) @(negedge test_clk);
    test_en = 1'b1;
    test_rst = 1'b1;
    repeat(2) @(negedge test_clk);
    test_rst = 1'b0;

    $display("Test count down\n");
    test_up = 1'b0;
    rnd_cycles = $urandom(seed)%100;
    repeat(rnd_cycles) @(negedge test_clk);
    expected_value = (N_COUNTS-(rnd_cycles%N_COUNTS));
    if(test_Q != expected_value)
        $error("Q = 0x%x\nExpected valule = 0x%x\n",test_Q,expected_value);
    @(negedge test_clk);
    test_up = 1'b1;

    $display("Test min tick\n");
    @(negedge test_clk);
    wait(test_Q == 0);
    if(!test_min_tick)
        $error("min_tick\n");
    $display("Test max tick\n");
    @(negedge test_clk);
    wait(test_Q == N_COUNTS-1);
    if(!test_max_tick)
        $error("max_tick\n");

    #(T*4);
    test_en = 1'b0;
    #(T*4);
    
    $display("Test end\n");

    $finish();
end

endmodule