`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:54:02
// Design Name: 
// Module Name: signext
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


module signext(
    input [15 : 0] inst,
    input signExt,
    output [31 : 0] data
    );
    assign data = (signExt ? { {16 {inst[15]}}, inst[15 : 0] } : { 16'h0000, inst[15 : 0] });
endmodule
