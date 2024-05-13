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
//�˺궨��Ϊд������ѡ�����Ŀ����ź�
module SCPU_TOP(
    input clk,  //100MHZ CLK
    input rstn,  //reset signal
    input [15:0] sw_i, //sw_i[15]---sw_i[0] 
    output [7:0] disp_an_o, //8λ�����λѡ
    output [7:0] disp_seg_o //�����8������
    );
    reg[31:0] clkdiv;
    wire Clk_CPU;
    //��Ƶ
    always @(posedge clk or negedge rstn) begin
        if(!rstn) clkdiv <= 0;
        else clkdiv <= clkdiv + 1'b1; 
    end
    //sw_i[15]ѡ������ģʽ�����ģʽ,��������ϵ����2��27�η�����������2��25�η����죩����Ƶ/��Ƶϵ��=ˢ��Ƶ��
    assign Clk_CPU = (sw_i[15])? clkdiv[27] : clkdiv[25];
    //ȡָ����instr��
    wire[31:0]inst_in;
    reg[31:0]rom_addr;
    reg[6:0] Op;
    wire[31:0]immout;
    reg PCSRC;
    //romÿ���ڵ�ַ˳��ȡ��
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
    //��coe�ļ��а���ַȡֵ
    dist_mem_gen_0 u_im(
        .a(rom_addr),
        .spo(inst_in)
    );
//ָ������
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
        iimm=inst_in[31:20];//addi ָ����������lwָ��������
        simm={inst_in[31:25],inst_in[11:7]}; //swָ��������  
        uimm=inst_in[31:12];
        jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
    end
    always@(*)begin
    case(Op)
     //7'b1101111:PCSRC=1'b1;
      default:PCSRC=1'b0;
      endcase
    end
  //�����ź�����
  wire Zero;
  wire RegWrite;
  wire[5:0]EXTOp;    
  wire[4:0] ALUOp;    
  wire ALUSrc;   
  wire[2:0] DMType; 
  wire WDSel;
  wire MemWrite;
  //���������ź�ģ��
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
  //rfģ�����������ΪRD1,RD2��������������
  wire[31:0]RD1;
  wire[31:0]RD2;
  reg signed [31:0] WD;
  rf U_RF(.clk(Clk_CPU),.rstn(rstn),.RFWr(RegWrite),.sw_i(sw_i[15:0]),.A1(rs1),.A2(rs2),.A3(rd),.WD(WD),.RD1(RD1),.RD2(RD2));
  //������չģ��������ʹ��immout��Ϊ���շ�����չģ������
  
  wire[4:0] iimm_shamt; 
  wire bimm;
  

  EXT U_EXT(.iimm(iimm),.simm(simm),.EXTOp(EXTOp),.immout(immout),.iimm_shamt(iimm_shamt),.bimm(bimm),.uimm(uimm),.jimm(jimm));
  //ΪALUģ��ѡ��ڶ��������������ݿ����ź�ALUOp��ֵ�������ǼĴ�����ֵ������������չ��Ľ����Ϊ�ڶ���������
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
  //aluģ���ʼ����ʹ��aluout��Zero��������alu�����
  wire [31:0]aluout;
  alu U_ALU(.A(A),.B(B),.ALUOp(ALUOp),.C(aluout),.Zero(Zero));
  //dmģ���ʼ����ʹ��dout��������dmģ������
  wire signed[31:0]dout;
  dm U_DM(.DMType(DMType),.clk(Clk_CPU),.addr(aluout),.din(RD2),.DMWr(MemWrite),.dout(dout));
  //����д������ѡ����������д�ص�����������alu�Ľ����������dm�Ľ��
  always@(*)
  begin
	  case(WDSel)
		  `WDSel_FromALU: WD<=aluout;
		  `WDSel_FromMEM: WD<=dout;
		  `WDSel_FromPC: WD<=rom_addr+1;
	  endcase
  end

  //ѭ����ʾdm��ǰ16����Ԫ��ʹ��dmem_addr���б�����ʹ��dmem_data���ն���������
  reg[31:0]dmem_data;
  reg[31:0]dmem_addr;
  parameter DM_DATA_NUM=16;
   always @(posedge Clk_CPU or negedge rstn) begin
          if(!rstn) begin  
              dmem_addr<= 7'b000000;
              dmem_data<= 32'hFFFFFFFF; end
          else if(sw_i[11]==1'b1)begin   
              dmem_data = {dmem_addr[3:0],{20'b0},U_DM.dmem[dmem_addr][7:0]};//ÿ���ڴ浥ԪΪ8λ��ռ����źŵİ�λ����һ����Ҫ��ʾ16��ģ�飬ʹ��1������ܱ�ʾ���ɹ�ռ����λ��������20λ��0����
              dmem_addr<= dmem_addr + 1'b1;
              if(dmem_addr >= DM_DATA_NUM)begin
                  dmem_addr<= 7'b0000000;
                  dmem_data<= 32'hFFFFFFFF;end
          end
      end
    
   //ѭ����ʾ32���Ĵ��������ݣ�ʹ��reg_addr�������б�����ʹ��reg_data���ն���������ֵ
    reg[4:0]reg_addr;
    reg[31:0]reg_data;
    always@(posedge Clk_CPU or negedge rstn)begin
        if (!rstn) begin reg_addr=5'b0;end 
        else if(sw_i[13]==1'b1)
         begin 
            reg_data={{3'b0},{reg_addr[4:0]},U_RF.rf[reg_addr][23:0]};//12��ָ��ִ�еĽ�����Ҳ���ǻ��õ�24λ������λ������ʾ32���Ĵ�����Ҫ���������Ҳ���ǰ�λ����˸պ�ֻʣ24λ��Ϊ����λ������Ҫ��0���롣
            reg_addr=reg_addr+ 1;
        end   
    end
    
    //ѭ����ʾALU�����������������ֵ����alu_addr����������ѡ����ʾ�����ĸ�������alu_disp_data�����ն���������
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
    
    //�����˸��������ʾ�����ݣ�ʹ��11��12��13��14�ĸ����ؾ��������ҿ����õڶ��ſ���������ͣѭ����ʾ��Ĭ����ʾ��������ִ�е�ָ��Ļ�����
    //ʹ��display����������Ҫ��ʾ��ֵ
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

//����Ҫ��ʾ������������ʾģ�飬������������λ�������
        seg7x16 u_seg7x16(
        .clk(clk),
        .rstn(rstn),
        .i_data(display_data),
        .disp_mode(sw_i[0]),
        .o_seg(disp_seg_o),
        .o_sel(disp_an_o)
    );
endmodule
