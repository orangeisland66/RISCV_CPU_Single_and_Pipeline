`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/09 17:29:56
// Design Name: 
// Module Name: Hazard_detecction_unit
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


module Hazard_detecction_unit(
    input EX_Mem_r,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] EX_rd,
    output reg Stall);
    
    always@(*) begin
        if(EX_rd != 0) begin
            if(EX_Mem_r && ((EX_rd == rs1)||(EX_rd == rs2))) begin
                Stall <= 1'b1;
            end
            else begin Stall <=1'b0; end
        end
        else begin Stall <=1'b0; end
    end

endmodule
