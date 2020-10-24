//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM #(
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
   // MCU<->UART Pins
   output MDM_TxD, input MDM_RxD,
   // MCU<->SPI Pins
   input MDM_CS, //output MDM_SDO,  input MDM_SDI, input MDM_SCK,
   // Intermediate Frequency Modulation
   output MULP, output MULN,
   // LTC2312 Analog to Digital Converter
   input AFE_SDO, output AFE_SCK, output AFE_CONV,
   // LED Pin
   output LED
);

   wire rst;
   por_gen por_gen (
      .clk(CLOCK),
      .reset_out(rst)
   );
   ////////////////////////////////
   //
   // Receiver Side Modules
   //
   ////////////////////////////////
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
      .o_tdata(LTC2312_tdata), .o_tvalid(LTC2312_tvalid),
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
      .i_tdata(i_Integrator_date), .i_tvalid(i_Integrator_valid), .i_tready(),
      .o_tdata(o_Integrator_date), .o_tvalid(o_Integrator_valid), .o_tready(o_Integrator_ready)
   );
   assign i_Integrator_date = {1'b0, LTC2312_tdata};
   assign i_Integrator_valid = LTC2312_tvalid;
   //Threshold ASK Detector
   //Manual Threshold
   /*reg [LTC2312_precision+$clog2(Integrator_SIZE+1):0] upthreshold   = $unsigned(24000);
   reg [LTC2312_precision+$clog2(Integrator_SIZE+1):0] downthreshold = $unsigned(8000);
   always @(posedge CLOCK)
      if(rst) begin
         upthreshold   <= $unsigned(24000);
         downthreshold <= $unsigned(8000);
      end*/
   wire ask_manual_rx;
   manual_threshold_ask_detector #(
      .WIDTH(LTC2312_precision+$clog2(Integrator_SIZE+1)+1)
   ) manual_threshold_ask_detector (
      .clk(CLOCK), .reset(rst), .clear(1'b0), .enable(1'b1),
      .i_tdata(o_Integrator_date), .i_tvalid(o_Integrator_valid), .i_tready(o_Integrator_ready),
      .upthreshold($unsigned(24000)), .downthreshold($unsigned(8000)),
      .rx(ask_manual_rx)
   );
   //automatic Threshold
   wire ask_automatic_rx;
   /*automatic_threshold_ask_detector #(
      .WIDTH(32),
      .DEPTH(10),
      .MINTHRESHOLD(200)
   ) automatic_threshold_ask_detector (
      .clk(CLOCK), .reset(rst), .clear(1'b0), .enable(1'b1),
      .i_tdata($signed(o_Integrator_date)), .i_tvalid(o_Integrator_valid), .i_tready(o_Integrator_ready),
      .rx(ask_automatic_rx)
   );*/
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
      .o_tdata(ask_rx_tdata), .o_tvalid(ask_rx_tvalid), .o_tready(ask_rx_tready),
      // Input RX port
      .rx(ask_manual_rx)
      //.rx(ask_automatic_rx)
   );
   // MCU UART TX
   wire MDM_Tx;
   localparam MCU_TX_SIZE = 1;
   localparam MCU_clkdiv_tx = clk_freq/ask_rate;
   axis_uart_tx_wrapper #(
      .TX_SIZE(MCU_TX_SIZE),
      .clkdiv_tx(MCU_clkdiv_tx)
   ) mcu_axis_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(ask_rx_tdata), .i_tvalid(ask_rx_tvalid), .i_tready(ask_rx_tready),
      // Output TX port
      .tx(MDM_Tx)
   );
   ////////////////////////////////
   //
   // Transmitter Side Modules
   //
   ////////////////////////////////
   // MCU UART RX
   localparam MCU_RX_SIZE = 1;
   localparam MCU_clkdiv_rx = clk_freq/ask_rate;
   wire [7:0] mcu_rx_tdata;
   wire mcu_rx_tvalid, mcu_rx_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(MCU_RX_SIZE),
      .clkdiv_rx(MCU_clkdiv_rx)
   ) mcu_axis_uart_rx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .o_tdata(mcu_rx_tdata), .o_tvalid(mcu_rx_tvalid), .o_tready(mcu_rx_tready),
      // Input RX port
      .rx(MDM_RxD)
   );
   // ASK TX
   localparam ASK_TX_SIZE = 1;
   localparam ASK_clkdiv_tx = clk_freq/ask_rate;
   wire [1:0] ask_tx;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(ASK_TX_SIZE),
      .clkdiv_tx(ASK_clkdiv_tx)
   ) simple_axis_ask_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(mcu_rx_tdata), .i_tvalid(mcu_rx_tvalid), .i_tready(mcu_rx_tready),
      // ASK output port
      .ask_tx(ask_tx)
   );
   // ASK output preparation
   assign MULP = ( ask_tx==2'b01 ? 1'b1 : 1'b0 );
   assign MULN = ( ask_tx==2'b11 ? 1'b1 : 1'b0 );
   ////////////////////////////////
   //
   // Debug
   //
   ////////////////////////////////
   assign LED = ~ask_manual_rx;
   //assign LED = ~ask_automatic_rx;
   assign UART_TX = MDM_RxD;
   assign MDM_TxD = UART_RX & (MDM_Tx | MDM_CS);

endmodule // MDM
