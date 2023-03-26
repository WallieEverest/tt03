// Title:  Square root algorithm in Verilog
// File:   morningjava_sqrt.v
// Author: Wallace Everest
// Date:   23-NOV-2022
// URL:    https://github.com/wallieeverest/tt03
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

module morningjava_sqrt #(
  parameter G_WIDTH = 8  // size must be even
)(
  input  wire                 clk,
  input  wire [G_WIDTH-1:0]   data_in,
  output wire [G_WIDTH/2-1:0] data_out
);

  reg [G_WIDTH-1:0]   d [G_WIDTH/2+1:0];  // unsigned
  reg [G_WIDTH/2-1:0] q [G_WIDTH/2+1:0];  // unsigned
  reg signed [G_WIDTH/2+1:0] r [G_WIDTH/2+1:0];

  assign data_out = q[G_WIDTH/2];
  assign d[0] = data_in;
  assign q[0] = '0;
  assign r[0] = '0;

  genvar i;
  for (i = 0; i < (G_WIDTH/2); i = i+1) begin : sqrt_gen
    wire sign;
    wire signed [G_WIDTH/2+1:0] x, y, alu;

    assign  sign = r[i][G_WIDTH/2+1];  // sign of R is operand
    assign  x    = {r[i][G_WIDTH/2-1:0], d[i][G_WIDTH-1:G_WIDTH-2]};
    assign  y    = {q[i], sign, 1'b1};
    assign  alu  = (sign == 1'b0) ? (x - y) : (x + y);
    
    initial begin : sqrt_init
      d[i+1] = '0;
      q[i+1] = '0;
      r[i+1] = '0;
    end;

    always @(posedge clk) begin : sqrt_reg
      d[i+1] <= {d[i][G_WIDTH-3:0], 2'b0};  // left shift 2-bit
      q[i+1] <= {q[i][G_WIDTH/2-2:0], ~alu[G_WIDTH/2+1]};  // left shift 1-bit
      r[i+1] <= alu;
    end;
  end
endmodule
