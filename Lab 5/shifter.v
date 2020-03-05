module shifter (in,shift,sout);
//decides whether to remain same, shift left, right or right with append MSB [15]
  input [15:0] in;
  input [1:0] shift;
  output [15:0] sout;
  reg [15:0] sout;

  always @* begin
    case (shift)
      
      2'b00: sout =in;     //stays the same
      2'b01: sout= in<<1;  //shift left
      2'b10: sout= in>>1; //shift right (MSB=0)
      2'b11: sout= {in[15],in[15:1]}; //shift right(MSB=in[15])
      default: sout= 16'bx; 
    endcase
  end
endmodule 