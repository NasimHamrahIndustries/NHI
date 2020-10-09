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
MDM_Development_Bench_Arch="""MDM Development Bench:
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Commands:                                                                                                 ___                                      //
//  reset                   : Reset registers to default values and states                                  |   \      _______                        //
//  set_ask VALUE           : E.g. set_ask 113  (It means  d113=b01110001)                            off --|a   \    |       |                       //
//  ask a/b/c               : Set mux stream direction                                                      |     |   |       |--> MULP  _   _        //
//  set_offset VALUE        : E.g. set_offset 0.04                                           set_ask VALUE  |     |   |  ASK  |         | | | |       //
//  cal_offset              : Calculate offset value in Auto Offset Cutter block               {0:0>8b} ====|b   {1}|===|       |      ---' | | | ,---  //
//  offset a/b              : Set mux stream direction                                         _________    |     |   | 5kb/s |           |_| |_|     //
//  filter a/b              : Set mux stream direction                                        |         |   |     |   |       |--> MULN   10kHz       //
//  set_upthreshold VALUE   : E.g. set_upthreshold 0.81                                       | Counter |===|c   /    |_______|                       //
//  set_downthreshold VALUE : E.g. set_downthreshold 1.45                                     |_________|   |___/                          /\         //
//  capture a/b/c/d/e/f     : Set mux stream direction                                                       ask                     ___   ''    ___  //
//  capture fire            : Capture 2048 samples from selected stream                                           Equal UART Pulse :    |_______|     //
//  exit                    : Exit                                                                                                                    //
//                                                                      set_upthreshold VALUE          set_downthreshold VALU                         //
//                                                                                    {5:.1f} ====o    o==== {6:.1f}                                        //
//                                                                                          ___|____|___                                              //
//                                                                                         |            |   __                                        //
//                      ___                                      ____________    __        |   Manual   |  |  \                                       //
//   set_offset VALUE  |   |                                    |            |  |  \    o==| Threshold  |==|a  \                                      //
//            {2:.2f} ====|   |==o                              o==|  Filter0   |==|a  \   |  |  Detector  |  |    \                                     //
//                    -|>  |  |                              |  | Integrator |  |    |  |  |____________|  |     |                                    //
//                     |___|  |        __                    |  |____________|  |    |  |   ____________   |     |                 ______             //
//          _____             |       |  \                   |                  |   {4}|==O  |            |  |     |  capture fire  |      |            //
//         |     |     o=====(-)======|a  \       ________   |   ____________   |    |  |  | Automatic  |  |     |    ________    | UART |            //
//  SDO -->|     |     |   ________   |    |     |        |  |  |            |  |    |  O==| Threshold  |==|b    |   | FIFO __|===| 125  |--> UART_TX //
//         | ADC |==O==O  |        |  |   {3}|==O==| Filter |==O==|  Filter1   |==|b  /   |  |  Detector  |  |     |   | 16  /      | kb/s |            //
//  SCK <--|     |  |  |  |  Auto  |  |    |  |  |  FIR   |  |  | Integrator |  |__/    |  |____________|  |    {7}|===| to /       |______|            //
//         |     |  |  o==| Offset |==|b  /   |  |________|  |  |____________| filter   |                  |     |   | 8 /                            //
// CONV <--|     |  |     | Cutter |  |__/    |              |                          o==================|c    |   |__/                             //
//         |_____|  |     |________| offset   |              |                                             |     |  2048 sample                       //
//                  |         |               |              o=============================================|d    |                                    //
//                  |     cal_offset          |                                                            |     |                                    //
//                  |                         o============================================================|e    |                                    //
//                  |                                                                                      |    /                                     //
//                  o======================================================================================|f  /                                      //
//                                                                                                         |__/                                       //
//                                                                                                        capture                                     //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"""
'''
//Instructions:
// command_type       argument  cmd   arg0  arg1
// reset                        h00   h00   h00
// set_ask            dxxx      h01   hXX   h00
// ask                a         h02   h00   h00
//                    b         h02   h01   h00
//                    c         h02   h02   h00
// set_offset         fx.xx     h03   hXX   hXX
// cal_offset                   h04   h00   h00
// offset             a         h05   h00   h00
//                    b         h05   h01   h00
// filter             a         h06   h00   h00
//                    b         h06   h01   h00
// set_upthreshold    fx.xx     h07   hXX   hXX
// set_downthreshold  fx.xx     h08   hXX   hXX
// capture            a         h09   h00   h00
//                    b         h09   h01   h00
//                    c         h09   h02   h00
//                    d         h09   h03   h00
//                    e         h09   h04   h00
//                    f         h09   h05   h00
// capture            fire      h0A   h00   h00
'''

