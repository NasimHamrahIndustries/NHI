//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module manual_threshold_ask_detector #(
   parameter WIDTH = 16
)(
   input clk, input reset, input clear, input enable,
   input [WIDTH-1:0] i_tdata, input i_tvalid, output i_tready,
   input [WIDTH-1:0] upthreshold, input [WIDTH-1:0] downthreshold,
   output rx
);

   reg state = 1'b0;               //                         |                  ___                            
   // state == 1'b0 : Low state    //    upthreshold  ,--->---|                 /   |  __     ___               
   // state == 1'b1 : High state   //                 |       |                /    ',/  |  _/   \_             
   always @(posedge clk)           //                 |       |              /`           \/       \       /\   
      if(reset | clear)            //  downthreshold  |---<---'   __/\/^'~'\/                       \_|^\_/  \__
         state <= 1'b0;            //                 |                           __________________            
      else if(i_tvalid & enable)   //                 0       1   _______________|                  |___________
         case (state)
            1'b0    : if( $signed(i_tdata) > $signed(upthreshold)   ) state <= 1'b1;
            1'b1    : if( $signed(i_tdata) < $signed(downthreshold) ) state <= 1'b0;
            default :                                                 state <= 1'b0;
         endcase

   assign i_tready = enable;
   assign rx = !state;

endmodule // manual_threshold_ask_detector
