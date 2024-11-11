module gray(
	 input sys_clk,
    input sys_rst,
	 input new_frame,
	 input[10:0] row_cnt,
	 input[10:0] column_cnt,
	 input[7:0] max,
	 output update,
	 output [8:0]index,
	 output reg[15:0] gray,
    output process_end
);
parameter width = 19;
parameter gray_width = 8'd16;
parameter gap = 8'd53;
parameter edge_column = 11'd1223;
parameter edge_row = 11'd746;

reg [width*24-1:0] data;
reg [gray_width-1:0] temp_data;
reg[10:0] start_column;
wire[10:0] end_column;
wire[10:0] final_end_column;
reg[10:0] start_row;
wire[10:0] end_row;
reg[5:0] current_block;
reg[5:0] group_row;
reg[5:0] group_column;
reg[5:0] process_cnt;
reg process_running;

wire calculate_enable;
wire calculate_end;

wire next_line;
wire next_block;
wire next_block1;
wire next_block2;
wire next_group;

wire get_data;
wire gray_process;

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			current_block <= 6'b0;
			start_column <= 11'h4;
			start_row <= 11'h4;
			group_row <= 6'b0;
		end
	else if(new_frame)
		begin
			current_block <= 6'b0;
			start_column <= 11'h4;
			start_row <= 11'h4;
			group_row <= 6'b0;
		end
	else if(next_block)
		begin
			current_block <= current_block + 1'b1;
			start_column <= start_column + gap;
		end
	else if(next_line)
		begin
			current_block <= 6'b0;
			start_column <= 11'h4;
		end
	else if(next_group)
		begin
			current_block <= 6'b0;
			start_column <= 11'h4;
			start_row <= start_row + gap;
		end
	else if(process_end)
		group_row <= group_row + 1'b1;
	else
		begin
			current_block <= current_block;
			start_column <= start_column;
			start_row <= start_row;
		end
end

