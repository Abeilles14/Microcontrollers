module lab5_check_1;
  // checks your unit level test benches for compatibility with autograder

  // instantiate test benches (should have no inputs or outputs)
  regfile_tb  T1();
  shifter_tb  T2();
  ALU_tb      T3();

  // i/o signals for register file 
  wire [15:0] data_in  = T1.DUT.data_in;
  wire [2:0]  writenum = T1.DUT.writenum;
  wire        write    = T1.DUT.write;
  wire [2:0]  readnum  = T1.DUT.readnum;
  wire        clk      = T1.DUT.clk;
  wire [15:0] data_out = T1.DUT.data_out;
  wire        err_rf   = T1.err;

  // i/o signals for shifter module
  wire [15:0] in     = T2.DUT.in;
  wire [1:0]  shift  = T2.DUT.shift;
  wire [15:0] sout   = T2.DUT.sout;
  wire        err_sh = T2.err;

  // i/o signals for ALU module
  wire [15:0] Ain     = T3.DUT.Ain;
  wire [15:0] Bin     = T3.DUT.Bin;
  wire [1:0]  ALUop   = T3.DUT.ALUop;
  wire [15:0] out     = T3.DUT.out;
  wire        Z       = T3.DUT.Z;
  wire        err_ALU = T3.err;

  // autograder will examine changes in inputs to device under test to see how many cases you cover
  always @(*) $display("REG: %b %b %b %b %b %b %b", err, clk, data_in, writenum, write, readnum, data_out);
  always @(*) $display("SFT: %b %b %b %b",          err, in, shift, sout);
  always @(*) $display("ALU: %b %b %b %b %b %b",    err, Ain, Bin, ALUop, out, Z);

  initial begin
    #500; // limit tests to 500 time units
    $display("CHECK #1 DONE: Your unit level testbenches appear compatible with the autograder.");
    $display("** NOTE ** You must manually verify you had no simulation warnings");
    $display("by looking above this line in the transcript window in ModelSim.");
    $stop;
  end

  // stop one time unit after any error detected 
  wire err = err_rf | err_sh | err_ALU;
  always @(posedge err) begin
    #1;
    $stop;
  end
endmodule

