module PC( clk, rst, NPC, Stall, PC );

  input            clk;
  input            rst;
  input     [31:0] NPC;
  input            Stall;
  output reg  [31:0] PC;

  always @(negedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else if (~Stall) begin
      PC <= NPC;
    end
      
endmodule

