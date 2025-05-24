module VRAMS_Controller (
    input wire clk,
    input wire rst,
    input wire [15:0] VRAMS_data_in,
    input wire [8:0] VRAMS_addr,      // 支持0~47地址范围
    input wire VRAMS_we,
    input wire [5:0] VRAMSR_addr,      // 读取地址范围为0~47（6*8=48）
    output reg [15:0] VRAMS_out
);

    // 声明 6x8 的数组，线性展开成 48 深度的寄存器数组
    reg [15:0] VRAMS_array [0:47];
    
    integer i;

     //写入或清空逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 48; i = i + 1) begin
                VRAMS_array[i] <= 16'b0;
            end
        end else if (VRAMS_we) begin
            if (VRAMS_addr < 48) begin
                VRAMS_array[VRAMS_addr] <= VRAMS_data_in;
            end
        end
    end

    // 读操作，组合逻辑
    always @(*) begin
        if (VRAMS_addr < 48)
            VRAMS_out = VRAMS_array[VRAMSR_addr];
        else
            VRAMS_out = 16'b0;
    end

endmodule