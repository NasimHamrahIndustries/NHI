//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module axi_uart_rx #(
   parameter SIZE=8
)(
   input clk, input rst,
   output [8:0] o_tdata, output o_tvalid, input o_tready,
   input parity_enable, output [15:0] fifo_level,
   input [15:0] clkdiv, input rx
);

   reg rx_d1, rx_d2;
   always @(posedge clk)
      if(rst) {rx_d2, rx_d1} <= 0;
      else    {rx_d2, rx_d1} <= {rx_d1, rx};

   reg [15:0] baud_ctr;
   reg [3:0] bit_ctr;
   reg [7:0] sr;
   reg [8:0] psr;

   wire neg_trans = rx_d2 & ~rx_d1;
   wire shift_now = baud_ctr == (clkdiv>>1);
   wire stop_now = (bit_ctr == 10 + parity_enable) && shift_now;
   wire go_now = (bit_ctr == 0) && neg_trans;

   always @(posedge clk)
      if(rst)            sr <= 0;
      else if(shift_now) sr <= {rx_d2, sr[7:1]};

   always @(posedge clk)
      if(rst)            psr <= 0;
      else if(shift_now) psr <= {rx_d2, psr[8:1]};

   always @(posedge clk)
      if(rst)
         baud_ctr <= 0;
      else
         if(go_now)                  baud_ctr <= 1;
         else if(stop_now)           baud_ctr <= 0;
         else if(baud_ctr >= clkdiv) baud_ctr <= 1;
         else if(baud_ctr != 0)      baud_ctr <= baud_ctr + 1;

   always @(posedge clk)
      if(rst)
         bit_ctr <= 0;
      else
         if(go_now)                  bit_ctr <= 1;
         else if(stop_now)           bit_ctr <= 0;
         else if(baud_ctr == clkdiv) bit_ctr <= bit_ctr + 1;

   wire i_tready;
   wire full = ~i_tready;
   wire write = ~full & stop_now;

   axi_fifo #(
      .WIDTH(9), .SIZE(SIZE)
   ) fifo (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(parity_enable ? psr : {1'b0, sr}), .i_tvalid(write), .i_tready(i_tready),
      .o_tdata(o_tdata), .o_tvalid(o_tvalid), .o_tready(o_tready),
      .space(), .occupied(fifo_level)
   );

endmodule // axi_uart_rx
