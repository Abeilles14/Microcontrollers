//DetectWinner testbench, no inputs or outputs
module detectwin_tb();

reg [8:0] sim_ain;
reg [8:0] sim_bin;
wire [7:0] sim_win_line;

//defining device under test
DetectWinner dut (
	.ain(sim_ain),
	.bin(sim_bin),
	.win_line(sim_win_line)
);

initial begin

	//TEST FOR ALL INPUT RESET

	//TEST 1 for all inputs set to 0 and no win
	//set inputs to 0s
	sim_ain = 9'b0;
	sim_bin = 9'b0;
	//wait five timesteps to allow changes to occur
  	#5;
  	//expect output to be 0 for no win
  	$display("Output is %b, we expected %b", sim_win_line, 8'b0);

	//TESTS FOR A OR B WINS

	//TEST 2 for A win row 1
	sim_ain = 9'b111000000;
	sim_bin = 9'b000101000;
	//wait five timesteps to allow changes to occur
  	#5;
    //expect output to be 1 for row 1 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000001);
	//TEST 3 for B win row 1
	sim_ain = 9'b000101001;
	sim_bin = 9'b111000000;
	//wait five timesteps to allow changes to occur
  	#5;
    //expect output to be 1 for row 1 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000001);

    //TEST 4 for A win row 2
	sim_ain = 9'b000111000;
	sim_bin = 9'b001000001;
  	#5;
    //expect output to be 1 for row 2 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000010);
	//TEST 3 for B win row 2, same result as A win
	sim_ain = 9'b101000001;
	sim_bin = 9'b000111000;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000010);

    //TEST 5 for A win row 3
	sim_ain = 9'b000000111;
	sim_bin = 9'b001010000;
  	#5;
    //expect output to be 1 for row 3 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000100);
	//TEST 6 for B win row 3, same result as A win
	sim_ain = 9'b101010000;
	sim_bin = 9'b000000111;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b00000100);

    //TEST 7 for A win col 1
	sim_ain = 9'b100100100;
	sim_bin = 9'b001010000;
  	#5;
    //expect output to be 1 for col 1 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00001000);
	//TEST 6 for B win col 1, same result as A win
	sim_ain = 9'b011010000;
	sim_bin = 9'b100100100;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b00001000);

    //TEST 8 for A win col 2
	sim_ain = 9'b010010010;
	sim_bin = 9'b001000100;
  	#5;
    //expect output to be 1 for col 2 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00010000);
	//TEST 9 for B win col 2, same result as A win
	sim_ain = 9'b101000100;
	sim_bin = 9'b010010010;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b00010000);

    //TEST 10 for A win col 3
	sim_ain = 9'b001001001;
	sim_bin = 9'b010000100;
  	#5;
    //expect output to be 1 for col 3 win
    $display("Output is %b, we expected %b", sim_win_line, 8'b00100000);
	//TEST 11 for B win col 2, same result as A win
	sim_ain = 9'b110000100;
	sim_bin = 9'b001001001;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b00100000);

    //TEST 12 for A win down diag
	sim_ain = 9'b100010001;
	sim_bin = 9'b001000100;
  	#5;
    //expect output to be 1 for down diag win
    $display("Output is %b, we expected %b", sim_win_line, 8'b01000000);
	//TEST 3 for B win down diag, same result as A win
	sim_ain = 9'b011000100;
	sim_bin = 9'b100010001;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b01000000);

    //TEST 14 for A win upw diag
	sim_ain = 9'b001010100;
	sim_bin = 9'b000100010;
  	#5;
    //expect output to be 1 for upw diag win
    $display("Output is %b, we expected %b", sim_win_line, 8'b10000000);
	//TEST 15 for B win upw diag, same result as A win
	sim_ain = 9'b010100010;
	sim_bin = 9'b001010100;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b10000000);


    //TESTS FOR DRAW
    //all inputs set, board is full, no win, expect all test outputs to be 9
	//TEST 16 for draw
	sim_ain = 9'b100011110;
	sim_bin = 9'b011100001;
  	#5;
    //expect output to be 0 for no win
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

    //TEST 17 for draw
	sim_ain = 9'b101110010;
	sim_bin = 9'b010001101;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

    //TEST 18 for draw
	sim_ain = 9'b101110010;
	sim_bin = 9'b010001101;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

    //TEST 19 for draw
	sim_ain = 9'b011110001;
	sim_bin = 9'b100001110;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

    //TEST 19 for draw
	sim_ain = 9'b010110101;
	sim_bin = 9'b101001010;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

    //TEST 20 for draw
	sim_ain = 9'b110001110;
	sim_bin = 9'b001110001;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 8'b0);

  end
endmodule  