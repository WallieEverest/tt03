// Title:   Tiny Tapeout Scanchain TAP
// File:    tap.v
// Author:  Wallace Everest
// Date:    25-MAR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description: Test Access Point (TAP) for each project in the chain
// Implementation:
//   Utilizes a bypass mux similar to JTAG for minimizing scan latency.
//   The 10-bit non-return to zero (NRZ) code is compatible with serial COM ports.
//   Message format is 1 start, 8 data, 1 stop. Least significant data bit is transmitted first
//   Synplify and Yosis attributes are included to produce equivalant results.
//   Throughput speed is determined by the chain of 250x(nominal) TDI->TDO multiplexers.
// Operation:
//   1.) The multiplexer configures O_TDO = I_TDI when (I_TMS == 0) or the module is not ACTIVE.
//   2.) The multiplexer configures O_TDO = I_DATA messages when (I_TMS == 1) and the module is ACTIVE.
//   3.) Internal states are updated on the rising edge of I_TCK.
//   4.) Inbound messages are received from I_TDI using 10-bit NRZ decoding.
//   5.) Outbound messages are updated from I_DATA after receving an inbound message.
//   6.) O_TDO updates on the falling edge of I_TCK when connected to outbound messages.
//   7.) The ACTIVE state is cleared when (inbound message != I_ADDR) while (I_TMS == 0).
//   8.) The ACTIVE state is set when (inbound message == I_ADDR) while (I_TMS == 0).
//   9.) O_DATA is asynchronously cleared when (I_TMS == 0).
//  10.) O_DATA is set by the inbound message when the module is ACTIVE.
//  11.) The external controller must wait for the outbound message to finish before changing the state of I_TMS.

`default_nettype none

module tap (
  input  wire i_tck,
  input  wire i_tms,
  input  wire i_tdi,
  input  wire [7:0] address,
  input  wire [7:0] outbound,
  output reg  [7:0] inbound = 0 /* synthesis syn_preserve=1 */,
  output wire o_tck            /* synthesis syn_keep=1 */,
  output wire o_tms            /* synthesis syn_keep=1 */,
  output wire o_tdo
) /* synthesis syn_hier="fixed" */;

  wire clk_n = ~i_tck   /* synthesis syn_keep=1 */;
  wire tms_n = ~i_tms   /* synthesis syn_keep=1 */;

  localparam WIDTH = 10;  // number of bits in message
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP = 1'b1;

  reg  active = 0;
  reg  q_tdo = 1;
  reg  [WIDTH-1:0] shift = IDLE;  // default to IDLE pattern
  wire [WIDTH-1:0] next_shift = {i_tdi, shift[WIDTH-1:1]};  // right-shift and get next TDI bit
  wire [7:0] data = shift[WIDTH-2:1];
  reg  [3:0] bit_count = 0;
  wire zero_count = (bit_count == 0);
  wire msg_sync = (shift[WIDTH-1] == STOP) && (shift[0] == START) && zero_count;  // valid message
 
  assign o_tck   = ~clk_n;
  assign o_tms   = ~tms_n;
  assign o_tdo   = (!tms_n && active) ? q_tdo : i_tdi;  // select source for TDO output

  always @(negedge clk_n) begin
    if (zero_count)
      bit_count <= WIDTH-1;
    else if ((shift[WIDTH-1] == START) || (bit_count != WIDTH-1))  // synchronize with IDLE pattern
      bit_count <= bit_count - 1;

    if (msg_sync)
      if (tms_n)  // address message
        shift <= IDLE;  // clear queue before mux switchover
      else  // data message
        shift <= {STOP,outbound,START};  // capture user outbound data
    else
      shift <= next_shift;  // TDI captured on rising edge of TCK

    if (msg_sync && tms_n)  // address message
      active <= (data == address);  // addess match
  end

  always @(negedge clk_n, posedge tms_n) begin
    if (tms_n)
      inbound <= 0;  // inactive state for user inbound data
    else if (msg_sync && active)
      inbound <= data;  // capture user inbound data
  end

  always @(posedge clk_n, posedge tms_n) begin
    if (tms_n)
      q_tdo <= 1;  // IDLE pattern
    else
      q_tdo <= shift[0];  // TDO transitions on falling edge of TCK
  end

endmodule
