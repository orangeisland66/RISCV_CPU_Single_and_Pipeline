`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/09 16:37:55
// Design Name: 
// Module Name: Forwarding_unit
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


module Forwarding_unit(
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,
    input [4:0] MEM_rd,
    input [4:0] WB_rd,
    input Mem_RegWrite,
    input WB_RegWrite,
    output [1:0] ForwardA,
    output [1:0] ForwardB
    );
    wire MEM_ForwardA = (MEM_rd == 0)? 1'b0:((~(|(MEM_rd ^ EX_rs1))) & (Mem_RegWrite));
    wire WB_ForwardA = (WB_rd == 0)? 1'b0:((~(|(WB_rd ^ EX_rs1))) & (WB_RegWrite) & (~MEM_ForwardA));
    assign ForwardA = {{MEM_ForwardA}, {WB_ForwardA}};
    wire MEM_ForwardB = (MEM_rd == 0)? 1'b0:((~(|(MEM_rd ^ EX_rs2))) & (Mem_RegWrite));
    wire WB_ForwardB = (WB_rd == 0)? 1'b0:((~(|(WB_rd ^ EX_rs2))) & (WB_RegWrite) & (~MEM_ForwardB));
    assign ForwardB = {{MEM_ForwardB}, {WB_ForwardB}};

    
endmodule
