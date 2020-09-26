#!/usr/bin/env python3
"""
Copyright 2020 Nasim Hamrah Industries

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import os
import sys
import serial
import numpy
import matplotlib.pyplot as plt

portName = '/dev/ttyUSB0'
baudrateValue = 125000
Vmax=2.048
MDM_Development_Bench_Arch="""
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Commands:                                                                  //        _________                 _                                        //
// reset : Reset registers to default values and states                      //       |         |  ask counter  | \      _______                          //
// set_offset VALUE : e.g. set_offset 0.64                                   //       | Counter |===============|  \    |       |                         //
// cal_offset : Calculate offset value in Auto Offset Cutter block           //       |_________|               |   |   |       |--> MULP    _   _        //
// offset manu/auto : Set mux stream direction                               //      set_ask VALUE              |   |   |  ASK  |           | | | |       //
// set_threshold VALUE : e.g. set_threshold 1.25                             //         {0:0>8b} ===============|   |===|       |        ---' | | | ,---  //
// capture manu/auto/filtered/cutted_offset/adc : Set mux stream direction   //                      ask value  |   |   | 5kb/s |             |_| |_|     //
// capture fire : Capture 2048 samples from selected stream                  //                                 |   |   |       |--> MULN     10kHz       //
// ask counter/value/off : Set mux stream direction                          //                       ask off --|  /    |_______|                         //
// set_ask VALUE : e.g. set_ask 113  (It means  d113=b01110001)              //                                 |_/                                       //
// exit                                                                      //                              {ask_mux:^10}                                   //
///////////////////////////////////////////////////////////////////////////////                                                                           //
//                                                                            set_threshold VALUE                                                         //
//                                                                                   {1:.2f}                                                                 //
//                                                                               _____||_____                  __                                         //
//                   ___                                                        |            |                |  \                                        //
// set_offset VALUE |   |                                                       |  Detector  |  capture manu  |   \                                       //
//          {2:.2f} ===|   |==0                                                 O==|   Manual   |================|    \                                      //
//                 -|>  |  |                                                 |  | Threshold  |                |     \                                     //
//                  |___|  |                        _                        |  |____________|                |      |                 ______             //
//          _____          |          offset manu  | \                       |   ____________                 |      |  capture fire  |      |            //
//         |     |     O==(-)======================|  \       ____________   |  |            |                |      |    ________    | UART |            //
//  SDO -->|     |     |   ________                |   |     |            |  |  |  Detector  |                |      |   | FIFO __|===| 125  |--> UART_TX //
//         | ADC |==O==O  |        |               |   |==O==|   Filter   |==O==|    Auto    |================|      |   | 16  /      | kb/s |            //
//  SCK <--|     |  |  |  |  Auto  |  offset auto  |   |  |  | Integrator |  |  | Threshold  |  capture auto  |      |===| to /       |______|            //
//         |     |  |  O==| Offset |===============|  /   |  |____________|  |  |____________|                |      |   | 8 /                            //
// CONV <--|     |  |     | Cutter |               |_/    |                  |                                |      |   |__/                             //
//         |_____|  |     |________|              {offset_mux:^4}    |                  O================================|      |  2048 sample                       //
//                  |         |                           |                                 capture filtered  |      |                                    //
//                  |     cal_offset                      O===================================================|      |                                    //
//                  |                                                                  capture cutted_offset  |     /                                     //
//                  O=========================================================================================|    /                                      //
//                                                                                               capture adc  |   /                                       //
//                                                                                                            |__/                                        //
//                                                                                                    {capture_mux:^20}                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
"""
'''
//Instructions:
// command_type  argument       Byte0 Byte1 Byte2
// reset                        h00   h00   h00
// set_offset    fx.xx          h01   hXX   hXX
// cal_offset                   h02   h00   h00
// offset        manu           h03   h00   h00
//               auto           h03   h01   h00
// set_threshold fx.xx          h04   hXX   hXX
// capture       adc            h05   h00   h00
//               cutted_offset  h05   h01   h00
//               filtered       h05   h02   h00
//               auto           h05   h03   h00
//               manu           h05   h04   h00
//               fire           h05   h05   h00
// ask           off            h06   h00   h00
//               value          h06   h01   h00
//               counter        h06   h02   h00
// set_ask       dxxx           h07   hXX   h00
'''

def main():
    print("In the Name of ALLAH")
    ask_value=0
    ask_mux='off'
    offset_value=0.0
    threshold_value=0.0
    offset_mux='manu'
    capture_mux='adc'
    reset(' ')
    while 'true':
        print("MDM Development Bench:")
        print(MDM_Development_Bench_Arch.format(ask_value, threshold_value, offset_value, ask_mux=ask_mux, offset_mux=offset_mux, capture_mux=capture_mux))
        command = input("Please enter your command:\n")
        separated_command=command.partition(' ')
        command_type=separated_command[0]
        argument=separated_command[2]
        del separated_command
        if(command_type=="reset"):
            clear()
            reset(argument)
        elif(command_type=="set_offset"):
            clear()
            val=set_offset(argument)
            if(val!='false'):
                offset_value=val
        elif(command_type=="cal_offset"):
            clear()
            cal_offset(argument)
        elif(command_type=="offset"):
            clear()
            val=offset(argument)
            if(val!='false'):
                offset_mux=val
        elif(command_type=="set_threshold"):
            clear()
            val=set_threshold(argument)
            if(val!='false'):
                threshold_value=val
        elif(command_type=="capture"):
            clear()
            val=capture(argument)
            if(val!='false' and val!='fire'):
                capture_mux=val
        elif(command_type=="ask"):
            clear()
            val=ask(argument)
            if(val!='false'):
                ask_mux=val
        elif(command_type=="set_ask"):
            clear()
            val=set_ask(argument)
            if(val!='false'):
                ask_value=val
        elif(command_type=="exit"):
            clear()
            break
        else:
            clear()
            print(command_type, argument)
            print("Irregular command!")

# define clear function 
def clear():
    os.system('clear')

def reset(argument):
    print("reset", argument)

def set_offset(argument):
    print("set_offset", argument)
    if(0.0<=float(argument) and float(argument)<=Vmax):
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def cal_offset(argument):
    print("cal_offset", argument)
    print("Done successfully!")

def offset(argument):
    print("offset", argument)
    if(argument=="manu"):
        print("Done successfully!")
        return argument
    elif(argument=="auto"):
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu or auto !")
        print("Irregular command!")
        return 'false'

def set_threshold(argument):
    print("set_threshold", argument)
    if(0.0<=float(argument) and float(argument)<=Vmax):
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def capture(argument):
    print("capture", argument)
    if(argument=="adc"):
        print("Done successfully!")
        return argument
    elif(argument=="cutted_offset"):
        print("Done successfully!")
        return argument
    elif(argument=="filtered"):
        print("Done successfully!")
        return argument
    elif(argument=="auto"):
        print("Done successfully!")
        return argument
    elif(argument=="manu"):
        print("Done successfully!")
        return argument
    elif(argument=="fire"):
        print("Done successfully!")
        return 'fire'
    else:
        print("Command argument should be : manu, auto, filtered, cutted_offset, adc or fire !")
        print("Irregular command!")
        return 'false'

def ask(argument):
    print("ask", argument)
    if(argument=="counter"):
        print("Done successfully!")
        return argument
    elif(argument=="value"):
        print("Done successfully!")
        return argument
    elif(argument=="off"):
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : counter, value or off !")
        print("Irregular command!")
        return 'false'

def set_ask(argument):
    print("set_ask", argument)
    if(0<=int(argument) and int(argument)<=255):
        print("Done successfully!")
        return int(argument)
    else:
        print("Command argument should be a integer number in range: 0 <= argument and argument <= 255 !")
        print("Irregular command!")
        return 'false'

if __name__ == '__main__':
    main()
