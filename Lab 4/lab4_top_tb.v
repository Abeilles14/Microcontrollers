module lab4_top_tb();
	reg [9:0] sim_SW;
	reg [3:0] sim_KEY;
	wire [6:0] sim_HEX0;

	lab4_top dut(
		.SW(sim_SW),
		.KEY(sim_KEY),
		.HEX0(sim_HEX0)
	);

	initial begin

		//initially reset at 1, switch at 1, no buttons pressed yet
		sim_KEY = 4'b1111;
		sim_SW = 10'b000000001;

		//TEST 1 KEY0 pressed, switch = 1, rising edge, present = 1, move forward = 2
		sim_KEY[0] = 0;
	  	#5;
	  	//expect output to be 2
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b0100100);
		//KEY0 released, switch = 1, initially = 2, nothing happens = 2
		sim_KEY[0] = 1;
	  	#3;
	  	//expect output to be 1
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b0100100);

		//TEST 2 KEY0 pressed, switch = 1, rising edge, present = 2, move forward = 3
		sim_KEY[0] = 0;
	  	#5;
	  	//expect output to be 3
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b0110000);
	  	//KEY0 released, nothing happens = 3
		sim_KEY[0] = 1;
	  	#3;

	  	//TEST 3 KEY1 KEY0 pressed, switch = 1, initially = 3, reset = 1
		sim_KEY[1] = 0;
		sim_KEY[0] = 0;
	  	#5;
	  	//expect output to be 1
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b1111001);
		//KEY1 KEY0 released, nothing happens = 1
		sim_KEY[1] = 1;
		sim_KEY[0] = 1;
	  	#3;

		//TEST 4 KEY0 pressed, switch = 0, initially = 1, move backward = 5
		sim_SW[0] = 0;
		sim_KEY[0] = 0;
	  	#5;
	  	//expect output to be 5
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b0010010);
	  	//KEY0 released, nothing happens = 5
	  	sim_KEY[0] = 1;
	  	#3;

		//TEST 5 KEY0 pressed, switch = 1, initially = 5, move loop forward = 1
		sim_SW[0] = 1;
		sim_KEY[0] = 0;
	  	#5;
	  	//expect output to be 1
	  	$display("Output is %b, we expected %b", sim_HEX0, 7'b1111001);
	  	
  	end
  endmodule