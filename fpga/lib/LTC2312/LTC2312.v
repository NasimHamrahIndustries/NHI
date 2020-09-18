//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module LTC2312 #(
   parameter WIDTH = 14,           // 12 or 14
   parameter clk_freq = 20000000,  // max=20000000
   parameter sample_rate = 500000  // max=500000
)(
   input clk, input rst, input clear,
   input enable,
   // Output Stream ports
   output reg [WIDTH-1:0] o_tdata,
   output reg o_tvalid = 1'b0,
   // SPI ports
   output CONV , output SCK, input SDO
);
/* LTC2312 <--> FPGA Interface Waveform:
      __    __    _     __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    _     __    _
clk     |__^  |__^ ~~~_^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^  |__^ ~~~_^  |__^ 
      __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ _
count _hHH_X_hHH_X_~~~_X_hHH_X_h0F_X_h0E_X_h0D_X_h0C_X_h0B_X_h0A_X_h09_X_h08_X_h07_X_h06_X_h05_X_h04_X_h03_X_h02_X_h01_X_h00_X_~~~_X_hHH_X_
         ________________________                                                                                        ______   _________
CONV  __/   tCONV MIN=1300 ns    \___________________________________tACQ MIN=700 ns____________________________________/      ~~~         
                                    __    __    __    __    __    __    __    __    __    __    __    __    __    __                       
SCK   _____________________________^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__^  !__________~~~_________
      __                           __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __                     
SDO   __X--------HI-Z STATE------X_B13_X_B12_X_B11_X_B10_X_B09_X_B08_X_B07_X_B06_X_B05_X_B04_X_B03_X_B02_X_B01_X_B00_\_1'b0_---~~~---------

*/
   reg CONV_reg = 1'b1;
   localparam max_count = clk_freq/sample_rate;
   reg [$clog2(max_count)-1:0] count = (max_count-1);
   always @(posedge clk)
      if(rst)
         count <= $unsigned(max_count-1);
      else if(count==0)
         count <= $unsigned(max_count-1);
      else
         count <= count-1;
   always @(negedge clk)
      if( $unsigned(WIDTH+2) > count & count > $unsigned(0) )
         CONV_reg <= 1'b0;
      else
         CONV_reg <= 1'b1;
   assign CONV = (count==0 ? 1'b1 : CONV_reg);
   assign SCK = ($unsigned(WIDTH+1) > count & count > $unsigned(0) ? clk : 1'b0);

   reg [WIDTH-1:0] data;
   integer i = 0;
   always @(posedge clk) begin
      if(rst | clear)
         data <= 0;
      else if($unsigned(WIDTH+2) > count & count > $unsigned(1) ) begin
         data[0] <= SDO;
         for(i=0;i<WIDTH-1;i=i+1)
            data[i+1] <= data[i];
      end
   end
   always @(posedge clk) begin
      if(rst | clear)
         o_tdata <= 0;
      else if(enable==1'b1 & count==$unsigned(1) )
         o_tdata <= data;
      if(rst | clear)
         o_tvalid <= 1'b0;
      else if(enable==1'b1 & count==$unsigned(1) )
         o_tvalid <= 1'b1;
      else
         o_tvalid <= 1'b0;
   end

endmodule // LTC2312
