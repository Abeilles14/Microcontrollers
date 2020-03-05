/*******************************************************************************
Copyright (c) 2012, Stanford University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed at Stanford University.
4. Neither the name of Stanford Univerity nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY STANFORD UNIVERSITY ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

//----------------------------------------------------------------------
// D-type Flip Flop
// Figure 14.16
//----------------------------------------------------------------------
module vDFF(clk, in, out) ;
  parameter n = 1;  // width
  input clk ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;

  always @(posedge clk)
    out = in ;
endmodule 
//----------------------------------------------------------------------
// Flop with enable
//----------------------------------------------------------------------
module vDFFE(clk, en, in, out) ;
  parameter n = 1;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;

  always @(posedge clk)
    out = en ? in : out ;
endmodule 
//----------------------------------------------------------------------
  
  
//ROM module
module ROM (clk, addr, data) ;
   parameter data_width = 32;
   parameter addr_width = 4;
   parameter file_name = "dataFile";
   
   input clk; 
   input [addr_width-1:0] addr;
   output reg [data_width-1:0] data;

   reg [data_width-1:0] rom [2**addr_width-1:0] ;

   initial begin
      $readmemb(file_name, rom);
   end
  
   always @(posedge clk) begin
      data = rom[addr];
   end
endmodule // rom_reg

//RAM module
module RAM(ra, wa, write, din, dout) ;
   parameter b = 32;
   parameter w = 4;

   input [w-1:0] ra, wa;
   input         write;
   input [b-1:0] din;
   output [b-1:0] dout;

   reg [b-1:0]      ram [2**w-1:0];

   assign dout = ram[ra];

   always@(*) begin
      if(write == 1)
        ram[wa] = din;
   end
endmodule
