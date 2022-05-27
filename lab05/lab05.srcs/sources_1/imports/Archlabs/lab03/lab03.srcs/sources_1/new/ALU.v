`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/13 23:15:43
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31 : 0] input1,
    input [31 : 0] input2,
    input [3 : 0] aluCtrOut,
    output reg zero,
    output reg [31 : 0] aluRes
    );
    
    always @ (input1 or input2 or aluCtrOut)
    begin
        case (aluCtrOut)
            4'b0000:    // and
                aluRes = input1 & input2;
            4'b0001:    // or
                aluRes = input1 | input2;
            4'b0010:    // add
                aluRes = input1 + input2;
            4'b0011:    // sll
                aluRes = input2 << input1;
            4'b0100:    // srl
                aluRes = input2 >> input1;
            4'b0101:    // no change
                aluRes = input1;
            4'b0110:    // sub
                aluRes = input1 - input2;
            4'b0111:    // slt
                aluRes = ($signed(input1) < $signed(input2));
            4'b1100:    // nor
                aluRes = ~(input1 | input2);
            default:
                aluRes = 0;
        endcase
        if (aluRes == 0)
            zero = 1;
        else 
            zero = 0;
    end
endmodule
