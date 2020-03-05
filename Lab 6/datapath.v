module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, Z_out, datapath_out, PC, mdata, sximm8, sximm5);
input clk, loada, loadb, asel, bsel, loadc, loads, write;
input [3:0] vsel;					//1-hot select for 4-input MUX
input [2:0] readnum, writenum;
input [1:0] shift, ALUop;
input [7:0] PC;
input [15:0] mdata, sximm8, sximm5;
output [2:0] Z_out;
output [15:0] datapath_out;

wire [15:0] data_in, data_out, loada_out, loadb_out, sout, Ain, Bin, ALUout;
wire Z, flag;
	
Mux4 #(16,8) MUX4 (.mdata(mdata), .sximm8(sximm8), .PC(PC), .vsel(vsel), .C(datapath_out), .out(data_in)); //input to register

regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out)); //Instantiate REGFILE with module regfile

ALU ALU(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(ALUout), .Z(Z)); //Instantiate ALU with module ALU

loadEnableDP #(16) LOADA (.in(data_out), .load(loada), .clk(clk), .out(loada_out) ); //Instantiate LOADA with module loadEnableDP
loadEnableDP #(16) LOADB (.in(data_out), .load(loadb), .clk(clk), .out(loadb_out) ); //Instantiate LOADB with module loadEnableDP
loadEnableDP #(16) LOADC (.in(ALUout), .load(loadc), .clk(clk), .out(datapath_out)); //Instantiate LOADC with module loadEnableDP
loadEnableDP #(3) STATUS (.in({Z,ALUout[15],flag}), .load(loads), .clk(clk), .out(Z_out)); //Instantiate STATUS with module loadEnableDP


shifter SHIFTER(.in(loadb_out), .shift(shift), .sout(sout)); //Instantiate SHIFTER with module shifter

//assign data_in = vsel ? datapath_in : datapath_out; //2 input binary select multiplexer

assign Ain = asel ? 16'b0: loada_out; //2 input binary select multiplexer

assign Bin = bsel ? sximm5 : sout; //2 input binary select multiplexer
assign flag=(Ain[15]^Bin[15])?1'b0:((Ain[15])!=ALUout[15])? 1'b1 : 1'b0; //overflow checker
endmodule


module Mux4(mdata, sximm8, PC, vsel, C, out); //Multiplexer with 4 input including C and a one hot code as vsel
 parameter k = 16;
 parameter j = 8;
 input [k-1:0] mdata, sximm8, C;
 input [j-1:0] PC;
 input [3:0] vsel;
 output [k-1:0] out;

			//confirm syntax!!

 //Assigns out to be the the input selected by vsel
assign out = ({k{vsel[0]}} & mdata) |
	({k{vsel[1]}} & sximm8) |
	({k{vsel[2]}} & PC) |
	({k{vsel[3]}} & C);

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

