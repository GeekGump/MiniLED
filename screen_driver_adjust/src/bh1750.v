module BH1750_drive(		
	input			clk,					//输入时钟=50M
	input 			rst,					//输入复位信号，低电平有效
	output 			scl,					//输出I2C时钟管脚
	inout 			sda,					//I2C数据管脚
	output  		dvi,                   //BH1750DVI上电配置管脚
    output       [15:0]data_out	//BH1750数据输出管脚
	);
	
	reg				r_scl;					//I2C_SCL寄存器
	reg 			r_sda;					//I2C_SDA寄存器
	reg 			ctl_sda;				//sda输入/输出控制
	assign sda = ctl_sda ? r_sda : 1'bz;	//配置三态接口
	assign scl = r_scl;				
	assign dvi = 1;               			//配置上电
	
	reg		[15:0]	data;					//数据采集管脚
	assign data_out = data[15:0];
	
	reg	[11:0]  cnt_100khz;					//定义一个计数器，用于产生100Khz时钟
	reg clk_100khz;								//产生100Khz的时钟

	always @ (posedge clk or negedge rst) begin   //posedge上升沿触发或者negedge下降沿触发
    if (!rst) begin
        cnt_100khz <= 12'd0;
        clk_100khz  <= 1'b0;
    end 
    else if (cnt_100khz < 12'd250) 
        cnt_100khz <= cnt_100khz + 1'b1;       
    else begin
        cnt_100khz <= 12'd0;
        clk_100khz  <= ~ clk_100khz;
    end 
end	
	
	parameter [7:0] DEVICE_ADDR_W 	 = 8'h46;	//BH1750FVI设备地址+写
	parameter [7:0] DEVICE_ADDR_R 	 = 8'h47;	//BH1750FVI设备地址+读
	parameter [7:0] DEVICE_POWER_OFF = 8'h00;	//BH1750FVI设备关断
	parameter [7:0] DEVICE_POWER_ON  = 8'h01;	//BH1750FVI设备上电
	parameter [7:0] DEVICE_MEASURE   = 8'h13;	//BH1750FVI设备测量环境光
	
	
	reg [11:0] cnt;								
	always@(posedge clk_100khz or negedge rst) begin
		if(!rst) begin
			ctl_sda<=1'b1;r_sda<=1'b1;
			r_scl<=1'b1;
			cnt<=0;
		end else begin
			cnt<=cnt+1'b1;
			case(cnt)
//外部地址+写+断电---------------------------------------------------------//
				0:	begin ctl_sda<=1'b1; 	end
				//START
				1:	begin r_scl<=1'b1;	 	end
				2:	begin r_sda<=1'b1;		end
				3:	begin r_sda<=1'b0;		end
				//ADDRESS+WRITE 8'H46
				4:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[7]; end
				5:	begin r_scl<=1'b1;							 end
				
				6:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[6]; end
				7:	begin r_scl<=1'b1;	 end
				
				8:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[5]; end
				9:	begin r_scl<=1'b1;	 end

			   10:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[4]; end
			   11:	begin r_scl<=1'b1;	 end				
		
			   12:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[3]; end
			   13:	begin r_scl<=1'b1;	 end
		
			   14:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[2]; end
			   15:	begin r_scl<=1'b1;	 end		
		
			   16:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[1]; end
			   17:	begin r_scl<=1'b1;	 end	
		
			   18:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[0]; end
			   19:	begin r_scl<=1'b1;	 end
			   20:	begin r_scl<=1'b0;	 end
			   
			   21:	begin ctl_sda<=1'b0; end
			   22:	begin r_scl<=1'b1;	 end
			   23: 	begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=24; 
						end else
							cnt<=22; 
						end
			   //POWER OFF 8'H00
			   24:	begin ctl_sda<=1'b1; end
			   25:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[7]; end
			   26:	begin r_scl<=1'b1 ;   end	

			   27:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[6]; end
			   28:	begin r_scl<=1'b1 ;   end	

			   29:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[5]; end
			   30:	begin r_scl<=1'b1 ;   end	

			   31:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[4]; end
			   32:	begin r_scl<=1'b1 ;   end	

			   33:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[3]; end
			   34:	begin r_scl<=1'b1 ;   end	

			   35:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[2]; end
			   36:	begin r_scl<=1'b1 ;   end	

			   37:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[1]; end
			   38:	begin r_scl<=1'b1 ;   end		

			   39:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_OFF[0]; end
			   40:	begin r_scl<=1'b1 ;   end	
			   41:  begin r_scl<=1'b0;	  end
			   
			   42:	begin ctl_sda<=1'b0;  end
			   43:	begin r_scl<=1'b1;	  end
			   44:	begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=45;
						end else
							cnt<=43; 
						end				
			   45: 	begin ctl_sda<=1'b1;	end		
			   //STOP
			   46:	begin r_scl<=1'b1;	   end
			   47:  begin r_sda<=1'b0;	   end
			   48:	begin r_sda<=1'b1;	   end
//外部地址+写+上电---------------------------------------------------------//
				49:	begin ctl_sda<=1'b1;	end
				//START
				50:	begin r_scl<=1'b1;	 	end
				51:	begin r_sda<=1'b1;		end
				52:	begin r_sda<=1'b0;		end
				//ADDRESS+WRITE 8'H46
				53:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[7]; end
				54:	begin r_scl<=1'b1;							 end
				
				55:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[6]; end
				56:	begin r_scl<=1'b1;	 end
				
				57:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[5]; end
				58:	begin r_scl<=1'b1;	 end

			    59:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[4]; end
			    60:	begin r_scl<=1'b1;	 end				
		
			    61:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[3]; end
			    62:	begin r_scl<=1'b1;	 end
		
			    63:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[2]; end
			    64:	begin r_scl<=1'b1;	 end		
		
			    65:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[1]; end
			    66:	begin r_scl<=1'b1;	 end	
		
			    67:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[0]; end
			    68:	begin r_scl<=1'b1;	 end
			    69:	begin r_scl<=1'b0;	 end
			   
			    70:	begin ctl_sda<=1'b0; end
			    71:	begin r_scl<=1'b1;	 end
			    72: begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=73;
						end else
							cnt<=71; 
						end
			   //POWER OFF 8'H00
			    73:	begin ctl_sda<=1'b1; end
			    74:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[7]; end
			    75:	begin r_scl<=1'b1 ;   end	

			    76:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[6]; end
			    77:	begin r_scl<=1'b1 ;   end	

			    78:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[5]; end
			    79:	begin r_scl<=1'b1 ;   end	

			    80:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[4]; end
			    81:	begin r_scl<=1'b1 ;   end	

			    82:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[3]; end
			    83:	begin r_scl<=1'b1 ;   end	

			    84:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[2]; end
			    85:	begin r_scl<=1'b1 ;   end	

			    86:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[1]; end
			    87:	begin r_scl<=1'b1 ;   end		

			    88:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_POWER_ON[0]; end
			    89:	begin r_scl<=1'b1 ;   end	
			    90:  begin r_scl<=1'b0;	  end
			   
			    91:	begin ctl_sda<=1'b0;  end
			    92:	begin r_scl<=1'b1;	  end
			    93:	begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=94;
						end else
							cnt<=92; 
						end				
			    94: begin ctl_sda<=1'b1;	end		
			   //STOP
			    95:	begin r_scl<=1'b1;	   end
			    96: begin r_sda<=1'b0;	   end
			    97:	begin r_sda<=1'b1;	   end	
//外部地址+写+读取单次---------------------------------------------------------		
				98:		begin ctl_sda<=1'b1;	end
				//START
				99:		begin r_scl<=1'b1;	 	end
				100:	begin r_sda<=1'b1;		end
				101:	begin r_sda<=1'b0;		end
				//ADDRESS+WRITE 8'H46
				102:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[7]; end
				103:	begin r_scl<=1'b1;							 end
				
				104:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[6]; end
				105:	begin r_scl<=1'b1;	 end
				
				106:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[5]; end
				107:	begin r_scl<=1'b1;	 end

			    108:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[4]; end
			    109:	begin r_scl<=1'b1;	 end				
		
			    110:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[3]; end
			    111:	begin r_scl<=1'b1;	 end
		
			    112:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[2]; end
			    113:	begin r_scl<=1'b1;	 end		
		
			    114:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[1]; end
			    115:	begin r_scl<=1'b1;	 end	
		
			    116:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_W[0]; end
			    117:	begin r_scl<=1'b1;	 end
			    118:	begin r_scl<=1'b0;	 end
			   
			    119:	begin ctl_sda<=1'b0; end
			    120:	begin r_scl<=1'b1;	 end
			    121:	begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=122;
						end else
							cnt<=120; 
						end
			   //POWER OFF 8'H23
			    122:	begin ctl_sda<=1'b1; end
			    123:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[7]; end
			    124:	begin r_scl<=1'b1 ;   end	

			    125:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[6]; end
			    126:	begin r_scl<=1'b1 ;   end	

			    127:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[5]; end
			    128:	begin r_scl<=1'b1 ;   end	

			    129:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[4]; end
			    130:	begin r_scl<=1'b1 ;   end	

			    131:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[3]; end
			    132:	begin r_scl<=1'b1 ;   end	

			    133:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[2]; end
			    134:	begin r_scl<=1'b1 ;   end	

			    135:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[1]; end
			    136:	begin r_scl<=1'b1 ;   end		

			    137:	begin r_scl<=1'b0 ;  r_sda<=DEVICE_MEASURE[0]; end
			    138:	begin r_scl<=1'b1 ;   end	
			    139:    begin r_scl<=1'b0;	  end
			   
			    140:	begin ctl_sda<=1'b0;  end
			    141:	begin r_scl<=1'b1;	  end
			    142:	begin 
						r_scl<=1'b0;
						if(sda==1'b0) begin
							cnt<=143;
						end else
							cnt<=141; 
						end				
			    143:    begin ctl_sda<=1'b1;	end		
			   //STOP
			    144:	begin r_scl<=1'b1;	   end
			    145:	begin r_sda<=1'b0;	   end
			    146:	begin r_sda<=1'b1;	   end	
//读取测量值---------------------------------------------------------
				2147:	begin ctl_sda<=1'b1;	end
				//START
				2148:	begin r_scl<=1'b1;	 	end
				2149:	begin r_sda<=1'b1;		end
				2150:	begin r_sda<=1'b0;		end
				//ADDRESS+WRITE 8'H46
				2151:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[7]; end
				2152:	begin r_scl<=1'b1;							 end
				
				2153:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[6]; end
				2154:	begin r_scl<=1'b1;	 end
				
				2155:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[5]; end
				2156:	begin r_scl<=1'b1;	 end

			    2157:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[4]; end
			    2158:	begin r_scl<=1'b1;	 end				
		
			    2159:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[3]; end
			    2160:	begin r_scl<=1'b1;	 end
		
			    2161:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[2]; end
			    2162:	begin r_scl<=1'b1;	 end		
		
			    2163:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[1]; end
			    2164:	begin r_scl<=1'b1;	 end	
		
			    2165:	begin r_scl<=1'b0;	r_sda<=DEVICE_ADDR_R[0]; end
			    2166:	begin r_scl<=1'b1;	 end
			    2167:	begin r_scl<=1'b0;	r_sda<=1; end
			   
			    2168:	begin ctl_sda<=1'b0; end
				2169:	begin r_scl<=1'b1;	 end
			    2170:	begin r_scl<=1'b0;	
						if(sda==1'b0)
							begin 
								cnt<=2171;  	end
							else
								cnt<=2169;
						end			 
						
			   //READ
			    2171:	begin r_scl<=1'b1 ;    end
			    2172:	begin data[15]=sda ;   end
			    2173:	begin r_scl<=1'b0 ;   end	

			    2174:	begin r_scl<=1'b1 ;   end
			    2175:	begin data[14]=sda ;  end	
			    2176:	begin r_scl<=1'b0 ;   end
			   
  			    2177:	begin r_scl<=1'b1 ;   end	
			    2178:	begin data[13]=sda ;  end
			    2179:	begin r_scl<=1'b0 ;   end	

			    2180:	begin r_scl<=1'b1 ;   end
			    2181:	begin data[12]=sda ;  end	
			    2182:	begin r_scl<=1'b0 ;   end
			    
				2183:	begin r_scl<=1'b1 ;   end	
			    2184:	begin data[11]=sda ;  end
			    2185:	begin r_scl<=1'b0 ;   end		

			    2186:	begin r_scl<=1'b1 ;   end
			    2187:	begin data[10]=sda ;  end	
			    2188:   begin r_scl<=1'b0;	  end
			   
			    2189:	begin r_scl<=1'b1;  end
			    2190:	begin data[9]=sda ;  end
			    2191:	begin r_scl<=1'b0;  end	
									
			    2192:   begin r_scl<=1'b1;	end		
				2193:	begin data[8]=sda ;  end
				2194:	begin r_scl<=1'b0;	  end
					
				2195:	begin r_scl<=1'b1;ctl_sda<=1'b1;r_sda<=1'b0;end
				
				2196:	begin r_scl<=1'b1; end           
				
				2197:	begin r_scl<=1'b0; ctl_sda<=1'b1; r_sda<=1'b1;	end
				
				2198:	begin ctl_sda<=0;end
			    
				2199:	begin r_scl<=1'b1 ;   end
			    2200:	begin data[7]=sda ;   end
			    2201:	begin r_scl<=1'b0 ;   end	

			    2202:	begin r_scl<=1'b1 ;   end
			    2203:	begin data[6]=sda ;   end	
			    2204:	begin r_scl<=1'b0 ;   end
			   
  			    2205:	begin r_scl<=1'b1 ;   end	
			    2206:	begin data[5]=sda ;   end
			    2207:	begin r_scl<=1'b0 ;   end	

			    2208:	begin r_scl<=1'b1 ;   end
			    2209:	begin data[4]=sda ;   end	
			    2210:	begin r_scl<=1'b0 ;   end
			    
				2211:	begin r_scl<=1'b1 ;   end	
			    2212:	begin data[3]=sda ;   end
			    2213:	begin r_scl<=1'b0 ;   end		

			    2214:	begin r_scl<=1'b1 ;   end
			    2215:	begin data[2]=sda ;   end	
			    2216:   begin r_scl<=1'b0;	  end
			   
			    2217:	begin r_scl<=1'b1;    end
			    2218:	begin data[1]=sda ;   end
			    2219:	begin r_scl<=1'b0;    end	
									
			    2220:   begin r_scl<=1'b1;	  end		
				2221:	begin data[0]=sda ;   end
				2222:	begin r_scl<=1'b0;	  end
					
				2223:   begin ctl_sda<=1'b1; r_sda<=1;end
				
			   default:begin r_scl<=1'b1; ctl_sda<=1'b0;  end
			endcase
		end
	end

endmodule
