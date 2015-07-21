import unittest
from cpm import *
from time import sleep
from random import *
import oct2py #delme


def randbits(sz):
    bits = [None]*sz
    for i in range(0, sz):
        bits[i] = randrange(0, 2)*2 - 1
    return bits

class Defaults(unittest.TestCase):
    def runTest(self):

        sz = 150
        bits=randbits(sz)

        demod = cpm_demod(cpm_mod(bits))

        self.assertEqual(bits,demod)

        # http://stackoverflow.com/questions/2612802/how-to-clone-or-copy-a-list-in-python
        bits2 = bits[:] # without [:] lists reffer to the same numbers

        bits2[0] *= -1 # flip a bit
        self.assertNotEqual(bits,bits2) # check we did it right

        demod2 = cpm_demod(cpm_mod(bits2)) # normal
        self.assertEqual(bits2,demod2)
        self.assertNotEqual(demod2,demod)


class ChangingOptionsIsKosher(unittest.TestCase):
    def runTest(self):

        # verify that using cpm with custom arguments does not modify the defaultCpmSettings hash
        sz = 150
        bits=randbits(sz)

        mod = cpm_mod(bits)
        mod2 = cpm_mod(bits, samplesPerSymbol=50)

        self.assertNotEqual(mod,mod2)

        mod3 = cpm_mod(bits)

        # assert mod != mod3
        self.assertEqual(mod,mod3)

class BitrateLimitations(unittest.TestCase):
    def runTest(self):

        # the fastest we can get at 125E3 with current demod
        fastCpmSettings = {'samplesPerSymbol': 4, 'rotationsPerSymbol': 1}

        sz = cpm_bits_per_packet(**fastCpmSettings)
        # print 'bits / packet:', sz

        bits=randbits(sz)
        mod = cpm_mod(bits,**fastCpmSettings)
        demod = cpm_demod(mod,**fastCpmSettings)

        assert bits == demod

        # print 'starting octave'
        # octave = oct2py.Oct2Py()
        # octave.addpath('../../simulink')
        # octave.plot(octave.imag(mod))
        # octave.push('m', mod)
        # octave.eval("fplot(m', 125E3)")
        # time.sleep(500)

class TestBitsPer(unittest.TestCase):
    def runTest(self):
        someCpmSettings = {'samplesPerSymbol': 50, 'rotationsPerSymbol': 1}

        bits=[-1,1] # too small on purpose, cpm mod will pad this out

        demod = cpm_demod(cpm_mod(bits, **someCpmSettings), **someCpmSettings)

        # verify that we did pad the bit vector
        self.assertNotEqual(demod, bits)

        # calculate how many bits we should be able to do
        sz = cpm_bits_per_packet(**someCpmSettings)

        self.assertEqual(len(demod), sz, "something wrong with cpm_bits_per_packet calculation or cpm_mod")

        sz2 = cpm_bits_per_packet()

        self.assertNotEqual(len(demod),sz2)



if __name__ == "__main__":
    unittest.main()