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
          `NPC_BRANCH: NPC = EX_PC+IMM;//if NPCOp for branch is true, the next PC should be the current PC(EX_PC) add immediate
          `NPC_JUMP:   NPC = EX_PC+IMM;//if NPCOp for jal is true, the next PC should be the current PC(EX_PC) add immediate
		    `NPC_JALR:	  NPC = aluout;   //if NPCOp for jalr is true,the next PC should be value from register add immediate which is aluout
           default:    NPC = PCPLUS4;
      endcase
      end
   end // end always
   
endmodule
