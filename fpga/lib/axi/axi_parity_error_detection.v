//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module axi_parity_error_detection (
   input clk, input rst, input parity_type,
   input [8:0] i_tdata, input i_tvalid, output i_tready,
   output [8:0] o_tdata, output o_tvalid, input o_tready
);

   wire [3:0] bitsum   = i_tdata[7] + i_tdata[6] + i_tdata[5] + i_tdata[4] + i_tdata[3] + i_tdata[2] + i_tdata[1] + i_tdata[0];
   assign o_tdata[7:0] = i_tdata[7:0];
   //assign o_tdata[8]   = F(parity_type, i_tdata[8], bitsum[0]);
   assign o_tvalid     = i_tvalid;
   assign i_tready     = o_tready;

endmodule // axi_parity_error_detection
