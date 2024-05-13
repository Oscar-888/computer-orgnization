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
    initial begin//为dm赋初值，将第i号单元赋值为i
    for(i=0;i<128;i=i+1)
        dmem[i]<=i;
    end
    
always@(posedge clk)begin//dm的写信号受时钟信号控制，在上升沿写入。
if(DMWr==1)
case(DMType)//根据数据类型来进行不同的存储方式
   `dm_byte:dmem[addr]<=din[7:0];//dm的一个单元为8位，一个字恰好为8位，因此使用一个内存单元
   `dm_halfword:begin//半字为两个字节占16位，因此要使用两个连续的内存单元
   dmem[addr]<=din[7:0];
   dmem[addr+1]<=din[15:8];end
   `dm_word:begin//字为四个字节32位，因此要占用四个连续的内存单元
   dmem[addr]<=din[7:0];
   dmem[addr+1]<=din[15:8];
   dmem[addr+2]<=din[23:16];
   dmem[addr+3]<=din[31:24];end
   endcase
   end
  always@(*)begin
  case(DMType)//根据数据类型决定从dm中读出多少位的数据
  `dm_byte:dout={{24{dmem[addr][7]}},dmem[addr][7:0]};//如果是字节类型，数据只有八位，而dout是32位的寄存器型变量，因此读一个内存单元的数据再用符号扩展填充高24位
  `dm_halfword:dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};//如果是半字类型，数据有16位，因此读两个连续的内存单元，同样用符号扩展填充高16位
  `dm_word:dout={dmem[addr+3][7:0],dmem[addr+2][7:0],dmem[addr+1][7:0],dmem[addr][7:0]};//如果是字类型，则数据有32位，刚好是读连续的四个内存单元，不需要扩展。
  default:dout=32'hFFFFFFFF;
  endcase
  end
   
  
endmodule
