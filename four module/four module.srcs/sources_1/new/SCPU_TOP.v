`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/03 20:27:29
// Design Name: 
// Module Name: SCPU_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC 2'b10
//此宏定义为写回数据选择器的控制信号
module SCPU_TOP(
    input clk,  //100MHZ CLK
    input rstn,  //reset signal
    input [15:0] sw_i, //sw_i[15]---sw_i[0] 
    output [7:0] disp_an_o, //8位数码管位选
    output [7:0] disp_seg_o //数码管8段数据
    );
    reg[31:0] clkdiv;
    wire Clk_CPU;
    //分频
    always @(posedge clk or negedge rstn) begin
        if(!rstn) clkdiv <= 0;
        else clkdiv <= clkdiv + 1'b1; 
    end
    //sw_i[15]选择慢速模式或快速模式,决定分屏系数是2的27次方（慢）还是2的25次方（快），总频/分频系数=刷新频率
    assign Clk_CPU = (sw_i[15])? clkdiv[27] : clkdiv[25];
    //取指令至instr中
    wire[31:0]inst_in;
    reg[31:0]rom_addr;
    reg[6:0] Op;
    wire[31:0]immout;
    reg PCSRC;
    //rom每周期地址顺序取数
    `define PCSRC_PC 1'b0
    `define PCSRC_SB 1'b1
    always @(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) begin rom_addr =32 'b0; end
        else begin
            if (rom_addr < 14) begin
                if(sw_i[1]==1'b0)begin
                case(PCSRC)
                  `PCSRC_PC: rom_addr = rom_addr + 1'b1;
                 // `PCSRC_SB: rom_addr = rom_addr+immout>>2;
                endcase
                end
                end
            else  
                rom_addr = 32'b00000; 
            end
    end
    
    // PCadder pc(.clk(clk),.imm(immout),.PC(rom_addr),.jalcontrol(Op),.nextAddr(addr));
    //从coe文件中按地址取值
    dist_mem_gen_0 u_im(
        .a(rom_addr),
        .spo(inst_in)
    );
