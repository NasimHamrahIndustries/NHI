//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM_LTC2312_2K_Tester #(
   parameter RX_SIZE = 1,
   parameter clkdiv_rx = 50,
   parameter TX_SIZE = 1,
   parameter clkdiv_tx = 50,
   parameter clk_freq = 4000000,
   parameter LTC2312_sample_rate = 200000
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
   reg [1:0] state = 2'b00;
   // state == 2'b00 : Waiting for command from host PC side
   // state == 2'b01 : Capturing a fram of ADC samples
   // state == 2'b10 : Transmitting ADC samples to PC
   // state == 2'b11 : Illegal state

   assign LED = ~UART_TX;

   wire rst;
   por_gen por_gen (
      .clk(CLOCK),
      .reset_out(rst)
   );

   wire [7:0] rx_tdata;
   wire rx_tvalid;
   wire rx_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .o_tdata(rx_tdata),
      .o_tvalid(rx_tvalid),
      .o_tready(rx_tready),
      // Input RX port
      .rx(UART_RX)
   );

   wire [1:0] ask_tx;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) simple_axis_ask_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(rx_tdata),
      .i_tvalid(rx_tvalid),
      .i_tready(rx_tready),
      // ASK output port
      .ask_tx(ask_tx)
   );
   assign MULP = ( ask_tx==2'b01 ? 1'b1 : 1'b0 );
   assign MULN = ( ask_tx==2'b11 ? 1'b1 : 1'b0 );

   wire [7:0] tx_tdata;
   wire tx_tvalid;
   wire tx_tready;
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(tx_tdata),
      .i_tvalid(tx_tvalid),
      .i_tready(tx_tready),
      // Output TX port
      .tx(UART_TX)
   );
   assign tx_tvalid = ( state==2'b10 ? tx_tready : 1'b0 );

   wire enable;
   wire [13:0] LTC2312_tdata;
   wire LTC2312_tvalid;
   LTC2312 #(
      .WIDTH(14),
      .clk_freq(clk_freq),
      .sample_rate(LTC2312_sample_rate)
   ) LTC2312 (
      .clk(CLOCK), .rst(rst), .clear(1'b0),
      .enable(enable),
      // Output Stream ports
      .o_tdata(LTC2312_tdata),
      .o_tvalid(LTC2312_tvalid),
      // SPI ports
      .CONV(AFE_CONV), .SCK(AFE_SCK), .SDO(AFE_SDO)
   );
   assign enable = ( state==2'b01 ? 1'b1 : 1'b0 );

   wire FIFO_WE;
   wire FIFO_RE;
   wire FIFO_FULL;
   wire FIFO_EMPTY;
   FIFOCore_2Bto1B_2048 FIFOCore_2Bto1B_2048 (
      .DATA({2'b00, LTC2312_tdata}),
      .Q(tx_tdata),
      .WE(FIFO_WE),
      .RE(FIFO_RE),
      .CLK(CLOCK),
      .FULL(FIFO_FULL),
      .EMPTY(FIFO_EMPTY),
      .RESET(rst)
   );
   assign FIFO_WE = ( state==2'b01 ? LTC2312_tvalid : 1'b0 );
   assign FIFO_RE = ( state==2'b10 ? tx_tready : 1'b0 );

   // Control Unit
   always @(posedge CLOCK)
      if(rst)
         state <= 2'b00;
      else
         case (state)
            2'b00   : if(rx_tdata==$unsigned(110) & rx_tvalid & rx_tready) state <= 2'b01;
            2'b01   : if(FIFO_FULL)                                        state <= 2'b10;
            2'b10   : if(FIFO_EMPTY)                                       state <= 2'b00;
            default :                                                      state <= 2'b00;
         endcase

endmodule // MDM_LTC2312_2K_Tester
