`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 15:01:08
// Design Name: 
// Module Name: Top_tb
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


module Top_tb(

    );
    reg clk, reset;
    
    Top cpu(.clk(clk), .reset(reset));
    always #20 clk = ~clk;
    initial begin
        $readmemh("D:/Archlabs/lab06/mem_data.txt", cpu.memory.memFile);   
        $readmemb("D:/Archlabs/lab06/mem_inst.txt", cpu.instMemory.instFile);
        reset = 1;
        clk = 0;
    end
    initial begin
        #20 reset = 0;
        #1000;
        $finish;
    end
endmodule
