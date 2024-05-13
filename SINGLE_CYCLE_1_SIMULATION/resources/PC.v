module PC( clk, rst, NPC, PC );

  input              clk;
  input              rst;
  input       [31:0] NPC;//from theNOC module to decide the next instruction
  output reg  [31:0] PC; //the instruction to be executed next clock

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else
      PC <= NPC;//use the output from NPC to fetch the PC of the next instruction
      
endmodule

