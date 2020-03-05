module datapath_tb ();
reg [15:0] sim_datapath_in;
reg [2:0] sim_writenum, sim_readnum;
reg err,sim_vsel,sim_write,sim_clk,sim_loada,sim_loadb,sim_loadc,sim_loads,sim_asel,sim_bsel;
reg [1:0] sim_shift,sim_ALUop;
wire sim_Z_out;
wire [15:0] sim_datapath_out;

datapath DUT (   .clk(sim_clk), // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                .readnum     (sim_readnum),
                .vsel        (sim_vsel),
                .loada       (sim_loada),
                .loadb       (sim_loadb),

                // computation stage (sometimes called "execute")
                .shift       (sim_shift),
                .asel        (sim_asel),
                .bsel        (sim_bsel),
                .ALUop       (sim_ALUop),
                .loadc       (sim_loadc),
                .loads       (sim_loads),

                // set when "writing back" to register file
                .writenum    (sim_writenum),
                .write       (sim_write),  
                .datapath_in (sim_datapath_in),

                // outputs
                .Z_out       (sim_Z_out),
                .datapath_out(sim_datapath_out)
             );
task checker; //task block checks if the output and Z are as expected and displays error is wrong
  input [15:0] expected_datapath_out;
  input expected_Z;
begin
  if(sim_datapath_out!==expected_datapath_out) begin
    $display("ERROR ** data output is %b, expected %b",sim_datapath_out,expected_datapath_out); //makes sure outs are the same
    err=1'b1;
  end
  if(sim_Z_out!==expected_Z) begin
    $display("ERROR ** data output Z is %b, expected %b",sim_Z_out,expected_Z); //makes sure outs are the same
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
//Test 1 
sim_datapath_in=16'b0;
sim_writenum=3'b0; sim_readnum=3'b0; //Sets inputs to 0
err=1'b0;sim_vsel=1'b0;sim_write=1'b0;sim_loada=1'b0;sim_loadb=1'b0;sim_loadc=1'b0;sim_loads=1'b1;sim_asel=1'b0;sim_bsel=1'b0;
sim_shift=2'b00;sim_ALUop=2'b0; #10;

//writes 42 into R3 
sim_datapath_in=16'b0000000000101010; sim_write=1'b1; sim_vsel=1'b1; 
sim_writenum=3'b011;#10;

//writes 13 into R5 
sim_datapath_in=16'b000000000001101; sim_write=1'b1; sim_vsel=1'b1;
sim_writenum=3'b101;#10;

//reads R3 into a
sim_write=1'b0; sim_vsel=1'b0;
sim_writenum=3'b000; sim_readnum=3'b011;sim_loada=1'b1;#10;
//reads R5 into b
sim_loada=1'b0;sim_readnum=3'b101;sim_loadb=1'b1; #10;
//loads ALUout into C
sim_loadb=1'b0; sim_ALUop=2'b00; sim_asel=1'b0;sim_bsel=1'b0;sim_shift=2'b00;sim_loadc=1'b1;
#10;
checker(16'b0000000000110111,1'b0);
#10;
  //TEST 2 for subtracting  numbers
  //write 43 in R4
  sim_loadc=1'b0;
  sim_datapath_in=16'b0000000000101011;
  sim_write=1'b1;
  sim_vsel=1'b1;
  sim_writenum=3'b100;
  #10;

  //write 12 in R6
  sim_datapath_in=16'b000000000001100;
  sim_write=1'b1;sim_vsel=1'b1;
  sim_writenum=3'b110;
  #10;


  //read 43 in R4, load into RA
  sim_write=1'b0;
  sim_vsel=1'b0;
  sim_writenum=3'b000;
  sim_readnum=3'b100;
  sim_loada=1'b1;
  #10;

  //read 12 in R6, load into RB
  sim_loada=1'b0;
  sim_readnum=3'b110;
  sim_loadb=1'b1;
  #10;

  //ALU set to subtracting, load result to RC
  sim_loadb=1'b0;
  sim_ALUop=2'b01;
  sim_asel=1'b0;
  sim_bsel=1'b0;
  sim_shift=2'b0;
  sim_loadc=1'b1;
  #10;
  //check datapath_out and Z_out for 31
  checker(16'b0000000000011111, 1'b0);
  #10;




  //TEST 3 for ANDing numbers
  //write 41 in R0
  sim_datapath_in=16'b0000000000101001;
  sim_write=1'b1;
  sim_vsel=1'b1;
  sim_writenum=3'b000;
  #10;

  //write 14 in R1
  sim_datapath_in=16'b000000000001110;
  sim_write=1'b1;sim_vsel=1'b1;
  sim_writenum=3'b001;
  #10;

  //read 41 in R0, load into RA
  sim_write=1'b0;
  sim_vsel=1'b0;
  sim_writenum=3'b000;
  sim_readnum=3'b000;
  sim_loada=1'b1;
  #10;

  //read 14 in R1, load into RB
  sim_loada=1'b0;
  sim_readnum=3'b001;
  sim_loadb=1'b1;
  #10;

  //ALU set to ANDing, load result to RC
  sim_loadb=1'b0;
  sim_ALUop=2'b10;
  sim_asel=1'b0;
  sim_bsel=1'b0;
  sim_shift=2'b0;
  sim_loadc=1'b1;
  #10;
  //check datapath_out and Z_out for 29
  checker(16'b0000000000001000, 1'b0);
  #10;


if(~err) $display("PASSED");
else $display("FAILED");
$stop;
end
endmodule 
