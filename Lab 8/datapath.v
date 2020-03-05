module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, Z_out, datapath_out, mdata, sximm8, sximm5, PC,data_out);
input clk, loada, loadb, asel, bsel, loadc, loads, write;
input [3:0] vsel;
input [2:0] readnum, writenum;
input [1:0] shift, ALUop;
input [15:0] mdata,sximm8, sximm5;
input [7:0] PC;
output [2:0] Z_out;
output [15:0]  data_out, datapath_out; //added data_out for lab 8 stage 2 

wire [15:0] data_in, loada_out, loadb_out, sout, Ain, Bin, ALUout;
wire [2:0] Z;

loadEnableDP #(16) LOADA (.in(data_out), .load(loada), .clk(clk), .out(loada_out) ); //Instantiate LOADA with module loadEnableDP
loadEnableDP #(16) LOADB (.in(data_out), .load(loadb), .clk(clk), .out(loadb_out) ); //Instantiate LOADB with module loadEnableDP
loadEnableDP #(3) STATUS (.in(Z), .load(loads), .clk(clk), .out(Z_out)); //Instantiate STATUS with module loadEnableDP
loadEnableDP #(16) LOADC (.in(ALUout), .load(loadc), .clk(clk), .out(datapath_out)); //Instantiate LOADC with module loadEnableDP

shifter SHIFTER(.in(loadb_out), .shift(shift), .sout(sout)); //Instantiate SHIFTER with module shifter

Mux4_Hot #(16) MUX4IN (.a3(mdata), .a2(sximm8), .a1({8'b0,PC}), .a0(datapath_out), .s(vsel), .out(data_in));

assign Ain = asel ? 16'b0: loada_out; //2 input binary select multiplexer
assign Bin = bsel ? sximm5 : sout; //2 input binary select multiplexer

ALU ALU(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(ALUout), .Z(Z)); //Instantiate ALU with module ALU

regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out)); //Instantiate REGFILE with module regfile

endmodule

module Mux4_Hot(a3,a2,a1,a0,s,out); //Multiplexer with 4 input and a one hot code as s, referenced from slide set 6
 parameter k = 16;
 input [k-1:0] a3,a2,a1,a0;
 input [3:0] s;
 output [k-1:0] out;

 //Assigns out to be the the input selected by the one-hot code 
 assign out =({k{s[0]}} & a0) |
	   ({k{s[1]}} & a1) |
	   ({k{s[2]}} & a2) |
	   ({k{s[3]}} & a3) ;
endmodule


module loadEnableDP(in,load,clk,out); //Create a loadEnable, referenced from slide set 6
 parameter n = 16;
 input [n-1:0] in;
 input load,clk;
 output[n-1:0] out;
 wire [n-1:0] middle;

 vDFFDP #(n) value (clk,middle,out); //Instantiate value with module VDFFDP
 assign middle = load ? in : out; //2 input binary select multiplexer
 
endmodule


module vDFFDP(clk,in,out); //Flip Flop, referenced from slide set 5
 parameter n = 1; //width
 input clk;
 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;

 //Assign out only on the positive edge of clock
 always@(posedge clk)
  out = in;
endmodule

