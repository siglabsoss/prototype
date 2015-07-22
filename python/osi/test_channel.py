import unittest
from cpm import *
from time import sleep
from random import *
import oct2py #delme
from channel import *



class Defaults(unittest.TestCase):
    def runTest(self):
        cnt = channel_count()

        with self.assertRaises(RuntimeError):
            channel_center(cnt)
        with self.assertRaises(RuntimeError):
            channel_center(cnt+1)

        c = Channel('1')

        c.changehz(sigproto.unlicensed_min)
        c.changehz(sigproto.unlicensed_max)

        with self.assertRaises(RuntimeError):
            c.changehz(sigproto.unlicensed_max+1)


class InAndOut(unittest.TestCase):
    def runTest(self):


        chosen_index = 32

        hz = channel_center(chosen_index)

        index = channel_by_hz(hz)

        self.assertEqual(index, chosen_index)




if __name__ == "__main__":
    unittest.main()
