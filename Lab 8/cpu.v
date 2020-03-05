`define Rn_select 3'b001
`define Rd_select 3'b010
`define Rm_select 3'b100 
`define X_nsel 3'bxxx

`define B 3'b000
`define BEQ 3'b001
`define BNE 3'b010
`define BLT 3'b011
`define BLE 3'b100

`define PC_RESET 3'b001
`define PC_PLUS1 3'b010
`define PC_BRANCH 3'b100 

`define BRANCH 5'B00100
`define BL 5'b01011
`define BX 5'b01000
`define BLX 5'b01010

`define mdata_select 4'b1000
`define sximm_select 4'b0100
`define PC_select 4'b0010
`define datapath_out_select 4'b0001
`define X_vsel 4'bxxxx

`define MOV_Rn_Imm8 5'b11010
`define MOV_Rd_RmShift 5'b11000
`define ADD_Rd_Rn_RmShift 5'b10100
`define CMP_Rn_RmShift 5'b10101
`define AND_Rd_Rn_RmShift 5'b10110
`define MVN_Rd_RmShift 5'b10111
`define LDR_RD_RNIM5 5'b01100 
`define STR_RD_RNIM5 5'b10000 
`define ALL_INSTRUCTIONS 5'bxxxxx

`define STATE_WIDTH 4
`define STATE_RESET 4'b0000
`define STATE_IF1 4'b0001
`define STATE_IF2 4'b0010
`define STATE_UPDATEPC 4'b0011
`define STATE_DECODE 4'b0100
`define STATE_GET_A 4'b0101
`define STATE_GET_B 4'b0110 
`define STATE_OPS 4'b0111
`define STATE_GET_ADDR 4'b1000
`define STATE_GETBSTR 4'b1001 
`define STATE_GETOPSTR 4'b1010 
`define STATE_RW 4'b1011 
`define STATE_WRITE_REG 4'b1100
`define STATE_HALT 4'b1101
`define STATE_BRANCH2 4'b1110
`define STATE_BRANCH 4'b1111

`define ON 1'b1
`define OFF 1'b0
`define X_s 1'bx

`define OPCODE_MOVE 3'b110
`define OPCODE_ALU 3'b101
`define OPCODE_HALT 3'b111
`define OPCODE_BL 3'b010
`define X_OPCODE 3'bxxx
`define X_COND 3'bxxx
`define OP_MOVE_IM8 2'b10
`define OP_MOVE_RDRM 2'b00
`define X_OP 2'bx

`define MREAD 2'b01
`define MWRITE 2'b10
`define X_M_CMD 2'bxx

module cpu(clk,reset,out,N,V,Z,mem_cmd, mem_addr, read_data, mdata,break);
    input clk, reset; 
    input [15:0] mdata, read_data;    
    output [8:0] mem_addr;
    output [15:0] out;
    output N, V, Z,break;
    output [1:0] mem_cmd;
    wire[1:0] op, shift, ALUop;
    wire [2:0] opcode, cond, Rn,Rd,Rm,nsel,readnum,writenum,reset_pc;
    wire [15:0] decoder_in, sximm5, sximm8,data_out;
       

    //Outputs from the state machine
    wire [3:0] vsel;
    wire loada, loadb, loadc, loads, write, asel, bsel, load_ir, load_pc, addr_sel, load_addr;
    wire [8:0] next_pc, PC,branchout, data_address_out;

    //instantiates a load-enabled register for storing instruction input
    loadEnableCPU #(16) INSTRUCTION_REGISTER(.in(read_data), .load(load_ir), .clk(clk), .out(decoder_in));

    //instantiates an 'instruction decoder' -> "decodes" instructions to be sent to state machine or datapath
    instructionDecoder INSTRUCTION_DECODER(.decoder_in(decoder_in), .nsel(nsel), .opcode(opcode), .op(op), .cond(cond), .readnum(readnum), .writenum(writenum), .shift(shift), .sximm8(sximm8), .sximm5(sximm5), .ALUop(ALUop));
    
    //instantiates a datapath module which executes instructions
    datapath DP(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), 
    .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .Z_out({Z,V,N}), .datapath_out(out), .mdata(mdata), .sximm8(sximm8), .sximm5(sximm5), .PC(PC[7:0]),.data_out(data_out));
    
    //instantiates a finite state machine for various states (wait, decode, etc...)
    fsm_Controller FSM(.break(break),.reset(reset), .clk(clk), .opcode(opcode), .op(op), .cond(cond), .vsel(vsel), .nsel(nsel), .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads), .write(write), .asel(asel), .bsel(bsel),
    .load_pc(load_pc), .reset_pc(reset_pc),.addr_sel(addr_sel), .mem_cmd(mem_cmd), .load_ir(load_ir),.load_addr(load_addr));

    //instantiates a load-enabled register for our program counter
    loadEnableCPU #(9) PC_COUNTER_REGISTER(.in(next_pc), .load(load_pc), .clk(clk), .out(PC));


    //instantitates a load-enabled register for our data address
    loadEnableCPU #(9) DATA_ADDRESS(.in(out[8:0]), .load(load_addr), .clk(clk), .out(data_address_out));
    
    //instantiates an alu that inputs into the pc mux
    branchalu b (.cond(cond),.opcode(opcode), .op(op),.PC(PC),.N(N),.V(V),.Z(Z),.sximm8(sximm8[8:0]),.branchout(branchout),.data_out(data_out[8:0]));

    //instantitates a one-hot 3 input multiplexer into the pc reg 
    Mux3_Hot #(9) pcmux(.a2(branchout),.a1(PC+1'b1),.a0(9'b0),.s(reset_pc),.out(next_pc));

    //Assign mem_addr to PC or data_address_out
    assign mem_addr = addr_sel ? PC : data_address_out;
