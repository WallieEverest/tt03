// Title:   UART clock recovery
// File:    clk_gen.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/scanchain_v2
// License: Apache 2.0
//
// Description: Recovers a bit clock (TCK) from asynchronous serial data.
// Implementation: A reference clock must be supplied at 16x the baud rate

`default_nettype none

module clk_gen (
  input  wire clk,  // 16x baud clock
  input  wire rx,
  output reg  rtck = 0
) /* synthesis syn_hier="fixed" */;

  reg rx_meta = 0;
  reg tdi = 0;
  reg tdi_delay = 0;
  reg [3:0] count = 0 /* synthesis syn_preserve=1 */;
  localparam [3:0] HALF_BIT = 8;

  always @(posedge clk) begin
    rx_meta   <= rx;       // capture asynchronous input
    tdi       <= rx_meta;  // align metastable input to the system clock
    tdi_delay <= tdi;      // generate delay to detect edge

    if (tdi != tdi_delay)  // edge detected
      count <= 4;          // synchronize bit clock with phase offset
    else
      count <= count+1;

    if (count < HALF_BIT)
      rtck <= 0;  // generate falling edge of TCK on RX change
    else
      rtck <= 1;  // generate rising edge of TCK midway through bit period
  end
  
endmodule