def main():
    print("In the Name of ALLAH")
    ask_value=0
    ask_mux='a'
    offset_value=0.0
    offset_mux='a'
    filter_mux='a'
    upthreshold_value=27
    downthreshold_value=13
    capture_mux='a'
    reset(' ')
    while 'true':
        print(MDM_Development_Bench_Arch.format(ask_value, ask_mux, offset_value, offset_mux, filter_mux, upthreshold_value, downthreshold_value, capture_mux))
        command = input("Please enter your command:\n")
        separated_command=command.partition(' ')
        command_type=separated_command[0]
        argument=separated_command[2]
        del separated_command
        if(command_type=="reset"):
            ask_value=0
            ask_mux='a'
            offset_value=0.0
            offset_mux='a'
            filter_mux='a'
            upthreshold_value=27
            downthreshold_value=13
            capture_mux='a'
            clear()
            reset(argument)
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
        elif(command_type=="filter"):
            clear()
            val=filter(argument)
            if(val!='false'):
                filter_mux=val
        elif(command_type=="set_upthreshold"):
            clear()
            val=set_upthreshold(argument)
            if(val!='false'):
                upthreshold_value=val
        elif(command_type=="set_downthreshold"):
            clear()
            val=set_downthreshold(argument)
            if(val!='false'):
                downthreshold_value=val
        elif(command_type=="capture"):
            clear()
            val=capture(argument)
            if(val!='false' and val!='fire'):
                capture_mux=val
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

def set_ask(argument):
    print("set_ask", argument)
    if(0<=int(argument) and int(argument)<=255):
        serial_commander(portName, baudrateValue, int(1), int(argument), int(0))
        print("Done successfully!")
        return int(argument)
    else:
        print("Command argument should be a integer number in range: 0 <= argument and argument <= 255 !")
        print("Irregular command!")
        return 'false'

def ask(argument):
    if(argument=="a"):
        serial_commander(portName, baudrateValue, int(2), int(0), int(0))
        print("ask off")
        print("Done successfully!")
        return argument
    elif(argument=="b"):
        serial_commander(portName, baudrateValue, int(2), int(1), int(0))
        print("ask value")
        print("Done successfully!")
        return argument
    elif(argument=="c"):
        serial_commander(portName, baudrateValue, int(2), int(2), int(0))
        print("ask Counter")
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : counter, value or off !")
        print("Irregular command!")
        return 'false'

def set_offset(argument):
    if(0.0<=float(argument) and float(argument)<=Vmax):
        serial_commander(portName, baudrateValue, int(3), int(72), int(14))
        print("set_offset", argument)
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def cal_offset(argument):
    serial_commander(portName, baudrateValue, int(4), int(0), int(0))
    print("cal_offset", argument)
    print("Done successfully!")

def offset(argument):
    if(argument=="a"):
        serial_commander(portName, baudrateValue, int(5), int(0), int(0))
        print("Manual Offset Cutter")
        print("Done successfully!")
        return argument
    elif(argument=="b"):
        serial_commander(portName, baudrateValue, int(5), int(1), int(0))
        print("Auto Offset Cutter")
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu or auto !")
        print("Irregular command!")
        return 'false'

def filter(argument):
    if(argument=="a"):
        serial_commander(portName, baudrateValue, int(6), int(0), int(0))
        print("Filter0 Integrator")
        print("Done successfully!")
        return argument
    elif(argument=="b"):
        serial_commander(portName, baudrateValue, int(6), int(1), int(0))
        print("Filter1 Integrator")
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu or auto !")
        print("Irregular command!")
        return 'false'

def set_upthreshold(argument):
    if(0.0<=float(argument) and float(argument)<=Vmax):
        print("set_upthreshold", argument)
        serial_commander(portName, baudrateValue, int(7), int(112), int(114))
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def set_downthreshold(argument):
    if(0.0<=float(argument) and float(argument)<=Vmax):
        print("set_downthreshold", argument)
        serial_commander(portName, baudrateValue, int(8), int(112), int(114))
        print("Done successfully!")
        return float(argument)
    else:
        print("Command argument should be a float number in range: 0.0 <= argument and argument <=", Vmax, "!")
        print("Irregular command!")
        return 'false'

def capture(argument):
    if(argument=="a"):
        serial_commander(portName, baudrateValue, int(9), int(0), int(0))
        print("Manual Threshold ASK Detector")
        print("Done successfully!")
        return argument
    elif(argument=="b"):
        serial_commander(portName, baudrateValue, int(9), int(1), int(0))
        print("Automatic Threshold ASK Detector")
        print("Done successfully!")
        return argument
    elif(argument=="c"):
        serial_commander(portName, baudrateValue, int(9), int(2), int(0))
        print("Filter Integrator")
        print("Done successfully!")
        return argument
    elif(argument=="d"):
        serial_commander(portName, baudrateValue, int(9), int(3), int(0))
        print("Filter FIR")
        print("Done successfully!")
        return argument
    elif(argument=="e"):
        serial_commander(portName, baudrateValue, int(9), int(4), int(0))
        print("Offset Cutter")
        print("Done successfully!")
        return argument
    elif(argument=="f"):
        serial_commander(portName, baudrateValue, int(9), int(5), int(0))
        print("ADC")
        print("Done successfully!")
        return argument
    elif(argument=="fire"):
        print("capture fire")
        serial_commander(portName, baudrateValue, int(10), int(0), int(0))
        fire_ploter(portName, baudrateValue, SampleNumber, ADCPrecision)
        print("Done successfully!")
        return argument
    else:
        print("Command argument should be : manu, auto, filtered, cutted_offset, adc or fire !")
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
