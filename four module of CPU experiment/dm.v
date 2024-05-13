`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/03 20:27:29
// Design Name: 
// Module Name: dm
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
`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100

module dm(
input clk,
input DMWr,
input[5:0]addr,
input[31:0] din,
input[2:0] DMType,
output reg[31:0]dout
);
reg [7:0]dmem[127:0];
integer i;
    initial begin//Ϊdm����ֵ������i�ŵ�Ԫ��ֵΪi
    for(i=0;i<128;i=i+1)
        dmem[i]<=i;
    end
    
always@(posedge clk)begin//dm��д�ź���ʱ���źſ��ƣ���������д�롣
if(DMWr==1)
case(DMType)//�����������������в�ͬ�Ĵ洢��ʽ
   `dm_byte:dmem[addr]<=din[7:0];//dm��һ����ԪΪ8λ��һ����ǡ��Ϊ8λ�����ʹ��һ���ڴ浥Ԫ
   `dm_halfword:begin//����Ϊ�����ֽ�ռ16λ�����Ҫʹ�������������ڴ浥Ԫ
   dmem[addr]<=din[7:0];
   dmem[addr+1]<=din[15:8];end
   `dm_word:begin//��Ϊ�ĸ��ֽ�32λ�����Ҫռ���ĸ��������ڴ浥Ԫ
   dmem[addr]<=din[7:0];
   dmem[addr+1]<=din[15:8];
   dmem[addr+2]<=din[23:16];
   dmem[addr+3]<=din[31:24];end
   endcase
   end
  always@(*)begin
  case(DMType)//�����������;�����dm�ж�������λ������
  `dm_byte:dout={{24{dmem[addr][7]}},dmem[addr][7:0]};//������ֽ����ͣ�����ֻ�а�λ����dout��32λ�ļĴ����ͱ�������˶�һ���ڴ浥Ԫ���������÷�����չ����24λ
  `dm_halfword:dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};//����ǰ������ͣ�������16λ����˶������������ڴ浥Ԫ��ͬ���÷�����չ����16λ
  `dm_word:dout={dmem[addr+3][7:0],dmem[addr+2][7:0],dmem[addr+1][7:0],dmem[addr][7:0]};//����������ͣ���������32λ���պ��Ƕ��������ĸ��ڴ浥Ԫ������Ҫ��չ��
  default:dout=32'hFFFFFFFF;
  endcase
  end
   
  
endmodule
