//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM_Development_Bench #(
   parameter clk_freq = 4000000,           // Hz
   parameter uart_rate = 125000,           // bit per second
   parameter ask_rate = 5000,              // bit per second
   parameter LTC2312_sample_rate = 200000  // sample per second
)(
   // Clock and Reset Pins
   input CLOCK, //input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // Intermediate Frequency Modulation
   //output MULP, output MULN,
   // LTC2312 Analog to Digital Converter
   //input AFE_SDO, output AFE_SCK, output AFE_CONV,
   // LED Pin
   output LED
);

   assign LED = ~UART_TX;

   wire rst;
   por_gen por_gen (
      .clk(CLOCK),
      .reset_out(rst)
   );

   // UART RX
   localparam UART_RX_SIZE = 1;
   localparam UART_clkdiv_rx= clk_freq/uart_rate;
   wire [7:0] rx_tdata;
   wire rx_tvalid;
   wire rx_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(UART_RX_SIZE),
      .clkdiv_rx(UART_clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .o_tdata(rx_tdata),
      .o_tvalid(rx_tvalid),
      .o_tready(rx_tready),
      // Input RX port
      .rx(UART_RX)
   );

   // UART TX
   localparam UART_TX_SIZE = 1;
   localparam UART_clkdiv_tx = clk_freq/uart_rate;
   wire [7:0] tx_tdata;
   wire tx_tvalid;
   wire tx_tready;
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

   // development space
   assign tx_tdata = rx_tdata;
   assign tx_tvalid = rx_tvalid;
   assign rx_tready = tx_tready;

endmodule // MDM_Development_Bench
