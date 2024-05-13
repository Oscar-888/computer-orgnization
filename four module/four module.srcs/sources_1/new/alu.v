`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/03 20:27:29
// Design Name: 
// Module Name: alu
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
`define ALUOp_add 5'b00011
`define ALUOp_sub 5'b00100
`define ALUOp_auipc 5'b00010
//加减法的宏定义有区别与之前实验的宏定义，且目前的ALU仅支持加减法运算
module alu(
input signed[31:0]A,B,
input[4:0]ALUOp,
output reg signed[31:0]C,
output reg[7:0]Zero
);
always@(*) begin
case(ALUOp)
`ALUOp_add:C=A+B;
`ALUOp_sub:C=A-B;
`ALUOp_auipc:C=A+B;
endcase
Zero=(C==0)?1:0;
end
endmodule
