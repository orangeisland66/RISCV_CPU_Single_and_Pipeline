module pwm_audio_100m (
    input        clk_100m,
    input        reset,
    input  [7:0] audio_data,
    output reg   aud_pwm
);

parameter CLK_FREQ    = 100_000_000;  // 100MHz 主时钟
parameter PWM_FREQ    = 200_000;      // PWM 频率 200kHz
parameter PWM_MAX     = (CLK_FREQ / PWM_FREQ) - 1;

reg [15:0] pwm_counter;         // PWM 计数器
reg [7:0]  audio_latched;       // 锁存的音频数据
reg        latch_flag;          // 锁存使能标志位

// 放大后的音频数据，中间用9位防止溢出
wire [8:0] audio_amplified;
wire [8:0] audio_amplified_2;
wire [7:0] audio_amplified_clamped;

// 放大1.5倍，防止溢出做限制
assign audio_amplified = {audio_data, 1'b0} + audio_data; // 等效*3
assign audio_amplified_2 = audio_amplified[8:1];    // 等效/2
assign audio_amplified_clamped = (audio_amplified_2 > 255) ? 8'd255 : audio_amplified_2[7:0];

// 初始块仅在仿真时有效，给寄存器初值
initial begin
    pwm_counter   = 0;
    aud_pwm       = 0;
    audio_latched = 0;
    latch_flag    = 0;
end

always @(posedge clk_100m) begin
    if (reset) begin
        pwm_counter   <= 0;
        aud_pwm       <= 1'b0;
        audio_latched <= 8'd0;
        latch_flag    <= 1'b0;
    end else begin
        // 计数器循环
        if (pwm_counter == PWM_MAX)
            pwm_counter <= 0;
        else
            pwm_counter <= pwm_counter + 1;

        // 控制 latch_flag 在 PWM 周期的特定时间使能
        if (pwm_counter == PWM_MAX - 2)
            latch_flag <= 1'b1;
        else if (pwm_counter == PWM_MAX)
            latch_flag <= 1'b0;

        // 锁存放大后的音频数据，排除 audio_data 为 x 的情况
        if (latch_flag && audio_data !== 8'bx)
            audio_latched <= audio_amplified_clamped;

        // PWM 输出逻辑
        aud_pwm <= (pwm_counter < audio_latched) ? 1'b1 : 1'b0;
    end
end

endmodule