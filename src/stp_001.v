// Title:  Tiny Tapeout Scan Controller test procedure
// File:   stp_001.v
// Author: Wallace Everest
// Date:   25-MAR-2023
// URL:    https://github.com/wallieeverest/tt03

// For a 249-project MPC, the scan period is 40.6 us, equivalent to 24 KSPS or 12 kHz project clock.
//

`default_nettype none
`timescale 1ns/100ps

module a_stp_001 ();
  localparam MPRJ_IO_PADS = 38;
  reg clk = 0;
  reg reset = 1;
  reg [8:0] active_select = '0;
  reg [1:0] driver_sel = '0;
  reg [7:0] inputs = '0;
  reg set_clk_div;

  wire [MPRJ_IO_PADS-1:0] io_in;
  wire [MPRJ_IO_PADS-1:0] io_out;
  wire [MPRJ_IO_PADS-1:0] io_oeb;
  wire [7:0] outputs;
  wire ready;
  wire slow_clk;
  wire [6:0] seven_seg;

  assign io_in[7:0]   = '0;
  assign io_in[9:8]   = driver_sel;     // scan state machine mode selection
  assign io_in[10]    = '0;
  assign io_in[11]    = set_clk_div;    // debug clock configuration
  assign io_in[20:12] = active_select;  // project index selection
  assign io_in[28:21] = inputs;         // project inputs and state machine configuration
  assign io_in[37:29] = '0;
  assign slow_clk     = io_out[10];     // debug clock output
  assign outputs      = io_out[36:29];  // project outputs
  assign ready        = io_out[37];     // 10 ns pulse after each io_out update
  assign seven_seg    = outputs[6:0];   // 7 segment display

  user_project_wrapper dut(
    .wb_clk_i   (clk),
    .wb_rst_i   (reset),
    .wbs_adr_i  ('0),
    .wbs_cyc_i  ('0),
    .wbs_dat_i  ('0),
    .wbs_sel_i  ('0),
    .wbs_stb_i  ('0),
    .wbs_we_i   ('0),
    .io_in      (io_in),
    .la_data_in ('0),
    .la_oenb    ('0),
    .user_clock2('0),
    .analog_io  (),    
    .la_data_out(),
    .user_irq   (),
    .wbs_dat_o  (),
    .wbs_ack_o  (),
    .io_out     (io_out),
    .io_oeb     (io_oeb)
  );  
  
  always #5 clk = ~clk;  // 100 MHz Wishbone clock
  initial #12 reset = 0; 
  
  initial begin
    driver_sel    = 2'b10;  // select internal scan chain without overiding prescaler
    set_clk_div   = '0;  // disable debug clock
    active_select = '0;  // select project number
    inputs        = 8'hA5;  // test vector
    repeat (10) @(negedge clk);  // wait for internal reset
    $display("Input = %x", io_in);
    //repeat (5) @(negedge clk);
    forever begin
      //io_in[7:1] = 32;
      //$display("Input = %0d", io_in[7:1]);
      repeat (5) @(negedge clk);
      //io_in[7:1] = 127;
      //$display("Input = %0d", io_in[7:1]);
      repeat (5) @(negedge clk);
    end
  end

endmodule
