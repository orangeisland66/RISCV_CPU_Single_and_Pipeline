`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/19 15:36:30
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
input clk,
input rstn,
input  [4:0]btn_i,
input [15:0]sw_i,
output [7:0]disp_an_o,
output [7:0]disp_seg_o,
output [15:0]led_o
    );
//U1_SCPU
wire [31:0]Addr_out;
wire CPU_MIO;
wire [31:0]Data_out;
wire [31:0]PC_out;
wire [2:0]dm_ctrl;
wire mem_w;
//U2_ROMD
wire [31:0] spo;
//U3_dm_controller
wire [31:0] Data_read;
wire [31:0] Data_write_to_dm;
wire [3:0] wea_mem;

//U4_RAM_B
wire [31:0] douta;

//U4_MIO_BUS
wire [31:0]Cpu_data4bus;
wire GPIOe0000000_we;
wire GPIOf0000000_we;
wire [31:0] Peripheral_in;
wire counter_we;
wire [9:0]ram_addr;
wire [31:0]ram_data_in;
//U5_Multi_8CH32
wire [31:0]Disp_num;
wire [7:0] LE_out;
wire [7:0]point_out;
//U6_SSeg7
wire [7:0]seg_an;
wire [7:0]seg_sout;
//U7_SPIO
wire [15:0] LED_out;
wire [1:0] counter_set;
//U8_clk_div
wire Clk_CPU;
wire [31:0] clkdiv;
//U9_Counter_x
wire counter0_OUT;
wire counter1_OUT;
wire counter2_OUT;
//U10_Enter
wire [4:0] BTN_out;
wire [15:0] SW_out;

//U1_SCPU
SCPU1 U1_SCPU1(
    .Data_in(Data_read),
    .INT(counter0_OUT),
    .MIO_ready(CPU_MIO),
    .clk(Clk_CPU),
    .inst_in(spo),
    .reset(~rstn),
    .Addr_out(Addr_out),
    .CPU_MIO(CPU_MIO),
    .Data_out(Data_out),
    .PC_out(PC_out),
    .DMType(dm_ctrl),
    .mem_w(mem_w)
);

//U2_ROMD
dist_mem_gen_0 U2_ROMD(
    .a(PC_out[11:2]),
    .spo(spo)
);
//.a(PC_out[11:2]),???
//U3_dm_controller
dm_control U3_dm_control(
    .Addr_in(Addr_out),
    .Data_read_from_dm(Cpu_data4bus),
    .Data_write(ram_data_in),
    .dm_ctrl(dm_ctrl),
    .mem_w(mem_w),
    .Data_read(Data_read),
    .Data_write_to_dm(Data_write_to_dm),
    .wea_mem(wea_mem)
);

//U4_RAM_B
blk_mem_gen_0 U4_RAM_B(
    .addra(ram_addr),
    .clka(~clk),
    .dina(Data_write_to_dm),
    .wea(wea_mem),
    .douta(douta)
);
//U4_MIO_BUS
MIO_BUS U4_MIO_BUS(
//    .PC(32'h0),//¼ÓµÄ
    .BTN(BTN_out),
    .Cpu_data2bus(Data_out),
    .SW(SW_out),
    .addr_bus(Addr_out),
    .clk(clk),
    .counter_out(32'h0000),
    .counter0_out(counter0_OUT),
    .counter1_out(counter1_OUT),
    .counter2_out(counter2_OUT),
    .led_out(LED_out),
    .mem_w(mem_w),
    .ram_data_out(douta[31:0]),
    .rst(~rstn),
    .Cpu_data4bus(Cpu_data4bus),
    .GPIOe0000000_we(GPIOe0000000_we),
    .GPIOf0000000_we(GPIOf0000000_we),
    .Peripheral_in(Peripheral_in),
    .counter_we(counter_we),
    .ram_addr(ram_addr),
    .ram_data_in(ram_data_in)
    
);
//U5_Multi_8CH32
Multi_8CH32 U5_Multi_8CH32(
    .clk(~Clk_CPU),
    .rst(~rstn),
    .EN(GPIOe0000000_we),
    .Switch(SW_out[7:5]),
    .point_in({clkdiv[31:0], clkdiv[31:0]}),
    .LES(~64'h00000000),
    .data0(Peripheral_in),
    .data1({1'b0, 1'b0, PC_out[31:2]}),
    .data2(spo),
    .data3(32'h0000),
    .data4(Addr_out),
    .data5(Data_out),
    .data6(Cpu_data4bus),
    .data7(PC_out),
    .point_out(point_out),
    .LE_out(LE_out),
    .Disp_num(Disp_num)
);
    

//U6_SSeg7
SSeg7 U6_SSeg7(
    .Hexs(Disp_num),
    .LES(LE_out),
    .SW0(SW_out[0]),
    .clk(clk),
    .flash(clkdiv[10]),
    .point(point_out),
    .rst(~rstn),
    .seg_an(disp_an_o),
    .seg_sout(disp_seg_o)
);

//U7_SPIO
SPIO U7_SPIO(
        .EN(GPIOf0000000_we),
        .P_Data(Peripheral_in),
        .clk(~Clk_CPU),
        .rst(~rstn),
        .LED_out(LED_out),
        .counter_set(counter_set),
        .led(led_o)
 );
 
//U8_clk_div
clk_div U8_clk_div(
        .SW2(SW_out[2]),
        .clk(clk),
        .rst(~rstn),
        .Clk_CPU(Clk_CPU),
        .clkdiv(clkdiv)
);
//U9_Counter_x
Counter_x U9_Counter_x(
    
    .clk(~Clk_CPU),
    .clk0(clkdiv[6]),
    .clk1(clkdiv[9]),
    .clk2(clkdiv[11]),
    .counter_ch(counter_set),
    .counter_val(Peripheral_in),
    .counter_we(counter_we),
    .counter0_OUT(counter0_OUT),
    .counter1_OUT(counter1_OUT),
    .counter2_OUT(counter2_OUT),
    .rst(~rstn)
    
);


// U10_Enter
Enter U10_Enter(
    .clk(clk),
    .BTN(btn_i),
    .SW(sw_i),
    .BTN_out(BTN_out),
    .SW_out(SW_out)
);

endmodule
////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////
////// Company: 
////// Engineer: 
////// 
////// Create Date: 2025/02/19 15:33:32
////// Design Name: 
////// Module Name: top
////// Project Name: 
////// Target Devices: 
////// Tool Versions: 
////// Description: 
////// 
////// Dependencies: 
////// 
////// Revision:
////// Revision 0.01 - File Created
////// Additional Comments:
////// 
//////////////////////////////////////////////////////////////////////////////////////


////module top(
////   input clk,
////   input rstn,
////   input [4:0]btn_i,
////   input [15:0]sw_i,
////   output [7:0]disp_an_o,
////   output [7:0]disp_seg_o,
////   output [15:0]led_o
////   );

////   // U1_SCPU
////   wire [31:0]Addr_out;
////   wire CPU_MIO,mem_w;
////   wire [31:0]Data_out;
////   wire [31:0]PC_out;
////   wire [2:0]dm_ctrl;

////   // U2_ROM_D
////   wire [31:0]spo;

////   // U3_dm_controller
////   wire [31:0]Data_read;
////   wire [31:0]Data_write_to_dm;
////   wire [3:0]wea_mem;

////   // U4_RAM_B
////   wire [31:0]douta;

////   // U4_MIO_BUS
////   wire [31:0]Cpu_data4bus;
////   wire GPIOf0000000_we,GPIOe0000000_we,counter_we;
////   wire [31:0]Peripheral_in;
////   wire [9:0]ram_addr;
////   wire [31:0]ram_data_in;

////   // U5_Multi_8CH32
////   wire [31:0]Disp_num;
////   wire [7:0]LE_out;
////   wire [7:0]point_out;

////   // U6_SSeg7
////   // wire [7:0]seg_an=disp_an_o;
////   // wire [7:0]seg_sout=disp_seg_o;

////   // U7_SPIO
////   wire [15:0]LED_out;
////   wire [1:0]counter_set;
////   // wire [15:0]led=led_o;

////   // U8_clk_div
////   wire Clk_CPU;
////   wire [31:0]clkdiv;

////   // U9_Counter_x
////   wire counter0_OUT,counter1_OUT,counter2_OUT;

////   // U10_Enter
////   wire [15:0]SW_out;
////   wire [4:0]BTN_out;

////   // RTL_INV  not
////   wire rst=~rstn;
////   wire IO_clk=~Clk_CPU;
////   wire clka0=~clk;
    
////  SCPU U1_SCPU(
////   .Data_in(Data_read),
////   .INT(counter0_OUT),
////   .MIO_ready(CPU_MIO),
////   .clk(Clk_CPU),
////   .inst_in(spo),
////   .reset(rst),

////   .Addr_out(Addr_out),
////   .CPU_MIO(CPU_MIO),
////   .Data_out(Data_out),
////   .PC_out(PC_out),
////   .dm_ctrl(dm_ctrl),
////   .mem_w(mem_w)
////  ); 
    
//// dist_mem_gen_0 U2_ROM_D(
////   .a(PC_out[11:2]),

////   .spo(spo)
////   );
    
////  dm_controller U3_dm_controller(
////   .Addr_in(Addr_out),
////   .Data_read_from_dm(Cpu_data4bus),
////   .Data_write(ram_data_in),
////   .dm_ctrl(dm_ctrl),
////   .mem_w(mem_w),
////   .Data_read(Data_read),
////   .Data_write_to_dm(Data_write_to_dm),
////   .wea_mem(wea_mem)
////   );
    
////blk_mem_gen_0 U4_RAM_B(
////   .addra(ram_addr),
////   .clka(clka0),
////   .dina(Data_write_to_dm),
////   .wea(wea_mem),
    
////   .douta(douta)
////   );
    
////  MIO_BUS U4_MIO_BUS(
////   .BTN(BTN_out),
////   .Cpu_data2bus(Data_out),
////   .SW(SW_out),
////   .addr_bus(Addr_out),
////   .clk(clk),
////   .counter_out(32'h0000),
////   .counter0_out(counter0_OUT),
////   .counter1_out(counter1_OUT),
////   .counter2_out(counter2_OUT),
////   .led_out(LED_out),
////   .mem_w(mem_w),
////   .ram_data_out(douta),
////   .rst(rst),

////   .Cpu_data4bus(Cpu_data4bus),
////   .GPIOf0000000_we(GPIOf0000000_we),
////   .GPIOe0000000_we(GPIOe0000000_we),
////   .counter_we(counter_we),
////   .Peripheral_in(Peripheral_in),
////   .ram_addr(ram_addr),
////   .ram_data_in(ram_data_in)
////   );
    
////  Multi_8CH32 U5_Multi_8CH32(
////   .clk(IO_clk),
////   .rst(rst),
////   .EN(GPIOf0000000_we),
////   .Switch(SW_out[7:5]),
////   .point_in({clkdiv[31:0], clkdiv[31:0]}),
////   .LES(~64'h00000000),
////   .data0(Peripheral_in),
////   .data1({1'b0,1'b0,PC_out[31:2]}),
////   .data2(spo),
////   .data3(32'h0000),
////   .data4(Addr_out),
////   .data5(Data_out),
////   .data6(Cpu_data4bus),
////   .data7(PC_out),

////   .point_out(point_out),
////   .LE_out(LE_out),
////   .Disp_num(Disp_num)
////); 

////SSeg7 U6_SSeg(
////   .Hexs(Disp_num),
////   .LES(LE_out),
////   .SW0(SW_out[0]),
////   .clk(clk),
////   .flash(clkdiv[10]),
////   .point(point_out),
////   .rst(rst),

////   .seg_an(disp_an_o),
////   .seg_sout(disp_seg_o)
////   );

////SPIO U7_SPIO(
////   .EN(GPIOf0000000_we),
////   .P_Data(Peripheral_in),
////   .clk(IO_clk),
////   .rst(rst),

////   .LED_out(LED_out),
////   .counter_set(counter_set),
////   .led(led_o)
////);

////clk_div U8_clk_div(
////                    .clk(clk),
////					.rst(rst),
////					.SW2(SW_out[2]),

////					.clkdiv(clkdiv),
////					.Clk_CPU(Clk_CPU)
////					);

////   Counter_x U9_Counter_x(
////                    .clk(IO_clk),
////					.rst(rst),
////					.clk0(clkdiv[6]),
////					.clk1(clkdiv[9]),
////					.clk2(clkdiv[11]),
////					.counter_we(counter_we),
////					.counter_val(Peripheral_in),
////					.counter_ch(counter_set),

////					.counter0_OUT(counter0_OUT),
////					.counter1_OUT(counter1_OUT),
////					.counter2_OUT(counter2_OUT)
////					);
					
					
////	Enter U10_Enter(
////	           .clk(clk),
////               .BTN(btn_i),
////               .SW(sw_i), 

////               .BTN_out(BTN_out),
////               .SW_out(SW_out) 
////           );
    
////endmodule
//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2025/02/19 15:40:14
//// Design Name: 
//// Module Name: top
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module top(
//    input [4:0] btn_i,
//    input [15:0] sw_i,
//    input clk,
//    input rstn,
//    output [7:0] disp_an_o,
//    output [7:0] disp_seg_o,
//    output [15:0] led_o
//    );
    
//    // U10_Enter
//    wire [4:0] BTN_out;
//    wire [15:0] SW_out;
    
//    // U8_clk_div
//    wire Clk_CPU;
//    wire [31:0] clkdiv;
     
//    // U7_SPIO
//    wire [15:0] LED_out;
//    wire [1:0] counter_set;
//    wire [15:0] led;
    
//    // U3_dm_controller
//    wire [31:0] Data_read;
//    wire [31:0] Data_write_to_dm;
//    wire [3:0] wea_mem;

//    //U2_ROMD
//    wire [31:0] spo;
    
//    //U9_Counter_x
//    wire counter0_OUT;
//    wire counter1_OUT;
//    wire counter2_OUT;
    
//    //U4_RAM_B
//    wire [31:0] douta;
    
//    //U1_SCPU
//    wire [31:0] Addr_out;
//    wire CPU_MIO;
//    wire [31:0] Data_out;
//    wire [31:0] PC_out;
//    wire [2:0] dm_ctrl;
//    wire mem_w;
    
//    //U4_MIO_BUS
//    wire [31:0] Cpu_data4bus;
//    wire [31:0] ram_data_in;
//    wire [9:0] ram_addr;
//    wire data_ram_we;
//    wire GPIOf0000000_we;
//    wire GPIOe0000000_we;
//    wire counter_we;
//    wire [31:0] Peripheral_in;
    
//    //U5_Multi_8CH32
//    wire [7:0] point_out;
//    wire [7:0] LE_out;
//    wire [31:0] Disp_num;

//    //U6_SSeg7
//    wire [7:0] seg_an;
//    wire [7:0] seg_sout;   
    
////U1_SCPU
//SCPU U1_SCPU(
//    .Data_in(Data_read),
//    .INT(counter0_OUT),
//    .MIO_ready(CPU_MIO),
//    .clk(Clk_CPU),
//    .inst_in(spo),
//    .reset(~rstn),
//    .Addr_out(Addr_out),
//    .CPU_MIO(CPU_MIO),
//    .Data_out(Data_out),
//    .PC_out(PC_out),
//    .dm_ctrl(dm_ctrl),
//    .mem_w(mem_w)
//);

//dist_mem_gen_0 U2_ROMD(
//    .a(PC_out[11:2]),
//    .spo(spo)
//);

////U3_dm_controller
//dm_controller U3_dm_controller(
//    .Addr_in(Addr_out),
//    .Data_read_from_dm(Cpu_data4bus),
//    .Data_write(ram_data_in),
//    .dm_ctrl(dm_ctrl),
//    .mem_w(mem_w),
//    .Data_read(Data_read),
//    .Data_write_to_dm(Data_write_to_dm),
//    .wea_mem(wea_mem)
//);

////U4_RAM_B
//blk_mem_gen_0 U4_RAM_B(
//    .addra(ram_addr),
//    .clka(clk),
//    .dina(Data_write_to_dm),
//    .wea(wea_mem),
//    .douta(douta)
//);
////U4_MIO_BUS
//MIO_BUS U4_MIO_BUS(
//    .BTN(BTN_out),
//    .Cpu_data2bus(Data_out),
//    .SW(SW_out),
//    .addr_bus(Addr_out),
//    .clk(clk),
//    .counter_out(32'h0000),
//    .counter0_out(counter0_OUT),
//    .counter1_out(counter1_OUT),
//    .counter2_out(counter2_OUT),
//    .led_out(LED_out),
//    .mem_w(mem_w),
//    .ram_data_out(douta[31:0]),
//    .rst(~rstn),
//    .Cpu_data4bus(Cpu_data4bus),
//    .GPIOe0000000_we(GPIOe0000000_we),
//    .GPIOf0000000_we(GPIOf0000000_we),
//    .Peripheral_in(Peripheral_in),
//    .counter_we(counter_we),
//    .ram_addr(ram_addr),
//    .ram_data_in(ram_data_in)
    
//);
////U5_Multi_8CH32
//Multi_8CH32 U5_Multi_8CH32(
//    .clk(~Clk_CPU),
//    .rst(~rstn),
//    .EN(GPIOe0000000_we),
//    .Switch(SW_out[7:5]),
//    .point_in({clkdiv[31:0], clkdiv[31:0]}),
//    .LES(~64'h00000000),
//    .data0(Peripheral_in),
//    .data1({1'b0, 1'b0, PC_out[31:2]}),
//    .data2(spo),
//    .data3(32'h0000),
//    .data4(Addr_out),
//    .data5(Data_out),
//    .data6(Cpu_data4bus),
//    .data7(PC_out),
//    .point_out(point_out),
//    .LE_out(LE_out),
//    .Disp_num(Disp_num)
//);
    

////U6_SSeg7
//SSeg7 U6_SSeg7(
//    .Hexs(Disp_num),
//    .LES(LE_out),
//    .SW0(SW_out[0]),
//    .clk(clk),
//    .flash(clkdiv[10]),
//    .point(point_out),
//    .rst(~rstn),
//    .seg_an(disp_an_o),
//    .seg_sout(disp_seg_o)
//);

////U7_SPIO
//SPIO U7_SPIO(
//        .EN(GPIOf0000000_we),
//        .P_Data(Peripheral_in),
//        .clk(~Clk_CPU),
//        .rst(~rstn),
//        .LED_out(LED_out),
//        .counter_set(counter_set),
//        .led(led_o)
// );
 
////U8_clk_div
//clk_div U8_clk_div(
//        .SW2(SW_out[2]),
//        .clk(clk),
//        .rst(~rstn),
//        .Clk_CPU(Clk_CPU),
//        .clkdiv(clkdiv)
//);
////U9_Counter_x
//Counter_x U9_Counter_x(
//    .clk(~Clk_CPU),
//    .clk0(clkdiv[6]),
//    .clk1(clkdiv[9]),
//    .clk2(clkdiv[11]),
//    .counter_ch(counter_set),
//    .counter_val(Peripheral_in),
//    .counter_we(counter_we),
//    .rst(!rstn),
//    .counter0_OUT(counter0_OUT),
//    .counter1_OUT(counter1_OUT),
//    .counter2_OUT(counter2_OUT)
//);

////U10_Enter
//Enter U10_Enter(
//    .BTN(btn_i),
//    .SW(sw_i),
//    .clk(clk),
//    .BTN_out(BTN_out),
//    .SW_out(SW_out)
//    );
//endmodule
//`timescale 1ns / 1ps

