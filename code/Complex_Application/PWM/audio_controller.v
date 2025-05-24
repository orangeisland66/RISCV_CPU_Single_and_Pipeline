module audio_controller (
    input wire clk,
    input wire reset,
    output wire [7:0] audio_data,
    output reg audio_valid,
    output reg [1:0] sample_phase
);

parameter CLK_FREQ = 100_000_000;  // 100MHz主时钟
parameter SAMPLE_RATE = 8000;      // 8kHz采样率
localparam SAMPLES_PER_WORD = 4;   // 每个ROM数据含4个8bit采样
localparam DIVIDER = CLK_FREQ / (SAMPLE_RATE * SAMPLES_PER_WORD);  // 3125

reg [$clog2(DIVIDER)-1:0] div_counter;
reg [17:0] addr_counter;

// ROM接口信号
wire [31:0] rom_data;

blk_mem_gen_0 PWM (
    .addra(addr_counter),
    .clka(clk),
    .wea(4'b0000),
    .douta(rom_data)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        div_counter <= 0;
        addr_counter <= 0;
        sample_phase <= 0;
        audio_valid <= 0;
    end else begin
        if (div_counter == DIVIDER - 1) begin
            div_counter <= 0;
            audio_valid <= 1'b1;

            sample_phase <= sample_phase + 1;
            if (sample_phase == SAMPLES_PER_WORD - 1) begin
                sample_phase <= 0;
                addr_counter <= addr_counter + 1;
            end
        end else begin
            div_counter <= div_counter + 1;
            audio_valid <= 1'b0;
        end
    end
end

assign audio_data = (sample_phase == 0) ? rom_data[7:0] :
                    (sample_phase == 1) ? rom_data[15:8] :
                    (sample_phase == 2) ? rom_data[23:16] :
                                          rom_data[31:24];

endmodule