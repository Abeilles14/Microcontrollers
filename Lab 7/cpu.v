`define Rn_select 3'b001
`define Rd_select 3'b010
`define Rm_select 3'b100 
`define X_nsel 3'bxxx

`define mdata_select 4'b1000
`define sximm_select 4'b0100
`define PC_select 4'b0010
`define datapath_out_select 4'b0001
`define X_vsel 4'bxxxx

`define M_NONE 2'b00
`define M_READ 2'b01
`define M_WRITE 2'b10


`define MOV_Rn_Imm8 5'b11010
`define MOV_Rd_RmShift 5'b11000
`define ADD_Rd_Rn_RmShift 5'b10100
`define CMP_Rn_RmShift 5'b10101
`define AND_Rd_Rn_RmShift 5'b10110
`define MVN_Rd_RmShift 5'b10111
`define ALL_INSTRUCTIONS 5'bxxxxx

`define STATE_WIDTH 4
`define STATE_RESET 3'b0000
`define STATE_DECODE 3'b0001
`define STATE_GET_A 3'b0010
`define STATE_GET_B 3'b0011 
`define STATE_OPS 3'b0100 
`define STATE_WRITE_REG 3'b0101
`define STATE_IF1 3'b0110 
`define STATE_IF2 3'b0111
`define STATE_UPDATEPC 3'b1000 


`define ON 1'b1
`define OFF 1'b0
`define X_s 1'bx

`define OPCODE_MOVE 3'b110
`define OPCODE_ALU 3'b101
`define X_OPCODE 3'bx
`define OP_MOVE_IM8 2'b10
`define OP_MOVE_RDRM 2'b00
`define X_OP 2'bx

module cpu(clk,reset,in,out,N,V,Z,mem_addr,mem_cmd);
    input clk, reset;
    input [15:0] in;
    output [15:0] out;
    output [8:0] mem_addr;
    output N, V, Z;
    output [1:0] mem_cmd;
    wire [15:0] decoder_in;
    wire [2:0] opcode, Rn,Rd,Rm,nsel,readnum,writenum;
    wire[1:0] op, shift, ALUop;
    wire [15:0] sximm5, sximm8;

    wire [3:0] vsel;
    wire loada, loadb, loadc, loads, write, asel, bsel,addr_sel,load_addr,load_pc,reset_pc,load_ir;
    wire [8:0] next_pc,pc_out,da_out; 
    wire [7:0] PC = 0;

    //instantiates a load-enabled register for storing instruction input
    loadEnableCPU #(16) INSTRUCTION_REGISTER(.in(in), .load(load_ir), .clk(clk), .out(decoder_in));

    //instantiates an 'instruction decoder' -> "decodes" instructions to be sent to state machine or datapath
    instructionDecoder INSTRUCTION_DECODER(.decoder_in(decoder_in), .nsel(nsel), .opcode(opcode), .op(op), .readnum(readnum), .writenum(writenum), .shift(shift), .sximm8(sximm8), .sximm5(sximm5), .ALUop(ALUop));
    
    //instantiates a datapath module which executes instructions
    datapath DP(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), 
    .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .Z_out({Z,V,N}), .datapath_out(out), .mdata(in), .sximm8(sximm8), .sximm5(sximm5), .PC(PC));
    
    //instantiates a finite state machine for various states (reset, decode, etc...)
    fsm_Controller FSM_CONTROLLER( .reset(reset), .clk(clk), .opcode(opcode), .op(op), .vsel(vsel), .nsel(nsel), .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads),.load_ir(load_ir),.load_addr(load_addr),
 .load_pc(load_pc),.reset_pc(reset_pc),.addr_sel(addr_sel), .write(write), .asel(asel), .bsel(bsel),.mem_cmd(mem_cmd));
    
    loadEnableCPU #(9) Program_Counter (.in(next_pc),.load(load_pc),.clk(clk),.out(pc_out));
    loadEnableCPU #(9) Data_Address (.in(out),.load(load_addr),.clk(clk),.out(da_out));

    assign next_pc=reset? 9'b0: pc_out+1;
    assign mem_addr=addr_sel?pc_out:da_out;
    