//module top(
//input rstn,
//input [4:0]btn_i,
//input [15:0]sw_i,
//input clk,

//output[7:0] disp_an_o,
//output[7:0] disp_seg_o,

//output [15:0]led_o
//);

//// U10_Enter
//wire[4:0] BTN_Enter;
//wire[15:0] SW_Enter;
//wire[4:0] BTN_out;
//wire[15:0] SW_out;

//// U8_clk_div
//wire SW2;
//wire Clk_CPU;
//wire[31:0] clkdiv;

//// U7_SPIO
//wire EN_SPIO;
//wire[31:0] P_Data;
//wire[15:0] LED_out;
//wire[1:0] counter_set;
//wire[15:0] led;

//// U9_Counter_x
//wire clk0;
//wire clk1;
//wire clk2;
//wire[1:0] counter_ch;
//wire[31:0] counter_val;
//wire counter_we_Counter;
//wire counter0_OUT;
//wire counter1_OUT;
//wire counter2_OUT;

//// U3_dm_controller
//wire[31:0] Addr_in;
//wire[31:0] Data_read_from_dm;
//wire[31:0] Data_write;
//wire[2:0] dm_ctrl_1;
//wire mem_w_control;
//wire[31:0] Data_read;
//wire[31:0] Data_write_to_dm;
//wire[3:0] wea_mem;

