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
  output reg [7:0] o_pins = 0,
  output reg tck = 0,
  output reg tms = 0,
  output reg tdi = 0
) /* synthesis syn_hier="fixed" */;

always @(posedge clk) begin
  if (reset) begin
    o_pins <= ~i_pins;
    tck    <= rtck;
    tms    <= (addr == 0);
    tdi    <= tdo;
  end
end

endmodule
