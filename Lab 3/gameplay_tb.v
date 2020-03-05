//gameplay testbench, no inputs or outputs
module gameplay_tb();

reg [8:0] sim_ain;
reg [8:0] sim_bin;
wire [8:0] sim_cout;


PlayAdjacentEdge dut (
	.ain(sim_ain),
	.bin(sim_bin),
	.cout(sim_cout)
);

initial begin

	//TEST FOR ALL INPUTS RESET

	//set inputs to 0s
	sim_ain = 9'b0;
	sim_bin = 9'b0;
	//wait five timesteps to allow changes to occur
  	#5;
  	//expect output to be 0 for no win
  	$display("Output is %b, we expected %b", sim_cout, 9'b0);


	//TESTS FOR PLAYING ADJ SIDE
  sim_ain = 9'b001000100;
	sim_bin = 9'b000010000;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b000001000);

    sim_ain = 9'b100000001;
	sim_bin = 9'b000010000;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b000001000);


    //TESTS FOR NOT PLAYING ADJ SIDE
    sim_ain = 9'b000010000;
	sim_bin = 9'b000000101;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b0);

    sim_ain = 9'b000001001;
	sim_bin = 9'b001010000;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b0);

    sim_ain = 9'b010011000;
	sim_bin = 9'b000100010;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b0);

    sim_ain = 9'b000000101;
	sim_bin = 9'b000010010;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b0);

    sim_ain = 9'b000010000;
	sim_bin = 9'b000000000;
  	#5;
    $display("Output is %b, we expected %b", sim_win_line, 9'b0);




  end
endmodule