`include "ctrl_encode_def.v"
module SCPU(
    input         clk,         // clock
    input         reset,       // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    output        mem_w,      // output: memory write signal
    output [31:0] PC_out,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    //input  [4:0] reg_sel,    // register selection (for debug use)
   // output [31:0] reg_data,  // selected register data (for debug use)
    output [2:0] DMType
);
    //assign Addr_out=aluout;
	//assign B = (ALUSrc) ? immout : RD2;
	//assign Data_out = RD2;
    //declaration of pipeline registers IN/OUT
    //given that the ID/EX pipeline register requires 160bits, larger than 128bits,so 181bits for all pipeline register IN and OUT
    //declaration of relevent virables of IF/ID register
    wire [180:0]IF_ID_IN;
	wire [180:0]IF_ID_OUT;
    wire        IF_ID_flush;
    //declaration of relevent virables of ID/EX register
    wire [180:0]ID_EX_IN;
    wire [180:0]ID_EX_OUT;
    wire        ID_EX_flush;
    wire        ID_EX_writeE;
    //declaration of relevent virables of EX/MEM register
    wire [180:0]EX_MEM_IN;
    wire [180:0]EX_MEM_OUT;
    wire        EX_MEM_flush;
    wire        EX_MEM_writeE;
    //declaration of relevent virables of MEM/WB register
    wire [180:0]MEM_WB_IN;
    wire [180:0]MEM_WB_OUT;
    wire        MEM_WB_flush;
    wire        MEM_WB_writeE;
    //declaration virables for ID STAGE
    wire       stall_signal;
    wire [31:0]ID_PC;
    wire       ID_MemWrite;
    wire [2:0] ID_DMType;
    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation
    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
    wire        ALUSrc;      // ALU source for A
    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire        MemRead;
	wire [4:0]  iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire [31:0] aluout;
    //declaration of virables for  EX stage 
    wire       ID_EX_MemRead;
    wire [4:0] ID_EX_rd;
    wire       ID_EX_RegWrite;
    wire       ID_EX_MemWrite;
    wire [4:0] ID_EX_ALUOp;
    wire [2:0] ID_EX_NPCOp;
    wire       ID_EX_ALUSrc;
    wire [2:0] ID_EX_DMType;
    wire [1:0] ID_EX_WDSel;
    wire [31:0]EX_immout;
    wire [31:0]EX_RD1;
    wire [31:0]EX_RD2;
    wire [4:0] EX_rs1;
    wire [4:0] EX_rs2;
    wire [31:0]EX_PC;
    wire [31:0]selResult;
    wire       Branch_or_jump;
    wire [1:0] FORWARD1;//=2'b0;
    wire [1:0] FORWARD2;//=2'b0;
    wire        Zero;        // ALU ouput zero
    wire [31:0] NPC;         // next PC
    wire [31:0] B;           // operator for ALU B
    wire [31:0] A;
    //declaration of virables for MEM stage 
    wire       MEM_RegWrite;
    wire [4:0] MEM_rd;
    wire [31:0]MEM_MemRead;
    wire [1:0] MEM_WDSel;
    wire [2:0] MEM_DMType;
    wire [2:0] MEM_NPCOp;
    wire [31:0]MEM_PC;
    wire       MEM_MemWrite;
    wire [31:0]MEM_immout;
    wire       MEM_Zero;
    wire [31:0]EX_MEM_aluout;
    wire [31:0]DataToDM;
    wire [31:0]dm_dout;
    //declaration of virables for WB stage 
    wire [1:0] WB_WDSel;
    wire [31:0]WB_PC;
    wire       WB_RegWrite;
	wire [4:0] WB_rd;
    wire [31:0]DataToReg;
    wire [31:0]MEM_WB_aluout;
    reg  [31:0] WD;          // register write data
   //IF STAGE
   //use PC to fetch the instruction for the clock cycle to execute
   // instantiation of pc unit
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out),.IS_STALL(stall_signal) );
   //assignment of the input of IF/ID pipeline register.
   //PC_out  represent for the current PC.
   //inst_in represent for the current instruction.
   assign IF_ID_IN={117'b0,PC_out[31:0],inst_in[31:0]};
   //assignment of the IF/ID pipeline register
   //clk&reset are the same to the input of the SCPU module
   //about write_enable: when the pipeline is stalled, 
   //          given that virable stall_signal is decided when current instruction is in IF stage and the next instruction is in ID stage
   //          the next instruction should be stalled, so IF/ID pipeline register should NOT be written 
   //about flush(ID_EX_flush): flush information is used for JUMP or BRANCH instruction and whether BRANCH instruction junps is decided in EX stage
   //    when jump occurs, 2 instructions has entered pipeline, which need to be flushed
   //    so use ID_EX_flush from EX stage to decide whether IF/ID is flushed
   GRE_array IF_ID
   (
    .Clk(clk),
    .Rst(reset),
    .write_enable(~stall_signal),
    .flush(ID_EX_flush),
    .in(IF_ID_IN),
    .out(IF_ID_OUT)
   );
   //ID STAGE
   // instantiation of control unit
   	assign iimm_shamt=IF_ID_OUT[24:20];
	assign iimm      =IF_ID_OUT[31:20];
	assign simm      ={IF_ID_OUT[31:25],IF_ID_OUT[11:7]};
	assign bimm      ={IF_ID_OUT[31],IF_ID_OUT[7],IF_ID_OUT[30:25],IF_ID_OUT[11:8]};
	assign uimm      =IF_ID_OUT[31:12];
	assign jimm      ={IF_ID_OUT[31],IF_ID_OUT[19:12],IF_ID_OUT[20],IF_ID_OUT[30:21]};
    assign Op        = IF_ID_OUT[6:0];  // instruction
    assign Funct7    = IF_ID_OUT[31:25]; // funct7
    assign Funct3    = IF_ID_OUT[14:12]; // funct3
    assign rs1       = IF_ID_OUT[19:15];  // rs1
    assign rs2       = IF_ID_OUT[24:20];  // rs2
    assign rd        = IF_ID_OUT[11:7];  // rd
    assign Imm12     = IF_ID_OUT[31:20];// 12-bit immediate
    assign IMM       = IF_ID_OUT[31:12];  // 20-bit immediate
    assign ID_PC     = IF_ID_OUT[63:32];
    //assignments of control signals
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), /*.Zero(Zero), */
		.RegWrite(RegWrite), .MemWrite(ID_MemWrite),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel)
        ,.DMType(ID_DMType),.MemRead(MemRead)
	);
    //assignments of immediate value
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
	//Module instantiation of RF
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(WB_RegWrite), 
		.A1(rs1), .A2(rs2), .A3(WB_rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);
    //assignments of stall_signal
    HazardDectectionUnit U_HazardDectectionUnit
    (
        .EX_MemRead(ID_EX_MemRead)
        ,.ID_rs1(rs1)
        ,.ID_rs2(rs2)
        ,.EX_rd(ID_EX_rd)
        ,.stall_signal(stall_signal)
    );
    //assignment of input of ID/EX pipeline register
    //assign ID_EX_IN={21'b0,RegWrite,mem_w,ALUOp[4:0],NPCOp[2:0],ALUSrc,DMType[2:0],WDSel[1:0],MemRead,ID_PC[31:0],immout[31:0],RD1[31:0],RD2[31:0],rs1[4:0],rs2[4:0],rd[4:0]};
    //if the pipeline is stalled,all control signals should be flushed
    assign ID_EX_IN[142:0]  ={ID_PC[31:0],immout[31:0],RD1[31:0],RD2[31:0],rs1[4:0],rs2[4:0],rd[4:0]};
    assign ID_EX_IN[143]    =(stall_signal)?0:MemRead;
    assign ID_EX_IN[145:144]=(stall_signal)?0:WDSel[1:0];
    assign ID_EX_IN[148:146]=(stall_signal)?0:ID_DMType[2:0];
    assign ID_EX_IN[149]    =(stall_signal)?0:ALUSrc;
    assign ID_EX_IN[152:150]=(stall_signal)?0:NPCOp[2:0];
    assign ID_EX_IN[157:153]=(stall_signal)?0:ALUOp[4:0];
    assign ID_EX_IN[158]    =(stall_signal)?0:ID_MemWrite;
    assign ID_EX_IN[159]    =(stall_signal)?0:RegWrite;
    assign ID_EX_IN[180:160]=21'b0;
    assign ID_EX_writeE=1;
    //assign ID_EX_flush=0;
    //information about ID_EX_flush has mentioned before
    //about write_enalbe: as has mentioned before, when stall_signal is positive,only 1 irrelvent instruction enters pipeline
    //only IF/ID pipeline register should not be modified,so ID/EX,EX/MA,MA/WB register's write_enable is 1
    GRE_array ID_EX
   (
    .Clk(clk),
    .Rst(reset),
    .write_enable(ID_EX_writeE),
    .flush(ID_EX_flush),
    .in(ID_EX_IN),
    .out(ID_EX_OUT)
   );
   //EX STAGE
   //decode essential information from ID/EX register
   // wire [4:0] EX_rd;
   assign ID_EX_rd            =ID_EX_OUT[4:0];
   assign EX_rs2              =ID_EX_OUT[9:5];
   assign EX_rs1              =ID_EX_OUT[14:10];
   assign EX_RD2              =ID_EX_OUT[46:15];
   assign EX_RD1              =ID_EX_OUT[78:47];
   assign EX_immout           =ID_EX_OUT[110:79];
   assign EX_PC               =ID_EX_OUT[142:111];//for NPC module to decide the next PC
   assign ID_EX_MemRead       =ID_EX_OUT[143];
   assign ID_EX_WDSel         =ID_EX_OUT[145:144];
   assign ID_EX_DMType        =ID_EX_OUT[148:146];
   assign ID_EX_ALUSrc        =ID_EX_OUT[149];
   // assign ID_EX_NPCOp[2:1]   =ID_EX_OUT[152:151];
   assign ID_EX_ALUOp        =ID_EX_OUT[157:153];
   assign ID_EX_MemWrite     =ID_EX_OUT[158];
   assign ID_EX_RegWrite     =ID_EX_OUT[159];
   //about NPCOp:decide whether sbtype instructions jump
   //NPCOp[0] is sbtype , so it depends on Zero&sbtype to deside whether it jummps
   assign ID_EX_NPCOp={ID_EX_OUT[152:151],ID_EX_OUT[150] & Zero};
   //2 forwarding unit to solve data hazard  
   //2 op number of alu can be selected from data read from RF from EX stage/aluout of previous instruction from MEM stage/data write bcak to RF from WB stage
   ForwardingUnit ForwardA
   (
    .MEM_RegWrite(MEM_RegWrite)
    ,.MEM_rd(MEM_rd)
    ,.WB_rd(WB_rd)
    ,.WB_RegWrite(WB_RegWrite)
    ,.Ex_rs(EX_rs1)
    ,.ForwardSignal(FORWARD1)
   );
    ForwardingUnit ForwardB
   (
    .MEM_RegWrite(MEM_RegWrite)
    ,.MEM_rd(MEM_rd)
    ,.WB_rd(WB_rd)
    ,.WB_RegWrite(WB_RegWrite)
    ,.Ex_rs(EX_rs2)
    ,.ForwardSignal(FORWARD2)
   );
 //select 2 op number for alu 
 //for A: forwardA=00:from rf
 //       forwardA=01:from WB stage
 //       forwardA=10:from MEM stage
 //for B: immidate value is selected afer forwarding unit
 //       ALUSRC=1: immediate from EXT module
 //       ALUSRC=0: result of forwarding unit
 //       forwardB=00: from rf
 //       forwardB=01: from WB stage
 //       forwardB=10: from EX stage 
  assign A=(FORWARD1[0])?WD:((FORWARD1[1])?EX_MEM_aluout:EX_RD1);
  assign B=(ID_EX_ALUSrc) ? EX_immout:((FORWARD2[0])?WD:((FORWARD2[1])?EX_MEM_aluout:EX_RD2));
  //assign Zero=0;
  //selResult is the result of the forwarding unit
  //it may serve as data to be written to dm for dm module
  assign selResult=(FORWARD2[0])?WD:((FORWARD2[1])?EX_MEM_aluout:EX_RD2);
  // instantiation of alu unit
  alu U_alu(.A(A), .B(B), .ALUOp(ID_EX_ALUOp), .C(aluout), .Zero(Zero),.PC(EX_PC));
  //decide whether to jump
  assign Branch_or_jump= ID_EX_NPCOp[2]|ID_EX_NPCOp[1]|ID_EX_NPCOp[0];
  assign ID_EX_flush= stall_signal | Branch_or_jump;
  //decide the next pc
  NPC U_NPC(.PC(PC_out), .NPCOp(ID_EX_NPCOp), .IMM(EX_immout), .NPC(NPC), .aluout(aluout),.EX_PC(EX_PC));
  assign EX_MEM_IN={36'b0,EX_PC[31:0],ID_EX_RegWrite,ID_EX_MemWrite,ID_EX_NPCOp[2:0],ID_EX_DMType[2:0],ID_EX_WDSel[1:0],ID_EX_MemRead,ID_EX_rd[4:0],selResult[31:0],Zero,aluout[31:0],EX_immout[31:0]};
  assign EX_MEM_flush =0;
  assign EX_MEM_writeE=1;
  GRE_array EX_MEM
   (
    .Clk(clk),
    .Rst(reset),
    .write_enable(EX_MEM_writeE),
    .flush(EX_MEM_flush),
    .in(EX_MEM_IN),
    .out(EX_MEM_OUT)
   );
  //MEM STAGE 
  //decode information for MEM stage from EX/MEM register 
  assign MEM_immout   =EX_MEM_OUT[31:0];
  assign EX_MEM_aluout=EX_MEM_OUT[63:32];
  assign MEM_Zero     =EX_MEM_OUT[64];
  assign DataToDM     =EX_MEM_OUT[96:65];
  assign MEM_rd       =EX_MEM_OUT[101:97];
  assign MEM_MemRead  =EX_MEM_OUT[102];
  assign MEM_WDSel    =EX_MEM_OUT[104:103];
  assign MEM_DMType   =EX_MEM_OUT[107:105];
  assign MEM_MemWrite =EX_MEM_OUT[111];
  assign MEM_RegWrite =EX_MEM_OUT[112];
  assign MEM_PC       =EX_MEM_OUT[144:113]; 
  //prepare parameters for DM module(it is instrantiated in the top module)
  assign mem_w        =MEM_MemWrite;
  assign Data_out     =DataToDM;
  assign DMType       =MEM_DMType;
  assign Addr_out     =EX_MEM_aluout;
  assign MEM_WB_IN    ={77'b0,MEM_PC[31:0],MEM_RegWrite,MEM_WDSel[1:0],MEM_rd[4:0],EX_MEM_aluout[31:0],Data_in[31:0]};
  assign MEM_WB_flush =0;
  assign MEM_WB_writeE=1;
  GRE_array MEM_WB
   (
    .Clk(clk),
    .Rst(reset),
    .write_enable(MEM_WB_writeE),
    .flush(MEM_WB_flush),
    .in(MEM_WB_IN),
    .out(MEM_WB_OUT)
   );
// WB STAGE
//decode information for WB stage from MEM/WB pipeline register 
assign WB_PC        =MEM_WB_OUT[103:72];
assign WB_RegWrite  =MEM_WB_OUT[71];
assign WB_WDSel     =MEM_WB_OUT[70:69];
assign DataToReg    =MEM_WB_OUT[31:0];
assign MEM_WB_aluout=MEM_WB_OUT[63:32];
assign WB_rd        =MEM_WB_OUT[68:64];
//please connnect the CPU by yourself
//select which is to be written to register
always @*
begin
	case(WB_WDSel)
		`WDSel_FromALU: WD<=MEM_WB_aluout;
		`WDSel_FromMEM: WD<=DataToReg;//WD<=Data_in;/
		`WDSel_FromPC:  WD<=WB_PC+4;//PC_out+4;
	endcase
end
endmodule