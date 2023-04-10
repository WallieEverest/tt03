// Title:   Clock prescaler
// File:    prescaler.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/scanchain_v2
// License: Apache 2.0
//
// Description: Recovers a bit clock (TCK) from an asynchronous serial data RX
// Implementation: Reports a link indicator for activity on RX

`default_nettype none

module prescaler #(
  parameter CLKRATE = 12_000_000,  // system clock rate
  parameter BAUDRATE = 57_600      // serial data rate: range 19,200 to 115,200
)(
  input  wire clk,
  input  wire rx,
  output reg  uart_clk = 0,  // 16x baud rate
  output reg  blink = 0,     // 1 Hz
  output reg  link = 0       // serial activity
) /* synthesis syn_hier="fixed" */;

  localparam [5:0] DIVISOR = CLKRATE / BAUDRATE / 16;  // 57,600 baud => 13
  reg rx_meta   = 0;
  reg tdi       = 0;
  reg tdi_delay = 0;
  reg [5:0] count_baud  = 0 /* synthesis syn_preserve=1 */;
  reg [11:0] count_4khz = 0;
  reg [10:0] count_2hz  = 0;
  reg [7:0] count_link  = 0;
  reg event_4khz = 0;
  reg event_2hz  = 0;

  always @(posedge clk) begin
    rx_meta   <= rx;       // capture asynchronous input
    tdi       <= rx_meta;  // align input to the system clock
    tdi_delay <= tdi;      // generate delay to detect edge

    if (count_baud == 0)
      count_baud <= DIVISOR-1;
    else
      count_baud <= count_baud-1;

    if (count_baud < DIVISOR/2)
      uart_clk <= 1;
    else
      uart_clk <= 0;

    event_4khz <= (count_4khz == 1);  // 4 kHz clock
    count_4khz <= (event_4khz) ? 3000-1 : count_4khz-1;
    
    if (event_4khz) begin
      event_2hz <= (count_2hz == 1);  // 2 Hz clock
      count_2hz <= (event_2hz) ? 2000-1 : count_2hz-1;
    end

    if (event_4khz && event_2hz)
      blink <= ~blink;  // toggle LED at 1 Hz

    if (tdi != tdi_delay)
      count_link <= ~0;
    else if (event_4khz && (count_link != 0))
      count_link <= count_link-1;

    link <= (count_link != 0);  // show RX activity
  end
  
endmodule
