`define RESET 1'b1
`define NORESET 1'b0
`define START 1'b1
`define STOP 1'b0
`define LOAD 1'b1
`define NOTLOAD 1'b0
`define MOVR0N128 16'b1101000010000000 //Move -128 to R0
`define MOVR1N37 16'b1101000111011011 //Move -37 to R1
`define MOVR2P25 16'b1101001000011001 //Move 25 to R2
`define MOVR3R0LSR1 16'b1100000001110000 //Move R0 LSR to R3 
`define MOVR4R1ASR1 16'b1100000010011001 //Move R1 ASR to R4
`define MOVR5R2LSL1 16'b1100000010101010 //Move R2 LSL to R5
`define ADDR6R5R4 16'b1010010111000100 //ADD R4 AND R5 to R6
`define ADDR7R0R1ASR1 16'b1010000011111001 //ADD R1 ASR AND R0 TO R7
`define ADDR0R0R2LSR1 16'b1010000000010010 //ADD R2 LSR AND R0 TO R0
`define ADDR1R4R5LSL1 16'b1010010000101101 //ADD R5 LSL AND R4 TO R1
`define CMDR3R0LSL1 16'b1010101100001000 //Get STATUS of R3 MINUS R0 LSL
`define CMDR2R5LSR1 16'b1010101000010101 // Get STATUS of R2 MINUS R5 LSR
`define CMDR4R6ASR1 16'b1010110000011110 // Get STATUS of R4 MINUS R6 ASR
`define CMDR5R6 16'b1010110100000110 // Get STATUS of R5 MINUS R6
`define ANDR2R0R1LSR1 16'b1011000001010001 //AND R0 AND R1 LSR TO R2
`define ANDR3R4R5ASR1 16'b1011010001111101 //AND R4 AND R5 ASR TO R3
`define ANDR4R7R0LSL1 16'b1011011110001000 //AND R7 AND R0 LSL TO R4
`define MVNR5R1 16'b1011100010100001 //MOVE R1 NOT TO R5
`define MVNR6R7LSR1 16'b1011100011010111 //MOVE R7 LSR NOT TO R6
`define MVNR7R2ASR1 16'b1011100011111010 //MOVE R2 ASR NOT TO R7
`define MVNR0R3LSL1 16'b1011100000001011 //MOVE R3 LSL NOT TO R0 
`define n_32704 16'b0111111111000000 
`define n_N19 16'b1111111111101101
`define n_50 16'b0000000000110010
`define n_31 16'b0000000000011111
`define n_N147 16'b1111111101101101
`define n_N116 16'b1111111110001100
`define n_81 16'b0000000001010001
`define n_8 16'b0000000000001000
`define n_9 16'b0000000000001001
`define n_N248 16'b1111111100001000
`define n_N82 16'b1111111110101110
`define n_N32695 16'b1000000001001001
`define n_N5 16'b1111111111111011
`define n_N19 16'b1111111111101101
`define UNDEF16 16'bx
`define UNDEF1 1'bx
`define ON 1'b1
`define OFF 1'b0

module cpu_tb();
reg s_clk, s_reset, s_load;
reg [15:0] s_in; 
wire [15:0] s_out;
wire s_N,s_V,s_Z;

cpu DUT(.clk(s_clk), .reset(s_reset), .load(s_load), .in(s_in), .out(s_out), .N(s_N), .V(s_V), .Z(s_Z));

reg err; 


task checker;
  input [15:0] expected_s_out;
  input expected_s_Z, expected_s_V, expected_s_N,expected_s_w;
begin
    if(cpu_tb.DUT.out !== expected_s_out) begin
      $display("ERROR: output is %d, expected %d", 
      cpu_tb.DUT.out,expected_s_out);
      err = 1'b1; 
    end
    if(cpu_tb.DUT.Z !== expected_s_Z) begin
      $display("ERROR: Z is %d, expected %d", 
      cpu_tb.DUT.Z, expected_s_Z);
      err = 1'b1; 
    end
    if(cpu_tb.DUT.V !== expected_s_V) begin
      $display("ERROR: V is %d, expected %d", 
      cpu_tb.DUT.V, expected_s_V);
      err = 1'b1; 
    end
    if(cpu_tb.DUT.N !== expected_s_N) begin
      $display("ERROR: N is %d, expected %d", 
      cpu_tb.DUT.N, expected_s_N);
      err = 1'b1; 
    end
end
endtask

initial begin 
    s_clk = 1'b0; #5; //Rising edge at 5 seconds
    forever begin 
    s_clk = 1'b1; #5; //Falling edge at 10k seconds
    s_clk = 1'b0; #5; //Rising edge at 5+10k seconds
    end
end

initial begin 
err = 1'b0;
//Store nothing during the first edge cycle of clk
s_reset = `RESET; s_s = `STOP; s_load = `NOTLOAD; s_in = `MOVR0N128; //Reset state machine, S is stop, load nothing, In has instructions
#10;
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
s_reset = `NORESET; //Reset is off
#10; 
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITE_REG

s_in = `MOVR1N37; //Feed in next instruction set
#10;
//R0 SHOULD CONTAIN -128
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITE_REG

s_in = `MOVR2P25; //Feed in next instruction set
#10;
//R1 SHOULD CONTAIN -37
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITE_REG

s_in = `MOVR3R0LSR1; //Feed in next instruction set
#10;
//R2 SHOULD CONTAIN 25
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10;  
checker(`UNDEF16,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in the STATE_OPS

