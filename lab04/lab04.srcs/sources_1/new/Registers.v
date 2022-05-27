`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:52:03
// Design Name: 
// Module Name: Registers
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


module Registers(
    input clk,
    input [25 : 21] readReg1,
    input [20 : 16] readReg2,
    input [4 : 0] writeReg,
    input [31 : 0] writeData,
    input regWrite,
    output reg [31 : 0] readData1,
    output reg [31 : 0] readData2
    );
    
    reg [31 : 0] regFile [31 : 0];
    
    always @ (readReg1 or readReg2)
    begin
        if(readReg1)
            readData1 = regFile[readReg1];
        else
            readData1 = 0;
        if(readReg2)
            readData2 = regFile[readReg2];
        else
            readData2 = 0;
    end
    
    always @ (negedge clk)
    begin
        if (regWrite)
            regFile[writeReg] = writeData;
    end
endmodule
