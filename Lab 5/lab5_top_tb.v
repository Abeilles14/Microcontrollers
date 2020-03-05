module lab5_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg CLOCK_50;
  reg [2:0] debug;

  lab5_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

  initial forever begin
    CLOCK_50 = 0; #5;
    CLOCK_50 = 1; #5;
  end

  initial begin
    $stop;
  end
endmodule
