`define MREAD 2'b01
`define MWRITE 2'b10

module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
    input CLOCK_50;
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire[1:0] mem_cmd;
    wire[8:0] mem_addr;
    wire[15:0] read_data, write_data, dout;
    wire write, msel, shouldWrite, shouldRead, e, g,f,break;
    parameter fileName = "lab8fig4.txt";

    //assigns write to 1 if mem_cmd is WRITE and if msel is 0
    assign shouldWrite = (mem_cmd == `MWRITE) ? 1 : 0;
    assign msel = (mem_addr[8] == 1'b0) ? 1 : 0;
    assign write = shouldWrite && msel;

    //assigns the tri-state inverter input by ANDing
    //msel==0 with mem_cmd == READ    
    assign shouldRead = (mem_cmd == `MREAD) ? 1 : 0;
    assign e = msel & shouldRead;
    assign read_data = e ? dout : (f ? {8'b0,SW[7:0]} : 16'bz);

    //Logic circuit that determines if we are reading from the switches
    assign f = ((mem_cmd == `MREAD) & (mem_addr == 9'b101000000)) ? 1 : 0;  

    //Logic circuit that determines if we are outputting to the LEDs  
    assign g = ((mem_cmd == `MWRITE) & (mem_addr == 9'b100000000)) ? 1 : 0;

    //Instantiates a loadEnable for the LED register
    loadEnableTop #(8) LEDREGISTER(.in(write_data[7:0]), .load(g), .clk(CLOCK_50), .out(LEDR[7:0]));


    //Instantiates a Read-Write Memory RAM, copied from Slide Set 7 
RAM #(16,8, fileName) MEM(.clk(CLOCK_50),
            .read_address(mem_addr[7:0]),
            .write_address(mem_addr[7:0]),
            .write(write),
            .din(write_data),
            .dout(dout));

    //Instantiates a CPU, copied from Lab 6
 cpu CPU( 
         .clk   (CLOCK_50), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset (~KEY[1]), 
         .out   (write_data),
         .Z     (Z),
         .N     (N),
         .V     (V),
         .mem_cmd(mem_cmd),
         .mem_addr(mem_addr),
         .read_data(read_data),
         .mdata(read_data),.break(break) );

  //Outputs for the status
  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  //Output is changed to write_data
  sseg H0(write_data[3:0],   HEX0);
  sseg H1(write_data[7:4],   HEX1);
  sseg H2(write_data[11:8],  HEX2);
  sseg H3(write_data[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = break; //sets LEDR[8] to the break value
endmodule

//Read-Write memory copied from Slide Set 7
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule


module loadEnableTop(in,load,clk,out); //Create a loadEnable, referenced from slide set 6
 parameter n = 16;
 input [n-1:0] in;
 input load,clk;
 output[n-1:0] out;
 wire [n-1:0] middle;


//Instantiate a VDFF module instance
 vDFF #(n) value(clk,middle,out); 
 //2 input binary select multiplexer to determine the input into vDFF based on the status of 'load'
 assign middle = load ? in : out; 

endmodule

//Flip flop referenced from slide set 5
module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

//Assign the seven segment display outputs
module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
  
  reg [6:0] segs;
  always@(in) begin
    case (in)
    4'b0000: segs = 7'b1000000;
    4'b0001: segs = 7'b1111001;
    4'b0010: segs = 7'b0100100;
    4'b0011: segs = 7'b0110000;
    4'b0100: segs = 7'b0011001;
    4'b0101: segs = 7'b0010010;
    4'b0110: segs = 7'b0000010;
    4'b0111: segs = 7'b1111000;
    4'b1000: segs = 7'b0000000;
    4'b1001: segs = 7'b0010000;
    4'b1010: segs = 7'b0001000;
    4'b1011: segs = 7'b0000011;
    4'b1100: segs = 7'b1000110;
    4'b1101: segs = 7'b0100001;
    4'b1110: segs = 7'b0000110;
    4'b1111: segs = 7'b0001110;
    default segs = 7'b0000000;
    endcase
  end

  endmodule
