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




if __name__ == "__main__":
    unittest.main()
