module pwm_audio_100m (
    input        clk_100m,
    input        reset,
    input  [7:0] audio_data,
    output reg   aud_pwm
);

parameter CLK_FREQ    = 100_000_000;  // 100MHz ��ʱ��
parameter PWM_FREQ    = 200_000;      // PWM Ƶ�� 200kHz
parameter PWM_MAX     = (CLK_FREQ / PWM_FREQ) - 1;

reg [15:0] pwm_counter;         // PWM ������
reg [7:0]  audio_latched;       // �������Ƶ����
reg        latch_flag;          // ����ʹ�ܱ�־λ

// �Ŵ�����Ƶ���ݣ��м���9λ��ֹ���
wire [8:0] audio_amplified;
wire [8:0] audio_amplified_2;
wire [7:0] audio_amplified_clamped;

// �Ŵ�1.5������ֹ���������
assign audio_amplified = {audio_data, 1'b0} + audio_data; // ��Ч*3
assign audio_amplified_2 = audio_amplified[8:1];    // ��Ч/2
assign audio_amplified_clamped = (audio_amplified_2 > 255) ? 8'd255 : audio_amplified_2[7:0];

// ��ʼ����ڷ���ʱ��Ч�����Ĵ�����ֵ
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
        // ������ѭ��
        if (pwm_counter == PWM_MAX)
            pwm_counter <= 0;
        else
            pwm_counter <= pwm_counter + 1;

        // ���� latch_flag �� PWM ���ڵ��ض�ʱ��ʹ��
        if (pwm_counter == PWM_MAX - 2)
            latch_flag <= 1'b1;
        else if (pwm_counter == PWM_MAX)
            latch_flag <= 1'b0;

        // ����Ŵ�����Ƶ���ݣ��ų� audio_data Ϊ x �����
        if (latch_flag && audio_data !== 8'bx)
            audio_latched <= audio_amplified_clamped;

        // PWM ����߼�
        aud_pwm <= (pwm_counter < audio_latched) ? 1'b1 : 1'b0;
    end
end

endmodule