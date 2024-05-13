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
    //��ʼ��������д�룬����i�żĴ�����ֵΪi
  always@(posedge clk or negedge rstn)
    if(!rstn)begin
        for(i = 0;i < 32;i =i + 1)
            rf[i] <= i;
    end
    else 
     if(RFWr && (!sw_i[1])&&A3!=0) begin//��д�ź���Ч��ָ�������ִ��״̬�Ҹ�ֵ�Ĳ�����żĴ���ʱ���������д��
        rf[A3] <= WD;
        $display("r[%2d]=0x%8X",A3,WD);
        end   
   //���Ĵ�����Ϊ0ʱ����ֵΪ0��������Ǹ���żĴ�����ֵ����������ֵ
    assign RD1 = (A1 != 0)? rf[A1] : 0;
    assign RD2 = (A2 != 0)? rf[A2] : 0;
endmodule
