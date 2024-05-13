`include "ctrl_encode_def.v"
// data memory
module dm(
    input              clk,
   input              DMWr,  //to decide whether write  operation is permitted
   input      [8:0]   addr,  //to decide where data is to be written,since the address is 9bits, it can only access 2^9=512 dm units
   input      [31:0]  din,   //the data to write
   input      [2:0]   DMType,//decide write module is byte/2bytes/4bytes
   output reg [31:0]  dout   //output of dm module
   );
   // declaration for  data memory units, each unit contain 8bits
   reg [7:0] dmem[127:0];
   // so that if read/write for 1 byte             that's 1 dm unit
   //         if read/write for 2 byte (half word) that's 2 dm unit
   //         if read/write for 4 byte (   word  ) that's 4 dm unit
   //for the UNSIGNED/SIGNED question: when LOAD instruction SIGNED is the same as the UNSIGNED
   //when SAVE instruction:
   //while dout is 32 bits register
   //SIGNED  :if data is less than 32 bits, the left bits are filled with the signed bit
   //UNSIGNED:if data is less than 32 bits, the left bits are filled with "0"
   always @(posedge clk)
      if (DMWr) begin
        case(DMType)// according to the DMTYPE to choose which save module is used
             `dm_byte:
                        begin
                        dmem[addr]<=din[7:0];// 1 dm unit is 8 bits,1 byte
                        $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                        end
             `dm_halfword:
                       begin//1 dm unit is 8 bits, halfword need 2 continous dm units 
                       dmem[addr]<=din[7:0];
                       dmem[addr+1]<=din[15:8];
                        $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                        $display("dmem[%2d] = 0x%2X,", addr+1, din[15:8]);
                       end
             `dm_word:
                       begin//1 dm unit is 8 bits, word need 4 continous dm units
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
             begin//the same as before byte talk about 
             dmem[addr]<=din[7:0];
             $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
             end
             `dm_halfword_unsigned:
                       begin//the same as before halfword talk about
                       dmem[addr]<=din[7:0];
                       dmem[addr+1]<=din[15:8];
                       $display("dmem[%2d] = 0x%2X,", addr, din[7:0]);
                       $display("dmem[%2d] = 0x%2X,", addr+1, din[15:8]);
                       end
          endcase
            //$display("dmem[0x%8X] = 0x%8X,", addr, din);
      end
   always@(*)begin
          case(DMType)//according to DMTYPE to decide how much data is read out from dm
               `dm_byte:dout={{24{dmem[addr][7]}},dmem[addr][7:0]};                                  //    byte signed, so 24bits signal+8 bits data
               `dm_halfword:dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};          //halfword signed, so 16bits signal+16bits data
               `dm_word:dout={dmem[addr+3][7:0],dmem[addr+2][7:0],dmem[addr+1][7:0],dmem[addr][7:0]};//    word signed, so 0 bits signal+32bits data
               `dm_byte_unsigned:dout<={24'b0,dmem[addr]};                                           //    byte unsigned, so 24bits 0+8 bits data
               `dm_halfword_unsigned:dout<={16'b0,dmem[addr+1],dmem[addr]};                          //halfword unsigned, so 16bits 0+16bits data
               //default:dout=32'hFFFFFFFF;
          endcase
  end
   
   //assign dout = dmem[addr[8:2]];
    
endmodule    
