//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module LTC2312_tb #(
   parameter WIDTH = 14,
   parameter clk_freq = 4000000,  // Hz
   parameter clk_per=250,         // ns
   parameter sample_rate = 200000 //Sample/Second
)();
   reg clk = 1'b0;
   always @(*) begin
      #(clk_per/2)
      clk <= ~clk;
   end
   wire rst;
   reg clear = 1'b0;
   reg reset = 1'b0;
   por_gen por_gen (.clk(clk), .reset_out(rst) );
   reg enable = 1'b0;
   wire [WIDTH-1:0] o_tdata;
   wire o_tvalid;
   wire CONV, SCK, SDO;
   LTC2312 #(
      .WIDTH(WIDTH),             // 12 or 14
      .clk_freq(clk_freq),       // max=20000000
      .sample_rate(sample_rate)  // max=500000
   ) LTC2312 (
      .clk(clk), .rst(rst | reset), .clear(clear),
      .enable(enable),
      // Output Stream ports
      .o_tdata(o_tdata),
      .o_tvalid(o_tvalid),
      // SPI ports
      .CONV(CONV), .SCK(SCK), .SDO(SDO)
   );
   always @(*) begin
      if(~rst) begin
         #(clk_per*100);
         enable <= 1'b1;
      end
   end
endmodule // LTC2312_tb