endmodule

module fsm_Controller(break,reset, clk, opcode, op, cond, vsel, nsel, loada, loadb, loadc, loads, write, asel, bsel,
                        load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr);
    input  reset, clk;
    input [2:0] opcode, cond;
    input [1:0] op;
    output break,loada, loadb, loadc, loads, write, asel, bsel, load_pc,  addr_sel, load_ir, load_addr;
    output [3:0] vsel;
    output [2:0] nsel,reset_pc;
    output [1:0] mem_cmd;
    reg loada, loadb, loadc, loads, write, load_pc, addr_sel, load_ir, load_addr;
    reg [3:0] vsel;
    reg [2:0] nsel,reset_pc;
    reg break,asel, bsel; 
    reg [1:0] mem_cmd;
    wire [`STATE_WIDTH - 1: 0] present_state, next_state_reset;
    reg [`STATE_WIDTH - 1: 0] next_state;
    
    //determines whether we reset back to STATE_RESET or not
    assign next_state_reset = reset ? `STATE_RESET : next_state;

    //instantiates a flip flop which updates the present_state on rising edge of clk
    vDFFCPU #(`STATE_WIDTH) STATE(.in(next_state_reset), .clk(clk), .out(present_state));

    //determine next_state and outputs to datapath/instruction_decoder based on both current state and current inputs (Mealy Machine)
    always@(*) begin
        casex({present_state, opcode, op})

            //If in STATE_RESET, next state is STATE_IF1
            {`STATE_RESET, `X_OPCODE, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF1, `OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `ON, `PC_RESET, `OFF, `X_M_CMD, `OFF, `OFF,`OFF};
            end
            
            //If in STATE_IF1, next state is STATE_IF2
            {`STATE_IF1, `X_OPCODE, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF2, `OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `ON, `MREAD, `OFF, `OFF,`OFF};
            end

            //If in STATE_IF2, next state is STATE_UPDATEPC
            {`STATE_IF2, `X_OPCODE, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_UPDATEPC, `OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `ON, `MREAD, `ON, `OFF,`OFF};
            end




 //If in STATE_UPDATEPC, and doing the branch instruction, set pc to the output of branchalu
            {`STATE_UPDATEPC, `BRANCH}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end

//If in STATE_UPDATEPC, and doing BL or BLX instruction, add 1 to pc then go to Branch
            {`STATE_UPDATEPC, `BL},{`STATE_UPDATEPC, `BLX}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_BRANCH,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `ON, `PC_PLUS1, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end
