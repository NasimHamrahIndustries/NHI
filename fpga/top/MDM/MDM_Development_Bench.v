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
   output MULP, output MULN,
   // LTC2312 Analog to Digital Converter
   input AFE_SDO, output AFE_SCK, output AFE_CONV,
   // LED Pin
   output LED
);

   assign LED = ~UART_TX;

   wire rst;
   reg cmd_rst = 1'b0;
   por_gen por_gen (
      .clk(CLOCK),
      .reset_out(rst)
   );

   ////////////////////////////////
   //
   // UART Command Receiver
   //
   ////////////////////////////////
   // UART RX
   localparam UART_RX_SIZE = 1;
   localparam UART_clkdiv_rx= clk_freq/uart_rate;
   wire [7:0] rx_tdata;
   wire rx_tvalid;
   wire rx_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(UART_RX_SIZE),
      .clkdiv_rx(UART_clkdiv_rx)
   ) axis_uart_rx_wrapper (      //                                  |             |             |             |             |
      .clk(CLOCK), .rst(rst),    //             ______  data         |   ______    |   ______    |   ______    |   ______    |
      // AXI Stream ports        //            |      |==>===========O==|      |=>=O==|      |=>=O==|      |=>=O==|      |=>=O
      .o_tdata(rx_tdata),        //            | UART | valid           | reg3 |      | reg2 |      | reg1 |      | reg0 |    
      .o_tvalid(rx_tvalid),      // UART_RX -->| 125  |-->-----------O--|      |   O--|      |   O--|      |   O--|      |    
      .o_tready(rx_tready),      //            | kb/s | ready        |  |______|   |  |______|   |  |______|   |  |______|    
      // Input RX port           //            |______|--<-- 1'b1    O->-----------O->-----------O->-----------O              
      .rx(UART_RX)               //                                                                                           
   );
   // Receiver registers
   reg [7:0] reg3 = 8'b0;
   reg [7:0] reg2 = 8'b0;
   reg [7:0] reg1 = 8'b0;
   reg [7:0] reg0 = 8'b0;
   always @(posedge CLOCK)
      if(rst) begin
         reg3 <= 8'b0;
         reg2 <= 8'b0;
         reg1 <= 8'b0;
         reg0 <= 8'b0;
      end else if(rx_tvalid) begin
         reg3 <= rx_tdata;
         reg2 <= reg3;
         reg1 <= reg2;
         reg0 <= reg1;
      end
   assign rx_tready = 1'b1;

   ////////////////////////////////
   //
   // Command Management
   //
   ////////////////////////////////
   reg [1:0] command_state = 2'b00;
   // command_state == 2'b00 : Waiting for command from host PC side and registering command and arguments
   // command_state == 2'b01 : Doing command step1
   // command_state == 2'b10 : Doing command step2
   // command_state == 2'b11 : Illegal state
   reg [7:0] arg1 = 8'b0;
   reg [7:0] arg0 = 8'b0;
   reg [7:0] cmd  = 8'b0;
   reg [15:0] offset_value     = 16'd0;
   reg        cal_offset       = 1'b0;
   reg [7:0]  offset_mux       = 8'd0;
   reg [15:0] threshold_value  = 16'd0;
   reg [7:0]  capture_mux      = 8'd0;
   reg        capture_fire     = 1'b0;
   reg [7:0]  ask_value        = 8'd0;
   reg [7:0]  ask_mux          = 8'd0;
   always @(posedge CLOCK)
      if(rst) begin
            command_state   <= 2'b00;
            cmd_rst         <= 1'b0;
            offset_value    <= 16'd0;
            cal_offset      <= 1'b0;
            offset_mux      <= 8'd0;
            threshold_value <= 16'd0;
            capture_mux     <= 8'd0;
            capture_fire    <= 1'b0;
            ask_value       <= 8'd0;
            ask_mux         <= 8'd0;
         end
      else
         case (command_state)
            2'b00 : begin
                  if(rx_tvalid & rx_tdata==$unsigned(111) & reg0==$unsigned(110)) begin
                     arg1 <= reg3;
                     arg0 <= reg2;
                     cmd  <= reg1;
                     command_state <= 2'b01;
                  end
               end
            2'b01 : begin
                  case (cmd)
                     8'h00 : cmd_rst         <= 1'b1;
                     8'h01 : offset_value    <= {arg0, arg1};
                     8'h02 : cal_offset      <= 1'b1;
                     8'h03 : offset_mux      <= arg0;
                     8'h04 : threshold_value <= {arg0, arg1};
                     8'h05 : capture_mux     <= arg0;
                     8'h06 : capture_fire    <= 1'b1;
                     8'h07 : ask_value       <= arg0;
                     8'h08 : ask_mux         <= arg0;
                  endcase
                  command_state <= 2'b10;
               end
            2'b10 : begin
                  case (cmd)
                     8'h00 : cmd_rst      <= 1'b0;
                     8'h02 : cal_offset   <= 1'b0;
                     8'h06 : capture_fire <= 1'b0;
                  endcase
                  command_state <= 2'b00;
               end
            default : command_state <= 2'b00;
         endcase

   ////////////////////////////////
   //
   // ADC Block
   //
   ////////////////////////////////
   // LTC2312 ADC chip
   wire [13:0] LTC2312_tdata;
   wire LTC2312_tvalid;
   LTC2312 #(
      .WIDTH(14),
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

   ////////////////////////////////
   //
   // DSP Blocks
   //
   ////////////////////////////////


   ////////////////////////////////
   //
   // Fire Management
   //
   ////////////////////////////////
   reg [1:0] fire_state = 2'b00;
   // fire_state == 2'b00 : Waiting for command from host PC side
   // fire_state == 2'b01 : Capturing a fram of samples
   // fire_state == 2'b10 : Transmitting samples to PC
   // fire_state == 2'b11 : Illegal state
   // FIFO 16 bit to 8 bit, 2048 sample
   reg [15:0] FIFO_DATA;
   wire [7:0] FIFO_Q;
   reg FIFO_WE = 1'b0;
   wire FIFO_RE;
   wire FIFO_FULL;
   wire FIFO_EMPTY;
   FIFOCore_2Bto1B_2048 FIFOCore_2Bto1B_2048 (
      .DATA(FIFO_DATA),
      .Q(FIFO_Q),
      .WE(FIFO_WE),
      .RE(FIFO_RE),
      .CLK(CLOCK),
      .FULL(FIFO_FULL),
      .EMPTY(FIFO_EMPTY),
      .RESET(rst)
   );
   // Capture MUX control
   always @(*)
      if(fire_state==2'b01)
         case (capture_mux)
            8'h00     : begin // adc
                  FIFO_DATA <= {2'b00, LTC2312_tdata};
                  FIFO_WE   <= LTC2312_tvalid;
               end
            /*8'h01     : begin // cutted_offset
                  FIFO_DATA <= ;
                  FIFO_WE   <= ;
               end
            8'h02     : begin // filtered
                  FIFO_DATA <= ;
                  FIFO_WE   <= ;
               end
            8'h03     : begin // auto
                  FIFO_DATA <= ;
                  FIFO_WE   <= ;
               end
            8'h04     : begin // manu
                  FIFO_DATA <= ;
                  FIFO_WE   <= ;
               end*/
            default : begin // Illegal
                  FIFO_DATA <= 16'd0;
                  FIFO_WE   <= 1'b1;
               end
         endcase
      else begin
         FIFO_DATA <= 16'd0;
         FIFO_WE   <= 1'b0;
      end
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
   assign tx_tdata = FIFO_Q;
   assign tx_tvalid = ( fire_state==2'b10 ? tx_tready : 1'b0 );
   assign FIFO_RE   = ( fire_state==2'b10 ? tx_tready : 1'b0 );
   // Fire control Unit
   always @(posedge CLOCK)
      if(rst)
         fire_state <= 2'b00;
      else
         case (fire_state)
            2'b00   : if(capture_fire) fire_state <= 2'b01;
            2'b01   : if(FIFO_FULL)    fire_state <= 2'b10;
            2'b10   : if(FIFO_EMPTY)   fire_state <= 2'b00;
            default :                  fire_state <= 2'b00;
         endcase

   ////////////////////////////////
   //
   // ASK Transmitter
   //
   ////////////////////////////////
   // ASK TX
   localparam ASK_TX_SIZE = 1;
   localparam ASK_clkdiv_tx = clk_freq/ask_rate;
   wire [7:0] ask_tx_tdata;
   wire ask_tx_tvalid;
   wire ask_tx_tready;
   wire [1:0] ask_tx;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(ASK_TX_SIZE),
      .clkdiv_tx(ASK_clkdiv_tx)
   ) simple_axis_ask_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(ask_tx_tdata),
      .i_tvalid(ask_tx_tvalid),
      .i_tready(ask_tx_tready),
      // ASK output port
      .ask_tx(ask_tx)
   );
   // ASK counter
   reg [7:0] ask_counter = 8'd0;
   always @(posedge CLOCK)
      if(rst)
         ask_counter <= 8'd0;
      else if(ask_tx_tready & ask_mux==8'h02)
         ask_counter <= ask_counter + 8'd1;
   // ASK command control
   assign ask_tx_tdata = ( ask_mux==8'h02 ? ask_counter : ask_value );
   assign ask_tx_tvalid = ( ask_mux==8'h00 ? 1'b0 : 1'b1 );
   // ASK output preparation
   assign MULP = ( ask_tx==2'b01 ? 1'b1 : 1'b0 );
   assign MULN = ( ask_tx==2'b11 ? 1'b1 : 1'b0 );

endmodule // MDM_Development_Bench
