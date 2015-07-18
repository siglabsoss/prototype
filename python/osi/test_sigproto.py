import unittest
from sigmath import *
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

if __name__ == "__main__":
    unittest.main()