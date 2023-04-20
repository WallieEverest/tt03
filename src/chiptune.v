// Title:   Sound generator
// File:    chiptune.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:
// Operation:

`default_nettype none

module chiptune (
  input  wire clk,       // 4800 Hz
  input  wire sck,       // 300 baud
  input  wire sdi,       // serial data
  output wire [4:0] dac  // audio DAC
);

  wire [7:0] apu_reg [0:3];
  wire qtr_clk;  // 240 Hz
  wire hlf_clk;  // 120 Hz
  wire signed [4:0] p1_out;
  wire reg_change;
  assign dac = p1_out;
  
  decoder decoder_inst (
    .sck       (sck),
    .sdi       (sdi),
    .apu_reg_0 (apu_reg[0]),
    .apu_reg_1 (apu_reg[1]),
    .apu_reg_2 (apu_reg[2]),
    .apu_reg_3 (apu_reg[3]),
    .reg_change(reg_change)
  );

  frame_counter frame_counter_inst (
    .clk    (clk),
    .qtr_clk(qtr_clk),
    .hlf_clk(hlf_clk)
  );
  
  pulse pulse_inst (
    .apu_clk   (clk),
    .qtr_clk   (qtr_clk),
    .hlf_clk   (hlf_clk),
    .reg_0     (apu_reg[0]),
    .reg_1     (apu_reg[1]),
    .reg_2     (apu_reg[2]),
    .reg_3     (apu_reg[3]),
    .reg_change(reg_change),
    .pulse_out (p1_out)
  );

endmodule
