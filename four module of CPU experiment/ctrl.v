`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/03 20:39:19
// Design Name: 
// Module Name: ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ctrl(
input [6:0] Op,  //opcode
input [6:0] Funct7,  //funct7 
input [2:0] Funct3,    // funct3 
input Zero,
output RegWrite, // control signal for register write
output MemWrite, // control signal for memory write
output	[5:0]EXTOp,    // control signal to signed extension
output [4:0] ALUOp,    // ALU opertion
//output [2:0] NPCOp,    // next pc operation
output ALUSrc,   // ALU source for b
output [2:0] DMType, //dm r/w type
output [1:0]WDSel    // (register) write data selection  (MemtoReg)
 );
 //R-type judgement  add sub
wire rtype= ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
wire i_add=rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
wire i_sub=rtype&~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000

//I-type judgement  lb,lh,lw
 wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011
 wire i_lb=itype_l&~Funct3[2]& ~Funct3[1]& ~Funct3[0]; //lb 000
 wire i_lh=itype_l&~Funct3[2]& ~Funct3[1]& Funct3[0];  //lh 001
 wire i_lw=itype_l&~Funct3[2]& Funct3[1]& ~Funct3[0];  //lw 010

//addi judgement
  wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
  wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi 000 func3

//S-format judgement   sw,sb,sh
wire stype=~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
wire i_sw=~Funct3[2]&Funct3[1]&~Funct3[0];//010
wire i_sb=stype& ~Funct3[2]& ~Funct3[1]&~Funct3[0];
wire i_sh=stype&& ~Funct3[2]&~Funct3[1]&Funct3[0];

//auipc信号检测
wire auipc=~Op[6]&~Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//0010111
//jal信号检测
wire jal=Op[6]&Op[5]&~Op[4]&Op[3]&Op[2]&Op[1]&Op[0];//1101111
//registerWrite, memwrite,alusrc,MemeryToregister信号生成
  assign RegWrite   = rtype | itype_r|itype_l |auipc |jal; // register write，12条指令中的r型和i型指令都要写寄存器，因此RegWrite的值与是否为这三种指令有关
  assign MemWrite   = stype;              // memory write，12条指令中只有s型需要写内存，因此MenWrite的赋值与是否是s型指令有关
  assign ALUSrc     = itype_r | stype | itype_l |auipc; // ALU B is from instruction immediate
//mem2reg=wdsel ,WDSel_FromALU 2'b00  WDSel_FromMEM 2'b01
  assign WDSel[0] = itype_l;   
  assign WDSel[1] = jal;

//ALUOp信号生成
//ALUOp_nop 5'b00000
//ALUOp_lui 5'b00001
//ALUOp_auipc 5'b00010
//ALUOp_add 5'b00011
  assign ALUOp[0]= i_add  | i_addi|stype|itype_l;
  assign ALUOp[1]= i_add  | i_addi|stype|itype_l |auipc;


//符号扩展操作信号生成，需要执行的12条指令中仅有S型，R型，I型指令而其对立即数扩展模块的要求只有第3，4位不同，因此仅对第三位第四位进行赋值
assign EXTOp[3] =  stype;
assign EXTOp[4] =  itype_l | itype_r ; 

assign EXTOp[0]=jal;//jal:000001
assign EXTOp[1]=auipc;//auipc:000010
//dm行为操作信号生成
// dm_word 3'b000
//dm_halfword 3'b001
//dm_halfword_unsigned 3'b010
//dm_byte 3'b011
//dm_byte_unsigned 3'b100
//assign DMType[2]=i_lbu;
assign DMType[1]=i_lb | i_sb; //| i_lhu;
assign DMType[0]=i_lh | i_sh | i_lb | i_sb;


endmodule
