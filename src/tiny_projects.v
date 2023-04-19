// Title:   Tiny example projects
// File:    tiny_projects.v
// Author:  Wallie Everest
// Date:    18-APR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description: Small example projects for scanchain
// Implementation:

`default_nettype none

module invert (
  input  wire [7:0] io_in,
  output wire [7:0] io_out
);
  assign io_out = ~io_in;
endmodule

module parity (
  input  wire [7:0] io_in,
  output wire [7:0] io_out
);
  assign io_out = io_in[0] ^ io_in[1] ^ io_in[2] ^ io_in[3] ^io_in[4] ^ io_in[5] ^ io_in[6] ^ io_in[7];
endmodule

module roll (
  input  wire [7:0] io_in,
  output wire [7:0] io_out
);
  assign io_out = {io_in[6:0], io_in[7]};
endmodule

module ecc (
  input  wire [7:0] io_in,
  output wire [7:0] io_out
);
  assign io_out[0] = io_in[0] ^ io_in[2] ^ io_in[4] ^ io_in[6];
  assign io_out[1] = io_in[1] ^ io_in[3] ^ io_in[5] ^ io_in[7];
  assign io_out[2] = io_in[0] ^ io_in[1] ^ io_in[4] ^ io_in[5];
  assign io_out[3] = io_in[2] ^ io_in[3] ^ io_in[6] ^ io_in[7];
  assign io_out[4] = io_in[0] ^ io_in[1] ^ io_in[2] ^ io_in[3];
  assign io_out[5] = io_in[4] ^ io_in[5] ^ io_in[6] ^ io_in[7];
  assign io_out[6] = 0;
  assign io_out[7] = 0;
endmodule
