module lab4_top(SW,KEY,HEX0);
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0;

	reg [6:0] HEX0;
	reg [6:0] present_state;

	//initializes first state to 1
	initial HEX0 = 7'b1111001;
	initial present_state = 7'b1111001;

	//button 1 is pressed
	always @(negedge KEY[0]) begin
		//if reset button pressed, reset to 1
		if (KEY[1] == 0)
			present_state = 7'b1111001;		//1
		//if switch is on, move forward to next number
		else if (SW == 10'b0000000001) begin
			case(present_state)
				7'b1111001: present_state = 7'b0100100;		//1 --> 2
				7'b0100100: present_state = 7'b0110000;		//2 --> 3
				7'b0110000: present_state = 7'b0011001;		//3 --> 4
				7'b0011001: present_state = 7'b0010010;		//4 --> 5
  				7'b0010010: present_state = 7'b1111001;		//5 --> 1
  				default: present_state = 7'bx0x0x0x;		//err
  			endcase // present_state
  		end
  		//if switch is off, move backward to previous number
  		else if (SW == 10'b0000000000) begin
			case(present_state)
				7'b0010010: present_state = 7'b0011001;		//5 --> 4
				7'b0011001: present_state = 7'b0110000;		//4 --> 3
				7'b0110000: present_state = 7'b0100100;		//3 --> 2
				7'b0100100: present_state = 7'b1111001;		//2 --> 1
  				7'b1111001: present_state = 7'b0010010;		//1 --> 5
  				default: present_state = 7'b0x0x0x0;		//err
  			endcase // present_state
  		end
  		else
  			present_state = 7'bxxxxxxx;	//err
  		HEX0 = present_state;
  	end
endmodule
