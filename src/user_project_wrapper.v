// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

//`default_nettype none

// Wrapper for OpenLane Caravel projects
module user_project_wrapper #(
  parameter BITS = 32,
  parameter MPRJ_IO_PADS = 38
)(
  input  wire         wb_clk_i,               // Wishbone Slave ports (WB MI A)
  input  wire         wb_rst_i,
  input  wire [127:0] la_data_in,             // Logic Analyzer Signals
  input  wire [127:0] la_oenb,
  input  wire         user_clock2,            // Independent clock
  input  wire [31:0]  wbs_adr_i,
  input  wire         wbs_cyc_i,
  input  wire [31:0]  wbs_dat_i,
  input  wire [3:0]   wbs_sel_i,
  input  wire         wbs_stb_i,
  input  wire         wbs_we_i,
  output wire         wbs_ack_o,
  output wire [127:0] la_data_out,
  output wire [2:0]   user_irq,               // User maskable interrupt signals
  output wire [31:0]  wbs_dat_o,
  input  wire [MPRJ_IO_PADS-1:0]  io_in,      // IOs
  inout  wire [MPRJ_IO_PADS-10:0] analog_io,  // Analog
  output wire [MPRJ_IO_PADS-1:0]  io_out,
  output wire [MPRJ_IO_PADS-1:0]  io_oeb
);

  localparam K_NUM_DESIGNS = 25;  // 249 for TT03 ASIC, 4 for test FPGA
  localparam K_NUM_IOS = 8;

  wire clk_out [0:K_NUM_DESIGNS];
  wire data_out [0:K_NUM_DESIGNS];
  wire scan_out [0:K_NUM_DESIGNS];
  wire latch_out [0:K_NUM_DESIGNS];

  assign io_out[9:0]        = 10'b0;
  assign io_out[28:11]      = 18'b0;
  assign wbs_ack_o          = 1'b0;
  assign user_irq           = 3'b0;
  assign wbs_dat_o          = 32'b0;
  assign la_data_out[127:1] = 127'b0;

  // Tiny Tapeout Scan Controller
  scan_controller #(.NUM_DESIGNS(K_NUM_DESIGNS)) scan_controller_inst (
    .clk             (wb_clk_i),
    .reset           (wb_rst_i),
    .driver_sel      (io_in[9:8]),
    .set_clk_div     (io_in[11]),
    .active_select   (io_in[20:12]),
    .inputs          (io_in[28:21]),
    .slow_clk        (io_out[10]),
    .outputs         (io_out[36:29]),
    .ready           (io_out[37]),
    .scan_clk_in     (clk_out[K_NUM_DESIGNS]),
    .scan_data_in    (data_out[K_NUM_DESIGNS]),
    .scan_clk_out    (clk_out[0]),
    .scan_data_out   (data_out[0]),
    .scan_select     (scan_out[0]),
    .scan_latch_en   (latch_out[0]),
    .la_scan_clk_in  (la_data_in[0]),
    .la_scan_data_in (la_data_in[1]),
    .la_scan_select  (la_data_in[2]),
    .la_scan_latch_en(la_data_in[3]),
    .la_scan_data_out(la_data_out[0]),
    .oeb             (io_oeb)
  );

  // First project in chain ias a test module that inverts the input data
  // [active_select = 000]
  wire [K_NUM_IOS-1:0] test_module_data_in;
  wire [K_NUM_IOS-1:0] test_module_data_out;
  assign test_module_data_out = ~test_module_data_in;  // https://github.com/TinyTapeout/tt03-test-invert
  scanchain_rtl #(.NUM_IOS(8)) scanchain_001 (
    .clk_in          (clk_out[0]),
    .data_in         (data_out[0]),
    .scan_select_in  (scan_out[0]),
    .latch_enable_in (latch_out[0]),
    .clk_out         (clk_out[1]),
    .data_out        (data_out[1]),
    .scan_select_out (scan_out[1]),
    .latch_enable_out(latch_out[1]),
    .module_data_in  (test_module_data_in),
    .module_data_out (test_module_data_out)
  );

  // Device Under Test is located in the second scan position
  // [active_select = 001]
  wire [K_NUM_IOS-1:0] dut_module_data_in;
  wire [K_NUM_IOS-1:0] dut_module_data_out;
  scanchain_rtl #(.NUM_IOS(8)) scanchain_002 (
    .clk_in          (clk_out[1]),
    .data_in         (data_out[1]),
    .scan_select_in  (scan_out[1]),
    .latch_enable_in (latch_out[1]),
    .clk_out         (clk_out[2]),
    .data_out        (data_out[2]),
    .scan_select_out (scan_out[2]),
    .latch_enable_out(latch_out[2]),
    .module_data_in  (dut_module_data_in),
    .module_data_out (dut_module_data_out)
  );

  // https://github.com/username/projectname
  morningjava_top dut (
    .io_in (dut_module_data_in),
    .io_out(dut_module_data_out)
  );

  // Remaining projects in the scan chain pass through the input data
  genvar i;
  for (i = 3; i <= K_NUM_DESIGNS; i = i+1) begin : scanchain_gen
    wire [K_NUM_IOS-1:0] loopback_data;
    scanchain_rtl #(.NUM_IOS(K_NUM_IOS)) scanchain_fill (
      .clk_in          (clk_out[i-1]),
      .data_in         (data_out[i-1]),
      .scan_select_in  (scan_out[i-1]),
      .latch_enable_in (latch_out[i-1]),
      .clk_out         (clk_out[i]),
      .data_out        (data_out[i]),
      .scan_select_out (scan_out[i]),
      .latch_enable_out(latch_out[i]),
      .module_data_in  (loopback_data),
      .module_data_out (loopback_data)
    );
  end

endmodule

//-------------//
// scanchain.v //
//-------------//

// RTL version of scanchain.v that used sky130 primitives
// Attributes are for Lattice version of Synplify
(* syn_hier="fixed" *)
module scanchain_rtl #(
  parameter NUM_IOS = 8
)(
  input  wire clk_in,
  input  wire data_in,
  input  wire scan_select_in,
  input  wire latch_enable_in,
  input  wire [NUM_IOS-1:0] module_data_out,
  output wire clk_out,
  output reg  data_out,
  output wire scan_select_out,
  output wire latch_enable_out,
  output reg [NUM_IOS-1:0] module_data_in
);

  (* syn_keep=1 *) wire clk_n;
  (* syn_keep=1 *) wire scan_select_out_i;
  (* syn_keep=1 *) wire latch_enable_out_i;
  reg [NUM_IOS-1:0] scan_data_out = 8'b0;  // output of the each scan chain flop

  // Balance the delays through the module
  assign clk_n   = ~clk_in;
  assign clk_out = ~clk_n;
  assign scan_select_out_i  = scan_select_in;
  assign scan_select_out    = scan_select_out_i;
  assign latch_enable_out_i = latch_enable_in;
  assign latch_enable_out   = latch_enable_out_i;

  always @(negedge clk_n) begin : scan_flop
    if (scan_select_in)
      scan_data_out <= module_data_out;
    else 
      scan_data_out <= {scan_data_out[NUM_IOS-2:0], data_in};
  end

  always @(latch_enable_in or scan_data_out) begin : latch
    if (latch_enable_in) 
      module_data_in <= scan_data_out;
  end

  always @(posedge clk_n) begin : out_flop
    data_out <= (scan_data_out[NUM_IOS-1]);
  end

endmodule
