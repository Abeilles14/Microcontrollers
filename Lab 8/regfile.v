module regfile(data_in,writenum,write,readnum,clk,data_out);
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;


wire [15:0] R0;
wire [15:0] R1;
wire [15:0] R2;
wire [15:0] R3;
wire [15:0] R4;
wire [15:0] R5;
wire [15:0] R6;
wire [15:0] R7;

wire [7:0] hotWrite;
wire [7:0] hotRead;

wire [7:0] hotWriteOut;
//Assigns the hotWrite one-hot code going to the regFile inputs if write is 1, otherwise assigns 8'b0
assign hotWriteOut = write ? hotWrite : 8'b0; 

DecoderRF #(3,8) writeHot(writenum,hotWrite); //Instantiate writeHot to module DecoderRF
DecoderRF #(3,8) readHot(readnum,hotRead); //Instantiate readHot to module DecoderRF
Mux8_Hot #(16) MUX(R7,R6,R5,R4,R3,R2,R1,R0,hotRead,data_out);//Instantiate MUX to module Mux8_Hot
loadEnableRF #(16) LR0(data_in,hotWriteOut[0],clk,R0); //Instantiate LR0 to module loadEnableRF
loadEnableRF #(16) LR1(data_in,hotWriteOut[1],clk,R1); //Instantiate LR1 to module loadEnableRF
loadEnableRF #(16) LR2(data_in,hotWriteOut[2],clk,R2); //Instantiate LR2 to module loadEnableRF
loadEnableRF #(16) LR3(data_in,hotWriteOut[3],clk,R3); //Instantiate LR3 to module loadEnableRF
loadEnableRF #(16) LR4(data_in,hotWriteOut[4],clk,R4); //Instantiate LR4 to module loadEnableRF
loadEnableRF #(16) LR5(data_in,hotWriteOut[5],clk,R5); //Instantiate LR5 to module loadEnableRF
loadEnableRF #(16) LR6(data_in,hotWriteOut[6],clk,R6); //Instantiate LR6 to module loadEnableRF
loadEnableRF #(16) LR7(data_in,hotWriteOut[7],clk,R7); //Instantiate LR7 to module loadEnableRF

endmodule

module loadEnableRF(in,load,clk,out); //Create a loadEnable, referenced from slide set 6
 parameter n = 16;
 input [n-1:0] in;
 input load,clk;
 output[n-1:0] out;
 wire [n-1:0] middle;

 vDFFRF #(n) value (clk,middle,out); //Instantiate value with module VDFFRF
 assign middle = load ? in : out; //2 input binary select multiplexer

endmodule


module vDFFRF(clk,in,out); //Flip Flop, referenced from slide set 5
 parameter n = 1; //width
 input clk;
 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;
 //Assigns out on the positive edge of clk
 always@(posedge clk)
  out = in;
endmodule

module Mux8_Hot(a7,a6,a5,a4,a3,a2,a1,a0,s,out); //Multiplexer with 8 input and a one hot code as s, referenced from slide set 6
 parameter k = 16;
 input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
 input [7:0] s;
 output [k-1:0] out;

 //Assigns out to be the the input selected by the one-hot code 
 assign out =({k{s[0]}} & a0) |
	   ({k{s[1]}} & a1) |
	   ({k{s[2]}} & a2) |
	   ({k{s[3]}} & a3) |
	   ({k{s[4]}} & a4) |
	   ({k{s[5]}} & a5) |
	   ({k{s[6]}} & a6) |
	   ({k{s[7]}} & a7) ;
endmodule


//a - binary input (n bits wide)
//b - one hot output (m bits wide)

module DecoderRF(a,b); //Decoder referenced from slide set 6 
 parameter n = 2;
 parameter m = 4;
 
 input [n-1:0] a;
 output [m-1:0] b;

//Assigns a one-hot code by shifting a 1 to the left by a
 wire [m-1:0] b = 1 << a; 
endmodule




