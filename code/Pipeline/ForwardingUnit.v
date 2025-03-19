`timescale 1ns / 1ps



// ǰ�ݵ�Ԫģ��
module ForwardingUnit(
    input MEM_RegWrite,
    input [4:0] MEM_rd,
    input WB_RegWrite,
    input [4:0] WB_rd,
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,
    output [1:0] ForwardA,
    output [1:0] ForwardB
);
    wire MEM_Forward;
    assign MEM_Forward = ~(|(MEM_rd ^ EX_rs1)) & MEM_RegWrite;

    wire WB_Forward;
    assign WB_Forward = ~(|(WB_rd ^ EX_rs1)) & WB_RegWrite & ~MEM_Forward;

    assign ForwardA = {MEM_Forward, WB_Forward};

    wire MEM_Forward2;
    assign MEM_Forward2 = ~(|(MEM_rd ^ EX_rs2)) & MEM_RegWrite;

    wire WB_Forward2;
    assign WB_Forward2 = ~(|(WB_rd ^ EX_rs2)) & WB_RegWrite & ~MEM_Forward2;

    assign ForwardB = {MEM_Forward2, WB_Forward2};
endmodule

