`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC,aluout,flush,JumpPC);  // next pc module
    
   input [31:0] PC;        // pc
   input [2:0]  NPCOp;     // next pc operation
   input [31:0] IMM;       // immediate
   input [31:0] aluout;
   input [31:0] JumpPC;
   output reg flush;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:   begin NPC <= PCPLUS4;    flush <= 1'b0; end
          `NPC_BRANCH:  begin NPC <= JumpPC+IMM; flush <= 1'b1; end
          `NPC_JUMP:    begin NPC <= JumpPC+IMM; flush <= 1'b1; end
		  `NPC_JALR:	begin NPC <= aluout;     flush <= 1'b1; end
          default:      begin NPC <= PCPLUS4;    flush <= 1'b0; end
      endcase
   end // end always
   
endmodule