module lab5_check_2;
  // checks register file, alu and shifter for compatibility with autograder

  // WARNING: While this single module checks the interface of your register
  // file, shifter and ALU to verify compatibility with the CPEN 211 
  // autograder, for Lab 5 you should create separate unit level test benches
  // for your register file, shifter and ALU.

  reg [15:0] data_in, in, Ain, Bin;
  reg [2:0] writenum,readnum;
  reg write, clk, err;
  reg [1:0] shift, ALUop;
  wire [15:0] data_out, sout, aout;
  wire Z;

  regfile DUT0(data_in,writenum,write,readnum,clk,data_out);
  shifter DUT1(in,shift,sout);
  ALU     DUT2(Ain,Bin,ALUop,aout,Z);

  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    err = 0;
    write = 1;
    data_in = 16'h42;
    writenum = 0;
    readnum = 0;

    in = 0;
    shift = 0;

    Ain = 16'h42;
    Bin = 16'h13;
    ALUop = 2'b00;

    #10;

    if (data_out !== 16'h42) begin
      err = 1;
      $display("FAILED: Regs[0] != 0x%h as expected", 16'h42); 
      $stop;
    end

    if (sout !== 16'b0) begin
      err = 1;
      $display("FAILED: shifter output != 0 as expected"); 
      $stop;
    end

    if (aout !== 16'h55) begin
      err = 1;
      $display("FAILED: ALU output != 0x%h as expected", 16'h55); 
      $stop;
    end

    if (Z !== 1'b0) begin
      err = 1;
      $display("FAILED: ALU zero detect != 0 as expected"); 
      $stop;
    end

    if (err === 0) begin
      $display("CHECK #2 DONE: Your register file, shifter and ALU appear compatible with the");
      $display("autograder. ** NOTE ** You must also manually verify you had no simulation");
      $display("warnings (above) and that you have no inferred latches (e.g., using Quartus).");
    end  

    $stop;
  end

endmodule


module lab5_check_3;
  // checks datapath for compatibility with autograder

  reg clk;
  reg [15:0] datapath_in;
  reg write, vsel, loada, loadb, asel, bsel, loadc, loads;
  reg [2:0] readnum, writenum;
  reg [1:0] shift, ALUop;

  wire [15:0] datapath_out;
  wire Z_out;

  reg err;

  datapath DUT ( .clk         (clk),

                // register operand fetch stage
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),

                // computation stage (sometimes called "execute")
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),

                // set when "writing back" to register file
                .writenum    (writenum),
                .write       (write),  
                .datapath_in (datapath_in),

                // outputs
                .Z_out       (Z_out),
                .datapath_out(datapath_out)
             );

  // autograder needs to be able to access the contents of your register file
  // using the following statements (wire used as follows acts like assign)
  wire [15:0] R0 = DUT.REGFILE.R0;
  wire [15:0] R1 = DUT.REGFILE.R1;
  wire [15:0] R2 = DUT.REGFILE.R2;
  wire [15:0] R3 = DUT.REGFILE.R3;
  wire [15:0] R4 = DUT.REGFILE.R4;
  wire [15:0] R5 = DUT.REGFILE.R5;
  wire [15:0] R6 = DUT.REGFILE.R6;
  wire [15:0] R7 = DUT.REGFILE.R7;

  // The first initial block below generates the clock signal. The clock (clk)
  // starts with value 0, changes to 1 after 5 time units and changes again 0
  // after 10 time units.  This repeats "forever".  Rising edges of clk are at
  // time = 5, 15, 25, 35, ...  
  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  // The rest of the inputs to our design under test (datapath) are defined 
  // below.
  initial begin
    // Plot err in your waveform to find out when first error occurs
    err = 0;
    
    // IMPORTANT: Set all control inputs to something at time=0 so not "undefined"
    datapath_in = 0;
    write = 0; vsel=0; loada=0; loadb=0; asel=0; bsel=0; loadc=0; loads=0;
    readnum = 0; writenum=0;
    shift = 0; ALUop=0;

    // Now, wait for clk -- clock rises at time = 5, 15, 25, 35, ...  Thus, at 
    // time = 10 the clock is NOT rising so it is safe to change the inputs.
    #10; 

    ////////////////////////////////////////////////////////////

    // First three instructions from Lab 5 intro slides

    // MOV R3, #42
    datapath_in = 16'h42; // h for hexadecimal
    writenum = 3'd3;
    write = 1'b1;
    vsel = 1'b1;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R3 !== 16'h42) begin
      err = 1; 
      $display("FAILED: MOV R3, #42 wrong -- Regs[R3]=%h is wrong, expected %h", R3, 16'h42); 
      $stop; 
    end

    ////////////////////////////////////////////////////////////

    // MOV R5, #13
    datapath_in = 16'h13;
    writenum = 3'd5;
    write = 1'b1;
    vsel = 1'b1;
    #10; // wait for clock 
    write = 0;  // done writing, remember to set write to zero

    // the following checks if MOV was executed correctly
    if (R5 !== 16'h13) begin 
      err = 1; 
      $display("FAILED: MOV R5, #13 wrong -- Regs[R5]=%h is wrong, expected %h", R5, 16'h13); 
      $stop; 
    end

    ////////////////////////////////////////////////////////////

    // ADD R2,R5,R3
    // step 1 - load contents of R3 into B reg
    readnum = 3'd3; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // step 2 - load contents of R5 into A reg 
    readnum = 3'd5; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // step 3 - perform addition of contents of A and B registers, load into C
    shift = 2'b00;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 1'b0;
    #10;
    write = 0;

    if (R2 !== 16'h55) begin 
      err = 1; 
      $display("FAILED: ADD R2, R5, R3 -- Regs[R2]=%h is wrong, expected %h", R2, 16'h55); 
      $stop; 
    end

    if (datapath_out !== 16'h55) begin 
      err = 1; 
      $display("FAILED: ADD R2, R5, R3 -- datapath_out=%h is wrong, expected %h", R2, 16'h55); 
      $stop; 
    end

    if (Z_out !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R5, R3 -- Z_out=%b is wrong, expected %b", Z_out, 1'b0); 
      $stop; 
    end

    if (err === 0) begin
      $display("CHECK #3 DONE: Your datapath appears to be compatibile with the autograder.");
      $display("** NOTE ** You must manually verify you had no simulation warnings");
      $display("(above) and that you have no inferred latches (e.g., using Quartus).");
    end 

    $stop;
  end
endmodule
