module ALU(Ain, Bin, ALUop, out, Z);
 input [15:0] Ain, Bin;
 input [1:0] ALUop;
 output [15:0] out;
 output [2:0] Z; 
 //Z[2] is 1 if the output is 0
 //Z[1] is 1 if the output overflows
 //Z[0] is 1 if the output is negative

 reg [15:0] out;
 assign Z[2] = (out == 16'b0) ? 1'b1 : 1'b0; 
 assign Z[1] = ((ALUop == 2'b10)||(ALUop == 2'b11)) ? 1'b0: 
 ((ALUop == 2'b01) ? (Ain[15]^out[15])&(~Bin[15]^out[15]): (Ain[15]^out[15])&(Bin[15]^out[15]));
 assign Z[0] = out[15];

//Assign out based on the desired operation
 always@(*) begin
  case(ALUop)
  2'b00: out = Ain + Bin; //Add Ain and Bin
  2'b01: out = Ain - Bin; //Subtract Bin from Ain
  2'b10: out = Ain & Bin; //Ain ANDed with Bin
  2'b11: out = ~Bin; //NOT Bin

  default: out = 16'bx; //Default case for debugging
  endcase



end

endmodule
