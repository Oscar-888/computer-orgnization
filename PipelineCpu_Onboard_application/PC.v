module PC( clk, rst, NPC, PC,IS_STALL);

  input              clk;
  input              rst;
  input              IS_STALL;

  input       [31:0] NPC;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else
      begin
        if(IS_STALL)PC<=PC;//if the current instrcution is stalled, the pc should not change
      else 
        begin 
           PC <= NPC; //if the current instruction is not stalled, the pc change to next pc
        end
      end
endmodule

