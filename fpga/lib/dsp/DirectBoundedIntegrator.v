//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

// This block implement : y[n] = x[n]+x[n-1]+x[n-2]+x[n-3]+...+x[n-m]

module DirectBoundedIntegrator #(
   parameter WIDTH = 16,
   parameter SIZE = 17,
   parameter MaxWIDTH = WIDTH+$clog2(SIZE+1)
)(
   input clk, input reset, input clear,
   input [WIDTH-1:0] i_tdata,
   input i_tvalid,
   output i_tready,
   output [WIDTH+$clog2(SIZE+1)-1:0] o_tdata,
   output o_tvalid,
   input o_tready
);

   wire [MaxWIDTH-1:0] idata;
   reg [SIZE*MaxWIDTH-1:0] queue = 0;

   genvar i;
   assign idata[WIDTH-1:0] = i_tdata;
   generate
      for(i=WIDTH;i<MaxWIDTH;i=i+1) begin
         assign idata[i] = i_tdata[WIDTH-1];
      end
   endgenerate

   always @(posedge clk)
      if(reset | clear)
         queue[MaxWIDTH-1:0] <= 0;
      else if(i_tvalid & o_tready)
         queue[MaxWIDTH-1:0] <= idata;

   generate
      for(i=0;i<SIZE-1;i=i+1) begin
         always @(posedge clk)
            if(reset | clear)
               queue[(i+2)*MaxWIDTH-1:(i+1)*MaxWIDTH] <= 0;
            else if(i_tvalid & o_tready)
               queue[(i+2)*MaxWIDTH-1:(i+1)*MaxWIDTH] <= queue[(i+1)*MaxWIDTH-1:i*MaxWIDTH];
      end
   endgenerate

   PyramidSum #(
      .WIDTH(MaxWIDTH), .SIZE(SIZE)
   ) PyramidSum (
      .clk(clk), .reset(reset), .clear(clear),
      .i_tdata(queue), .i_tvalid(i_tvalid), .i_tready(i_tready),
      .o_tdata(o_tdata), .o_tvalid(o_tvalid), .o_tready(o_tready)
   );

endmodule // DirectBoundedIntegrator
