//THIS CODE IS A VARIATION OF THE CODE SEEN IN SLIDE SET #5 slide # 35-36

module regfile_tb();
  // No inputs or outputs, because it is a testbench
 
  reg [15:0] sim_data_in;
   reg [2:0] sim_writenum, sim_readnum;
   reg err, sim_write,sim_clk;
   wire [15:0] sim_data_out;

    REGFILE DUT (
      .data_in(sim_data_in),
      .write(sim_write),
      .writenum(sim_writenum),
      .readnum(sim_readnum),
      .data_out(sim_data_out),
      .clk(sim_clk)
    );

task checker; //task block checks if the output and Z are as expected and displays error is wrong
  input [15:0] expected_data_out;
begin
  if(sim_data_out!==expected_data_out) begin
    $display("ERROR ** data output from R%b is %b, expected %b",sim_writenum,sim_data_out,expected_data_out); //makes sure outs are the same
    err=1'b1;
  end
end 
endtask


initial begin
  sim_clk=0; #5; //simulates a button presses in 5 ps intervals 
  forever begin
    sim_clk=1; #5;
    sim_clk=0; #5;
  end
end

    initial begin
    //TEST 1 inputs to 0 check R0
    //initializing inputs to 0
     sim_data_in=16'b0; sim_writenum=3'b0; sim_readnum=3'b0; sim_write=1'b0; err=1'b0;#10; 
    //test for no signals - all inputs 0
    //expect 16'bx from R0

     checker(16'bx);

sim_data_in=16'b0000_0000_0010_1010;

  $display("checking write to R0"); //TEST 2 for writing 42 to register 0
    sim_writenum=3'b000;sim_write=1'b1;#10;
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b000; #5;
    checker(16'b0000_0000_0010_1010);#5;

sim_data_in=16'b0000_0000_0010_1011;

  $display("checking write to R1");   //TEST 3 for writing 43 in R1 
    sim_writenum=3'b001;sim_write=1'b1;#10;
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b001; #5;
    checker(16'b0000_0000_0010_1011);#5;

sim_data_in=16'b0000_0000_0010_1100;

  $display("checking write to R2"); //TEST 4 for writing 44 in R2 
    sim_writenum=3'b010;sim_write=1'b1; #10; 
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b010; #5;
    checker(16'b0000_0000_0010_1100); #5;

sim_data_in=16'b0000_0000_0010_1101;

  $display("checking write to R3");  //TEST 5 for writing 45 in R3
    sim_writenum=3'b011;sim_write=1'b1;#10; 
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b011; #5;
    checker(16'b0000_0000_0010_1101);#5;

sim_data_in=16'b0000_0000_0010_1110;

  $display("checking write to R4");  //TEST 5 for writing 46 in R4
    sim_writenum=3'b100;sim_write=1'b1;#10;
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b100; #5;
    checker(16'b0000_0000_0010_1110);#5;

sim_data_in=16'b0000_0000_0010_1111;

  $display("checking write to R5");  //TEST 6 for writing 47 in R5
    sim_writenum=3'b101;sim_write=1'b1;#10; 
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b101; #5;
    checker(16'b0000_0000_0010_1111);#5;

sim_data_in=16'b0000_0000_0011_0000;

  $display("checking write to R6");  //TEST 6 for writing 47 in R6 
    sim_writenum=3'b110;sim_write=1'b1;#10;
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b110; #5;
    checker(16'b0000_0000_0011_0000);#5;

sim_data_in=16'b0000_0000_0011_0001;

  $display("checking write to R7");  //TEST 7 for writing 48 in R7 
    sim_writenum=3'b111;sim_write=1'b1;#10;
    sim_writenum=3'bx;sim_write=1'b0; sim_readnum=3'b111; #5;
    checker(16'b0000_0000_0011_0001);#5;


  if(~err) $display("PASSED");
  else $display("FAILED");
 
    $stop;
    end
endmodule
