//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module simple_ask_uart_tx_tb #(
   parameter clk_freq = 4000000,          // Hz
   parameter uart_rate = 125000           // bit per second
);
   parameter [31:0] clk_period=1000000000.0/$itor(clk_freq);
   parameter clkdiv = clk_freq/uart_rate;
   parameter TX_SIZE = 6;
   parameter RX_SIZE = 2;
   reg clk = 1'b0;
   wire rst;
   always @(*) begin
     #(clk_period/2);
     clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   parameter ask_tx_length_model = 8;
   wire [1:0] ask_tx;
   wire [ask_tx_length_model-1:0] ask_tx_model;
   wire tx;

   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;

   wire i_tready_ask;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv)
   ) simple_axis_ask_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready_ask),
      // ASK output port
      .ask_tx(ask_tx)
   );

   axis_ask_uart_tx_wrapper #(
      .ask_core_type("model"),
      .ask_tx_length(ask_tx_length_model),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv)
   ) model_axis_ask_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(),
      // ASK output port
      .ask_tx(ask_tx_model)
   );

   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(),
      // Output TX port
      .tx(tx)
   );

   always @(*) begin
      #(clk_period*313);
      if(~rst) begin
         #(clk_period*110);
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
         #(clk_period*110);
         //
      end
   end
   ////////////////////////////////////// RX //////////////////////////////////////
   wire [ask_tx_length_model-1:0] ask_rx_model;
   assign ask_rx_model = ( ask_tx_model[ask_tx_length_model-1]==1'b0 ? ask_tx_model : 0 );

   parameter SIZE = (clkdiv/2)-3;
   wire [ask_tx_length_model+$clog2(SIZE+1)-1:0] BoundedIntegratorOut;
   wire BoundedIntegratorOut_valid;
   BoundedIntegrator #(
      .WIDTH(ask_tx_length_model),
      .SIZE(SIZE)
   ) BoundedIntegrator (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(ask_rx_model),
      .i_tvalid(1'b1),
      .i_tready(),
      .o_tdata(BoundedIntegratorOut),
      .o_tvalid(BoundedIntegratorOut_valid),
      .o_tready(1'b1)
   );
   wire [ask_tx_length_model+$clog2(SIZE+1)-1:0] DirectBoundedIntegratorOut;
   wire DirectBoundedIntegratorOut_valid;
   DirectBoundedIntegrator #(
      .WIDTH(ask_tx_length_model),
      .SIZE(SIZE)
   ) DirectBoundedIntegrator (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(ask_rx_model),
      .i_tvalid(1'b1),
      .i_tready(),
      .o_tdata(DirectBoundedIntegratorOut),
      .o_tvalid(DirectBoundedIntegratorOut_valid),
      .o_tready(1'b1)
   );

   wire rx;
   manual_threshold_ask_detector #(
      .WIDTH(ask_tx_length_model+$clog2(SIZE+1)-1)
   ) manual_threshold_ask_detector (
      .clk(clk), .reset(rst), .clear(1'b0), .enable(1'b1),
      .i_tdata(DirectBoundedIntegratorOut), .i_tvalid(DirectBoundedIntegratorOut_valid), .i_tready(),
      .upthreshold($signed(501)), .downthreshold($signed(139)),
      .rx(rx)
   );

   // UART RX
   wire [7:0] o_tdata;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv)
   ) axis_uart_rx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .o_tdata(o_tdata),
      .o_tvalid(),
      .o_tready(1'b1),
      // Input RX port
      .rx(rx)
   );

endmodule // simple_ask_uart_tx_tb
