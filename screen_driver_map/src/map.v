module map(
	input sys_clk,
	input sys_rst,
	input [15:0]light,
	input get_map,
	output[15:0] mapped_light,
	output light_refresh
);
parameter map0 = 16'h0000;
parameter map1 = 16'h4898;
parameter map2 = 16'h637b;
parameter map3 = 16'h779d;
parameter map4 = 16'h8853;
parameter map5 = 16'h96e0;
parameter map6 = 16'ha3ea;
parameter map7 = 16'hafcf;
parameter map8 = 16'hbad0;
parameter map9 = 16'hc516;
parameter map10 = 16'hcec1;
parameter map11 = 16'hd7e8;
parameter map12 = 16'he09e;
parameter map13 = 16'he8f1;
parameter map14 = 16'hf0ec;
parameter map15 = 16'hf899;
parameter map16 = 16'hffff;

reg[4:0] interval;
reg[3:0] map_cnt;
reg[15:0] read_data;
reg[15:0] left_value;
reg[15:0] right_value;
reg[15:0] interval_length;
wire[19:0] ratio;
wire read_enable;

assign read_enable = map_cnt == 2 | map_cnt == 4;
assign light_refresh = map_cnt >= 8;
always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			read_data <= 16'b0;
		end
	else if(read_enable)
	begin
	   case(interval)
		  0:  read_data <= map0;
		  1:  read_data <= map1;
		  2:  read_data <= map2;
		  3:  read_data <= map3;
		  4:	read_data <= map4;
		  5:	read_data <= map5;
		  6: 	read_data <= map6;
		  7: 	read_data <= map7;
		  8:	read_data <= map8;
		  9: 	read_data <= map9;
		  10: read_data <= map10;
		  11: read_data <= map11;
		  12: read_data <= map12;
		  13: read_data <= map13;
		  14: read_data <= map14;
		  15: read_data <= map15;
		  16: read_data <= map16;
		  default: read_data <= map16;
		endcase
	end
end

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			map_cnt <= 4'b0;
		end
	else if(get_map)
		begin
			map_cnt<=  4'b1;
		end
	else if(map_cnt >= 1 && map_cnt <= 11)
		begin
			map_cnt <= map_cnt + 1'b1;
		end
	else if(map_cnt == 12)
		begin
			map_cnt <= 4'b0;
		end
end

always@(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		begin
			interval <= 5'b0;
		end
		else if(map_cnt >0)
		case(map_cnt)
			1:interval <= {1'b0,light[15:12]};
			2:;//get_data
			3:begin
				left_value <= read_data;
				interval <= {1'b0,light[15:12]} + 1'b1;
			  end
			4:;//get_data
			5:right_value <= read_data;
			6:interval_length <= right_value - left_value;
			default ; //no action
		endcase
end


assign ratio = interval_length * light[11:8] ;
assign mapped_light = {ratio/4'hf + left_value}[15:0];

endmodule
