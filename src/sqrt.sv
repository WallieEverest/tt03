// Title:  Square root algorithm in SystemVerilog
// File:   sqrt.sv
// Author: Wallace Everest
// Date:   23-NOV-2022
// URL:    https://github.com/navray/tt02-square-root
//
// Decription:
//   Based on work by Yamin Li and Wanming Chu, 
//   "A new non-restoring square root algorithm and its VLSI implementations,"
//   Proceedings of the 1996 International Conference on Computer Design,
//   VLSI in Computers and Processors, October 1996 Pages 538–544
//
// Implementation:
//   Code is parameterized to accept variable input width.
//   Output width is half the input width.
//   Pipeline delay is output width + 1.

`default_nettype none

module sqrt
#(parameter G_WIDTH = 8)  // size must be even
(
  input  wire                 clk,
  input  wire [G_WIDTH-1:0]   data_in,
  output wire [G_WIDTH/2-1:0] data_out
);

  typedef logic unsigned [G_WIDTH-1:0]   d_type;
  typedef logic unsigned [G_WIDTH/2-1:0] q_type;
  typedef logic signed   [G_WIDTH/2+1:0] r_type;
  d_type d [G_WIDTH/2+1];
  q_type q [G_WIDTH/2+1];
  r_type r [G_WIDTH/2+1];

  assign data_out = q[G_WIDTH/2];
  
  always_comb begin : sqrt_io
    d[0] = data_in;
    q[0] = '0;
    r[0] = '0;
  end : sqrt_io;

  for (genvar i = 0; i < (G_WIDTH/2); i++) begin : sqrt_gen
    always_ff @(posedge clk) begin : sqrt_reg
      logic sign;
      r_type x, y, alu;
      sign    = r[i][G_WIDTH/2+1];  // sign of R is operand
      x       = {r[i][G_WIDTH/2-1:0], d[i][G_WIDTH-1:G_WIDTH-2]};
      y       = {q[i], sign, 1'b1};
      alu     = (sign == 1'b0) ? (x - y) : (x + y);
      d[i+1] <= {d[i][G_WIDTH-3:0], 2'b0};  // left shift 2-bit
      q[i+1] <= {q[i][G_WIDTH/2-2:0], ~alu[G_WIDTH/2+1]};  // left shift 1-bit
      r[i+1] <= alu;
    end : sqrt_reg
  end : sqrt_gen
endmodule
