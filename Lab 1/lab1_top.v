module lab1_top ( 
  input not_LEFT_pushbutton, 
  input not_RIGHT_pushbutton, 
  input [3:0] A, 
  input [3:0] B,  
  output reg [3:0] result );
  
  wire [3:0] ANDed_result;
  wire [3:0] ADDed_result;
  wire LEFT_pushbutton;
  wire RIGHT_pushbutton;

  assign ANDed_result = A & B;
  assign ADDed_result = A + B;

  assign LEFT_pushbutton = ~ not_LEFT_pushbutton;
  assign RIGHT_pushbutton = ~ not_RIGHT_pushbutton;

  always @* begin 
    case( {LEFT_pushbutton, RIGHT_pushbutton} ) 
      2'b01: result = ADDed_result; 
      2'b10: result = ANDed_result; 
      2'b11: result = ADDed_result;
    endcase 
  end
endmodule
