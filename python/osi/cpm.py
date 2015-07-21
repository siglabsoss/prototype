import struct
from sigproto import defaultCpmSettings
import collections
from itertools import repeat
import time
from sigmath import *
import timeit


def cpm_bits_per_packet(**kwargs):
    #http://stackoverflow.com/a/1552420/836450
    args = dict(defaultCpmSettings, **kwargs)

    # unload arguments from args dictionary
    fs = args['fs']
    samplesPerSymbol = args['samplesPerSymbol']
    patternVector = args['patternVector']

    packetLength = 0.4
    srate = 1/fs


    bitsrate = srate * samplesPerSymbol

    pvSize = len(patternVector)
    dataDutyCycle = float(patternVector.count(0))/pvSize

    expectedBitLength = int(round( (1/bitsrate)*packetLength*dataDutyCycle ))

    return expectedBitLength




def cpm_mod(bits, **kwargs):
    #http://stackoverflow.com/a/1552420/836450
    args = dict(defaultCpmSettings, **kwargs)

    # unload arguments from args dictionary
    fs = args['fs']
    samplesPerSymbol = args['samplesPerSymbol']
    rotationsPerSymbol = args['rotationsPerSymbol']
    patternVector = args['patternVector']

    srate = 1/fs
    bitsrate = srate * samplesPerSymbol
    # print "\n bitsrate = ", bitsrate

    rateRatio = bitsrate/srate
    outSampleTime = srate

    clockFrequency = 100
    dinFilterLength = 3

    clock_comb = []

    # init
    totalSamples = 0
    dataInt = 0.0
    clockUpInt = 0.0
    clockDownInt = 0.0

    # fixed packet length in seconds
    packetLength = 0.4

    pvSize = len(patternVector)
    dataDutyCycle = float(patternVector.count(0))/pvSize

    sz = len(bits)

    expectedBitLength = cpm_bits_per_packet(**kwargs)

    # expectedBitLength = int(round( (1/bitsrate)*packetLength*dataDutyCycle ))

    # print expectedBitLength

    # if sz != expectedBitLength:
    #     print('warning: bit vector is the wrong size');

    if sz < expectedBitLength:
        delta = expectedBitLength - sz
        bits = bits + [-1]*delta
        sz = len(bits)

    # print bits

    # mulitply up like simulink does, this could be our biggest savings
    bitVector = [x for item in bits for x in repeat(item, int(rateRatio))]

    # print "rateRatio", rateRatio
    # print "sampprsym", samplesPerSymbol
    # print "srate", srate
    # print "fs", fs
    # print "expectedBitLength", expectedBitLength
    # print "len bitvector", len(bitVector)

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



def cpm_demod(data, **kwargs):
    #http://stackoverflow.com/a/1552420/836450
    args = dict(defaultCpmSettings, **kwargs)

    # unload arguments from args dictionary
    fs = args['fs']
    samplesPerSymbol = args['samplesPerSymbol']
    patternVector = args['patternVector']

    dif = np.diff(unroll_angle(np.angle(data)))

    # init
    srate = 1/fs

    # fixed packet length in seconds
    packetLength = 0.4
    sz = len(data)
    pvSize = len(patternVector)
    dataDutyCycle = float(patternVector.count(0))/pvSize
    expectedBitLength = int(round( sz / samplesPerSymbol * dataDutyCycle))

    period = (fs * packetLength) / pvSize # how many samples per pattern period

    # pre allocate output
    bits = [None] * expectedBitLength

    # count for output
    count = 0

    for i in range(0,pvSize):

        # skip clock parts of data vector
        if patternVector[i] != 0:
            continue

        # start and end of the bit period
        start = int(i*period)
        end = int((i+1)*period)

        for j in range(start,end,samplesPerSymbol):
            s = sum(dif[j:j+samplesPerSymbol])
            bit = 1 if s > 0 else -1
            bits[count] = bit
            count += 1

    return bits
