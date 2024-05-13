`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero,PC);
           
   input  signed [31:0] A, B; //two operation number for alu module
   input         [4:0]  ALUOp;//alu operation control signal, from Ctrl module
	input         [31:0] PC;   //the PC of the current instrcution, use for the AUIPC instruction
   output signed [31:0] C;    //the result of alu 
   output               Zero; //judge whether the result is 0
   
   reg [31:0] C;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
`ALUOp_nop:  C=A;
`ALUOp_lui:  C=B;
`ALUOp_auipc:C=PC+B;
`ALUOp_add:  C=A+B;
`ALUOp_sub:  C=A-B;
`ALUOp_bne:  C={31'b0,(A==B)};
`ALUOp_blt:  C={31'b0,(A>=B)};
`ALUOp_bge:  C={31'b0,(A<B)};
`ALUOp_bltu: C={31'b0,($unsigned(A)>=$unsigned(B))};
`ALUOp_bgeu: C={31'b0,($unsigned(A)<$unsigned(B))};
`ALUOp_slt:  C={31'b0,(A<B)};
`ALUOp_sltu: C={31'b0,($unsigned(A)<$unsigned(B))};
`ALUOp_xor:  C=A^B;
`ALUOp_or:   C=A|B;
`ALUOp_and:  C=A&B;
`ALUOp_sll:  C=A<<B;
`ALUOp_srl:  C=A>>B;
`ALUOp_sra:  C=A>>>B;
      endcase
     // Zero=(C==32'b0);
   end // end always
   
   assign Zero = (C == 32'b0);

endmodule
    
