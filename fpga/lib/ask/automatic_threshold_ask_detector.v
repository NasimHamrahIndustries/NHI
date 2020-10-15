//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module automatic_threshold_ask_detector #(
   parameter WIDTH = 16,
   parameter DEPTH = 5,
   parameter MINTHRESHOLD = 80
)(
   input clk, input reset, input clear, input enable,
   input [WIDTH-1:0] i_tdata, input i_tvalid, output i_tready,
   output rx
);

   reg [DEPTH-1:0] counter = 0;
   reg [WIDTH-1:0] maximum = 0;
   reg [WIDTH-1:0] upthreshold = 0;
   reg [WIDTH-1:0] downthreshold = 0;
   reg [WIDTH-1:0] delaied [2**DEPTH-1:0];

   always @(posedge clk)
      if(reset | clear) begin
         delaied[0] <= 0;
         counter <= 0;
         maximum <= 0;
         upthreshold <= 0;
         downthreshold <= 0;
      end else if(i_tvalid & enable) begin
         counter <= counter + 1;
         delaied[0] <= i_tdata;
         if( $signed(counter) == -1 ) begin
            maximum <= 0;
            upthreshold   <= (upthreshold > MINTHRESHOLD ? 2*($signed(maximum)/3) : MINTHRESHOLD);
            downthreshold <= (upthreshold > MINTHRESHOLD ? $signed(maximum)/3     : MINTHRESHOLD);
         end else if( $signed(maximum) < $signed(i_tdata) )
            maximum <= i_tdata;
      end

   genvar i;
   generate
      for(i=1;i<2**DEPTH;i=i+1)
         always @(posedge clk)
            if(reset | clear)
               delaied[i] <= 0;
            else if(i_tvalid & enable)
               delaied[i] <= delaied[i-1];
   endgenerate

   reg state = 1'b0;               //                         |                  ___                            
   // state == 1'b0 : Low state    //    upthreshold  ,--->---|                 /   |  __     ___               
   // state == 1'b1 : High state   //                 |       |                /    ',/  |  _/   \_             
   always @(posedge clk)           //                 |       |              /`           \/       \       /\   
      if(reset | clear)            //  downthreshold  |---<---'   ~ /\/^'~'\/                       \ /^\ /  \_~
         state <= 1'b0;            //                 |            ^              __________________ '   ^      
      else if(i_tvalid & enable)   //                 0       1   _______________|                  |___________
         case (state)
            1'b0    : if( $signed(delaied[2**DEPTH-1]) > $signed(upthreshold)   ) state <= 1'b1;
            1'b1    : if( $signed(delaied[2**DEPTH-1]) < $signed(downthreshold) ) state <= 1'b0;
            default :                                                             state <= 1'b0;
         endcase

   assign i_tready = enable;
   assign rx = !state;

endmodule // automatic_threshold_ask_detector
