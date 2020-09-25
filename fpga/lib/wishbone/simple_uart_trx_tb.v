//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module simple_uart_trx_tb #(
   parameter clk_freq = 4000000,          // Hz
   parameter uart_rate = 125000           // bit per second
);
   localparam [31:0] clk_period=1000000000.0/$itor(clk_freq); // ps
   reg clk = 1'b0;
   wire rst;
   always @(*) begin
     #(clk_period/2);
     clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   wire trxline;

   // UART TX
   localparam TX_SIZE = 10;
   localparam clkdiv_tx= clk_freq/uart_rate;
   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;
   wire i_tready;
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      // Output TX port
      .tx(trxline)
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

   // UART RX
   localparam RX_SIZE = 10;
   localparam clkdiv_rx = clk_freq/uart_rate;
   wire [7:0] o_tdata;
   wire o_tvalid;
   reg o_tready = 1'b0;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .o_tdata(o_tdata),
      .o_tvalid(o_tvalid),
      .o_tready(o_tready),
      // Input RX port
      .rx(trxline)
   );
   always @(*) begin
      #(clk_period*40)
      if(~rst) begin
         #(clk_period/13);
         #(clk_period*100);
         o_tready <= 1'b1;
      end
   end

endmodule // simple_uart_trx_tb
