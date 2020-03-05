module lab3_top(
        input [3:0] KEY,
        input [9:0] SW,
        output [9:0] LEDR,
        input CLOCK_50,
        output VGA_CLK,
        output VGA_HS,
        output VGA_VS,
        output VGA_BLANK_N,
        output VGA_SYNC_N,
        output [7:0] VGA_R,
        output [7:0] VGA_G,
        output [7:0] VGA_B
      );

  wire [8:0] x, o;   // current board positions
  wire [8:0] next_o; // next position that O wants to play
  wire [7:0] win_line; // has someone won and if so along which line? 

  // The following module instance determines the next move played by O. The
  // logic is is described in the Lab 3 handout and in Section 9.4 of Dally.  
  // The TicTacToe module is purely combinational logic.  We connect "o" to
  // "xin" instead of "oin" because we want GameLogic to play for O instead 
  // of X.
  TicTacToe GameLogic( .xin(o), .oin(x), .xout(next_o) );

  // The following module records past moves played by you and the module above.
  // It uses something called "sequential logic" we will learn about later.
  // The implementation can be found in game_state.v, but for this lab all you
  // need to know is that the "x" and "o" wires are driven by this block.
  GameState State(  // inputs 
                    .o_move(next_o), 
                    .x_move(SW[8:0]), 
                    .reset(~KEY[0]), 
                    .clk(CLOCK_50), 
                    .winner(|win_line), 
                    // outputs
                    .o(o),
                    .x(x) );

  // The following module will be implemented by you! It detects when someone
  // wins and along which line
  DetectWinner Wins( // inputs
                     .ain(x), .bin(o), 
                     // outputs
                     .win_line(win_line) );

  // only set LEDs for positions that X can still play (combinational logic)
  assign LEDR = {1'b0, ~(x|o)}; 

  // The following module interfaces with the VGA monitor.  The implementation
  // is in tictactoe_to_vga.v and vga.v.  You do not need to understand that
  // code to complete this lab although you are welcome to look at it.
  TicTacToe_to_VGA GFX(
          // inputs
          .x_positions( {x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8]} ),
          .o_positions( {o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],o[8]} ),
          .next_position( 9'b0 ),
          .win_line( win_line ),
          .reset(~KEY[0]),
          .CLOCK_50(CLOCK_50),

          // outputs
          .VGA_CLK(VGA_CLK),
          .VGA_HS(VGA_HS),
          .VGA_VS(VGA_VS),
          .VGA_BLANK(VGA_BLANK_N),
          .VGA_SYNC(VGA_SYNC_N),
          .VGA_R(VGA_R),
          .VGA_G(VGA_G),
          .VGA_B(VGA_B)
        );
endmodule
