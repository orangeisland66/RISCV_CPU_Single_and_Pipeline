module HazardDetectionUnit(
    input [4:0] IF_ID_rs1,  // ����׶Σ�ID���ĵ�һ��Դ�Ĵ������
    input [4:0] IF_ID_rs2,  // ����׶Σ�ID���ĵڶ���Դ�Ĵ������
    input [4:0] ID_EX_rd,   // ִ�н׶Σ�EX����Ŀ��Ĵ������
    input ID_EX_MemRead,    // ִ�н׶��Ƿ�����ڴ��ȡ����
    input [2:0] ID_EX_NPCOp, // ִ�н׶ε���һ�� PC ���������ź�
    output reg stall,       // ��ˮ��ͣ���ź�
    output reg IF_ID_flush, // ȡָ - ���루IF - ID����ˮ�߼Ĵ�����ˢ�ź�
    output reg PCWrite      // ������PCдʹ���ź�
);

    always @(*) begin
        // ����ð�ռ��
        if (ID_EX_MemRead && 
            ((ID_EX_rd != 5'b0) && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            stall = 1'b1;  // ��⵽����ð�գ�ͣ����ˮ��
            IF_ID_flush = 1'b0;
            PCWrite = 1'b0; // ����ʱ��ֹPC����
        end 
        // ����ð�ռ�⣨��֧����תָ�
        else if (ID_EX_NPCOp != 3'b000) begin
            stall = 1'b0;
            IF_ID_flush = 1'b1;  // ��⵽����ð�գ���ˢ IF - ID ��ˮ�߼Ĵ���
            PCWrite = 1'b1; // ������ʱ����PC����
        end 
        else begin
            stall = 1'b0;
            IF_ID_flush = 1'b0;
            PCWrite = 1'b1; // ��������ʱ����PC����
        end
    end

endmodule