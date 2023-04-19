`default_nettype none

module decoder (
  input  wire sck,
  input  wire sdi,
  output reg  [7:0] apu_reg_0,
  output reg  [7:0] apu_reg_1,
  output reg  [7:0] apu_reg_2,
  output reg  [7:0] apu_reg_3,
  output reg  [7:0] apu_reg_4,
  output reg  [7:0] apu_reg_5,
  output reg  [7:0] apu_reg_6,
  output reg  [7:0] apu_reg_7
);

always @ ( posedge sck ) begin
  apu_reg_0 = 0;
  apu_reg_1 = 0;
  apu_reg_2 = 0;
  apu_reg_3 = 0;
  apu_reg_4 = 0;
  apu_reg_5 = 0;
  apu_reg_6 = 0;
  apu_reg_7 = 0;
end

endmodule