module shifter_tb();
  // No inputs or outputs, because it is a testbench
  reg [15:0] sim_in;
  reg [1:0] sim_shift;
  wire [15:0] sim_sout;
  reg err;

    shifter DUT (
      .in(sim_in),
      .shift(sim_shift),
      .sout(sim_sout)
);

task checker; //task block checks if the outputs are as expected
  input [15:0] expected_sout;

begin
  if(sim_sout!==expected_sout) begin
    $display("ERROR ** sout is %b, expected %b",sim_sout,expected_sout); //makes sure outs are the same
    err=1'b1;
  end
end 
endtask

    initial begin
     sim_in =16'b0; sim_shift=2'b0; err=1'b0;#5; 
     checker(16'b0);#5;

sim_in=16'b1111_1111_1111_1111;

  $display("checking no shift"); //TEST 1 testing no shift 00
    sim_shift=2'b00;#10;
    checker(16'b1111_1111_1111_1111); #5;

  $display("checking shift left"); //TEST 2 testing shift left 01
    sim_shift=2'b01; #10;
    checker(16'b1111_1111_1111_1110);#5;

  $display("checking shift right w MSB 0"); //TEST 3 testing shift right 10
    sim_shift=2'b10; #10;
    checker(16'b0111_1111_1111_1111);#5;
  
  $display("checking shift right w MSB in[15]");//TEST 4 testing shift right 11 append last bit
    sim_shift=2'b11; #10;
    checker(16'b1111_1111_1111_1111);#5;

sim_in=16'b0000_0000_0000_0000;

  $display("checking no shift"); //TEST 1 testing no shift 00
    sim_shift=2'b00;#10;
    checker(16'b0000_0000_0000_0000); #5;

  $display("checking shift left");//TEST 2 testing shift left 01 
    sim_shift=2'b01; #10;
    checker(16'b0000_0000_0000_0000);#5;

  $display("checking shift right w MSB 0"); //TEST 3 testing shift right 10

    sim_shift=2'b10; #10;
    checker(16'b0000_0000_0000_0000);#5;
  
  $display("checking shift right w MSB in[15]");//TEST 4 testing shift right 11 append last bit
    sim_shift=2'b11; #10;
    checker(16'b0000_0000_0000_0000);#5;

sim_in=16'b1111_0000_1100_1111;

  $display("checking no shift"); //TEST 1 testing no shift 00

    sim_shift=2'b00;#10;
    checker(16'b1111_0000_1100_1111); #5;

  $display("checking shift left"); //TEST 2 testing shift left 01
    sim_shift=2'b01; #10;
    checker(16'b1110_0001_1001_1110);#5;

  $display("checking shift right w MSB 0"); //TEST 3 testing shift right 10
    sim_shift=2'b10; #10;
    checker(16'b0111_1000_0110_0111);#5;
  
  $display("checking shift right w MSB in[15]");//TEST 4 testing shift right 11 append last bit
    sim_shift=2'b11; #10;
    checker(16'b1111_1000_0110_0111);#5;

sim_in=16'b0101_0101_0101_0101;

  $display("checking no shift"); //TEST 1 testing no shift 00
    sim_shift=2'b00;#10;
    checker(16'b0101_0101_0101_0101); #5;

  $display("checking shift left"); //TEST 2 testing shift left 01
    sim_shift=2'b01; #10;
    checker(16'b1010_1010_1010_1010);#5;

  $display("checking shift right w MSB 0"); //TEST 3 testing shift right 10
    sim_shift=2'b10; #10;
    checker(16'b0010_1010_1010_1010);#5;
  
  $display("checking shift right w MSB in[15]");//TEST 4 testing shift right 11 append last bit
    sim_shift=2'b11; #10;
    checker(16'b0010_1010_1010_1010);#5;

sim_in=16'b1010_0101_0010_1011;

  $display("checking no shift"); //TEST 1 testing no shift 00
    sim_shift=2'b00;#10;
    checker(16'b1010_0101_0010_1011); #5;

  $display("checking shift left"); //TEST 2 testing shift left 01
    sim_shift=2'b01; #10;
    checker(16'b0100_1010_0101_0110);#5;

  $display("checking shift right w MSB 0"); //TEST 3 testing shift right 10
    sim_shift=2'b10; #10;
    checker(16'b0101_0010_1001_0101);#5;
  
  $display("checking shift right w MSB in[15]");//TEST 4 testing shift right 11 append last bit
    sim_shift=2'b11; #10;
    checker(16'b1101_0010_1001_0101);#5;

  if(~err) $display("PASSED");
  else $display("FAILED");
 
    $stop;
    end
endmodule
