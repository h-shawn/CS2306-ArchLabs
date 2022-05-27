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
    reg NOP;
    reg STALL;

    //IF 
    reg [31:0] IF_PC;  
    wire [31:0] IF_INST;  
    InstMemory instMemory(
        .address(IF_PC),
        .inst(IF_INST)
    );

    //IF to ID
    reg [31:0] IF2ID_INST;
    reg [31:0] IF2ID_PC;

    //ID 
    wire [12:0] ID_CTR_SIGNALS;
    wire [3:0] ID_CTR_SIGNAL_ALUOP;
    Ctr mainCtr(
        .opCode(IF2ID_INST[31:26]),
        .funct(IF2ID_INST[5:0]),
        .jump(ID_CTR_SIGNALS[12]),
        .jrSign(ID_CTR_SIGNALS[11]),
        .extSign(ID_CTR_SIGNALS[10]),
        .regDst(ID_CTR_SIGNALS[9]),
        .jalSign(ID_CTR_SIGNALS[8]),
        .aluSrc(ID_CTR_SIGNALS[7]),
        .luiSign(ID_CTR_SIGNALS[6]),
        .beqSign(ID_CTR_SIGNALS[5]),
        .bneSign(ID_CTR_SIGNALS[4]),
        .memWrite(ID_CTR_SIGNALS[3]),
        .memRead(ID_CTR_SIGNALS[2]),
        .memToReg(ID_CTR_SIGNALS[1]),
        .regWrite(ID_CTR_SIGNALS[0]),
        .aluOp(ID_CTR_SIGNAL_ALUOP)
    );

    wire[31:0] ID_REG_READ_DATA1;   
    wire[31:0] ID_REG_READ_DATA2;  

    wire[4:0] WB_WRITE_REG_ID;         
    wire[4:0] WB_WRITE_REG_ID_AFTER_JAL_MUX;         
    wire[31:0] WB_REG_WRITE_DATA;    
    wire[31:0] WB_REG_WRITE_DATA_AFTER_JAL_MUX; 
    wire WB_REG_WRITE;         

    wire [4:0] ID_REG_DEST;

    Mux32 jal_data_mux(
        .select(ID_CTR_SIGNALS[8]),
        .input2(WB_REG_WRITE_DATA),
        .input1(IF2ID_PC+4),
        .out(WB_REG_WRITE_DATA_AFTER_JAL_MUX)
    );

    Mux32 jal_reg_id_mux(
        .select(ID_CTR_SIGNALS[8]),
        .input2(WB_WRITE_REG_ID),
        .input1(5'b11111),
        .out(WB_WRITE_REG_ID_AFTER_JAL_MUX)
    );
    
    
    Mux5 reg_dst_mux(
        .select(ID_CTR_SIGNALS[9]),
        .input2(IF2ID_INST[20:16]),
        .input1(IF2ID_INST[15:11]),
        .out(ID_REG_DEST)
    );

    Registers registers(
        .readReg1(IF2ID_INST[25:21]),
        .readReg2(IF2ID_INST[20:16]),
        .writeReg(WB_WRITE_REG_ID_AFTER_JAL_MUX),
        .writeData(WB_REG_WRITE_DATA_AFTER_JAL_MUX),
        .regWrite(WB_REG_WRITE),
        .clk(clk),
        .reset(reset),
        .readData1(ID_REG_READ_DATA1),
        .readData2(ID_REG_READ_DATA2)
    );
    
    wire [31:0] ID_EXT_RES;

    signext signExt(
        .inst(IF2ID_INST[15:0]),
        .signExt(ID_CTR_SIGNALS[10]),
        .data(ID_EXT_RES)
    );


    //ID to EX
    reg [3:0] ID2EX_ALUOP;
    reg [7:0] ID2EX_CTR_SIGNALS;
    reg [31:0] ID2EX_EXT_RES;
    reg [4:0] ID2EX_INST_RS;        
    reg [4:0] ID2EX_INST_RT;    
    reg [31:0] ID2EX_REG_READ_DATA1;
    reg [31:0] ID2EX_REG_READ_DATA2;
    reg [5:0] ID2EX_INST_FUNCT;
    reg [4:0] ID2EX_INST_SHAMT;
    reg [4:0] ID2EX_REG_DEST;
    reg [31:0] ID2EX_PC;


    // EX 
    wire EX_ALU_SRC_SIG = ID2EX_CTR_SIGNALS[7];
    wire EX_LUI_SIG = ID2EX_CTR_SIGNALS[6];
    wire EX_BEQ_SIG = ID2EX_CTR_SIGNALS[5];
    wire EX_BNE_SIG = ID2EX_CTR_SIGNALS[4];

    wire [3:0] EX_ALU_CTR_OUT;  
    wire EX_SHAMT_SIGNAL; 

    ALUCtr aluCtr(
        .aluOp(ID2EX_ALUOP),
        .funct(ID2EX_INST_FUNCT),
        .shamtSign(EX_SHAMT_SIGNAL),
        .aluCtrOut(EX_ALU_CTR_OUT)
    );

    //FORWARDING
    wire [31:0] FORWARDING_RES_A;
    wire [31:0] FORWARDING_RES_B;

    wire [31:0] EX_ALU_INPUT2;
    wire [31:0] EX_ALU_INPUT1;

    Mux32 rt_ext_mux(
        .select(EX_ALU_SRC_SIG),
        .input1(ID2EX_EXT_RES),
        .input2(FORWARDING_RES_B),
        .out(EX_ALU_INPUT2)
    );
    Mux32 rs_shamt_mux(
        .select(EX_SHAMT_SIGNAL),
        .input1({27'b0, ID2EX_INST_SHAMT}),
        .input2(FORWARDING_RES_A),
        .out(EX_ALU_INPUT1)
    );

    wire EX_ALU_ZERO;   
    wire [31:0] EX_ALU_RES;
    wire [31:0] EX_FINAL_DATA;
    ALU alu(
        .input1(EX_ALU_INPUT1),
        .input2(EX_ALU_INPUT2),
        .aluCtrOut(EX_ALU_CTR_OUT),
        .aluRes(EX_ALU_RES),
        .zero(EX_ALU_ZERO)
    );

    Mux32 lui_mux(
        .select(EX_LUI_SIG),
        .input2(EX_ALU_RES),
        .input1({ID2EX_EXT_RES[15:0],16'b0}),
        .out(EX_FINAL_DATA)
    );

    wire [31:0] BRANCH_DEST = ID2EX_PC + 4 + (ID2EX_EXT_RES << 2);

    //EX to MA
    reg [3:0] EX2MA_CTR_SIGNALS;
    reg [31:0] EX2MA_ALU_RES;
    reg [31:0] EX2MA_REG_READ_DATA_2;
    reg [4:0] EX2MA_REG_DEST;

    wire MA_MEM_WRITE = EX2MA_CTR_SIGNALS[3];
    wire MA_MEM_READ = EX2MA_CTR_SIGNALS[2];
    wire MA_MEM_TO_REG = EX2MA_CTR_SIGNALS[1];
    wire MA_REG_WRITE = EX2MA_CTR_SIGNALS[0];

    //MA 
    wire [31:0] MA_MEM_READ_DATA;
    dataMemory memory(
        .clk(clk),
        .address(EX2MA_ALU_RES),
        .writeData(EX2MA_REG_READ_DATA_2),
        .memWrite(MA_MEM_WRITE),
        .memRead(MA_MEM_READ),
        .readData(MA_MEM_READ_DATA)
    );

    wire [31:0] MA_FINAL_DATA;
    Mux32 mem_to_reg_mux(
        .input2(EX2MA_ALU_RES),
        .input1(MA_MEM_READ_DATA),
        .select(MA_MEM_TO_REG),
        .out(MA_FINAL_DATA)
    );

    //MA to WB
    reg MA2WB_CTR_SIGNALS;
    reg [31:0] MA2WB_FINAL_DATA;
    reg [4:0] MA2WB_REG_DEST;

    //WB 
    assign WB_WRITE_REG_ID = MA2WB_REG_DEST;
    assign WB_REG_WRITE_DATA = MA2WB_FINAL_DATA;
    assign WB_REG_WRITE = MA2WB_CTR_SIGNALS;

    // Jump or Jr
    wire[31:0] PC_AFTER_JUMP_MUX;
    Mux32 jump_mux(
        .select(ID_CTR_SIGNALS[12]), 
        .input1(((IF2ID_PC + 4) & 32'hf0000000) + (IF2ID_INST [25 : 0] << 2)),
        .input2(IF_PC + 4),
        .out(PC_AFTER_JUMP_MUX)
    );
    
    wire[31:0] PC_AFTER_JR_MUX;
    Mux32 jr_mux(
        .select(ID_CTR_SIGNALS[11]),   
        .input2(PC_AFTER_JUMP_MUX),
        .input1(ID_REG_READ_DATA1),
        .out(PC_AFTER_JR_MUX)
    );
    
    wire EX_BEQ_BRANCH = EX_BEQ_SIG & EX_ALU_ZERO;
    wire[31:0] PC_AFTER_BEQ_MUX;
    Mux32 beq_mux(
        .select(EX_BEQ_BRANCH),
        .input1(BRANCH_DEST),
        .input2(PC_AFTER_JR_MUX),
        .out(PC_AFTER_BEQ_MUX)
    );
    
    wire EX_BNE_BRANCH = EX_BNE_SIG & (~ EX_ALU_ZERO);
    wire[31:0] PC_AFTER_BNE_MUX;
    Mux32 bne_mux(
        .select(EX_BNE_BRANCH),
        .input1(BRANCH_DEST),
        .input2(PC_AFTER_BEQ_MUX),
        .out(PC_AFTER_BNE_MUX)
    );

    wire[31:0] NEXT_PC = PC_AFTER_BNE_MUX;
    
    wire BRANCH = EX_BEQ_BRANCH | EX_BNE_BRANCH;

    // forwarding
    wire[31:0] EX_FORWARDING_A_TEMP;
    wire[31:0] EX_FORWARDING_B_TEMP;
    Mux32 forward_A_mux1(
        .select(WB_REG_WRITE & (MA2WB_REG_DEST == ID2EX_INST_RS)),
        .input2(ID2EX_REG_READ_DATA1),
        .input1(MA2WB_FINAL_DATA),
        .out(EX_FORWARDING_A_TEMP)
    );
    Mux32 forward_A_mux2(
        .select(MA_REG_WRITE & (EX2MA_REG_DEST == ID2EX_INST_RS)),
        .input2(EX_FORWARDING_A_TEMP),
        .input1(EX2MA_ALU_RES),
        .out(FORWARDING_RES_A)
    );
    
    Mux32 forward_B_mux1(
        .select(WB_REG_WRITE & (MA2WB_REG_DEST == ID2EX_INST_RT)),
        .input2(ID2EX_REG_READ_DATA2),
        .input1(MA2WB_FINAL_DATA),
        .out(EX_FORWARDING_B_TEMP)
    );
    Mux32 forward_B_mux2(
        .select(MA_REG_WRITE & (EX2MA_REG_DEST == ID2EX_INST_RT)),
        .input2(EX_FORWARDING_B_TEMP),
        .input1(EX2MA_ALU_RES),
        .out(FORWARDING_RES_B)
    );
    initial IF_PC = 0;
    
    always @(reset)
    begin
        if (reset) begin
            IF_PC = 0;
            IF2ID_INST = 0;
            IF2ID_PC = 0;
            ID2EX_ALUOP = 0;
            ID2EX_CTR_SIGNALS = 0;
            ID2EX_EXT_RES = 0;
            ID2EX_INST_RS = 0;
            ID2EX_INST_RT = 0;
            ID2EX_REG_READ_DATA1 = 0;
            ID2EX_REG_READ_DATA2 = 0;
            ID2EX_INST_FUNCT = 0;
            ID2EX_INST_SHAMT = 0;
            ID2EX_REG_DEST = 0;
            EX2MA_CTR_SIGNALS = 0;
            EX2MA_ALU_RES = 0;
            EX2MA_REG_READ_DATA_2 = 0;
            EX2MA_REG_DEST = 0;
            MA2WB_CTR_SIGNALS = 0;
            MA2WB_FINAL_DATA = 0;
            MA2WB_REG_DEST = 0;
        end
    end
    
    always @(posedge clk) 
    begin
        NOP = BRANCH | ID_CTR_SIGNALS[12] | ID_CTR_SIGNALS[11];
        STALL = ID2EX_CTR_SIGNALS[2] & 
                 ((ID2EX_INST_RT == IF2ID_INST[25:21]) | 
                 (ID2EX_INST_RT == IF2ID_INST[20:16])); 

        // IF - ID
        if(!STALL)
        begin
            if(!NOP)
            begin
                IF2ID_INST <= IF_INST;
                IF2ID_PC <= IF_PC;
                IF_PC <= NEXT_PC;
            end
            else
            begin
                if(IF_PC == NEXT_PC)
                begin
                    IF2ID_INST <= IF_INST;
                    IF2ID_PC <= IF_PC;
                    IF_PC <= IF_PC + 4;
                end
                else begin
                    IF2ID_INST <= 0;
                    IF2ID_PC <= 0;
                    IF_PC <= NEXT_PC;
                end
            end
        end
        
        // ID - EX
        if (!ID_CTR_SIGNALS[8])
        begin
            if (STALL | NOP)
            begin
                ID2EX_PC <= IF2ID_PC;
                ID2EX_ALUOP <= 4'b1110;
                ID2EX_CTR_SIGNALS <= 0;
                ID2EX_EXT_RES <= 0;
                ID2EX_INST_RS <= 0;
                ID2EX_INST_RT <= 0;
                ID2EX_REG_READ_DATA1 <= 0;
                ID2EX_REG_READ_DATA2 <= 0;
                ID2EX_INST_FUNCT <= 0;
                ID2EX_INST_SHAMT <= 0;
                ID2EX_REG_DEST <= 0;
            end else 
            begin
                ID2EX_PC <= IF2ID_PC;
                ID2EX_ALUOP <= ID_CTR_SIGNAL_ALUOP;
                ID2EX_CTR_SIGNALS <= ID_CTR_SIGNALS[7:0];
                ID2EX_EXT_RES <= ID_EXT_RES;
                ID2EX_INST_RS <= IF2ID_INST[25:21];
                ID2EX_INST_RT <= IF2ID_INST[20:16];
                ID2EX_REG_DEST <= ID_REG_DEST;
                ID2EX_REG_READ_DATA1 <= ID_REG_READ_DATA1;
                ID2EX_REG_READ_DATA2 <= ID_REG_READ_DATA2;
                ID2EX_INST_FUNCT <= IF2ID_INST[5:0];
                ID2EX_INST_SHAMT <= IF2ID_INST[10:6];
            end
        end

        // EX - MA
        if (!ID_CTR_SIGNALS[8])
        begin
            EX2MA_CTR_SIGNALS <= ID2EX_CTR_SIGNALS[3:0];
            EX2MA_ALU_RES <= EX_FINAL_DATA;
            EX2MA_REG_READ_DATA_2 <= FORWARDING_RES_B;
            EX2MA_REG_DEST <= ID2EX_REG_DEST;
        end

        // MA - WB
        if (!ID_CTR_SIGNALS[8])
        begin
            MA2WB_CTR_SIGNALS <= EX2MA_CTR_SIGNALS[0];
            MA2WB_FINAL_DATA <= MA_FINAL_DATA;
            MA2WB_REG_DEST <= EX2MA_REG_DEST;
        end  
    end
endmodule