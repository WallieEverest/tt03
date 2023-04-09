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
  output reg  tck = 0
) /* synthesis syn_hier="fixed" */;

  reg rx_meta = 0;
  reg tdi = 0;
  reg tdi_delay = 0;
  reg [3:0] counter = 0 /* synthesis syn_preserve=1 */;
  localparam [3:0] HALF_BIT = 8;

  always @(posedge clk) begin
    rx_meta   <= rx;       // capture asynchronous input
    tdi       <= rx_meta;  // align metastable input to the system clock
    tdi_delay <= tdi;      // generate delay to detect edge

    if (tdi != tdi_delay)  // edge detected
      counter <= 0;        // synchronize bit clock
    else
      counter <= counter+1;

    if (counter < HALF_BIT)
      tck <= 0;  // generate falling edge of TCK on RX change
    else
      tck <= 1;  // generate rising edge of TCK midway through bit period
  end
  
endmodule
