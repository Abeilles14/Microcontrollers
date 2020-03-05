// Copyright (C) Tor M. Aamodt, Andrew Boktor, Ahmed ElTantawy UBC
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


module TicTacToe_to_VGA( 
  input [8:0] x_positions, o_positions, next_position,
  input [7:0] win_line,
  input reset, CLOCK_50,
  output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC,
  output [7:0] VGA_R, VGA_G, VGA_B );

  wire raster_valid, shader_ready, shader_valid, fb_ready;
  wire [9:0] coor_x, coor_y;
  wire [31:0] shader_pixel_rgba, shader_pixel_addr;

  rasterizer RASTER( .clk(CLOCK_50), .reset(reset),
              .shader_ready(shader_ready),
              .raster_valid(raster_valid),
              .x(coor_x),
              .y(coor_y) );

  tictactoe_shader SHADER( .clk(CLOCK_50), 
               .reset(reset),
               .coor_x(coor_x),
               .coor_y(coor_y),
               .x_pos(x_positions),
               .o_pos(o_positions),
               .next_position(next_position),
               .win(win_line),
               .fb_ready(fb_ready),
               .shader_pixel_rgba(shader_pixel_rgba),
               .shader_pixel_addr(shader_pixel_addr),
               .shader_ready(shader_ready),
               .raster_valid(raster_valid),
               .shader_valid(shader_valid) );

  framebuffer FB( .shader_valid(shader_valid),
              .fb_ready(fb_ready),
              .shader_pixel_rgba(shader_pixel_rgba),
              .shader_pixel_addr(shader_pixel_addr),
              .reset(reset),
              .CLOCK_50(CLOCK_50),
              .VGA_CLK(VGA_CLK),
              .VGA_HS(VGA_HS),
              .VGA_VS(VGA_VS),
              .VGA_BLANK(VGA_BLANK),
              .VGA_SYNC(VGA_SYNC),
              .VGA_R(VGA_R),
              .VGA_G(VGA_G),
              .VGA_B(VGA_B)
           ); 
endmodule

