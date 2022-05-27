`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:57:14
// Design Name: 
// Module Name: signext_tb
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


module signext_tb(
    );
    
    reg [15 : 0] Inst;
    wire [31 : 0] Data;
    
    signext u0(
        .inst(Inst), 
        .data(Data)
    );
    
    initial begin
        Inst = 0;
        
        // 200 ns
        #200;
        Inst = 1;
      
        // 400 ns
        #200;
        Inst = -1;
        
        // 600 ns
        #200;
        Inst = 2;
        
        // 800 ns
        #200;
        Inst = -2;
    end
endmodule
