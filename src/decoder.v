// Title:   Serial register decoder
// File:    decoder.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:
// Operation:

`default_nettype none

module decoder (
  input  wire sck,
  input  wire sdi,
  output reg  [7:0] apu_reg_0 = 0,
  output reg  [7:0] apu_reg_1 = 0,
  output reg  [7:0] apu_reg_2 = 0,
  output reg  [7:0] apu_reg_3 = 0,
  output reg        reg_change = 0
);

  localparam WIDTH = 10;  // number of bits in message
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP = 1'b1;

  reg  [WIDTH-1:0] shift = IDLE;  // default to IDLE pattern
  wire [WIDTH-1:0] next_shift = {sdi, shift[WIDTH-1:1]};  // right-shift and get next TDI bit
  wire [2:0] addr = shift[WIDTH-3:5];  // address is upper nibble
  wire [3:0] data = shift[WIDTH-6:1];  // data is lower nibble
  reg  [3:0] hold = 0;
  reg  [3:0] bit_count = 0;
  wire zero_count = (bit_count == 0);
  wire msg_sync = (shift[WIDTH-1] == STOP) && (shift[0] == START) && zero_count;  // valid message

  always @(posedge sck) begin
    shift <= next_shift;  // TDI captured on rising edge of TCK

    if (zero_count)
      bit_count <= WIDTH-1;
    else if ((shift[WIDTH-1] == START) || (bit_count != WIDTH-1))  // synchronize with IDLE pattern
      bit_count <= bit_count - 1;

    if (msg_sync) begin // capture user inbound data
      hold <= data;  // hold first 4-bits and wait for remaining half
      if (addr[0] == 1)
        reg_change <= ~reg_change;  // toggle on register update
      case (addr)
        1:  apu_reg_0 <= {data, hold};
        3:  apu_reg_1 <= {data, hold};
        5:  apu_reg_2 <= {data, hold};
        7:  apu_reg_3 <= {data, hold};
        // 9:  apu_reg_4 <= {data, hold};
        // 11: apu_reg_5 <= {data, hold};
        // 13: apu_reg_6 <= {data, hold};
        // 15: apu_reg_7 <= {data, hold};
      endcase
    end
  end

endmodule
