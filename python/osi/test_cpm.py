import unittest
from cpm import *
from time import sleep
from random import *


class BasicPyObj(unittest.TestCase):
    def runTest(self):

        sz = 150
        bits = [None]*sz

        for i in range(0, sz):
            bits[i] = randrange(0, 2)*2 - 1

        demod = cpm_demod(cpm_mod(bits))

        # http://stackoverflow.com/questions/2612802/how-to-clone-or-copy-a-list-in-python
        bits2 = bits[:] # without [:] lists reffer to the same numbers

        bits2[0] *= -1 # flip a bit
        assert bits != bits2 # check we did it right

        demod2 = cpm_demod(cpm_mod(bits2)) # normal
        assert bits2 == demod2
        assert demod2 != demod


if __name__ == "__main__":
    unittest.main()