// ==============0ooo===================================================0ooo===========
// =  Copyright (C) 2014-2020 Gowin Semiconductor Technology Co.,Ltd.
// =                     All rights reserved.
// ====================================================================================
// 
//  __      __      __
//  \ \    /  \    / /   [File name   ] lvds_video_top.v
//   \ \  / /\ \  / /    [Description ] LVDS Video
//    \ \/ /  \ \/ /     [Timestamp   ] Friday November 20 14:00:30 2020
//     \  /    \  /      [version     ] 1.0
//      \/      \/
//
// ==============0ooo===================================================0ooo===========
// Code Revision History :
// ----------------------------------------------------------------------------------
// Ver:    |  Author    | Mod. Date    | Changes Made:
// ----------------------------------------------------------------------------------
// V1.0    | Caojie     | 11/20/20     | Initial version 
// ----------------------------------------------------------------------------------
// ==============0ooo===================================================0ooo===========

module lvds_video_top
(
    input          I_clk       ,  //50MHz      
    input          I_rst_n     ,
    input          I_clkin_p   ,  //LVDS Input
    input          I_clkin_n   ,  //LVDS Input
    input  [3:0]   I_din_p     ,  //LVDS Input
    input  [3:0]   I_din_n     ,  //LVDS Input    
    output         O_clkout_p  ,
    output         O_clkout_n  ,
    output [3:0]   O_dout_p    ,
    output [3:0]   O_dout_n   ,
    output light_refresh,
    output[15:0] mapped_light,
    output[8:0] light_index
);

//======================================================
reg  [31:0] run_cnt;
//--------------------------
wire [7:0]  r_R_0;  // Red,   8-bit data depth
wire [7:0]  r_G_0;  // Green, 8-bit data depth
wire [7:0]  r_B_0;  // Blue,  8-bit data depth
wire        r_Vsync_0;
wire        r_Hsync_0;
wire        r_DE_0   ;

wire [7:0] max;
wire new_frame;
wire [10:0] row_cnt;
wire [10:0] column_cnt;
wire [15:0] gray;
wire [8:0] index;
wire [15:0] light;
//===================================================

//==============================================================
//LVDS Reciver
LVDS_7to1_RX_Top LVDS_7to1_RX_Top_inst
(
    .I_rst_n        (I_rst_n    ),
    .I_clkin_p      (I_clkin_p  ),    // LVDS clock input pair
    .I_clkin_n      (I_clkin_n  ),    // LVDS clock input pair
    .I_din_p        (I_din_p    ),    // LVDS data input pair 0
    .I_din_n        (I_din_n    ),    // LVDS data input pair 0
    .O_pllphase     (           ),
    .O_pllphase_lock(           ),
    .O_clkpat_lock  (           ),
    .O_pix_clk      (rx_sclk    ),  
    .O_vs           (r_Vsync_0  ),
    .O_hs           (r_Hsync_0  ),
    .O_de           (r_DE_0     ),
    .O_data_r       (r_R_0      ),
    .O_data_g       (r_G_0      ),
    .O_data_b       (r_B_0      )
);

//===================================================================================
//LVDS TX
LVDS_7to1_TX_Top LVDS_7to1_TX_Top_inst
(
    .I_rst_n       (I_rst_n     ),
    .I_pix_clk     (rx_sclk     ), //x1                       
    .I_vs          (r_Vsync_0   ), 
    .I_hs          (r_Hsync_0   ),
    .I_de          (r_DE_0      ),
    .I_data_r      (r_R_0       ),
    .I_data_g      (r_G_0       ),
    .I_data_b      (r_B_0       ), 
    .O_clkout_p    (O_clkout_p  ), 
    .O_clkout_n    (O_clkout_n  ),
    .O_dout_p      (O_dout_p    ),    
    .O_dout_n      (O_dout_n    ) 
);

get_pixel u_get_pixel(
    .sys_rst(I_rst_n),
    .pixel_clk(rx_sclk),
    .hs(r_Hsync_0),
    .vs(r_Vsync_0),
    .data_vld(r_DE_0),
	 .R(r_R_0),
	 .G(r_G_0),
	 .B(r_B_0),
    .new_frame(new_frame), 
    .row_cnt(row_cnt), 
    .column_cnt(column_cnt), 
    .max(max)
);

gray u_gray (
    .sys_clk(rx_sclk), 
    .sys_rst(I_rst_n), 
    .new_frame(new_frame), 
    .row_cnt(row_cnt), 
    .column_cnt(column_cnt), 
    .max(max), 
    .update(update), 
    .index(index), 
    .gray(gray),
	 .process_end(process_end)
);

filter u_filter (
    .sys_clk(rx_sclk),
    .sys_rst(I_rst_n),
    .gray(gray),
    .gray_index(index),
    .gray_update(update),
    .process_end(process_end),
    .light(light),
    .light_index(light_index),
    .filter_end(filter_end),
     .get_map(get_map)
);

map map_instance (
    .sys_clk(rx_sclk),
    .sys_rst(I_rst_n),
    .light(light),
    .get_map(get_map),
    .mapped_light(mapped_light),
    .light_refresh(light_refresh)
);


endmodule