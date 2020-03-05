module ALU(Ain, Bin, ALUop, out, Z);
 input [15:0] Ain, Bin;
 input [1:0] ALUop;
 output [15:0] out;
 output Z;

 reg Z;
 reg [15:0] out;

//Assign out based on the desired operation
 always@(*) begin
  case(ALUop)
  2'b00: out = Ain + Bin; //Add Ain and Bin
  2'b01: out = Ain - Bin; //Subtract Bin from Ain
  2'b10: out = Ain & Bin; //Ain ANDed with Bin
  2'b11: out = ~Bin; //NOT Bin

  default: out = 16'bx; //Default case for debugging
  endcase

  Z = (out == 16'b0) ? 1 : 0; //If output is all 0, Z is 1. Otherwise Z is 0.

end
endmodule
