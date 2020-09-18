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

import serial
import random
import os
import time
import numpy
import matplotlib.pyplot as plt

print("In the Name of ALLAH")
print("Universal Asynchronous Receiver Transmitter UART Ploter:")

def LTC2312SerialReceiver(port, baudrate, SampleNumber, Precision):
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    # Start fire
    si=(110).to_bytes(1, byteorder='big')
    ser.write(si)
    # Start receve
    i=0
    ri = ser.read()
    ii0 = int.from_bytes(ri, byteorder='big')
    ri = ser.read()
    ii1 = int.from_bytes(ri, byteorder='big')
    LTC2312=[Precision*float(ii1+ii0*(2**8))]
    i=i+1
    while ( i < SampleNumber ) :
        ri = ser.read()
        ii0 = int.from_bytes(ri, byteorder='big')
        ri = ser.read()
        ii1 = int.from_bytes(ri, byteorder='big')
        LTC2312.append(Precision*float(ii1+ii0*(2**8)))
        i=i+1
    ser.close()
    return LTC2312

# Serial Port
portName='/dev/ttyUSB0'
baudrateValue = 80000

# LTC2312
SampleRate=200000
SampleNumber=2048
TimeStep=1/SampleRate
ADCPrecision=2.048/(2**14)

i=0
TimeSteps=[float(0)]
freTest=float(SampleRate/51)
SinusoidalWaveTest=[numpy.sin(2.0*numpy.pi*freTest*TimeSteps[0])]
while (i<SampleNumber-1):
    TimeSteps.append(TimeSteps[i]+TimeStep)
    i=i+1
    SinusoidalWaveTest.append(numpy.sin(2.0*numpy.pi*freTest*TimeSteps[i]))
    freTest=freTest*1.001

LTC2312=LTC2312SerialReceiver(portName, baudrateValue, SampleNumber, ADCPrecision)

plt.plot(TimeSteps, LTC2312)
plt.plot(TimeSteps, LTC2312, 'go')
plt.ylabel('ADC Values (Volt)')
plt.xlabel('Time (Second)')
plt.grid()
plt.show()
