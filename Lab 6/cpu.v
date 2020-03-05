`define Sa 6'b000000
`define Sdec 6'b000001
`define MOV1a 6'b000010
`define MOV2a 6'b000011
`define MOV2b 6'b000100
`define MOV2c 6'b000101
`define ADDa 6'b000110
`define ADDb 6'b000111
`define ADDc 6'b001000
`define ADDd 6'b001001
`define CMPa 6'b001010
`define CMPb 6'b001011
`define CMPc 6'b001100
`define ANDa 6'b001101
`define ANDb 6'b001110
`define ANDc 6'b001111
`define ANDd 6'b010000
`define MVNa 6'b010001
`define MVNb 6'b010010
`define MVNc 6'b010011

module cpu(clk,reset,s,load,in,out,N,V,Z,w);
  input clk, reset, s, load; 
  input [15:0] in;
  output [15:0] out;
  output N, V, Z, w;
wire [15:0] inregout, sximm5,sximm8;
wire [1:0] ALUop,shift,op,nsel;
wire [2:0] rwnum, opcode,readnum,writenum;
wire [15:0] mdata=16'b0;
wire [7:0] PC=8'b0;
wire loada,loadb,loadc,write,w,asel,bsel,loads;
wire [3:0] vsel;
assign readnum=rwnum;
assign writenum=rwnum;

loadEnableDP instructreg (in,load,clk,inregout); //instruction register
instructdec instruction (inregout,nsel,ALUop,sximm5,sximm8,shift,rwnum,opcode,op); //instruction decoder
datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, {Z,N,V},out, PC, mdata, sximm8, sximm5); //datapath
statemach Controller(s,reset,clk,opcode,op,w,nsel,vsel,loada,loadb,asel,bsel,loadc,loads,write); //FSM
endmodule

module statemach (s,reset,clk,opcode,op,w,nsel,vsel,loada,loadb,asel,bsel,loadc,loads,write);//variation of code from slide set 7 slide #54
input clk,reset,s;
input [2:0] opcode;
input [1:0] op;
output loada,loadb,loadc,write,w,loads,asel,bsel;
output [3:0] vsel;
output [1:0] nsel;


