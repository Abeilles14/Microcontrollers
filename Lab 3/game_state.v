module GameState(
  input clk, reset, winner,
  input [8:0] x_move, o_move,
  output [8:0] x, o );

  // determine whether X or O should play next : first count number of X's and O's
  wire [3:0] count_x = x[0]+x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8];
  wire [3:0] count_o = o[0]+o[1]+o[2]+o[3]+o[4]+o[5]+o[6]+o[7]+o[8];

  // assuming X plays first, it is X's turn when O has as many squares on the board as X
  wire turn = count_o >= count_x;

  wire [8:0] x_move_reg;
  vDFF #(9) xmov(clk,x_move,x_move_reg);

  wire [8:0] x_new = x_move_reg & ~x;
  wire [8:0] o_new = o_move & ~o;
  wire [8:0] x_overlap = x_move_reg & o;

  wire [3:0] x_count = x_new[0]+x_new[1]+x_new[2]+
                       x_new[3]+x_new[4]+x_new[5]+
                       x_new[6]+x_new[7]+x_new[8];

  wire [3:0] o_count = o_new[0]+o_new[1]+o_new[2]+
                       o_new[3]+o_new[4]+o_new[5]+
                       o_new[6]+o_new[7]+o_new[8];
 
  wire x_legal = (x_count == 1) & (~|x_overlap);
  wire o_legal = o_count == 1;

  wire x_update = turn & x_legal & ~winner;
  wire o_update = ~turn & o_legal & ~winner;

  wire [8:0] x_next = x_update ? (x_move_reg|x) : x;
  wire [8:0] o_next = o_update ? (o_move|o) : o;

  wire [8:0] x_next_reset = reset ? 9'b0 : x_next;
  wire [8:0] o_next_reset = reset ? 9'b0 : o_next;

  vDFF #(9) xreg(clk,x_next_reset,x);
  vDFF #(9) oreg(clk,o_next_reset,o);
endmodule 
