module datapath(clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,writenum,write,datapath_in,Z_out,datapath_out);
input [15:0] datapath_in;
input [2:0] writenum, readnum;
input vsel,write,clk,loada,loadb,loadc,loads,asel,bsel;
input [1:0] shift,ALUop;
output Z_out;
output [15:0] datapath_out;
wire [15:0] data_in, data_out,in,sout,out,Ain,Bin,aout;
wire Z;
//module instantiations for datapath names refer to lab 5 handout
MUX writeback (datapath_in,datapath_out,vsel,data_in);  
regfile REGFILE (data_in,writenum,write,readnum,clk,data_out);
pipeline PLA (data_out,loada,aout);
pipeline PLB (data_out,loadb,in);\

shifter U1 (in,shift,sout);
MUX mux6 (16'b0,aout,asel,Ain);
MUX mux7 ({11'b0,datapath_in[4:0]},sout,bsel,Bin);
ALU U2 (Ain,Bin,ALUop,out,Z);
pipeline PLC (out,loadc,datapath_out);
status zstatus (Z,loads,Z_out);
endmodule

module MUX (path_in,back,vselect,data); //Multiplexer
input [15:0] path_in,back;
input vselect;
output reg [15:0] data;
always @* begin
  case (vselect)
    1'b0: data=back;
    1'b1: data=path_in;
    default: data=16'bx;
  endcase
end
endmodule

module pipeline (enter,loader,return); //pipeline register 
input [15:0] enter;
input loader;
output reg [15:0] return;
always @* begin
  case (loader)
    1'b1:return=enter;
    1'b0:return=return;
    default: return=16'bx;
  endcase
end
endmodule


module status (Zin,Zload,Zout); //Status Block
input Zin,Zload;
output reg Zout;

  always @* begin  
    case (Zload)
      1'b0:Zout=Zout;
      1'b1:Zout=Zin;
      default: Zout=1'bx;
    endcase
  end
endmodule
