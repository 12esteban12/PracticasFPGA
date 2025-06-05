/*------------------------------------------------------------------------
---- Module: instruction_decoder_tb                                   ----
---- Description:  testbench for instruction_decoder                  ----
---- Author/s:  Martín A. Heredia                                     ----
---- Last revision: Sep. 2023                                         ----
---- Dependencies:                                                    ----
----    instruction_decoder.v                                         ----
------------------------------------------------------------------------*/

`include "instruction_decoder.v"
`timescale 1us / 100ns // 1 useg por unidad de tiempo, 100 nseg como mínima unidad

module instruction_decoder_tb;

    //Estímulos:
    localparam LOAD      = 12'b000010000000;
    localparam ADD       = 12'b010001000000;
    localparam BITAND    = 12'b000100100000;
    localparam SUB       = 12'b011000010000;
    localparam INPUT     = 12'b101000001000;
    localparam OUTPUT    = 12'b111000000100;
    localparam JUMP      = 12'b100000000010;
    localparam JUMP_COND = 12'b100100000001;

    //Instrucciones inválidas:
    localparam INVALID_2 = 4'b0010;
    localparam INVALID_3 = 4'b0011;
    localparam INVALID_5 = 4'b0101;
    localparam INVALID_7 = 4'b0111;
    localparam INVALID_B = 4'b1011;
    localparam INVALID_C = 4'b1100;
    localparam INVALID_D = 4'b1101;
    localparam INVALID_F = 4'b1111;

    localparam N_BITS = 4   ; 
    reg [N_BITS-1:0] a_in   ;
    wire add                ; 
    wire load               ; 
    wire output_out         ;
    wire input_out          ;
    wire jump_cond          ;
    wire jump               ;
    wire sub                ; 
    wire bitand             ;

    wire [7:0] dut_outputs_grp;
    assign dut_outputs_grp = {load, add, bitand, sub, input_out, output_out, jump, jump_cond};


    instruction_decoder decoder0 
    (
      .a_in        (a_in        ),  
      .add         (add         ), 
      .load        (load        ),
      .output_out  (output_out  ),        
      .input_out   (input_out   ),    
      .jump        (jump        ),
      .jump_cond   (jump_cond   ),   
      .sub         (sub         ), 
      .bitand      (bitand      )          
    );


    initial begin 

        $dumpfile("test.vcd");
        $dumpvars(0,instruction_decoder_tb);

        $display("\nTesting valid instructions:\n");

        a_in = LOAD[11-:N_BITS];
        #10;
        if(dut_outputs_grp != LOAD[7:0])
        begin
          $error("Wrong output at LOAD instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,LOAD[7:0],dut_outputs_grp);
        end

        a_in = ADD[11-:N_BITS];
        #10;
        if(dut_outputs_grp != ADD[7:0])
        begin
          $error("Wrong output at ADD instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,ADD[7:0],dut_outputs_grp);
        end

        a_in = BITAND[11-:N_BITS];
        #10;
        if(dut_outputs_grp != BITAND[7:0])
        begin
          $error("Wrong output at BITAND instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,BITAND[7:0],dut_outputs_grp);
        end

        a_in = SUB[11-:N_BITS];
        #10;
        if(dut_outputs_grp != SUB[7:0])
        begin
          $error("Wrong output at SUB instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,SUB[7:0],dut_outputs_grp);
        end

        a_in = INPUT[11-:N_BITS];
        #10;
        if(dut_outputs_grp != INPUT[7:0])
        begin
          $error("Wrong output at INPUT instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,INPUT[7:0],dut_outputs_grp);
        end

        a_in = OUTPUT[11-:N_BITS];
        #10;
        if(dut_outputs_grp != OUTPUT[7:0])
        begin
          $error("Wrong output at OUTPUT instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,OUTPUT[7:0],dut_outputs_grp);
        end

        a_in = JUMP[11-:N_BITS];
        #10;
        if(dut_outputs_grp != JUMP[7:0])
        begin
          $error("Wrong output at JUMP instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,JUMP[7:0],dut_outputs_grp);
        end

        a_in = JUMP_COND[11-:N_BITS];
        #10;
        if(dut_outputs_grp != JUMP_COND[7:0])
        begin
          $error("Wrong output at JUMP_COND instruction\n");
          $display("\ta_in = %b\n\texpected = %b\n\tobtained = %b",a_in,JUMP_COND[7:0],dut_outputs_grp);
        end

        $display("\nTesting invalid instructions:\n");

        a_in = INVALID_2;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_2 instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_3;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_3 instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_5;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_5 instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_7;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_7 instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_B;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_B instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_C;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_C instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_D;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_D instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        a_in = INVALID_F;
        #10;
        if(dut_outputs_grp != 8'd0)
        begin
          $error("Wrong: outputs are not zero with INVALID_F instruction\n");
          $display("\ta_in = %b\n\tobtained = %b",a_in,dut_outputs_grp);
        end

        #10 $finish;
    end 


endmodule