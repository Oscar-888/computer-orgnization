`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC,aluout,EX_PC);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
   input [31:0] aluout;
   input [31:0]EX_PC;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = EX_PC+IMM;
          `NPC_JUMP:   NPC = EX_PC+IMM;
		    `NPC_JALR:	  NPC = aluout;
           default:    NPC = PCPLUS4;
      endcase
      end
   end // end always
   
endmodule
