module screen_driver_top
(
    input           I_clk,
    input           sys_rst,
    input            I_clkin_p,
    input            I_clkin_n   ,  //LVDS Input
    input  [3:0]   I_din_p     ,  //LVDS Input
    input  [3:0]   I_din_n     ,  //LVDS Input    
    output         O_clkout_p  ,
    output         O_clkout_n  ,
    output [3:0]   O_dout_p    ,
    output [3:0]   O_dout_n    ,
    output         LE          ,
    output         DCLK        , //12.5M
    output         SDI         ,
    output         GCLK         ,
    output         scan1       ,
    output         scan2       ,
    output         scan3       , 
    output         scan4       

);
wire [8:0] light_index;
wire [15:0] light;
lvds_video_top lvds_video_top_inst(
    .I_clk(I_clk)       ,  //50MHz      
    .I_rst_n (sys_rst)    ,
    .I_clkin_p(I_clkin_p)   ,  //LVDS Input
    .I_clkin_n(I_clkin_n)   ,  //LVDS Input
    .I_din_p(I_din_p)     ,  //LVDS Input
    .I_din_n(I_din_n)     ,  //LVDS Input    
    .O_clkout_p(O_clkout_p)  ,
    .O_clkout_n(O_clkout_n)  ,
    .O_dout_p(O_dout_p)    ,
    .O_dout_n(O_dout_n)    ,
    .light_refresh(light_refresh),
    .light(light),
    .light_index(light_index)
);

MiniLED_driver MiniLED_driver_inst
(
    .I_clk(I_clk)       ,  //50MHz      
    .I_rst_n (sys_rst)    ,   
    //led()
    .LE(LE)          ,
    .DCLK(DCLK)        , //12.5M
    .SDI(SDI)   ,
    .GCLK(GCLK)         ,
    .scan1(scan1)       ,
    .scan2(scan2)       ,
    .scan3(scan3)       , 
    .scan4(scan4)       ,
    .light_refresh(light_refresh),
    .light(light),
    .light_index(light_index)
    
);
endmodule