endmodule

module fsm_Controller (reset, clk, opcode, op, vsel, nsel, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, write, asel, bsel, mem_cmd);

    input reset, clk;
    input [2:0] opcode;
    input [1:0] op;
    output [1:0] mem_cmd;
    output loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, write;
    output [3:0] vsel;
    output [2:0] nsel;
    output asel, bsel;
    reg loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, write;
    reg [3:0] vsel;
    reg [2:0] nsel;
    reg asel, bsel; 
    reg [1:0] mem_cmd;
    wire [`STATE_WIDTH - 1: 0] present_state, next_state_reset;
    reg [`STATE_WIDTH - 1: 0] next_state;
    
  
    //determines whether we reset back to 'wait' or not
    assign next_state_reset = reset ? `STATE_RESET : next_state;

    //instantiates a flip flop which updates the present_state on rising edge of clk
    vDFFCPU #(`STATE_WIDTH) STATE(.in(next_state_reset), .clk(clk), .out(present_state));

    //determine next_state and outputs to datapath/instruction_decoder based on both current state and current inputs (Mealy Machine)
    always@(*) begin
        casex({present_state, opcode, op})
            //In the waiting state - unless s is asserted we remain in 'wait'
         /*   {`STATE_WAIT, `OFF, `ALL_INSTRUCTIONS}: begin
            {next_state, w, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_WAIT, `ON, `OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end
*/

            //s is asserted -> on next clock cycle go to stage 'decode'
            {`STATE_RESET, `ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_IF1, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `ON, `ON,`OFF, `M_NONE, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            {`STATE_IF1, `ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_IF2, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `ON, `M_READ, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            {`STATE_IF2, `ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_UPDATEPC, `OFF, `OFF, `OFF, `OFF, `ON, `OFF, `OFF, `OFF, `ON, `M_READ, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            {`STATE_UPDATEPC, `ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_DECODE, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `ON, `OFF,`OFF, `M_NONE, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end


            //If input instruction is MOV Rn, #<imm8>, go immediately to state 'writeReg'
            {`STATE_DECODE, `MOV_Rn_Imm8}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_WRITE_REG, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF,`OFF, `M_NONE, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            //If input instruction is ADD, CMP, or AND, go to state 'getA'
            {`STATE_DECODE, `ADD_Rd_Rn_RmShift}, {`STATE_DECODE, `CMP_Rn_RmShift}, {`STATE_DECODE,`AND_Rd_Rn_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_GET_A, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF,`OFF, `M_NONE, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            //If input instruction is MOV Rd, Rm<, sh_op>, or MVN , go to state 'getB'
            {`STATE_DECODE,`MOV_Rd_RmShift}, {`STATE_DECODE,  `MVN_Rd_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 
            {`STATE_GET_B, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF, `OFF,`OFF, `M_NONE, `OFF, `X_vsel, `X_nsel, `X_s, `X_s};
            end

            //For all instructions using state 'getA' go to state 'getB,' and load value into Register A
            {`STATE_GET_A, `ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_GET_B, `ON, `OFF, `OFF, `OFF, `OFF, `X_vsel, `Rn_select, `X_s, `X_s};
            end

            //For all instructions using state 'getB' go to state 'operations,' and load value into Register B
            {`STATE_GET_B,`ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_OPS, `OFF, `ON, `OFF, `OFF, `OFF, `X_vsel, `Rm_select, `X_s, `X_s};
            end

            //For instruction CMP, turn on loads so the status outputs are displayed on the next clk cycle
            {`STATE_OPS, `CMP_Rn_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_RESET,  `OFF, `OFF, `OFF, `ON, `OFF, `X_vsel, `X_nsel, `OFF, `OFF};
            end

            //For instructions ADD and AND, turn on loadc so the ALU output is displayed on the next clk cycle
            {`STATE_OPS, `ADD_Rd_Rn_RmShift}, {`STATE_OPS, `AND_Rd_Rn_RmShift}: begin
            {next_state,  loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_WRITE_REG, `OFF, `OFF, `ON, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF};
            end

            //For instructions MOV Rd, Rm<, sh_op> and MVN, turn on asel so the ALU only does computations with Register B
            {`STATE_OPS, `MOV_Rd_RmShift}, {`STATE_OPS, `MVN_Rd_RmShift}: begin
            {next_state,loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_WRITE_REG, `OFF, `OFF, `ON, `OFF, `OFF, `X_vsel, `X_nsel, `ON, `OFF};
            end

            //For the MOV Rn, <#imm8>, turn on sximm_select so the immediate number is written into regFile
            {`STATE_WRITE_REG, `MOV_Rn_Imm8}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_RESET, `OFF, `OFF, `OFF, `OFF, `ON, `sximm_select, `Rn_select, `X_s, `X_s};
            end

            //For all instructions except MOV_Rn_Imm8 (as well as CMP_Rn_RmShift), turn on datapath_out_select so output C is written into regFile
            {`STATE_WRITE_REG,`ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel} = 
            {`STATE_RESET, `OFF, `OFF, `OFF, `OFF, `ON, `datapath_out_select, `Rd_select, `X_s, `X_s};
            end

            //for debugging
            default: begin
            {next_state, loada, loadb, loadc, loads, load_ir, load_addr, load_pc, reset_pc, addr_sel, mem_cmd, write, vsel, nsel, asel, bsel} = 21'bx;
            end
         
        endcase
    end

    
endmodule
 

module instructionDecoder(decoder_in,nsel,opcode,op,readnum,writenum,shift,sximm8,sximm5,ALUop);
    input [15:0] decoder_in;
    input [2:0] nsel;
    output [2:0] opcode,readnum,writenum;
    output [1:0] op,shift,ALUop;
    output [15:0] sximm5, sximm8;
    wire [2:0] Rn, Rd, Rm;
    wire[7:0] imm8;
    wire[4:0] imm5;

    //instantiates a 3-input multiplexer which selects what registers to read from/write to at different states
    Mux3_Hot #(3) REGISTER_SELECT(.a2(Rm), .a1(Rd), .a0(Rn), .s(nsel),.out(readnum));

    //assigns outputs (inputs to the datapath/fsm) based on certain bits of the input instruction
    assign opcode = decoder_in[15:13];
    assign op = decoder_in[12:11];
    assign Rn = decoder_in[10:8];
    assign Rd = decoder_in[7:5];
    assign Rm = decoder_in[2:0];
    assign writenum = readnum;
    assign shift = decoder_in[4:3];
    assign imm8 = decoder_in[7:0];
    assign imm5 = decoder_in[4:0];
    assign sximm8 = {{8{imm8[7]}},imm8};
    assign sximm5 = {{11{imm5[4]}},imm5};
    assign ALUop = decoder_in[12:11];

endmodule




module loadEnableCPU(in,load,clk,out); //Create a loadEnable, referenced from slide set 6
 parameter n = 16;
 input [n-1:0] in;
 input load,clk;
 output[n-1:0] out;
 wire [n-1:0] middle;


//Instantiate a VDFFCPU module instance
 vDFFCPU #(n) value(clk,middle,out); 
 //2 input binary select multiplexer to determine the input into vDFFCPU based on the status of 'load'
 assign middle = load ? in : out; 

endmodule

module vDFFCPU(clk,in,out); //Flip Flop, referenced from slide set 5
 parameter n; //width
 input clk;
 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;
 //Assigns out on the positive edge of clk
 always@(posedge clk)
  out = in;
endmodule

module Mux3_Hot(a2,a1,a0,s,out); //Multiplexer with 3 input and a one hot code as s, referenced from slide set 6
 parameter k = 16;
 input [k-1:0] a2,a1,a0;
 input [2:0] s;
 output [k-1:0] out;

 //Assigns out to be the the input selected by the one-hot code 
 assign out =({k{s[0]}} & a0) |
	   ({k{s[1]}} & a1) |
	   ({k{s[2]}} & a2) ;
endmodule


