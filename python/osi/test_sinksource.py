import unittest
from sigsource import *
from sigsink import *
from time import sleep

class BasicConnection(unittest.TestCase):
    def runTest(self):

        sink = SigSink(4000)
        source = SigSource()
        source.connect(sink)
        sleep(1E-3) # sleep after connection

        # check nothing is there
        assert not source.waiting()

        datain = 'hello'

        sink.send(datain)
        sleep(1E-3)

        # check something is there
        assert source.waiting()

        # check that it was correct
        dataout = source.get()
        assert datain == dataout

        # check nothing is there
        assert not source.waiting()



if __name__ == "__main__":
    unittest.main()