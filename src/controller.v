// Title:   Tiny Tapeout Scanchain Controller
// File:    controller.v
// Author:  Wallace Everest
// Date:    25-MAR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:

`default_nettype none

module controller (
  input  wire clk,
  input  wire reset,
  input  wire rtck,
  input  wire tdo,
  input  wire addr,
  input  wire [7:0] i_pins,
  output wire [7:0] o_pins,
  output wire tck,
  output wire tms,
  output wire tdi
) /* synthesis syn_hier="fixed" */;

  // DEBUG faked signal assignments
  assign o_pins = 0; //i_pins;
  assign tck = 0; //rtck;
  assign tms = 0; //addr & reset & clk;
  assign tdi = 0; //tdo;

// always @(posedge clk) begin
//   if (reset) begin
//     o_pins <= ~i_pins;
//     tck    <= rtck;
//     tms    <= (addr == 0);
//     tdi    <= tdo;
//   end
// end

endmodule
