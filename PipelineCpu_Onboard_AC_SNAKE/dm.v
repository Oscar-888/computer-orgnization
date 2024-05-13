`include "ctrl_encode_def.v"
// data memory
module dm(
   input              clk,
   input              DMWr,
   input      [8:0]   addr,
   input      [31:0]  din,
   input      [2:0]   DMType,
   output reg [31:0]  dout

   );
   reg [7:0] dmem[4095:0];
          integer i = 0;
   initial begin     
        for(i = 0; i < 4096; i = i + 1) begin
            dmem[i] =0;
        end
    end
   always @(posedge clk)
      if (DMWr) begin
        case(DMType)//根据数据类型来进行不同的存储方式
             `dm_byte:
                        begin
                        dmem[addr]<=din[7:0];//dm的一个单元为8位，�?个字恰好�?8位，因此使用�?个内存单�?
                        $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                        end
             `dm_halfword:
                       begin//半字为两个字节占16位，因此要使用两个连续的内存单元
                       dmem[addr]<=din[7:0];
                       dmem[addr+1]<=din[15:8];
                        $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                        $display("dmem[%2d] = 0x%2X,", addr+1, din[15:8]);
                       end
             `dm_word:
                       begin//字为四个字节32位，因此要占用四个连续的内存单元
                       dmem[addr]<=din[7:0];
                       dmem[addr+1]<=din[15:8];
                       dmem[addr+2]<=din[23:16];
                       dmem[addr+3]<=din[31:24];
                       $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                       $display("dmem[%2d] = 0x%2X,", addr+1, din[15:8]);
                       $display("dmem[%2d] = 0x%2X,", addr+2, din[23:16]);
                       $display("dmem[%2d] = 0x%2X,", addr+3, din[31:24]);
                       end
             `dm_byte_unsigned:
             begin
             dmem[addr]<=din[7:0];
             $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
             end
             `dm_halfword_unsigned:
                       begin//半字为两个字节占16位，因此要使用两个连续的内存单元
                       dmem[addr]<=din[7:0];
                       dmem[addr+1]<=din[15:8];
                       $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                       $display("dmem[%2d] = 0x%2X,", addr+1, din[15:8]);
                       end
          endcase
            //$display("dmem[0x%8X] = 0x%8X,", addr, din);
      end
   always@(*)begin
          case(DMType)//根据数据类型决定从dm中读出多少位的数�?
               `dm_byte:             dout={{24{dmem[addr][7]}},dmem[addr][7:0]};//如果是字节类型，数据只有八位，�?�dout�?32位的寄存器型变量，因此读�?个内存单元的数据再用符号扩展填充�?24�?
               `dm_halfword:         dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};//如果是半字类型，数据�?16位，因此读两个连续的内存单元，同样用符号扩展填充�?16�?
               `dm_word:             dout={dmem[addr+3][7:0],dmem[addr+2][7:0],dmem[addr+1][7:0],dmem[addr][7:0]};//如果是字类型，则数据�?32位，刚好是读连续的四个内存单元，不需要扩展�??
               `dm_byte_unsigned:    dout<={24'b0,dmem[addr][7:0]};
               `dm_halfword_unsigned:dout<={16'b0,dmem[addr+1][7:0],dmem[addr][7:0]};
               //default:dout=32'hFFFFFFFF;
          endcase
  end
   
   //assign dout = dmem[addr[8:2]];
    
endmodule    
