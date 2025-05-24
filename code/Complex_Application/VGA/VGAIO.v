module VGAIO (
    input             clk,
    input             rst,    //100MHzʱ��
    input      [11:0] Pixel,  //ͼ����ʾ�������룺RRRR_GGGG_BBBB
    output     [ 8:0] row,    // pixel ram row address, 480 lines
    output     [ 9:0] col,    // pixel ram col address, 640 pixels
    output     [ 3:0] R,
    G,
    B,
    output reg        HSYNC,
    VSYNC,
    output     [12:0] VRAMA,  //�ı���ʾ�����ַ
    output            rdn     //VAM��ַ
);

  wire [11:0] pixel_in = Pixel[11:0];
  wire h_sync;
  wire v_sync;
  wire read ;
  reg [3:0] red, green, blue;
  reg [15:0] VRAM_BUF;

  reg [ 2:0] VGACLK;
  always @(posedge clk or posedge rst) begin
    if (rst) 
        VGACLK <= 3'b0;  // ��λʱ��ʼ��Ϊ0
    else 
        VGACLK <= VGACLK + 1;
end

  //������ʾɨ��ͬ��ģ�飺vga_core        
  VGA_Scan VScans (
      .clk   (VGACLK[1]),  //25MHz                        
      .rst   (rst),
      .row   (row),        //����������
      .col   (col),        //����������
      .Active(read),       //��Ƶ��Ч
      .HSYNC (h_sync),     //��ɨ��ͬ��
      .VSYNC (v_sync)      //��ɨ��ͬ��
  );

  //vga signals���
  always @(posedge VGACLK[1]) begin
    HSYNC <= h_sync;  // horizontal synchronization
    VSYNC <= v_sync;  // vertical   synchronization
    red     <= read ? pixel_in[3:0] : 4'h0;  // 4-bit red
    green     <= read ? pixel_in[7:4] : 4'h0;  // 4-bit green
    blue     <= read ? pixel_in[11:8] : 4'h0;  // 4-bit blue
  end
    assign R = red;
    assign G = green;
    assign B = blue;
endmodule