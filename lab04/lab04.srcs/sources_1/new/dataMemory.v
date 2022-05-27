`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:53:42
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input clk,
    input [31 : 0] address,
    input [31 : 0] writeData,
    input memWrite,
    input memRead,
    output reg [31 : 0] readData
    );
    
    reg [31 : 0] memFile [0 : 1023];
    
    always @ (address)
    begin
        if (memRead && !memWrite)
            readData = memFile[address];
        else
            readData = 0;
    end
    
    always @ (negedge clk)
    begin
        if (memWrite)
            memFile[address] = writeData;
    end
endmodule
