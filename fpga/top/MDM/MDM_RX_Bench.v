//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM_RX_Bench #(
   parameter clk_freq = 8000000,           // Hz
   parameter uart_rate = 125000,           // bit per second
   parameter ask_rate = 5000,              // bit per second
   parameter LTC2312_sample_rate = 200000, // sample per second
   parameter LTC2312_precision = 14        // output bit length
)(
   // Clock and Reset Pins
   input CLOCK, //input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // Intermediate Frequency Modulation
   output MULP, output MULN,
   // LTC2312 Analog to Digital Converter
   input AFE_SDO, output AFE_SCK, output AFE_CONV,
   // LED Pin
   output LED
);

   assign LED = ~UART_TX;
   assign MULP = 1'b0;
   assign MULN = 1'b0;

   wire rst;
   por_gen por_gen (
      .clk(CLOCK),
      .reset_out(rst)
   );
   // LTC2312 ADC chip
   wire [LTC2312_precision-1:0] LTC2312_tdata;
   wire LTC2312_tvalid;
   LTC2312 #(
      .WIDTH(LTC2312_precision),
      .clk_freq(clk_freq),
      .sample_rate(LTC2312_sample_rate)
   ) LTC2312 (
      .clk(CLOCK), .rst(rst), .clear(1'b0),
      .enable(1'b1),
      // Output Stream ports
      .o_tdata(LTC2312_tdata),
      .o_tvalid(LTC2312_tvalid),
      // SPI ports
      .CONV(AFE_CONV), .SCK(AFE_SCK), .SDO(AFE_SDO)
   );
   // Filter Integrator
   localparam Integrator_SIZE = LTC2312_sample_rate/(2*ask_rate);
   wire [LTC2312_precision:0] i_Integrator_date;
   wire i_Integrator_valid;
   wire [LTC2312_precision+$clog2(Integrator_SIZE+1):0] o_Integrator_date;
   wire o_Integrator_valid, o_Integrator_ready;
   BoundedIntegrator #(
      .WIDTH(LTC2312_precision+1),
      .SIZE(Integrator_SIZE)
   ) BoundedIntegrator (
      .clk(CLOCK), .reset(rst), .clear(1'b0),
      .i_tdata(i_Integrator_date),
      .i_tvalid(i_Integrator_valid),
      .i_tready(),
      .o_tdata(o_Integrator_date),
      .o_tvalid(o_Integrator_valid),
      .o_tready(o_Integrator_ready)
   );
   assign i_Integrator_date = {1'b0, LTC2312_tdata};
   assign i_Integrator_valid = LTC2312_tvalid;
   //Threshold ASK Detector
   //automatic Threshold
   wire ask_automatic_rx;
   automatic_threshold_ask_detector #(
      .WIDTH(LTC2312_precision+$clog2(Integrator_SIZE+1)-1),
      .DEPTH(8),
      .MINTHRESHOLD(160)
   ) automatic_threshold_ask_detector (
      .clk(CLOCK), .reset(rst), .clear(1'b0), .enable(1'b1),
      .i_tdata(o_Integrator_date), .i_tvalid(o_Integrator_valid), .i_tready(o_Integrator_ready),
      .rx(ask_automatic_rx)
   );
   // ASK UART RX
   localparam ASK_RX_SIZE = 1;
   localparam ASK_clkdiv_rx = clk_freq/ask_rate;
   wire [7:0] ask_rx_tdata;
   wire ask_rx_tvalid, ask_rx_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(ASK_RX_SIZE),
      .clkdiv_rx(ASK_clkdiv_rx)
   ) ask_axis_uart_rx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .o_tdata(ask_rx_tdata),
      .o_tvalid(ask_rx_tvalid),
      .o_tready(ask_rx_tready),
      // Input RX port
      .rx(ask_automatic_rx)
   );
   // UART TX
   localparam UART_TX_SIZE = 1;
   localparam UART_clkdiv_tx = clk_freq/uart_rate;
   wire [7:0] tx_tdata;
   wire tx_tvalid, tx_tready;
   axis_uart_tx_wrapper #(
      .TX_SIZE(UART_TX_SIZE),
      .clkdiv_tx(UART_clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(tx_tdata),
      .i_tvalid(tx_tvalid),
      .i_tready(tx_tready),
      // Output TX port
      .tx(UART_TX)
   );
   assign tx_tdata = ask_rx_tdata;
   assign tx_tvalid = ask_rx_tvalid;
   assign ask_rx_tready = tx_tready;

endmodule // MDM_RX_Bench
