// Title:   Top-level FPGA wrapper
// File:    fpga_top.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/scanchain_v2
// License: Apache 2.0
//
// Description: Test of a Tiny Tapeout project on an FPGA evaluation board.
// Implementation: Targets a Lattice iCEstick Evaluation Kit with an iCE40HX1K-TQ100.
// The COM port is the latter selection of the two FTDI ports.

`default_nettype none

module fpga_top (
  input  wire       CLK,     // PIO_3[0], pin 21 (ICE_CLK)
  input  wire       TRST,    // PIO_3[4], pin 3  (RS232_DTRn)
  input  wire       MODE,    // PIO_1[9], pin 91 (pullup)
  input  wire       RX,      // PIO_3[8], pin 9  (RS232_RX)
  input  wire       TMS,     // PIO_3[6], pin 7  (RS232_RTSn)
  input  wire [7:0] I_DATA,  // PIO_0[9:2]       (pullup)
  output wire [7:0] O_DATA,  // PIO_2[10:17]
  output wire       TCK,     // PIO_1[2], pin 78
  output wire       TDI,     // PIO_1[3], pin 79
  output wire       TDO,     // PIO_1[4], pin 80
  output wire       RTCK,    // PIO_1[5], pin 81
  output wire       TX,      // PIO_3[7], pin 8  (RS232_TX)
  output wire [4:0] LED      // PIO_1[10:14]
);

  localparam MPRJ_IO_PADS = 38;
  wire [MPRJ_IO_PADS-1:0] io_in;
  wire [MPRJ_IO_PADS-1:0] io_out;
  wire blink;
  wire link;

  // Evaluation board features
  assign LED[0] = 1;      // D1, power
  assign LED[1] = TMS;    // D2, test enable from COM
  assign LED[2] = TRST;   // D3, reset from COM
  assign LED[3] = link;   // D4, RX activity status
  assign LED[4] = blink;  // D5, 1 Hz blink
  
  // Connections via the Caravel wrapper
  assign io_in[7:0]   = 0;        // Caravel reserved
  assign io_in[8]     = MODE;     // mode selection [0: auto, 1: UART]
  assign io_in[9]     = TMS;      // test mode select
  assign io_in[10]    = 0;        // shared with outputs
  assign io_in[11]    = TCK;      // test clock
  assign io_in[19:12] = 8'd2;     // project index
  assign io_in[20]    = RX;       // test input data
  assign io_in[28:21] = I_DATA;   // input pins to projects
  assign io_in[37:29] = 0;        // shared with outputs
  assign RTCK   = io_out[10];     // test clock out
  assign O_DATA = io_out[36:29];  // output pins from projects
  assign TDO    = io_out[37];     // test data output
  assign TX     = io_out[37];     // serial data to host

  user_project_wrapper #(.MPRJ_IO_PADS(MPRJ_IO_PADS)) dut (
    .wb_clk_i   (CLK),
    .wb_rst_i   (TRST),
    .wbs_adr_i  (32'b0),
    .wbs_cyc_i  (1'b0),
    .wbs_dat_i  (32'b0),
    .wbs_sel_i  (4'b0),
    .wbs_stb_i  (1'b0),
    .wbs_we_i   (1'b0),
    .io_in      (io_in),
    .la_data_in (128'b0),
    .la_oenb    (128'b0),
    .user_clock2(1'b0),
    .analog_io  (),    
    .la_data_out(),
    .user_irq   (),
    .wbs_dat_o  (),
    .wbs_ack_o  (),
    .io_out     (io_out),
    .io_oeb     ()
  );

  uart #(
    .CLKRATE(12_000_000),
    .BAUDRATE(115_200)
  ) uart_inst (
    .clk(CLK),
    .rx(RX),
    .tck(TCK),
    .tdi(TDI),
    .blink(blink),
    .link(link)
  );
  
endmodule
