import unittest
from sigsource import *
from sigsink import *
from time import sleep
from siglabs_pb2 import *
from sigmath import *
from sigproto import *

class BasicConnection(unittest.TestCase):
    def runTest(self):
        a = Packet()
        a.radio = 12345
        a.sequence = 127
        a.type = Packet.HELLO

        assert a.IsInitialized()

        # print a.__str__()

        str =  a.SerializeToString()
        # print "len", len(str), ' ',str
        # print_dec(str)

        b = Packet()

        b.ParseFromString(str)

        # print "----"
        # print a.__str__()
        # print "----"
        # print b.__str__()

        assert a == b




if __name__ == "__main__":
    unittest.main()