//If in STATE_BRANCH and doing the BL instruction, place value of PC into Rn and set PC to the output of branchalu  
            {`STATE_BRANCH, `BL}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `ON, `PC_select, `Rn_select, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end

 //If in STATE_UPDATEPC, and doing the BX instruction, load pc with value from branchalu 
            {`STATE_UPDATEPC, `BX}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `Rd_select, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end

 //If in STATE_BRANCH, and doing blx instruction, put pc into Rn
            {`STATE_BRANCH, `BLX}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_BRANCH2,`OFF, `OFF, `OFF, `OFF, `ON, `PC_select, `Rn_select, `X_s, `X_s, `OFF, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end

 //If in STATE_BRANCH2, and doing BLX instruction, put value of Rd into branchalu then set pc to output of branchalu
            {`STATE_BRANCH2, `BLX}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `Rd_select, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end






            //If in STATE_UPDATEPC, next state is STATE_DECODE
            {`STATE_UPDATEPC, `X_OPCODE, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir, load_addr,break} = 
            {`STATE_DECODE,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD,`OFF,`OFF,`OFF};
            end

            //If in STATE_DECODE, and input is OPCODE_HALT, go to STATE_HALT
            {`STATE_DECODE, `OPCODE_HALT, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_HALT,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF,`PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //remain in STATE_HALT until reset is asserted
            {`STATE_HALT, `X_OPCODE, `X_OP}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_HALT,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`ON};
            end
           