assign end_row = start_row + 8'd45;
assign end_column = start_column + 8'd45;
assign final_end_column = start_column + 8'd22;
assign calculate_enable = row_cnt>=start_row && row_cnt<=end_row && column_cnt >= start_column && column_cnt<end_column;
assign next_line = start_column==edge_column && column_cnt == end_column && row_cnt != end_row;
assign next_block1 = column_cnt == end_column && start_column!= edge_column && row_cnt!=end_row;
assign next_block2 = column_cnt == final_end_column && start_column!= edge_column && row_cnt==end_row;
assign next_block = next_block1 | next_block2;
assign next_group = start_column==edge_column && row_cnt == end_row && column_cnt == final_end_column && start_row != edge_row;
assign calculate_end = start_column==edge_column && column_cnt == final_end_column && row_cnt == end_row;
//assign index = group_row*5'd24 + group_column;
assign index = {group_row[4:0],3'b0}+{group_row[4:0],4'b0}+group_column;

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			data <= 0;
		end
	else if(new_frame | process_end)
		begin
			data <= 0;
		end
	else if(calculate_enable)
		begin
			case(current_block)
			0:  data[width-1:0] <= data[width-1:0] + max;
			1:  data[width*2-1:width] <= data[width*2-1:width] + max;
			2:  data[width*3-1:width*2] <= data[width*3-1:width*2] + max;
			3:  data[width*4-1:width*3] <= data[width*4-1:width*3] + max;
			4:  data[width*5-1:width*4] <= data[width*5-1:width*4] + max;
			5:  data[width*6-1:width*5] <= data[width*6-1:width*5] + max;
			6:  data[width*7-1:width*6] <= data[width*7-1:width*6] + max;
			7:  data[width*8-1:width*7] <= data[width*8-1:width*7] + max;
			8:  data[width*9-1:width*8] <= data[width*9-1:width*8] + max;
			9:  data[width*10-1:width*9] <= data[width*10-1:width*9] + max;
			10: data[width*11-1:width*10] <= data[width*11-1:width*10] + max;
			11: data[width*12-1:width*11] <= data[width*12-1:width*11] + max;
			12: data[width*13-1:width*12] <= data[width*13-1:width*12] + max;
			13: data[width*14-1:width*13] <= data[width*14-1:width*13] + max;
			14: data[width*15-1:width*14] <= data[width*15-1:width*14] + max;
			15: data[width*16-1:width*15] <= data[width*16-1:width*15] + max;
			16: data[width*17-1:width*16] <= data[width*17-1:width*16] + max;
			17: data[width*18-1:width*17] <= data[width*18-1:width*17] + max;
			18: data[width*19-1:width*18] <= data[width*19-1:width*18] + max;
			19: data[width*20-1:width*19] <= data[width*20-1:width*19] + max;
			20: data[width*21-1:width*20] <= data[width*21-1:width*20] + max;
			21: data[width*22-1:width*21] <= data[width*22-1:width*21] + max;
			22: data[width*23-1:width*22] <= data[width*23-1:width*22] + max;
			23: data[width*24-1:width*23] <= data[width*24-1:width*23] + max;
            default: ; // 没有匹配的case项时不执行任何操作
			endcase
		end
	else if(get_data)
		begin
			case(group_column)
			0: temp_data <= data[width-1:width-gray_width];
			1: temp_data <= data[width*2-1:width*2-gray_width];
			2: temp_data <= data[width*3-1:width*3-gray_width];
			3: temp_data <= data[width*4-1:width*4-gray_width];
			4: temp_data <= data[width*5-1:width*5-gray_width];
			5: temp_data <= data[width*6-1:width*6-gray_width];
			6: temp_data <= data[width*7-1:width*7-gray_width];
			7: temp_data <= data[width*8-1:width*8-gray_width];
			8: temp_data <= data[width*9-1:width*9-gray_width];
			9: temp_data <= data[width*10-1:width*10-gray_width];
			10: temp_data <= data[width*11-1:width*11-gray_width];
			11: temp_data <= data[width*12-1:width*12-gray_width];
			12: temp_data <= data[width*13-1:width*13-gray_width];
			13: temp_data <= data[width*14-1:width*14-gray_width];
			14: temp_data <= data[width*15-1:width*15-gray_width];
			15: temp_data <= data[width*16-1:width*16-gray_width];
			16: temp_data <= data[width*17-1:width*17-gray_width];
			17: temp_data <= data[width*18-1:width*18-gray_width];
			18: temp_data <= data[width*19-1:width*19-gray_width];
			19: temp_data <= data[width*20-1:width*20-gray_width];
			20: temp_data <= data[width*21-1:width*21-gray_width];
			21: temp_data <= data[width*22-1:width*22-gray_width];
			22: temp_data <= data[width*23-1:width*23-gray_width];
			23: temp_data <= data[width*24-1:width*24-gray_width];
			default: temp_data <= temp_data;
        endcase
		end
end

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			process_running <= 1'b0;
		end
	else if(calculate_end)
		begin
			process_running <= 1'b1;
		end
	else if(process_end)
		begin
			process_running <= 1'b0;
		end
end

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			process_cnt <= 6'b0;
		end
	else if(process_running && process_cnt != 6'd20)
		begin
			process_cnt <= process_cnt + 1'b1;
		end
	else if(process_cnt == 6'd20)
		begin
			process_cnt <= 6'b0;
		end
end

assign get_data = process_cnt == 4'h1;
assign gray_process = process_cnt == 4'h2;
assign update = process_cnt > 4'h3 && process_cnt < 4'd15;
assign group_column_update = process_cnt == 6'd16;
assign process_end = group_column == 24 && process_cnt == 6'd20;

//在此处对灰度值进行处理后送至灯板处
always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			group_column <= 6'h0;
			gray <= 16'h0;
		end
	else if(gray_process)
		begin
			gray <= temp_data;
		end
	else if(group_column_update)
		begin
			group_column <= group_column + 1'b1;
		end
	else if(process_end)
		begin
			group_column <= 6'h0;
		end
end

endmodule
