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

`default_nettype none

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

  localparam NUM_DESIGNS = 5;  // 250 for TT03 ASIC, 5 for test FPGA
  localparam NUM_IOS = 8;

  wire tms [0:NUM_DESIGNS];
  wire tck [0:NUM_DESIGNS];
  wire td  [0:NUM_DESIGNS];
  wire [NUM_IOS-1:0] i_data [0:NUM_DESIGNS];
  wire [NUM_IOS-1:0] o_data [0:NUM_DESIGNS];
  wire controller_tck;
  wire controller_tdi;
  wire controller_tms;
  wire ref_clk;
  wire led;
  genvar i;

  assign wbs_ack_o = 0;
  assign user_irq  = 0;
  assign wbs_dat_o = 0;
  assign io_oeb    = 0;
  assign analog_io = 0;
  assign la_data_out[127:0] = 0;
  
  // Pin assignments
  assign io_out[9:0]     = 0;                           // shared with inputs and Caravel logic
  assign io_out[28:11]   = 0;                           // shared with inputs
  assign io_out[36:29]   = o_data[0];                   // IO_OUT
  assign io_out[10]      = ref_clk;                     // RTCK
  assign io_out[37]      = td[NUM_DESIGNS];             // TDO
  wire   select          = io_in[19:12];                // project selection
  wire   clk             = wb_clk_i;
  assign i_data[0]       = io_in[28:21];                // IO_IN
  wire   mode            = io_in[8];                    // MODE
  wire   baud_clk        = io_in[9];                    // BAUD_CLK
  assign tck[0] = (mode) ? io_in[11] : controller_tck;  // TCK
  assign tms[0] = (mode) ? io_in[9]  : controller_tms;  // TMS
  assign td[0]  = (mode) ? io_in[20] : controller_tdi;  // TDI

  // Bit-clock generator derived from asynchronous serial data input
  clk_gen clk_gen_inst (
    .clk  (baud_clk),
    .rx   (io_in[20]),
    .tck  (ref_clk)
  );

  // Internal scan chain controller
  controller controller_inst (
    .clk   (clk),
    .reset (1'b0),
    .rtck  (tck[NUM_DESIGNS]),
    .tdo   (td[NUM_DESIGNS]),
    .addr  (select),
    .i_pins(i_data[0]),
    .o_pins(o_data[0]),
    .tck   (controller_tck),
    .tms   (controller_tms),
    .tdi   (controller_tdi)
  );

  // Tap instances for scan chain
  for (i=1; i<=NUM_DESIGNS; i=i+1) begin : tap_gen
    localparam [7:0] address = i;
    tap tap_inst (
      .i_tck   (tck[i-1]),
      .i_tms   (tms[i-1]),
      .i_tdi   (td[i-1]),
      .outbound(o_data[i]),
      .address (address),
      .inbound (i_data[i]),
      .o_tck   (tck[i]),
      .o_tms   (tms[i]),
      .o_tdo   (td[i])
    );
  end

  // Default data loopback for unused project locations
  for (i=2; i<=NUM_DESIGNS; i=i+1)
    assign o_data[i] = ~i_data[i];

  // *** Project list ***
  // User_01
  morningjava_top morningjava_top_inst(
    .io_in (i_data[1]),
    .io_out(o_data[1])
  );

endmodule
