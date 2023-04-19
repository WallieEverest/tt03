`default_nettype none

// Generate low-frequency clocks
module frame_counter (
  input  wire clk,
  output reg  fc_qfr_clk = 0,  // approx. 240 Hz
  output reg  fc_hfr_clk = 0   // approx. 120 Hz
);

reg [10:0] seq = 0;

// Step through Mode 0 4-step sequence
always @ ( posedge clk ) begin
  if ( seq == 1864 ) begin
    seq <= 0;
    fc_qfr_clk <= ~fc_qfr_clk;
    if (fc_qfr_clk == 0)
      fc_hfr_clk <= ~fc_hfr_clk;
  end else
    seq <= seq + 1;
end

endmodule