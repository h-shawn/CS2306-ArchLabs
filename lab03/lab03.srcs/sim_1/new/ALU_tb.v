`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/13 23:39:40
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb(
    );
    wire Zero;
    wire [31 : 0] ALURes;
    reg [31 : 0] InputA;
    reg [31 : 0] InputB;
    reg [3 : 0] ALUCtrOut;
    
    ALU u0(
        .inputA(InputA), 
        .inputB(InputB),
        .aluCtrOut(ALUCtrOut), 
        .zero(Zero),
        .aluRes(ALURes)
    );
    
    initial begin
        InputA = 0;
        InputB = 0;
        ALUCtrOut = 0;
        
        #100;
        
        InputA = 15;
        InputB = 10;
        ALUCtrOut = 4'b0000;
        #100;
        
        InputA = 15;
        InputB = 10;
        ALUCtrOut = 4'b0001;
        #100;
        
        InputA = 15;
        InputB = 10;
        ALUCtrOut = 4'b0010;
        #100;
        
        InputA = 15;
        InputB = 10;
        ALUCtrOut = 4'b0110;
        #100;
        
        InputA = 10;
        InputB = 15;
        ALUCtrOut = 4'b0110;
        #100;
        
        InputA = 15;
        InputB = 10;
        ALUCtrOut = 4'b0111;
        #100;
        
        InputA = 10;
        InputB = 15;
        ALUCtrOut = 4'b0111;
        #100;
        
        InputA = 1;
        InputB = 1;
        ALUCtrOut = 4'b1100;
        #100;
        
        InputA = 16;
        InputB = 1;
        ALUCtrOut = 4'b1100;
        #100;
    end
endmodule