//指令译码
    reg[4:0]rs1;
    reg[4:0]rs2;
    reg[4:0]rd;
    
    reg[6:0] Funct7;
    reg[2:0] Funct3;
    reg[11:0] iimm;
    reg[11:0] simm;
    reg[19:0] uimm;
    reg [31:0]jimm;
    //Decode
    always@(*)begin
        Op = inst_in[6:0];  // op
        Funct7 = inst_in[31:25]; // funct7
        Funct3 = inst_in[14:12]; // funct3
        rs1 = inst_in[19:15];  // rs1
        rs2 = inst_in[24:20];  // rs2
        rd = inst_in[11:7];  // rd
        iimm=inst_in[31:20];//addi 指令立即数，lw指令立即数
        simm={inst_in[31:25],inst_in[11:7]}; //sw指令立即数  
        uimm=inst_in[31:12];
        jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
    end
    always@(*)begin
    case(Op)
     //7'b1101111:PCSRC=1'b1;
      default:PCSRC=1'b0;
      endcase
    end
  //控制信号生成
  wire Zero;
  wire RegWrite;
  wire[5:0]EXTOp;    
  wire[4:0] ALUOp;    
  wire ALUSrc;   
  wire[2:0] DMType; 
  wire WDSel;
  wire MemWrite;
  //例化控制信号模块
  ctrl U_CTRL(
  .Op(Op),
  .Funct7(Funct7),
  .Funct3(Funct3),
  .Zero(Zero),
  .RegWrite(RegWrite),
  .EXTOp(EXTOp),
  .ALUOp(ALUOp),
  .ALUSrc(ALUSrc),
  .DMType(DMType),
  .WDSel(WDSel),
  .MemWrite(MemWrite)
   );
  //rf模块例化，输出为RD1,RD2两个变量来接收
  wire[31:0]RD1;
  wire[31:0]RD2;
  reg signed [31:0] WD;
  rf U_RF(.clk(Clk_CPU),.rstn(rstn),.RFWr(RegWrite),.sw_i(sw_i[15:0]),.A1(rs1),.A2(rs2),.A3(rd),.WD(WD),.RD1(RD1),.RD2(RD2));
  //符号扩展模块例化，使用immout作为最终符号扩展模块的输出
  
  wire[4:0] iimm_shamt; 
  wire bimm;
  

  EXT U_EXT(.iimm(iimm),.simm(simm),.EXTOp(EXTOp),.immout(immout),.iimm_shamt(iimm_shamt),.bimm(bimm),.uimm(uimm),.jimm(jimm));
  //为ALU模块选择第二个操作数，根据控制信号ALUOp的值来决定是寄存器的值还是立即数扩展后的结果作为第二个操作数
  //reg [31:0]nextAddr;

  
  reg signed[31:0]A;
   always@(*)
  begin
	  case(Op)
		   7'b0010111: A<=rom_addr;//auipc
		  // 7'b1101111: A<=rom_addr+1;
		   default:A<=RD1;
	  endcase
  end
  wire signed[31:0]B;
  assign B=(ALUSrc==1)?immout:RD2;
  //alu模块初始化，使用aluout和Zero变量接收alu的输出
  wire [31:0]aluout;
  alu U_ALU(.A(A),.B(B),.ALUOp(ALUOp),.C(aluout),.Zero(Zero));
  //dm模块初始化，使用dout变量接收dm模块的输出
  wire signed[31:0]dout;
  dm U_DM(.DMType(DMType),.clk(Clk_CPU),.addr(aluout),.din(RD2),.DMWr(MemWrite),.dout(dout));
  //最后的写回数据选择器，决定写回的数据是来自alu的结果还是来自dm的结果
  always@(*)
  begin
	  case(WDSel)
		  `WDSel_FromALU: WD<=aluout;
		  `WDSel_FromMEM: WD<=dout;
		  `WDSel_FromPC: WD<=rom_addr+1;
	  endcase
  end

  //循环显示dm的前16个单元，使用dmem_addr进行遍历，使用dmem_data接收读出的数据
  reg[31:0]dmem_data;
  reg[31:0]dmem_addr;
  parameter DM_DATA_NUM=16;
   always @(posedge Clk_CPU or negedge rstn) begin
          if(!rstn) begin  
              dmem_addr<= 7'b000000;
              dmem_data<= 32'hFFFFFFFF; end
          else if(sw_i[11]==1'b1)begin   
              dmem_data = {dmem_addr[3:0],{20'b0},U_DM.dmem[dmem_addr][7:0]};//每个内存单元为8位，占输出信号的八位，而一共需要显示16个模块，使用1个数码管表示即可故占用四位，其他的20位用0补齐
              dmem_addr<= dmem_addr + 1'b1;
              if(dmem_addr >= DM_DATA_NUM)begin
                  dmem_addr<= 7'b0000000;
                  dmem_data<= 32'hFFFFFFFF;end
          end
      end
    
   //循环显示32个寄存器的内容，使用reg_addr变量进行遍历，使用reg_data接收读出的数据值
    reg[4:0]reg_addr;
    reg[31:0]reg_data;
    always@(posedge Clk_CPU or negedge rstn)begin
        if (!rstn) begin reg_addr=5'b0;end 
        else if(sw_i[13]==1'b1)
         begin 
            reg_data={{3'b0},{reg_addr[4:0]},U_RF.rf[reg_addr][23:0]};//12条指令执行的结果最多也就智慧用到24位的数据位，而表示32个寄存器需要两个数码管也就是八位，因此刚好只剩24位作为数据位，不需要用0补齐。
            reg_addr=reg_addr+ 1;
        end   
    end
    
    //循环显示ALU两个输入两个输出的值，用alu_addr变量来进行选择显示的是哪个数，用alu_disp_data来接收读出的数据
    reg[31:0]alu_disp_data;
    reg[2:0]alu_addr=3'b000;
    always@(posedge Clk_CPU or negedge rstn)begin
        if(!rstn)alu_addr<=3'b000;
        else if(alu_addr==3'b100)alu_addr<=3'b000;
        else alu_addr<=alu_addr+1;
    end
    always@(posedge Clk_CPU)begin
         case(alu_addr)
               3'b001:alu_disp_data=U_ALU.A;
               3'b010:alu_disp_data=U_ALU.B;
               3'b011:alu_disp_data=U_ALU.C;
               3'b100:alu_disp_data=U_ALU.Zero;
               default:alu_disp_data=32'hFFFFFFFF;
          endcase
    end
    
    //决定八个数码管显示的内容，使用11，12，13，14四个开关决定，并且可以用第二号开关让其暂停循环显示，默认显示的是正在执行的指令的机器码
    //使用display变量接收需要显示的值
    reg[31:0]display_data;
    always @(posedge Clk_CPU) begin
        if(sw_i[2] == 0)begin
            case (sw_i[14:11])
                4'b1000 : display_data = inst_in;
                4'b0100 : display_data = reg_data;
                4'b0010:  display_data=alu_disp_data;
                4'b0001:  display_data=dmem_data;
            default: display_data = inst_in;
            endcase
        end
    end

//将需要显示的数据送入显示模块，由其输入至八位数码管上
        seg7x16 u_seg7x16(
        .clk(clk),
        .rstn(rstn),
        .i_data(display_data),
        .disp_mode(sw_i[0]),
        .o_seg(disp_seg_o),
        .o_sel(disp_an_o)
    );
endmodule
