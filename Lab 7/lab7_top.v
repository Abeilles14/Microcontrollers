`define MWRITE 2'b10
`define MREAD 2'b01

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
wire clk,msel,N,V,Z;
wire [1:0] mem_cmd;
wire [8:0] mem_addr;
wire [15:0]din,dout,read_data,datapath_out;
reg write,tricase;


RAM  #(16,8) mem(.clk(clk),.read_address(mem_addr[7:0]),.write_address(mem_addr[7:0]),.write(write),.din(datapath_out),.dout(dout));
cpu programfsm(.clk(clk),.reset(reset),.in(read_data),.out(datapath_out),.N(N),.V(V),.Z(Z),.mem_addr(mem_addr),.mem_cmd(mem_cmd));
assign msel=1'b0&~mem_addr[8];
assign read_data= tricase?dout:16'bzzzz_zzzz_zzzz_zzzz;
always @* begin
  if (`MWRITE==mem_cmd) begin
	write=`MWRITE&&msel;
  end else begin
        write=1'bx;
  end
  if (`MREAD==mem_cmd) begin
	tricase=`MREAD&&msel;
  end else begin
        tricase=1'bx;
  end
end
endmodule 

// From Altera's Quartus II Handbook (QII5V1 2015.05.04) in Chapter 12, ?Recommended HDL Coding Style? via slide set 7 slide 74
module RAM(clk,read_address,write_address,write,din,dout);// From Altera's Quartus II Handbook (QII5V1 2015.05.04) in Chapter 12, ?Recommended HDL Coding Style?slide set 7 slide 74
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule


