// File: frame_counter.v

`default_nettype none

// Generate low-frequency clocks
module frame_counter (
  input  wire clk,
  output reg  qtr_clk = 0,  // approx. 240 Hz
  output reg  hlf_clk = 0   // approx. 120 Hz
);

localparam PRESCALE = 4800/240/2;  // frame rate
reg [3:0] counter = 0;

// Step through Mode 0 4-step sequence
always @ ( posedge clk ) begin
  if ( counter == PRESCALE-1 ) begin
    counter <= 0;
    qtr_clk <= ~qtr_clk;
    if (qtr_clk == 0)
      hlf_clk <= ~hlf_clk;
  end else
    counter <= counter + 1;
end

endmodule