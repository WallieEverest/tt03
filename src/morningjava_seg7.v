// Title:  7-segment decoder for the TinyTapeout-02 PCB
// File:   morningjava_seg7.v
// Author: Wallace Everest
// Date:   25-NOV-2022
// URL:    https://github.com/wallieeverest/tt03
//
// Description:
//   Converts a 4-bit binary code to 7-segment hexadecimal
//   Segment illustration:
//    -- a --
//   |       |
//   f       b
//   |       |
//    -- g --
//   |       |
//   e       c
//   |       |
//    -- d --  (p)
//

`default_nettype none

module morningjava_seg7 (
  input  wire       clk,
  input  wire [3:0] data_in,
  output reg  [7:0] segments
);
  always @(posedge clk) begin : segment_decoder
    case(data_in)
      // ext. connections:   pgfedcba
      4'h0:    segments = 8'b00111111;
      4'h1:    segments = 8'b00000110;
      4'h2:    segments = 8'b01011011;
      4'h3:    segments = 8'b01001111;
      4'h4:    segments = 8'b01100110;
      4'h5:    segments = 8'b01101101;
      4'h6:    segments = 8'b01111100;
      4'h7:    segments = 8'b00000111;
      4'h8:    segments = 8'b01111111;
      4'h9:    segments = 8'b01100111;
      4'hA:    segments = 8'b01110111;
      4'hB:    segments = 8'b01111100;
      4'hC:    segments = 8'b00111001;
      4'hD:    segments = 8'b01011110;
      4'hE:    segments = 8'b01111001;
      4'hF:    segments = 8'b01110001;
      default: segments = 8'b10000000;  // only occurs in simulation for undefined input
    endcase
  end : segment_decoder
endmodule
