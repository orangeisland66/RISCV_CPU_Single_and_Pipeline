`include "ctrl_encode_def.v"

module SCPU1(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    input INT,
    input MIO_ready,
    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    output CPU_MIO,

//    input  [4:0] reg_sel,    // register selection (for debug use)
//    output [31:0] reg_data , // selected register data (for debug use)
    output [2:0] DMType
);

    // ????????????
    wire [63:0] IF_ID_in;
    wire [63:0] IF_ID_out;
    wire [160:0] ID_EX_in;
    wire [160:0] ID_EX_out;
    wire [110:0] EX_MEM_in;
    wire [110:0] EX_MEM_out;
    wire [103:0] MEM_WB_in;
    wire [103:0] MEM_WB_out;

    wire IF_ID_write_enable;
    wire IF_ID_flush;
    wire ID_EX_write_enable = 1'b1;  
    wire EX_MEM_write_enable = 1'b1;  
    wire MEM_WB_write_enable = 1'b1;  
    reg [31:0] RF_WD;  // ????��???????????????
    // ??????????????
    GRE_array #(200) IF_ID (
       .Clk(clk),
       .Rst(reset),
       .write_enable(IF_ID_write_enable),
       .flush(IF_ID_flush),
       .in(IF_ID_in),
       .out(IF_ID_out)
    );

    GRE_array #(200) ID_EX (
       .Clk(clk),
       .Rst(reset),
       .write_enable(ID_EX_write_enable),
       .flush(ID_EX_flush),
       .in(ID_EX_in),
       .out(ID_EX_out)
    );

    GRE_array #(200) EX_MEM (
       .Clk(clk),
       .Rst(reset),
       .write_enable(EX_MEM_write_enable),
       .flush(1'b0),
       .in(EX_MEM_in),
       .out(EX_MEM_out)
    );

    GRE_array #(200) MEM_WB (
       .Clk(clk),
       .Rst(reset),
       .write_enable(MEM_WB_write_enable),
       .flush(1'b0),
       .in(MEM_WB_in),
       .out(MEM_WB_out)
    );

    wire PCWrite;
    // IF???
//    ????????
    // ID???
    wire [31:0] IF_ID_PC = IF_ID_out[63:32];
    wire [31:0] IF_ID_inst = IF_ID_out[31:0];
    wire [6:0] Op = IF_ID_inst[6:0];
    wire [2:0] Funct3 = IF_ID_inst[14:12];
    wire [6:0] Funct7 = IF_ID_inst[31:25];
    wire [4:0] rs1 = IF_ID_inst[19:15];
    wire [4:0] rs2 = IF_ID_inst[24:20];
    wire [4:0] rd = IF_ID_inst[11:7];
    // ?????????
    wire [31:0] immout;
    wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	assign iimm_shamt=IF_ID_inst[24:20];
	assign iimm=IF_ID_inst[31:20];
	assign simm={IF_ID_inst[31:25],IF_ID_inst[11:7]};
	assign bimm={IF_ID_inst[31],IF_ID_inst[7],IF_ID_inst[30:25],IF_ID_inst[11:8]};
	assign uimm=IF_ID_inst[31:12];
	assign jimm={IF_ID_inst[31],IF_ID_inst[19:12],IF_ID_inst[20],IF_ID_inst[30:21]};
    // EX???
   
    wire [31:0] aluout_EX;
    wire Zero_EX;
    wire RegWrite_EX = ID_EX_out[160];
    wire MemWrite_EX = ID_EX_out[159];
    wire [4:0] ALUOp_EX = ID_EX_out[158:154];
    wire ALUSrc_EX = ID_EX_out[153];
    wire [1:0] GPRSel_EX = ID_EX_out[152:151];
    wire [1:0] WDSel_EX = ID_EX_out[150:149];
    wire [2:0] DMType_EX = ID_EX_out[148:146];
    wire [2:0] NPCOp_EX = {ID_EX_out[145:144],ID_EX_out[143]&Zero_EX};
    wire [31:0] RD1_EX = ID_EX_out[142:111];
    wire [31:0] RD2_EX = ID_EX_out[110:79];
    wire [31:0] immout_EX = ID_EX_out[78:47];
    wire [4:0] rs1_EX = ID_EX_out[46:42];
    wire [4:0] rs2_EX = ID_EX_out[41:37];
    wire [4:0] rd_EX = ID_EX_out[36:32];
    wire [31:0] PC_EX = ID_EX_out[31:0];
    wire [31:0] NPC; 
    
    // MEM???
    wire [31:0] PC_MEM = EX_MEM_out[109:78];
    wire RegWrite_MEM = EX_MEM_out[77];
    wire MemWrite_MEM = EX_MEM_out[76];
    wire [1:0] WDSel_MEM = EX_MEM_out[75:74];
    wire [1:0] GPRSel_MEM = EX_MEM_out[73:72];
    wire [2:0] DMType_MEM = EX_MEM_out[71:69];
    wire [31:0] aluout_MEM = EX_MEM_out[68:37];
    wire [31:0] RD2_MEM = EX_MEM_out[36:5];
    wire [4:0] rd_MEM = EX_MEM_out[4:0];

    assign Addr_out = aluout_MEM;
    assign Data_out = RD2_MEM;
    assign mem_w = MemWrite_MEM;
    assign DMType = DMType_MEM;
    
    //WB???
    wire [31:0]PC_WB=MEM_WB_out[103:72];
    wire RegWrite_WB=MEM_WB_out[71];
    wire [1:0] WDSel_WB=MEM_WB_out[70:69];
    wire [31:0] Data_in_WB=MEM_WB_out[68:37];
    wire [31:0] aluout_WB=MEM_WB_out[36:5];
    wire [4:0] rd_WB=MEM_WB_out[4:0];
    PC u_PC (
       .clk(clk),
       .rst(reset),
       .NPC(NPC),
       .PC(PC_out)
    );

    assign IF_ID_in = {PC_out, inst_in};



    // ???????????
    wire RegWrite, MemWrite, ALUSrc;
    wire [1:0] WDSel, GPRSel;
    wire [4:0] ALUOp;
    wire [2:0] NPCOp, DMType_ID;
    wire [5:0] EXTOp;
    wire Zero;  // ?????EX??��?????????????
    wire ID_EX_MemRead; // ??��?????????????????
//    assign ID_EX_MemRead = (ID_EX_out[159] == 1'b0) && (ID_EX_out[150:149] == `WDSel_FromMEM); // ???????????��?
    assign ID_EX_MemRead = WDSel_EX[0]; // ???????????��?
    
    ctrl u_ctrl (
       .Op(Op),
       .Funct7(Funct7),
       .Funct3(Funct3),
       .Zero(Zero),
       .RegWrite(RegWrite),
       .MemWrite(MemWrite),
       .EXTOp(EXTOp),
       .ALUOp(ALUOp),
       .NPCOp(NPCOp),
       .ALUSrc(ALUSrc),
       .GPRSel(GPRSel),
       .WDSel(WDSel),
       .DMType(DMType_ID)
    );


 	EXT u_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

    // ????????
    wire [31:0] RD1, RD2;
    RF u_RF (
       .clk(clk),
       .rst(reset),
       .RFWr(RegWrite_WB),  // MEM/WB??��?��???
       .A1(rs1),
       .A2(rs2),
       .A3(rd_WB),  // MEM/WB??��???????????
       .WD(RF_WD),  // ��???????????????
       .RD1(RD1),
       .RD2(RD2)
    );

    // ???ID????????ID_EX??????????
    assign ID_EX_in = {RegWrite, MemWrite, ALUOp, ALUSrc, GPRSel, WDSel, DMType_ID, NPCOp, 
                              RD1, RD2, immout, rs1, rs2, rd, IF_ID_PC};
    HazardDetectionUnit u_hazard (
       .IF_ID_rs1(rs1),
       .IF_ID_rs2(rs2),
       .ID_EX_rd(rd_EX),
       .ID_EX_MemRead(ID_EX_MemRead),
       .ID_EX_NPCOp(NPCOp_EX),
       .stall(stall_signal),
       .IF_ID_flush(IF_ID_flush),
       .PCWrite(PCWrite)
    );
    // ???????????????ID_EX_flush???
    wire Branch_or_Jump = |NPCOp_EX;
