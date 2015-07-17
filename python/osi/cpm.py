import struct
import numpy as np
import sigproto
import collections
from itertools import repeat
import oct2py #delme
import time
from sigmath import *

def cpm_mod2(bits, bitsrate = 1/125E1, srate = 1/125E3, samplesPerSymbol = 100, rotationsPerSymbol = 1, patternVector = [1,1,0,2,1,0,2,2,1,0,0,1,1,1,0,2,2,0,2,2]):
    print bitsrate

    rateRatio = bitsrate/srate
    demodSamplesPerSymbol = samplesPerSymbol
    outSampleTime = srate

    clockFrequency = 100
    dinFilterLength = 3

    dataout = []
    clock_comb = []

    # init
    totalSamples = 0
    dataInt = 0.0
    clockUpInt = 0.0
    clockDownInt = 0.0

    # more init
    fs = 1/srate
    # fixed packet length in seconds
    packetLength = 0.4

    pvSize = len(patternVector)
    dataDutyCycle = float(patternVector.count(0))/pvSize

    sz = len(bits)

    expectedBitLength = int(round( (1/bitsrate)*packetLength*dataDutyCycle ))

    print expectedBitLength

    if sz != expectedBitLength:
        print('warning: bit vector is the wrong size');

    if sz < expectedBitLength:
        delta = expectedBitLength - sz
        bits = bits + [-1]*delta
        sz = len(bits)

    # print bits

    # mulitply up like simulink does, this could be our biggest savings
    bitVector = [x for item in bits for x in repeat(item, int(rateRatio))]

    print "rateRatio", rateRatio
    print "sampprsym", samplesPerSymbol
    print "srate", srate
    print "fs", fs
    print "expectedBitLength", expectedBitLength
    print "len bitvector", len(bitVector)

    dataout = [None] * int(packetLength/srate)

    j = 0

    for currentTime in drange(0,packetLength,srate):
        din = bitVector[j]
        scaledTimeIndex = int((currentTime / packetLength) * pvSize)
        # print "ct", currentTime, "sti", scaledTimeIndex

        mode = patternVector[scaledTimeIndex % pvSize]

        # 1/rotations per bit.
        # each bit is 10 data points (when samplesPerSymbol is 10)
        # so a clock with 1000 points for rotation would be 1/100
        df = rotationsPerSymbol

        cdf = outSampleTime * clockFrequency * samplesPerSymbol


        # always run clock "movies"
        clockUpInt   = clockUpInt   + (1.0 / samplesPerSymbol)
        clockDownInt = clockDownInt - (1.0 / samplesPerSymbol)
        ddt = float(din) / samplesPerSymbol
        dataInt = dataInt + ddt

        if mode == 0:
            crout = 0
            ciout = 0
        if mode == 1:
            crout = np.cos(cdf * 2 * np.pi * clockUpInt)
            ciout = np.sin(cdf * 2 * np.pi * clockUpInt)
        if mode == 2:
            crout = np.cos(cdf * 2 * np.pi * clockDownInt)
            ciout = np.sin(cdf * 2 * np.pi * clockDownInt)

        # Data only output port (mostly useless)
        rout = np.cos(df * 2 * np.pi * dataInt)
        iout = np.sin(df * 2 * np.pi * dataInt)

        # modulation output port ('t' stands for 3rd)
        trout = crout
        tiout = ciout

        # 0 is data, 1 is clock up, 2 is clock down
        if mode == 0:
            # mode 0 so put in data
            trout = rout
            tiout = iout

        if currentTime > packetLength:
            trout = 0 # end packet
            tiout = 0
            crout = 0
            ciout = 0
            print 'packet is already over', currentTime

        dataout[totalSamples] = np.complex(trout,tiout)

        totalSamples += 1

        # only advance bit pattern when in the right mode
        if mode == 0:
            j += 1
            j = int(min(j,(expectedBitLength*rateRatio)-1))
            # print j, currentTime

    return dataout




if __name__ == '__main__':

    bits = [-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1]    # convert to numpy vec of 0,1
    # bits = bits[:,np.newaxis] # convert to columnar vec

    data = cpm_mod2(bits)

    print 'starting octave'
    octave = oct2py.Oct2Py()
    octave.addpath('../../simulink')
    octave.plot(octave.imag(data))



    time.sleep(500)