//// U2_ROMD
//wire[9:0] a;
//wire[31:0] spo;

//// U4_RAM_B
//wire[9:0] addra;
//wire[31:0] dina;
//wire[3:0] wea;
//wire[31:0] douta;

//// U1_SCPU
//wire[31:0] Data_in;
//wire INT;
//wire MIO_ready;
//wire[31:0] inst_in;
//wire[31:0] Addr_out;
//wire CPU_MIO;
//wire[31:0] Data_out;
//wire[31:0] PC_out;
//wire[2:0] dm_ctrl_2;
//wire mem_w_SCPU;

//// U4_MIO_BUS
//wire[4:0] BTN_BUS;
//wire[31:0] Cpu_data2bus;
//wire[15:0] SW_BUS;
//wire[31:0] addr_bus;
//wire[31:0] counter_out;
//wire counter0_out;
//wire counter1_out;
//wire counter2_out;
//wire[15:0] led_out;
//wire mem_w_BUS;
//wire[31:0] ram_data_out;
//wire[31:0] Cpu_data4bus;
//wire GPIOe0000000_we;
//wire GPIOf0000000_we;
//wire[31:0] Peripheral_in;
//wire counter_we_BUS;
//wire[9:0] ram_addr;
//wire[31:0] ram_data_in;

