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
SampleRate = 200000  # sample per second
SampleNumber=2048
TimeStep=1/SampleRate
ADCPrecision=Vmax/(2**14)
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
// set_ask VALUE : e.g. set_ask 113  (It means  d113=b01110001)              //                       ask off --|  /    |_______|                         //
// ask counter/value/off : Set mux stream direction                          //                                 |_/                                       //
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
// command_type  argument       cmd   arg0  arg1
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
// capture       fire           h06   h00   h00
// set_ask       dxxx           h07   hXX   h00
// ask           off            h08   h00   h00
//               value          h08   h01   h00
//               counter        h08   h02   h00
'''

def main():
    print("In the Name of ALLAH")
    offset_value=0.0
    offset_mux='manu'
    threshold_value=0.0
    capture_mux='adc'
    ask_value=0
    ask_mux='off'
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
        elif(command_type=="set_ask"):
            clear()
            val=set_ask(argument)
            if(val!='false'):
                ask_value=val
        elif(command_type=="ask"):
            clear()
            val=ask(argument)
            if(val!='false'):
                ask_mux=val
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
    serial_commander(portName, baudrateValue, int(0), int(0), int(0))
    print("Done successfully!")

def set_offset(argument):
    print("set_offset", argument)
    if(0.0<=float(argument) and float(argument)<=Vmax):
        serial_commander(portName, baudrateValue, int(1), int(72), int(14))
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def cal_offset(argument):
    print("cal_offset", argument)
    serial_commander(portName, baudrateValue, int(2), int(0), int(0))
    print("Done successfully!")

def offset(argument):
    print("offset", argument)
    if(argument=="manu"):
        serial_commander(portName, baudrateValue, int(3), int(0), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="auto"):
        serial_commander(portName, baudrateValue, int(3), int(1), int(0))
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu or auto !")
        print("Irregular command!")
        return 'false'

def set_threshold(argument):
    print("set_threshold", argument)
    if(0.0<=float(argument) and float(argument)<=Vmax):
        serial_commander(portName, baudrateValue, int(4), int(112), int(114))
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def capture(argument):
    print("capture", argument)
    if(argument=="adc"):
        serial_commander(portName, baudrateValue, int(5), int(0), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="cutted_offset"):
        serial_commander(portName, baudrateValue, int(5), int(1), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="filtered"):
        serial_commander(portName, baudrateValue, int(5), int(2), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="auto"):
        serial_commander(portName, baudrateValue, int(5), int(3), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="manu"):
        serial_commander(portName, baudrateValue, int(5), int(4), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="fire"):
        serial_commander(portName, baudrateValue, int(6), int(0), int(0))
        fire_ploter(portName, baudrateValue, SampleNumber, ADCPrecision)
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu, auto, filtered, cutted_offset, adc or fire !")
        print("Irregular command!")
        return 'false'

def set_ask(argument):
    print("set_ask", argument)
    if(0<=int(argument) and int(argument)<=255):
        serial_commander(portName, baudrateValue, int(7), int(argument), int(0))
        print("Done successfully!")
        return int(argument)
    else:
        print("Command argument should be a integer number in range: 0 <= argument and argument <= 255 !")
        print("Irregular command!")
        return 'false'

def ask(argument):
    print("ask", argument)
    if(argument=="counter"):
        serial_commander(portName, baudrateValue, int(8), int(2), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="value"):
        serial_commander(portName, baudrateValue, int(8), int(1), int(0))
        print("Done successfully!")
        return argument
    elif(argument=="off"):
        serial_commander(portName, baudrateValue, int(8), int(0), int(0))
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : counter, value or off !")
        print("Irregular command!")
        return 'false'

def serial_commander(portName, baudrateValue, cmd, arg0, arg1):
    ser=serial.Serial()
    ser.port = portName
    ser.baudrate = baudrateValue
    ser.open()
    # start Byte sign
    startByte=110
    si=(startByte).to_bytes(1, byteorder='big')
    ser.write(si)
    # cmd
    si=(cmd).to_bytes(1, byteorder='big')
    ser.write(si)
    # arg0
    si=(arg0).to_bytes(1, byteorder='big')
    ser.write(si)
    # arg1
    si=(arg1).to_bytes(1, byteorder='big')
    ser.write(si)
    # stop Byte sign
    stopByte=111
    si=(stopByte).to_bytes(1, byteorder='big')
    ser.write(si)
    '''# for loopback test
    i=0
    ii=[0, 0, 0, 0, 0]
    while i<5:
        ri = ser.read()
        ii[i] = int.from_bytes(ri, byteorder='big')
        i=i+1
    print("stop:", ii[4], " ,arg1:", ii[3], " ,arg0:", ii[2], " ,cmd:", ii[1], " ,start:", ii[0])
    #'''
    ser.close()

def fire_ploter(port, baudrate, SampleNumber, Precision):
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    # Start receve
    i=0
    ri = ser.read()
    ii0 = int.from_bytes(ri, byteorder='big')
    ri = ser.read()
    ii1 = int.from_bytes(ri, byteorder='big')
    sample_received=[Precision*float(ii1+ii0*(2**8))]
    i=i+1
    while ( i < SampleNumber ) :
        ri = ser.read()
        ii0 = int.from_bytes(ri, byteorder='big')
        ri = ser.read()
        ii1 = int.from_bytes(ri, byteorder='big')
        sample_received.append(Precision*float(ii1+ii0*(2**8)))
        i=i+1
    ser.close()
    # Plot
    i=0
    TimeSteps=[float(0)]
    freTest=float(SampleRate/51)
    SinusoidalWaveTest=[numpy.sin(2.0*numpy.pi*freTest*TimeSteps[0])]
    while (i<SampleNumber-1):
        TimeSteps.append(TimeSteps[i]+TimeStep)
        i=i+1
        SinusoidalWaveTest.append(numpy.sin(2.0*numpy.pi*freTest*TimeSteps[i]))
        freTest=freTest*1.001
    plt.plot(TimeSteps, sample_received)
    plt.plot(TimeSteps, sample_received, 'go')
    plt.ylabel('ADC Values (Volt)')
    plt.xlabel('Time (Second)')
    plt.grid()
    plt.show()

if __name__ == '__main__':
    main()
