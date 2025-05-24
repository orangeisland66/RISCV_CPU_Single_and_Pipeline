`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:22:10 11/03/2014 
// Design Name: 
// Module Name:    Input_2_32bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module   Enter(input clk,
                input[4:0] BTN,
                input[15:0] SW,
                output[4:0] BTN_out,
                output[15:0] SW_out 
            );
	// TODO 防抖

    // always @(*) begin
    //     BTN_out = BTN;
    //     SW_out = SW;
    // end
	
    assign BTN_out = BTN;
    assign SW_out = SW;

endmodule
