module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum,readnum;
  input write,clk;
  output [15:0] data_out;
  wire [7:0] d,e,f;    //variables for inbetween
  wire [15:0] R0,R1,R2,R3,R4,R5,R6,R7;

decoder #(3,8) writer (writenum, d);  //writes values
check_write checker (write,d,e);      //ands the values
decoder #(3,8) reader (readnum,f);    //reads values

//loads R0:R7
vDFF_load #(16) R0_call (data_in,e[0],clk,R0);
vDFF_load #(16) R1_call (data_in,e[1],clk,R1);
vDFF_load #(16) R2_call (data_in,e[2],clk,R2);
vDFF_load #(16) R3_call (data_in,e[3],clk,R3);
vDFF_load #(16) R4_call (data_in,e[4],clk,R4);
vDFF_load #(16) R5_call (data_in,e[5],clk,R5);
vDFF_load #(16) R6_call (data_in,e[6],clk,R6);
vDFF_load #(16) R7_call (data_in,e[7],clk,R7);
MUX8a #(16) final (R7,R6,R5,R4,R3,R2,R1,R0,f,data_out); 
endmodule

//Load enabled register
module vDFF_load (data,load,c,out);//from the slide "lab 5 introduction"
parameter n=16; 
  input [n-1:0] data;
  input c,load;
  output reg [n-1:0]out;
  wire [15:0] next_out= load ?data :out;
 always @(posedge c) begin
      out=next_out;
  end
endmodule

//Decoder
module decoder(a,b); //from slide set 6 slide #8
  parameter g=3;
  parameter h=8;
  
  input [g-1:0] a;
  output [h-1:0] b;
  
  wire [h-1:0] b =1<< a;
endmodule

//Multiplexer
module MUX8a(a7,a6,a5,a4,a3,a2,a1,a0,s,b); //from slide set 6 slide # 20
  parameter k =16;
  input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
  input [7:0] s;
  output [k-1:0] b;
  wire [k-1:0] b=({k{s[0]}} & a0) | 
                 ({k{s[1]}} & a1) | 
                 ({k{s[2]}} & a2) | 
                 ({k{s[3]}} & a3) |
                 ({k{s[4]}} & a4) |
                 ({k{s[5]}} & a5) |
                 ({k{s[6]}} & a6) |
                 ({k{s[7]}} & a7); 
endmodule

module check_write (wri,one_hot,one_hot_out);
parameter j=8;
input [j-1:0] one_hot;
input wri;
output [j-1:0] one_hot_out;
wire [j-1:0] one_hot_out= ({j{wri}}&one_hot);
endmodule
