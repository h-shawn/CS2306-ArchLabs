`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:56:22
// Design Name: 
// Module Name: dataMemory_tb
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


module dataMemory_tb(
    );
    
    reg Clk;
    reg [31 : 0] Address;
    reg [31 : 0] WriteData;
    reg MemWrite;
    reg MemRead;
    wire [31 : 0] ReadData;
    
    dataMemory u0(
        .clk(Clk), 
        .address(Address), 
        .writeData(WriteData),
        .memWrite(MemWrite), 
        .memRead(MemRead), 
        .readData(ReadData)
    );
    
    always #100 Clk = ~Clk;
    
    initial begin
        Clk = 0;
        Address = 0;
        WriteData = 0;
        MemWrite = 0;
        MemRead = 0;
        
        // 185 ns
        #185;
        MemWrite = 1'b1;
        WriteData = 32'b11100000000000000000000000000000;
        Address = 32'b00000000000000000000000000000111;
        
        // 285 ns
        #100;
        MemWrite = 1'b1;
        WriteData = 32'hffffffff;
        Address = 32'b00000000000000000000000000000110;
        
        // 470 ns
        #185;
        MemRead = 1'b1;
        MemWrite = 1'b0;
        Address = 7;
        
        // 550 ns
        #80;
        MemWrite = 1;
        WriteData = 32'haaaaaaaa;
        Address = 8;
        
        // 630 ns
        #80;
        MemWrite = 0;
        MemRead = 1;
        Address = 6;
    end
endmodule
