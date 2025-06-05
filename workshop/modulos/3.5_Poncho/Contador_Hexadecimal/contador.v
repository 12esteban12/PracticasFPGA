/*Contador a 4 display de 7 segmentos
 *
 *Ejemplo de FPGA Prototyping with Verilog Examples.
 *
 *Este ejemplo utiliza  el módulo de multiplexación temporal
 *
 *Se trata de un contador hexadecimal simple
 *Los interruptores controlan el incremento del contador
 *cambiando la suma al siguiente valor entre 0x0 y 0xF
*/


module disp_hex_mux #(
    parameter CLK_SND = 12000000
) (
    input wire       clk  ,  //input wire clk: clock signal
    input wire       reset,  //input wire reset: reset del contador del mux
    input wire [3:0] hex3 ,  //input wire [3:0] hex3: valor hexadecimal para display 3 
    input wire [3:0] hex2 ,  //input wire [3:0] hex2: valor hexadecimal para display 2
    input wire [3:0] hex1 ,  //input wire [3:0] hex1: valor hexadecimal para display 1
    input wire [3:0] hex0 ,  //input wire [3:0] hex0: valor hexadecimal para display 0
    input wire [3:0] dp_in,  //input wire [3:0] dp_in: valor del punto decimal de cada display
    output reg [3:0] an   ,  //output reg [3:0] an: enable de la señal de salida de cada display
    output reg [7:0] sseg    //output reg [7:0] sseg: señal de salida para cada segmento + punto decimal
);

// 12 MHz / 2^14 = 732 Hz
// 12 MHz / 2^16 = 183 Hz
// 12 MHz / 2^22 = 3 Hz
localparam N = 16;
localparam M = 32;

reg [N-1:0] q_reg;
wire [N-1:0] q_next;
reg [3:0] hex_in;
reg dp;

//Lógica del contador.
always @ ( posedge clk, posedge reset )
    if (reset)
        q_reg <= 0;
    else
        q_reg <= q_next;

assign q_next = q_reg + 1 ;

//Es una variable de 16bits, ya que hay 4 displays
reg [15:0] display_valor = {16{1'b0}};

//Esta es la cuenta maxima de actualizacion del display
//N es el divisor de tiempo, por lo que un N = 2, dará un contador
//que va a la mitad de la velocidad del clock
reg [M-1:0] display_cuenta = {M{1'b0}};

always @ ( posedge clk ) begin
    //Es una variable que cuenta hasta llegar a un máximo,
    //que se determina con la cuenta máxima justamente
    display_cuenta <= display_cuenta + 1;
    if ( display_cuenta == (CLK_SND - 1) ) begin
        display_valor <= display_valor + hex0;
        display_cuenta <= {M{1'b0}};
    end
end

//Lógica del trascodificador
always @(*)
    case (q_reg[N-1: N-2])
    2'b00:
        begin
            an = 4'b1110;
            hex_in = ~display_valor[15:12];
            dp = ~dp_in[0] ;
        end
    2'b01:
        begin
            an = 4'b1101;
            hex_in = ~display_valor[11:8];
            dp = ~dp_in[1] ;
        end
    2'b10:
        begin
            an = 4'b1011;
            hex_in = ~display_valor[7:4];
            dp = ~dp_in[2] ;
        end
    default:
        begin
            an = 4'b0111;
            hex_in = ~display_valor[3:0];
            dp = ~dp_in[3] ;
        end
endcase

always @(*)
    begin
        case (~hex_in)
            4'h0: sseg[6:0] = 7'b1000000;
            4'h1: sseg[6:0] = 7'b1111001;
            4'h2: sseg[6:0] = 7'b0100100;
            4'h3: sseg[6:0] = 7'b0110000;
            4'h4: sseg[6:0] = 7'b0011001;
            4'h5: sseg[6:0] = 7'b0010010;
            4'h6: sseg[6:0] = 7'b0000010;
            4'h7: sseg[6:0] = 7'b1111000;
            4'h8: sseg[6:0] = 7'b0000000;
            4'h9: sseg[6:0] = 7'b0010000;
            4'ha: sseg[6:0] = 7'b0001000;
            4'hb: sseg[6:0] = 7'b0000011;
            4'hc: sseg[6:0] = 7'b1000110;
            4'hd: sseg[6:0] = 7'b0100001;
            4'he: sseg[6:0] = 7'b0000110;
            default: sseg[6:0] = 7'b0001110;
        endcase
    sseg[7] = ~dp;

end

endmodule
