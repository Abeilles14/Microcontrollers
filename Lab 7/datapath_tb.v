`define UNDEF1 1'bx
`define UNDEF3 3'bx
`define UNDEF16 16'bx
`define n_0 16'b0000
`define n_1 16'b0001
`define n_2 16'b0010  
`define n_3 16'b0011 
`define n_4 16'b0100 
`define n_5 16'b0101
`define n_6 16'b0110 
`define n_7 16'b0111 
`define n_8 16'b1000 
`define n_9 16'b1001 
`define n_10 16'b1010 
`define n_16 16'b0001_0000
`define n_34 16'b0010_0010
`define n_42 16'b0010_1010
`define n_127 16'b0000_0000_0111_1111
`define n_neg128 16'b1111_1111_1000_0000
`define n_neg253 16'b1111_1111_0000_0011
`define n_16BITMAX 16'b1111_1111_1111_1111
`define n_32515 16'b0111_1111_0000_0011
`define n_32644 16'b0111_1111_1000_0100
`define n_32767 16'b0111_1111_1111_1111
`define n_neg32516 16'b1000_0000_1111_1100
`define n_neg32766 16'b1000_0000_0000_0010
`define n_neg32768 16'b1000_0000_0000_0000
`define s_NOTHING 2'b00
`define s_SHIFTLEFT 2'b01
`define s_SHIFTRIGHT 2'b10
`define s_SHIFTRIGHTMSB 2'b11
`define o_PLUS 2'b00
`define o_MINUS 2'b01
`define o_AND 2'b10
`define o_NOT 2'b11

`define ON 1'b1
`define OFF 1'b0 
`define mdata_select 4'b1000
`define sximm_select 4'b0100
`define PC_select 4'b0010
`define datapath_out_select 4'b0001
`define X_vsel 4'bxxxx

`define X_16BIT 16'bx


module datapath_tb(); 
reg s_clk, s_loada, s_loadb, s_asel, s_bsel, s_loadc, s_loads, s_write;
reg [3:0] s_vsel;
reg [2:0] s_readnum, s_writenum;
reg [1:0] s_shift, s_ALUop;
reg [15:0] s_mdata,s_sximm8,s_sximm5;
reg [7:0] s_PC;
wire [2:0] s_Z_out;
wire [15:0] s_datapath_out;

reg err; 

datapath DUT(.clk(s_clk), .readnum(s_readnum), .vsel(s_vsel), .loada(s_loada), .loadb(s_loadb), .shift(s_shift), 
.asel(s_asel), .bsel(s_bsel), .ALUop(s_ALUop), .loadc(s_loadc), .loads(s_loads), 
.writenum(s_writenum), .write(s_write), .Z_out(s_Z_out), .datapath_out(s_datapath_out),
.mdata(s_mdata),.sximm8(s_sximm8),.sximm5(s_sximm5), .PC(s_PC));



task checker;
  input [2:0] expected_Z_out;
  input [15:0] expected_datapath_out;
begin
    if(datapath_tb.DUT.datapath_out !== expected_datapath_out) begin
      $display("ERROR: output is %d, expected %d", 
      datapath_tb.DUT.datapath_out, expected_datapath_out);
      err = 1'b1; 
    end
    if(datapath_tb.DUT.Z_out !== expected_Z_out) begin
      $display("ERROR: output is %b, expected %b", 
      datapath_tb.DUT.Z_out, expected_Z_out);
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
//Store nothing during the first edge cycle of clk
err = 1'b0;

s_sximm8 = `n_0; s_mdata = `n_0; s_sximm5 = `n_0; s_PC = `n_0;
s_vsel = `sximm_select;
s_readnum = `n_0; s_writenum = `n_0;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(`UNDEF3,`UNDEF16);

//Register 0 stores the value of 7, undefined outputs
s_sximm8 = `n_7; 
s_vsel = `sximm_select;
s_readnum = `n_0; s_writenum = `n_0;
s_write = `ON; s_loada = `OFF; s_loadb = `OFF; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(`UNDEF3,`UNDEF16);

//Register 1 stores the value of 3, Register B loads 7 from Register 0, undefined outputs
s_sximm8 = `n_3; 
s_vsel = `sximm_select;
s_readnum = `n_0; s_writenum = `n_1;
s_write = `ON; s_loada = `OFF; s_loadb = `ON; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(`UNDEF3,`UNDEF16);

