//`timescale 1ns / 1ps

//module tb_top;

//    // ================== 输入信号声明 ==================
//    reg [15:0] sw_i;
//    reg [4:0] btn_i;
//    reg rstn;
//    reg ddr2_clk_p;   // 100MHz差分时钟（主时钟）
////    reg clk_ref_p;   // 200MHz参考时钟（MIG专用）
//    reg ddr2_clk_n;  // 差分时钟反相（接地或反相）
////    wire clk_ref_n;  // 参考时钟反相（接地或反相）

//    // ================== 输出信号声明 ==================
//    wire [7:0] disp_an_o;
//    wire [7:0] disp_seg_o;
//    wire [15:0] led_o;
//    wire [3:0] RED, GRN, BLU;
//    wire HS, VS;

//    // ================== 实例化被测模块 ==================
//    Top uut (
//        .sw_i(sw_i),
//        .btn_i(btn_i),
//        .clk(sys_clk_p),        // 使用sys_clk_p作为系统时钟（与MIG主时钟一致）
//        .rstn(rstn),
//        .disp_an_o(disp_an_o),
//        .disp_seg_o(disp_seg_o),
//        .led_o(led_o),
//        .RED(RED),
//        .GRN(GRN),
//        .BLU(BLU),
//        .HS(HS),
//        .VS(VS),
//        .ddr2_ck_p(ddr2_clk_p),
//        .ddr2_ck_n(ddr2_clk_n)

//    );

//    // ================== 时钟生成 ==================
//    // 100MHz主时钟（sys_clk_p/n）
//    always #5 ddr2_clk_p = ~ddr2_clk_p;  // 周期10ns（100MHz）
////    assign ddr2_clk_n = ~ddr2_clk_p;     // 模拟差分时钟（实际应接地或连接真实反相时钟）

//    // 200MHz参考时钟（clk_ref_p/n）
//    always #2.5 ddr2_clk_n = ~ddr2_clk_n;  // 周期5ns（200MHz）
////    assign clk_ref_n = ~clk_ref_p;       // 模拟差分时钟

//    // ================== 初始化与激励 ==================
//    initial begin
//        // 初始化信号
//        sw_i = 16'h0000;
//        btn_i = 5'b00000;
//        rstn = 0;
//        ddr2_clk_p = 0;
//        ddr2_clk_n = 0;

//        // 复位序列（MIG需要至少200us复位，但仿真中缩短为200ns）
//        #200;
//        rstn = 1;  // 释放复位

//        // 等待MIG初始化完成
//        wait(uut.init_calib_complete === 1'b1);
//        $display("MIG initialization complete!");

//        // ================== 写测试图案到DDR2 ==================
//        // 写入水平渐变条（R=G=B=X/16，X为像素横坐标0~319）
//        write_test_pattern();

//        // 等待一段时间观察显示
//        #10000;

//        // 结束仿真
//        $finish();
//    end

//    // ================== 写测试图案任务 ==================
//    task write_test_pattern();
//    integer x, y;
//    reg [31:0] pixel_data;
//    reg [31:0] write_addr;
//    begin
        

//        // 写地址从0x00100000开始（与代码中一致）
//        write_addr = 32'h00100000;

//        // 遍历所有像素（320x240）
//        for (y = 0; y < 240; y = y + 1) begin
//            for (x = 0; x < 320; x = x + 1) begin
//                // 生成12位RGB数据（4-4-4格式）
//                pixel_data = {4'b0, x[7:4], x[7:4], x[7:4]};  // R=G=B=x/16（0~15）
                
//                // 模拟MIG写时序（需满足app_rdy和app_wdf_rdy）
//                @(posedge uut.clk_100m);
//                uut.app_addr <= write_addr;
//                uut.app_cmd <= 3'b010;  // 写命令
//                uut.app_en <= 1'b1;
//                uut.app_wdf_data <= pixel_data[15:0];  // 注意：MIG的app_wdf_data为16位，取低16位
//                uut.app_wdf_wren <= 1'b1;
                
//                // 等待写操作完成
//                wait(uut.app_rdy && uut.app_wdf_rdy);
                
//                // 地址递增2字节（每个像素占2字节）
//                write_addr = write_addr + 2;
//            end
//        end
//        $display("Test pattern written to DDR2!");
//    end
//endtask

//    // ================== 波形观测标记 ==================
//    initial begin
//        $timeformat(-9, 0, " ns", 6);
//        $monitor("@%t: rstn=%b, init_calib_complete=%b, app_rd_data_valid=%b", 
//                 $time, rstn, uut.init_calib_complete, uut.app_rd_data_valid);
//    end

//endmodule