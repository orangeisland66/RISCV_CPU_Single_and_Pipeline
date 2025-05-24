`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC 2'b10
module PCPU(
    input   clk,            // clock
    input   reset,          // reset
    input   INT,
    input   MIO_ready,
    input   [31:0]  inst_in,// instruction
    input   [31:0]  Data_in,// data from data memory
          
    output  mem_w,          // output: memory write signal
    output  [31:0] PC_out,  // PC address

    output  [31:0] Addr_out,// ALU output
    output  [31:0] Data_out,// data to data memory
           
    output  CPU_MIO,
    //input  [4:0] reg_sel,      // register selection (for debug use)
    //output [31:0] reg_data,    // selected register data (for debug use)
    output  [2:0] dm_ctrl
);
    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation

    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
   
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;         // rs
    wire [4:0]  rs2;         // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg  [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;     // register data specified by rs
    wire [31:0] B;           // operator for ALU B
	
	wire [4:0]  iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire [31:0] aluout;
    
    wire [255:0] MEM_WB_in;
    wire [255:0] MEM_WB_out;
    
    wire [255:0] EX_MEM_in;
    wire [255:0] EX_MEM_out;
    
    wire Stall;
    
    wire IF_ID_flush;
    wire ID_EX_flush;
    wire EX_MEM_flush;
    wire MEM_WB_flush;
    
    wire [2:0] True_NPCOp;
    
    wire [31:0] MEM_PC,MEM_RD2,MEM_aluout;
    wire [4:0] MEM_rd;
    wire [2:0] MEM_DMType,MEM_WDSel;
    wire MEM_RegWrite,MEM_Mem_w;
    
    wire flush;
    
    wire [255:0] IF_ID_in;
    wire [255:0] IF_ID_out;
    wire [31:0] ID_PC,ID_inst;
    
    wire [31:0] instruction;
    
    wire [2:0] DMType;
    wire Mem_w;
    wire Mem_r;
    
    wire [255:0] ID_EX_in;
    wire [255:0] ID_EX_out;
    wire [31:0] EX_PC,EX_RD1,EX_RD2,EX_immout;
    wire [4:0] EX_rs1,EX_rs2,EX_rd;
    wire EX_ALUSrc,EX_RegWrite,EX_Mem_w,EX_Mem_r;
    wire [4:0]EX_ALUOp;
    wire [2:0]EX_NPCOp,EX_DMType;
    wire [1:0]EX_WDSel;
    
    wire [1:0] forwardA;
    wire [1:0] forwardB;
    reg [31:0] ALU_A;
    reg [31:0] ALU_B;
    
    wire [31:0] WB_PC;
    wire [4:0] WB_rd;
    wire WB_RegWrite;
    wire [1:0] WB_WDSel;
    wire [31:0] WB_Data_in;
    wire [31:0] WB_aluout; 
    
    wire [4:0] True_ALUOp;
    
    assign IF_ID_flush = flush; 
    assign ID_EX_flush = flush || Stall;
    assign EX_MEM_flush = 1'b0;
    assign MEM_WB_flush = 1'b0;
	
    //IF_ID

    
    assign IF_ID_in [31:0] = PC_out;
    assign IF_ID_in [63:32] = inst_in;
    assign ID_PC = IF_ID_out [31:0];
    assign ID_inst = IF_ID_out [63:32];
    GRE_array #(256) IF_ID(
        .clk(clk),
        .rst(reset),
        .write_enable(~Stall),
        .flush(IF_ID_flush),
        .in(IF_ID_in),
        .out(IF_ID_out)
    );
    
    //ctrl EXT RF
    
    
    assign instruction = ID_inst;
	
	assign iimm_shamt = instruction[24:20];
	assign iimm = instruction[31:20];
	assign simm = {instruction[31:25],instruction[11:7]};
	assign bimm = {instruction[31],instruction[7],instruction[30:25],instruction[11:8]};
	assign uimm = instruction[31:12];
	assign jimm = {instruction[31],instruction[19:12],instruction[20],instruction[30:21]};
   
    assign Op = instruction[6:0];  // instruction
    assign Funct7 = instruction[31:25]; // funct7
    assign Funct3 = instruction[14:12]; // funct3
    assign rs1 = instruction[19:15];  // rs1
    assign rs2 = instruction[24:20];  // rs2
    assign rd = instruction[11:7];  // rd
    assign Imm12 = instruction[31:20];// 12-bit immediate
    assign IMM = instruction[31:12];  // 20-bit immediate
     
    //ID_EX
    
    assign ID_EX_in [31:0] = ID_PC;
    assign ID_EX_in [63:32] = RD1;
    assign ID_EX_in [95:64] = RD2;
    assign ID_EX_in [127:96] = immout;
    assign ID_EX_in [132:128] = rs1;
    assign ID_EX_in [137:133] = rs2;
    assign ID_EX_in [142:138] = rd;
    assign ID_EX_in [143] = ALUSrc;
    assign ID_EX_in [148:144] = ALUOp;
    assign ID_EX_in [151:149] = NPCOp;
    assign ID_EX_in [154:152] = DMType;
    assign ID_EX_in [155] = RegWrite;
    assign ID_EX_in [157:156] = WDSel;
    assign ID_EX_in [158] = Mem_w;
    assign ID_EX_in [159] = Mem_r;
    assign EX_PC = ID_EX_out [31:0];
    assign EX_RD1 = ID_EX_out [63:32];
    assign EX_RD2 = ID_EX_out [95:64];
    assign EX_immout = ID_EX_out [127:96];
    assign EX_rs1 = ID_EX_out [132:128];
    assign EX_rs2 = ID_EX_out [137:133];
    assign EX_rd = ID_EX_out [142:138];
    assign EX_ALUSrc = ID_EX_out [143];
    assign EX_ALUOp = ID_EX_out [148:144];
    assign EX_NPCOp = ID_EX_out [151:149];
    assign EX_DMType = ID_EX_out [154:152];
    assign EX_RegWrite = ID_EX_out [155];
    assign EX_WDSel = ID_EX_out [157:156];
    assign EX_Mem_w = ID_EX_out [158];
    assign EX_Mem_r = ID_EX_out [159];
    
    
    
    GRE_array #(256) ID_EX(
        .clk(clk),
        .rst(reset),
        .write_enable(1'b1),
        .flush(ID_EX_flush),
        .in(ID_EX_in),
        .out(ID_EX_out)
    );
    
    

    
    always @(*)
    begin
	   case(forwardA)
		  2'b00: ALU_A<=EX_RD1;
		  2'b01: ALU_A<=WD;
		  2'b10: ALU_A<=MEM_aluout;
	   endcase
	   case(forwardB)
		  2'b00: ALU_B<=EX_RD2;
		  2'b01: ALU_B<=WD;
		  2'b10: ALU_B<=MEM_aluout;
	   endcase
    end
    

    assign B = (EX_ALUSrc) ? EX_immout : ALU_B;

    assign True_NPCOp = {EX_NPCOp[2:1], EX_NPCOp[0] & Zero};
    //EX_MEM

    
    assign EX_MEM_in [31:0] = EX_PC;//PC
    assign EX_MEM_in [63:32] = aluout;
    assign EX_MEM_in [95:64] = ALU_B;//RD2
    assign EX_MEM_in [100:96] = EX_rd;//rd
    assign EX_MEM_in [103:101] = EX_DMType;//dm_ctrl
    assign EX_MEM_in [104] = EX_RegWrite;//RegWrite
    assign EX_MEM_in [106:105] = EX_WDSel;//WDSel
    assign EX_MEM_in [107] = EX_Mem_w;//mem_w
    assign MEM_PC = EX_MEM_out [31:0];
    assign MEM_aluout = EX_MEM_out [63:32];
    assign MEM_RD2 = EX_MEM_out [95:64];
    assign MEM_rd = EX_MEM_out [100:96];
    assign MEM_DMType = EX_MEM_out [103:101];
    assign MEM_RegWrite = EX_MEM_out [104];
    assign MEM_WDSel = EX_MEM_out [106:105];
    assign MEM_Mem_w = EX_MEM_out [107];
    
    GRE_array #(256) EX_MEM(
        .clk(clk),
        .rst(reset),
        .write_enable(1'b1),
        .flush(EX_MEM_flush),
        .in(EX_MEM_in),
        .out(EX_MEM_out)
    );
    
    assign Addr_out = MEM_aluout;
	assign Data_out = MEM_RD2;
	assign dm_ctrl = MEM_DMType;
	assign mem_w = MEM_Mem_w;

    //MEM_WB
    
    assign MEM_WB_in [31:0] = MEM_PC;//PC
    assign MEM_WB_in [36:32] = MEM_rd;//rd
    assign MEM_WB_in [37] = MEM_RegWrite;//RegWrite
    assign MEM_WB_in [39:38] = MEM_WDSel;//WDSel
    assign MEM_WB_in [71:40] = Data_in;
    assign MEM_WB_in [103:72] = MEM_aluout;//aluout
    assign WB_PC = MEM_WB_out [31:0];
    assign WB_rd = MEM_WB_out [36:32];
    assign WB_RegWrite = MEM_WB_out [37];
    assign WB_WDSel = MEM_WB_out [39:38];
    assign WB_Data_in = MEM_WB_out [71:40];
    assign WB_aluout = MEM_WB_out [103:72];
    
    GRE_array #(256) MEM_WB(
        .clk(clk),
        .rst(reset),
        .write_enable(1'b1),
        .flush(MEM_WB_flush),
        .in(MEM_WB_in),
        .out(MEM_WB_out)
    );

    RF U_RF(
	   .clk(clk), .rst(reset),
	   .RFWr(WB_RegWrite), 
	   .A1(rs1), .A2(rs2), .A3(WB_rd), 
	   .WD(WD),
	   .RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);
	
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC),.Stall(Stall), .PC(PC_out) );
	NPC U_NPC(.PC(PC_out), .NPCOp(True_NPCOp), .IMM(EX_immout), .NPC(NPC),.JumpPC(EX_PC),.flush(flush), .aluout(aluout));
	alu U_alu(.A(ALU_A), .B(B), .ALUOp(EX_ALUOp), .C(aluout), .Zero(Zero), .PC(EX_PC));
	
	Forwarding_unit forwarding_unit(
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .MEM_rd(MEM_rd),
        .WB_rd(WB_rd),
        .Mem_RegWrite(MEM_RegWrite),
        .WB_RegWrite(WB_RegWrite),
        .ForwardA(forwardA),
        .ForwardB(forwardB)
    );
    Hazard_detecction_unit hazard_detecction_unit(
        .EX_Mem_r(EX_Mem_r),
        .rs1(rs1),
        .rs2(rs2),
        .EX_rd(EX_rd),
        .Stall(Stall)
    );
    
    ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), 
		.RegWrite(RegWrite), .MemWrite(Mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc),.DMType(DMType), .GPRSel(GPRSel), .WDSel(WDSel), .MemRead(Mem_r)
	);
    
    EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

always @*
begin
	case(WB_WDSel)
		`WDSel_FromALU: WD<=WB_aluout;
		`WDSel_FromMEM: WD<=WB_Data_in;
		`WDSel_FromPC: WD<= WB_PC+4;
	endcase
end


endmodule