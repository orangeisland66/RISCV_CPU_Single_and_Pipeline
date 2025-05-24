module tone_generator (
    input wire clk,
    input wire reset,
    input wire [4:0] buttons,     // 5λ��ťѡ������
    input wire [5:0] switches,    // 6λ���ؿ��ƹ���
    input wire [1:0] sample_phase, // ����audio_controller����λ
    output reg [7:0] tone_data,   // ���ɵ���Ƶ����
    output reg tone_valid         // ������Ч�ź�
);

// ϵͳ����
parameter CLK_FREQ = 100_000_000;  // 100MHzʱ��
parameter SAMPLE_RATE = 8000;      // 8kHz������

// Ƶ�ʿ����ּ��㣨f * 2^32 / CLK_FREQ��
localparam [31:0] 
    DO_FREQ  = (261.63  * (2**32)) / CLK_FREQ,  // C4
    RE_FREQ  = (293.66  * (2**32)) / CLK_FREQ,  // D4
    MI_FREQ  = (329.63  * (2**32)) / CLK_FREQ,  // E4
    FA_FREQ  = (349.23  * (2**32)) / CLK_FREQ,  // F4
    SO_FREQ  = (392.00  * (2**32)) / CLK_FREQ;  // G4

// ��λ�ۼ���
reg [31:0] phase_acc;
reg [31:0] delta_theta;

// ���Ҳ���1024��8λ�з��ţ�
reg signed [7:0] sine_table [0:1023];
initial begin
    $readmemh("sine_table.mif", sine_table);
end

// ��ťѡ��Ƶ��
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

// ��λ�ۼӺͲ�������
reg [9:0] addr0, addr1, addr2, addr3;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        phase_acc <= 0;
        tone_data <= 8'h80;  // �м�ֵ
        tone_valid <= 0;
    end else begin
        if (sample_phase == 2'b00) begin
            // �����ĸ���λ��
            addr0 = phase_acc[31:22];        // ��ǰ��λ
            addr1 = (phase_acc + delta_theta) >> 22;
            addr2 = (phase_acc + delta_theta*2) >> 22;
            addr3 = (phase_acc + delta_theta*3) >> 22;

            // ������Ƶ���ݣ��з���ת�޷��ţ�
            tone_data <= {sine_table[addr3], 1'b0} + 8'h80;  // ʾ������
            tone_valid <= 1'b1;
            
            // ������λ�ۼ���
            phase_acc <= phase_acc + delta_theta*4;
        end else begin
            tone_valid <= 0;
        end
    end
end

// �������ƣ�ʹ�ÿ��ظ�3λ��
reg [7:0] scaled_data;
always @(*) begin
    case (switches[5:3])
        3'b000: scaled_data = tone_data & 8'h0F;  // 1/16
        3'b001: scaled_data = tone_data & 8'h1F;  // 1/8
        3'b010: scaled_data = tone_data & 8'h3F;  // 1/4
        3'b011: scaled_data = tone_data & 8'h7F;  // 1/2
        default: scaled_data = tone_data;        // ȫ����
    endcase
end

endmodule