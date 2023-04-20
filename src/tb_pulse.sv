`default_nettype none
`timescale 1ns/100ps

module a_tb_pulse ();

  reg  [7:0] apu_reg [0:31];
  reg  apu_clk = 0;  // 894,720 Hz
  wire qfr_clk;      // 240 Hz
  wire hfr_clk;      // 120 Hz
  wire signed [15:0] p1_out;

  initial forever #558 apu_clk = ~apu_clk;  // 896 kHz APU clock

  initial begin : reg_init
    integer i;
    for (i=0; i<=31; i=i+1)
      apu_reg[i] = 0;  // clear APU registers
    repeat (2) @(negedge hfr_clk);
    apu_reg[0] = 1;
    @(negedge hfr_clk);
  end

  frame_counter frame_counter_inst (
    .clk        ( apu_clk ),
    .fc_qfr_clk ( qfr_clk ),
    .fc_hfr_clk ( hfr_clk )
  );
  
  pulse pulse_inst (
    .in_apu_clk ( apu_clk    ),
    .in_qfr_clk ( qfr_clk    ),
    .in_hfr_clk ( hfr_clk    ),
    .reg_0      ( apu_reg[0] ),
    .reg_1      ( apu_reg[1] ),
    .reg_2      ( apu_reg[2] ),
    .reg_3      ( apu_reg[3] ),
    .pulse_out  ( p1_out     )
  );

endmodule