//// U5_Multi_8CH32
//wire EN_Multi;
//wire[63:0] LES_64;
//wire[2:0] Switch;
//wire[31:0] data0;
//wire[31:0] data1;
//wire[31:0] data2;
//wire[31:0] data3;
//wire[31:0] data4;
//wire[31:0] data5;
//wire[31:0] data6;
//wire[31:0] data7;
//wire[63:0] point_in;
//wire[31:0] Disp_num;
//wire[7:0] LE_out;
//wire[7:0] point_out;

//// U6_SSeg7
//wire[31:0] Hexs;
//wire[7:0] LES_8;
//wire SW0;
//wire flash;
//wire[7:0] point;
//wire[7:0] seg_an;
//wire[7:0] seg_sout;

//Enter U10_Enter(
//    .BTN(btn_i),
//    .SW(sw_i),
//    .clk(clk),
//    .BTN_out(BTN_out),
//    .SW_out(SW_out)
//);

//Counter_x U9_Counter_x(
//    .clk(~Clk_CPU),
//    .clk0(clkdiv[6]),
//    .clk1(clkdiv[9]),
//    .clk2(clkdiv[11]),
//    .counter_ch(counter_set),
//    .counter_val(Peripheral_in),
//    .counter_we(counter_we_BUS),
//    .rst(~rstn),
//    .counter0_OUT(counter0_OUT),
//    .counter1_OUT(counter1_OUT),
//    .counter2_OUT(counter2_OUT)
//);

