module filter(
	input sys_clk,
	input sys_rst,
	input [15:0]gray,
	input [8:0]gray_index,
	input gray_update,
	input process_end,
	output reg [15:0]light,
	output reg [8:0]light_index,
	output filter_end,
	output get_map
);
reg [15:0] gray_ram[0:359];
reg [15:0] min;
reg [15:0] center_gray;
reg [15:0] compare_data;
reg [5:0] filter_cnt;

reg [8:0] center;
wire[8:0] top;
wire[8:0] bottom;
wire[8:0] left;
wire[8:0] right;
wire top_illegal;
wire left_illegal;
wire bottom_illegal;
wire right_illegal;
wire[16:0] correct_gray;

assign top = center - 8'd24;
assign bottom = center + 8'd24;
assign left = center - 1'b1;
assign right = center + 1'b1;

reg filter_running;
always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			filter_running<=1'b0;
		end
	else if(process_end)
		begin
			filter_running<=1'b1;
		end
	else if(filter_end)
		begin
			filter_running <= 1'b0;
		end
end

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			filter_cnt <= 6'b0;
		end
	else if(process_end | filter_end)
		begin
			filter_cnt <= 6'b0;
		end
	else if(filter_running && filter_cnt < 17)
		begin
			filter_cnt <= filter_cnt + 1'b1;
		end
	else if(filter_cnt == 17)
		begin
			filter_cnt <= 6'b0;
		end
end

assign get_data = filter_cnt >=1 && filter_cnt <= 11; 

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			compare_data <= 16'b0;
		end
	else if(gray_update)
	gray_ram[gray_index] <= gray;
	else if(get_data)
		case(filter_cnt)
		1:compare_data <= gray_ram[center];
		3:compare_data <= gray_ram[top];
		5:compare_data <= gray_ram[left];
		7:compare_data <= gray_ram[bottom];
		9:compare_data <= gray_ram[right];
		default: ;
		endcase
end

assign compare = get_data;
assign top_illegal = center>=0 && center <=23;
assign left_illegal = center % 24 == 0;
assign bottom_illegal = center >= 336 && center <= 359;
assign right_illegal = (center+1) % 24 == 0;
assign correct_gray = center_gray + min;

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			min <= 8'hFF;
		end
	else if(compare)
		case(filter_cnt)
			2:begin
					min <= compare_data;
					center_gray <= compare_data;
				end
			4:	if(!top_illegal && compare_data < min)
					min <= compare_data;
			6:begin
				if(!left_illegal && compare_data < min)
					min <= compare_data;
				end
			8:begin
				if(!bottom_illegal && compare_data < min)
					min <= compare_data;
				end
			10:begin
				if(!right_illegal && compare_data < min)
					min <= compare_data;
				end
			11:begin
					light <= correct_gray[16:1];
					light_index <= center;
				end
			default: ;
		endcase
end	

assign get_map = filter_cnt == 12;
assign filter_end = center == 359 && filter_cnt == 15; 
				
always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			center<=9'b0;
		end
	else if(process_end|filter_end)
		begin
			center<=9'b0;
 		end
	else if(filter_cnt == 16)
		begin
			center <= center + 1'b1;
		end
end

endmodule
