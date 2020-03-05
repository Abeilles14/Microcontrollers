module shifter(in, shift, sout);
 input [15:0] in;
 input [1:0] shift;
 output [15:0] sout;
  reg [15:0] sout;

//Assign sout based on the desired shifting operation
 always@(*) begin
  case(shift)
  2'b00: sout = in; //sout = in
  2'b01: sout = in<<1; //Shifts to left by 1
  2'b10: sout = in>>1; //Shifts to right by 1
  2'b11: begin sout = in>>1; sout[15] = in[15]; end //Shifts to right by 1 MSB is 1
  default: sout = 16'bx; //Default case for debugging
  endcase
end
endmodule