//clk_div U8_clk_div(
//    .SW2(SW_out[2]),
//    .clk(clk),
//    .rst(~rstn),
//    .Clk_CPU(Clk_CPU),
//    .clkdiv(clkdiv)
//);

//SPIO U7_SPIO (
//    .EN(GPIOf0000000_we),
//    .P_Data( Peripheral_in),
//    .clk(~Clk_CPU),
//    .rst(~rstn),
//    .LED_out(LED_out),
//    .counter_set(counter_set),
//    .led(led_o)
//);

//SSeg7 U6_SSeg7 (
//    .Hexs(Disp_num),
//    .LES(LE_out),
//    .SW0(SW_out[0]),
//    .clk(clk),
//    .flash(clkdiv[10]),
//    .point(point_out),
//    .rst(~rstn),
//    .seg_an(disp_an_o),
//    .seg_sout(disp_seg_o)
//);

//Multi_8CH32 U5_Multi_8CH32 (
//    .EN(GPIOe0000000_we),
//    .LES(~64'h00000000),
//    .Switch(SW_out[7:5]),
//    .clk(~Clk_CPU),
//    .data0( Peripheral_in),
//    .data1({1'b0,1'b0,PC_out[31:2]}),
//    .data2(spo),
//    .data3(32'b0),
//    .data4(Addr_out),
//    .data5( Data_out),
//    .data6(Cpu_data4bus),
//    .data7(PC_out),
//    .point_in({clkdiv[31:0],clkdiv[31:0]}),
//    .rst(~rstn),
//    .Disp_num(Disp_num),
//    .LE_out(LE_out),
//    .point_out(point_out)
//);

