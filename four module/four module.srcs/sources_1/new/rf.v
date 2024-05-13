`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/03 20:27:29
// Design Name: 
// Module Name: rf
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


module rf(
    input	clk,							//100MHZ CLK
    input	rstn,							//reset signal
    input	RFWr,						//Rfwrite = mem2reg  
    input[15:0] sw_i, 		 		//sw_i[15]---sw_i[0]
    input 	[4:0] A1, A2, A3,		// Register Num 
    input 	[31:0] WD,					//Write data
    output  [31:0] RD1, RD2	//Data output port
    );
    reg[31:0] rf[31:0];
    integer i;
    //初始化和数据写入，将第i号寄存器赋值为i
  always@(posedge clk or negedge rstn)
    if(!rstn)begin
        for(i = 0;i < 32;i =i + 1)
            rf[i] <= i;
    end
    else 
     if(RFWr && (!sw_i[1])&&A3!=0) begin//当写信号有效且指令处于正常执行状态且赋值的不是零号寄存器时，正常完成写入
        rf[A3] <= WD;
        $display("r[%2d]=0x%8X",A3,WD);
        end   
   //当寄存器号为0时，其值为0，如果不是给零号寄存器赋值，则正常赋值
    assign RD1 = (A1 != 0)? rf[A1] : 0;
    assign RD2 = (A2 != 0)? rf[A2] : 0;
endmodule
