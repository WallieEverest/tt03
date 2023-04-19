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
  input  wire [7:0] io_in,
  output wire [7:0] io_out
);

  wire [7:0] apu_reg [0:7];
  wire sck = io_in[5];  // 4,800 Hz
  wire qfr_clk;         // 240 Hz
  wire hfr_clk;         // 120 Hz
  wire signed [15:0] p1_out;
  wire signed [15:0] p2_out;
  assign io_out = {p2_out[3:0], p1_out[3:0]};
  
  decoder decoder_inst (
    .sck      (sck),
    .sdi      (io_in[7]),
    .apu_reg_0(apu_reg[0]),
    .apu_reg_1(apu_reg[1]),
    .apu_reg_2(apu_reg[2]),
    .apu_reg_3(apu_reg[3]),
    .apu_reg_4(apu_reg[4]),
    .apu_reg_5(apu_reg[5]),
    .apu_reg_6(apu_reg[6]),
    .apu_reg_7(apu_reg[7])
  );

  frame_counter frame_counter_inst (
    .clk       (sck),
    .fc_qfr_clk(qfr_clk),
    .fc_hfr_clk(hfr_clk)
  );
  
  pulse pulse_inst_1 (
    .in_apu_clk(sck),
    .in_qfr_clk(qfr_clk),
    .in_hfr_clk(hfr_clk),
    .reg_0     (apu_reg[0]),
    .reg_1     (apu_reg[1]),
    .reg_2     (apu_reg[2]),
    .reg_3     (apu_reg[3]),
    .pulse_out (p1_out)
  );

  pulse pulse_inst_2 (
    .in_apu_clk(sck),
    .in_qfr_clk(qfr_clk),
    .in_hfr_clk(hfr_clk),
    .reg_0     (apu_reg[0]),
    .reg_1     (apu_reg[1]),
    .reg_2     (apu_reg[2]),
    .reg_3     (apu_reg[3]),
    .pulse_out (p2_out)
  );

endmodule
