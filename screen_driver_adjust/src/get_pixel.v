module get_pixel(
    input sys_rst,
    input pixel_clk,
    input hs,
    input vs,
    input data_vld,
	 input [7:0] R,
	 input [7:0] G,
	 input [7:0] B,
    output new_frame,
    output reg[10:0] row_cnt,
    output reg[10:0] column_cnt,
    output reg [7:0] max
);
wire hs_temp;
wire vs_temp;
assign hs_temp = hs;
assign vs_temp = vs;
reg hs_delaya;
reg hs_delayb;
reg vs_delaya;
reg vs_delayb;
reg [7:0] temp;
wire new_row;

always@(posedge pixel_clk or negedge sys_rst)begin
    if(!sys_rst)
        begin
            hs_delaya<=1'b1;
            hs_delayb<=1'b1;
        end
    else
        begin
            hs_delaya<=hs_temp;
            hs_delayb<=hs_delaya;
        end
end 

assign new_row = hs_delayb&(!hs_delaya);

//打拍器，检测新帧
always@(posedge pixel_clk or negedge sys_rst)begin
    if(!sys_rst)
        begin
            vs_delaya<=1'b1;
            vs_delayb<=1'b1;
        end
    else
        begin
            vs_delaya<=vs_temp;
            vs_delayb<=vs_delaya;
        end
end 

assign new_frame = (vs_delayb)&(!vs_delaya);

//记录行数与列数
always@(posedge pixel_clk or negedge sys_rst)begin
    if(!sys_rst)
        begin
            row_cnt<=11'b0;
            column_cnt<=11'b0;
        end
    else if(new_frame)
        begin
            row_cnt<=11'b0;
            column_cnt<=11'b0;
        end
    else if(new_row)
        begin
            row_cnt <= row_cnt + 1'b1;
            column_cnt<= 11'b0;
        end
    else if(data_vld)
		  begin
				column_cnt<= column_cnt+1'b1;
		  end
end

//取RGB最大值为亮度

always@(posedge pixel_clk or negedge sys_rst)begin
     if(!sys_rst)
        begin
            max<= 8'b0;
        end
	else if((R>G) && (R>B))
        begin
        max <= R;
        end
    else if((G>B) && (G>R))
        begin
        max <= G;
        end
    else begin
        max<=B;
       end
end

endmodule
