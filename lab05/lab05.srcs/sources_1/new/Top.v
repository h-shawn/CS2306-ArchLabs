`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 22:38:18
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top(
        input clk,
        input reset
    );      
    wire REG_DST, ALU_SRC, MEM_TO_REG, REG_WRITE, MEM_READ;                                
    wire MEM_WRITE, BRANCH, EXT_SIGN, JAL_SIGN, JUMP;   
    wire SHAMT_SIGN, JR_SIGN, ALU_OUT_ZERO;
                                  
    wire [2 : 0] ALU_OP;                               
    wire [3 : 0] ALU_CTR_OUT;      
                     
    wire [4 : 0] WRITE_REG1;  
    wire [4 : 0] WRITE_REG2;  
    
    wire [31 : 0] INST_ADDR;        
    wire [31 : 0] INST;                   
    wire [31 : 0] REG_OUT1;         
    wire [31 : 0] REG_OUT2;        
    wire [31 : 0] ALU_INPUT1;     
    wire [31 : 0] ALU_INPUT2;      
    wire [31 : 0] EXT_RES;          
    wire [31 : 0] ALU_RES;          
    wire [31 : 0] REG_WRITE_DATA;   
    wire [31 : 0] REG_WRITE_DATA_T; 
    wire [31 : 0] PC_IN;            
    wire [31 : 0] PC_OUT;           
    wire [31 : 0] MEM_READ_DATA;    
    wire [31 : 0] PC_TEMP1;         
    wire [31 : 0] PC_TEMP2;        
    
    Ctr mainCtr (
        .opCode(INST[31 : 26]),
        .regDst(REG_DST),
        .aluSrc(ALU_SRC),
        .aluOp(ALU_OP),
        .memToReg(MEM_TO_REG),
        .regWrite(REG_WRITE),
        .memRead(MEM_READ),
        .memWrite(MEM_WRITE),
        .branch(BRANCH),
        .jump(JUMP),
        .extSign(EXT_SIGN),
        .jalSign(JAL_SIGN)
    );
    
    ALUCtr aluCtr (
        .aluOp(ALU_OP),
        .funct(INST[5 : 0]),
        .aluCtrOut(ALU_CTR_OUT),
        .shamtSign(SHAMT_SIGN),
        .jrSign(JR_SIGN)
    );
    
    ALU alu (
        .input1(ALU_INPUT1),
        .input2(ALU_INPUT2),
        .aluCtrOut(ALU_CTR_OUT),
        .zero(ALU_OUT_ZERO),
        .aluRes(ALU_RES)
    );
    
    Registers registers (
        .readReg1(INST[25 : 21]),
        .readReg2(INST[20 : 16]),
        .writeReg(WRITE_REG1),
        .writeData(REG_WRITE_DATA),
        .regWrite(REG_WRITE & (~JR_SIGN)),
        .clk(clk),
        .reset(reset),
        .readData1(REG_OUT1),
        .readData2(REG_OUT2)
    );
    
    dataMemory dataMemory (
        .clk(clk),
        .address(ALU_RES),
        .writeData(REG_OUT2),
        .memWrite(MEM_WRITE),
        .memRead(MEM_READ),
        .readData(MEM_READ_DATA)
    );
    
    signext signExt (
        .inst(INST[15 : 0]),
        .signExt(EXT_SIGN),
        .data(EXT_RES)
    );
    
    InstMemory instMemory (
        .address(PC_OUT),
        .inst(INST)
    );
    
    PC pc_controller (
        .pcIn(PC_IN),
        .clk(clk),
        .reset(reset),
        .pcOut(PC_OUT)
    );
    
    Mux32 branch_mux (
        .select(BRANCH & ALU_OUT_ZERO),
        .input1(PC_OUT + 4 + (EXT_RES << 2)),
        .input2(PC_OUT + 4),
        .out(PC_TEMP1)
    );
    
    Mux32 jr_mux (
        .select(JR_SIGN),
        .input1(REG_OUT1),
        .input2(PC_TEMP2),
        .out(PC_IN)
    );
    
    Mux32 jump_mux (
        .select(JUMP),
        .input1(((PC_OUT + 4) & 32'hf0000000) + (INST[25 : 0] << 2)),
        .input2(PC_TEMP1),
        .out(PC_TEMP2)
    );
    
    Mux32 jal_mux (
        .select(JAL_SIGN),
        .input1(PC_OUT + 4),
        .input2(REG_WRITE_DATA_T),
        .out(REG_WRITE_DATA)
    );
    
    Mux32 reg_shamt_mux (
        .select(SHAMT_SIGN),
        .input1({27'b0, INST[10 : 6]}),
        .input2(REG_OUT1),
        .out(ALU_INPUT1)
    );
    
    Mux32 alu_src_mux (
        .select(ALU_SRC),
        .input1(EXT_RES),
        .input2(REG_OUT2),
        .out(ALU_INPUT2)
    );
    
    Mux32 mem_to_reg_mux (
        .select(MEM_TO_REG),
        .input1(MEM_READ_DATA),
        .input2(ALU_RES),
        .out(REG_WRITE_DATA_T)
    );
    
    Mux5 reg_dst_mux (
        .select(REG_DST),
        .input1(INST[15 : 11]),
        .input2(INST[20 : 16]),
        .out(WRITE_REG2)
    );
    
    Mux5 jar_reg_mux (
        .select(JAL_SIGN),
        .input1(5'b11111),
        .input2(WRITE_REG2),
        .out(WRITE_REG1)
    );
endmodule
