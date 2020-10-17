//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module axi_uart_trx_tb #(
   parameter clk_freq = 4000000,          // Hz
   parameter uart_rate = 125000           // bit per second
);
   localparam [31:0] clk_period=1000000000.0/$itor(clk_freq);
   reg clk = 1'b0;
   wire rst;
   always @(*) begin
     #(clk_period/2);
     clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   wire trxline;

   // AXI UART TX
   localparam TX_SIZE = 10;
   localparam clkdiv_tx= clk_freq/uart_rate;
   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;
   wire axi_tx;
   axi_uart_tx #(
      .SIZE(TX_SIZE)
   ) axi_uart_tx (
      .clk(clk), .rst(rst),
      .i_tdata(i_tdata), .i_tvalid(i_tvalid), .i_tready(),
      .parity_enable(1'b0), .parity_type(1'b0), .fifo_level(),
      .clkdiv(clkdiv_tx), .baudclk(), .tx(axi_tx)
   );
   wire axi_tx1;
   axi_uart_tx #(
      .SIZE(TX_SIZE)
   ) axi_uart_tx1 (
      .clk(clk), .rst(rst),
      .i_tdata(i_tdata), .i_tvalid(i_tvalid), .i_tready(),
      .parity_enable(1'b1), .parity_type(1'b0), .fifo_level(),
      .clkdiv(clkdiv_tx), .baudclk(), .tx(axi_tx1)
   );
   wire axi_tx2;
   axi_uart_tx #(
      .SIZE(TX_SIZE)
   ) axi_uart_tx2 (
      .clk(clk), .rst(rst),
      .i_tdata(i_tdata), .i_tvalid(i_tvalid), .i_tready(),
      .parity_enable(1'b1), .parity_type(1'b1), .fifo_level(),
      .clkdiv(clkdiv_tx), .baudclk(), .tx(axi_tx2)
   );

   always @(*) begin
      #(clk_period*40)
      if(~rst) begin
         #(clk_period/13);
         #(clk_period*10);
         //
         i_tdata <= 8'b01010101;
         i_tvalid <= 1'b1;
         #clk_period;
         i_tdata <= 8'b01010111;
         #clk_period;
         i_tdata <= 8'b01010101;     
         #clk_period;
         i_tdata <= 8'b00000000;
         #clk_period;
         i_tdata <= 8'b10101010;
         #clk_period;
         i_tdata <= 8'b11111111;
         #clk_period;
         i_tdata <= 8'b01010011;
         #clk_period;
         i_tdata <= 8'b11001010;
         #clk_period;
         i_tdata <= 8'b01011010;
         #clk_period;
         i_tdata <= 8'b10100101;
         #clk_period;
         i_tdata <= 8'b01010101;
         #clk_period;
         i_tdata <= 8'b01010101;     
         #clk_period;
         i_tdata <= 8'b00000000;
         #clk_period;
         i_tdata <= 8'b10101010;
         #clk_period;
         i_tdata <= 8'b11111111;
         #clk_period;
         i_tdata <= 8'b01010011;
         #clk_period;
         i_tdata <= 8'b00011000;
         #clk_period;
         i_tvalid <= 1'b0;
         #(clk_period*10);
         //
      end
   end

   // AXI UART RX
   localparam RX_SIZE = 2;
   localparam clkdiv_rx= clk_freq/uart_rate;
   wire [7:0] o_tdata;
   wire parity;
   wire o_tvalid;
   axi_uart_rx #(
      .SIZE(RX_SIZE)
   ) axi_uart_rx (
      .clk(clk), .rst(rst),
      .o_tdata({o_tdata, parity}), .o_tvalid(o_tvalid), .o_tready(1'b1),
      .parity_enable(1'b0), .fifo_level(),
      .clkdiv(clkdiv_rx), .rx(axi_tx)
   );
   wire [7:0] o_tdata1;
   wire o_tvalid1;
   wire parity1;
   axi_uart_rx #(
      .SIZE(RX_SIZE)
   ) axi_uart_rx1 (
      .clk(clk), .rst(rst),
      .o_tdata({o_tdata1, parity1}), .o_tvalid(o_tvalid1), .o_tready(1'b1),
      .parity_enable(1'b1), .fifo_level(),
      .clkdiv(clkdiv_rx), .rx(axi_tx1)
   );
   wire [7:0] o_tdata2;
   wire o_tvalid2;
   wire parity2;
   axi_uart_rx #(
      .SIZE(RX_SIZE)
   ) axi_uart_rx2 (
      .clk(clk), .rst(rst),
      .o_tdata({o_tdata2, parity2}), .o_tvalid(o_tvalid2), .o_tready(1'b1),
      .parity_enable(1'b1), .fifo_level(),
      .clkdiv(clkdiv_rx), .rx(axi_tx2)
   );

endmodule // axi_uart_trx_tb
