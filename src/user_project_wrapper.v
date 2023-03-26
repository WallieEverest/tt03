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

`default_nettype wire

// Wrapper for OpenLane Caravel projects
module user_project_wrapper #(
  parameter BITS = 32,
  parameter MPRJ_IO_PADS = 38
)(
`ifdef USE_POWER_PINS
  inout vdda1,  // User area 1 3.3V supply
  inout vdda2,  // User area 2 3.3V supply
  inout vssa1,  // User area 1 analog ground
  inout vssa2,  // User area 2 analog ground
  inout vccd1,  // User area 1 1.8V supply
  inout vccd2,  // User area 2 1.8v supply
  inout vssd1,  // User area 1 digital ground
  inout vssd2,  // User area 2 digital ground
`endif
  input          wb_clk_i,               // Wishbone Slave ports (WB MI A)
  input          wb_rst_i,
  input  [127:0] la_data_in,             // Logic Analyzer Signals
  input  [127:0] la_oenb,
  input          user_clock2,            // Independent clock
  input  [31:0]  wbs_adr_i,
  input          wbs_cyc_i,
  input  [31:0]  wbs_dat_i,
  input  [3:0]   wbs_sel_i,
  input          wbs_stb_i,
  input          wbs_we_i,
  output         wbs_ack_o,
  output [127:0] la_data_out,
  output [2:0]   user_irq,               // User maskable interrupt signals
  output [31:0]  wbs_dat_o,
  input  [MPRJ_IO_PADS-1:0]  io_in,      // IOs
  inout  [MPRJ_IO_PADS-10:0] analog_io,  // Analog
  output [MPRJ_IO_PADS-1:0]  io_out,
  output [MPRJ_IO_PADS-1:0]  io_oeb
);

  localparam K_NUM_DESIGNS = 249;  // 249 for TT03 ASIC, 4 for test FPGA
  localparam K_NUM_IOS = 8;

  wire clk_out [0:K_NUM_DESIGNS];
  wire data_out [0:K_NUM_DESIGNS];
  wire scan_out [0:K_NUM_DESIGNS];
  wire latch_out [0:K_NUM_DESIGNS];

  // Tiny Tapeout Scan Controller
  scan_controller #(.NUM_DESIGNS(K_NUM_DESIGNS)) scan_controller (
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

endmodule	: user_project_wrapper

//-------------//
// scanchain.v //
//-------------//

// RTL version of scanchain.v that used sky130 primitives
module scanchain_rtl #(
  parameter NUM_IOS = 8
)(
  input  wire clk_in,
  input  wire data_in,
  input  wire scan_select_in,
  input  wire latch_enable_in,
  input  wire [NUM_IOS-1:0] module_data_out,
  output wire clk_out,
  output wire data_out,
  output wire scan_select_out,
  output wire latch_enable_out,
  output reg [NUM_IOS-1:0] module_data_in
);

  wire clk;
  reg data_out_i;
  reg [NUM_IOS-1:0] scan_data_out;  // output of the each scan chain flop
  reg [NUM_IOS-1:0] scan_data_in;   // input of each scan chain flop

  assign clk = clk_in;
  assign clk_out = clk;
  assign data_out = data_out_i;
  assign scan_select_out = scan_select_in;
  assign latch_enable_out = latch_enable_in;

  always @(*) begin : primitive_logic
    scan_data_in <= {scan_data_out[NUM_IOS-2:0], data_in};
  end

  always @(negedge clk) begin : out_flop
    data_out_i <= (scan_data_out[NUM_IOS-1]);
  end

  always @(posedge clk) begin : scan_flop
    if (scan_select_in)
      scan_data_out <= module_data_out;
    else 
      scan_data_out <= scan_data_in;
  end

  always @(latch_enable_in or scan_data_out) begin : latch
    if (latch_enable_in) 
      module_data_in <= scan_data_out;
  end

endmodule
