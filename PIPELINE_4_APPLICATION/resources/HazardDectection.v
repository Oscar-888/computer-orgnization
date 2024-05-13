module HazardDectectionUnit
(
 input      EX_MemRead,  //MemRead signal from ID/EX pipeline register
 input [4:0]ID_rs1,      //rs1 signal from IF/ID pipeline register
 input [4:0]ID_rs2,      //rs2 signal from IF/ID pipeline register
 input [4:0]EX_rd,       //rd  signal from ID/EX pipeline register
 output     stall_signal //stall signal
);
//the HAZARD DECTECT UNIT is  used for LOAD instruction such as ld,lb,lbu...... TO SOLVE DATA HAZARD
//whether the register which previous instruction is to write is equal to the register which current instruction is read
//rd=rs1 or rd=rs2
assign stall_signal=EX_MemRead&(~(|(EX_rd^ID_rs1))|~(|(EX_rd^ID_rs2)));
endmodule