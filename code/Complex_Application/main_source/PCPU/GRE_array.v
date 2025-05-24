`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/05 14:49:11
// Design Name: 
// Module Name: GRE_array
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


module GRE_array #(parameter WIDTH = 256)(
    input clk, rst, write_enable, flush,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
    );
    
    always@(negedge clk,posedge rst)
    begin
        if(rst) begin out <= 0; end
        else if(write_enable)
        begin
            if(flush)
                out <= 0;
            else
                out <= in;
        end
    end
    
endmodule