`timescale 1 ns/100 ps
// Version: v11.8 SP3 11.8.3.6


module RAMCoreTP_4B_1024(
       WD,
       RD,
       WEN,
       REN,
       WADDR,
       RADDR,
       RWCLK,
       RESET
    );
input  [31:0] WD;
output [31:0] RD;
input  WEN;
input  REN;
input  [9:0] WADDR;
input  [9:0] RADDR;
input  RWCLK;
input  RESET;

    wire WEAP, WEBP, RESETP, VCC, GND;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    
    RAM4K9 RAMCoreTP_4B_1024_R0C1 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[7]), .DINA2(WD[6]), .DINA1(WD[5]), 
        .DINA0(WD[4]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[7]), .DOUTB2(RD[6]), .DOUTB1(RD[5]), 
        .DOUTB0(RD[4]));
    RAM4K9 RAMCoreTP_4B_1024_R0C6 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[27]), .DINA2(WD[26]), .DINA1(WD[25]), 
        .DINA0(WD[24]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[27]), .DOUTB2(RD[26]), .DOUTB1(RD[25]), 
        .DOUTB0(RD[24]));
    RAM4K9 RAMCoreTP_4B_1024_R0C3 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[15]), .DINA2(WD[14]), .DINA1(WD[13]), 
        .DINA0(WD[12]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[15]), .DOUTB2(RD[14]), .DOUTB1(RD[13]), 
        .DOUTB0(RD[12]));
    INV RESETBUBBLE (.A(RESET), .Y(RESETP));
    RAM4K9 RAMCoreTP_4B_1024_R0C5 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[23]), .DINA2(WD[22]), .DINA1(WD[21]), 
        .DINA0(WD[20]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[23]), .DOUTB2(RD[22]), .DOUTB1(RD[21]), 
        .DOUTB0(RD[20]));
    RAM4K9 RAMCoreTP_4B_1024_R0C0 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[3]), .DINA2(WD[2]), .DINA1(WD[1]), 
        .DINA0(WD[0]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[3]), .DOUTB2(RD[2]), .DOUTB1(RD[1]), 
        .DOUTB0(RD[0]));
    RAM4K9 RAMCoreTP_4B_1024_R0C2 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[11]), .DINA2(WD[10]), .DINA1(WD[9]), 
        .DINA0(WD[8]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[11]), .DOUTB2(RD[10]), .DOUTB1(RD[9]), 
        .DOUTB0(RD[8]));
    INV WEBUBBLEB (.A(REN), .Y(WEBP));
    RAM4K9 RAMCoreTP_4B_1024_R0C4 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[19]), .DINA2(WD[18]), .DINA1(WD[17]), 
        .DINA0(WD[16]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[19]), .DOUTB2(RD[18]), .DOUTB1(RD[17]), 
        .DOUTB0(RD[16]));
    INV WEBUBBLEA (.A(WEN), .Y(WEAP));
    RAM4K9 RAMCoreTP_4B_1024_R0C7 (.ADDRA11(GND), .ADDRA10(GND), 
        .ADDRA9(WADDR[9]), .ADDRA8(WADDR[8]), .ADDRA7(WADDR[7]), 
        .ADDRA6(WADDR[6]), .ADDRA5(WADDR[5]), .ADDRA4(WADDR[4]), 
        .ADDRA3(WADDR[3]), .ADDRA2(WADDR[2]), .ADDRA1(WADDR[1]), 
        .ADDRA0(WADDR[0]), .ADDRB11(GND), .ADDRB10(GND), .ADDRB9(
        RADDR[9]), .ADDRB8(RADDR[8]), .ADDRB7(RADDR[7]), .ADDRB6(
        RADDR[6]), .ADDRB5(RADDR[5]), .ADDRB4(RADDR[4]), .ADDRB3(
        RADDR[3]), .ADDRB2(RADDR[2]), .ADDRB1(RADDR[1]), .ADDRB0(
        RADDR[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(WD[31]), .DINA2(WD[30]), .DINA1(WD[29]), 
        .DINA0(WD[28]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(
        GND), .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(GND), 
        .DINB0(GND), .WIDTHA0(GND), .WIDTHA1(VCC), .WIDTHB0(GND), 
        .WIDTHB1(VCC), .PIPEA(GND), .PIPEB(VCC), .WMODEA(GND), .WMODEB(
        GND), .BLKA(WEAP), .BLKB(WEBP), .WENA(GND), .WENB(VCC), .CLKA(
        RWCLK), .CLKB(RWCLK), .RESET(RESETP), .DOUTA8(), .DOUTA7(), 
        .DOUTA6(), .DOUTA5(), .DOUTA4(), .DOUTA3(), .DOUTA2(), .DOUTA1(
        ), .DOUTA0(), .DOUTB8(), .DOUTB7(), .DOUTB6(), .DOUTB5(), 
        .DOUTB4(), .DOUTB3(RD[31]), .DOUTB2(RD[30]), .DOUTB1(RD[29]), 
        .DOUTB0(RD[28]));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule

// _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


// _GEN_File_Contents_

// Version:11.8.3.6
// ACTGENU_CALL:1
// BATCH:T
// FAM:PA3LC
// OUTFORMAT:Verilog
// LPMTYPE:LPM_RAM
// LPM_HINT:TWO
// INSERT_PAD:NO
// INSERT_IOREG:NO
// GEN_BHV_VHDL_VAL:F
// GEN_BHV_VERILOG_VAL:F
// MGNTIMER:F
// MGNCMPL:T
// DESDIR:D:/NHI/fpga/top/MDM/Build_MDM/smartgen\RAMCoreTP_4B_1024
// GEN_BEHV_MODULE:F
// SMARTGEN_DIE:IS4X2M1
// SMARTGEN_PACKAGE:vq100
// AGENIII_IS_SUBPROJECT_LIBERO:T
// WWIDTH:32
// WDEPTH:1024
// RWIDTH:32
// RDEPTH:1024
// CLKS:1
// CLOCK_PN:RWCLK
// RESET_PN:RESET
// RESET_POLARITY:1
// INIT_RAM:F
// DEFAULT_WORD:0x00000000
// CASCADE:0
// WCLK_EDGE:RISE
// PMODE2:1
// DATA_IN_PN:WD
// WADDRESS_PN:WADDR
// WE_PN:WEN
// DATA_OUT_PN:RD
// RADDRESS_PN:RADDR
// RE_PN:REN
// WE_POLARITY:1
// RE_POLARITY:1
// PTYPE:1

// _End_Comments_