//MIO_BUS U4_MIO_BUS (
//    .BTN(BTN_out),
//    .Cpu_data2bus( Data_out),
//    .SW(SW_out),
//    .addr_bus(Addr_out),
//    .clk(clk),
//    .counter_out(32'b0),
//    .counter0_out(counter0_OUT),
//    .counter1_out(counter1_OUT),
//    .counter2_out(counter2_OUT),
//    .led_out(LED_out),
//    .mem_w(mem_w_SCPU),
//    .ram_data_out(douta),
//    .rst(~rstn),
//    .Cpu_data4bus(Cpu_data4bus),
//    .GPIOe0000000_we(GPIOe0000000_we),
//    .GPIOf0000000_we(GPIOf0000000_we),
//    .Peripheral_in(Peripheral_in),
//    .counter_we(counter_we_BUS),
//    .ram_addr(ram_addr),
//    .ram_data_in(ram_data_in)
//);

//blk_mem_gen_0 U4_RAM_B (
//    .addra(ram_addr),
//    .clka(~clk),
//    .dina(Data_write_to_dm),
//    .wea( wea_mem),
//    .douta(douta)
//);

//dm_controller U3_dm_controller (
//    .Addr_in(Addr_out),
//    .Data_read_from_dm(Cpu_data4bus),
//    .Data_write( ram_data_in),
//    .dm_ctrl(dm_ctrl_2),
//    .mem_w(mem_w_SCPU),
//    .Data_read(Data_read),
//    .Data_write_to_dm(Data_write_to_dm),
//    .wea_mem(wea_mem)
//);

//dist_mem_gen_0 U2_ROM_D (
//    .a(PC_out[11:2]),
//    .spo(spo)
//);

//SCPU U1_SCPU (
//    .Data_in(Data_read),
//    .INT(counter0_OUT),
//    .MIO_ready(CPU_MIO),
//    .clk(Clk_CPU),
//    .inst_in(spo),
//    .reset(~rstn),
//    .Addr_out(Addr_out),
//    .CPU_MIO(CPU_MIO),
//    .Data_out(Data_out),
//    .PC_out(PC_out),
//    .dm_ctrl(dm_ctrl_2),
//    .mem_w(mem_w_SCPU)
//);

//endmodule