/*	    //remain in STATE_HALT until reset is asserted
            {`STATE_DECODE, `BRANCH}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `ON, `PC_BRANCH, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end
*/
            //If in STATE_DECODE and input instruction is MOV Rn, #<imm8>, go immediately to STATE_WRITE_REG
            {`STATE_DECODE, `MOV_Rn_Imm8}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_WRITE_REG,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_DECODE and  input instruction is ADD, CMP, AND, LDR, or STR go to STATE_GET_A
            {`STATE_DECODE,`ADD_Rd_Rn_RmShift}, {`STATE_DECODE,`CMP_Rn_RmShift}, {`STATE_DECODE,`AND_Rd_Rn_RmShift}, {`STATE_DECODE,`LDR_RD_RNIM5}, {`STATE_DECODE,`STR_RD_RNIM5}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GET_A,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_DECODE and input instruction is MOV Rd, Rm<, sh_op>, or MVN , go to STATE_GET_B
            {`STATE_DECODE,`MOV_Rd_RmShift}, {`STATE_DECODE, `MVN_Rd_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GET_B, `OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_GET_A, for all instructions except LDR and STR, if in STATE_GET_A, go to STATE_GET_B and load value into Register A
            {`STATE_GET_A,`MOV_Rd_RmShift}, {`STATE_GET_A,`MOV_Rn_Imm8}, {`STATE_GET_A,`ADD_Rd_Rn_RmShift}, {`STATE_GET_A,`CMP_Rn_RmShift}, {`STATE_GET_A, `AND_Rd_Rn_RmShift}, {`STATE_GET_A,`MVN_Rd_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GET_B,`ON, `OFF, `OFF, `OFF, `OFF, `X_vsel, `Rn_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_GET_A and input instructions is LDR or STR, go to STATE_OPS
            {`STATE_GET_A,`LDR_RD_RNIM5}, {`STATE_GET_A,`STR_RD_RNIM5}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_OPS,`ON, `OFF, `OFF, `OFF, `OFF, `X_vsel, `Rn_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_GET_B for all instructions go to STATE_OPS and load value into Register B
            {`STATE_GET_B,`ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_OPS, `OFF, `ON, `OFF, `OFF, `OFF, `X_vsel, `Rm_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_OPS and input instructions is CMP, turn on loads so the status outputs are displayed on the next clk cycle and go back to STATE_IF1
            {`STATE_OPS,`CMP_Rn_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `ON, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_OPS and input instructions are ADD or AND, turn on loadc so the ALU output is displayed on the next clk cycle and go to STATE_WRITE_REG
            {`STATE_OPS,`ADD_Rd_Rn_RmShift}, {`STATE_OPS,`AND_Rd_Rn_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_WRITE_REG,`OFF, `OFF, `ON, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_OPS and input instructions are MOV Rd, Rm<, sh_op> or MVN, turn on asel so the ALU only does computations with Register B and go to STATE_WRITE_REG
            {`STATE_OPS,`MOV_Rd_RmShift}, {`STATE_OPS,`MVN_Rd_RmShift}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_WRITE_REG,`OFF, `OFF, `ON, `OFF, `OFF, `X_vsel, `X_nsel, `ON, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_OPS and input instructions are LDR or STR, go to STATE_GET_ADDR
            {`STATE_OPS,`LDR_RD_RNIM5}, {`STATE_OPS,`STR_RD_RNIM5}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GET_ADDR,`OFF, `OFF, `ON, `ON, `OFF, `X_vsel, `X_nsel, `OFF, `ON, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_GET_ADDR and input instructions are LDR, go to STATE_RW
            {`STATE_GET_ADDR, `LDR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_RW,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`ON,`OFF};
            end

            //If in STATE_GET_ADDR and input instructions are STR, go to STATE_GETBSTR
            {`STATE_GET_ADDR, `STR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GETBSTR,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `PC_PLUS1, `OFF, `OFF, `X_M_CMD, `OFF,`ON,`OFF};
            end

            //If in STATE_GETBSTR and input instructions are STR, go to STATE_GETOPSTR
            {`STATE_GETBSTR, `STR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_GETOPSTR,`OFF, `ON, `OFF, `OFF, `OFF, `X_vsel, `Rd_select, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_GETOPSTR and input instructions are STR, go to STATE_RW
            {`STATE_GETOPSTR, `STR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_RW,`OFF, `OFF, `ON, `OFF, `OFF, `X_vsel, `X_nsel, `ON, `OFF, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_RW and input instructions are LDR, go to STATE_WRITE_REG
            {`STATE_RW, `LDR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_WRITE_REG,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `MREAD, `OFF,`OFF,`OFF};
            end

            //If in STATE_RW and input instructions are STR, go to STATE_IF1
            {`STATE_RW, `STR_RD_RNIM5}:begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1,`OFF, `OFF, `OFF, `OFF, `OFF, `X_vsel, `X_nsel, `OFF, `OFF, `OFF, `PC_PLUS1, `OFF, `MWRITE, `OFF,`OFF,`OFF};
            end

            //If in STATE_WRITE_REG and input instructions are MOV Rn, <#imm8>, turn on sximm_select so the immediate number is written into regFile and go back to STATE_IF1
            {`STATE_WRITE_REG,`MOV_Rn_Imm8}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1, `OFF, `OFF, `OFF, `OFF, `ON, `sximm_select, `Rn_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //If in STATE_WRITE_REG and input instructions are MOV Rn, <#imm8>, turn on sximm_select so the immediate number is written into regFile and go to STATE_IF1
            {`STATE_WRITE_REG,`LDR_RD_RNIM5}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1, `OFF, `OFF, `OFF, `OFF, `ON, `mdata_select, `Rd_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `MREAD, `OFF,`OFF,`OFF};
            end

            //If in STATE_WRITE_REG, for all the instructions except MOV_Rn_Imm8 and LDR (as well as CMP_Rn_RmShift), turn on datapath_out_select so output C is written into regFile and go to STATE_IF1
            {`STATE_WRITE_REG,`ALL_INSTRUCTIONS}: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 
            {`STATE_IF1, `OFF, `OFF, `OFF, `OFF, `ON, `datapath_out_select, `Rd_select, `X_s, `X_s, `OFF, `PC_PLUS1, `OFF, `X_M_CMD, `OFF,`OFF,`OFF};
            end

            //for debugging
            default: begin
            {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, reset_pc, addr_sel, mem_cmd, load_ir,load_addr,break} = 28'bx;
            end
         
        endcase
    end

    
endmodule
 
module branchalu (cond,opcode, op,PC,N,V,Z,sximm8,branchout,data_out); //sets up an alu to do the branch operations then inputs it into the pc mux
input [2:0] cond,opcode;
input[1:0] op;
input [8:0] PC,sximm8,data_out;
input N,V,Z;
output reg [8:0] branchout;
wire NeqV;

assign NeqV=(V^N);
always @* begin
    casex({opcode, op,cond,NeqV,Z})
   
    {`BRANCH,`B,1'bx,1'bx}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`BEQ,1'bx,1'b1}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`BNE,1'bx,1'b0}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`BLT,1'b1,1'bx}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`BLE,1'b1,1'bx}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`BLE,1'bx,1'b1}: branchout=PC+1'b1+sximm8;
    {`BRANCH,`B,1'bx,1'bx}: branchout=PC+1'b1+sximm8;
    
    {`BL,3'bx,1'bx,1'bx}: branchout=PC+sximm8;
    {`BX,3'bx,1'bx,1'bx}: branchout=data_out;
    {`BLX,3'bx,1'bx,1'bx}: branchout=data_out;

default: branchout=PC+1'b1; 

   endcase
end
endmodule

module instructionDecoder(decoder_in,nsel,opcode,op,cond,readnum,writenum,shift,sximm8,sximm5,ALUop);
    input [15:0] decoder_in;
    input [2:0] nsel;
    output [2:0] opcode,readnum,writenum,cond;
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
    assign cond= decoder_in[10:8];
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

