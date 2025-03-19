module HazardDetectionUnit(
    input [4:0] IF_ID_rs1,  // 译码阶段（ID）的第一个源寄存器编号
    input [4:0] IF_ID_rs2,  // 译码阶段（ID）的第二个源寄存器编号
    input [4:0] ID_EX_rd,   // 执行阶段（EX）的目标寄存器编号
    input ID_EX_MemRead,    // 执行阶段是否进行内存读取操作
    input [2:0] ID_EX_NPCOp, // 执行阶段的下一个 PC 操作控制信号
    output reg stall,       // 流水线停顿信号
    output reg IF_ID_flush, // 取指 - 译码（IF - ID）流水线寄存器冲刷信号
    output reg PCWrite      // 新增：PC写使能信号
);

    always @(*) begin
        // 数据冒险检测
        if (ID_EX_MemRead && 
            ((ID_EX_rd != 5'b0) && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            stall = 1'b1;  // 检测到数据冒险，停顿流水线
            IF_ID_flush = 1'b0;
            PCWrite = 1'b0; // 阻塞时禁止PC更新
        end 
        // 控制冒险检测（分支和跳转指令）
        else if (ID_EX_NPCOp != 3'b000) begin
            stall = 1'b0;
            IF_ID_flush = 1'b1;  // 检测到控制冒险，冲刷 IF - ID 流水线寄存器
            PCWrite = 1'b1; // 不阻塞时允许PC更新
        end 
        else begin
            stall = 1'b0;
            IF_ID_flush = 1'b0;
            PCWrite = 1'b1; // 正常运行时允许PC更新
        end
    end

endmodule