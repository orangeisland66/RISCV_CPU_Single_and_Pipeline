module VRAMS_Controller (
    input wire clk,
    input wire rst,
    input wire [15:0] VRAMS_data_in,
    input wire [8:0] VRAMS_addr,      // ֧��0~47��ַ��Χ
    input wire VRAMS_we,
    input wire [5:0] VRAMSR_addr,      // ��ȡ��ַ��ΧΪ0~47��6*8=48��
    output reg [15:0] VRAMS_out
);

    // ���� 6x8 �����飬����չ���� 48 ��ȵļĴ�������
    reg [15:0] VRAMS_array [0:47];
    
    integer i;

     //д�������߼�
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

    // ������������߼�
    always @(*) begin
        if (VRAMS_addr < 48)
            VRAMS_out = VRAMS_array[VRAMSR_addr];
        else
            VRAMS_out = 16'b0;
    end

endmodule