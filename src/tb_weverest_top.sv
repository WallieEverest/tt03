// Title:  Square root testbench
// File:   tb_sqrt.sv
// Author: Wallace Everest
// Date:   23-NOV-2022
// URL:    https://github.com/navray/tt02-square-root

`default_nettype none

module tb_sqrt_gl ();

  logic       vccd1 = 3;
  logic       vssd1 = 0;
  logic       clk;
  logic [7:0] io_in;
  logic [7:0] io_out;

  assign io_in[0] = clk;
  
  weverest_top_gl navray_top_gl_dut (
    .vccd1 (vccd1),
    .vssd1 (vssd1),
    .io_in (io_in),
    .io_out(io_out)
  );
  
  initial begin
    clk = 1'b0;
    repeat (40) #500us clk = ~clk;
  end
  
  initial begin
    io_in[7:1] = 0;
    $display("Input = %0d", io_in[7:1]);
    repeat (5) @(negedge clk);
    forever begin
      io_in[7:1] = 32;
      $display("Input = %0d", io_in[7:1]);
      repeat (5) @(negedge clk);
      io_in[7:1] = 127;
      $display("Input = %0d", io_in[7:1]);
      repeat (5) @(negedge clk);
    end
  end
endmodule
