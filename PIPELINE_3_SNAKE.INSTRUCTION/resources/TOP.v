`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/20 16:49:16
// Design Name: 
// Module Name: top
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

module top(
input rstn,
input [4:0]btn_i,
input [15:0]sw_i,
input clk,

output[7:0] disp_an_o,
output[7:0] disp_seg_o,

output [15:0]led_o
);

wire Clk_CPU, rst, CPU_MIO, mem_w, counter0_out;
wire [31:0] inst_in, Data_in_CPU, PC, Addr_out, Data_out;
wire [2:0] dm_ctrl;

assign rst = ~rstn;

SCPU U1_SCPU(.clk(Clk_CPU),			// 
                .reset(rst),	
                .inst_in(inst_in),
                .Data_in(Data_in_CPU),	
                //.MIO_ready(CPU_MIO),
                //.CPU_MIO(CPU_MIO),
                .mem_w(mem_w),
                .PC_out(PC),
                .Addr_out(Addr_out),
                .Data_out(Data_out), 
                .DMType(dm_ctrl)
                //.INT(counter0_out)
                );

ROM_D U2_ROMD(.a(PC[11:2]),
                .spo(inst_in)
                );

wire [31:0] dina,Data_in,dina_dm;
wire [3:0] wea;

dm_controller U3_dm_controller(.mem_w(mem_w),
                                .Addr_in(Addr_out),
                                .Data_write(dina),
                                .dm_ctrl(dm_ctrl),
                                .Data_read_from_dm(Data_in),
                                .Data_read(Data_in_CPU),
                                .Data_write_to_dm(dina_dm),
                                .wea_mem(wea));

wire [31:0] addra, douta;

RAM_B U3_RAM_B(.addra(addra),
                .wea(wea),
                .dina(dina_dm),
                .clka(~clk),
                .douta(douta));

wire [4:0] BTN_OK;
wire [15:0] SW_OK, LED_out;
wire [31:0] counter_out;
wire counter1_out, counter2_out;
wire wea_mio, GPIOF0, GPIOE0, counter_we;
wire [31:0] CPU2IO;

MIO_BUS U4_MIO_BUS(.clk(clk),
                    .rst(rst),
                    .BTN(BTN_OK),
                    .SW(SW_OK),
                    .mem_w(mem_w),
                    .Cpu_data2bus(Data_out),
                    .addr_bus(Addr_out),
                    .ram_data_out(douta),
                    .led_out(LED_out),
                    .counter_out(counter_out),
                    .counter0_out(counter0_out),
                    .counter1_out(counter1_out),
                    .counter2_out(counter2_out),
                    .PC(PC),
                    .Cpu_data4bus(Data_in),
                    .ram_data_in(dina),
                    .ram_addr(addra),
                    .data_ram_we(wea_mio),
                    .GPIOf0000000_we(GPIOF0),
                    .GPIOe0000000_we(GPIOE0),
                    .counter_we(counter_we),
                    .Peripheral_in(CPU2IO));

wire IO_clk;
wire [31:0] div;
wire [7:0] point_out, LE_out;
wire [31:0] Disp_num;

assign IO_clk = ~Clk_CPU; 

Multi_8CH32 U5_Multi_8CH32(.clk(IO_clk),
                            .rst(rst),
                            .EN(GPIOE0),
                            .Switch(SW_OK[7:5]),
                            .point_in({div[31:0],div[31:0]}),
                            .LES(~64'h00000000),
                            .data0(CPU2IO),
                            .data1({1'b0,1'b0,PC[31:2]}),
                            .data2(inst_in),
                            .data3(counter_out),
                            .data4(Addr_out),
                            .data5(Data_out),
                            .data6(Data_in),
                            .data7(PC),
                            .point_out(point_out),
                            .LE_out(LE_out),
                            .Disp_num(Disp_num));



SSeg7 U6_SSeg7(.clk(clk),
                .rst(rst),
                .SW0(SW_OK[0]),
                .flash(div[10]),
                .Hexs(Disp_num),
                .point(point_out),
                .LES(LE_out),
                .seg_an(disp_an_o),
                .seg_sout(disp_seg_o));

wire [1:0] counter_ch;
wire [13:0] GPIOfO_o;

SPIO U7_SPIO(.clk(IO_clk),
                .rst(rst),
                .EN(GPIOF0),
                .P_Data(CPU2IO),
                .counter_set(counter_ch),
                .LED_out(LED_out),
                .led(led_o),
                .GPIOf0(GPIOfO_o)
    );

clk_div U8_clk_div(.clk(clk),
    .rst(rst),
    .SW2(SW_OK[2]),
    .clkdiv(div),
    .Clk_CPU(Clk_CPU));

Counter_x U9_Counter_x(.clk(IO_clk),
                        .rst(rst),
                        .clk0(div[6]),
                        .clk1(div[9]),
                        .clk2(div[11]),
                        .counter_we(counter_we),
                        .counter_val(CPU2IO),
                        .counter_ch(counter_ch),

                        .counter0_OUT(counter0_out),
                        .counter1_OUT(counter1_out),
                        .counter2_OUT(counter2_out),
                        .counter_out(counter_out));

Enter U10_Enter(.clk(clk),
                .BTN(btn_i),
                .SW(sw_i),
                .BTN_out(BTN_OK),
                .SW_out(SW_OK));
endmodule
