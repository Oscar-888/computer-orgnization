module ForwardingUnit(
input      MEM_RegWrite,// EX/MEM RegWrite
input [4:0]MEM_rd,// EX/MEM RegisterRd
input      WB_RegWrite,// MEM/WB RegWrite
input [4:0]WB_rd,//   MEM/WB RegisterRd
input [4:0]Ex_rs,// EX/MEM RegisterRs1/2
output[1:0]ForwardSignal//00:from regfile,10:from MEM_aluout,01:from WB_WD
);
wire MEM_Forward;
wire WB_Forward;
assign MEM_Forward   =~(|(MEM_rd^Ex_rs))&MEM_RegWrite;
assign WB_Forward    =~(|(WB_rd^Ex_rs))&WB_RegWrite&~MEM_Forward;
assign ForwardSignal ={MEM_Forward,WB_Forward};
endmodule