// Title:   Tiny Tapeout Simulation Test Procedure
// File:    stp_001.v
// Author:  Wallace Everest
// Date:    25-MAR-2023
// URL:     https://github.com/wallieeverest/scanchain_v2
// License: Apache 2.0
//
// Description:
// Implementation:

`default_nettype none
`timescale 1ns/100ps

module a_tb_fpga_top ();
  localparam WIDTH = 10;  // number of bits in message
  localparam DELAY = WIDTH+1;
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP  = 1'b1;
  
  reg  [WIDTH-1:0] message = IDLE;  // default to IDLE pattern
  wire [7:0] i_data;
  wire [7:0] o_data;
  reg  clk = 0;
  reg  trst = 0;
  reg  tck = 0;
  wire tdi;
  wire tdo;
  reg  tms = 0;  // scan chain defaults to bypass
  wire rx = message[0];

  assign i_data = 0;

  fpga_top fpga_inst (
    .CLK(clk),
    .DTRN(trst),
    .MODE(1'b1),
    .RX(rx),
    .RTSN(tms),
    .I_DATA(i_data),
    .O_DATA(o_data),
    .TCK(),
    .TDI(tdi),
    .TDO(tdo),
    .TMS(),
    .TX(),
    .LED()
  );
    
  initial forever #42 clk = ~clk;    // 12 MHz system clock
  initial forever #8681 tck = ~tck;  // 57,600 baud UART

  initial begin
    repeat (2) @(negedge tck);
    message = {STOP,8'hA5,START};
    tms = 0;  // select address
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h00,START};
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h02,START};  // select tap 2
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h7F,START};  // send data
    tms = 1;  // select data
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h08,START};  // send data
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    repeat (DELAY) @(negedge tck)  // wait for data message received
    message = {STOP,8'h5A,START};  // deselect tap 2
    tms = 0;   // select address
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'hA5,START};  // send data
    tms = 1;
    repeat (DELAY) @(negedge tck) message = {STOP, message[WIDTH-1:1]};
    repeat (2) @(negedge tck);
  end

// add MODE tests
// extend I/O tests

endmodule