//Register 2 stores the value of -128, Register A loads 3 from Register 1, undefined outputs
s_sximm8 = `n_neg128; 
s_vsel = `sximm_select;
s_readnum = `n_1; s_writenum = `n_2;
s_write = `ON; s_loada = `ON; s_loadb = `OFF; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(`UNDEF3,`UNDEF16);

//Register 3 stores the value of 127
//Register C outputs 3 - (7/2) = 0, Z_out should be 3'b100;
s_sximm8 = `n_127; 
s_vsel = `sximm_select;
s_readnum = `n_1; s_writenum = `n_3;
s_write = `ON; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHTMSB; s_ALUop = `o_MINUS;
#10;
checker(3'b100,`n_0);

//Register 4 stores the value of 32767 (hypothetically), Register B loads -128 from Register 2
//Register C outputs 0, Z_out should be 3'b100;
s_sximm8 = `n_32767; 
s_vsel = `sximm_select;
s_readnum = `n_2; s_writenum = `n_4;
s_write = `ON; s_loada = `OFF; s_loadb = `ON; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHTMSB; s_ALUop = `o_MINUS;
#10;
checker(3'b100,`n_0);

//Register C outputs 3 + (-128 * 2) = -253, Z_out should be 3'b001; (ZVN)
s_sximm8 = `n_32767; 
s_vsel = `sximm_select;
s_readnum = `n_2; s_writenum = `n_4;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTLEFT; s_ALUop = `o_PLUS;
#10;
checker(3'b001,`n_neg253);

//Register 5 stores the output from C (-253), Register B loads 32767 from Register 4
//Register C outputs -253, Z_out should be 3'b001; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_5;
s_write = `ON; s_loada = `OFF; s_loadb = `ON; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTLEFT; s_ALUop = `o_PLUS;
#10;
checker(3'b001,`n_neg253);

//Register 5 stores the output from C (-253), Register B loads 32767 from Register 4
//Register C outputs -253, Z_out should be 3'b001; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_5;
s_write = `ON; s_loada = `OFF; s_loadb = `ON; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTLEFT; s_ALUop = `o_PLUS;
#10;
checker(3'b001,`n_neg253);

//Register C outputs NOT(32767) = -32768, Z_out should be 3'b001; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_NOT;
#10;
checker(3'b001,`n_neg32768);

//Register 6 stores output from Register C (-32768)
//Register C outputs AND(3, 32767) = 3, Z_out should be 3'b000; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_6;
s_write = `ON; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_AND;
#10;
checker(3'b000,`n_3);

//Register C outputs 3 + 32767 = -32766 (overflow!), Z_out should be 3'b011; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(3'b011,`n_neg32766);

//Register B loads -253 from Register 5
//Register C outputs 3, Z_out should be 3'b011; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_5; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `ON; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(3'b011,`n_neg32766);

//Register C outputs 3 + 32641{-253 shifted right} = 32644, Z_out should be 3'b000; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_5; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHT; s_ALUop = `o_PLUS;
#10;
checker(3'b000,`n_32644);

//Register A loads -32768 from Register 6
//Register C outputs = 32644, Z_out should be 3'b000; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_6; s_writenum = `n_5;
s_write = `OFF; s_loada = `ON; s_loadb = `OFF; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHT; s_ALUop = `o_PLUS;
#10;
checker(3'b000,`n_32644);


//Register C outputs -32768 + (-253) = 32515(overflow!), Z_out should be 3'b010; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_5; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_PLUS;
#10;
checker(3'b010,`n_32515);

//Register C outputs -32768 - 32641{-253 shifted right} = 127(overflow!), Z_out should be 3'b010; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_5; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHT; s_ALUop = `o_MINUS;
#10;
checker(3'b010,`n_127);

//Register A loads 32767 from Register 4
//Register C outputs -32768 - 32641{-253 shifted right} = 127(overflow!), Z_out should be 3'b010; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_4; s_writenum = `n_5;
s_write = `OFF; s_loada = `ON; s_loadb = `OFF; s_loadc = `OFF; s_loads = `OFF; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_SHIFTRIGHT; s_ALUop = `o_PLUS;
#10;
checker(3'b010,`n_127);

//Register C outputs 32767 - (-253) = -32516(overflow!), Z_out should be 3'b011; (ZVN)
s_sximm8 = `n_127; 
s_vsel = `datapath_out_select;
s_readnum = `n_5; s_writenum = `n_5;
s_write = `OFF; s_loada = `OFF; s_loadb = `OFF; s_loadc = `ON; s_loads = `ON; s_asel = `OFF; s_bsel = `OFF;  
s_shift = `s_NOTHING; s_ALUop = `o_MINUS;
#10;
checker(3'b011,`n_neg32516);

//all 4 overflow cases checked!!

    if(~err) begin
    $display("PASSED");
    end else begin
    $display("FAILED");
    end

    $stop;
  end
endmodule
