import unittest
from sigsource import *
from sigsink import *
from time import sleep
from siglabs_pb2 import *
from sigmath import *

class BasicConnection(unittest.TestCase):
    def runTest(self):
        a = Packet()
        a.radio = 12345
        a.sequence = 1
        a.type = 0

        # assert a.IsInitialized()

        print a.__str__()

        str =  a.SerializeToString()
        print "len", len(str), ' ',str
        print_dec(str)


        # b = PacketB()
        # b.radio = 12345
        # b.sequence = 1
        #
        #
        # str =  b.SerializeToString()
        # print "len", len(str), ' ',str
        # print_dec(str)




if __name__ == "__main__":
    unittest.main()