//    wire stall_signal = 1'b0;  // ?????????????????????????????
    assign ID_EX_flush = stall_signal | Branch_or_Jump;
    assign IF_ID_write_enable = ~stall_signal;

    

    // ?????
    wire [1:0] ForwardA, ForwardB;
    ForwardingUnit u_forward (
       .MEM_RegWrite(RegWrite_MEM),
       .MEM_rd(rd_MEM),
       .WB_RegWrite(RegWrite_WB),
       .WB_rd(rd_WB),
       .EX_rs1(rs1_EX),
       .ForwardA(ForwardA),
       .EX_rs2(rs2_EX),
       .ForwardB(ForwardB)
    );

    wire [31:0] RD1_forwarded = (ForwardA == 2'b00)? RD1_EX :
                                (ForwardA == 2'b01)? RF_WD:
                                (ForwardA == 2'b10)? aluout_MEM : 32'b0;
    wire [31:0] RD2_forwarded = (ForwardB == 2'b00)? RD2_EX :
                                (ForwardB == 2'b01)? RF_WD:
                                (ForwardB == 2'b10)? aluout_MEM : 32'b0;
    wire [31:0] B_EX = ALUSrc_EX? immout_EX : RD2_forwarded;

    alu u_alu (
       .A(RD1_forwarded),
       .B(B_EX),
       .ALUOp(ALUOp_EX),
       .C(aluout_EX),
       .Zero(Zero_EX),     
       .PC(PC_EX)
    );

    // ??????????????????????PC_next
//    wire PCSrc = Branch_or_Jump && Zero_EX;
    NPC u_NPC (
       .PC(PC_out),
       .PC_EX(PC_EX),
       .NPCOp(NPCOp_EX),
       .IMM(immout_EX),
       .NPC(NPC),
       .PCWrite(PCWrite),
       .aluout(aluout_EX)
    );

    // ???EX????????EX_MEM??????????
    assign EX_MEM_in = {PC_EX,RegWrite_EX, MemWrite_EX, WDSel_EX, GPRSel_EX, DMType_EX, aluout_EX, RD2_forwarded, rd_EX};

    // ???MEM????????MEM_WB??????????
    assign MEM_WB_in = {PC_MEM,RegWrite_MEM, WDSel_MEM, Data_in, aluout_MEM, rd_MEM};

    // WB???

    always @(*) begin
        case(WDSel_WB)  // WDSel???
            `WDSel_FromALU: RF_WD = aluout_WB;
            `WDSel_FromMEM: RF_WD = Data_in_WB;
            `WDSel_FromPC:  RF_WD = PC_WB + 4;
            default: RF_WD = 32'b0;
        endcase
    end


endmodule
