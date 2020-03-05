module cpu_tb ();
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N,V,Z,w;
  reg err;

  cpu DUT(.clk(clk),.reset(reset),.s(s),.load(load),.in(in),.out(out),.N(N),.V(V),.Z(Z),.w(w));

  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

initial begin
  err = 0; reset = 1; s = 0; load = 0; in = 16'b0; #10;
  reset = 0; #10;



//Test 1 testing first instruction
in=16'b110_10_111_11111001; $display("Test: MOV R7, #-7");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'b1111111111111001) begin
      err = 1;
      $display("FAILED: MOV R7, #-7");
      $stop;
    end

  //Test 2 testing first instruction writing into the same register
  in=16'b110_10_000_00000101; $display("Test: MOV R0, #5");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h5) begin
      err = 1;
      $display("FAILED: MOV R0, #5");
      $stop;
    end  

//Test 3 testing writing into a different register first instruction
in=16'b110_10_001_01111111; $display("Test: MOV R1, #127");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b0000000001111111) begin
      err = 1;
      $display("FAILED: MOV R1, #127");
      $stop;
    end

//input 6 into reg 2
in=16'b110_10_010_00000110; $display("Test: MOV R2, #6");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b0000000000000110) begin
      err = 1;
      $display("FAILED: MOV R2, #6");
      $stop;
    end

//Test 4 testing second instruction no shift 
in=16'b110_00_000_011_00_000; $display("Test: MOV R3,R0");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'h5) begin
      err = 1;
      $display("FAILED: MOV R3, R0");
      $stop;
    end

//Test 5 testing second instruction with left shift 
in=16'b110_00_000_100_01_000; $display("Test: MOV R4,R0, LSL#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000001010) begin
      err = 1;
      $display("FAILED: MOV R4, R0");
      $stop;
    end

//Test 6 testing second instruction with right shift and sign extension  
in=16'b110_00_000_100_11_000; $display("Test: MOV R4,R0, ASR#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000000010) begin
      err = 1;
      $display("FAILED: MOV R4, R0");
      $stop;
    end

//Test 7 testing third instruction
in=16'b101_00_010_101_00_000; $display("Test: ADD R5,R2,R0");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'b0000000000001011) begin
      err = 1;
      $display("FAILED: ADD R5,R2,R0");
      $stop;
    end

//Test 8 testing third instruction with right shift no sign extend
in=16'b101_00_000_110_10_010; $display("Test: ADD R6,R2,R0,LSR#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'b0000000000001000) begin
      err = 1;
      $display("FAILED: ADD R6,R2,R0, LSR#1");
      $stop;
    end

//Test 9 testing third instruction with right shift with sign extend
in=16'b101_00_000_110_11_100; $display("Test: ADD R6,R0,R4, ASR#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'b0000000000000110) begin
      err = 1;
      $display("FAILED: ADD R6,R0,R4, ASR#1");
      $stop;
    end

//Test 10 testing fourth instruction
in=16'b101_01_010_000_00_110; $display("Test: CMP R2,R6");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if ((cpu_tb.DUT.N!== 1'b0)&(cpu_tb.DUT.Z!== 1'b1)&(cpu_tb.DUT.V!== 1'b0)) begin
      err = 1;
      $display("FAILED: CMP R2,R6");
      $stop;
    end
//Test 11 testing fourth instruction with left shift for negative number
in=16'b101_01_101_000_01_110; $display("Test: CMP R5,R6,LSL#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.N!== 1'b1) begin
      err = 1;
      $display("FAILED: CMP R5,R6,LSL#1");
      $stop;
    end
 //Setting up overflow
  in=16'b110_10_111_00000111; $display("Test: MOV R7, #7");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R7, #5");
      $stop;
    end   
//setting up overflow
  in=16'b110_10_001_00000010; $display("Test: MOV R1, #2");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
      $stop;
    end  

//Test 12 testing fourth instruction overflow 
in=16'b101_01_010_000_00_111; $display("Test: CMP overflow R1,R7");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.V !== 1'b1) begin
      err = 1;
      $display("FAILED: CMP overflow R1,R7");
      $stop;
    end

//Test 13 testing fifth instruction
in=16'b101_10_010_100_00_000; $display("Test: AND R4,R2,R0");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000000100) begin
      err = 1;
      $display("FAILED: AND R4,R2,R0");
      $stop;
    end

//Test 14 testing fifth instruction with left shift
in=16'b101_10_010_100_01_000; $display("Test: AND R4,R2,R0,LSL#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000000010) begin
      err = 1;
      $display("FAILED: AND R4,R2,R0,LSL#1");
      $stop;
    end

//Test 15 testing fifth instruction right shift with sign extend
in=16'b101_10_010_100_11_000; $display("Test: AND R4,R2,R0,ASR#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000000010) begin
      err = 1;
      $display("FAILED: AND R4,R2,R0,ASR#1");
      $stop;
    end

//Test 16 testing sixth instruction
in=16'b101_11_000_101_00_000; $display("Test: MVN R5,R0");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'b1111111111111010) begin
      err = 1;
      $display("FAILED: MVN R5,R0");
      $stop;
    end

//Test 17 testing sixth instruction with left shift no sign extend
in=16'b101_11_000_101_01_100; $display("Test: MVN R5,R4, LSL#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'b1111111111111011) begin
      err = 1;
      $display("FAILED: MVN R5,R4, LSR#1");
      $stop;
    end

//Test 18 testing sixth instruction with left shift
in=16'b101_11_000_110_01_101; $display("Test: MVN R6,R5,LSL#1");
  load = 1; #10;
  load = 0; s = 1; #10;
  s = 0;
  @(posedge w); // wait for w to go high again
  #10;
  if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'b0000000000001001) begin
      err = 1;
      $display("FAILED: MVN R6,R5,LSL#1");
      $stop;
    end

if (~err) $display("Passed all tests");
    $stop;
end
endmodule
