module tone_generator (
    input wire clk,
    input wire reset,
    input wire [4:0] buttons,     // 5位按钮选择音调
    input wire [5:0] switches,    // 6位开关控制功能
    input wire [1:0] sample_phase, // 来自audio_controller的相位
    output reg [7:0] tone_data,   // 生成的音频数据
    output reg tone_valid         // 数据有效信号
);

// 系统参数
parameter CLK_FREQ = 100_000_000;  // 100MHz时钟
parameter SAMPLE_RATE = 8000;      // 8kHz采样率

// 频率控制字计算（f * 2^32 / CLK_FREQ）
localparam [31:0] 
    DO_FREQ  = (261.63  * (2**32)) / CLK_FREQ,  // C4
    RE_FREQ  = (293.66  * (2**32)) / CLK_FREQ,  // D4
    MI_FREQ  = (329.63  * (2**32)) / CLK_FREQ,  // E4
    FA_FREQ  = (349.23  * (2**32)) / CLK_FREQ,  // F4
    SO_FREQ  = (392.00  * (2**32)) / CLK_FREQ;  // G4

// 相位累加器
reg [31:0] phase_acc;
reg [31:0] delta_theta;

// 正弦波表（1024点8位有符号）
reg signed [7:0] sine_table [0:1023];
initial begin
    $readmemh("sine_table.mif", sine_table);
end

// 按钮选择频率
always @(*) begin
    case (buttons)
        5'b00001: delta_theta = DO_FREQ;
        5'b00010: delta_theta = RE_FREQ;
        5'b00100: delta_theta = MI_FREQ;
        5'b01000: delta_theta = FA_FREQ;
        5'b10000: delta_theta = SO_FREQ;
        default:  delta_theta = DO_FREQ;
    endcase
end

// 相位累加和波形生成
reg [9:0] addr0, addr1, addr2, addr3;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        phase_acc <= 0;
        tone_data <= 8'h80;  // 中间值
        tone_valid <= 0;
    end else begin
        if (sample_phase == 2'b00) begin
            // 计算四个相位点
            addr0 = phase_acc[31:22];        // 当前相位
            addr1 = (phase_acc + delta_theta) >> 22;
            addr2 = (phase_acc + delta_theta*2) >> 22;
            addr3 = (phase_acc + delta_theta*3) >> 22;

            // 生成音频数据（有符号转无符号）
            tone_data <= {sine_table[addr3], 1'b0} + 8'h80;  // 示例处理
            tone_valid <= 1'b1;
            
            // 更新相位累加器
            phase_acc <= phase_acc + delta_theta*4;
        end else begin
            tone_valid <= 0;
        end
    end
end

// 音量控制（使用开关高3位）
reg [7:0] scaled_data;
always @(*) begin
    case (switches[5:3])
        3'b000: scaled_data = tone_data & 8'h0F;  // 1/16
        3'b001: scaled_data = tone_data & 8'h1F;  // 1/8
        3'b010: scaled_data = tone_data & 8'h3F;  // 1/4
        3'b011: scaled_data = tone_data & 8'h7F;  // 1/2
        default: scaled_data = tone_data;        // 全音量
    endcase
end

endmodule