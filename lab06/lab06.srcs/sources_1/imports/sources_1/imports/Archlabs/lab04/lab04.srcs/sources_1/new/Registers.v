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
    input [4 : 0] readReg1,
    input [4 : 0] readReg2,
    input [4 : 0] writeReg,
    input [31 : 0] writeData,
    input regWrite,
    input reset,
    output [31 : 0] readData1,
    output [31 : 0] readData2
    );
    
    reg [31 : 0] regFile [31 : 0];
    integer cnt;
    
     initial begin
        regFile[0] = 0;
    end
    
    assign readData1 = regFile[readReg1];
    assign readData2 = regFile[readReg2];
    
    always @ (negedge clk or reset)
    begin
        if(reset)
        begin
            for(cnt = 0;cnt < 32;cnt = cnt + 1)
                regFile[cnt] = 0;
        end
        else 
        begin
            if(regWrite)
                regFile[writeReg] = writeData; 
        end
    end
endmodule
