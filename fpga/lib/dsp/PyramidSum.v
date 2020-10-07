//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module PyramidSum #(
   parameter WIDTH = 16,
   parameter SIZE = 3
)(
   input clk, input reset, input clear,
   input [SIZE*WIDTH-1:0] i_tdata,
   input i_tvalid,
   output i_tready,
   output [WIDTH-1:0] o_tdata,
   output o_tvalid,
   input o_tready
);

   localparam NSIZE = ( (2*(SIZE/2))==SIZE ? SIZE/2 : 1 + SIZE/2 );
   genvar i;
   generate
      if(SIZE>2) begin
         reg [NSIZE*WIDTH-1:0] mediumbus = 0;
         for(i=0;i<SIZE/2;i=i+1) begin
            always @(posedge clk)
               if(reset | clear)
                  mediumbus[(i+1)*WIDTH-1:i*WIDTH] <= 0;
               else if(i_tvalid & o_tready)
                  mediumbus[(i+1)*WIDTH-1:i*WIDTH] <= i_tdata[2*(i+1)*WIDTH-1:(2*i+1)*WIDTH] + i_tdata[(2*i+1)*WIDTH-1:2*i*WIDTH];
            if(i==(SIZE/2)-1 & (2*(SIZE/2))!=SIZE) begin
               always @(posedge clk)
                  if(reset | clear)
                     mediumbus[(i+2)*WIDTH-1:(i+1)*WIDTH] <= 0;
                  else if(i_tvalid & o_tready)
                     mediumbus[(i+2)*WIDTH-1:(i+1)*WIDTH] <= i_tdata[(2*i+3)*WIDTH-1:2*(i+1)*WIDTH];
            end
         end
         PyramidSum #(
            .WIDTH(WIDTH), .SIZE(NSIZE)
         ) PyramidSum (
            .clk(clk), .reset(reset), .clear(clear),
            .i_tdata(mediumbus), .i_tvalid(i_tvalid), .i_tready(i_tready),
            .o_tdata(o_tdata), .o_tvalid(o_tvalid), .o_tready(o_tready)
         );
      end else begin
         reg [WIDTH-1:0] sum = 0;
         always @(posedge clk)
            if(reset | clear)
               sum <= 0;
            else if(i_tvalid & o_tready)
               sum <= i_tdata[SIZE*WIDTH-1:WIDTH] + i_tdata[WIDTH-1:0];
         assign o_tdata = sum;
         assign o_tvalid = i_tvalid;
         assign i_tready = o_tready;
      end
   endgenerate

endmodule // PyramidSum
