`include "ctrl_encode_def.v"
//// NPC control signal
//`define NPC_PLUS4   3'b000
//`define NPC_BRANCH  3'b001
//`define NPC_JUMP    3'b010
//`define NPC_JALR 3'b100

module NPC(PC,PC_EX, NPCOp, IMM, NPC,aluout,PCWrite);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [31:0] PC_EX;        // pc_EX
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] aluout;
	input PCWrite;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      if(PCWrite)
      begin
          case (NPCOp)
              `NPC_PLUS4:  NPC = PCPLUS4;
              `NPC_BRANCH: NPC = PC_EX+IMM;
              `NPC_JUMP:   NPC = PC_EX+IMM;
              `NPC_JALR:	NPC =aluout;
              default:     NPC = PCPLUS4;
          endcase
      end
      else NPC=PC;
   end // end always
   
endmodule