module rasterizer( input clk, reset, shader_ready, 
                   output raster_valid, 
                   output [9:0] x, y );

  wire raster_valid_next, next_pixel, reset_last;
  wire [9:0] x_new_reset, y_new_reset;
  reg [9:0] x_new, y_new;
  reg x_wrap;
  
  vDFF CTRL(clk,raster_valid_next,raster_valid);
  assign raster_valid_next = reset ? 1'b0 : (raster_valid ? ~shader_ready : 1'b1);
  assign next_pixel = ~raster_valid;

  vDFFE #(10) X_REG(clk,next_pixel,x_new_reset,x);
  vDFFE #(10) Y_REG(clk,next_pixel,y_new_reset,y);
  vDFF R_REG(clk,reset,reset_last);
  
  assign x_new_reset = (reset|reset_last) ? 10'd635 : x_new; 
  assign y_new_reset = (reset|reset_last) ? 10'd479 : y_new;
  
  // update x position
  always @* begin
    casex ({next_pixel,x}) 
      {1'b0, 10'bxxxxxxxxxx}: {x_wrap,x_new} = {1'b0, x};
      {1'b1, 10'd639} :       {x_wrap,x_new} = {1'b1, 10'd0};
      default:                {x_wrap,x_new} = {1'b0, x+10'd1};
    endcase
  end

  // update y position
  always @* begin
    casex ({x_wrap,y})
      {1'b0, 10'bxxxxxxxxxx}:  y_new = y;
      {1'b1, 10'd479}       :  y_new = 10'd0;
      default:                 y_new = y+10'd1;
    endcase
  end
endmodule

module tictactoe_shader(
     input clk, reset,

     // interface to current game state
     input [8:0] x_pos, o_pos, next_position,
     input [7:0] win,

     // interface to upstream unit (rasterizer)
     input raster_valid,
     input [9:0] coor_x, coor_y,
     output shader_ready,

     // interface to downstream unit (framebuffer)
     input fb_ready,
     output [31:0] shader_pixel_rgba, shader_pixel_addr,
     output shader_valid
    );
  
  `define xdiv0 10'd160
  `define xdiv1 10'd266
  `define xdiv2 10'd373
  `define xdiv3 10'd480
  `define ydiv0 10'd120
  `define ydiv1 10'd200
  `define ydiv2 10'd280
  `define ydiv3 10'd360
  `define row0 10'd160 
  `define row1 10'd240 
  `define row2 10'd320 
  `define col0 10'd213 
  `define col1 10'd320 
  `define col2 10'd426 

  wire stage_2_ready, stage_1_valid;

  wire   shader_valid_next_reset = reset ? 1'b0 : (stage_1_valid ? ~stage_2_ready : raster_valid);
  assign shader_ready = ~ stage_1_valid;
  vDFF S_CTRL1(clk,shader_valid_next_reset,stage_1_valid);

  wire   stage_2_valid_next_reset = reset ? 1'b0 : (shader_valid ? ~fb_ready : stage_1_valid);
  assign stage_2_ready = ~shader_valid;
  vDFF S_CTRL2(clk,stage_2_valid_next_reset,shader_valid);

  wire [9:0] x_cur, y_cur, xcur, ycur, coor_ximg_delay;
  vDFFE #(10) S_X(clk,shader_ready,coor_x,x_cur);
  vDFFE #(10) S_Y(clk,shader_ready,coor_y,y_cur);

  // map screen coordinates into image coordinates for X and O texture lookups
  wire [9:0] coor_ximg = (x_cur >= (`xdiv1+1) && x_cur < (`xdiv2+1)) ? (x_cur - (`xdiv1+1)) :
                        ((x_cur >= (`xdiv2+1) && x_cur < (`xdiv3+1)) ? (x_cur - (`xdiv2+1)) : 
                                                                       (x_cur - (`xdiv0+1)) );
  wire [9:0] coor_yimg = (y_cur >= (`ydiv1+1) && y_cur < (`ydiv2+1)) ? (y_cur - (`ydiv1+1)) : 
                        ((y_cur >= (`ydiv2+1))                       ? (y_cur - (`ydiv2+1)) : 
                                                                       (y_cur - (`ydiv0+1)) );

  wire [13:0] shader_addr = {coor_yimg,3'b0} + {11'b0, coor_ximg[6:4]};

  wire [15:0] xshader_data, oshader_data;
  wire xshader_value, oshader_value, on_xborder, on_yborder;

  // texture lookup for X 
  ROM #(16, 10, "X.bin") XBMP(clk, shader_addr[9:0], xshader_data);
  assign xshader_value = xshader_data[15-coor_ximg_delay[3:0]];

  // texture lookup for O
  ROM #(16, 10, "O.bin") OBMP(clk, shader_addr[9:0], oshader_data);       
  assign oshader_value = oshader_data[15-coor_ximg_delay[3:0]];

  vDFFE #(10) XD(clk,stage_2_ready,coor_ximg,coor_ximg_delay);
  vDFFE #(10) XCD(clk,stage_2_ready,x_cur,xcur);
  vDFFE #(10) YCD(clk,stage_2_ready,y_cur,ycur);

  //which board position does this pixel live in?
  wire [8:0] board_position;
  assign board_position[0] = xcur>`xdiv0 & xcur<`xdiv1 & ycur>`ydiv0 & ycur<`ydiv1;
  assign board_position[1] = xcur>`xdiv1 & xcur<`xdiv2 & ycur>`ydiv0 & ycur<`ydiv1;
  assign board_position[2] = xcur>`xdiv2 & xcur<`xdiv3 & ycur>`ydiv0 & ycur<`ydiv1;

  assign board_position[3] = xcur>`xdiv0 & xcur<`xdiv1 & ycur>`ydiv1 & ycur<`ydiv2;
  assign board_position[4] = xcur>`xdiv1 & xcur<`xdiv2 & ycur>`ydiv1 & ycur<`ydiv2;
  assign board_position[5] = xcur>`xdiv2 & xcur<`xdiv3 & ycur>`ydiv1 & ycur<`ydiv2;

  assign board_position[6] = xcur>`xdiv0 & xcur<`xdiv1 & ycur>`ydiv2 & ycur<`ydiv3;
  assign board_position[7] = xcur>`xdiv1 & xcur<`xdiv2 & ycur>`ydiv2 & ycur<`ydiv3;
  assign board_position[8] = xcur>`xdiv2 & xcur<`xdiv3 & ycur>`ydiv2 & ycur<`ydiv3;

  //determine if this pixel has an X, O, and/or "next X" (more than one if game logic error)
  wire draw_x = |(board_position & x_pos);
  wire draw_o = |(board_position & o_pos);
  wire draw_s = |(board_position & next_position);

  // grid lines for playing tic-tac-toe
  assign on_xborder = (xcur==`xdiv1 | xcur==`xdiv2) & (ycur>`ydiv0 & ycur<`ydiv3);
  assign on_yborder = (ycur==`ydiv1 | ycur==`ydiv2) & (xcur>`xdiv0 & xcur<`xdiv3);

  wire inframe = (ycur>`ydiv0 & ycur<`ydiv3) & (xcur>`xdiv0 & xcur<`xdiv3);

  // win lines
  wire [7:0] wline;
  assign wline[0] = inframe & ycur[9:2] == (`row0>>2) & win[0] ;
  assign wline[1] = inframe & ycur[9:2] == (`row1>>2) & win[1] ;
  assign wline[2] = inframe & ycur[9:2] == (`row2>>2) & win[2] ;

  assign wline[3] = inframe & xcur[9:2] == (`col0>>2) & win[3] ;
  assign wline[4] = inframe & xcur[9:2] == (`col1>>2) & win[4] ;
  assign wline[5] = inframe & xcur[9:2] == (`col2>>2) & win[5] ;

  // diagonals slightly more involved
  wire [21:0] x3_pixel = 12'd3 * xcur;
  // downward diagonal: 3x=4y
  wire [21:0]  x3_dn_diag = 12'd4 * ycur;
  // upwards diagonal:  3x=3*640-4y (320 VGA width, 4/3 screen aspect ratio) 
  wire [21:0] x3_up_diag = 12'd1920 - x3_dn_diag;

  assign wline[6] = win[6] & inframe & x3_pixel[9:4] == x3_dn_diag[9:4]; // ddiag
  assign wline[7] = win[7] & inframe & x3_pixel[9:4] == x3_up_diag[9:4]; // udiag

  // blend all of the above together
  wire [31:0] c1 = 32'hffffffff; // by default, pixel will be white
  // blend X's and O's
  wire [31:0] c2 = (~xshader_value & draw_x) ? (c1 - 32'h0000ffff) : c1; // red
  wire [31:0] c3 = (~oshader_value & draw_s) ? (c2 - 32'h00ff00ff) : c2; // green
  wire [31:0] c4 = (~oshader_value & draw_o) ? (c3 - 32'h00ffff00) : c3; // blue
  // blend gridlines
  wire [31:0] c5 = (on_xborder | on_yborder) ? 32'h0 : c4;
  // blend winlines
  assign shader_pixel_rgba = |wline ? 32'hffff0000 : c5;

  // convert from X-Y coord to framebuffer address (this could be done after shader)
  wire [63:0] address = 64'h0 + 32'h4 * xcur + 32'd2560 * ycur;
  assign shader_pixel_addr = address[31:0];
endmodule

`timescale 1ns/10ps
module framebuffer( input shader_valid,
        output fb_ready,
        input [31:0] shader_pixel_rgba,
        input [31:0] shader_pixel_addr,

        input reset,
        input CLOCK_50,
        output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC,
        output [7:0] VGA_R, VGA_G, VGA_B
      );

  wire vga_valid;
  wire vga_read_enable, vga_end_of_frame, vga_end_of_active_frame, vga_c_sync, vga_data_enable;
  wire [9:0] vga_color_data;
  wire [9:0] red, blue, green, vga_red, vga_blue, vga_green;
  wire [24:0] vga_data;
  wire start_of_framedata_in, start_of_framedata_out;
  wire [24:0] data_in;
  reg  fifo_read_enable;

  assign start_of_framedata_in = shader_valid & (shader_pixel_addr == 0);
  assign data_in = {start_of_framedata_in, shader_pixel_rgba[23:0]};

  wire locked;

  altera_pll #(
		.fractional_vco_multiplier("false"),
		.reference_clock_frequency("50.0 MHz"),
		.operation_mode("direct"),
		.number_of_clocks(1),
		.output_clock_frequency0("25.000000 MHz"),
		.phase_shift0("0 ps"),
		.duty_cycle0(50),
		.pll_type("General"),
		.pll_subtype("General")
	) altera_pll_i (
		.rst	(reset),
		.outclk	(VGA_CLK),
		.locked	(locked),
		.fbclk	(1'b0),
		.refclk	(CLOCK_50)
	);

  wire [31:0] count, count_next, count_next_reset;
  assign count_next = locked ? ((count < 1024) ? count+1: count) : 0;
  assign count_next_reset = reset ? 0 : count_next;
  vDFF #(32) counter(VGA_CLOCK,count_next_reset,count);
  wire vga_reset = (locked & (count > 5)) ? 1'b1 : 1'b0; 

  wire[6:0]	fifo_wr_used;
  wire fifo_empty;
  assign fb_ready = ~(&(fifo_wr_used[6:4]));
  assign vga_valid = ~fifo_empty;

  dcfifo	Data_FIFO (
    // Inputs
    .wrclk	(CLOCK_50),
    .wrreq	(fb_ready & shader_valid),
    .data		(data_in),
    .rdclk	(VGA_CLK),
    .rdreq	(fifo_read_enable & ~fifo_empty),

    // Outputs
    .wrusedw	(fifo_wr_used),
    .rdempty	(fifo_empty),
    .q			(vga_data)
  );
  defparam
    Data_FIFO.intended_device_family	= "Cyclone II",
    Data_FIFO.lpm_hint					= "MAXIMIZE_SPEED=7",
    Data_FIFO.lpm_numwords				= 128,
    Data_FIFO.lpm_showahead				= "ON",
    Data_FIFO.lpm_type					= "dcfifo",
    Data_FIFO.lpm_width					= 25,
    Data_FIFO.lpm_widthu					= 7,
    Data_FIFO.overflow_checking		= "OFF",
    Data_FIFO.rdsync_delaypipe			= 5,
    Data_FIFO.underflow_checking		= "OFF",
    Data_FIFO.use_eab						= "ON",
    Data_FIFO.wrsync_delaypipe			= 5;


  assign start_of_framedata_out = vga_data[24];
  assign red = {vga_data[23:16],2'b0};
  assign green = {vga_data[15:8],2'b0};
  assign blue = {vga_data[7:0],2'b0};

  // state machine to synchronize VGA with pixel generation
  reg [1:0] state;
  always @(posedge VGA_CLK or posedge vga_reset) begin
    if (vga_reset)
      state = 2'b0;
    else 
      casex ({state, vga_end_of_frame, vga_end_of_active_frame, vga_valid, start_of_framedata_out})
        6'b00xx11: state = 2'b01; // start of pixels 
        6'b010x11: state = 2'b01; // wait for vga
        6'b011011: state = 2'b10; // vga and pixels in sync 
        6'b10xxxx: state = 2'b11; // wait for start_of_framedata_out to drop
        6'b11x0x0: state = 2'b11; // draw pixels 
        6'b11x011: state = 2'b01; // last pixel, wait for end of frame signal
        6'b11x1xx: state = 2'b01; // at end of active frame, wait for end of frame again
        default:   state = 2'b00;
      endcase
  end

  always @* begin
    case (state)
      2'b00: fifo_read_enable = ~(vga_valid & start_of_framedata_out);
      2'b01: fifo_read_enable = 1'b0;
      2'b10: fifo_read_enable = vga_read_enable;
      default: fifo_read_enable = vga_read_enable;
    endcase
  end

  altera_up_avalon_video_vga_timing VGA(
        //  inputs
        .clk(VGA_CLK),
        .reset(vga_reset),
        .red_to_vga_display(red),
        .green_to_vga_display(green),
        .blue_to_vga_display(blue),
        .color_select(4'b0001),

        // outputs
        .read_enable(vga_read_enable),
        .end_of_active_frame(vga_end_of_active_frame),
        .end_of_frame(vga_end_of_frame),

        // dac pins
        .vga_blank(VGA_BLANK),
        .vga_c_sync(vga_c_sync),
        .vga_h_sync(VGA_HS),
        .vga_v_sync(VGA_VS),
        .vga_data_enable(vga_data_enable), 
        .vga_red(vga_red), 
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .vga_color_data(vga_color_data) );

  assign VGA_R = vga_red[9:2];
  assign VGA_G = vga_green[9:2];
  assign VGA_B = vga_blue[9:2];
  assign VGA_SYNC = 1'b0;
endmodule
