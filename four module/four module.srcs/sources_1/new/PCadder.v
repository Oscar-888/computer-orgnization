`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/27 10:05:45
// Design Name: 
// Module Name: PCadder
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


module PCadder(
input clk,
input[31:0]imm,
input[31:0]PC,
input[7:0]jalcontrol,
output reg [31:0]nextAddr
    );
    always@(posedge clk)
    begin
     
    if(jalcontrol==7'b1101111)
      begin nextAddr=PC+imm;end
      else begin nextAddr=PC+1'b1;end
    if (PC>= 13) begin
    nextAddr=32'b0;
    end
      end
endmodule
