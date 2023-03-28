// Title:  Top-level FPGA wrapper in Verilog
// File:   fpga_top.v
// Author: Wallie Everest
// Date:   26-MAR-2023
// URL:    https://github.com/wallieeverest/tt03
//
// Description:
// Implementation:

module fpga_top (
  input  wire       CLK,      // PIO_3[0]
  input  wire       RESET_N,  // pin 81
  input  wire       RTS,      // pin 7
  input  wire       RX,       // pin 9
  input  wire [7:0] INPUTS,   // PIO_0[9:2], pull up
  output wire [7:0] OUTPUTS,  // PIO_2[10:7]
  output wire       READY,    // pin 78
  output wire       LED0,     // pin 99
  output wire       LED1,     // pin 98
  output wire       LED2,     // pin 97
  output wire       LED3,     // pin 96
  output wire       LED4,     // pin 95
  output wire       TX        // pin 8
);

  wire reset;
  wire [37:0] io_in;
  wire [37:0] io_out;

  user_project_wrapper dut(
    .wb_clk_i   (CLK),
    .wb_rst_i   (reset),
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

  assign reset        = ~RESET_N;
  assign io_in[7:0]   = 8'b0;
  assign io_in[9:8]   = 2'b10;    // internal scan state machine mode selection
  assign io_in[10]    = 1'b0;
  assign io_in[11]    = 1'b0;    // debug clock configuration
  assign io_in[20:12] = 9'b0;    // project index selection
  assign io_in[28:21] = INPUTS;  // project inputs and state machine configuration
  assign io_in[37:29] = 9'b0;
  assign OUTPUTS      = io_out[36:29];
  assign READY        = io_out[37];
  assign TX   = RX;
  assign LED0 = 1'b1;
  assign LED1 = 1'b0;
  assign LED2 = 1'b0;
  assign LED3 = 1'b0;
  assign LED4 = RTS;

endmodule