wire [5:0] present_state, state_next_reset, state_next;
reg [19:0] next;
vDFFRF #(6) mach(clk,state_next_reset,present_state);
assign state_next_reset= reset ? 6'b0 : state_next;
always@(*)begin
  casex({present_state,s,opcode,op})
    {`Sa,6'b0_xxx_xx}:next={`Sa,14'b00_0_0_0_0_0000_0_0_0_1}; //reset state
    {`Sa,6'b1_xxx_xx}:next={`Sdec,14'b00_0_0_0_0_0000_0_0_0_1}; //decode state
  
    {`Sdec,6'bx_110_10}:next={`MOV1a,14'b10_0_0_0_0_0000_0_0_0_0}; //first instruct
    {`MOV1a,6'bx_110_10}:next={`Sa,14'b10_0_0_0_0_0010_1_0_0_0};
    
    {`Sdec,6'bx_110_00}:next={`MOV2a,14'b00_0_0_0_0_0000_0_0_0_0}; //second instruct
    {`MOV2a,6'bx_110_00}:next={`MOV2b,14'b00_0_1_0_0_0000_0_0_0_0};
    {`MOV2b,6'bx_110_00}:next={`MOV2c,14'b01_0_0_1_0_0000_0_1_0_0};
    {`MOV2c,6'bx_110_00}:next={`Sa,14'b01_0_0_0_0_1000_1_0_0_0};

    {`Sdec,6'bx_101_00}:next={`ADDa,14'b10_0_0_0_0_0000_0_0_0_0}; //third instruct
    {`ADDa,6'bx_101_00}:next={`ADDb,14'b10_1_0_0_0_0000_0_0_0_0};
    {`ADDb,6'bx_101_00}:next={`ADDc,14'b00_0_1_0_0_0000_0_0_0_0};
    {`ADDc,6'bx_101_00}:next={`ADDd,14'b00_0_0_1_0_0000_0_0_0_0};
    {`ADDd,6'bx_101_00}:next={`Sa,14'b01_0_0_0_0_1000_1_0_0_0};

    {`Sdec,6'bx_101_01}:next={`CMPa,14'b10_0_0_0_0_0000_0_0_0_0}; //fourth instruct
    {`CMPa,6'bx_101_01}:next={`CMPb,14'b10_1_0_0_0_0000_0_0_0_0};
    {`CMPb,6'bx_101_01}:next={`CMPc,14'b00_0_1_1_0_0000_0_0_0_0};
    {`CMPc,6'bx_101_01}:next={`Sa,14'b00_0_0_0_1_0000_0_0_0_0};

    {`Sdec,6'bx_101_10}:next={`ANDa,14'b10_0_0_0_0_0000_0_0_0_0}; //fifth instruct
    {`ANDa,6'bx_101_10}:next={`ANDb,14'b10_1_0_0_0_0000_0_0_0_0};
    {`ANDb,6'bx_101_10}:next={`ANDc,14'b00_0_1_0_0_0000_0_0_0_0};
    {`ANDc,6'bx_101_10}:next={`ANDd,14'b00_0_0_1_0_0000_0_0_0_0};
    {`ANDd,6'bx_101_10}:next={`Sa,14'b01_0_0_0_0_1000_1_0_0_0};

    {`Sdec,6'bx_101_11}:next={`MVNa,14'b00_0_0_0_0_0000_0_0_0_0}; //sixth instruct
    {`MVNa,6'bx_101_11}:next={`MVNb,14'b00_0_1_0_0_0000_0_0_0_0};
    {`MVNb,6'bx_101_11}:next={`MVNc,14'b00_0_0_1_0_0000_0_1_0_0};
    {`MVNc,6'bx_101_11}:next={`Sa,14'b01_0_0_0_0_1000_1_0_0_0};

  default: next=20'bx;
  endcase
end
assign {state_next,nsel,loada,loadb,loadc,loads,vsel,write,asel,bsel,w}=next; //assigns values to output according to state
endmodule

module instructdec (in,nsel,ALUop,sximm5,sximm8,shift,rwnum,opcode,op);
  input [15:0] in;
  input [1:0] nsel;
  output [15:0] sximm5,sximm8;
  output reg [1:0] ALUop, shift,op;
  output reg [2:0] opcode;
  output [2:0] rwnum;
reg [4:0] imm5;
reg [7:0] imm8;
reg [2:0] Rn,Rd,Rm;

assign sximm5={{11{imm5[4]}},imm5};
assign sximm8={{8{imm8[7]}},imm8};
MUXb3 #(3) m3(Rn,Rd,Rm,nsel,rwnum);

always @* begin
  casex (in)
  16'b110_10_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b110,2'b0,in[12:11],5'b0,in[7:0],2'b0,in[10:8],3'b0,3'b0};//mov #im8
  16'b110_00_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b110,2'b0,in[12:11],5'b0,8'b0,in[4:3],3'b0,in[7:5],in[2:0]};//mov shifter


  16'b101_00_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b101,in[12:11],2'b0,5'b0,8'b0,in[4:3],in[10:8],in[7:5],in[2:0]};//add
  16'b101_01_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b101,in[12:11],2'b01,5'b0,8'b0,in[4:3],in[10:8],3'b0,in[2:0]};//cmp
  16'b101_10_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b101,in[12:11],2'b10,5'b0,8'b0,in[4:3],in[10:8],in[7:5],in[2:0]};//and
  16'b101_11_xxx_xxx_xx_xxx: {opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}={3'b101,in[12:11],2'b11,5'b0,8'b0,in[4:3],3'b0,in[7:5],in[2:0]};//mvn
default{opcode,ALUop,op,imm5,imm8,shift,Rn,Rd,Rm}=31'bx;
endcase
end
endmodule


module MUXb3 (a2,a1,a0,nsel,rwnum);//code from slideset 6 slide #24
  parameter k=3;
  input [k-1:0] a0,a1,a2;
  input [1:0] nsel;
  output [k-1:0] rwnum;
  wire [2:0] s;
  
  DecoderRF #(2,3) d(nsel,s);
  MUX3 #(k) m(a2,a1,a0,s,rwnum);
endmodule

module MUX3 (a2,a1,a0,s,b);//code from slideset 6 slide #20
  parameter k=3;
  input [k-1:0] a0,a1,a2;
  input [2:0] s;
  output [k-1:0] b;
  assign b=({k{s[0]}}&a0)|({k{s[1]}}&a1)|({k{s[2]}}&a2);
endmodule
