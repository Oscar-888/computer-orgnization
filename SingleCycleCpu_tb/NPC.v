`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC,aluout);  // next pc module
    
   input  [31:0] PC;        // pc,use for AUIPC instruction
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input  [31:0] aluout;    //result from alu module,for jalr instruction
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = PC+IMM;  //for sbtype
          `NPC_JUMP:   NPC = PC+IMM;  //for jal
		    `NPC_JALR:	  NPC = aluout;  //for jalr instruction
           default:    NPC = PCPLUS4; //for the default condition
      endcase
   end // end always
   
endmodule
