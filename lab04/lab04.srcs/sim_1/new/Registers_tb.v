`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:55:07
// Design Name: 
// Module Name: Registers_tb
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


module Registers_tb(
    );
    reg Clk;
    reg [25 : 21] ReadReg1;
    reg [20 : 16] ReadReg2;
    reg [4 : 0] WriteReg;
    reg [31 : 0] WriteData;
    reg RegWrite;
    wire [31 : 0] ReadData1;
    wire [31 : 0] ReadData2;

    Registers u0(
        .clk(Clk),
        .readReg1(ReadReg1), 
        .readReg2(ReadReg2), 
        .writeReg(WriteReg),
        .writeData(WriteData), 
        .regWrite(RegWrite), 
        .readData1(ReadData1), 
        .readData2(ReadData2)
    );
    
    always #100 Clk = ~Clk;
    
    initial begin
        Clk = 0;
        ReadReg1 = 0;
        ReadReg2 = 0;
        WriteReg = 0;
        WriteData = 0;
        RegWrite = 0;
        
        // 285 ns
        #285;
        RegWrite = 1;
        WriteReg = 5'b10101;
        WriteData = 32'b11111111111111110000000000000000;
        
        // 485 ns
        #200;
        WriteReg = 5'b01010;
        WriteData = 32'b00000000000000001111111111111111;
        
        // 685 ns
        #200;
        RegWrite = 0;
        WriteReg = 5'b00000;
        WriteData = 32'b00000000000000000000000000000000;
        
        // 735 ns
        #50;
        ReadReg1 = 5'b10101;
        ReadReg2 = 5'b01010;    
    end
endmodule
