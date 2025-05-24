module Pixel_control(
    input wire [8:0] row,
    input wire [9:0] col,
    input wire [15:0] douta_VGA,
    input  wire [15:0] sw_i,
    input wire [15:0] VRAMS_out,
    output reg [11:0] Pixel
    );
    
    
    
    
    
    always @(*) begin
        if(sw_i[0] == 1) begin
            Pixel = douta_VGA[11:0];
        end
        else begin
            if(sw_i[8] == 0) begin
                Pixel = (row<240&&col<320)?douta_VGA[11:0]:0;
            end
            else begin
               case(VRAMS_out[2:0])
               3'b000:begin
                   Pixel = 12'h000;//ǽ��ɫ
               end
               3'b001:begin
                   Pixel = 12'hF84;//�հ״�����ɫ
               end
               3'b010:begin
                   Pixel = 12'h55F;//��ǳ��ɫ
               end
               3'b011:begin
                   Pixel = 12'h22A;//������ɫ
               end
               3'b100:begin
                   Pixel = 12'h8E8;//Ŀ���ǳ��ɫ
               end
               3'b101:begin
                   Pixel = 12'h0DF;//���ӵ���Ŀ����ɫ
               end
               default:begin
                   Pixel = 12'hFFF;//Ĭ�ϰ�ɫ
               end
               endcase
            end
        end
    end
    
    
    
    
    
    
    
endmodule