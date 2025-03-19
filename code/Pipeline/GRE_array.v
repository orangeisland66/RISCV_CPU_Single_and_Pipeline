`timescale 1ns / 1ps


module GRE_array #(parameter WIDTH = 200) (
    input Clk, 
    input Rst, 
    input write_enable, 
    input flush,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            out <= {WIDTH{1'b0}};
        end else if (write_enable) begin
            if (flush) begin
                out <= {WIDTH{1'b0}};
            end else begin
                out <= in;
            end
        end
    end

endmodule
