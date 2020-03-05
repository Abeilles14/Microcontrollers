module ALU_tb();
  // No inputs or outputs, because it is a testbench

   reg [1:0] sim_ALUop;
   reg [15:0] sim_Ain;
   reg [15:0] sim_Bin;
   reg err;
   wire [15:0] sim_out;
   wire sim_Z;

    ALU DUT (
      .Ain(sim_Ain),
      .Bin(sim_Bin),
      .ALUop(sim_ALUop),
      .out(sim_out),
      .Z(sim_Z)
    );

task checker; //task block checks if the output and Z are as expected and displays error is wrong
  input [15:0] expected_out;
  input expected_Z;
begin
  if(sim_out!==expected_out) begin
    $display("ERROR ** out is %b, expected %b",sim_out,expected_out); //makes sure outs are the same
    err=1'b1;
  end
  if (sim_Z!==expected_Z) begin
    $display("ERROR ** Z is %b, expected %b",sim_Z,expected_Z); //makes sure Z are the same
    err=1'b1;
  end
end 
endtask

    initial begin
     sim_Ain =16'b0; sim_Bin=16'b0; sim_ALUop=2'b0;err=1'b0;#10; 
  checker(16'b0,1'b1);

sim_Ain=16'b0000_0000_1111_1111;
sim_Bin=16'b0000_0000_0000_0001;

  $display("checking A+B"); //Test 1 checks A+B
    sim_ALUop=2'b00;#10;
    checker(16'b0000_0001_0000_0000,1'b0);

  $display("checking A-B"); //Test 2 checks A-B
    sim_ALUop=2'b01; #10;
    checker(16'b0000_0000_1111_1110,1'b0);

  $display("checking A&B"); //Test 3 checks A&B
    sim_ALUop=2'b10; #10;
    checker(16'b0000_0000_0000_0001,1'b0);
  
  $display("checking ~B"); //Test 4 check ~B
    sim_ALUop=2'b11; #10;
    checker(16'b1111_1111_1111_1110,1'b0);
  
sim_Ain=16'b1111_1111_1111_1111;
sim_Bin=16'b0000_0000_0000_0000;


  $display("checking A+B"); //Test 1 checks A+B
    sim_ALUop=2'b00;#10;
    checker(16'b1111_1111_1111_1111,1'b0);

  $display("checking A-B");//Test 2 checks A-B
    sim_ALUop=2'b01; #10;
    checker(16'b1111_1111_1111_1111,1'b0);

  $display("checking A&B"); //Test 3 checks A&B
    sim_ALUop=2'b10; #10;
    checker(16'b0000_0000_0000_0000,1'b1);
  
  $display("checking ~B"); //Test 4 check ~B
    sim_ALUop=2'b11; #10;
    checker(16'b1111_1111_1111_1111,1'b0);
  


sim_Ain=16'b0010_1010_1010_1010;
sim_Bin=16'b0010_1010_1010_1010;

  $display("checking A+B"); //Test 1 checks A+B
    sim_ALUop=2'b00;#10;
    checker(16'b0101_0101_0101_0100,1'b0);

  $display("checking A-B");//Test 2 checks A-B
    sim_ALUop=2'b01; #10;
    checker(16'b0000_0000_0000_0000,1'b1);

  $display("checking A&B"); //Test 3 checks A&B
    sim_ALUop=2'b10; #10;
    checker(16'b0010_1010_1010_1010,1'b0);
  
  $display("checking ~B"); //Test 4 check ~B
    sim_ALUop=2'b11; #10;
    checker(16'b1101_0101_0101_0101,1'b0);

sim_Ain=16'b1000_0000_0000_0000;
sim_Bin=16'b0111_1111_1111_1111;

  $display("checking A+B"); //Test 1 checks A+B
    sim_ALUop=2'b00;#10;
    checker(16'b1111_1111_1111_1111,1'b0);

  $display("checking A-B");//Test 2 checks A-B
    sim_ALUop=2'b01; #10;
    checker(16'b0000_0000_0000_0001,1'b0);

  $display("checking A&B"); //Test 3 checks A&B
    sim_ALUop=2'b10; #10;
    checker(16'b0000_0000_0000_0000,1'b1);
  
  $display("checking ~B"); //Test 4 check ~B
    sim_ALUop=2'b11; #10;
    checker(16'b1000_0000_0000_0000,1'b0);

sim_Ain=16'b1010_0010_1000_1010;
sim_Bin=16'b0100_1010_1010_0101;

  $display("checking A+B"); //Test 1 checks A+B
    sim_ALUop=2'b00;#10;
    checker(16'b1110_1101_0010_1111,1'b0);

  $display("checking A-B");//Test 2 checks A-B
    sim_ALUop=2'b01; #10;
    checker(16'b0101_0111_1110_0101,1'b0);

  $display("checking A&B"); //Test 3 checks A&B 
    sim_ALUop=2'b10; #10;
    checker(16'b0000_0010_1000_0000,1'b0);
  
  $display("checking ~B"); //Test 4 check ~B
    sim_ALUop=2'b11; #10;
    checker(16'b1011_0101_0101_1010,1'b0);

  if(~err) $display("PASSED");
  else $display("FAILED");
 
    $stop;
    end
endmodule
