module ForwardingUnit(
input      MEM_RegWrite,  // EX/MEM RegWrite ,RegWrite signal from EX/MEM pipeline register
input [4:0]MEM_rd,        // EX/MEM RegisterRd,rd signal from EX/MEM pipeline register
input      WB_RegWrite,   // MEM/WB RegWrite, RegWrite signal from MEM/WB pipeline register
input [4:0]WB_rd,         // MEM/WB RegisterRd,rd signal from MEM/WB pipeline register
input [4:0]Ex_rs,         // EX/MEM RegisterRs1/2,rs1 and rs2 signal from EX/MEM pipeline register
output[1:0]ForwardSignal  // 00:from regfile,10:from MEM_aluout,01:from WB_WD
);
//the FORWARD UNIT is used for DATA HAZARD
//to choose two operation number for ALU module
wire MEM_Forward;
wire WB_Forward;
assign MEM_Forward   =~(|(MEM_rd^Ex_rs))&MEM_RegWrite;//decide whether the register which previous 1 instruction is to write is equal to the register which current instruction is to read
assign WB_Forward    =~(|(WB_rd^Ex_rs))&WB_RegWrite&~MEM_Forward;//decide whether the register which previous 2 instruction is to write is equal to the register which current instruction is to read
assign ForwardSignal ={MEM_Forward,WB_Forward};
endmodule  