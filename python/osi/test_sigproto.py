import unittest
import sigmath as sm
from sigproto import *
from random import *

class Basics(unittest.TestCase):
    def runTest(self):

        str = encode_varint(127)
        assert len(str) == 1
        val = decode_varint(str)
        assert val == 127

        str = encode_varint(128)
        assert len(str) == 2
        val = decode_varint(str)
        assert val == 128

        for i in range(1,10):
            valin = randrange(0, 2**63)
            assert valin == decode_varint(encode_varint(valin))

class StringPlusJunk(unittest.TestCase):
    def runTest(self):

        for pow in range(0,63):
            val = 2**pow
            str = encode_varint(val)
            assert val == decode_varint(str)
            assert val == decode_varint(str+"junk")

            val = 2**pow - 1
            str = encode_varint(val)
            assert val == decode_varint(str)
            assert val == decode_varint(str+"junk")




if __name__ == "__main__":
    unittest.main()