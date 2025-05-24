`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/19 15:34:15
// Design Name: 
// Module Name: Top
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


module Top(
    input wire rstn,
    input  wire [4:0]btn_i,
    input  wire [15:0]sw_i,
    input  wire clk,
    output wire [7:0] disp_an_o,
    output wire [7:0] disp_seg_o,
    output wire [15:0]led_o,
    output wire [3:0]RED,
    output wire [3:0]GRN,
    output wire [3:0]BLU,
    output wire HS,
    output wire VS,
    output wire AUD_PWM
    );
    //U1_PCPU
    wire MIO_ready;
    wire[31:0] inst_in;
    wire[31:0] Data_in;
    wire mem_w;
    wire[31:0] PC_out;
    wire[31:0] Addr_out;
    wire[31:0] Data_out;
    wire[2:0] dm_ctrl;
    wire CPU_MIO;
    wire INT;
    
    //U2_ROM_D
    wire[11:0] a;
    wire[31:0] spo;
    
    //U3_dm_controller
    wire [31:0]Addr_in;
    wire [31:0]Data_write;
    wire [31:0]Data_read_from_dm;
    wire [31:0]Data_read;
    wire [31:0]Data_write_to_dm;
    wire [3:0]wea_mem;
    
    //U4_RAM_B
    wire [9:0] addra;
    wire [31:0] dina;
    wire [3:0] wea;
    wire [31:0] douta;
    
    //U4_MIO_BUS
    wire [4:0]BTN;
    wire [15:0]SW_U4;
    wire [31:0]PC;
    wire [31:0]Cpu_data2bus;
    wire [31:0]addr_bus;
    wire [31:0]ram_data_out;
    wire [15:0]led_out;
    wire [31:0]counter_out_U4;
    wire counter0_out;
    wire counter1_out;
    wire counter2_out;
    wire [31:0]Cpu_data4bus;
    wire [31:0]ram_data_in;
    wire [9:0]ram_addr;
    wire data_ram_we;
    wire GPIOf0000000_we;
    wire GPIOe0000000_we;
    wire counter_we;
    wire [31:0]Peripheral_in;
    
    //U5_Multi_8CH32
    wire EN_U5;
    wire [2:0]Switch;
    wire [63:0]point_in;
    wire [63:0]LES_U5;
    wire [31:0]data0;
    wire [31:0]data1;
    wire [31:0]data2;
    wire [31:0]data3;
    wire [31:0]data4;
    wire [31:0]data5;
    wire [31:0]data6;
    wire [31:0]data7;
    wire [7:0]point_out;
    wire [7:0]LE_out;
    wire [31:0]Disp_num;
    
    //U6_SSeg7        
    wire SW0;           
    wire flash;         
    wire [31:0]Hexs;    
    wire [7:0]point;    
    wire [7:0]LES_U6;      
    wire [7:0]seg_an;  
    wire [7:0]seg_sout;
    
    //U7_SPIO
    wire EN_U7;
    wire [31:0]P_Data;
    wire [1:0]counter_set;
    wire [15:0]LED_out;
    wire [15:0]led;
    wire [13:0]GPIOf0;
    
    //U8_clk_div
    wire SW2;
    wire[31:0] clkdiv;
    wire Clk_CPU;
    
    //U9_Counter_x
	wire clk0;
	wire clk1;
	wire clk2;
	wire [31:0] counter_val;
	wire [1:0] counter_ch;
	wire counter0_OUT;
	wire counter1_OUT;
	wire counter2_OUT;
	wire [31:0] counter_out_U9;
	
	//U10
	wire [4:0] BTN_Enter;
    wire [15:0] SW_Enter;
    wire [4:0] BTN_out;
    wire [15:0] SW_out;
	
	
	//U1
	assign Data_in = Data_read;
	assign INT = counter0_OUT;
	assign MIO_ready = CPU_MIO;
	assign inst_in = spo;
	assign Addr_in = Addr_out;
	assign Data_out = Cpu_data2bus;
	assign a = PC_out[13:2];
	
	//U2
	assign data2 = spo;
	
	//U3
	assign Data_read_from_dm = Cpu_data4bus;
	assign Data_write = ram_data_in;
	assign dina = Data_write_to_dm;
	assign wea = wea_mem;
	
	//U4_RAM_B
	assign addra = ram_addr;
	assign ram_data_out = douta;
	
	//U4_MIO_BUS
	assign BTN = BTN_out;
	assign data5 = Data_out;
	assign SW_U4 = SW_out;
	assign addr_bus = Addr_out;
	assign addr_bus = data4;
	assign counter_out_U4 = 32'b0;
	assign counter0_out =counter0_OUT;
    assign counter1_out =counter1_OUT;
    assign counter2_out =counter2_OUT;
    assign led_out = LED_out;
    assign data6 = Cpu_data4bus;
    assign EN_U5 = GPIOe0000000_we;
    assign EN_U7 = GPIOf0000000_we;
    assign P_Data = Peripheral_in;
    
    //U5
    assign LES_U5 = ~64'h00000000;
    assign Switch = SW_out[7:5];
    assign data0 = Peripheral_in;
    assign data1 = {1'b0,1'b0,PC_out[31:2]};
	assign data3 = 32'b0;
	assign data4 = Addr_out;
	assign data7 = PC_out;
	assign point_in = {clkdiv[31:0],clkdiv[31:0]};
	assign Hexs = Disp_num;
    assign LES_U6 = LE_out;
    assign point = point_out;
	
	//U6
	assign SW0 = SW_out[0];
	assign flash = clkdiv[10];
	assign seg_an = disp_an_o;
	assign seg_sout = disp_seg_o;
	
	//U7
	assign P_Data = counter_val;
	assign counter_set = counter_ch;
	assign led = led_o;
	
	//U8
	assign SW2 = SW_out[2];
	
	//U9
	assign clk0 = clkdiv[6];
    assign clk1 = clkdiv[9];
    assign clk2 = clkdiv[11];

	//U10
	assign BTN_Enter = btn_i;
	assign SW_Enter = sw_i;
    
    
    PCPU U1_PCPU (
    .clk(Clk_CPU),
    .reset(~rstn),
    .MIO_ready(MIO_ready),
    .inst_in(inst_in),
    .Data_in(Data_in),
    .mem_w(mem_w),
    .PC_out(PC_out),
    .Addr_out(Addr_out),
    .Data_out(Data_out),
    .dm_ctrl(dm_ctrl),
    .CPU_MIO(CPU_MIO),
    .INT(INT)
    );
    
    ROM_D U2_ROM_D (
    .a(a),
    .spo(spo)
    );
    
    dm_controller U3_dm_controller (
    .mem_w(mem_w),
    .Addr_in(Addr_in),
    .Data_write(Data_write),
    .dm_ctrl(dm_ctrl),
    .Data_read_from_dm(Data_read_from_dm),
    .Data_read(Data_read),
    .Data_write_to_dm(Data_write_to_dm),
    .wea_mem(wea_mem)
    );
    
    RAM_B U4_RAM_B (
    .addra(addra),
    .clka(~clk),
    .dina(dina),
    .wea(wea),
    .douta(douta)
    );
    
    wire [15:0] VRAM_data_in;
    wire [8:0] VRAM_addr;
    wire VRAM_we;
    
    wire [15:0] VRAMS_data_in;
    wire [8:0] VRAMS_addr;
    wire VRAMS_we;
    
    MIO_BUS U4_MIO_BUS (
    .clk(clk),
    .rst(~rstn),
    .BTN(BTN),
    .SW(SW_U4),
    .PC(PC),
    .mem_w(mem_w),
    .Cpu_data2bus(Cpu_data2bus),
    .addr_bus(addr_bus),
    .ram_data_out(ram_data_out),
    .led_out(led_out),
    .counter_out(counter_out_U4),
    .counter0_out(counter0_out),
    .counter1_out(counter1_out),
    .counter2_out(counter2_out),
    .Cpu_data4bus(Cpu_data4bus),
    .ram_data_in(ram_data_in),
    .ram_addr(ram_addr),
    .data_ram_we(data_ram_we),
    .GPIOe0000000_we(GPIOe0000000_we),
    .GPIOf0000000_we(GPIOf0000000_we),
    .counter_we(counter_we),
    .Peripheral_in(Peripheral_in),
    .VRAM_data_in(VRAM_data_in),
    .VRAM_addr(VRAM_addr),
    .VRAM_we(VRAM_we),
    .VRAMS_data_in(VRAMS_data_in),
    .VRAMS_addr(VRAMS_addr),
    .VRAMS_we(VRAMS_we)
    );
    
    Multi_8CH32 U5_Multi_8CH32 (
    .clk(~Clk_CPU),
    .rst(~rstn),
    .EN(EN_U5),
    .Switch(Switch),
    .point_in(point_in),
    .LES(LES_U5),
    .data0(data0),
    .data1(data1),
    .data2(data2),
    .data3(data3),
    .data4(data4),
    .data5(data5),
    .data6(data6),
    .data7(data7),
    .point_out(point_out),
    .LE_out(LE_out),
    .Disp_num(Disp_num)
    );
    
    SSeg7 U6_SSeg7 (
    .clk(clk),
    .rst(~rstn),
    .SW0(SW0),
    .flash(flash),
    .Hexs(Hexs),
    .point(point),
    .LES(LES_U6),
    .seg_an(seg_an),
    .seg_sout(seg_sout)
    );
    
    SPIO U7_SPIO (
    .clk(~Clk_CPU),
    .rst(~rstn),
    .EN(EN_U7),
    .P_Data(P_Data),
    .counter_set(counter_set),
    .LED_out(LED_out),
    .led(led),
    .GPIOf0(GPIOf0)
    );
    
    clk_div U8_clk_div(
    .clk(clk),
    .rst(~rstn),
    .SW2(SW2),
    .clkdiv(clkdiv),
    .Clk_CPU(Clk_CPU)
    );
    
    Counter_x U9_Counter_x(
    .clk(~Clk_CPU),
    .rst(~rstn),
    .clk0(clk0),
    .clk1(clk1),
    .clk2(clk2),
    .counter_we(counter_we),
    .counter_val(counter_val),
    .counter_ch(counter_ch),
    .counter0_OUT(counter0_OUT),
    .counter1_OUT(counter1_OUT),
    .counter2_OUT(counter2_OUT),
    .counter_out(counter_out_U9)
    );
    
    Enter U10_Enter(
    .clk(clk),
    .BTN(BTN_Enter),
    .SW(SW_Enter),
    .BTN_out(BTN_out),
    .SW_out(SW_out)
    );
    
    wire [31:0]addra_VGA;
    wire dina_VGA;
    wire [15:0]douta_VGA;
    
    VGARAM U11_VGARAM(
    .addra(addra_VGA),
    .clka(~clk),
    .dina(dina_VGA),
    .wea(2'b00),
    .douta(douta_VGA)
    );
    
    wire [15:0]VRAMOUT;
    wire [13:0]Test;
    wire [31:0]Din;
    wire [3:0]Regaddr;
    wire [12:0]Cursor;
    wire Blink;
    
    wire [8:0]row;
    wire [9:0]col;
    wire [31:0]VRAMA;
    
    wire [11:0] Pixel;  
    wire rdn;
    
    wire [3:0] R;
    wire [3:0] G;
    wire [3:0] B;
    
    assign addra_VGA = sw_i[0]?(row/2 * 320 + col/2):(row * 320 + col);

    VGAIO U12_VGAIO(
    .clk(clk),
    .rst(~rstn),
    //.VRAMOUT(VRAMOUT),
    .Pixel(Pixel),
    //.Test(Test),
    //.Din(Din),
    //.Regaddr(Regaddr),
    //.Cursor(Cursor),
    //.Blink(Blink),
           
    .row(row),
    .col(col),
    .R(R),
    .G(G),
    .B(B),
    .HSYNC(HS),
    .VSYNC(VS),
    .VRAMA(VRAMA),
    .rdn(rdn)		
    );
    
    assign RED=R;
    assign GRN=G;
    assign BLU=B;
    
    // 声明音频相关信号
    wire [7:0] audio_data;
    wire audio_valid;
    wire aud_pwm;
    
    // 内部信号声明
    wire [7:0] rom_audio_data;
    wire [7:0] tone_audio_data;
    wire [7:0] selected_audio;
    wire [1:0] sample_phase;

    // 实例化音频控制器
    audio_controller audio_ctrl (
        .clk(clk),
        .reset(~rstn),
        .audio_data(rom_audio_data),
        .audio_valid(audio_valid),
        .sample_phase(sample_phase)
    );

    // 实例化音调生成器
    tone_generator tone_gen (
    .clk(clk),
    .reset(~rstn),
    .buttons(btn_i),
    .switches(sw_i[14:9]),
    .sample_phase(sample_phase), // 连接相位信号
    .tone_data(tone_audio_data),
    .tone_valid()
    );

    // 音频源选择器
    assign selected_audio = sw_i[15] ? tone_audio_data : rom_audio_data;

    // 实例化PWM音频输出
    pwm_audio_100m pwm_output (
    .clk_100m(clk),
    .reset(~rstn),
    .audio_data(selected_audio),
    .aud_pwm(aud_pwm)
    );

    assign AUD_PWM = aud_pwm;

    wire [5:0] VRAMSR_addr;      // 读取地址范围为0~47（6*8=48）
    wire [15:0] VRAMS_out;
    
    assign VRAMSR_addr = (row/80 * 8 + col/80);

    VRAMS_Controller VRAMS_Controller (
    .clk(~clk),
    .rst(~rstn),
    .VRAMS_data_in(VRAMS_data_in),
    .VRAMS_addr(VRAMS_addr),
    .VRAMS_we(VRAMS_we),
    .VRAMSR_addr(VRAMSR_addr),
    .VRAMS_out(VRAMS_out)
    );
    
    Pixel_control Pixel_control(
    .row(row),
    .col(col),
    .douta_VGA(douta_VGA),
    .sw_i(sw_i),
    .VRAMS_out(VRAMS_out),
    .Pixel(Pixel)
    );
    
endmodule