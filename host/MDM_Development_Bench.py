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
MDM_Development_Bench_Arch="""
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Commands:                                                                  //        _________                 _                                        //
// reset : Reset registers to default values and states                      //       |         |  ask counter  | \      _______                          //
// set_offset VALUE : e.g. set_offset 0.64                                   //       | Counter |===============|  \    |       |                         //
// set_offset cal : Calculate offset value in Auto Offset Cutter block       //       |_________|               |   |   |       |--> MULP    _   _        //
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
//                  |   set_offset cal                    O===================================================|      |                                    //
//                  |                                                                  capture cutted_offset  |     /                                     //
//                  O=========================================================================================|    /                                      //
//                                                                                               capture adc  |   /                                       //
//                                                                                                            |__/                                        //
//                                                                                                    {captura_mux:^20}                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
"""

def main():
    print("In the Name of ALLAH")
    ask_value=0
    ask_mux='off'
    offset_value=0.0
    threshold_value=0.0
    offset_mux='manu'
    captura_mux='adc'
    reset()
    while 'true':
        print("MDM Development Bench:")
        print(MDM_Development_Bench_Arch.format(ask_value, offset_value, threshold_value, ask_mux=ask_mux, offset_mux=offset_mux, captura_mux=captura_mux))
        command = input("Please inter your command:\n")
        separated_command=command.partition(' ')
        command_type=separated_command[0]
        command=separated_command[2]
        del separated_command
        if(command_type=="reset"):
            clear()
            reset()
        elif(command_type=="set_offset"):
            clear()
            set_offset()
        elif(command_type=="offset"):
            clear()
            offset()
        elif(command_type=="set_threshold"):
            clear()
            set_threshold()
        elif(command_type=="capture"):
            clear()
            capture()
        elif(command_type=="ask"):
            clear()
            ask()
        elif(command_type=="set_ask"):
            clear()
            set_ask()
        elif(command_type=="exit"):
            clear()
            break
        else:
            clear()
            print("Irregular command!")

# define clear function 
def clear():
    os.system('clear')

def reset():
    print("reset!")

def set_offset():
    print("set_offset!")

def offset():
    print("offset!")

def set_threshold():
    print("set_threshold!")

def capture():
    print("capture!")

def ask():
    print("ask!")

def set_ask():
    print("set_ask!")

if __name__ == '__main__':
    main()
