module HazardDectectionUnit
(
 input      EX_MemRead,//ID/EX 中memread信号
 input [4:0]ID_rs1,//IF/ID中rs1信号
 input [4:0]ID_rs2,//IF/ID中rs2信号
 input [4:0]EX_rd,//ID/EX中rd信号
 output     stall_signal//stall information
);
//
assign stall_signal=EX_MemRead&(~(|(EX_rd^ID_rs1))|~(|(EX_rd^ID_rs2)));
endmodule