#10;
checker(`n_32704,`UNDEF1, `UNDEF1, `UNDEF1, `OFF); //Should be in the STATE_WRITEREG

s_in = `MOVR4R1ASR1; //Feed in next instruction set
#10;
//R3 SHOULD CONTAIN 32704
checker(`n_32704,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_32704,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_32704,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10;  
checker(`n_32704,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in the STATE_OPS

#10;
checker(`n_N19,`UNDEF1, `UNDEF1, `UNDEF1, `OFF); //Should be in the STATE_WRITEREG

s_in = `MOVR5R2LSL1; //Feed in next instruction set
#10;
//R4 SHOULD CONTAIN -19
checker(`n_N19,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N19,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_N19,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10;  
checker(`n_N19,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in the STATE_OPS

#10;
checker(`n_50,`UNDEF1, `UNDEF1, `UNDEF1, `OFF); //Should be in the STATE_WRITEREG

s_in = `ADDR6R5R4; //Feed in next instruction set
#10;
//R5 SHOULD CONTAIN 50
checker(`n_50,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_50,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_50,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_50,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_50,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_OPS

#10; 
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITEREG

s_in = `ADDR7R0R1ASR1; //Feed in next instruction set
#10;
//R6 SHOULD CONTAIN 31
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_31,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_OPS

#10; 
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITEREG

s_in = `ADDR0R0R2LSR1; //Feed in next instruction set
#10;
//R7 SHOULD CONTAIN -147
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_N147,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_OPS

#10; 
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITEREG

s_in = `ADDR1R4R5LSL1; //Feed in next instruction set
#10;
//R0 SHOULD CONTAIN -116
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_N116,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_OPS

#10; 
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_WRITEREG

s_in = `CMDR3R0LSL1; //Feed in next instruction set
#10;
//R1 SHOULD CONTAIN 81
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_81,`UNDEF1,`UNDEF1,`UNDEF1,`OFF); //Should be in STATE_OPS

s_in = `CMDR2R5LSR1; //Feed in next instruction set
#10; 
//OUT IS 81, Z IS OFF, V IS ON, N IS ON
checker(`n_81,`OFF,`ON,`ON,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_81,`OFF,`ON,`ON,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_81,`OFF,`ON,`ON,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_81,`OFF,`ON,`ON,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_81,`OFF,`ON,`ON,`OFF); //Should be in STATE_OPS

s_in = `CMDR4R6ASR1; //Feed in next instruction set
#10;
//OUT IS 81, Z IS ON, V IS OFF, N IS OFF
checker(`n_81,`ON,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_81,`ON,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_81,`ON,`OFF,`OFF,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_81,`ON,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_81,`ON,`OFF,`OFF,`OFF); //Should be in STATE_OPS

s_in = `CMDR5R6; //Feed in next instruction set
#10;
//OUT IS 81, Z IS OFF, V IS OFF, N IS ON
checker(`n_81,`OFF,`OFF,`ON,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_81,`OFF,`OFF,`ON,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_81,`OFF,`OFF,`ON,`OFF); //Should be in STATE_GET_A

#10; 
checker(`n_81,`OFF,`OFF,`ON,`OFF); //Should be in STATE_GET_B

#10; 
checker(`n_81,`OFF,`OFF,`ON,`OFF); //Should be in STATE_OPS

s_in = `ANDR2R0R1LSR1; //Feed in next instruction set
#10;
//OUT IS 81, Z IS OFF, V IS OFF, N IS OFF
checker(`n_81,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_81,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_81,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_A

#10;
checker(`n_81,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_81,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_8,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `ANDR3R4R5ASR1; //Feed in next instruction set
#10;
//R2 SHOULD CONTAIN 8
checker(`n_8,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_8,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_8,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_A

#10;
checker(`n_8,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_8,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_9,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `ANDR4R7R0LSL1; //Feed in next instruction set
#10;
//R3 SHOULD CONTAIN 9
checker(`n_9,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_9,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10; 
checker(`n_9,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_A

#10;
checker(`n_9,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_9,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_N248,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `MVNR5R1; //Feed in next instruction set
#10;
//R4 SHOULD CONTAIN -187
checker(`n_N248,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N248,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_N248,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_N248,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_N82,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `MVNR6R7LSR1; //Feed in next instruction set
#10;
//R5 SHOULD CONTAIN 113
checker(`n_N82,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N82,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_N82,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_N82,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_N32695,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `MVNR7R2ASR1; //Feed in next instruction set
#10;
//R6 SHOULD CONTAIN -32695
checker(`n_N32695,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N32695,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_N32695,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_N32695,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_N5,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG

s_in = `MVNR0R3LSL1; //Feed in next instruction set
#10;
//R7 SHOULD CONTAIN -5
checker(`n_N5,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

s_load = `LOAD; //Load turns on
s_s = `START; //Start the state machine
#10; 
checker(`n_N5,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_DECODE

s_load = `NOTLOAD; //Turn off load
s_s = `STOP; //Turn off S
#10;
checker(`n_N5,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_GET_B

#10;
checker(`n_N5,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_OPS

#10;
checker(`n_N19,`OFF,`OFF,`OFF,`OFF); //Should be in STATE_WRITEREG
#10;
//R0 SHOULD CONTAIN -19
checker(`n_N19,`OFF,`OFF,`OFF,`ON); //Should be in STATE_WAIT

    if(~err) begin
    $display("PASSED");
    end else begin
    $display("FAILED");
    end

    $stop;
  end
endmodule
