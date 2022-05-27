`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 14:36:02
// Design Name: 
// Module Name: PC
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


module PC(
    input [31 : 0] pcIn,
    input clk,
    input reset,
    output reg [31 : 0] pcOut
    );
    
    initial pcOut = 0;
    
    always @ (posedge clk or reset)
    begin
        if(reset)
            pcOut = 0;
        else
            pcOut = pcIn;
    end
endmodule
