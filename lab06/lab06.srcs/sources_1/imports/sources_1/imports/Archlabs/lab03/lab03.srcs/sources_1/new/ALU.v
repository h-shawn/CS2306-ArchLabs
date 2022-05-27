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
    output reg overflow,
    output reg [31 : 0] aluRes
    );
    
    reg [31:0] complement;
    
    always @ (input1 or input2 or aluCtrOut)
    begin
        overflow = 0;
        case (aluCtrOut)
            4'b0000:    // and with overflow check
            begin
                aluRes = input1 + input2;
                overflow=((input1[31]&complement[31]&!aluRes[31])|
                         (!input1[31]&!input2[31]&aluRes[31]))?
                            1:0;
            end
            4'b0001:    // add without overflow check
                aluRes = input1 + input2;
            4'b0010:        // sub with overflow check
            begin
                if(input2==32'h80000000)
                    begin
                        aluRes = input1 - input2;
                        overflow = input1[0]?1:0;
                    end
                else
                    begin
                        complement=(~input2)+1;
                        aluRes = input1 + complement;
                        overflow = ((input1[31]&complement[31]&!aluRes[31])||
                                   (!input1[31]&!complement[31]&aluRes[31]))?
                                    1:0;
                    end
            end
            4'b0011:        // sub without overflow check
                aluRes = input1 - input2;
            4'b0100:        // and
                aluRes = input1 & input2;
            4'b0101:        // or
                aluRes = input1 | input2;
            4'b0110:        // xor
                aluRes = input1 ^ input2;
            4'b0111:        // nor
                aluRes = ~(input1 | input2);
            4'b1000:        // slt
                aluRes = ($signed(input1) < $signed(input2));
            4'b1001:        // slt (unsigned)
                aluRes = (input1 < input2);
            4'b1010:        // shift logical left
                aluRes = (input2 << input1);
            4'b1011:        // shift logical right
                aluRes = (input2 >> input1);
            4'b1100:        // shift arithmetic right
                aluRes = ($signed(input2) >>> input1);
            default:        // default
                aluRes = 0;
        endcase
        if (aluRes == 0)
            zero = 1;
        else 
            zero = 0;
    end
endmodule
