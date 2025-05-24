//`timescale 1ns / 1ps

//module tb_top;

//    // ================== �����ź����� ==================
//    reg [15:0] sw_i;
//    reg [4:0] btn_i;
//    reg rstn;
//    reg ddr2_clk_p;   // 100MHz���ʱ�ӣ���ʱ�ӣ�
////    reg clk_ref_p;   // 200MHz�ο�ʱ�ӣ�MIGר�ã�
//    reg ddr2_clk_n;  // ���ʱ�ӷ��ࣨ�ӵػ��ࣩ
////    wire clk_ref_n;  // �ο�ʱ�ӷ��ࣨ�ӵػ��ࣩ

//    // ================== ����ź����� ==================
//    wire [7:0] disp_an_o;
//    wire [7:0] disp_seg_o;
//    wire [15:0] led_o;
//    wire [3:0] RED, GRN, BLU;
//    wire HS, VS;

//    // ================== ʵ��������ģ�� ==================
//    Top uut (
//        .sw_i(sw_i),
//        .btn_i(btn_i),
//        .clk(sys_clk_p),        // ʹ��sys_clk_p��Ϊϵͳʱ�ӣ���MIG��ʱ��һ�£�
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

//    // ================== ʱ������ ==================
//    // 100MHz��ʱ�ӣ�sys_clk_p/n��
//    always #5 ddr2_clk_p = ~ddr2_clk_p;  // ����10ns��100MHz��
////    assign ddr2_clk_n = ~ddr2_clk_p;     // ģ����ʱ�ӣ�ʵ��Ӧ�ӵػ�������ʵ����ʱ�ӣ�

//    // 200MHz�ο�ʱ�ӣ�clk_ref_p/n��
//    always #2.5 ddr2_clk_n = ~ddr2_clk_n;  // ����5ns��200MHz��
////    assign clk_ref_n = ~clk_ref_p;       // ģ����ʱ��

//    // ================== ��ʼ���뼤�� ==================
//    initial begin
//        // ��ʼ���ź�
//        sw_i = 16'h0000;
//        btn_i = 5'b00000;
//        rstn = 0;
//        ddr2_clk_p = 0;
//        ddr2_clk_n = 0;

//        // ��λ���У�MIG��Ҫ����200us��λ��������������Ϊ200ns��
//        #200;
//        rstn = 1;  // �ͷŸ�λ

//        // �ȴ�MIG��ʼ�����
//        wait(uut.init_calib_complete === 1'b1);
//        $display("MIG initialization complete!");

//        // ================== д����ͼ����DDR2 ==================
//        // д��ˮƽ��������R=G=B=X/16��XΪ���غ�����0~319��
//        write_test_pattern();

//        // �ȴ�һ��ʱ��۲���ʾ
//        #10000;

//        // ��������
//        $finish();
//    end

//    // ================== д����ͼ������ ==================
//    task write_test_pattern();
//    integer x, y;
//    reg [31:0] pixel_data;
//    reg [31:0] write_addr;
//    begin
        

//        // д��ַ��0x00100000��ʼ���������һ�£�
//        write_addr = 32'h00100000;

//        // �����������أ�320x240��
//        for (y = 0; y < 240; y = y + 1) begin
//            for (x = 0; x < 320; x = x + 1) begin
//                // ����12λRGB���ݣ�4-4-4��ʽ��
//                pixel_data = {4'b0, x[7:4], x[7:4], x[7:4]};  // R=G=B=x/16��0~15��
                
//                // ģ��MIGдʱ��������app_rdy��app_wdf_rdy��
//                @(posedge uut.clk_100m);
//                uut.app_addr <= write_addr;
//                uut.app_cmd <= 3'b010;  // д����
//                uut.app_en <= 1'b1;
//                uut.app_wdf_data <= pixel_data[15:0];  // ע�⣺MIG��app_wdf_dataΪ16λ��ȡ��16λ
//                uut.app_wdf_wren <= 1'b1;
                
//                // �ȴ�д�������
//                wait(uut.app_rdy && uut.app_wdf_rdy);
                
//                // ��ַ����2�ֽڣ�ÿ������ռ2�ֽڣ�
//                write_addr = write_addr + 2;
//            end
//        end
//        $display("Test pattern written to DDR2!");
//    end
//endtask

//    // ================== ���ι۲��� ==================
//    initial begin
//        $timeformat(-9, 0, " ns", 6);
//        $monitor("@%t: rstn=%b, init_calib_complete=%b, app_rd_data_valid=%b", 
//                 $time, rstn, uut.init_calib_complete, uut.app_rd_data_valid);
//    end

//endmodule