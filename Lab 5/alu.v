module ALU(Ain,Bin,ALUop,out,Z);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output Z;
reg [15:0] out;
reg Z;
//assigns specific operation to output depending on ALUop input
//sets Z to 1 if operation output is 0
always @* begin
  case (ALUop) 
    2'b00: {out,Z}= {(Ain+Bin),((Ain+Bin)?1'b0:1'b1)};  //adds
    2'b01: {out,Z}= {(Ain-Bin),((Ain-Bin)?1'b0:1'b1)};  //subtracts
    2'b10: {out,Z}= {(Ain&Bin),((Ain&Bin)?1'b0:1'b1)};  //ands
    2'b11: {out,Z}= {(~Bin),((~Bin)? 1'b0:1'b1)};       //nots Bin
    default: out=15'bx;
  endcase
end

endmodule
